package core.controlZones {
import core.scene.Game;

import flash.utils.Dictionary;

import playerio.DatabaseObject;
import playerio.Message;

public class ControlZoneManager {
    public static var claimData:Message;

    public function ControlZoneManager(g:Game) {
        super();
        this.g = g;
    }
    public var controlZones:Vector.<ControlZone> = new Vector.<ControlZone>();
    private var g:Game;

    public function init():void {
        if (!g.isSystemTypeHostile()) {
            return;
        }
        if (g.me.clanId == "") {
            return;
        }
        load();
    }

    public function load(callback:Function = null):void {
        if (controlZones.length > 0) {
            if (Boolean(callback)) {
                callback();
                return;
            }
            return;
        }
        g.dataManager.loadRangeFromBigDB("ControlZones", "ByPlayer", null, function (param1:Array):void {
            onGetControlZones(param1);
            if (Boolean(callback)) {
                callback();
            }
        });
    }

    public function addMessageHandlers():void {
        g.addMessageHandler("updateControlZones", onUpdateControlZones);
        g.addMessageHandler("zoneClaimed", onZoneClaimed);
        g.addServiceMessageHandler("updateClaimedZone", onUpdateClaimedZone);
    }

    public function onUpdateControlZones(m:Message):void {
        g.sendToServiceRoom("updateControlZones");
    }

    public function onUpdateClaimedZone(m:Message):void {
        var _loc2_:String = m.getString(0);
        var _loc3_:ControlZone = getZoneByKey(_loc2_);
        if (_loc3_ != null) {
            controlZones.splice(controlZones.indexOf(_loc3_), 1);
        }
        var _loc4_:int = 1;
        var _loc5_:ControlZone = new ControlZone();
        _loc5_.key = _loc2_;
        _loc5_.claimTime = m.getNumber(_loc4_++);
        _loc5_.releaseTime = m.getNumber(_loc4_++);
        _loc5_.playerKey = m.getString(_loc4_++);
        _loc5_.clanKey = m.getString(_loc4_++);
        _loc5_.clanName = m.getString(_loc4_++);
        _loc5_.clanLogo = m.getString(_loc4_++);
        _loc5_.clanColor = m.getUInt(_loc4_++);
        _loc5_.solarSystemKey = m.getString(_loc4_++);
        _loc5_.troonsPerMinute = m.getInt(_loc4_++);
        controlZones.push(_loc5_);
        g.hud.clanButton.updateTroons();
    }

    public function getZoneByKey(key:String):ControlZone {
        var _loc2_:int = 0;
        var _loc3_:ControlZone = null;
        _loc2_ = 0;
        while (_loc2_ < controlZones.length) {
            _loc3_ = controlZones[_loc2_];
            if (_loc3_.key == key) {
                return _loc3_;
            }
            _loc2_++;
        }
        return null;
    }

    public function getTotalTroonsPerMinute(clanKey:String):int {
        var _loc2_:int = 0;
        var _loc4_:ControlZone = null;
        var _loc3_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < controlZones.length) {
            _loc4_ = controlZones[_loc2_];
            if (clanKey == _loc4_.clanKey) {
                _loc3_ += _loc4_.troonsPerMinute;
            }
            _loc2_++;
        }
        return _loc3_;
    }

    public function getTopTroonsPerMinuteClans():Vector.<Object> {
        var controlZone:ControlZone;
        var sortedArray:Vector.<Object>;
        var prop:String;
        var topTroonsPerMinuteDict:Dictionary = new Dictionary();
        for each(controlZone in controlZones) {
            if (topTroonsPerMinuteDict[controlZone.clanKey] == null) {
                topTroonsPerMinuteDict[controlZone.clanKey] = {};
                topTroonsPerMinuteDict[controlZone.clanKey].key = controlZone.clanKey;
                topTroonsPerMinuteDict[controlZone.clanKey].name = controlZone.clanName;
                topTroonsPerMinuteDict[controlZone.clanKey].logo = controlZone.clanLogo;
                topTroonsPerMinuteDict[controlZone.clanKey].color = controlZone.clanColor;
                topTroonsPerMinuteDict[controlZone.clanKey].troons = 0;
            }
            topTroonsPerMinuteDict[controlZone.clanKey].troons += controlZone.troonsPerMinute;
        }
        sortedArray = new Vector.<Object>();
        for (prop in topTroonsPerMinuteDict) {
            sortedArray.push(topTroonsPerMinuteDict[prop]);
        }
        sortedArray.sort(function (param1:Object, param2:Object):int {
            return param2.troons - param1.troons;
        });
        return sortedArray;
    }

    private function onZoneClaimed(m:Message):void {
        claimData = m;
    }

    private function onGetControlZones(zonesArray:Array):void {
        var _loc3_:int = 0;
        var _loc2_:DatabaseObject = null;
        var _loc5_:ControlZone = null;
        controlZones.length = 0;
        var _loc4_:int = int(zonesArray.length);
        _loc3_ = 0;
        while (_loc3_ < _loc4_) {
            _loc2_ = zonesArray[_loc3_];
            _loc5_ = new ControlZone();
            _loc5_.key = _loc2_.key;
            _loc5_.claimTime = _loc2_.claimTime;
            _loc5_.releaseTime = _loc2_.releaseTime;
            _loc5_.playerKey = _loc2_.player;
            _loc5_.clanKey = _loc2_.clan;
            _loc5_.clanName = _loc2_.clanName;
            _loc5_.clanLogo = _loc2_.clanLogo;
            _loc5_.clanColor = _loc2_.clanColor;
            _loc5_.solarSystemKey = _loc2_.solarSystem;
            _loc5_.troonsPerMinute = _loc2_.troonsPerMinute;
            controlZones.push(_loc5_);
            _loc3_++;
        }
    }
}
}

