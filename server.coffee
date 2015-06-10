express = require 'express'
errorHandler = require 'errorhandler'
meshbluAuth = require 'express-meshblu-auth'
morgan = require 'morgan'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
FlowDeployController = require './src/flow-deploy-controller'
cors = require 'cors'
bodyParser = require 'body-parser'
MeshbluConfig = require 'meshblu-config'

meshbluConfig = new MeshbluConfig(
  uuid_env_name: 'FLOW_DEPLOY_SERVICE_UUID'
  token_env_name: 'FLOW_DEPLOY_SERVICE_TOKEN'
).toJSON()

PORT  = process.env.FLOW_DEPLOY_SERVICE_PORT || 80

app = express()
app.use cors()
app.use morgan('combined')
app.use errorHandler()
app.use meshbluHealthcheck()
app.use bodyParser.urlencoded limit: '50mb', extended : true
app.use bodyParser.json limit : '50mb'

meshbluOptions =
  server: meshbluConfig.server
  port: meshbluConfig.port

app.use meshbluAuth meshbluOptions

app.options '*', cors()

flowDeployController = new FlowDeployController meshbluConfig

app.post '/flows/:flowId/instance', flowDeployController.start
app.delete '/flows/:flowId/instance', flowDeployController.stop

server = app.listen PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
