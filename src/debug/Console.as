package debug {
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class Console extends Sprite {
    public static var tf:TextField;

    public static function write(...rest):void {
        trace(rest);
    }

    public function Console() {
        super();
        tf = new TextField(200, 800, "");
        addChild(tf);
        tf.x = 20;
        tf.y = 25;
        tf.alpha = 0.6;
        tf.touchable = false;
        addEventListener("enterFrame", update);
    }

    public function show():void {
        addChild(tf);
    }

    public function hide():void {
        removeChild(tf);
    }

    public function update(e:Event):void {
        var text:String = "";
        if (text != null) {
            tf.text = text;
        }
    }
}
}

