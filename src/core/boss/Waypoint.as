package core.boss {
import core.scene.Game;
import core.solarSystem.Body;

import flash.geom.Point;

public class Waypoint {
    public function Waypoint(g:Game, key:String, x:Number, y:Number, id:int) {
        super();
        this.id = id;
        if (key != null) {
            target = g.bodyManager.getBodyByKey(key);
        }
        if (target == null) {
            _pos = new Point(x, y);
        }
    }
    public var id:int;
    private var target:Body;

    private var _pos:Point;

    public function get pos():Point {
        if (target != null) {
            return new Point(target.pos.x, target.pos.y);
        }
        return _pos;
    }
}
}

