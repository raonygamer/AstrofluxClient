package core.hud.components.credits {
import core.hud.components.Button;
import core.scene.Game;

import facebook.FB;

import playerio.Message;

import starling.events.Event;

public class FBInvite extends Button {
    public function FBInvite(g:Game) {
        this.g = g;
        super(invite, "Invite friends", "positive");
    }
    private var g:Game;

    private function onUICallback(result:Object):void {
        var _loc4_:Message = null;
        var _loc3_:int = 0;
        var _loc2_:String = null;
        if (result == null) {
            return;
        }
        var _loc5_:Array = [];
        _loc5_ = result.to as Array;
        if (_loc5_.length > 0) {
            _loc4_ = g.createMessage("FBinvitedUsers");
            _loc3_ = 0;
            while (_loc3_ < _loc5_.length) {
                _loc2_ = _loc5_[_loc3_];
                _loc2_ = "fb" + _loc2_;
                _loc4_.add(_loc2_);
                _loc3_++;
            }
            g.sendMessage(_loc4_);
            Game.trackEvent("FBinvite", "invite sent", "to " + _loc5_.length.toString() + " users", _loc5_.length);
        }
    }

    public function invite(e:Event):void {
        var _loc2_:Object = {};
        _loc2_.method = "apprequests";
        _loc2_.message = "Play together with your friends, explore a vast universe, kill epic space monsters!";
        _loc2_.title = "Come play Astroflux with me!";
        _loc2_.filters = ["app_non_users"];
        FB.ui(_loc2_, onUICallback);
    }
}
}

