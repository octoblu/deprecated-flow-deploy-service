class FlowStatusMessenger
  constructor: (meshbluHttp, options={}) ->
    @meshbluHttp = meshbluHttp
    {@userUuid, @flowUuid, @workflow, @deploymentUuid, @flowLoggerUuid} = options

  message: (state,message) =>
    @meshbluHttp.message
      devices: [@flowLoggerUuid]
      payload:
        application: 'flow-deploy-service'
        deploymentUuid: @deploymentUuid
        flowUuid: @flowUuid
        userUuid: @userUuid
        workflow: @workflow
        state:    state
        message:  message

module.exports = FlowStatusMessenger
