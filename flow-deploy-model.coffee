_ = require 'lodash'
request = require 'request'
FlowConverterModel = require './flow-converter-model'
MeshbluHttp = require 'meshblu-http'

class FlowDeployModel
  constructor: (@flowId, @meshbluConfig) ->

  start: (callback=->) =>
    @find @flowId, (flow) =>
      @sendMessage flow, 'nodered-instance-start', callback

  sendMessage: (flow, topic) =>
    convertedFlow = @convertFlow flow
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.mydevices type: 'nodered-docker-manager', (data) ->
      managerDevices = data.devices
      devices = _.pluck managerDevices, 'uuid'
      msg =
        devices: devices
        topic: topic
        qos: 0

      debug 'sendMessage.token', flow.token

      msg.payload =
        uuid: flow.flowId
        token: flow.token
        flow: convertedFlow

      meshbluHttp.message msg

  find: (flowId) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    meshbluHttp.mydevices type: 'nodered-docker-manager', (data) ->

  convertFlow: (flow) =>
    flowConverter = new FlowConverterModel flow
    flowConverter.convert

module.exports = FlowDeployModel
