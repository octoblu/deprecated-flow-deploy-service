_       = require 'lodash'
request = require 'request'
debug   = require('debug')('flow-deploy-service:flow-deploy-model')
Container = require './container'

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

  useContainer: (flow, topic, callback=->) =>
    container = new Container uuid: flow.uuid, token: flow.token, image: 'octoblu/flow-runner:latest'
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

          @useContainer flow, 'create', (error) =>
            debug '->start @useContainer', error
            callback error

  stop: (callback=->) =>
    meshbluHttp = new @MeshbluHttp @userMeshbluConfig
    meshbluHttp.update @flowId, stopping: true
    @find @flowId, (error, flow) =>
      return callback error if error?
      @useContainer flow, 'delete', (error) =>
        _.delay =>
          meshbluHttp.update @flowId, stopping: false
        , 10000
        callback error

module.exports = FlowDeployModel
