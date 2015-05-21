express = require 'express'
errorHandler = require 'errorhandler'
meshbluAuth = require 'express-meshblu-auth'
morgan = require 'morgan'
MeshbluAuthExpress = require 'express-meshblu-auth/src/meshblu-auth-express'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
FlowDeployController = require './flow-deploy-controller'
cors = require 'cors'
bodyParser = require 'body-parser'

MESHBLU_HOST          = process.env.MESHBLU_HOST || 'meshblu.octoblu.com'
MESHBLU_PORT          = process.env.MESHBLU_PORT || '443'
PORT  = process.env.FLOW_DEPLOY_SERVICE_PORT || 80
UUID  = process.env.FLOW_DEPLOY_SERVICE_UUID
TOKEN = process.env.FLOW_DEPLOY_SERVICE_TOKEN

app = express()
app.use cors()
app.use morgan('combined')
app.use errorHandler()
app.use meshbluHealthcheck()
app.use bodyParser.urlencoded limit: '50mb', extended : true
app.use bodyParser.json limit : '50mb'

meshbluOptions =
  server: MESHBLU_HOST
  port: MESHBLU_PORT

app.use meshbluAuth meshbluOptions

app.options '*', cors()

flowDeployController = new FlowDeployController
  server: MESHBLU_HOST
  port: MESHBLU_PORT
  uuid: UUID
  token: TOKEN

app.post '/flows/:flowId/instance', flowDeployController.start
app.delete '/flows/:flowId/instance', flowDeployController.stop

server = app.listen PORT, ->
  host = server.address().address
  port = server.address().port

  console.log "Server running on #{host}:#{port}"
