_ = require 'lodash'
request = require 'request'
debug = require('debug')('flow-deploy-service:flow-deploy-model')

class FlowDeployModel
  constructor: (@flowId, @userMeshbluConfig, @serviceMeshbluConfig, dependencies={}) ->
    @MeshbluHttp = dependencies.MeshbluHttp || require 'meshblu-http'

  clearState: (uuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update states: null, uuid: uuid, callback

  find: (flowId, callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.device flowId, (error, device) =>
      return callback error if error?
      callback null, device

  resetToken: (flowId, callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.resetToken flowId, (error, result) =>
      callback error, result?.token

  sendMessage: (flow, topic, callback=->) =>
    meshbluHttp = new @MeshbluHttp @serviceMeshbluConfig
    meshbluHttp.mydevices type: 'octoblu:octo-master', online: true, (error, data) =>
      return callback error if error?
      deviceId = _.sample _.pluck(data.devices, 'uuid')
      msg =
        devices: [deviceId]
        topic: topic

      debug 'sendMessage.token', flow.token

      msg.payload =
        uuid: flow.uuid
        token: flow.token
        image: 'octoblu/flow-runner:latest'

      meshbluHttp.message msg, (error) =>
        callback error

  start: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->start @find', error
      return callback error if error?

      @resetToken @flowId, (error, token) =>
        debug '->start @resetToken', error
        return callback error if error?
        flow.token = token

        @clearState @flowId, (error) =>
          debug '->start @clearState', error
          return callback error if error?

          @sendMessage flow, 'create', (error) ->
            debug '->start @sendMessage', error
            return callback error

  stop: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @sendMessage flow, 'delete', (error) ->
        callback error

module.exports = FlowDeployModel
