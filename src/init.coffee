require ['App', 'Time', 'Cults', 'Base', 'Island', 'Rectangle', 'MiniMap', 'Cursor', 'Route', 'Port', 'Ship', 'Islands',  'Nodes', 'Ships', 'Routes', 'Menu', 'WelcomeWindow'], (app, Time, Cults, Base, Island, Rectangle, MiniMap, Cursor, Route, Port, Ship, Islands, Nodes, Ships, Routes, Menu, WelcomeWindow) ->
  console.log 'init'

  canvas = document.getElementById('game')
  canvas.width = app.state.view.w
  canvas.height = app.state.view.h
  app.ctx = canvas.getContext('2d')

  app.calculateMap()

  app.linksData = JSON.parse Base.doXhr('data/links.json').responseText

  app.registerCollection(new Islands(JSON.parse Base.doXhr('data/islands.json').responseText), 1)
  app.registerCollection(new Nodes(JSON.parse Base.doXhr('data/nodes.json').responseText), 3)
  app.registerCollection(new Routes(JSON.parse Base.doXhr('data/edges.json').responseText), 2)

  app.getCollection('islands').registerGeometries()
  app.getCollection('nodes').registerGeometries()
  app.getCollection('routes').registerGeometries()

  app.cults = new Cults()
  app.time = new Time()
  app.menu = new Menu()
  app.cursor = new Cursor()

  app.registerInfoWindow(new WelcomeWindow('welcome', 500, 500))

  app.registerCollection(new Ships [], 10)

  app.getCollection('ships').createShip()

  app.loop()

  canvas.addEventListener 'mousedown', (e) ->
    app.state.controls.mouseClicked = true
    app.state.controls.mouseClickedPosition =
      x: e.clientX
      y: e.clientY
    return

  canvas.addEventListener 'mouseup', (e) ->
    app.state.controls.mouseClicked = false
    return

  canvas.addEventListener 'mousemove', (e) ->
    app.state.controls.mousePosition =
      x: e.clientX
      y: e.clientY

    if app.state.controls.mouseClicked and app.mouseOverMap()
      zoom = app.state.zoom
      mcp = app.state.controls.mouseClickedPosition
      app.setNewYPosition app.state.position.y + (mcp.y - (e.clientY)) * 1/zoom
      app.setNewXPosition app.state.position.x + (mcp.x - (e.clientX)) * 1/zoom

      app.state.controls.mouseClickedPosition =
        x: e.clientX
        y: e.clientY
    return

  canvas.addEventListener 'mouseout', (e) ->
    app.state.controls.mouseClicked = false
    app.state.controls.mouseClickedPosition =
      x: e.clientX
      y: e.clientY
    return
