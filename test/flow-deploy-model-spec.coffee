FlowDeployModel = require '../flow-deploy-model'

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

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe '.start', ->
    describe 'when find returns an error', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel 1234, {}, {}
        @sut.find = sinon.stub().yields new Error
        @sut.start (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when find succeeds', ->
      beforeEach (done) ->
        @sut = new FlowDeployModel 1234, {}, {}
        @sut.find = sinon.stub().yields null, {}
        @sut.resetToken = sinon.stub().yields null, 'token'
        @sut.sendMessage = sinon.stub().yields null
        @sut.start (@error) => done()

      it 'should have called find', ->
        expect(@sut.find).to.have.been.calledWith 1234

      it 'should have called sendMessage', ->
        expect(@sut.sendMessage).to.have.been.calledWith {token: 'token'}

      it 'should not have an error', ->
        expect(@error).not.to.be

  describe '.stop', ->
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

  describe '.find', ->
    beforeEach (done) ->
      @meshbluHttp.device.yields null, uuid: 'honey-bunny'
      @sut.find 21352135, (@error, @device) => done()

    it 'should find the flow', ->
      expect(@device).to.deep.equal uuid: 'honey-bunny'

  describe '.sendMessage', ->
    beforeEach ->
      @flow = uuid: 'big-daddy', token: 'tolking'
      @meshbluHttp.mydevices.yields null, devices: [uuid: 'honey-bear']
      @meshbluHttp.message.yields null
      @sut.sendMessage @flow, 'test'

    it 'should call mydevices', ->
      expect(@meshbluHttp.mydevices).to.have.been.calledWith type: 'octoblu:octo-master'

    it 'should call message', ->
      expect(@meshbluHttp.message).to.have.been.calledWith
        devices: ['honey-bear']
        topic: "test"
        payload:
          image: 'octoblu/flow-runner:latest'
          token: 'tolking'
          uuid: 'big-daddy'
