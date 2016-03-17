// Generated by CoffeeScript 1.10.0
(function() {
  define('App', ['Base', 'Ship'], function(Base, Ship) {
    return window.app = {
      state: {
        game: {
          time: {
            timeSpeed: 1,
            year: 400,
            month: 1,
            frameInterval: 0.001
          }
        },
        fps: [],
        lastTimeLoop: null,
        view: {
          h: 700,
          w: 800
        },
        map: {
          h: 0,
          w: 0
        },
        zoom: 0.5,
        zoomStep: 0.1,
        minZoom: 0.3,
        maxZoom: 10,
        position: {
          x: 0,
          y: 300
        },
        controls: {
          up: false,
          down: false,
          right: false,
          left: false,
          mouseClicked: false,
          mouseClickedPosition: {},
          mousePosition: {}
        },
        pxDensity: 400,
        boundingCoordinates: {
          n: 41,
          s: 30,
          e: 32,
          w: 22
        }
      },
      collections: [],
      getPath: function(start, end) {
        var alt1, alt2, path, pathData;
        alt1 = start + '-' + end;
        alt2 = end + '-' + start;
        path = false;
        if (this.linksData[alt1]) {
          path = this.linksData[alt1];
        } else if (this.linksData[alt2]) {
          pathData = _.clone(this.linksData[alt2]);
          path = _.reverse(pathData);
        }
        return path;
      },
      registerCollection: function(collection, z) {
        this.collections.push({
          'collection': collection,
          'z': z
        });
      },
      getCollection: function(collectionName) {
        var foundCollection;
        foundCollection = false;
        _.each(this.collections, function(collection, c) {
          if (collection.collection.name === collectionName) {
            return foundCollection = collection.collection;
          }
        });
        return foundCollection;
      },
      newMonth: function() {
        app.getCollection('ships').createShip();
      },
      changeTime: function() {
        var lastFrame;
        lastFrame = _.clone(this.state.game.time.month);
        this.state.game.time.month += this.state.game.time.timeSpeed * this.state.game.time.frameInterval;
        if (_.floor(lastFrame) !== _.floor(this.state.game.time.month)) {
          console.log('new month');
          this.newMonth();
        }
        if (this.state.game.time.month > 13) {
          console.log('new year');
          this.state.game.time.year -= 1;
          this.state.game.time.month = 1;
          this.newYear();
        }
      },
      newYear: function() {
        app.getCollection('ships').createShip();
      },
      draw: function() {
        this.changeTime();
        _.each(_.orderBy(this.collections, 'z'), (function(_this) {
          return function(collection, c) {
            return collection.collection.draw();
          };
        })(this));
        this.drawBorders();
        this.writeInfo();
      },
      clear: function() {
        this.ctx.clearRect(0, 0, this.state.view.w, this.state.view.h);
      },
      calculateMap: function() {
        var c;
        c = this.state.boundingCoordinates;
        this.state.map.h = (c.n - c.s) * this.state.pxDensity;
        this.state.map.w = (c.e - c.w) * this.state.pxDensity;
        this.state.pxkm = this.state.pxDensity / 110;
      },
      goTo: function(coordinate) {
        this.state.position.x = coordinate.x;
        this.state.position.y = coordinate.y;
      },
      writeInfo: function() {
        this.ctx.fillStyle = 'black';
        this.ctx.fillText('x: ' + this.state.position.x + ' y: ' + this.state.position.y + ' zoom: ' + this.state.zoom, 10, 10);
        this.ctx.fillText('fps : ' + parseInt(_.mean(this.state.fps)), 10, 40);
      },
      getClicked: function() {
        var clicked, g, i, len, ref;
        clicked = falsecd;
        ref = this.state.geometries;
        for (i = 0, len = ref.length; i < len; i++) {
          g = ref[i];
          if (g.isClicked()) {
            clicked = g;
          }
        }
        return clicked;
      },
      getMousePosition: function() {
        return {
          x: this.state.position.x,
          y: this.state.position.y
        };
      },
      isPointVisible: function(point) {
        return point.x < this.state.view.w && point.x > 0 && point.y < this.state.view.h && point.y > 0;
      },
      drawBorders: function() {
        this.ctx.lineWidth = 5;
        this.ctx.strokeStyle = 'black';
        this.ctx.strokeRect((0 - this.state.position.x) * this.state.zoom, (0 - this.state.position.y) * this.state.zoom, this.state.map.w * this.state.zoom, this.state.map.h * this.state.zoom);
      },
      coordinateToMap: function(c) {
        return {
          x: (c.lon - this.state.boundingCoordinates.w) * this.state.pxDensity,
          y: this.state.map.h - (c.lat - this.state.boundingCoordinates.s) * this.state.pxDensity
        };
      },
      pointToUTM: function(point) {},
      setInteractions: function() {
        if (this.menu.mm.mouseConflict() && app.state.controls.mouseClicked) {
          this.menu.mm.mouseClick();
        }
      },
      coordinatesToView: function(coords) {
        return _.each(coords, (function(_this) {
          return function(coord, c) {
            return _this.coordinateToView(coord);
          };
        })(this));
      },
      coordinateToView: function(c) {
        return {
          x: (c.x - this.state.position.x) * this.state.zoom,
          y: (c.y - this.state.position.y) * this.state.zoom
        };
      },
      loop: function() {
        var now, nowValue;
        now = new Date();
        nowValue = now.valueOf();
        if (app.state.lastTimeLoop) {
          app.state.fps.push(parseInt(1 / (nowValue - app.state.lastTimeLoop) * 1000));
        }
        app.state.fps = _.takeRight(app.state.fps, 30);
        app.state.lastTimeLoop = nowValue;
        app.clear();
        app.draw();
        app.menu.draw();
        app.cursor.draw();
        app.checkPosition();
        app.setInteractions();
        window.requestAnimationFrame(app.loop);
      },
      checkPosition: function() {
        var p, step;
        step = 5;
        p = this.state.position;
        if (this.state.controls.left) {
          app.setNewXPosition(p.x - step);
        }
        if (this.state.controls.up) {
          app.setNewYPosition(p.y - step);
        }
        if (this.state.controls.right) {
          app.setNewXPosition(p.x + step);
        }
        if (this.state.controls.down) {
          app.setNewYPosition(p.y + step);
        }
      },
      setNewXPosition: function(newX) {
        this.state.position.x = _.clamp(newX, 0, this.state.map.w - (this.state.view.w / this.state.zoom));
      },
      setNewYPosition: function(newY) {
        this.state.position.y = _.clamp(newY, 0, this.state.map.h - (this.state.view.h / this.state.zoom));
      },
      mouseOverMap: function() {
        return !this.menu.mouseConflict();
      },
      zoomIn: function() {
        var h, s, w, z;
        if (this.state.zoom < this.state.maxZoom) {
          w = this.state.view.w;
          h = this.state.view.h;
          s = this.state.zoomStep;
          z = this.state.zoom;
          this.setNewXPosition(this.state.position.x + (w / z - (w / (z + s))) / 2);
          this.setNewYPosition(this.state.position.y + (w / z - (w / (z + s))) / 2);
          this.state.zoom = this.state.zoom + s;
        }
      },
      zoomOut: function() {
        var h, s, w, z;
        if (this.state.zoom > this.state.minZoom) {
          w = this.state.view.w;
          h = this.state.view.h;
          s = this.state.zoomStep;
          z = this.state.zoom;
          this.setNewXPosition(this.state.position.x + (w / z - (w / (z - s))) / 2);
          this.setNewYPosition(this.state.position.y + (w / z - (w / (z - s))) / 2);
          this.state.zoom = this.state.zoom - s;
        }
      }
    };
  });

}).call(this);