class FlowStatusMessenger
  constructor: (meshbluHttp, options={}) ->
    @meshbluHttp = meshbluHttp
    {@userUuid, @flowUuid, @workflow, @deploymentUuid} = options

  message: (state,message) =>
    @meshbluHttp.message
      devices: [process.env.FLOW_LOGGER_UUID]
      payload:
        application: 'flow-deploy-service'
        deploymentUuid: @deploymentUuid
        flowUuid: @flowUuid
        userUuid: @userUuid
        workflow: @workflow
        state:    state
        message:  message

module.exports = FlowStatusMessenger
