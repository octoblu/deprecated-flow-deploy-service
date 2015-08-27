_            = require 'lodash'
debug        = require('debug')('flow-deploy-service:flow-deploy-controller')

class FlowDeployController
  constructor: (@meshbluOptions={}, dependencies={}) ->
    @FlowDeployModel = dependencies.FlowDeployModel || require './flow-deploy-model'

  pause: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions

    @flowDeployModel.pause (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  resume: (request, response) =>
    {flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions

    @flowDeployModel.resume (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  save: (request, response) =>
    {id, flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions

    @flowDeployModel.save id, (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  savePause: (request, response) =>
    {id, flowId} = request.params
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions

    @flowDeployModel.savePause id, (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  start: (request, response) =>
    {flowId} = request.params
    deploymentUuid = request.get('deploymentUuid') ? 'unset'
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions
      deploymentUuid: deploymentUuid

    @flowDeployModel.start (error) ->
      debug '@flowDeployModel.start', error, typeof error
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(201).end()

  stop: (request, response) =>
    {flowId} = request.params
    debugger
    deploymentUuid = request.get('deploymentUuid') ? 'unset'
    meshbluConfig = _.defaults {}, request.meshbluAuth, @meshbluOptions

    @flowDeployModel = new @FlowDeployModel
      flowId: flowId
      userMeshbluConfig: meshbluConfig
      serviceMeshbluConfig: @meshbluOptions
      deploymentUuid: deploymentUuid

    @flowDeployModel.stop (error) ->
      return response.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return response.status(502).send(error: error) if error?
      return response.status(204).end()

module.exports = FlowDeployController
