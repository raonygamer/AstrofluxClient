package core.player {
import data.DataLocator;
import data.IDataManager;

import playerio.Message;

public class FleetObj {
    public function FleetObj() {
        super();
    }
    public var skin:String = "";
    public var shipHue:Number = 0;
    public var shipBrightness:Number = 0;
    public var shipSaturation:Number = 0;
    public var shipContrast:Number = 0;
    public var engineHue:Number = 0;
    public var activeWeapon:String = "";
    public var activeArtifactSetup:int;
    public var lastUsed:Number = 0;
    public var weapons:Array = [];
    public var weaponsState:Array = [];
    public var weaponsHotkeys:Array = [];
    public var techSkills:Vector.<TechSkill> = new Vector.<TechSkill>();
    public var nrOfUpgrades:Vector.<int> = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);

    public function initFromSkin(skinKey:String):void {
        var _loc2_:TechSkill = null;
        var _loc6_:IDataManager = DataLocator.getService();
        var _loc3_:Object = _loc6_.loadKey("Skins", skinKey);
        skin = skinKey;
        var _loc4_:Array = _loc3_.upgrades;
        for each(var _loc5_ in _loc4_) {
            _loc2_ = new TechSkill();
            _loc2_.table = _loc5_.table;
            _loc2_.tech = _loc5_.tech;
            _loc2_.name = _loc5_.name;
            _loc2_.level = _loc5_.level;
            techSkills.push(_loc2_);
            if (_loc5_.table == "Weapons") {
                weapons.push({"weapon": _loc5_.tech});
                weaponsState.push(false);
                weaponsHotkeys.push(0);
            }
        }
    }

    public function initFromMessage(m:Message, startIndex:int):int {
        skin = m.getString(startIndex++);
        activeArtifactSetup = m.getInt(startIndex++);
        activeWeapon = m.getString(startIndex++);
        shipHue = m.getNumber(startIndex++);
        shipBrightness = m.getNumber(startIndex++);
        shipSaturation = m.getNumber(startIndex++);
        shipContrast = m.getNumber(startIndex++);
        engineHue = m.getNumber(startIndex++);
        lastUsed = m.getNumber(startIndex++);
        startIndex = initWeaponsFromMessage(m, startIndex);
        return initTechSkillsFromMessage(m, startIndex, skin);
    }

    private function initWeaponsFromMessage(m:Message, startIndex:int):int {
        var _loc3_:int = 0;
        weapons = [];
        weaponsState = [];
        weaponsHotkeys = [];
        var _loc4_:int = m.getInt(startIndex);
        _loc3_ = startIndex + 1;
        while (_loc3_ < startIndex + _loc4_ * 3 + 1) {
            weapons.push({"weapon": m.getString(_loc3_)});
            weaponsState.push(m.getBoolean(_loc3_ + 1));
            weaponsHotkeys.push(m.getInt(_loc3_ + 2));
            _loc3_ += 3;
        }
        return _loc3_;
    }

    private function initTechSkillsFromMessage(m:Message, startIndex:int, skinKey:String):int {
        var _loc9_:int = 0;
        var _loc5_:int = 0;
        var _loc6_:TechSkill = null;
        var _loc8_:int = 0;
        var _loc11_:int = 0;
        var _loc10_:int = 0;
        var _loc12_:int = 0;
        techSkills = new Vector.<TechSkill>();
        var _loc4_:int = m.getInt(startIndex);
        nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
        var _loc7_:int = startIndex + 1;
        _loc9_ = 0;
        while (_loc9_ < _loc4_) {
            _loc5_ = m.getInt(_loc7_ + 3);
            _loc6_ = new TechSkill(m.getString(_loc7_), m.getString(_loc7_ + 1), m.getString(_loc7_ + 2), _loc5_, m.getString(_loc7_ + 4), m.getInt(_loc7_ + 5));
            _loc8_ = m.getInt(_loc7_ + 6);
            _loc7_ += 7;
            _loc11_ = 0;
            while (_loc11_ < _loc8_) {
                if (m.getString(_loc7_) != "") {
                    _loc6_.addEliteTechData(m.getString(_loc7_), m.getInt(_loc7_ + 1));
                }
                _loc7_ += 2;
                _loc11_++;
            }
            techSkills.push(_loc6_);
            _loc10_ = Player.getSkinTechLevel(_loc6_.tech, skinKey);
            if (_loc5_ > _loc10_) {
                var _loc13_:* = 0;
                var _loc14_:* = nrOfUpgrades[_loc13_] + _loc5_;
                nrOfUpgrades[_loc13_] = _loc14_;
                if (_loc5_ > 0) {
                    _loc12_ = 1;
                    while (_loc12_ <= _loc5_) {
                        _loc14_ = _loc12_;
                        _loc13_ = nrOfUpgrades[_loc14_] + 1;
                        nrOfUpgrades[_loc14_] = _loc13_;
                        _loc12_++;
                    }
                }
            }
            _loc9_++;
        }
        return _loc7_;
    }
}
}

