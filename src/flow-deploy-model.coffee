_       = require 'lodash'
request = require 'request'
debug   = require('debug')('flow-deploy-service:flow-deploy-model')
Container = require './container'
FlowStatusMessenger = require './flow-status-messenger'

class FlowDeployModel
  constructor: (options={}, dependencies={}) ->
    {@flowId, @userMeshbluConfig, @serviceMeshbluConfig, @deploymentUuid} = options
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

  useContainer: (flow, topic, callback=->) =>
    container = new Container
      uuid: flow.uuid
      token: flow.token
      deploymentUuid: @deploymentUuid
      image: 'octoblu/flow-runner:latest'

    container[topic]? callback

  pause: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->pause @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:pause', {}, (error) =>
        debug '->pause @useContainer', error
        callback error

  resume: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->resume @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:resume', {}, (error) =>
        debug '->resume @useContainer', error
        callback error

  save: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->save @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save', stateId: id, (error) =>
        debug '->save @useContainer', error

        @didSave id, callback

  savePause: (id, callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->savePause @find', error
      return callback error if error?

      @sendFlowMessage flow, 'flow:save-pause', stateId: id, (error) =>
        debug '->savePause @useContainer', error

        @didSave id, callback

  start: (callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update @flowId, deploying: true

    flowStatusMessenger = new FlowStatusMessenger meshbluHttp,
      userUuid: @userMeshbluConfig.uuid
      flowUuid: @flowId
      deploymentUuid: @deploymentUuid
      workflow: 'flow-start'

    flowStatusMessenger.message 'begin'

    @_start (error) =>
      if error?
        flowStatusMessenger.message 'error', error.message
        return callback error

      flowStatusMessenger.message 'end'
      callback null

  _start: (callback=->) =>
    @find @flowId, (error, flow) =>
      debug '->_start @find', error
      return callback error if error?

      @resetToken @flowId, (error, token) =>
        debug '->_start @resetToken', error
        return callback error if error?
        flow.token = token

        @clearState @flowId, (error) =>
          debug '->_start @clearState', error
          return callback error if error?

          @useContainer flow, 'create', (error) =>
            debug '->_start @useContainer', error
            callback error

  stop: (callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update @flowId, stopping: true

    flowStatusMessenger = new FlowStatusMessenger meshbluHttp,
      userUuid: @userMeshbluConfig.uuid
      flowUuid: @flowId
      deploymentUuid: @deploymentUuid
      workflow: 'flow-stop'

    flowStatusMessenger.message 'begin'

    @_stop (error) =>
      _.delay =>
        meshbluHttp.update @flowId, stopping: false
      , 10000

      if error?
        flowStatusMessenger.message 'error', error.message
        return callback error

      flowStatusMessenger.message 'end'
      callback null

  _stop: (callback=->) =>
    @find @flowId, (error, flow) =>
      return callback error if error?
      @useContainer flow, 'delete', (error) =>
        callback error

module.exports = FlowDeployModel
