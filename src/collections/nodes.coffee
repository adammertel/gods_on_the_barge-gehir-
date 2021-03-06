define 'Nodes', ['Base', 'Collection', 'Port', 'Colors', 'FontStyle'], (Base, Collection, Port, Colors, FontStyle) ->
  class Nodes extends Collection
    constructor: (data) ->
      @name = 'nodes'
      super data
      return

    limitConflict: 2

    registerGeometries: ->
      @ports = []

      _.each _.keys(@data), (nodeId, n) =>
        islandValue = @data[nodeId]
        if islandValue.island
          @ports.push nodeId

          @addGeometry new Port(app.coordinateToMap({lon: islandValue.x, lat: islandValue.y}), @ctx, nodeId, @getIslandOfPort(nodeId), islandValue.port_name)
        return

      return

    setStyle: ->
      @ctx.fillStyle = Colors.PORTMAP
      @ctx.font = FontStyle.BOLDNORMAL
      @ctx.textAlign = 'center'

    getNode: (id) ->
      @data[id]

    isNodePort: (id) ->
      @data[id].island?

    getIslandOfPort: (id) ->
      @data[id].island

    nodeMapCoordinates: (id) ->
      node = @getNode(id)
      try
        app.coordinateToMap {lon: node.x, lat: node.y}
      catch
        console.log 'node problem', node, 'id', id

    checkConflict: (id, coords) ->
      Base.distance(@nodeMapCoordinates(id), coords) < @limitConflict * app.time.state.timeSpeed

    getIdOfNode: (node) ->
      id = false
      self = @
      _.each _.keys(@data), (nodeKey, k) ->
        if self.data[nodeKey].x == node.x
          id = nodeKey
        return
      id

    getNodesOnIsland: (islandName) ->
      _.filter @data, (node, n) ->
        node.island == islandName

    getAllPorts: ->
      _.filter @data, (node, n) ->
        node.island != ''

    # using points from politics
    chooseShipEndingNodeId: ->
      endPointsSamples = []
      for endPoint, endPointValue  of app.game.state.politics.endingPoints
        endPointsSamples = _.concat endPointsSamples, _.times endPointValue, _.constant parseInt endPoint

      _.sample endPointsSamples

    getShipStartingNodes: ->
      @getNodesOnIsland 'Egypt'

    getShipEndingNodes: ->
      _.union @getNodesOnIsland('Greece'), @getNodesOnIsland('Turkey')

    draw: ->
      for node in @geometries
        if node.name
          node.draw()
