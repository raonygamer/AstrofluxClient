package core.hud.components.chat {
import core.scene.Game;

import feathers.controls.Label;

import starling.display.Sprite;
import starling.events.Event;

public class ChatSimple extends Sprite {
    public function ChatSimple(g:Game) {
        super();
        this.g = g;
        tf = new Label();
        tf.styleName = "chat";
        tf.minWidth = 5 * 60;
        tf.maxWidth = 500;
        addChild(tf);
        addEventListener("addedToStage", updateTexts);
    }
    private var g:Game;
    private var tf:Label;
    private var nextTimeout:Number = 0;

    public function update(e:Event = null):void {
        if (nextTimeout != 0 && nextTimeout < g.time) {
            updateTexts();
        }
    }

    public function updateTexts(e:Event = null):void {
        var _loc2_:Object = null;
        var _loc3_:Vector.<Object> = MessageLog.textQueue;
        var _loc5_:String = "\n";
        var _loc4_:int = _loc3_.length - 1;
        var _loc6_:int = 0;
        _loc4_;
        while (_loc4_ >= 0) {
            _loc2_ = _loc3_[_loc4_];
            if (_loc2_.timeout < g.time) {
                break;
            }
            if (!g.messageLog.isMuted(_loc2_.type)) {
                _loc6_++;
                _loc5_ = _loc2_.text + "\n" + _loc5_;
                nextTimeout = _loc2_.nextTimeout;
                var maxLines:int = 10;
                if (_loc6_ > maxLines) {
                    break;
                }
            }
            _loc4_--;
        }
        if (tf.text != _loc5_) {
            tf.text = _loc5_;
        }
    }
}
}

