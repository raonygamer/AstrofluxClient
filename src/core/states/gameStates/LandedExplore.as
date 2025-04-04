package core.states.gameStates {
import core.player.LandedBody;
import core.scene.Game;
import core.solarSystem.Body;
import core.states.DisplayStateMachine;
import core.states.exploreStates.ExploreState;
import core.states.exploreStates.ReportState;
import core.states.exploreStates.SelectTeamState;

import facebook.Action;

import starling.display.Sprite;

public class LandedExplore extends LandedState {
    public function LandedExplore(g:Game, body:Body) {
        var _loc4_:Boolean = false;
        for each(var _loc3_ in g.me.landedBodies) {
            if (_loc3_.key == body.key) {
                _loc4_ = true;
                break;
            }
        }
        if (!_loc4_) {
            g.me.landedBodies.push(new LandedBody(body.key, false));
            Action.discover(body.key);
        }
        super(g, body, body.name);
    }
    private var sceneSM:DisplayStateMachine;

    override public function enter():void {
        super.enter();
        var container:starling.display.Sprite = new Sprite();
        sceneSM = new DisplayStateMachine(container);
        sceneSM.changeState(new ExploreState(g, body));
        loadCompleted();
        addChild(container);
    }

    override public function execute():void {
        if (sceneSM.inState(SelectTeamState)) {
            leaveButton.visible = false;
            if (keybinds.isEscPressed) {
                sceneSM.revertState();
            }
        } else if (sceneSM.inState(ReportState)) {
            leaveButton.visible = false;
        } else {
            super.execute();
            leaveButton.visible = true;
            if (_loaded && !g.blockHotkeys && keybinds.isEscPressed || !g.chatInput.isActive() && keybinds.isInputPressed(10)) {
                super.leave();
            }
        }
    }

    override public function tickUpdate():void {
        sceneSM.update();
        super.tickUpdate();
    }

    override public function exit(callback:Function):void {
        sceneSM.changeState(null);
        super.exit(callback);
    }
}
}

