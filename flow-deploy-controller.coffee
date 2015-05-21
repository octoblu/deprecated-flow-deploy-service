MeshbluHttp     = require 'meshblu-http'
FlowDeployModel = require './flow-deploy-model'
_            = require 'lodash'
debug        = require('debug')('flow-deploy-service:flow-deploy-controller')

class TriggerController
  constructor: (@meshbluOptions={}) ->

  start: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.extend {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new FlowDeployModel flowId, meshbluConfig
    @flowDeployModel.start (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(500).end() if error?
      return response.status(201).json(body)

module.exports = TriggerController
