FlowDeployController = require '../flow-deploy-controller'

describe 'FlowDeployController', ->
  beforeEach ->
    @flowDeployModel =
      start: sinon.stub()
      stop: sinon.stub()
    @FlowDeployModel = => @flowDeployModel

    @sut = new FlowDeployController {}, FlowDeployModel: @FlowDeployModel

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe 'start', ->
    describe 'when unauthorized', ->
      beforeEach (done) ->
        @flowDeployModel.start.yields new Error 'unauthorized'
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.json = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.start request, @response

      it 'should set status 401', ->
        expect(@response.status).to.have.been.calledWith 401

      it 'should json error', ->
        expect(@response.json).to.have.been.calledWith error: 'unauthorized'

    describe 'when a generic error happens', ->
      beforeEach (done) ->
        @flowDeployModel.start.yields new Error
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.send = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.start request, @response

      it 'should set status 502', ->
        expect(@response.status).to.have.been.calledWith 502

    describe 'when valid', ->
      beforeEach (done) ->
        @flowDeployModel.start.yields null, {}
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.end = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.start request, @response

      it 'should set status 201', ->
        expect(@response.status).to.have.been.calledWith 201

  describe 'stop', ->
    describe 'when unauthorized', ->
      beforeEach (done) ->
        @flowDeployModel.stop.yields new Error 'unauthorized'
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.json = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.stop request, @response

      it 'should set status 401', ->
        expect(@response.status).to.have.been.calledWith 401

      it 'should json error', ->
        expect(@response.json).to.have.been.calledWith error: 'unauthorized'

    describe 'when a generic error happens', ->
      beforeEach (done) ->
        @flowDeployModel.stop.yields new Error
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.send = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.stop request, @response

      it 'should set status 502', ->
        expect(@response.status).to.have.been.calledWith 502

    describe 'when valid', ->
      beforeEach (done) ->
        @flowDeployModel.stop.yields null, {}
        @response = {}
        @response.status = sinon.stub().returns @response
        @response.end = sinon.spy => done()
        request =
          params:
            flowId: 12345

        @sut.stop request, @response

      it 'should set status 201', ->
        expect(@response.status).to.have.been.calledWith 201
