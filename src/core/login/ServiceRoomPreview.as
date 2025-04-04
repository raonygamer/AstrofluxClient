package core.login {
import com.greensock.TweenMax;

import core.friend.Friend;
import core.hud.components.Text;

import playerio.Connection;
import playerio.Message;
import playerio.PlayerIOError;
import playerio.RoomInfo;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.TouchEvent;

public class ServiceRoomPreview extends Sprite {
    public static const roomNames:Array = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "beta", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"];
    public static var WIDTH:int = 300;

    public function ServiceRoomPreview(info:RoomInfo, selectCallback:Function, serviceRoomSelector:ServiceRoomSelector) {
        super();
        this.info = info;
        this.selectCallback = selectCallback;
        this.serviceRoomSelector = serviceRoomSelector;
        bg = new Quad(WIDTH, 50, 0);
        bg.alpha = 0.7;
        addChild(bg);
        _name.color = 0xffffff;
        online.color = 0xff00;
        friends.color = 10854300;
        status.color = 10854300;
        level.color = status.color;
        recommended.color = 16441344;
        status.alignRight();
        level.alignRight();
        _name.text = getName().toUpperCase();
        _name.size = 12;
        status.size = 14;
        online.text = info.onlineUsers + " ONLINE";
        if (info.onlineUsers == 0) {
            online.text = "EMPTY";
            online.color = 10854300;
        }
        online.size = 11;
        friends.size = 11;
        recommended.text = "RECOMMENDED";
        recommendedBg = new Quad(recommended.width - 1, recommended.height - 12, 0);
        recommendedBg.alpha = 0.7;
        var _loc4_:int = 5;
        _name.y = online.y = level.y = _loc4_;
        _name.x = friends.x = 5;
        online.x = _name.x + _name.width + _loc4_ / 2;
        friends.y = _name.y + _name.height;
        status.y = friends.y;
        status.x = bg.width - _loc4_;
        level.x = status.x;
        recommended.y = y - recommended.height / 3;
        recommended.x = width / 2 - recommended.width / 2;
        recommended.visible = false;
        recommendedBg.visible = false;
        recommendedBg.x = recommended.x - 1;
        recommendedBg.y = recommended.y;
        bg.height = status.y + status.height + 22;
        addChild(_name);
        addChild(friends);
        addChild(online);
        addChild(status);
        addChild(level);
        addChild(recommendedBg);
        addChild(recommended);
        addEventListener("touch", onTouch);
        useHandCursor = true;
        if (_name.text == "") {
            this.enabled = false;
        } else {
            join();
        }
    }
    public var info:RoomInfo;
    public var enabled:Boolean = false;
    public var even:Boolean = true;
    public var avgLevel:int = -1;
    public var playerLevel:int = -1;
    public var isClosing:Boolean = false;
    private var _name:Text = new Text();
    private var online:Text = new Text();
    private var friends:Text = new Text();
    private var status:Text = new Text();
    private var level:Text = new Text();
    private var recommended:Text = new Text();
    private var recommendedBg:Quad;
    private var selectCallback:Function;
    private var serviceRoomSelector:ServiceRoomSelector;
    private var bg:Quad;
    private var isSupporter:Boolean = false;
    private var onlineFriends:Vector.<Friend>;
    private var friendsTooltip:Sprite;

    public function selectRoom():void {
        selectCallback(this, info.id);
    }

    public function isOpenForAll():Boolean {
        return info.onlineUsers < 950;
    }

    public function isOpenForSupporters():Boolean {
        return info.onlineUsers < 1000;
    }

    public function disable():void {
        enabled = false;
        this.removeEventListeners();
        TweenMax.to(this, 0.3, {"alpha": 0});
    }

    public function highlight():void {
        var _loc1_:Quad = new Quad(bg.width + 4, bg.height + 4, 11150770);
        _loc1_.x = -2;
        _loc1_.y = -2;
        bg.alpha = 0.9;
        addChildAt(_loc1_, 0);
    }

    public function trySetClosing():void {
        var _loc1_:int = ServiceRoomSelector.totalFree - info.onlineUsers;
        if (_loc1_ < 950) {
            return;
        }
        status.text = "CLOSING DOWN";
        status.color = 13202944;
        status.size = 10;
        status.y += 3;
        enabled = false;
        isClosing = true;
        useHandCursor = false;
        alpha = 0.5;
    }

    public function setRecommended(v:Boolean):void {
        recommended.visible = v;
        recommendedBg.visible = v;
    }

    private function getName():String {
        var _loc1_:int = getIndex();
        if (_loc1_ > roomNames.length - 1) {
            return "n/a";
        }
        if (!roomNames[_loc1_]) {
            return "";
        }
        return roomNames[_loc1_];
    }

    private function getIndex():int {
        var _loc2_:Number = NaN;
        var _loc1_:Array = info.id.split("_");
        if (_loc1_.length == 2) {
            _loc2_ = Number(_loc1_[1]);
            if (!isNaN(_loc2_)) {
                return _loc2_;
            }
        }
        return -1;
    }

    private function validate():Boolean {
        if (getIndex() < 0) {
            return false;
        }
        if (getIndex() > roomNames.length - 1) {
            return false;
        }
        return true;
    }

    private function join():void {
        if (!validate()) {
            this.visible = false;
            return;
        }
        if (info.onlineUsers == 0) {
            updateStatus();
            return;
        }
        friends.text = "Looking for friends...";
        Login.client.multiplayer.joinRoom(info.id, {
            "client_version": 1388,
            "preview": "true"
        }, joined, function (param1:PlayerIOError):void {
            var _loc2_:String = null;
            if (param1.errorID != 2) {
                _loc2_ = param1.message;
                if (_loc2_.indexOf("The room cannot") > -1) {
                    full(true);
                } else {
                    status.text = "An error occured...";
                }
                trace(_loc2_);
                friends.color = 0xff0000;
            }
        });
    }

    private function joined(c:Connection):void {
        var connection:playerio.Connection = c;
        connection.addMessageHandler("onlineFriends", onOnlineFriends);
        connection.addMessageHandler("preview", onPreview);
        connection.addMessageHandler("error", function (param1:Message):void {
            friends.text = param1.getString(0);
            friends.color = 0xff0000;
        });
    }

    private function onPreview(m:Message):void {
        isSupporter = m.getBoolean(0);
        ServiceRoomSelector.isSupporter = isSupporter;
        playerLevel = m.getInt(1);
        ServiceRoomSelector.playerLevel = playerLevel;
        avgLevel = m.getInt(2);
        level.text = "Avg level " + avgLevel;
        serviceRoomSelector.updateRecommended();
        if (playerLevel == 0) {
            serviceRoomSelector.setNewPlayer();
        }
    }

    private function onOnlineFriends(m:Message):void {
        var _loc3_:Friend = null;
        onlineFriends = new Vector.<Friend>();
        var _loc4_:int = 0;
        var _loc2_:String = "";
        while (_loc4_ < m.length) {
            _loc3_ = new Friend();
            _loc4_ = _loc3_.fill(m, _loc4_);
            _loc3_.isOnline = true;
            onlineFriends.push(_loc3_);
            _loc2_ += _loc3_.name + ", ";
        }
        _loc2_ = _loc2_.substr(0, _loc2_.length - 2);
        if (onlineFriends.length > 0) {
            friends.text = onlineFriends.length + " friends online";
        } else {
            friends.text = " ";
        }
        updateStatus();
        showFriendsTooltip();
    }

    private function showFriendsTooltip():void {
        var _loc2_:int = 0;
        var _loc3_:Text = null;
        if (!onlineFriends) {
            return;
        }
        if (friendsTooltip != null) {
            friendsTooltip.visible = true;
            return;
        }
        if (onlineFriends.length == 0) {
            return;
        }
        friendsTooltip = new Sprite();
        _loc2_ = 0;
        while (_loc2_ < onlineFriends.length) {
            _loc3_ = new Text(3, 3);
            _loc3_.text = onlineFriends[_loc2_].name;
            _loc3_.color = 0;
            _loc3_.y += _loc2_ * (_loc3_.height - 1);
            _loc3_.size = 10;
            friendsTooltip.addChild(_loc3_);
            _loc2_++;
        }
        var _loc1_:Quad = new Quad(friendsTooltip.width + 10, friendsTooltip.height + 3, 0xff00);
        _loc1_.alpha = 0.3;
        friendsTooltip.addChildAt(_loc1_, 0);
        if (even) {
            friendsTooltip.x = 0 - friendsTooltip.width;
        } else {
            friendsTooltip.x = width;
        }
        friendsTooltip.y = 0;
        addChild(friendsTooltip);
        hideFriends();
    }

    private function hideFriends():void {
        if (!friendsTooltip) {
            return;
        }
        friendsTooltip.visible = false;
    }

    private function updateStatus():void {
        if (isClosing) {
            return;
        }
        if (isOpenForAll()) {
            status.text = "JOIN >";
            status.color = 0xff00;
            enabled = true;
            return;
        }
        if (isOpenForSupporters()) {
            status.size = 10;
            status.text = "OPEN FOR SUPPORTERS >";
            status.color = 16426240;
            status.y += 3;
            if (isSupporter) {
                enabled = true;
            }
            return;
        }
        full();
    }

    private function full(fromError:Boolean = false):void {
        status.text = "FULL";
        status.color = 0xff0000;
        if (fromError) {
            online.text = "1000 online";
            friends.text = "";
        }
    }

    private function onTouch(e:TouchEvent):void {
        if (e.getTouch(this) == null) {
            hideFriends();
        }
        if (e.getTouch(this, "hover")) {
            showFriendsTooltip();
        }
        if (!enabled) {
            return;
        }
        if (e.getTouch(this, "ended")) {
            enabled = false;
            selectRoom();
        }
    }
}
}

