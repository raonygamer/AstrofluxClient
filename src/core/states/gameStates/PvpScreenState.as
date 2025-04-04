package core.states.gameStates {
import core.hud.components.pvp.PvpQueueScreen;
import core.hud.components.pvp.PvpScoreScreen;
import core.hud.components.pvp.PvpScreen;
import core.scene.Game;

import starling.events.Event;

public class PvpScreenState extends PlayState {
    public function PvpScreenState(g:Game) {
        super(g);
        nextUpdate = g.time;
        if (g.solarSystem.isPvpSystemInEditor) {
            obj = new PvpScoreScreen(g);
        } else {
            obj = new PvpQueueScreen(g);
        }
    }
    private var obj:PvpScreen;
    private var nextUpdate:Number;

    override public function enter():void {
        super.enter();
        obj.load();
        obj.visible = true;
        addChild(obj);
        g.hud.show = false;
        obj.addEventListener("close", function (param1:Event):void {
            sm.revertState();
        });
        loadCompleted();
    }

    override public function tickUpdate():void {
        super.tickUpdate();
        if (g.time > nextUpdate) {
            nextUpdate = g.time + 1000;
            obj.update();
        }
    }

    override public function execute():void {
        if (loaded) {
            if (!me.commandable) {
                return;
            }
            if (keybinds.isEscPressed || keybinds.isInputPressed(6)) {
                sm.revertState();
            }
            updateCommands();
        }
        super.execute();
    }

    override public function exit(callback:Function):void {
        obj.unload();
        super.exit(callback);
    }
}
}

