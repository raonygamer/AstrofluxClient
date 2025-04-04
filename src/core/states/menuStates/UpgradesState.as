package core.states.menuStates {
import core.hud.components.Text;
import core.hud.components.techTree.TechTree;
import core.player.Player;
import core.scene.Game;
import core.states.DisplayState;

public class UpgradesState extends DisplayState {
    public function UpgradesState(g:Game, p:Player) {
        super(g, HomeState);
        this.p = p;
    }

    private var p:Player;

    override public function enter():void {
        super.enter();
        var _loc1_:Text = new Text();
        _loc1_.width = 5 * 60;
        _loc1_.wordWrap = true;
        _loc1_.font = "Verdana";
        _loc1_.size = 12;
        _loc1_.color = 0xaaaaaa;
        _loc1_.x = 45;
        _loc1_.y = 80;
        _loc1_.text = "Upgrades can be bought at the upgrade station.";
        addChild(_loc1_);
        var techTree:core.hud.components.techTree.TechTree = new TechTree(g, 400);
        techTree.load();
        techTree.x = 30;
        techTree.y = _loc1_.y + _loc1_.height;
        addChild(techTree);
    }
}
}

