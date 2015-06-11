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

  sendFlowMessage: (flow, topic, payload, callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    msg =
      devices: [flow.uuid]
      topic: topic

    debug 'sendFlowMessage.token', flow.token

    msg.payload = payload

    meshbluHttp.message msg, (error) =>
      callback error

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

  pause: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->pause @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:pause', {}, (error) ->
        debug '->pause @sendMessage', error
        return callback error

  resume: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->resume @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:resume', {}, (error) ->
        debug '->resume @sendMessage', error
        return callback error

  save: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->save @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save', stateId: id, (error) ->
        debug '->save @sendMessage', error
        return callback error

  savePause: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->savePause @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save-pause', stateId: id, (error) ->
        debug '->savePause @sendMessage', error
        return callback error

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
