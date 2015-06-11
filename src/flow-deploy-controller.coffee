_            = require 'lodash'
debug        = require('debug')('flow-deploy-service:flow-deploy-controller')

class FlowDeployController
  constructor: (@meshbluOptions={}, dependencies={}) ->
    @FlowDeployModel = dependencies.FlowDeployModel || require './flow-deploy-model'

  pause: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.pause (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  resume: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.resume (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  save: (request, response) =>
    {id, flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.save id, (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  savePause: (request, response) =>
    {id, flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.savePause id, (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  start: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions
    @flowDeployModel = new @FlowDeployModel flowId, meshbluConfig, @meshbluOptions
    @flowDeployModel.start (error) ->
      debug '@flowDeployModel.start', error, typeof error
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
      return response.status(204).end()

module.exports = FlowDeployController
