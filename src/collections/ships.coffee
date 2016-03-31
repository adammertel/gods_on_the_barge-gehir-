define 'Ships', ['Base', 'Collection', 'Ship'], (Base, Collection, Ship) ->
  class Ships extends Collection
    constructor: (data) ->
      @name = 'ships'
      super()
      app.registerNewDayAction @updateEnergyForShips.bind @
      app.registerNewDayAction @calculateBuildCost.bind @
      return

    calculateBuildCost: ->
      gameState = app.game.state.ships
      variability = gameState.buildCostVariability
      temperatureSignificance = gameState.buildCostTemperatureSignificance
      temperature = app.weather.state.temperature

      temperatureCoefficient = 1 - temperatureSignificance * (temperature - 5)
      randomness =  _.random(1 - variability, 1 + variability)
      newBuildCost = _.mean([gameState.buildCost * randomness, temperatureCoefficient * gameState.baseBuildCost])
      gameState.buildCost = Base.round newBuildCost
      return

    findClosePorts: (ship) ->
      allPorts = app.getCollection('nodes').ports
      ports = []
      for port in allPorts
        ports.push {'id': parseInt(port), 'distance': app.getDistanceOfNodes ship.stops[0], port}
      _.orderBy ports, 'distance'

    findClosestPort: (ship) ->
      @findClosePorts(ship)[0].id

    stopToRest: (ship) ->
      if (ship.nextDistance/1000) / ship.energy < 2000
        @findClosePorts(ship)
      else
        return

    updateEnergyForShips: ->
      for ship in @geometries
        ship.updateEnergy()
      return

    isInRain: (ship) ->
      inRain = false
      for storm in app.getCollection('storms').geometries
        if Base.distance(storm.coords, ship.coords) < storm.radius
          inRain = true
      inRain

    createShip: (cult) ->
      if app.game.freeShips(cult) > 0 and app.game.hasCultGoldToBuildShip(cult)
        app.game.shipBuilt(cult)
        @addGeometry new Ship(cult)
      return

    destroyShip: (ship) ->
      app.game.shipRemoved(ship.cult)
      @unregisterGeometry ship.id
      return

    registerGeometries: ->
      return
