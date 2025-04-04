package core.friend {
import core.hud.components.chat.MessageLog;
import core.player.Player;
import core.scene.Game;

import playerio.Message;

public class FriendManager {
    public function FriendManager(g:Game) {
        super();
        this.g = g;
    }
    private var g:Game;
    private var me:Player;
    private var requests:Array = [];
    private var onlineFriendsCallback:Function;

    public function addMessageHandlers():void {
        g.addMessageHandler("friendRequest", friendRequest);
        g.addMessageHandler("addFriend", addFriend);
        g.addMessageHandler("removeFriend", removeFriendRecieved);
        g.addServiceMessageHandler("onlineFriends", onOnlineFriends);
    }

    public function init(me:Player, forceFetch:Boolean = false):void {
        this.me = me;
        if (Player.friends != null && !forceFetch) {
            return;
        }
        Player.friends = new Vector.<Friend>();
        g.rpc("getFriends", function (param1:Message):void {
            var _loc3_:int = 0;
            var _loc2_:Friend = null;
            _loc3_ = 0;
            while (_loc3_ < param1.length) {
                _loc2_ = new Friend();
                _loc2_.id = param1.getString(_loc3_);
                Player.friends.push(_loc2_);
                _loc3_++;
            }
        });
    }

    public function updateOnlineFriends(callback:Function):void {
        onlineFriendsCallback = callback;
        g.sendToServiceRoom("getOnlineFriends");
    }

    public function sendFriendRequest(p:Player):void {
        g.send("sendFriendRequest", p.id);
    }

    public function friendRequest(m:Message):void {
        var _loc3_:String = m.getString(0);
        var _loc2_:Player = g.playerManager.playersById[_loc3_];
        if (_loc2_ == null) {
            return;
        }
        if (me.isFriendWith(_loc2_)) {
            return;
        }
        if (requests.indexOf(_loc3_) != -1) {
            return;
        }
        requests.push(_loc3_);
        MessageLog.write("<FONT COLOR=\'#88ff88\'>" + _loc2_.name + " wants to add you as a friend.</FONT>");
        g.hud.playerListButton.hintNew();
    }

    public function sendFriendConfirm(p:Player):void {
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < requests.length) {
            if (requests[_loc2_] == p.id) {
                requests.splice(_loc2_, 1);
                break;
            }
            _loc2_++;
        }
        g.send("friendConfirm", p.id);
    }

    public function addFriend(m:Message):void {
        var _loc2_:Friend = new Friend();
        _loc2_.fill(m, 0);
        Player.friends.push(_loc2_);
        MessageLog.write("<FONT COLOR=\'#88ff88\'>You are now friends with " + _loc2_.name + "</FONT>");
        g.sendToServiceRoom("addFriend", _loc2_.id);
    }

    public function removeFriend(playerId:String):void {
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < Player.friends.length) {
            if (Player.friends[_loc2_].id == playerId) {
                g.sendToServiceRoom("removeFriend", Player.friends[_loc2_].id);
                Player.friends.splice(_loc2_, 1);
            }
            _loc2_++;
        }
    }

    public function sendRemoveFriend(p:Player):void {
        removeFriend(p.id);
        g.send("removeFriend", p.id);
    }

    public function sendRemoveFriendById(id:String):void {
        removeFriend(id);
        g.send("removeFriend", id);
    }

    public function removeFriendRecieved(m:Message):void {
        removeFriend(m.getString(0));
    }

    public function pendingRequest(p:Player):Boolean {
        return requests.indexOf(p.id) != -1;
    }

    private function onOnlineFriends(m:Message):void {
        var _loc2_:Friend = null;
        if (onlineFriendsCallback == null) {
            return;
        }
        Player.onlineFriends = new Vector.<Friend>();
        var _loc3_:int = 0;
        while (_loc3_ < m.length) {
            _loc2_ = new Friend();
            _loc3_ = _loc2_.fill(m, _loc3_);
            _loc2_.isOnline = true;
            Player.onlineFriends.push(_loc2_);
        }
        onlineFriendsCallback();
    }
}
}

