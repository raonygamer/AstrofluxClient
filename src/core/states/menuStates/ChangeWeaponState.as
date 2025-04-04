package core.states.menuStates {
import core.hud.components.Text;
import core.player.Player;
import core.scene.Game;
import core.states.DisplayState;
import core.weapon.Weapon;

import starling.display.Image;
import starling.events.TouchEvent;

public class ChangeWeaponState extends DisplayState {
    public function ChangeWeaponState(g:Game, p:Player, slot:int, isRoot:Boolean = false) {
        super(g, HomeState, isRoot);
        this.p = p;
        this.slot = slot;
    }
    private var p:Player;
    private var slot:int;

    override public function enter():void {
        super.enter();
        var _loc1_:Text = new Text(60, 80);
        _loc1_.wordWrap = false;
        _loc1_.size = 12;
        _loc1_.color = 0xffffff;
        _loc1_.htmlText = "Assign a weapon to slot <FONT COLOR=\'#fea943\'>" + slot + "</FONT>.";
        addChild(_loc1_);
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        for each(var _loc2_ in p.ship.weapons) {
            createWeaponBox(_loc3_, _loc4_, _loc2_);
            _loc3_++;
            if (_loc3_ == 10) {
                _loc4_++;
                _loc3_ = 0;
            }
        }
    }

    override public function execute():void {
        super.execute();
    }

    override public function exit():void {
        super.exit();
    }

    private function createWeaponBox(i:int, j:int, w:Weapon):void {
        var weaponBox:Image = new Image(textureManager.getTextureGUIByKey(w.techIconFileName));
        weaponBox.x = i * 50 + 60;
        weaponBox.y = j * 50 + 110;
        weaponBox.useHandCursor = true;
        weaponBox.addEventListener("touch", function (param1:TouchEvent):void {
            if (param1.getTouch(weaponBox, "ended")) {
                g.playerManager.trySetActiveWeapons(p, slot, w.key);
                g.hud.weaponHotkeys.refresh();
                sm.revertState();
            }
        });
        addChild(weaponBox);
    }
}
}

