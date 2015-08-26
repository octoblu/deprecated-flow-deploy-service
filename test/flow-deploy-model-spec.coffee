FlowDeployModel = require '../src/flow-deploy-model'

describe 'FlowDeployModel', ->
  beforeEach ->
    @flowId  = '1234'
    @meshbluHttp =
      mydevices: sinon.stub()
      message: sinon.stub()
      device: sinon.stub()
      update: sinon.stub()
      updateDangerously: sinon.stub()
      resetToken: sinon.stub()

    MeshbluHttp = =>
      @meshbluHttp

    @dependencies = MeshbluHttp: MeshbluHttp, TIMEOUT: 1000, WAIT: 100

    options =
      flowId: @flowId
      userMeshbluConfig: {}
      serviceMeshbluConfig: {}

    @sut = new FlowDeployModel options, @dependencies

  describe '->constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '->clearState', ->
    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.clearState 'whatevs'

      it 'should call meshbluHttp.update', ->
        expect(@meshbluHttp.update).to.have.been.calledWith 'whatevs', states: null

    describe 'when called with a different uuid', ->
      beforeEach ->
        @sut.clearState 'evswhat'

      it 'should call meshbluHttp.update', ->
        expect(@meshbluHttp.update).to.have.been.calledWith 'evswhat', states: null

    describe 'when meshbluHttp.update yields an error', ->
      beforeEach (done) ->
        @meshbluHttp.update.yields new Error('big badda boom')
        @sut.clearState 'smoething', (@error) => done()

      it 'should call the callback with an error', ->
        expect(@error).to.be.an.instanceOf Error
        expect(@error.message).to.deep.equal 'big badda boom'

    describe 'when meshbluHttp.update does not yield an error', ->
      beforeEach (done) ->
        @meshbluHttp.update.yields undefined
        @sut.clearState 'smoething', (@error) => done()

      it 'should call the callback without an error', ->
        expect(@error).to.not.exist

  describe '->find', ->
    beforeEach (done) ->
      @meshbluHttp.device.yields null, uuid: 'honey-bunny'
      @sut.find 21352135, (@error, @device) => done()

    it 'should find the flow', ->
      expect(@device).to.deep.equal uuid: 'honey-bunny'

  describe '->resetToken', ->
    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.resetToken 'river-flow'

      it 'should call resetToken on meshbluHttp with river-flow', ->
        expect(@meshbluHttp.resetToken).to.have.been.calledWith 'river-flow'

    describe 'when called with a different uuid', ->
      beforeEach ->
        @sut.resetToken 'river-song'

      it 'should call resetToken on meshbluHttp with river-song', ->
        expect(@meshbluHttp.resetToken).to.have.been.calledWith 'river-song'

    describe 'when meshbluHttp.resetToken yields an error', ->
      beforeEach (done) ->
        @sut.resetToken 'something-witty', (@error, @result) => done()
        @meshbluHttp.resetToken.yield new Error('oh no!')

      it 'should call the callback with the error', ->
        expect(@error).to.deep.equal new Error('oh no!')

      it 'should call the callback with no result', ->
        expect(@result).not.to.exist

    describe 'when meshbluHttp.resetToken yields a uuid and token', ->
      beforeEach (done) ->
        @sut.resetToken 'something-witty', (@error, @result) => done()
        @meshbluHttp.resetToken.yield null, uuid: 'river-uuid', token: 'river-token'

      it 'should call the callback with the token', ->
        expect(@result).to.deep.equal 'river-token'

      it 'should call the callback with an empty error', ->
        expect(@error).to.not.exist

  describe '->sendFlowMessage', ->
    beforeEach ->
      @flow = uuid: 'big-daddy', token: 'tolking'
      @meshbluHttp.mydevices.yields null, devices: [uuid: 'honey-bear']
      @meshbluHttp.message.yields null
      @sut.sendFlowMessage @flow, 'test', {pay: 'load'}

    it 'should call message', ->
      expect(@meshbluHttp.message).to.have.been.calledWith
        devices: ['big-daddy']
        topic: "test"
        payload:
          pay: 'load'

  describe '->start', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234', userMeshbluConfig: {}, @dependencies
        @sut.find = sinon.stub().yields new Error
        @sut.sendFlowMessage = sinon.spy()
        @sut.start (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find, resetToken, clearState, and useContainer succeed', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234', userMeshbluConfig: {}, @dependencies
        @sut.find = sinon.stub().yields null, {}
        @sut.resetToken = sinon.stub().yields null, 'token'
        @sut.clearState = sinon.stub().yields null
        @sut.useContainer = sinon.stub().yields null
        @sut.sendFlowMessage = sinon.spy()
        @sut.start (@error) => done()

      it 'should call find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should call resetToken with the uuid', ->
        expect(@sut.resetToken).to.have.been.calledWith '1234'

      it 'should call clearState with the uuid', ->
        expect(@sut.clearState).to.have.been.calledWith '1234'

      it 'should call useContainer', ->
        expect(@sut.useContainer).to.have.been.calledWith {token: 'token'}

      it 'should not have an error', ->
        expect(@error).not.to.exist

    describe 'when clearState yields an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234', userMeshbluConfig: {}, @dependencies
        @sut.find = sinon.stub().yields null, {}
        @sut.resetToken = sinon.stub().yields null, 'token'
        @sut.clearState = sinon.stub().yields new Error('state is still opaque')
        @sut.useContainer = sinon.stub().yields new Error('should not be called')
        @sut.sendFlowMessage = sinon.spy()
        @sut.start (@error) => done()

      it 'should call the callback with the error', ->
        expect(@error).to.be.an.instanceOf Error
        expect(@error.message).to.deep.equal 'state is still opaque'

  describe '->stop', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel {}, @dependencies
        @sut.find = sinon.stub().yields new Error
        @sut.sendFlowMessage = sinon.spy()
        @sut.stop (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234', @dependencies
        @sut.find = sinon.stub().yields null, {}
        @sut.useContainer = sinon.stub().yields null
        @sut.sendFlowMessage = sinon.spy()
        @sut.stop (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should have called useContainer', ->
        expect(@sut.useContainer).to.have.been.calledWith {}

      it 'should not have an error', ->
        expect(@error).not.to.exist

  describe '->pause', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel
        @sut.find = sinon.stub().yields new Error
        @sut.pause (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234'
        @sut.find = sinon.stub().yields null, {}
        @sut.sendFlowMessage = sinon.stub().yields null
        @sut.pause (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should have called sendFlowMessage', ->
        expect(@sut.sendFlowMessage).to.have.been.calledWith {}, 'flow:pause', {}

      it 'should not have an error', ->
        expect(@error).not.to.exist

  describe '->resume', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel
        @sut.find = sinon.stub().yields new Error
        @sut.resume (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234'
        @sut.find = sinon.stub().yields null, {}
        @sut.sendFlowMessage = sinon.stub().yields null
        @sut.resume (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should have called sendFlowMessage', ->
        expect(@sut.sendFlowMessage).to.have.been.calledWith {}, 'flow:resume', {}

      it 'should not have an error', ->
        expect(@error).not.to.exist

  describe '->didSave', ->
    describe 'when the state has changed', ->
      beforeEach (done) ->
        @meshbluHttp.device = sinon.stub()
        @meshbluHttp.device.onCall(0).yields null, {}
        @meshbluHttp.device.onCall(1).yields null, stateId:'4321'
        @sut.didSave '4321', (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call device', ->
        expect(@meshbluHttp.device).to.have.been.calledWith '1234'

    describe 'when the state is something else and has changed', ->
      beforeEach (done) ->
        @meshbluHttp.device = sinon.stub()
        @meshbluHttp.device.onCall(0).yields null, {}
        @meshbluHttp.device.onCall(1).yields null, stateId: '5678'
        @sut.didSave '5678', (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call device', ->
        expect(@meshbluHttp.device).to.have.been.calledWith '1234'

    describe 'when the state does not change', ->
      beforeEach (done) ->
        @meshbluHttp.device = sinon.stub().yields null, {}
        @sut.didSave '5678', (@error) => done()

      it 'should have an error', ->
        expect(@error).to.exist

      it 'should call device', ->
        expect(@meshbluHttp.device).to.have.been.calledWith '1234'

  describe '->save', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel
        @sut.find = sinon.stub().yields new Error
        @sut.didSave = sinon.stub().yields null
        @sut.save 1555, (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234'
        @sut.find = sinon.stub().yields null, {}
        @sut.sendFlowMessage = sinon.stub().yields null
        @sut.didSave = sinon.stub().yields null
        @sut.save 1235, (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should have called sendFlowMessage', ->
        expect(@sut.sendFlowMessage).to.have.been.calledWith {}, 'flow:save', stateId: 1235

      it 'should not have an error', ->
        expect(@error).not.to.exist

  describe '->savePause', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel
        @sut.find = sinon.stub().yields new Error
        @sut.didSave = sinon.stub().yields null
        @sut.savePause 1555, (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel flowId: '1234'
        @sut.find = sinon.stub().yields null, {}
        @sut.sendFlowMessage = sinon.stub().yields null
        @sut.didSave = sinon.stub().yields null
        @sut.savePause 1235, (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should have called sendFlowMessage', ->
        expect(@sut.sendFlowMessage).to.have.been.calledWith {}, 'flow:save-pause', stateId: 1235

      it 'should not have an error', ->
        expect(@error).not.to.exist
