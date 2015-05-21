_ = require 'lodash'
request = require 'request'
debug = require('debug')('flow-deploy-service:flow-deploy-model')
FlowConverterModel = require './flow-converter-model'

class FlowDeployModel
  constructor: (@flowId, @meshbluConfig, dependencies={}) ->
    @MeshbluHttp = dependencies.MeshbluHttp || require 'meshblu-http'

  convertFlow: (flow) =>
    flowConverter = new FlowConverterModel flow
    flowConverter.convert

  find: (flowId, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.device flowId, callback

  sendMessage: (flow, topic, callback=->) =>
    convertedFlow = @convertFlow flow
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.mydevices type: 'nodered-docker-manager', (error, devices) ->
      msg =
        devices: _.pluck devices, 'uuid'
        topic: topic
        qos: 0

      debug 'sendMessage.token', flow.token

      msg.payload =
        uuid: flow.flowId
        token: flow.token
        image: 'octoblu/flow-runner:latest'
        flow: convertedFlow

      meshbluHttp.message msg, (error) =>
        callback error

  start: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @sendMessage flow, 'nodered-instance-start', ->
        callback()

  stop: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @sendMessage flow, 'nodered-instance-stop', ->
        callback()

module.exports = FlowDeployModel
