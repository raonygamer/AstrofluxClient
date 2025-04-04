package core.hud.components {
import core.scene.Game;

import starling.display.Sprite;

public class ResourceBox extends Sprite {
    public function ResourceBox(g:Game) {
        super();
        this.g = g;
    }
    private var g:Game;

    public function update():void {
        var _loc2_:int = 0;
        removeChildren();
        for each(var _loc1_ in g.myCargo.minerals) {
            _loc1_.draw("hud");
            _loc1_.x = _loc2_ * 78;
            _loc1_.y = 1;
            addChild(_loc1_);
            _loc2_++;
        }
    }
}
}

