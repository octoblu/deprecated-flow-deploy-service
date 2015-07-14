_ = require 'lodash'
os = require 'os'
path = require 'path'
fs = require 'fs-extra'
eco = require 'eco'
debug = require('debug')('flow-deploy-service:service-file')

SERVICE_TEMPLATE = eco.compile fs.readFileSync(path.join(__dirname, 'octo.service.eco'), 'utf8')

class ServiceFile
  constructor: (options={}) ->
    {@uuid, @token, @image} = options
    @servicesPath = path.join os.tmpdir(), 'services'
    @filePath = path.join @servicesPath, "octo-#{@uuid}.service"

  open: (callback=->) =>
    debug 'open', @servicesPath
    fs.mkdirp @servicesPath, (error) =>
      return callback error if error?
      data = SERVICE_TEMPLATE uuid: @uuid, token: @token, image: @image
      debug 'writing file', @filePath
      fs.writeFile @filePath, data, encoding: 'utf8', (error) =>
        debug 'wrote file', @filePath
        return callback error if error?
        callback null, @filePath

  close: (callback=->) =>
    debug 'close', @filePath
    fs.remove @filePath, (error) =>
      debug 'removed', @filePath
      return callback error if error?
      callback()

module.exports = ServiceFile
