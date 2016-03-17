define 'Route', ['App', 'Geography', 'Base'], (app, Geography, Base) ->
  class Route extends Geography

    constructor: (@from, @to)->
      @speed = 5
      super()
      return

    draw: ->
      fromView = app.coordinateToView @from
      toView = app.coordinateToView @to

      app.ctx.strokeStyle = 'black'
      app.ctx.lineWidth = 1
      app.ctx.beginPath()
      app.ctx.moveTo fromView.x, fromView.y
      app.ctx.lineTo toView.x, toView.y
      app.ctx.stroke()
      return