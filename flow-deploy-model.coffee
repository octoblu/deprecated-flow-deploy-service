_ = require 'lodash'
request = require 'request'
debug = require('debug')('flow-deploy-service:flow-deploy-model')

class FlowDeployModel
  constructor: (@flowId, @meshbluConfig, dependencies={}) ->
    @MeshbluHttp = dependencies.MeshbluHttp || require 'meshblu-http'

  find: (flowId, callback=->) =>
    meshbluHttp = new @MeshbluHttp @meshbluConfig
    meshbluHttp.device flowId, (error, device) =>
      return callback error if error?
      callback null, device

  sendMessage: (flow, topic, callback=->) =>
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

      meshbluHttp.message msg, (error) =>
        callback error

  start: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @sendMessage flow, 'nodered-instance-start', (error) ->
        callback error

  stop: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @sendMessage flow, 'nodered-instance-stop', (error) ->
        callback error

module.exports = FlowDeployModel
