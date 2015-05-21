FlowDeployModel = require '../flow-deploy-model'

describe 'FlowDeployModel', ->
  beforeEach ->
    @sut = new FlowDeployModel()

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '.start', ->
    beforeEach ->
      @flow = {}
      @sut = new FlowDeployModel @flow
      @sut.convertFlow = sinon.spy()
      @sut.start()

    it 'should convert the flow', ->
      expect(@sut.convertFlow).to.have.been.calledWith @flow
