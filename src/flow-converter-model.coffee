_ = require 'lodash'
request = require 'request'

class FlowConverterModel
  constructor: (@flow) ->

  convert: =>
    convertedNodes = _.map @flow.nodes, (node) =>
      @convertNode @flow, node

    convertedNodes.unshift
      id: @flow.flowId
      label: @flow.name
      type: 'tab'
      hash: @flow.hash

    convertedNodes

  convertNode: (flow, node) =>
    nodeLinks           = _.where flow.links, from: node.id
    groupedLinks        = _.groupBy nodeLinks, 'fromPort'
    largestPort         = @largestPortNumber groupedLinks

    convertedNode = _.clone node
    convertedNode.z = flow.flowId
    convertedNode.hash = flow.hash
    convertedNode.wires = @paddedArray largestPort
    if convertedNode.category == 'operation'
      convertedNode.type = convertedNode.type.replace 'operation:', ''
    else
      convertedNode.type = convertedNode.category

    _.each groupedLinks, (links, fromPort) ->
      port = parseInt fromPort
      convertedNode.wires[port] = _.pluck links, 'to'

    convertedNode

  paddedArray: (length) =>
    _.map _.range(length), -> []

  largestPortNumber: (groupedLinks) =>
    portsKeys = _.keys groupedLinks
    _.max _.map portsKeys, (portKey) ->
      parseInt portKey

module.exports = FlowConverterModel
