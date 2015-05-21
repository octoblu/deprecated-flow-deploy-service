FlowConverterModel = require '../flow-converter-model'

describe 'FlowConverterModel', ->
  beforeEach ->
    @sut = new FlowConverterModel @flow

  describe 'constructor', ->
    it 'should exist', ->
      expect(@sut).to.exist

  describe 'when it is called with one flow with no nodes or links', ->
    beforeEach ->
      flow =
        flowId: '1234',
        name: 'mah flow'
        hash: 'zhash'
        nodes:[]
        links: []

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.contain
        id: '1234'
        label: 'mah flow'
        type: 'tab'
        hash: 'zhash'

  describe 'when it is called with one flow with one node and no links', ->
    beforeEach ->
      node =
        id: '4848bef2.b7b74'
        category: 'operation'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x : 167
        y : 159
      flow =
        flowId: '55235'
        name: 'mah notha flow'
        hash: 'thehash'
        nodes: [ node ]
        links: []
      @convertedNode =
        id: '4848bef2.b7b74'
        category: 'operation'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: '55235'
        wires: []
        hash: 'thehash'
      @convertedFlow =
        id: '55235'
        label: 'mah notha flow'
        type: 'tab'
        hash: 'thehash'

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.deep.include.members [
        @convertedFlow
        @convertedNode
      ]

  describe 'when it is called with one flow with two node and no links', ->
    beforeEach ->
      node1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      node2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      flow =
        flowId: 'flowid'
        name: 'flowname'
        hash: 'ahash'
        nodes: [
          node1
          node2
        ]
        links: []
      @convertedWorkspace1 =
        id: 'flowid'
        label: 'flowname'
        type: 'tab'
        hash: 'ahash'
      @convertedNode1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: []
        hash: 'ahash'
      @convertedNode2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: []
        hash: 'ahash'

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.deep.include.members [
        @convertedWorkspace1
        @convertedNode1
        @convertedNode2
      ]

  describe 'when it is called with one flow with two node and one link', ->
    beforeEach ->
      node1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      node2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      link =
        from: 'node1'
        fromPort: '0'
        to: 'node2'
        toPort: '0'
      flow =
        flowId: 'flowid'
        name: 'flowname'
        hash: 'bhash'
        nodes: [
          node1
          node2
        ]
        links: [ link ]
      @convertedWorkspace1 =
        id: 'flowid'
        label: 'flowname'
        type: 'tab'
        hash: 'bhash'
      @convertedNode1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: [ [ 'node2' ] ]
        hash: 'bhash'
      @convertedNode2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: []
        hash: 'bhash'

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.deep.include.members [
        @convertedWorkspace1
        @convertedNode1
        @convertedNode2
      ]

  describe 'when it is called with one flow with two node and a link from both ports', ->
    beforeEach ->
      node1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      node2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      link1 =
        from: 'node1'
        fromPort: '0'
        to: 'node2'
        toPort: '0'
      link2 =
        from: 'node1'
        fromPort: '1'
        to: 'node2'
        toPort: '0'
      flow =
        flowId: 'flowid'
        name: 'flowname'
        hash: 'chash'
        nodes: [
          node1
          node2
        ]
        links: [
          link1
          link2
        ]
      @convertedWorkspace1 =
        id: 'flowid'
        label: 'flowname'
        type: 'tab'
        hash: 'chash'
      @convertedNode1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: [
          [ 'node2' ]
          [ 'node2' ]
        ]
        hash: 'chash'
      @convertedNode2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: []
        hash: 'chash'

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.deep.include.members [
        @convertedWorkspace1
        @convertedNode1
        @convertedNode2
      ]

  describe 'when it is called with one flow with two node and a link from only the second port', ->
    beforeEach ->
      node1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      node2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
      link =
        from: 'node1'
        fromPort: '1'
        to: 'node2'
        toPort: '0'
      flow =
        flowId: 'flowid'
        name: 'flowname'
        hash: 'dhash'
        nodes: [
          node1
          node2
        ]
        links: [ link ]
      @convertedWorkspace1 =
        id: 'flowid'
        label: 'flowname'
        type: 'tab'
        hash: 'dhash'
      @convertedNode1 =
        id: 'node1'
        category: 'inject'
        type: 'inject'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: [
          []
          [ 'node2' ]
        ]
        hash: 'dhash'
      @convertedNode2 =
        id: 'node2'
        category: 'debug'
        type: 'debug'
        name: ''
        topic: ''
        payload: ''
        payloadType: 'date'
        repeat: ''
        crontab: ''
        once: false
        x: 167
        y: 159
        z: 'flowid'
        wires: []
        hash: 'dhash'

      @sut = new FlowConverterModel flow

    it 'should return a converted flow', ->
      expect(@sut.convert()).to.deep.include.members [
        @convertedWorkspace1
        @convertedNode1
        @convertedNode2
      ]
