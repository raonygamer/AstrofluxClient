package core.hud.components {
import starling.display.Sprite;
import starling.events.Event;

public class SaleTimer extends Sprite {
    public function SaleTimer(g:*, start:Number, end:Number, callback:Function) {
        super();
        this.callback = callback;
        var text:core.hud.components.Text = new Text();
        text.size = 18;
        text.text = "Offer ends in";
        addChild(text);
        hudTimer = new HudTimer(g, 18);
        hudTimer.x = text.x + 35;
        hudTimer.y = text.y + text.height / 2 + 5;
        hudTimer.start(start, end);
        addChild(hudTimer);
        addEventListener("enterFrame", update);
        addEventListener("removedFromStage", function (param1:Event):void {
            removeEventListeners();
        });
    }
    private var hudTimer:HudTimer;
    private var callback:Function = null;

    private function update(e:Event):void {
        hudTimer.update();
        if (hudTimer.isComplete() && callback != null) {
            callback();
        }
    }
}
}

