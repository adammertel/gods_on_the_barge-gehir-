define 'App', ['Base', 'Ship', 'Season'], (Base, Ship, Season) ->
  window.app =
    state:
      fps: []
      lastTimeLoop: null
      view:
        h: 700
        w: 800
      map:
        h: 0
        w: 0
      zoom: 0.5
      zoomStep: 0.1
      minZoom: 0.3
      maxZoom: 10
      position:
        x: 0
        y: 300
      controls:
        up: false
        down: false
        right: false
        left: false
        mouseClicked: false
        mouseClickedPosition: {}
        mousePosition: {}
      pxDensity: 400
      boundingCoordinates:
        n: 39
        s: 30
        e: 32
        w: 22

    collections: []
    infoWindows: []
    startGameFunctions: []
    shipPath: new Path2D Base.shipPath()

    drawShip: (coords, size, rotation, color) ->
      app.ctx.translate coords.x, coords.y
      if rotation
        app.ctx.rotate rotation
      if size != 1
        app.ctx.scale size, size

      app.ctx.fillStyle = color
      app.ctx.fill @shipPath
      app.ctx.stroke @shipPath

      if rotation
        app.ctx.rotate -rotation
      if size != 1
        app.ctx.scale 1/size, 1/size
      app.ctx.translate -coords.x, -coords.y
      return

    deactivateClick: () ->
      @state.controls.mouseClicked = false
      return

    isClicked: () ->
      @state.controls.mouseClicked

    # functions that need to wait untill player chooses his cult
    registerStartGameFunction: (startGameFunction) ->
      @startGameFunctions.push startGameFunction
      return

    startGame: (cult) ->
      @game.chooseCult cult
      _.each @startGameFunctions, (startGameFunction) ->
        startGameFunction()

      @time.resume()
      return

    registerInfoWindow: (infoWindow) ->
      @infoWindows.push infoWindow
      return

    getInfoWindow: (id) ->
      _.find @infoWindows, (infoWindow) =>
        infoWindow.id == id

    isInfoWindowOpen: () ->
      open = false
      _.each @infoWindows, (infoWindow) =>
        if infoWindow.open
          open = true
      open

    drawInfoWindows: () ->
      _.each @infoWindows, (infoWindow) =>
        if infoWindow.open
          infoWindow.draw()
      return

    # links, paths, nodes
    getPathWithCheckPoints: (from, to, checkPoints) ->
      path = []
      if checkPoints.length == 0
        path = @getPath(from, to)
      else
        path = @getPath(from, checkPoints[0])
        _.each checkPoints, (checkPoint, p) =>
          if checkPoints[p+1]
            path = _.concat path, @getPath(checkPoints[p], checkPoints[p+1])
        path = _.concat path, @getPath(checkPoints[checkPoints.length-1], to)
      path

    getPath: (from, to) ->
      alt1 = from + '-' + to
      alt2 = to + '-' + from
      path = []

      if @linksData[alt1]
        path = @linksData[alt1]
      else if @linksData[alt2]
        pathData = _.clone @linksData[alt2]
        path = _.reverse pathData
      path.push parseInt to
      path

    getDistanceOfNodes: (from, to) ->
      distance = 0
      path = @getPath(from, to)
      path.unshift(from)

      _.each path, (node, n) =>
        if path[n+1]
          thisNode = node
          nextNode = path[n+1]
          distance += @getCollection('routes').getDistanceOfEdge(thisNode, nextNode)

      distance

    registerCollection: (collection, z) ->
      @collections.push {'collection': collection, 'z': z}
      return

    getCollection: (collectionName) ->
      foundCollection = false
      _.each @collections, (collection, c) ->
        if collection.collection.name == collectionName
          foundCollection = collection.collection
      foundCollection

    drawTextArea: (text, x, y, lineHeight, lineWidth, font) ->
      app.ctx.font = font
      app.ctx.fillStyle = 'black'
      texts = Base.wrapText(app.ctx, text, lineWidth)

      _.each texts, (text, t) ->
        app.ctx.fillText text, x, y + t * lineHeight
      return

    newDay: ->
      #console.log 'newDay'
      return

    newWeek: ->
      #console.log 'newWeek'
      #app.getCollection('ships').createShip()
      return

    newSeason: (newSeason)->
      #console.log 'newSeason'
      #app.getCollection('ships').createShip()
      return

    newYear: ->
      #console.log 'newYear'
      #app.getCollection('ships').createShip()
      return

    draw: ->
      @time.nextTick()

      for collection in _.orderBy(@collections, 'z')
        collection.collection.draw()

      @drawBorders()
      @writeInfo()
      @time.draw()
      return

    clear: ->
      @ctx.clearRect 0, 0, @state.view.w, @state.view.h
      return

    countFps: ->
      now = new Date()
      nowValue = now.valueOf()
      app.state.fps.push parseInt(1/(nowValue - app.state.lastTimeLoop) * 1000)
      app.state.fps = _.takeRight app.state.fps, 30
      app.state.lastTimeLoop = nowValue
      return

    loop: ->
      app.clear()
      app.countFps()
      app.draw()
      app.menu.draw()

      app.drawInfoWindows()

      app.cursor.draw()

      app.checkPosition()
      app.setInteractions()

      window.requestAnimationFrame app.loop
      return

    calculateMap: ->
      c = @state.boundingCoordinates
      @state.map.h = (c.n - c.s) * @state.pxDensity
      @state.map.w = (c.e - c.w) * @state.pxDensity
      @state.pxkm = @state.pxDensity/110
      return

    goTo: (coordinate) ->
      @state.position.x = coordinate.x
      @state.position.y = coordinate.y
      return

    writeInfo: ->
      @ctx.textAlign = 'left'
      @ctx.fillStyle = 'black'
      @ctx.fillText 'x: ' + @state.position.x + ' y: ' + @state.position.y + ' zoom: ' + @state.zoom, 10, 10
      @ctx.fillText 'fps : ' + parseInt(_.mean(@state.fps)), 10, 40
      return

    getClicked: ()->
      clicked = falsecd
      for g in @state.geometries
        if g.isClicked()
          clicked = g
      clicked

    getMousePosition: ->
      {x: @state.position.x, y: @state.position.y}

    isPointVisible: (point) ->
      point.x < @state.view.w and point.x > 0 and point.y < @state.view.h and point.y > 0

    drawBorders: ->
      @ctx.lineWidth = 5
      @ctx.strokeStyle = 'black'
      @ctx.strokeRect (0 - (@state.position.x)) * @state.zoom, (0 - (@state.position.y)) * @state.zoom, @state.map.w * @state.zoom, @state.map.h * @state.zoom
      # @ctx.lineWidth = 5
      # @ctx.strokeStyle = 'black'
      # @ctx.strokeRect 0, 0, @state.view.w, @state.view.h
      return

    coordinateToMap: (c) ->
      x: Base.round((c.lon - @state.boundingCoordinates.w) * @state.pxDensity)
      y: Base.round(@state.map.h - (c.lat - @state.boundingCoordinates.s) * @state.pxDensity)

    pointToUTM: (point) ->


    setInteractions: () ->
      if @menu.mm.mouseConflict() and app.state.controls.mouseClicked
        @menu.mm.mouseClick()
        return
      # else
      #   for g in @state.geometries
      #     conflict = g.mouseConflict()
      #     g.over = conflict
      #     if app.state.controls.mouseClicked
      #       g.clicked = conflict
      #     else
      #       g.clicked = false

    coordinatesToView: (coords) ->
      _.each coords, (coord, c) =>
        @coordinateToView coord

    coordinateToView: (c) ->
      x: Base.round((c.x - @state.position.x) * @state.zoom)
      y: Base.round((c.y - @state.position.y) * @state.zoom)

    checkPosition: ->
      step = 5
      p = @state.position
      if @state.controls.left
        app.setNewXPosition p.x - step
      if @state.controls.up
        app.setNewYPosition p.y - step
      if @state.controls.right
        app.setNewXPosition p.x + step
      if @state.controls.down
        app.setNewYPosition p.y + step
      return

    setNewXPosition: (newX) ->
      @state.position.x = _.clamp(newX, 0, @state.map.w - (@state.view.w / @state.zoom))
      return

    setNewYPosition: (newY) ->
      @state.position.y = _.clamp(newY, 0, @state.map.h - (@state.view.h / @state.zoom))
      return

    mouseOverMap: () ->
      !@menu.mouseConflict() and !@isInfoWindowOpen()

    zoomIn: ->
      if @state.zoom < @state.maxZoom
        w = @state.view.w
        h = @state.view.h
        s = @state.zoomStep
        z = @state.zoom
        @setNewXPosition @state.position.x + (w / z - (w / (z + s))) / 2
        @setNewYPosition @state.position.y + (w / z - (w / (z + s))) / 2
        @state.zoom = @state.zoom + s
      return

    zoomOut: ->
      if @state.zoom > @state.minZoom
        w = @state.view.w
        h = @state.view.h
        s = @state.zoomStep
        z = @state.zoom
        @setNewXPosition @state.position.x + (w / z - (w / (z - s))) / 2
        @setNewYPosition @state.position.y + (w / z - (w / (z - s))) / 2
        @state.zoom = @state.zoom - s
      return
