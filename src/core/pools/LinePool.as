package core.pools {
import core.hud.components.Line;
import core.scene.Game;

public class LinePool {
    public function LinePool(g:Game) {
        var _loc2_:int = 0;
        var _loc3_:Line = null;
        inactiveLines = new Vector.<Line>();
        activeLines = new Vector.<Line>();
        super();
        this.g = g;
        _loc2_ = 0;
        while (_loc2_ < 4) {
            _loc3_ = new Line();
            inactiveLines.push(_loc3_);
            _loc2_++;
        }
    }
    private var inactiveLines:Vector.<Line>;
    private var activeLines:Vector.<Line>;
    private var g:Game;

    public function getLine():Line {
        var _loc1_:Line = null;
        if (inactiveLines.length > 0) {
            _loc1_ = inactiveLines.pop();
        } else {
            _loc1_ = new Line();
        }
        activeLines.push(_loc1_);
        return _loc1_;
    }

    public function removeLine(bl:Line):void {
        var _loc2_:int = int(activeLines.indexOf(bl));
        if (_loc2_ == -1) {
            return;
        }
        activeLines.splice(_loc2_, 1);
        inactiveLines.push(bl);
    }

    public function dispose():void {
        for each(var _loc1_ in inactiveLines) {
            _loc1_.dispose();
        }
        for each(_loc1_ in activeLines) {
            _loc1_.dispose();
        }
        activeLines = null;
        inactiveLines = null;
    }
}
}

