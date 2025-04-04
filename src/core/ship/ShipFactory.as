package core.ship {
import core.engine.EngineFactory;
import core.player.EliteTechs;
import core.player.FleetObj;
import core.player.Player;
import core.player.TechSkill;
import core.scene.Game;
import core.turret.Turret;
import core.unit.Unit;
import core.weapon.Weapon;
import core.weapon.WeaponFactory;

import data.DataLocator;
import data.IDataManager;

import generics.Random;

import sound.ISound;
import sound.SoundLocator;

import starling.filters.ColorMatrixFilter;

public class ShipFactory {
    public static function createPlayer(g:Game, player:Player, ship:PlayerShip, weapons:Array):PlayerShip {
        var _loc10_:ColorMatrixFilter = null;
        var _loc8_:IDataManager = DataLocator.getService();
        var _loc6_:Object = _loc8_.loadKey("Skins", player.activeSkin);
        var _loc11_:FleetObj = player.getActiveFleetObj();
        ship.hideShadow = _loc6_.hideShadow;
        createBody(_loc6_.ship, g, ship);
        ship = PlayerShip(ship);
        ship.name = player.name;
        ship.setIsHostile(player.isHostile);
        ship.group = player.group;
        ship.factions = player.factions;
        ship.hpBase = ship.hpMax;
        ship.shieldHpBase = ship.shieldHpMax;
        ship.activeWeapons = 0;
        ship.unlockedWeaponSlots = player.unlockedWeaponSlots;
        ship.player = player;
        ship.artifact_convAmount = 0;
        ship.artifact_cooldownReduction = 0;
        ship.artifact_speed = 0;
        ship.artifact_powerRegen = 0;
        ship.artifact_powerMax = 0;
        ship.artifact_refire = 0;
        var _loc9_:Number = !!_loc11_.shipHue ? _loc11_.shipHue : 0;
        var _loc5_:Number = !!_loc11_.shipBrightness ? _loc11_.shipBrightness : 0;
        if (_loc9_ != 0 || _loc5_ != 0) {
            _loc10_ = createPlayerShipColorMatrixFilter(_loc11_);
            ship.movieClip.filter = _loc10_;
            ship.originalFilter = _loc10_;
        }
        ship.engine = EngineFactory.create(_loc6_.engine, g, ship);
        var _loc7_:Number = !!_loc11_.engineHue ? _loc11_.engineHue : 0;
        addEngineTechToShip(player, ship);
        ship.engine.colorHue = _loc7_;
        CreatePlayerShipWeapon(g, player, 0, weapons, ship);
        addArmorTechToShip(player, ship);
        addShieldTechToShip(player, ship);
        addPowerTechToShip(player, ship);
        addLevelBonusToShip(g, player.level, ship);
        ship.hp = ship.hpMax;
        ship.shieldHp = ship.shieldHpMax;
        return ship;
    }

    public static function createPlayerShipColorMatrixFilter(fleetObj:FleetObj):ColorMatrixFilter {
        if (RymdenRunt.isBuggedFlashVersion) {
            return null;
        }
        var _loc6_:ColorMatrixFilter = new ColorMatrixFilter();
        var _loc5_:Number = !!fleetObj.shipHue ? fleetObj.shipHue : 0;
        var _loc3_:Number = !!fleetObj.shipBrightness ? fleetObj.shipBrightness : 0;
        var _loc2_:Number = !!fleetObj.shipSaturation ? fleetObj.shipSaturation : 0;
        var _loc4_:Number = !!fleetObj.shipContrast ? fleetObj.shipContrast : 0;
        _loc6_.resolution = 2;
        _loc6_.adjustHue(_loc5_);
        _loc6_.adjustBrightness(_loc3_);
        _loc6_.adjustSaturation(_loc2_);
        _loc6_.adjustContrast(_loc4_);
        return _loc6_;
    }

    public static function CreatePlayerShipWeapon(g:Game, player:Player, i:int, weapons:Array, ship:PlayerShip):void {
        var _loc7_:int = 0;
        var _loc6_:TechSkill = null;
        var _loc9_:Weapon = null;
        var _loc8_:Object = weapons[i];
        var _loc11_:int = 0;
        var _loc10_:int = -1;
        var _loc13_:String = "";
        if (player != null && player.techSkills != null && _loc8_ != null) {
            _loc7_ = 0;
            while (_loc7_ < player.techSkills.length) {
                _loc6_ = player.techSkills[_loc7_];
                if (_loc6_.tech == _loc8_.weapon) {
                    _loc11_ = _loc6_.level;
                    _loc10_ = _loc6_.activeEliteTechLevel;
                    _loc13_ = _loc6_.activeEliteTech;
                }
                _loc7_++;
            }
        }
        var _loc12_:Weapon = WeaponFactory.create(_loc8_.weapon, g, ship, _loc11_, _loc10_, _loc13_);
        _loc12_.setActive(ship, player.weaponsState[i]);
        _loc12_.hotkey = player.weaponsHotkeys[i];
        addLevelBonusToWeapon(g, player.level, _loc12_, player);
        if (i < ship.weapons.length) {
            _loc9_ = ship.weapons[i];
            ship.weapons[i] = _loc12_;
            _loc9_.destroy();
        } else {
            ship.weapons.push(_loc12_);
        }
        if (i == weapons.length - 1) {
            player.saveWeaponData(ship.weapons);
        } else {
            i += 1;
            CreatePlayerShipWeapon(g, player, i, weapons, ship);
        }
    }

    public static function createEnemy(g:Game, key:String, rareType:int = 0):EnemyShip {
        var _loc5_:Number = NaN;
        var _loc4_:Random = null;
        var _loc8_:IDataManager = DataLocator.getService();
        var _loc6_:Object = _loc8_.loadKey("Enemies", key);
        if (g.isLeaving) {
            return null;
        }
        if (_loc6_ == null) {
            trace("Key: ", key);
            return null;
        }
        var _loc7_:EnemyShip = g.shipManager.getEnemyShip();
        _loc7_.name = _loc6_.name;
        _loc7_.xp = _loc6_.xp;
        _loc7_.level = _loc6_.level;
        _loc7_.rareType = rareType;
        _loc7_.aggroRange = _loc6_.aggroRange;
        _loc7_.chaseRange = _loc6_.chaseRange;
        _loc7_.observer = _loc6_.observer;
        if (_loc7_.observer) {
            _loc7_.visionRange = _loc6_.visionRange;
        } else {
            _loc7_.visionRange = _loc7_.aggroRange;
        }
        if (g.isSystemTypeSurvival() && _loc7_.level < g.hud.uberStats.uberLevel) {
            _loc5_ = g.hud.uberStats.CalculateUberRankFromLevel(_loc7_.level);
            _loc7_.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc5_, _loc7_.level);
            _loc7_.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _loc7_.level) / 100;
            _loc7_.aggroRange *= _loc7_.uberLevelFactor;
            _loc7_.chaseRange *= _loc7_.uberLevelFactor;
            _loc7_.visionRange *= _loc7_.uberLevelFactor;
            _loc4_ = new Random(_loc7_.id);
            if (_loc7_.aggroRange > 2000) {
                _loc7_.aggroRange = 10000;
            } else if (g.hud.uberStats.uberRank >= 9) {
                _loc7_.aggroRange = 50 * 60 + _loc4_.random(10000);
            } else if (g.hud.uberStats.uberRank >= 6) {
                _loc7_.aggroRange = 2000 + _loc4_.random(10000);
            } else if (g.hud.uberStats.uberRank >= 3) {
                _loc7_.aggroRange = 25 * 60 + _loc4_.random(10000);
            } else if (_loc7_.aggroRange < 50 * 60) {
                _loc7_.aggroRange = 1000 + _loc4_.random(10000);
            }
            _loc7_.chaseRange = _loc7_.aggroRange;
            _loc7_.visionRange = _loc7_.aggroRange;
            _loc7_.xp *= _loc7_.uberLevelFactor;
            _loc7_.level = g.hud.uberStats.uberLevel;
        }
        _loc7_.orbitSpawner = _loc6_.orbitSpawner;
        if (_loc7_.orbitSpawner) {
            _loc7_.hpRegen = _loc6_.hpRegen;
        }
        _loc7_.aimSkill = _loc6_.aimSkill;
        if (_loc6_.hasOwnProperty("stopWhenClose")) {
            _loc7_.stopWhenClose = _loc6_.stopWhenClose;
        }
        if (_loc6_.hasOwnProperty("AIFaction1") && _loc6_.AIFaction1 != "") {
            _loc7_.factions.push(_loc6_.AIFaction1);
        }
        if (_loc6_.hasOwnProperty("AIFaction2") && _loc6_.AIFaction2 != "") {
            _loc7_.factions.push(_loc6_.AIFaction2);
        }
        if (_loc6_.hasOwnProperty("teleport")) {
            _loc7_.teleport = _loc6_.teleport;
        }
        _loc7_.kamikaze = _loc6_.kamikaze;
        if (_loc7_.kamikaze) {
            _loc7_.kamikazeLifeTreshhold = _loc6_.kamikazeLifeTreshhold;
            _loc7_.kamikazeHoming = _loc6_.kamikazeHoming;
            _loc7_.kamikazeTtl = _loc6_.kamikazeTtl;
            _loc7_.kamikazeDmg = _loc6_.kamikazeDmg;
            _loc7_.kamikazeRadius = _loc6_.kamikazeRadius;
            _loc7_.kamikazeWhenClose = _loc6_.kamikazeWhenClose;
        }
        if (_loc6_.hasOwnProperty("alwaysFire")) {
            _loc7_.alwaysFire = _loc6_.alwaysFire;
        } else {
            _loc7_.alwaysFire = false;
        }
        _loc7_.forcedRotation = _loc6_.forcedRotation;
        if (_loc7_.forcedRotation) {
            _loc7_.forcedRotationSpeed = _loc6_.forcedRotationSpeed;
            _loc7_.forcedRotationAim = _loc6_.forcedRotationAim;
        }
        _loc7_.melee = _loc6_.melee;
        if (_loc7_.melee) {
            _loc7_.meleeCharge = _loc6_.charge;
            _loc7_.meleeChargeSpeedBonus = Number(_loc6_.chargeSpeedBonus) / 100;
            _loc7_.meleeChargeDuration = _loc6_.chargeDuration;
            _loc7_.meleeCanGrab = _loc6_.grab;
        }
        _loc7_.flee = _loc6_.flee;
        if (_loc7_.flee) {
            _loc7_.fleeLifeTreshhold = _loc6_.fleeLifeTreshhold;
            _loc7_.fleeDuration = _loc6_.fleeDuration;
            if (_loc6_.hasOwnProperty("fleeClose")) {
                _loc7_.fleeClose = _loc6_.fleeClose;
            } else {
                _loc7_.fleeClose = 0;
            }
        }
        _loc7_.aiCloak = false;
        if (_loc6_.hasOwnProperty("hardenShield")) {
            _loc7_.aiHardenShield = false;
            _loc7_.aiHardenShieldDuration = _loc6_.hardenShieldDuration;
        } else {
            _loc7_.aiHardenShield = false;
            _loc7_.aiHardenShieldDuration = 0;
        }
        if (_loc6_.hasOwnProperty("sniper")) {
            _loc7_.sniper = _loc6_.sniper;
            if (_loc7_.sniper) {
                _loc7_.sniperMinRange = _loc6_.sniperMinRange;
            }
        }
        _loc7_.isHostile = true;
        _loc7_.group = null;
        createBody(_loc6_.ship, g, _loc7_);
        _loc7_.engine = EngineFactory.create(_loc6_.engine, g, _loc7_);
        if (_loc7_.uberDifficulty > 0) {
            _loc7_.hp = _loc7_.hpMax *= _loc7_.uberDifficulty;
            _loc7_.shieldHp = _loc7_.shieldHpMax *= _loc7_.uberDifficulty;
            _loc7_.engine.speed *= _loc7_.uberLevelFactor;
            if (_loc7_.engine.speed > 380) {
                _loc7_.engine.speed = 380;
            }
        }
        if (rareType == 1) {
            _loc7_.hp = _loc7_.hpMax *= 3;
            _loc7_.shieldHp = _loc7_.shieldHpMax *= 3;
        }
        if (rareType == 4) {
            _loc7_.hp = _loc7_.hpMax *= 3;
            _loc7_.shieldHp = _loc7_.shieldHpMax *= 3;
            _loc7_.engine.speed *= 1.1;
        }
        if (rareType == 5) {
            _loc7_.color = 0xff8811;
            _loc7_.hp = _loc7_.hpMax *= 10;
            _loc7_.shieldHp = _loc7_.shieldHpMax *= 10;
            _loc7_.engine.speed *= 1.3;
        }
        if (rareType == 3) {
            _loc7_.engine.speed *= 1.4;
        }
        if (_loc6_.hasOwnProperty("startHp")) {
            _loc7_.hp = 0.01 * _loc6_.startHp * _loc7_.hp;
        }
        CreateEnemyShipWeapon(g, 0, _loc6_.weapons, _loc7_);
        CreateEnemyShipExtraWeapon(g, _loc7_.weapons.length, _loc6_.fleeWeaponItem, _loc7_, 0);
        CreateEnemyShipExtraWeapon(g, _loc7_.weapons.length, _loc6_.antiProjectileWeaponItem, _loc7_, 1);
        if (!g.isLeaving) {
            g.shipManager.activateEnemyShip(_loc7_);
        }
        return _loc7_;
    }

    public static function createBody(key:String, g:Game, s:Unit):void {
        var _loc6_:IDataManager = DataLocator.getService();
        var _loc4_:Object = _loc6_.loadKey("Ships", key);
        s.switchTexturesByObj(_loc4_);
        if (_loc4_.blendModeAdd) {
            s.movieClip.blendMode = "add";
        }
        s.obj = _loc4_;
        s.bodyName = _loc4_.name;
        s.collisionRadius = _loc4_.collisionRadius;
        s.hp = _loc4_.hp;
        s.hpMax = _loc4_.hp;
        s.shieldHp = _loc4_.shieldHp;
        s.shieldHpMax = _loc4_.shieldHp;
        s.armorThreshold = _loc4_.armor;
        s.armorThresholdBase = _loc4_.armor;
        s.shieldRegenBase = 1.5 * _loc4_.shieldRegen;
        s.shieldRegen = s.shieldRegenBase;
        if (s is Ship) {
            s.enginePos.x = _loc4_.enginePosX;
            s.enginePos.y = _loc4_.enginePosY;
            s.weaponPos.x = _loc4_.weaponPosX;
            s.weaponPos.y = _loc4_.weaponPosY;
        } else {
            s is Turret;
        }
        s.weaponPos.x = _loc4_.weaponPosX;
        s.weaponPos.y = _loc4_.weaponPosY;
        s.explosionEffect = _loc4_.explosionEffect;
        s.explosionSound = _loc4_.explosionSound;
        var _loc5_:ISound = SoundLocator.getService();
        if (s.explosionSound != null) {
            _loc5_.preCacheSound(s.explosionSound);
        }
    }

    private static function addArmorTechToShip(player:Player, s:PlayerShip):void {
        var _loc8_:int = 0;
        var _loc3_:TechSkill = null;
        var _loc10_:Object = null;
        var _loc7_:int = 0;
        _loc8_ = 0;
        while (_loc8_ < player.techSkills.length) {
            _loc3_ = player.techSkills[_loc8_];
            if (_loc3_.tech == "m4yG1IRPIUeyRQHrC3h5kQ") {
                break;
            }
            _loc8_++;
        }
        var _loc9_:IDataManager = DataLocator.getService();
        var _loc5_:Object = _loc9_.loadKey("BasicTechs", _loc3_.tech);
        var _loc6_:int = _loc3_.level;
        _loc7_ = 0;
        while (_loc7_ < _loc6_) {
            _loc10_ = _loc5_.techLevels[_loc7_];
            s.armorThreshold += _loc10_.dmgThreshold;
            s.armorThresholdBase += _loc10_.dmgThreshold;
            s.hpBase += _loc10_.hpBonus;
            if (_loc7_ == _loc6_ - 1) {
                if (_loc10_.armorConvGain > 0) {
                    s.hasArmorConverter = true;
                    s.convCD = _loc10_.cooldown * 1000;
                    s.convCost = _loc10_.armorConvCost;
                    s.convGain = _loc10_.armorConvGain;
                }
            }
            _loc7_++;
        }
        s.hpMax = s.hpBase;
        var _loc4_:int = -1;
        var _loc11_:String = "";
        _loc4_ = _loc3_.activeEliteTechLevel;
        _loc11_ = _loc3_.activeEliteTech;
        EliteTechs.addEliteTechs(s, _loc5_, _loc4_, _loc11_);
    }

    private static function addShieldTechToShip(player:Player, s:PlayerShip):void {
        var _loc8_:int = 0;
        var _loc3_:TechSkill = null;
        var _loc10_:Object = null;
        var _loc7_:int = 0;
        _loc8_ = 0;
        while (_loc8_ < player.techSkills.length) {
            _loc3_ = player.techSkills[_loc8_];
            if (_loc3_.tech == "QgKEEj8a-0yzYAJ06eSLqA") {
                break;
            }
            _loc8_++;
        }
        var _loc9_:IDataManager = DataLocator.getService();
        var _loc5_:Object = _loc9_.loadKey("BasicTechs", _loc3_.tech);
        var _loc6_:int = _loc3_.level;
        _loc7_ = 0;
        while (_loc7_ < _loc6_) {
            _loc10_ = _loc5_.techLevels[_loc7_];
            s.shieldHpBase += _loc10_.hpBonus;
            s.shieldRegenBase += _loc10_.regen;
            if (_loc7_ == _loc6_ - 1) {
                if (_loc10_.hardenMaxDmg > 0) {
                    s.hasHardenedShield = true;
                    s.hardenMaxDmg = _loc10_.hardenMaxDmg;
                    s.hardenCD = _loc10_.cooldown * 1000;
                    s.hardenDuration = _loc10_.duration * 1000;
                }
            }
            _loc7_++;
        }
        s.shieldRegen = s.shieldRegenBase;
        s.shieldHpMax = s.shieldHpBase;
        var _loc4_:int = -1;
        var _loc11_:String = "";
        _loc4_ = _loc3_.activeEliteTechLevel;
        _loc11_ = _loc3_.activeEliteTech;
        EliteTechs.addEliteTechs(s, _loc5_, _loc4_, _loc11_);
    }

    private static function addEngineTechToShip(player:Player, s:PlayerShip):void {
        var _loc5_:int = 0;
        var _loc3_:TechSkill = null;
        var _loc7_:Object = null;
        var _loc4_:int = 0;
        _loc5_ = 0;
        while (_loc5_ < player.techSkills.length) {
            _loc3_ = player.techSkills[_loc5_];
            if (_loc3_.tech == "rSr1sn-_oUOY6E0hpAhh0Q") {
                break;
            }
            _loc5_++;
        }
        var _loc12_:IDataManager = DataLocator.getService();
        var _loc9_:Object = _loc12_.loadKey("BasicTechs", _loc3_.tech);
        var _loc10_:int = _loc3_.level;
        var _loc6_:int = 100;
        var _loc11_:int = 100;
        _loc4_ = 0;
        while (_loc4_ < _loc10_) {
            _loc7_ = _loc9_.techLevels[_loc4_];
            _loc6_ += _loc7_.acceleration;
            _loc11_ += _loc7_.maxSpeed;
            if (_loc4_ == _loc10_ - 1) {
                if (_loc7_.boost > 0) {
                    s.hasBoost = true;
                    s.boostBonus = _loc7_.boost;
                    s.boostCD = _loc7_.cooldown * 1000;
                    s.boostDuration = _loc7_.duration * 1000;
                    s.totalTicksOfBoost = s.boostDuration / 33;
                    s.ticksOfBoost = 0;
                }
            }
            _loc4_++;
        }
        s.engine.acceleration = s.engine.acceleration * _loc6_ / 100;
        s.engine.speed = s.engine.speed * _loc11_ / 100;
        var _loc8_:int = -1;
        var _loc13_:String = "";
        _loc8_ = _loc3_.activeEliteTechLevel;
        _loc13_ = _loc3_.activeEliteTech;
        EliteTechs.addEliteTechs(s, _loc9_, _loc8_, _loc13_);
    }

    private static function addPowerTechToShip(player:Player, s:PlayerShip):void {
        var _loc8_:int = 0;
        var _loc3_:TechSkill = null;
        var _loc10_:Object = null;
        var _loc7_:int = 0;
        _loc8_ = 0;
        while (_loc8_ < player.techSkills.length) {
            _loc3_ = player.techSkills[_loc8_];
            if (_loc3_.tech == "kwlCdExeJk-oEJZopIz5kg") {
                break;
            }
            _loc8_++;
        }
        var _loc9_:IDataManager = DataLocator.getService();
        var _loc5_:Object = _loc9_.loadKey("BasicTechs", _loc3_.tech);
        var _loc6_:int = _loc3_.level;
        s.maxPower = 1;
        s.powerRegBonus = 1;
        _loc7_ = 0;
        while (_loc7_ < _loc6_) {
            _loc10_ = _loc5_.techLevels[_loc7_];
            s.maxPower += 0.01 * Number(_loc10_.maxPower);
            s.powerRegBonus += 0.01 * Number(_loc10_.powerReg);
            if (_loc7_ == _loc6_ - 1) {
                if (_loc10_.boost > 0) {
                    s.hasDmgBoost = true;
                    s.dmgBoostCD = _loc10_.cooldown * 1000;
                    s.dmgBoostDuration = _loc10_.duration * 1000;
                    s.dmgBoostCost = 0.01 * Number(_loc10_.boostCost);
                    s.dmgBoostBonus = 0.01 * Number(_loc10_.boost);
                    s.totalTicksOfBoost = s.boostDuration / 33;
                    s.ticksOfBoost = 0;
                }
            }
            _loc7_++;
        }
        s.weaponHeat.setBonuses(s.maxPower, s.powerRegBonus);
        var _loc4_:int = -1;
        var _loc11_:String = "";
        _loc4_ = _loc3_.activeEliteTechLevel;
        _loc11_ = _loc3_.activeEliteTech;
        EliteTechs.addEliteTechs(s, _loc5_, _loc4_, _loc11_);
    }

    private static function addLevelBonusToShip(g:Game, level:Number, s:PlayerShip):void {
        if (g.solarSystem.isPvpSystemInEditor) {
            level = 100;
        }
        var _loc5_:Number = s.player.troons;
        var _loc4_:Number = _loc5_ / 200000;
        level += _loc4_;
        s.hpBase = s.hpBase * (100 + 8 * (level - 1)) / 100;
        s.hpMax = s.hpBase;
        s.hp = s.hpMax;
        s.armorThresholdBase = s.armorThresholdBase * (100 + 2.5 * 8 * (level - 1)) / 100;
        s.shieldHpBase = s.shieldHpBase * (100 + 8 * (level - 1)) / 100;
        s.armorThreshold = s.armorThresholdBase;
        s.shieldHpMax = s.shieldHpBase;
        s.shieldHp = s.shieldHpMax;
        s.shieldRegenBase = s.shieldRegenBase * (100 + 1 * (level - 1)) / 100;
        s.shieldRegen = s.shieldRegenBase;
    }

    private static function addLevelBonusToWeapon(g:Game, level:Number, w:Weapon, p:Player):void {
        if (g.solarSystem.isPvpSystemInEditor) {
            level = 100;
        }
        var _loc6_:Number = p.troons;
        var _loc5_:Number = _loc6_ / 200000;
        level += _loc5_;
        w.dmg.addLevelBonus(level, 8);
        if (w.debuffValue != null) {
            w.debuffValue.addLevelBonus(level, 8);
            w.debuffValue2.addLevelBonus(level, 8);
        }
    }

    private static function CreateEnemyShipWeapon(g:Game, i:int, weapons:Array, ship:EnemyShip):void {
        var _loc7_:Weapon = null;
        if (weapons.length == 0) {
            return;
        }
        var _loc6_:Object = weapons[i];
        var _loc5_:Weapon = WeaponFactory.create(_loc6_.weapon, g, ship, 0);
        ship.weaponRanges.push(new WeaponRange(_loc6_.minRange, _loc6_.maxRange));
        if (i < ship.weapons.length) {
            _loc7_ = ship.weapons[i];
            ship.weapons[i] = _loc5_;
            _loc7_.destroy();
        } else {
            ship.weapons.push(_loc5_);
        }
        if (i != weapons.length - 1) {
            i += 1;
            CreateEnemyShipWeapon(g, i, weapons, ship);
        }
    }

    private static function CreateEnemyShipExtraWeapon(g:Game, i:int, weaponObj:Object, ship:EnemyShip, type:int):void {
        var _loc7_:Weapon = null;
        if (weaponObj == null) {
            return;
        }
        var _loc6_:Weapon = WeaponFactory.create(weaponObj.weapon, g, ship, 0);
        ship.weaponRanges.push(new WeaponRange(0, 0));
        if (type == 0) {
            ship.escapeWeapon = _loc6_;
        } else {
            ship.antiProjectileWeapon = _loc6_;
        }
        if (i < ship.weapons.length) {
            _loc7_ = ship.weapons[i];
            ship.weapons[i] = _loc6_;
            _loc7_.destroy();
        } else {
            ship.weapons.push(_loc6_);
        }
    }

    public function ShipFactory() {
        super();
    }
}
}

