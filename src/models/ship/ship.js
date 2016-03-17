// Generated by CoffeeScript 1.10.0
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('Ship', ['Geometry', 'Base'], function(Geometry, Base) {
    var Ship;
    return Ship = (function(superClass) {
      extend(Ship, superClass);

      function Ship() {
        this.collectionName = 'ships';
        this.startId = app.getCollection('nodes').chooseShipStartingNodeId();
        this.endId = app.getCollection('nodes').chooseShipEndingNodeId();
        this.baseSpeed = 1;
        Ship.__super__.constructor.call(this, app.getCollection('nodes').nodeMapCoordinates(this.startId), {
          w: 15,
          h: 40
        }, {
          minZoom: 0.4
        });
        this.calculateStops();
        this.fullEnergy = 2000;
        this.energy = this.fullEnergy;
        return;
      }

      Ship.prototype.calculateStops = function() {
        this.stops = app.getPath(this.startId, this.endId);
        this.stops.push(parseInt(this.endId));
        this.nextStop = app.getCollection('nodes').nodeMapCoordinates(this.stops[0]);
        this.rotation = this.calculateRotation();
      };

      Ship.prototype.move = function() {
        this.energy -= .5;
        if (this.energy < 0) {
          this.suicide();
        }
        if (app.getCollection('nodes').checkConflict(this.stops[0], this.coords)) {
          if (this.stops.length > 1) {
            this.stops = _.slice(this.stops, 1);
            this.nextStop = app.getCollection('nodes').nodeMapCoordinates(this.stops[0]);
            this.rotation = this.calculateRotation();
          } else {
            this.suicide();
          }
        }
        return this.coords = Base.moveTo(this.coords, this.nextStop, this.getSpeed());
      };

      Ship.prototype.calculateRotation = function() {
        var dx, dy, theta;
        dy = this.coords.y - this.nextStop.y;
        dx = this.nextStop.x - this.coords.x;
        theta = Math.atan2(-dy, dx);
        if (theta < 0) {
          theta += 2 * Math.PI;
        }
        if (theta > 3 / 2 * Math.PI) {
          theta -= 3 / 2 * Math.PI;
        } else {
          theta += Math.PI / 2;
        }
        return theta;
      };

      Ship.prototype.getSpeed = function() {
        return this.baseSpeed * app.state.game.time.timeSpeed;
      };

      Ship.prototype.drawEnergyBar = function() {
        var energypx, fullEnergypx;
        fullEnergypx = 60;
        energypx = (fullEnergypx / this.fullEnergy) * this.energy;
        app.ctx.strokeStyle = 'black';
        app.ctx.fillStyle = 'red';
        app.ctx.strokeRect(this.shipCoord.x - 30, this.shipCoord.y - 30, fullEnergypx, 5);
        return app.ctx.fillRect(this.shipCoord.x - 30, this.shipCoord.y - 30, energypx, 5);
      };

      Ship.prototype.draw = function() {
        this.shipCoord = app.coordinateToView(this.coords);
        this.move();
        this.drawEnergyBar();
        Ship.__super__.draw.call(this);
      };

      Ship.prototype.suicide = function() {
        app.getCollection(this.collectionName).unregisterGeometry(this.id);
      };

      Ship.prototype.sprite = 'ship';

      return Ship;

    })(Geometry);
  });

}).call(this);