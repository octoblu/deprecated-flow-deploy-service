FlowDeployController = require '../flow-deploy-controller'

describe 'FlowDeployController', ->
  beforeEach ->
    @sut = new FlowDeployController()

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe 'start', ->
    it 'should start a flow', ->
      expect(@sut.start).to.exist
