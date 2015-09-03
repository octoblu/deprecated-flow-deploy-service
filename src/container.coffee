{exec} = require 'child_process'
ServiceFile = require './service-file'
debug = require('debug')('flow-deploy-service:container')

class Container
  constructor: (options={}, dependencies={}) ->
    {@uuid,@token,@deploymentUuid,@image,@flowLoggerUuid} = options

  create: (callback=->) =>
    debug 'create'
    @delete =>
      debug 'deleted'
      @waitForDeath =>
        debug 'dead'
        serviceFile = new ServiceFile
          uuid: @uuid
          token: @token
          image: @image
          deploymentUuid: @deploymentUuid
          flowLoggerUuid: @flowLoggerUuid

        debug 'opening'
        serviceFile.open (error, filePath) =>
          return callback error if error?
          debug 'exec', "fleetctl start #{filePath}"
          fs = require 'fs'
          debug 'file', fs.readFileSync(filePath).toString('utf8')
          exec "fleetctl start \"#{filePath}\"", (error, stdout, stderr) =>
            debug 'execed', "fleetctl start #{filePath}", error
            console.error('exec error:', error.message) if error?
            console.log stdout if stdout?
            console.error stderr if stderr?
            serviceFile.close()
            callback error

  delete: (callback=->) =>
    debug 'delete'
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

  waitForDeath: (callback=->) =>
    child = exec "fleetctl status octo-#{@uuid}.service"
    child.on 'exit', (code) =>
      return callback() if code != 0
      _.defer @waitForDeath, callback

module.exports = Container
