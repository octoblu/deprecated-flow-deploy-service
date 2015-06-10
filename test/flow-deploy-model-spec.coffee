FlowDeployModel = require '../src/flow-deploy-model'

describe 'FlowDeployModel', ->
  beforeEach ->
    @flowId  = 1234
    @meshbluHttp =
      mydevices: sinon.stub()
      message: sinon.stub()
      device: sinon.stub()

    MeshbluHttp = =>
      @meshbluHttp

    @sut = new FlowDeployModel @flowId, {}, {}, MeshbluHttp: MeshbluHttp

  describe '->constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '->clearState', ->
    beforeEach ->
      @meshbluHttp.update = sinon.stub()

    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.clearState 'whatevs'

      it 'should call meshbluHttp.update', ->
        expect(@meshbluHttp.update).to.have.been.calledWith uuid: 'whatevs', states: null

    describe 'when called with a different uuid', ->
      beforeEach ->
        @sut.clearState 'evswhat'

      it 'should call meshbluHttp.update', ->
        expect(@meshbluHttp.update).to.have.been.calledWith uuid: 'evswhat', states: null

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
        @meshbluHttp.resetToken = sinon.stub()
        @sut.resetToken 'river-flow'

      it 'should call resetToken on meshbluHttp with river-flow', ->
        expect(@meshbluHttp.resetToken).to.have.been.calledWith 'river-flow'

    describe 'when called with a different uuid', ->
      beforeEach ->
        @meshbluHttp.resetToken = sinon.stub()
        @sut.resetToken 'river-song'

      it 'should call resetToken on meshbluHttp with river-song', ->
        expect(@meshbluHttp.resetToken).to.have.been.calledWith 'river-song'

    describe 'when meshbluHttp.resetToken yields an error', ->
      beforeEach (done) ->
        @meshbluHttp.resetToken = sinon.stub()
        @sut.resetToken 'something-witty', (@error, @result) => done()
        @meshbluHttp.resetToken.yield new Error('oh no!')

      it 'should call the callback with the error', ->
        expect(@error).to.deep.equal new Error('oh no!')

      it 'should call the callback with no result', ->
        expect(@result).not.to.exist

    describe 'when meshbluHttp.resetToken yields a uuid and token', ->
      beforeEach (done) ->
        @meshbluHttp.resetToken = sinon.stub()
        @sut.resetToken 'something-witty', (@error, @result) => done()
        @meshbluHttp.resetToken.yield null, uuid: 'river-uuid', token: 'river-token'

      it 'should call the callback with the token', ->
        expect(@result).to.deep.equal 'river-token'

      it 'should call the callback with an empty error', ->
        expect(@error).to.not.exist

  describe '->sendMessage', ->
    beforeEach ->
      @flow = uuid: 'big-daddy', token: 'tolking'
      @meshbluHttp.mydevices.yields null, devices: [uuid: 'honey-bear']
      @meshbluHttp.message.yields null
      @sut.sendMessage @flow, 'test'

    it 'should call mydevices', ->
      expect(@meshbluHttp.mydevices).to.have.been.calledWith type: 'octoblu:octo-master', online: true

    it 'should call message', ->
      expect(@meshbluHttp.message).to.have.been.calledWith
        devices: ['honey-bear']
        topic: "test"
        payload:
          image: 'octoblu/flow-runner:latest'
          token: 'tolking'
          uuid: 'big-daddy'

  describe '->start', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel 1234, {}, {}
        @sut.find = sinon.stub().yields new Error
        @sut.start (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find, resetToken, clearState, and sendMessage succeed', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel '1234', {}, {}
        @sut.find = sinon.stub().yields null, {}
        @sut.resetToken = sinon.stub().yields null, 'token'
        @sut.clearState = sinon.stub().yields null
        @sut.sendMessage = sinon.stub().yields null
        @sut.start (@error) => done()

      it 'should call find', ->
        expect(@sut.find).to.have.been.calledWith '1234'

      it 'should call resetToken with the uuid', ->
        expect(@sut.resetToken).to.have.been.calledWith '1234'

      it 'should call clearState with the uuid', ->
        expect(@sut.clearState).to.have.been.calledWith '1234'

      it 'should call sendMessage', ->
        expect(@sut.sendMessage).to.have.been.calledWith {token: 'token'}

      it 'should not have an error', ->
        expect(@error).not.to.be

    describe 'when clearState yields an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel '1234', {}, {}
        @sut.find = sinon.stub().yields null, {}
        @sut.resetToken = sinon.stub().yields null, 'token'
        @sut.clearState = sinon.stub().yields new Error('state is still opaque')
        @sut.sendMessage = sinon.stub().yields new Error('should not be called')
        @sut.start (@error) => done()

      it 'should call the callback with the error', ->
        expect(@error).to.be.an.instanceOf Error
        expect(@error.message).to.deep.equal 'state is still opaque'

  describe '->stop', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel
        @sut.find = sinon.stub().yields new Error
        @sut.stop (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel 1234
        @sut.find = sinon.stub().yields null, {}
        @sut.sendMessage = sinon.stub().yields null
        @sut.stop (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith 1234

      it 'should have called sendMessage', ->
        expect(@sut.sendMessage).to.have.been.calledWith {}

      it 'should not have an error', ->
        expect(@error).not.to.be
