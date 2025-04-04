package core.unit {
import core.scene.Game;
import core.ship.PlayerShip;

import starling.display.Sprite;

public class UnitManager {
    public function UnitManager(g:Game) {
        super();
        this.g = g;
    }
    public var units:Vector.<Unit> = new Vector.<Unit>();
    private var g:Game;

    public function add(unit:Unit, canvas:Sprite, addToRadar:Boolean = true):void {
        units.push(unit);
        if (addToRadar) {
            g.hud.radar.add(unit);
        }
        unit.canvas = canvas;
        if (unit.isBossUnit) {
            unit.addToCanvas();
        }
        if (unit is PlayerShip) {
            unit.addToCanvas();
        }
    }

    public function remove(unit:Unit):void {
        units.splice(units.indexOf(unit), 1);
        g.hud.radar.remove(unit);
        unit.removeFromCanvas();
        unit.reset();
    }

    public function forceUpdate():void {
        var _loc1_:Unit = null;
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < units.length) {
            _loc1_ = units[_loc2_];
            _loc1_.nextDistanceCalculation = -1;
            _loc2_++;
        }
    }

    public function getTarget(targetId:int):Unit {
        for each(var _loc2_ in units) {
            if (_loc2_.id == targetId) {
                return _loc2_;
            }
        }
        return null;
    }
}
}

