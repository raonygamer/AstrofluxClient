package core.hud.components {
import com.greensock.TweenMax;

import core.hud.components.starMap.StarMap;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;

public class WarpGateFriendLocationSelector extends Sprite {
    public function WarpGateFriendLocationSelector(callback:Function) {
        super();
        this.callback = callback;
        closeButton = new Button(close, "Back");
        bgr.alpha = 0.5;
        addChild(bgr);
        addChild(box);
        box.addChild(closeButton);
        addEventListener("addedToStage", stageAddHandler);
    }
    protected var box:Box = new Box(5 * 60, 200, "highlight", 18);
    protected var closeButton:Button;
    protected var bgr:Quad = new Quad(100, 100, 0x22000000);
    private var callback:Function;

    private function closeAndWarp(doit:Boolean = true):void {
        TweenMax.to(this, 0.3, {
            "height": 0,
            "alpha": 0,
            "onComplete": function ():void {
                callback(doit);
            }
        });
    }

    protected function close(e:TouchEvent = null):void {
        closeAndWarp(false);
    }

    protected function draw(e:Event = null):void {
        if (stage == null) {
            return;
        }
        closeButton.x = Math.round(115);
        var _loc3_:int = 0;
        var _loc2_:int = 47;
        var _loc5_:WarpToFriendRow = new WarpToFriendRow("friendly", null, closeAndWarp);
        _loc5_.y = 3 + _loc2_ * _loc3_++;
        box.addChild(_loc5_);
        _loc5_ = new WarpToFriendRow("hostile", null, closeAndWarp);
        _loc5_.y = 3 + _loc2_ * _loc3_++;
        box.addChild(_loc5_);
        _loc5_ = new WarpToFriendRow("clan", null, closeAndWarp);
        _loc5_.y = 3 + _loc2_ * _loc3_++;
        box.addChild(_loc5_);
        for each(var _loc4_ in StarMap.friendsInSelectedSystem) {
            _loc5_ = new WarpToFriendRow("", _loc4_, closeAndWarp);
            _loc5_.y = 3 + _loc2_ * _loc3_++;
            box.addChild(_loc5_);
        }
        box.height = 50 + _loc3_ * _loc2_;
        closeButton.y = box.height - 60;
        box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
        box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
        bgr.width = stage.stageWidth;
        bgr.height = stage.stageHeight;
    }

    protected function clean(e:Event):void {
        stage.removeEventListener("resize", resize);
        removeEventListener("removedFromStage", clean);
        removeEventListener("addedToStage", stageAddHandler);
    }

    private function stageAddHandler(e:Event):void {
        addEventListener("removedFromStage", clean);
        stage.addEventListener("resize", resize);
        bgr.width = stage.stageWidth;
        bgr.height = stage.stageHeight;
        draw();
    }

    private function resize(e:Event):void {
        box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
        box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
    }
}
}

import com.adobe.crypto.MD5;

import core.friend.Friend;
import core.hud.components.Button;
import core.hud.components.Style;
import core.hud.components.Text;
import core.hud.components.starMap.StarMap;
import core.scene.Game;

import joinRoom.IJoinRoomManager;
import joinRoom.JoinRoomLocator;

import starling.display.Sprite;

class WarpToFriendRow extends Sprite {
    public function WarpToFriendRow(type:String, friend:Friend, callback:Function) {
        var playerInSystem:Text;
        var description:Text;
        var buttonText:String;
        var warpToFriendButton:Button;
        super();
        playerInSystem = new Text();
        description = new Text();
        playerInSystem.color = Style.COLOR_H2;
        if (friend == null) {
            playerInSystem.color = 0xaaaaaa;
        }
        playerInSystem.size = 14;
        description.size = 11;
        description.font = "Verdana";
        description.y = playerInSystem.y + 19;
        description.color = 0xffffff;
        buttonText = "Warp";
        if (type == "friendly") {
            playerInSystem.text = "Friendly";
            playerInSystem.color = Style.COLOR_FRIENDLY;
            description.text = "Other players are friendly";
        } else if (type == "hostile") {
            playerInSystem.size = 13;
            playerInSystem.text = "Hostile (+5 artifact levels)";
            playerInSystem.color = Style.COLOR_HOSTILE;
            description.text = "Other players may attack";
        } else if (type == "clan") {
            playerInSystem.size = 13;
            playerInSystem.text = "Clan Instance (-20% loot)";
            playerInSystem.color = Style.COLOR_HIGHLIGHT;
            description.text = "Only for clan members";
        } else {
            playerInSystem.text = friend.name;
            buttonText = "Warp";
        }
        warpToFriendButton = new Button(function ():void {
            setDesiredRoom(type, friend);
            callback();
        }, buttonText, "positive");
        if (type == "clan" && !Game.instance.me.clanId) {
            warpToFriendButton.enabled = false;
        }
        warpToFriendButton.x = 225;
        warpToFriendButton.y = playerInSystem.y;
        addChild(playerInSystem);
        addChild(description);
        addChild(warpToFriendButton);
    }

    private function setDesiredRoom(type:String, friend:Friend):void {
        var _loc3_:String = null;
        var _loc4_:IJoinRoomManager = JoinRoomLocator.getService();
        _loc4_.desiredRoomId = null;
        _loc4_.desiredSystemType = "friendly";
        if (type == "friendly") {
            _loc4_.desiredSystemType = "friendly";
        } else if (type == "hostile") {
            _loc4_.desiredSystemType = "hostile";
        } else if (type == "clan") {
            if (Game.instance.me.clanId) {
                _loc3_ = MD5.hash(StarMap.selectedSolarSystem.key + Game.instance.me.clanId);
                _loc4_.desiredRoomId = _loc3_;
                _loc4_.desiredSystemType = "clan";
            }
        } else {
            _loc4_.desiredRoomId = friend.currentRoom;
        }
    }
}
