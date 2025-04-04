package core.states.gameStates.missions {
import core.scene.Game;

import feathers.controls.ScrollContainer;

import starling.display.Sprite;
import starling.events.Event;

public class DailyList extends Sprite {
    public function DailyList(g:Game) {
        var _loc6_:int = 0;
        var _loc5_:Daily = null;
        var _loc2_:DailyView = null;
        views = [];
        super();
        this.g = g;
        container = new ScrollContainer();
        container.width = 680;
        container.height = 500;
        container.x = 40;
        container.y = 40;
        addChild(container);
        var _loc7_:Array = g.me.dailyMissions;
        _loc7_.sortOn(["complete", "level"], [2, 16]);
        container.addEventListener("dailyMissionsUpdateList", updateList);
        var _loc3_:int = 24;
        var _loc4_:int = 20;
        _loc6_ = 0;
        while (_loc6_ < _loc7_.length) {
            _loc5_ = _loc7_[_loc6_];
            _loc2_ = new DailyView(g, _loc5_, container);
            _loc2_.x = _loc4_;
            _loc2_.y = _loc3_;
            container.addChild(_loc2_);
            if (_loc6_ % 2 != 0) {
                _loc4_ = 20;
                _loc3_ += _loc2_.height;
            } else {
                _loc4_ = _loc2_.width + 40;
            }
            views.push(_loc2_);
            _loc6_++;
        }
    }
    private var g:Game;
    private var views:Array;
    private var container:ScrollContainer;

    override public function dispose():void {
        super.dispose();
        container.removeEventListener("dailyMissionsUpdateList", updateList);
        for each(var _loc1_ in views) {
            _loc1_.dispose();
        }
    }

    private function updateList(e:Event):void {
        var _loc2_:DailyView = null;
        var _loc3_:int = 0;
        _loc3_ = 0;
        while (_loc3_ < views.length) {
            _loc2_ = views[_loc3_];
            if (_loc2_.isTypeMission()) {
                _loc2_.onReset(null);
            }
            _loc3_++;
        }
    }
}
}

