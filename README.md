# Octoblu Flow Deploy Service
Service to start/stop Octoblu Flows

## Supported Auth Methods

* cookies: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* headers: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* basic: `Authorization: Basic c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`
* bearer: `Authorization: Bearer c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`

## Start Flow Example:
    curl -X POST https://username:password@flow-deploy.octoblu.com/flows/:flowId/instance

## Stop Flow Example:
    curl -X DELETE https://username:password@flow-deploy.octoblu.com/flows/:flowId/instance
