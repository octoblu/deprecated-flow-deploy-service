MeshbluHttp     = require 'meshblu-http'
FlowDeployModel = require './flow-deploy-model'
_            = require 'lodash'
debug        = require('debug')('flow-deploy-service:flow-deploy-controller')

class TriggerController
  constructor: (@meshbluOptions={}) ->
    @flowDeployModel = new FlowDeployModel()

  start: (request, response) =>
    {flowId} = request.params

    meshbluConfig = _.extend {}, request.meshbluAuth, @meshbluOptions
    meshbluHttp = new MeshbluHttp meshbluConfig
    debug 'meshbluHttp', meshbluConfig
    message =
      devices: [flowId]
      topic: 'nodered-start-flow'
      payload:
        from: flowDeployId
        params: request.body

    debug 'sending message', message

    meshbluHttp.message message, (error, body) =>
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?
      return response.status(201).json(body)

module.exports = TriggerController
