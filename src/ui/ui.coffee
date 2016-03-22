define 'Ui', ['Button', 'Text'], (Button, Text) ->
  class Ui
    constructor: (@id, @x, @y, @w, @h) ->
      @buttons = []
      @texts = []
      @buttonStyle =
        inactive: {stroke: 'black', fill: 'white', text: 'black', lw: 2, font: 'bold 8pt Calibri'}
        active: {stroke: 'black', fill: 'grey', text: 'black', lw: 2, font: 'bold 8pt Calibri'}
      return

    mouseConflict: ->
      if app.isClicked()
        mouseX = app.state.controls.mousePosition.x
        mouseY = app.state.controls.mousePosition.y
        if mouseX > @x and mouseX < @x + @w and mouseY > @y and mouseY < @y + @h
          for button in @buttons
            button.isClicked()

          if @clickableAreas
            for area in @clickableAreas
              if mouseX > area.x and mouseX < area.x + area.w and mouseY > area.y and mouseY < area.y + area.h
                app.deactivateClick()
                area.action()
      return

    makeStaticText: (text) ->
      text

    getButton: (buttonId) ->
      _.find @buttons, (button) =>
        button.id == buttonId

    registerText: (id, position, text, font)->
      @texts.push new Text(id, position, text, font)
      return

    registerButton: (id, position, text, action, style, active)->
      @buttons.push new Button(id, position, text, action, style, active)
      return

    registerClickableArea: (x, y, w, h, action) ->
      @clickableAreas.push({x: x, y: y, w: w, h: h, action: action})

    drawTexts: () ->
      for text in @texts
        text.draw()
      return

    drawButtons: () ->
      for button in @buttons
        button.draw()
      return

    drawBackground: () ->
      m = 2
      app.ctx.beginPath()
      app.ctx.fillStyle = 'white'
      app.ctx.strokeStyle = 'black'
      app.ctx.lineWidth = 4
      app.ctx.rect @x - m/2, @y, @w - m/2, @h - m/2
      app.ctx.stroke()
      app.ctx.fill()

    draw: () ->
      app.ctx.lineWidth = 2
      @mouseConflict()

      @drawBackground()
      app.ctx.fillStyle = 'black'
      @drawTexts()
      @drawButtons()
      return
