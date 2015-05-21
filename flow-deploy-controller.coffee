_            = require 'lodash'
debug        = require('debug')('flow-deploy-service:flow-deploy-controller')

class FlowDeployController
  constructor: (@meshbluOptions={}, dependencies={}) ->
    @FlowDeployModel = dependencies.FlowDeployModel || require './flow-deploy-model'

  start: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.start (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  stop: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.stop (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

module.exports = FlowDeployController
