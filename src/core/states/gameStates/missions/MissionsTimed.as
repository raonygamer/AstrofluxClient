package core.states.gameStates.missions {
import core.hud.components.ToolTip;
import core.scene.Game;

import starling.display.Sprite;

public class MissionsTimed extends Sprite {
    public function MissionsTimed(g:Game) {
        super();
        this.g = g;
        missionsList = new MissionsList(g);
        missionsList.loadTimedMissions();
        missionsList.drawMissions();
        addChild(missionsList);
        this.addEventListener("enterFrame", update);
    }
    private var g:Game;
    private var missionsList:MissionsList;

    override public function dispose():void {
        super.dispose();
        removeEventListeners();
        ToolTip.disposeType("missionView");
    }

    public function update():void {
        missionsList.update();
    }
}
}

