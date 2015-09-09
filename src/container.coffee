{exec} = require 'child_process'
ServiceFile = require './service-file'
debug = require('debug')('flow-deploy-service:container')
FlowStatusMessenger = require './flow-status-messenger'
request = require 'request'
_ = require 'lodash'

class Container
  constructor: (options={}, dependencies={}) ->
    {@uuid,@token,@deploymentUuid,@image,@flowLoggerUuid,@userMeshbluConfig} = options
    @MeshbluHttp = dependencies.MeshbluHttp ? require 'meshblu-http'
    @meshbluHttp = new @MeshbluHttp @userMeshbluConfig

  isRunning: (callback=->) =>
    url = "#{process.env.FLEETCTL_ENDPOINT}/v2/keys/_coreos.com/fleet/states/octo-#{@uuid}.service"
    request.get url, json: true, (error, response, body) =>
      isRunning = "running" == @parseFleetctlStatus body
      callback null, isRunning

  parseFleetctlStatus: (body) =>
    node = JSON.parse _.first(body.node.nodes).value
    node.subState

  create: (callback=->) =>
    flowStatusMessenger = new FlowStatusMessenger @meshbluHttp,
      userUuid: @userMeshbluConfig.uuid
      flowUuid: @uuid
      deploymentUuid: @deploymentUuid
      workflow: 'flow-start'
      flowLoggerUuid: @flowLoggerUuid

    flowStatusMessenger.message 'container-destroy-begin'
    debug 'create'

    @_destroy =>
      flowStatusMessenger.message 'container-destroy-end'
      debug 'deleted'
      serviceFile = new ServiceFile
        uuid: @uuid
        token: @token
        image: @image
        flowLoggerUuid: @flowLoggerUuid

      debug 'opening'
      serviceFile.open (error, filePath) =>
        return callback error if error?
        debug 'exec', "fleetctl start #{filePath}"
        fs = require 'fs'
        debug 'file', fs.readFileSync(filePath).toString('utf8')

        flowStatusMessenger.message 'container-create-begin'
        exec "fleetctl start \"#{filePath}\"", (error, stdout, stderr) =>
          flowStatusMessenger.message 'container-create-end'
          debug 'execed', "fleetctl start #{filePath}", error
          console.error('exec error:', error.message) if error?
          console.log stdout if stdout?
          console.error stderr if stderr?
          serviceFile.close()
          callback error

  delete: (callback=->) =>
    flowStatusMessenger = new FlowStatusMessenger @meshbluHttp,
      userUuid: @userMeshbluConfig.uuid
      flowUuid: @uuid
      deploymentUuid: @deploymentUuid
      workflow: 'flow-start'
      flowLoggerUuid: @flowLoggerUuid

    flowStatusMessenger.message 'container-destroy-begin'

    debug 'delete'
    @_destroy (error) =>
      flowStatusMessenger.message 'container-destroy-end'
      callback error

  _destroy: (callback=->) =>
    debug '_destroy'
    exec "fleetctl destroy octo-#{@uuid}.service", (error, stdout, stderr) =>
      debug 'execed'
      console.error('exec error:', error.message) if error?
      console.log stdout if stdout?
      console.error stderr if stderr?
      callback error

  pull: (callback=->) =>
    exec "fleetctl start global-flow-runner-update.service", (error, stdout, stderr) =>
      console.error('exec error:', error.message) if error?
      console.log stdout if stdout?
      console.error stderr if stderr?
      callback error

module.exports = Container
