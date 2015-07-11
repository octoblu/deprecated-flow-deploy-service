_       = require 'lodash'
request = require 'request'
debug   = require('debug')('flow-deploy-service:flow-deploy-model')

class FlowDeployModel
  constructor: (@flowId, @userMeshbluConfig, @serviceMeshbluConfig, dependencies={}) ->
    @MeshbluHttp = dependencies.MeshbluHttp ? require 'meshblu-http'
    @async = dependencies.async ? require 'async'
    @TIMEOUT = dependencies.TIMEOUT ? 60 * 1000
    @WAIT = dependencies.WAIT ? 2000

  clearState: (uuid, callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update uuid, states: null, callback

  didSave: (id, callback=->) =>
    debug 'didSave', id
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    timeLimit = _.now() + @TIMEOUT
    wait = 0
    @async.doUntil (next) =>
      return next new Error 'Save Timeout' if _.now() > timeLimit
      setTimeout =>
        meshbluHttp.device @flowId, next
      , wait
      debug 'doUntil loop wait', wait
      wait = @WAIT
    , (device) =>
      return device.stateId == id
    , (error) =>
      debug 'didSave error', error
      callback error

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

      @sendFlowMessage flow, 'flow:pause', {}, (error) =>
        debug '->pause @sendMessage', error
        callback error

  resume: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->resume @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:resume', {}, (error) =>
        debug '->resume @sendMessage', error
        callback error

  save: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->save @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save', stateId: id, (error) =>
        debug '->save @sendMessage', error

        @didSave id, callback

  savePause: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->savePause @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save-pause', stateId: id, (error) =>
        debug '->savePause @sendMessage', error

        @didSave id, callback

  start: (callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update @flowId, deploying: true
    @find @flowId, (error, flow) =>
      @sendFlowMessage flow, 'step-change', step: 2
      debug '->start @find', error
      return callback error if error?

      @resetToken @flowId, (error, token) =>
        @sendFlowMessage flow, 'step-change', step: 3
        debug '->start @resetToken', error
        return callback error if error?
        flow.token = token

        @clearState @flowId, (error) =>
          @sendFlowMessage flow, 'step-change', step: 4
          debug '->start @clearState', error
          return callback error if error?

          @sendMessage flow, 'create', (error) =>
            @sendFlowMessage flow, 'step-change', step: 5
            debug '->start @sendMessage', error
            meshbluHttp.update @flowId, deploying: false
            callback error

  stop: (callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update @flowId, stopping: true
    @find @flowId, (error, flow) =>
      @sendFlowMessage flow, 'step-change', step: -2
      return callback error if error?
      @sendMessage flow, 'delete', (error) =>
        @sendFlowMessage flow, 'step-change', step: -3
        meshbluHttp.update @flowId, stopping: false
        callback error

module.exports = FlowDeployModel
