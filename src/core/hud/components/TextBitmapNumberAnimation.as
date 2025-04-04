package core.hud.components {
import com.greensock.TweenMax;

public class TextBitmapNumberAnimation extends TextBitmap {
    public function TextBitmapNumberAnimation(x:int = 0, y:int = 0, text:String = "", fontSize:int = 13) {
        super(x, y, text, fontSize);
    }
    private var current:int;
    private var from:int;
    private var to:int;
    private var increase:int;
    private var delay:Number;
    private var id:int = Math.random() * 100;
    private var callback:Function;

    public function animate(from:int, to:int, timeMillies:int, callback:Function = null):void {
        this.callback = callback;
        this.from = from;
        this.to = to;
        var _loc5_:int = to - from;
        var _loc6_:int = Math.ceil(timeMillies / 50);
        increase = _loc5_ / _loc6_;
        if (increase == 0) {
            increase = 1;
        }
        delay = timeMillies / _loc6_ / 1000;
        current = from;
        next();
    }

    private function next():void {
        var _loc1_:Boolean = false;
        current += increase;
        if (current >= to) {
            current = to;
            _loc1_ = true;
        }
        text = "" + current;
        if (_loc1_) {
            if (Boolean(callback)) {
                callback();
            }
            return;
        }
        TweenMax.delayedCall(delay, next);
    }
}
}

