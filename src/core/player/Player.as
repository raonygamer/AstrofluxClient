package core.player {
import com.greensock.TweenMax;

import core.artifact.Artifact;
import core.artifact.ArtifactFactory;
import core.friend.Friend;
import core.group.Group;
import core.hud.components.chat.MessageLog;
import core.particle.Emitter;
import core.particle.EmitterFactory;
import core.scene.Game;
import core.scene.SceneBase;
import core.ship.PlayerShip;
import core.ship.ShipFactory;
import core.solarSystem.Body;
import core.states.StateMachine;
import core.states.gameStates.RoamingState;
import core.states.player.Killed;
import core.states.player.Landed;
import core.states.player.Roaming;
import core.text.TextParticle;
import core.weapon.Beam;
import core.weapon.Cloak;
import core.weapon.Damage;
import core.weapon.PetSpawner;
import core.weapon.Teleport;
import core.weapon.Weapon;
import core.weapon.WeaponDataHolder;

import data.DataLocator;
import data.IDataManager;

import debug.Console;

import facebook.Action;

import movement.Heading;

import playerio.Message;

import sound.ISound;
import sound.SoundLocator;

import starling.core.Starling;
import starling.display.Image;
import starling.utils.MathUtil;

public class Player {
    public static const SLOT_WEAPON_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
    public static const SLOT_ARTIFACT_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
    public static const SLOT_CREW_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
    public static const SLOT_WEAPON:String = "slotWeapon";
    public static const SLOT_ARTIFACT:String = "slotArtifact";
    public static const SLOT_CREW:String = "slotCrew";
    public static const RESPAWN_TIME:Number = 10000;
    public static const RESPAWN_TIME_PVP:Number = 3000;
    public static const SUPPORTER_ICON_ASCII:String = "<font color=\'#ffff66\'>&#9733;</font>";

    public static const EXPBOOSTBONUS_MISSION:Number = 0.3;
    public static const SLOT_WEAPON_UNLOCK_COST:Array = [0, 0, 200, 1000, 5000];
    public static const SLOT_ARTIFACT_UNLOCK_COST:Array = [0, 1000, 2000, 10000, 25000];
    public static const SLOT_CREW_UNLOCK_COST:Array = [0, 0, 250, 5000, 25000];
    public static const ARTIFACT_CAPACITY:Array = [250, 400, 10 * 60, 800];
    public static var friends:Vector.<Friend>;
    public static var onlineFriends:Vector.<Friend>;

    public static function getSkinTechLevel(tech:String, skinKey:String):int {
        var _loc5_:IDataManager = DataLocator.getService();
        var _loc3_:Object = _loc5_.loadKey("Skins", skinKey);
        for each(var _loc4_ in _loc3_.upgrades) {
            if (_loc4_.tech == tech) {
                return _loc4_.level;
            }
        }
        return 0;
    }

    public function Player(g:Game, id:String) {
        super();
        this.g = g;
        this.id = id;
        disableLeave = false;
    }
    public var isMe:Boolean = false;
    public var id:String;
    public var inviter_id:String = "";
    public var ship:PlayerShip;
    public var mirror:PlayerShip;
    public var stateMachine:StateMachine = new StateMachine();
    public var currentBody:Body;
    public var lastBody:Body;
    public var xp:int = 0;
    public var reputation:int = 0;
    public var split:String = "";
    public var respawnNextReady:Number = 0;
    public var spree:int = 0;
    public var techPoints:int = 0;
    public var clanId:String = "";
    public var clanApplicationId:String = "";
    public var troons:int = 0;
    public var rating:int = 0;
    public var ranking:int = 0;
    public var techSkills:Vector.<TechSkill> = new Vector.<TechSkill>();
    public var weapons:Array = [];
    public var weaponsState:Array = [];
    public var weaponsHotkeys:Array = [];
    public var weaponData:Vector.<WeaponDataHolder>;
    public var selectedWeaponIndex:int = 0;
    public var unlockedWeaponSlots:int;
    public var artifactCount:int = 0;
    public var compressorLevel:int = 0;
    public var artifactCapacityLevel:int = 0;
    public var artifactAutoRecycleLevel:int = 0;
    public var activeSkin:String = "";
    public var unlockedArtifactSlots:int;
    public var artifacts:Vector.<Artifact> = new Vector.<Artifact>();
    public var activeArtifactSetup:int;
    public var artifactSetups:Array = [];
    public var unlockedCrewSlots:int;
    public var rotationSpeedMod:Number = 1;
    public var KOTSIsReady:Boolean = false;
    public var fleet:Vector.<FleetObj> = new Vector.<FleetObj>();
    public var nrOfUpgrades:Vector.<int> = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
    public var playerKills:int = 0;
    public var enemyKills:int = 0;
    public var playerDeaths:int = 0;
    public var expBoost:Number = 0;
    public var tractorBeam:Number = 0;
    public var xpProtection:Number = 0;
    public var cargoProtection:Number = 0;
    public var supporter:Number = 0;
    public var beginnerPackage:Boolean = false;
    public var powerPackage:Boolean = false;
    public var megaPackage:Boolean = false;
    public var explores:Vector.<Explore> = new Vector.<Explore>();
    public var missions:Vector.<Mission> = new Vector.<Mission>();
    public var dailyMissions:Array = [];
    public var crewMembers:Vector.<CrewMember> = new Vector.<CrewMember>();
    public var encounters:Vector.<String> = new Vector.<String>();
    public var triggeredMissions:Vector.<String> = new Vector.<String>();
    public var completedMissions:Object = {};
    public var warpPathLicenses:Array;
    public var solarSystemLicenses:Array;
    public var guest:Boolean = false;
    public var fbLike:Boolean = false;
    public var showIntro:Boolean = true;
    public var kongRated:Boolean = false;
    public var isDeveloper:Boolean = false;
    public var isTester:Boolean = false;
    public var isModerator:Boolean = false;
    public var isTranslator:Boolean = false;
    public var pickUpLog:Vector.<TextParticle> = new Vector.<TextParticle>();
    public var disableLeave:Boolean;
    public var clanLogo:Image;
    public var clanName:String;
    public var clanRankName:String;
    public var clanLogoColor:uint;
    public var freeResets:int;
    public var freePaintJobs:int;
    public var factions:Vector.<String> = new Vector.<String>();
    public var landedBodies:Vector.<LandedBody> = new Vector.<LandedBody>();
    public var tosVersion:int;
    public var isLanded:Boolean = false;
    private var activeWeapon:String;
    private var tractorBeamActive:Boolean = true;
    private var cargoProtectionActive:Boolean = true;
    private var isTakingOff:Boolean = false;
    private var g:Game;
    private var updateInterval:int;

    private var _name:String;

    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    private var _team:int = -1;

    public function get team():int {
        return _team;
    }

    public function set team(value:int):void {
        _team = value;
        if (ship != null) {
            ship.team = value;
            ship.updateLabel();
        }
    }

    private var _level:int = 1;

    public function get level():int {
        return _level;
    }

    public function set level(value:int):void {
        _level = value;
        if (ship != null) {
            ship.level = value;
            ship.updateLabel();
        }
    }

    private var _inSafeZone:Boolean = false;

    public function get inSafeZone():Boolean {
        return _inSafeZone;
    }

    public function set inSafeZone(value:Boolean):void {
        _inSafeZone = value;
    }

    private var _isWarpJumping:Boolean = false;

    public function get isWarpJumping():Boolean {
        return _isWarpJumping;
    }

    public function set isWarpJumping(value:Boolean):void {
        _isWarpJumping = value;
    }

    private var _group:Group = null;

    public function get group():Group {
        return _group;
    }

    public function set group(value:Group):void {
        _group = value;
        if (ship != null) {
            ship.group = value;
        }
    }

    private var _isHostile:Boolean = false;

    public function get isHostile():Boolean {
        return _isHostile;
    }

    public function set isHostile(value:Boolean):void {
        _isHostile = value;
        if (ship != null) {
            ship.isHostile = value;
        }
    }

    public function get artifactLimit():int {
        return ARTIFACT_CAPACITY[artifactCapacityLevel];
    }

    public function get activeArtifacts():Array {
        return artifactSetups[activeArtifactSetup] as Array;
    }

    public function get hasCorrectTOSVersion():Boolean {
        if (Login.currentState === "steam") {
            return true;
        }
        return tosVersion == 3;
    }

    public function set hasCorrectTOSVersion(value:Boolean):void {
        if (value) {
            tosVersion = 3;
        } else {
            tosVersion = -1;
        }
    }

    public function get levelXpMax():int {
        if (level >= 100) {
            return int((level + 2) * level * 500 * Math.pow(1.06, level - 99));
        }
        return (level + 2) * level * 500;
    }

    public function get levelXpMin():int {
        if (level >= 100) {
            return int((level + 1) * (level - 1) * 500 * Math.pow(1.06, level - 100));
        }
        if (level == 1) {
            return 0;
        }
        return (level + 1) * (level - 1) * 500;
    }

    public function get hasExpBoost():Boolean {
        if (isModerator) {
            return true;
        }
        return expBoost > g.time;
    }

    public function get invulnarable():Boolean {
        if (_inSafeZone || _isWarpJumping) {
            return true;
        }
        return false;
    }

    public function get commandable():Boolean {
        if (ship == null || !ship.alive || isLanded || isWarpJumping) {
            return false;
        }
        return true;
    }

    public function init(m:Message, i:int):int {
        var _loc14_:Heading = null;
        var _loc7_:int = 0;
        _name = m.getString(i++);
        inviter_id = m.getString(i++);
        tosVersion = m.getInt(i++);
        isDeveloper = m.getBoolean(i++);
        isTester = m.getBoolean(i++);
        isModerator = m.getBoolean(i++);
        isTranslator = m.getBoolean(i++);
        level = m.getInt(i++);
        xp = m.getInt(i++);
        techPoints = m.getInt(i++);
        isHostile = m.getBoolean(i++);
        rotationSpeedMod = m.getNumber(i++);
        reputation = m.getInt(i++);
        var _loc4_:String = m.getString(i++);
        split = m.getString(i++);
        var _loc8_:String = m.getString(i++);
        spree = m.getInt(i++);
        var _loc15_:int = m.getInt(i++);
        var _loc6_:int = 0;
        var _loc9_:int = 0;
        var _loc13_:int = 0;
        var _loc5_:int = 0;
        var _loc10_:Number = 0;
        var _loc11_:Number = 0;
        if (_loc15_ != -1) {
            _loc9_ = m.getInt(i++);
            _loc6_ = m.getInt(i++);
            _loc13_ = m.getInt(i++);
            _loc5_ = m.getInt(i++);
            _loc10_ = m.getNumber(i++);
            _loc11_ = m.getNumber(i++);
            _loc14_ = new Heading();
            i = _loc14_.parseMessage(m, i);
        }
        unlockedWeaponSlots = m.getInt(i++);
        unlockedArtifactSlots = m.getInt(i++);
        unlockedCrewSlots = m.getInt(i++);
        compressorLevel = m.getInt(i++);
        artifactCapacityLevel = m.getInt(i++);
        artifactAutoRecycleLevel = m.getInt(i++);
        playerKills = m.getInt(i++);
        playerDeaths = m.getInt(i++);
        enemyKills = m.getInt(i++);
        showIntro = m.getBoolean(i++);
        expBoost = m.getNumber(i++);
        tractorBeam = m.getNumber(i++);
        xpProtection = m.getNumber(i++);
        cargoProtection = m.getNumber(i++);
        supporter = m.getNumber(i++);
        beginnerPackage = m.getBoolean(i++);
        powerPackage = m.getBoolean(i++);
        megaPackage = m.getBoolean(i++);
        guest = m.getBoolean(i++);
        clanId = m.getString(i++);
        clanApplicationId = m.getString(i++);
        troons = m.getNumber(i++);
        freeResets = m.getInt(i++);
        freePaintJobs = m.getInt(i++);
        artifactCount = m.getInt(i++);
        var _loc12_:int = m.getInt(i++);
        _loc7_ = 0;
        while (_loc7_ < _loc12_) {
            factions.push(m.getString(i++));
            _loc7_++;
        }
        i = initFleetFromMessage(m, i);
        if (isMe) {
            i = initEncountersFromMessage(m, i);
            i = initCompletedMissionsFromMessage(m, i);
            i = initFinishedExploresFromMessage(m, i);
            i = initExploresFromMessage(m, i);
            i = initMissionsFromMessage(m, i);
            i = g.dailyManager.initDailyMissionsFromMessage(m, i);
            i = initTriggeredMissionsFromMessage(m, i);
            i = initCrewFromMessage(m, i);
            i = initLandedBodiesFromMessage(m, i);
            i = initArtifactsFromMessage(m, i);
            i = SceneBase.settings.init(m, i);
            SceneBase.settings.setPlayerValues(g);
            g.parallaxManager.refresh();
            i = g.tutorial.init(m, i);
            i = initWarpPathLicensesFromMessage(m, i);
            i = initSolarSystemLicensesFromMessage(m, i);
            kongRated = m.getBoolean(i++);
            fbLike = m.getBoolean(i++);
            g.friendManager.init(this);
        }
        var _loc3_:Body = g.bodyManager.getBodyByKey(_loc8_);
        if (_loc3_ != null) {
            ship = ShipFactory.createPlayer(g, this, new PlayerShip(g), weapons);
            startLanded(_loc3_);
            isLanded = true;
        } else {
            loadShip(_loc9_, _loc6_, _loc13_, _loc5_);
            ship.id = _loc15_;
            loadCourse(_loc14_);
            enterRoaming();
            MessageLog.writeChatMsg("join_leave", _name + " has entered the system.");
        }
        if (!isMe && _loc6_ != 0) {
            ship.shieldHpMax = _loc9_;
            ship.hpMax = _loc6_;
            ship.armorThreshold = _loc13_;
            ship.shieldRegen = _loc5_;
            ship.level = level;
            ship.updateLabel();
            ship.engine.speed = _loc10_;
            ship.engine.acceleration = _loc11_;
        }
        if (supporter) {
            Game.trackEvent("logged in", "supporter");
        } else {
            Game.trackEvent("logged in", "not supporter");
        }
        g.groupManager.autoJoinOrCreateGroup(this, _loc4_);
        return i;
    }

    public function requestLikeReward():void {
        if (Login.hasFacebookLiked && !fbLike) {
            g.send("fbLike");
        }
    }

    public function requestInviteReward():void {
        g.send("requestInviteReward");
    }

    public function requestRewardsOnLogin():void {
        g.rpc("requestRewardsOnLogin", requestResult);
    }

    public function sendKongRated():void {
        kongRated = true;
        g.send("kongRated");
    }

    public function requestResult():void {
    }

    public function getExploreByKey(key:String):Explore {
        for each(var _loc2_ in explores) {
            if (_loc2_.areaKey == key) {
                return _loc2_;
            }
        }
        return null;
    }

    public function loadShip(shieldHp:int, hp:int, armor:int, shieldRegen:int):void {
        var _loc5_:int = 0;
        ship = null;
        ship = ShipFactory.createPlayer(g, this, g.shipManager.getPlayerShip(), weapons);
        _loc5_ = 0;
        while (_loc5_ < ship.weapons.length) {
            if (ship.weapons[_loc5_].key == activeWeapon) {
                selectedWeaponIndex = _loc5_;
                if (isMe) {
                    g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_loc5_].hotkey);
                }
                break;
            }
            _loc5_++;
        }
        activateShip();
        if (hp != 0) {
            ship.shieldHp = shieldHp;
            ship.hp = hp;
            ship.armorThreshold = armor;
            ship.shieldRegen = shieldRegen;
            ship.level = level;
            ship.updateLabel();
        }
        if (spree > 4 && ship != null) {
            ship.startKillingSpreeEffect();
        }
    }

    public function unloadShip():void {
        if (ship == null) {
            return;
        }
        ship.destroy(false);
        if (mirror != null) {
            mirror.destroy(false);
            mirror = null;
        }
    }

    public function update():void {
        if (isMe) {
            updateInterval++;
            if (updateInterval == 1) {
                g.hud.bossHealth.update();
            } else if (updateInterval == 2) {
                g.hud.powerBar.update();
                updateInterval = 0;
            }
        }
        stateMachine.update();
    }

    public function setSpree(newSpree:int):void {
        if (spree != newSpree) {
            spree = newSpree;
            if (spree > 15) {
                MessageLog.writeChatMsg("death", _name + " is Godlike! With a " + spree + " frag long killing frenzy!");
            } else if (spree > 10) {
                MessageLog.writeChatMsg("death", _name + " is on a Rampage! " + spree + " frag long killing frenzy!");
            } else if (spree > 4) {
                MessageLog.writeChatMsg("death", _name + " is on a " + spree + " frag long killing frenzy!");
            }
            if (spree == 4 && ship != null) {
                ship.startKillingSpreeEffect();
            }
        }
    }

    public function getExploredAreas(body:Body, callback:Function):void {
        if (body.obj.exploreAreas == null) {
            callback([]);
            return;
        }
        try {
            g.client.bigDB.loadRange("Explores", "ByPlayerAndBodyAndArea", [id, body.key], null, null, 100, function (param1:Array):void {
                callback(param1);
            });
        } catch (e:Error) {
            g.client.errorLog.writeError(e.toString(), "Something went wrong when loading explores: pid: " + id + " bid:" + body.key, e.getStackTrace(), {});
        }
    }

    public function levelUp():void {
        var effect:Vector.<Emitter>;
        var effect2:Vector.<Emitter>;
        var soundManager:ISound;
        level += 1;
        if (ship == null) {
            return;
        }
        if (level >= 10 && Login.currentState == "facebook") {
            g.tutorial.showFacebookInviteHint();
        }
        setLevelBonusStats();
        if (g.camera.isCircleOnScreen(ship.x, ship.y, 5 * 60)) {
            effect = EmitterFactory.create("wrycG8hPkEGYgMkWXyd6FQ", g, 0, 0, ship, false);
            effect2 = EmitterFactory.create("6SRymw3GLkqIn6YvIGoLrw", g, 0, 0, ship, false);
            if (isMe) {
                if (g.me.split != "") {
                    Game.trackEvent("AB Splits", "player flow", g.me.split + ": reached level " + level);
                }
                soundManager = SoundLocator.getService();
                soundManager.preCacheSound("5wAlzsUCPEKqX7tAdCw3UA", function ():void {
                    for each(var _loc1_ in effect) {
                        _loc1_.play();
                    }
                    for each(var _loc2_ in effect2) {
                        _loc2_.play();
                    }
                    g.textManager.createLevelUpText(level);
                    g.textManager.createLevelUpDetailsText();
                });
                g.updateServiceRoom();
                Action.levelUp(level);
                if (inviter_id != "" && level == 10) {
                    if (level == 10 || level == 2) {
                        g.sendToServiceRoom("requestUpdateInviteReward", inviter_id);
                    }
                    if (level % 10 == 0) {
                        if (Login.currentState == "facebook") {
                            Game.trackEvent("FBinvite", "invite feedback", "reached level " + level, 1);
                        } else if (Login.currentState == "kongregate") {
                            Game.trackEvent("KONGinvite", "invite feedback", "joined game", 1);
                        }
                    }
                }
            } else {
                MessageLog.write("<FONT COLOR=\'#44ff44\'>" + name + " reached level " + level + ".</FONT>");
            }
        }
    }

    public function increaseXp(xpGain:int, newXp:int):void {
        xp = newXp;
        while (xp > levelXpMax) {
            levelUp();
        }
        if (isMe) {
            g.textManager.createXpText(xpGain);
        }
    }

    public function decreaseXp(xpLoss:int, newXp:int):void {
        xp = newXp;
        if (isMe) {
            g.textManager.createXpText(-xpLoss);
        }
    }

    public function updateReputation(mod:int, rep:int):void {
        reputation = rep;
        Login.submitKongregateStat("Reputation", mod);
        if (ship == null) {
            return;
        }
        if (mod != 0) {
            g.textManager.createReputationText(mod, ship);
        }
    }

    public function loadCourse(heading:Heading):void {
        if (ship != null) {
            ship.course = heading;
        }
    }

    public function initRoaming(m:Message, i:int, changeGameState:Boolean = true):int {
        if (stateMachine.inState(RoamingState)) {
            return i;
        }
        unloadShip();
        level = m.getInt(i++);
        xp = m.getInt(i++);
        techPoints = m.getInt(i++);
        isHostile = m.getBoolean(i++);
        var _loc5_:String = m.getString(i++);
        var _loc12_:int = m.getInt(i++);
        var _loc9_:int = m.getInt(i++);
        var _loc7_:int = m.getInt(i++);
        var _loc4_:int = m.getInt(i++);
        var _loc6_:int = m.getInt(i++);
        var _loc11_:Number = m.getNumber(i++);
        var _loc10_:Number = m.getNumber(i++);
        var _loc8_:Heading = new Heading();
        i = _loc8_.parseMessage(m, i);
        playerKills = m.getInt(i++);
        playerDeaths = m.getInt(i++);
        enemyKills = m.getInt(i++);
        showIntro = m.getBoolean(i++);
        clanId = m.getString(i++);
        clanApplicationId = m.getString(i++);
        troons = m.getNumber(i++);
        i = initFleetFromMessage(m, i);
        loadShip(_loc9_, _loc7_, _loc4_, _loc6_);
        ship.id = _loc12_;
        loadCourse(_loc8_);
        if (isMe) {
            applyArtifactStats();
            ship.shieldHp = _loc9_;
            ship.hp = _loc7_;
            g.hud.weaponHotkeys.refresh();
            g.hud.abilities.refresh();
            g.hud.healthAndShield.update();
            g.hud.powerBar.update();
            if (changeGameState) {
                g.fadeIntoState(new RoamingState(g));
            }
        } else {
            ship.engine.speed = _loc11_;
            ship.engine.acceleration = _loc10_;
        }
        enterRoaming();
        g.groupManager.autoJoinOrCreateGroup(this, _loc5_);
        return i;
    }

    public function enterRoaming():void {
        isLanded = false;
        isTakingOff = false;
        if (!stateMachine.inState(Roaming)) {
            stateMachine.changeState(new Roaming(this, g));
        }
    }

    public function startLanded(b:Body):void {
        if (stateMachine.inState(Landed)) {
            return;
        }
        stateMachine.changeState(new Landed(this, b, g));
    }

    public function land(body:Body):void {
        var that:Player;
        var toRot:Number;
        if (stateMachine.inState(Landed)) {
            return;
        }
        isLanded = true;
        that = this;
        toRot = 0;
        if (ship.rotation > 3.1) {
            toRot = 6.2;
        }
        ship.engine.stop();
        if (!isMe) {
            TweenMax.to(ship, 1.2, {
                "x": body.x,
                "y": body.y,
                "scaleX": 0.5,
                "scaleY": 0.5,
                "rotation": toRot,
                "onComplete": function ():void {
                    stateMachine.changeState(new Landed(that, body, g));
                    ship.removeFromCanvas();
                    ship.land();
                }
            });
            return;
        }
        g.camera.zoomFocus(3, 25);
        TweenMax.to(ship, 1.2, {
            "x": body.x,
            "y": body.y,
            "scaleX": 0.5,
            "scaleY": 0.5,
            "rotation": toRot,
            "onComplete": function ():void {
                stateMachine.changeState(new Landed(g.me, body, g));
                g.enterLandedState();
                ship.land();
                TweenMax.delayedCall(0.5, function ():void {
                    g.camera.zoomFocus(1, 1);
                });
            }
        });
    }

    public function enterKilled(m:Message):void {
        if (g.solarSystem.isPvpSystemInEditor) {
            respawnNextReady = g.time + 50 * 60;
        } else {
            respawnNextReady = g.time + 10000;
        }
        stateMachine.changeState(new Killed(this, g, m));
    }

    public function hasExploredArea(areaKey:String):Boolean {
        for each(var _loc2_ in explores) {
            if (areaKey == _loc2_.areaKey && _loc2_.finished && _loc2_.lootClaimed) {
                return true;
            }
        }
        return false;
    }

    public function leaveBody():void {
        if (!isTakingOff) {
            Console.write("Leaving body");
            isTakingOff = true;
            g.send("leaveBody");
        }
    }

    public function initMissionsFromMessage(m:Message, startIndex:int):int {
        Console.write("Init missions");
        missions = new Vector.<Mission>();
        var _loc3_:int = m.getInt(startIndex);
        var _loc4_:int = startIndex + 1;
        while (_loc3_ > 0) {
            _loc4_ = addMission(m, _loc4_);
            _loc3_--;
        }
        return _loc4_;
    }

    public function addMission(m:Message, i:int):int {
        var _loc3_:Mission = new Mission();
        _loc3_.id = m.getString(i++);
        _loc3_.missionTypeKey = m.getString(i++);
        _loc3_.type = m.getString(i++);
        _loc3_.majorType = m.getString(i++);
        _loc3_.count = m.getInt(i++);
        _loc3_.viewed = m.getBoolean(i++);
        _loc3_.finished = m.getBoolean(i++);
        _loc3_.claimed = m.getBoolean(i++);
        _loc3_.created = m.getNumber(i++);
        _loc3_.expires = m.getNumber(i++);
        missions.push(_loc3_);
        return i;
    }

    public function hasMission(id:String):Boolean {
        for each(var _loc2_ in missions) {
            if (_loc2_.id == id) {
                return true;
            }
        }
        return false;
    }

    public function removeMission(m:Mission):void {
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < missions.length) {
            if (missions[_loc2_].missionTypeKey == m.missionTypeKey) {
                missions.splice(_loc2_, 1);
                return;
            }
            _loc2_++;
        }
    }

    public function initFinishedExploresFromMessage(m:Message, startIndex:int):int {
        var _loc3_:String = null;
        var _loc5_:int = 0;
        var _loc4_:Explore = null;
        explores = new Vector.<Explore>();
        var _loc6_:int = m.getInt(startIndex);
        var _loc7_:int = startIndex + 1;
        var _loc8_:Object = g.dataManager.loadTable("BodyAreas");
        while (_loc6_ > 0) {
            _loc3_ = m.getString(_loc7_++);
            _loc5_ = int(_loc8_[_loc3_] != null ? _loc8_[_loc3_].size : 0);
            _loc5_ = _loc5_ + 4;
            _loc4_ = new Explore();
            _loc4_.key = "";
            _loc4_.areaKey = _loc3_;
            _loc4_.bodyKey = "";
            _loc4_.failed = false;
            _loc4_.failTime = 0;
            _loc4_.finished = true;
            _loc4_.finishTime = 0;
            _loc4_.lootClaimed = true;
            _loc4_.playerKey = id;
            _loc4_.startEvent = 0;
            _loc4_.startTime = 0;
            _loc4_.successfulEvents = _loc5_;
            explores.push(_loc4_);
            _loc6_--;
        }
        return _loc7_;
    }

    public function initExploresFromMessage(m:Message, startIndex:int):int {
        var _loc3_:Explore = null;
        var _loc4_:int = m.getInt(startIndex);
        var _loc5_:int = startIndex + 1;
        while (_loc4_ > 0) {
            _loc3_ = new Explore();
            _loc3_.key = m.getString(_loc5_++);
            _loc3_.areaKey = m.getString(_loc5_++);
            _loc3_.bodyKey = m.getString(_loc5_++);
            _loc3_.failed = m.getBoolean(_loc5_++);
            _loc3_.failTime = m.getNumber(_loc5_++);
            _loc3_.finished = m.getBoolean(_loc5_++);
            _loc3_.finishTime = m.getNumber(_loc5_++);
            _loc3_.lootClaimed = m.getBoolean(_loc5_++);
            _loc3_.playerKey = m.getString(_loc5_++);
            _loc3_.startEvent = m.getInt(_loc5_++);
            _loc3_.startTime = m.getNumber(_loc5_++);
            _loc3_.successfulEvents = m.getInt(_loc5_++);
            explores.push(_loc3_);
            _loc4_--;
        }
        return _loc5_;
    }

    public function initLandedBodiesFromMessage(m:Message, startIndex:int):int {
        var _loc3_:int = 0;
        landedBodies = new Vector.<LandedBody>();
        var _loc4_:int = m.getInt(startIndex);
        _loc3_ = startIndex + 1;
        while (_loc3_ < startIndex + _loc4_ * 2 + 1) {
            landedBodies.push(new LandedBody(m.getString(_loc3_), m.getBoolean(_loc3_ + 1)));
            _loc3_ += 2;
        }
        return _loc3_;
    }

    public function initEncountersFromMessage(m:Message, startIndex:int):int {
        var _loc4_:int = 0;
        encounters = new Vector.<String>();
        var _loc3_:int = m.getInt(startIndex);
        _loc4_ = startIndex + 1;
        while (_loc4_ < startIndex + _loc3_ + 1) {
            encounters.push(m.getString(_loc4_));
            _loc4_++;
        }
        return _loc4_;
    }

    public function initCompletedMissionsFromMessage(m:Message, startIndex:int):int {
        var _loc4_:int = 0;
        completedMissions = {};
        var _loc3_:int = m.getInt(startIndex);
        _loc4_ = startIndex + 1;
        while (_loc4_ < startIndex + _loc3_ * 2 + 1) {
            completedMissions[m.getString(_loc4_)] = m.getNumber(_loc4_ + 1);
            _loc4_ += 2;
        }
        return _loc4_;
    }

    public function initTriggeredMissionsFromMessage(m:Message, startIndex:int):int {
        var _loc4_:int = 0;
        triggeredMissions = new Vector.<String>();
        var _loc3_:int = m.getInt(startIndex);
        _loc4_ = startIndex + 1;
        while (_loc4_ < startIndex + _loc3_ + 1) {
            triggeredMissions.push(m.getString(_loc4_));
            _loc4_++;
        }
        return _loc4_;
    }

    public function initCrewFromMessage(m:Message, startIndex:int):int {
        var _loc7_:int = 0;
        var _loc5_:CrewMember = null;
        var _loc3_:Array = null;
        var _loc4_:Array = null;
        crewMembers = new Vector.<CrewMember>();
        var _loc6_:int = m.getInt(startIndex);
        _loc7_ = startIndex + 1;
        while (_loc7_ < startIndex + _loc6_ * 30 + 1) {
            _loc5_ = new CrewMember(g);
            _loc5_.seed = m.getInt(_loc7_++);
            _loc5_.key = m.getString(_loc7_++);
            _loc5_.name = m.getString(_loc7_++);
            _loc5_.solarSystem = m.getString(_loc7_++);
            _loc5_.area = m.getString(_loc7_++);
            _loc5_.body = m.getString(_loc7_++);
            _loc5_.imageKey = m.getString(_loc7_++);
            _loc5_.injuryEnd = m.getNumber(_loc7_++);
            _loc5_.injuryStart = m.getNumber(_loc7_++);
            _loc5_.trainingEnd = m.getNumber(_loc7_++);
            _loc5_.trainingType = m.getInt(_loc7_++);
            _loc5_.artifactEnd = m.getNumber(_loc7_++);
            _loc5_.artifact = m.getString(_loc7_++);
            _loc5_.missions = m.getInt(_loc7_++);
            _loc5_.successMissions = m.getInt(_loc7_++);
            _loc5_.rank = m.getInt(_loc7_++);
            _loc5_.fullLocation = m.getString(_loc7_++);
            _loc5_.skillPoints = m.getInt(_loc7_++);
            _loc3_ = [];
            _loc3_.push(m.getNumber(_loc7_++));
            _loc3_.push(m.getNumber(_loc7_++));
            _loc3_.push(m.getNumber(_loc7_++));
            _loc5_.skills = _loc3_;
            _loc4_ = [];
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc4_.push(m.getNumber(_loc7_++));
            _loc5_.specials = _loc4_;
            crewMembers.push(_loc5_);
            _loc7_ += 0;
        }
        return _loc7_;
    }

    public function initFleetFromMessage(m:Message, startIndex:int):int {
        var _loc5_:int = 0;
        var _loc6_:FleetObj = null;
        fleet.length = 0;
        activeSkin = m.getString(startIndex++);
        var _loc4_:int = m.getInt(startIndex++);
        var _loc3_:* = startIndex;
        _loc5_ = 0;
        while (_loc5_ < _loc4_) {
            _loc6_ = new FleetObj();
            _loc3_ = _loc6_.initFromMessage(m, _loc3_);
            if (_loc6_.skin == activeSkin) {
                techSkills = _loc6_.techSkills;
                weapons = _loc6_.weapons;
                weaponsState = _loc6_.weaponsState;
                weaponsHotkeys = _loc6_.weaponsHotkeys;
                nrOfUpgrades = _loc6_.nrOfUpgrades;
                activeArtifactSetup = _loc6_.activeArtifactSetup;
                activeWeapon = _loc6_.activeWeapon;
            }
            fleet.push(_loc6_);
            _loc5_++;
        }
        return _loc3_;
    }

    public function addNewSkin(skinKey:String):void {
        if (hasSkin(skinKey)) {
            return;
        }
        var _loc2_:FleetObj = new FleetObj();
        _loc2_.initFromSkin(skinKey);
        fleet.push(_loc2_);
    }

    public function changeArtifactSetup(index:int):void {
        var _loc4_:* = null;
        var _loc2_:Artifact = null;
        var _loc3_:int = 0;
        var _loc5_:FleetObj = null;
        for each(_loc4_ in activeArtifacts) {
            _loc2_ = getArtifactById(_loc4_);
            if (_loc2_ != null) {
                removeArtifactStat(_loc2_, false);
            }
        }
        activeArtifactSetup = index;
        _loc3_ = 0;
        while (_loc3_ < fleet.length) {
            _loc5_ = fleet[_loc3_];
            if (_loc5_.skin == activeSkin) {
                _loc5_.activeArtifactSetup = index;
                break;
            }
            _loc3_++;
        }
        for each(_loc4_ in activeArtifacts) {
            _loc2_ = getArtifactById(_loc4_);
            if (_loc2_ != null) {
                addArtifactStat(_loc2_, false);
            }
        }
    }

    public function addWeapon(item:String):void {
        weapons.push({"weapon": item});
        addTechSkill(name, "Weapons", item);
        refreshWeapons();
    }

    public function pickupArtifacts(m:Message):void {
        g.hud.artifactsButton.hintNew();
        loadArtifactsFromMessage(m, 0, true);
        artifactCount += m.getInt(0);
        if (artifactCount >= artifactLimit) {
            g.hud.showArtifactLimitText();
        }
    }

    public function pickupArtifact(m:Message):void {
        g.hud.artifactsButton.hintNew();
        loadArtifactsFromMessage(m, 0, true);
        artifactCount += 1;
        if (artifactCount >= artifactLimit) {
            g.hud.showArtifactLimitText();
        }
    }

    public function checkPickupMessage(m:Message, i:int):void {
        var _loc11_:String = null;
        var _loc13_:String = null;
        var _loc3_:String = null;
        var _loc4_:int = 0;
        var _loc10_:Boolean = false;
        var _loc9_:Boolean = false;
        if (!isMe) {
            return;
        }
        var _loc5_:Boolean = m.getBoolean(i);
        var _loc7_:Boolean = m.getBoolean(i + 1);
        var _loc12_:Boolean = m.getBoolean(i + 2);
        i += 3;
        if (_loc7_) {
            g.hud.artifactsButton.hintNew();
            i = loadArtifactsFromMessage(m, i, true);
            artifactCount += 1;
            if (artifactCount >= artifactLimit) {
                g.hud.showArtifactLimitText();
            }
        }
        if (_loc5_) {
            MessageLog.writeChatMsg("loot", "<FONT COLOR=\'#4488ff\'>You found a Crate</FONT>");
        }
        if (_loc12_) {
            MessageLog.writeChatMsg("loot", "<FONT COLOR=\'#ffcc44\'>Auto recycled artifact</FONT>");
        }
        var _loc8_:int = m.getInt(i++);
        var _loc6_:int = i + _loc8_ * 6;
        i;
        while (i < _loc6_) {
            _loc11_ = m.getString(i);
            _loc13_ = m.getString(i + 1);
            _loc3_ = m.getString(i + 2);
            _loc4_ = m.getInt(i + 3);
            _loc10_ = m.getBoolean(i + 4);
            _loc9_ = m.getBoolean(i + 5);
            if (_loc13_ == "Weapons") {
                MessageLog.writeChatMsg("loot", "<FONT COLOR=\'#ff3322\'>You found a new weapon: " + _loc11_ + "</FONT>");
                g.textManager.createDropText("You found the " + _loc11_ + "!", 1, 20, 5000, 0xff3322);
            } else if (_loc5_) {
                g.textManager.createDropText(_loc11_, _loc4_, 20, 5000, 0xffff88);
                MessageLog.writeChatMsg("loot", _loc11_ + " x" + _loc4_);
                g.myCargo.addItem(_loc13_, _loc3_, _loc4_);
            } else if (_loc12_) {
                g.textManager.createDropText(_loc11_, _loc4_, 14, 5000, 0xffcc44);
                g.myCargo.addItem(_loc13_, _loc3_, _loc4_);
            } else {
                g.textManager.createDropText(_loc11_, _loc4_);
                g.myCargo.addItem(_loc13_, _loc3_, _loc4_);
            }
            g.hud.cargoButton.update();
            g.hud.resourceBox.update();
            g.hud.cargoButton.flash();
            if (_loc13_ == "Weapons") {
                removeAllArtifactStats();
            }
            if (_loc10_) {
                weapons.push({"weapon": _loc3_});
                refreshWeapons();
            }
            if (_loc9_) {
                addTechSkill(_loc11_, _loc13_, _loc3_);
            }
            if (_loc13_ == "Weapons") {
                addAllArtifactStats();
                if (ship != null) {
                    ship.hp = ship.hpMax;
                    ship.shieldHp = ship.shieldHpMax;
                }
            }
            i += 6;
        }
    }

    public function addTechSkill(name:String, table:String, item:String):void {
        techSkills.push(new TechSkill(name, item, table, 0));
    }

    public function nrOfActiveArtifacts():int {
        return activeArtifacts.length;
    }

    public function getArtifactById(artifactId:String):Artifact {
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < artifacts.length) {
            if (artifacts[_loc2_].id === artifactId) {
                return artifacts[_loc2_];
            }
            _loc2_++;
        }
        return null;
    }

    public function isActiveArtifact(a:Artifact):Boolean {
        return activeArtifacts.indexOf(a.id) != -1;
    }

    public function isArtifactInSetup(a:Artifact):Boolean {
        for each(var _loc2_ in artifactSetups) {
            if (_loc2_.indexOf(a.id) != -1) {
                return true;
            }
        }
        return false;
    }

    public function addArtifactStat(a:Artifact, notifyServer:Boolean = true):void {
        addRemoveArtifactStat(a, true, notifyServer);
    }

    public function removeArtifactStat(a:Artifact, notifyServer:Boolean = true):void {
        addRemoveArtifactStat(a, false, notifyServer);
    }

    public function removeAllArtifactStats():void {
        var _loc1_:Artifact = null;
        for each(var _loc2_ in activeArtifacts) {
            _loc1_ = getArtifactById(_loc2_);
            if (_loc1_ != null) {
                removeArtifactStat(_loc1_, false);
            }
        }
    }

    public function addAllArtifactStats():void {
        var _loc1_:Artifact = null;
        for each(var _loc2_ in activeArtifacts) {
            _loc1_ = getArtifactById(_loc2_);
            if (_loc1_ != null) {
                addArtifactStat(_loc1_, false);
            }
        }
    }

    public function toggleArtifact(a:Artifact, notifyServer:Boolean = true):void {
        var _loc3_:int = int(activeArtifacts.indexOf(a.id));
        if (_loc3_ != -1) {
            activeArtifacts.splice(_loc3_, 1);
            removeArtifactStat(a, notifyServer);
        } else {
            activeArtifacts.push(a.id);
            addArtifactStat(a, notifyServer);
        }
    }

    public function hasTechSkill(table:String, tech:String):Boolean {
        for each(var _loc3_ in techSkills) {
            if (_loc3_.table == table && _loc3_.tech == tech) {
                return true;
            }
        }
        return false;
    }

    public function changeWeapon(m:Message, i:int):void {
        var _loc6_:int = 0;
        var _loc7_:FleetObj = null;
        var _loc4_:Weapon = null;
        var _loc5_:int = m.getInt(i + 1);
        var _loc3_:String = m.getString(i + 2);
        if (_loc3_ != null && _loc3_ != "") {
            activeWeapon = _loc3_;
            _loc6_ = 0;
            while (_loc6_ < fleet.length) {
                _loc7_ = fleet[_loc6_];
                if (_loc7_.skin == activeSkin) {
                    _loc7_.activeWeapon = _loc3_;
                    break;
                }
                _loc6_++;
            }
        }
        if (ship == null) {
            return;
        }
        selectedWeaponIndex = _loc5_;
        ship.weaponIsChanging = false;
        for each(var _loc8_ in weapons) {
            if (_loc8_ is Weapon) {
                _loc4_ = _loc8_ as Weapon;
                _loc4_.fire = false;
            }
        }
        if (isMe) {
            g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_loc5_].hotkey);
        }
    }

    public function sendChangeWeapon(weaponUsedHotkey:int):void {
        var _loc3_:int = 0;
        if (weaponUsedHotkey != 0 && ship != null) {
            _loc3_ = 0;
            while (_loc3_ < ship.weapons.length) {
                if (ship.weapons[_loc3_].active && ship.weapons[_loc3_].hotkey == weaponUsedHotkey) {
                    ship.weaponIsChanging = true;
                    for each(var _loc2_ in ship.weapons) {
                        _loc2_.fire = false;
                    }
                    selectedWeaponIndex = _loc3_;
                    g.send("changeWeapon", _loc3_);
                    return;
                }
                _loc3_++;
            }
        }
    }

    public function tryUnlockSlot(type:String, index:int, callback:Function):void {
        if (type == "slotCrew" && index + 1 < 4) {
            return;
        }
        g.rpc("tryUnlockSlot", function (param1:Message):void {
            var _loc5_:String = param1.getString(0);
            var _loc4_:int = param1.getInt(1);
            var _loc3_:int = 0;
            var _loc2_:String = "";
            if (_loc5_ == "slotWeapon") {
                _loc3_ = int(SLOT_WEAPON_UNLOCK_COST[_loc4_ - 1]);
                _loc2_ = "flpbTKautkC1QzjWT28gkw";
                unlockedWeaponSlots = _loc4_;
                if (ship != null) {
                    ship.unlockedWeaponSlots = _loc4_;
                }
            } else if (_loc5_ == "slotArtifact") {
                _loc3_ = int(SLOT_ARTIFACT_UNLOCK_COST[_loc4_ - 1]);
                _loc2_ = "flpbTKautkC1QzjWT28gkw";
                unlockedArtifactSlots = _loc4_;
            } else if (_loc5_ == "slotCrew") {
                _loc3_ = int(SLOT_CREW_UNLOCK_COST[_loc4_ - 1]);
                _loc2_ = "flpbTKautkC1QzjWT28gkw";
                unlockedCrewSlots = _loc4_;
            }
            g.myCargo.removeMinerals(_loc2_, _loc3_);
            callback();
        }, type, index);
    }

    public function saveWeaponData(weapList:Vector.<Weapon>):void {
        var _loc2_:WeaponDataHolder = null;
        var _loc4_:String = "";
        weaponData = new Vector.<WeaponDataHolder>();
        for each(var _loc3_ in weapList) {
            _loc4_ = _loc3_.getDescription(_loc3_ is Beam);
            _loc2_ = new WeaponDataHolder(_loc3_.key, _loc4_);
            weaponData.push(_loc2_);
        }
    }

    public function getWeaponByHotkey(i:int):Weapon {
        if (ship == null) {
            return null;
        }
        for each(var _loc2_ in ship.weapons) {
            if (_loc2_.active && _loc2_.hotkey == i) {
                return _loc2_;
            }
        }
        return null;
    }

    public function getCrewMember(key:String):CrewMember {
        for each(var _loc2_ in crewMembers) {
            if (_loc2_.key == key) {
                return _loc2_;
            }
        }
        return null;
    }

    public function getCrewMembersBySolarSystem(solarSystemKey:String):Vector.<CrewMember> {
        var _loc3_:Vector.<CrewMember> = new Vector.<CrewMember>();
        for each(var _loc2_ in crewMembers) {
            if (_loc2_.solarSystem == solarSystemKey) {
                _loc3_.push(_loc2_);
            }
        }
        return _loc3_;
    }

    public function isFriendWith(p:Player):Boolean {
        for each(var _loc2_ in friends) {
            if (_loc2_.id == p.id) {
                return true;
            }
        }
        return false;
    }

    public function removeMissionById(id:String):void {
        var _loc2_:Mission = getMissionById(id);
        if (_loc2_ != null) {
            removeMission(_loc2_);
        }
    }

    public function updateMission(m:Message, i:int):void {
        var missionType:Object;
        var id:String = m.getString(i);
        var missionTypeKey:String = m.getString(i + 1);
        var mission:Mission = getMissionById(id);
        if (mission == null) {
            return;
        }
        if (missionTypeKey == "KG4YJCr9tU6IH0rJRYo7HQ") {
            g.hud.compas.clear();
            TweenMax.delayedCall(1.5, function ():void {
                var _loc1_:Boolean = false;
                for each(var _loc2_ in g.bodyManager.bodies) {
                    if (_loc2_.key == "SWqDETtcD0i6Wc3s81yccQ" || _loc2_.key == "U8PYtFoC5U6c2A_gar9j2A" || _loc2_.key == "TLYpHghGOU6FaZtxDiVXBA") {
                        for each(var _loc3_ in _loc2_.spawners) {
                            if (_loc3_.alive) {
                                _loc1_ = true;
                                g.hud.compas.addHintArrowByKey(_loc2_.key);
                                break;
                            }
                        }
                        if (_loc1_) {
                            break;
                        }
                    }
                }
            });
        }
        if (missionTypeKey == "s1l0zM-6lkq9l1jlGDBy4w") {
            g.hud.compas.clear();
        }
        g.hud.missionsButton.flash();
        mission.count = m.getInt(i + 2);
        missionType = mission.getMissionType();
        if (missionType != null && missionType.value != null) {
            g.textManager.createMissionUpdateText(mission.count, missionType.value);
        }
        mission.finished = m.getBoolean(i + 3);
        if (mission.finished) {
            g.hud.missionsButton.hintFinished();
            g.textManager.createMissionFinishedText();
            if (missionType.completeDescription != null) {
                g.tutorial.showMissionCompleteText(mission, missionType.drop, missionType.completeDescription);
            }
        }
        if (missionTypeKey == "puc60G5hKUypAIaEB4cAaA" || missionTypeKey == "mZsWmk4BUkunoD6w35aOjg" || missionTypeKey == "TYs2gVcB8UmyxfXqtIvTQA" || missionTypeKey == "m1gVvWQOGUmrFE6k4U9HOQ") {
            g.hud.compas.clear();
        }
    }

    public function toggleTractorBeam():void {
        tractorBeamActive = !tractorBeamActive;
    }

    public function isTractorBeamActive():Boolean {
        if (!hasTractorBeam()) {
            return false;
        }
        return tractorBeamActive;
    }

    public function hasTractorBeam():Boolean {
        if (g.time == 0) {
            return false;
        }
        if (isModerator) {
            return true;
        }
        return tractorBeam > g.time;
    }

    public function hasXpProtection():Boolean {
        if (g.time == 0) {
            return false;
        }
        if (level <= 15) {
            return true;
        }
        if (isModerator) {
            return true;
        }
        return xpProtection > g.time;
    }

    public function toggleCargoProtection():void {
        cargoProtectionActive = !cargoProtectionActive;
    }

    public function isCargoProtectionActive():Boolean {
        if (!hasCargoProtection()) {
            return false;
        }
        return cargoProtectionActive;
    }

    public function hasCargoProtection():Boolean {
        if (g.time == 0) {
            return false;
        }
        if (isModerator) {
            return true;
        }
        return cargoProtection > g.time;
    }

    public function hasSupporter():Boolean {
        if (g.time == 0) {
            return false;
        }
        if (isModerator) {
            return true;
        }
        return supporter > g.time;
    }

    public function changeSkin(skin:String):void {
        var _loc2_:int = 0;
        var _loc3_:FleetObj = null;
        _loc2_ = 0;
        while (_loc2_ < fleet.length) {
            _loc3_ = fleet[_loc2_];
            if (skin == _loc3_.skin) {
                activeSkin = skin;
                g.send("changeSkin", skin);
                techSkills = _loc3_.techSkills;
                weapons = _loc3_.weapons;
                weaponsState = _loc3_.weaponsState;
                weaponsHotkeys = _loc3_.weaponsHotkeys;
                nrOfUpgrades = _loc3_.nrOfUpgrades;
                activeArtifactSetup = _loc3_.activeArtifactSetup;
                activeWeapon = _loc3_.activeWeapon;
                selectedWeaponIndex = 0;
                _loc3_.lastUsed = g.time;
                unloadShip();
                ship = ShipFactory.createPlayer(g, this, g.shipManager.getPlayerShip(), weapons);
                applyArtifactStats();
                return;
            }
            _loc2_++;
        }
    }

    public function respawnReady():Boolean {
        return respawnNextReady < g.time && respawnNextReady > 0;
    }

    public function hasSkin(skin:String):Boolean {
        for each(var _loc2_ in fleet) {
            if (skin == _loc2_.skin) {
                return true;
            }
        }
        return false;
    }

    public function addEncounter(m:Message):void {
        var _loc3_:Object = null;
        var _loc4_:String = m.getString(0);
        var _loc2_:int = m.getInt(1);
        if (_loc4_.search("enemy_") != -1) {
            _loc3_ = DataLocator.getService().loadKey("Enemies", _loc4_.replace("enemy_", ""));
            if (_loc3_.hasOwnProperty("miniBoss") && _loc3_.miniBoss) {
                Game.trackEvent("encounters", _loc3_.name, name, level);
            }
        } else if (_loc4_.search("boss_") != -1) {
            _loc3_ = DataLocator.getService().loadKey("Bosses", _loc4_.replace("boss_", ""));
            Game.trackEvent("encounters", _loc3_.name, name, level);
        }
        encounters.push(_loc4_);
        Action.encounter(_loc4_);
        MessageLog.write("<FONT COLOR=\'#44ff44\'>New Encounter!</FONT>");
        MessageLog.write(_loc3_.name);
        MessageLog.write("+" + _loc2_ + " bonus xp");
        g.hud.encountersButton.flash();
        g.hud.encountersButton.hintNew();
        g.textManager.createBonusXpText(_loc2_);
    }

    public function getFleetObj(skin:String):FleetObj {
        for each(var _loc2_ in fleet) {
            if (_loc2_.skin == skin) {
                return _loc2_;
            }
        }
        return null;
    }

    public function getActiveFleetObj():FleetObj {
        return getFleetObj(activeSkin);
    }

    public function addCompletedMission(missionTypeKey:String, bestTime:Number):void {
        completedMissions[missionTypeKey] = bestTime;
        g.textManager.createMissionBestTimeText();
    }

    public function addTriggeredMission(typeKey:String):void {
        triggeredMissions.push(typeKey);
    }

    public function hasTriggeredMission(typeKey:String):Boolean {
        for each(var _loc2_ in triggeredMissions) {
            if (_loc2_ == typeKey) {
                return true;
            }
        }
        return false;
    }

    public function dispose():void {
        g = null;
        ship = null;
        stateMachine = null;
        currentBody = null;
        lastBody = null;
        weaponsHotkeys = null;
        weapons = null;
        weaponsState = null;
        weaponData = null;
        techSkills = null;
        artifacts = null;
        explores = null;
        missions = null;
        crewMembers = null;
        encounters = null;
        nrOfUpgrades = null;
        warpPathLicenses = null;
        solarSystemLicenses = null;
        pickUpLog = null;
        landedBodies = null;
        encounters = null;
        clanLogo = null;
    }

    private function activateShip():void {
        g.shipManager.activatePlayerShip(ship);
        if (isMe) {
            autoSetHotkeysForWeapons();
            g.camera.focusTarget = ship.movieClip;
        }
        ship.player = this;
        ship.enterRoaming();
    }

    private function setLevelBonusStats():void {
        var _loc1_:int = 0;
        var _loc4_:Number = NaN;
        var _loc6_:* = NaN;
        var _loc2_:Number = NaN;
        var _loc5_:Number = NaN;
        var _loc3_:int = 0;
        if (ship != null) {
            _loc1_ = level;
            _loc4_ = level;
            _loc2_ = _loc6_ / 200000;
            _loc4_ += _loc2_;
            if (g.solarSystem.isPvpSystemInEditor) {
                _loc4_ = 100;
            }
            if (level == 2) {
                _loc5_ = 8;
            } else {
                _loc5_ = (100 + 8 * (_loc4_ - 1)) / (100 + 8 * (_loc4_ - 2)) * 100 - 100;
            }
            _loc3_ = ship.hpBase * _loc5_ / 100;
            ship.hpBase += _loc3_;
            ship.hpMax += _loc3_;
            _loc3_ = ship.shieldHpBase * _loc5_ / 100;
            ship.shieldHpBase += _loc3_;
            ship.shieldHpMax += _loc3_;
            _loc3_ = ship.armorThresholdBase * _loc5_ / 100;
            ship.armorThresholdBase += _loc3_;
            ship.armorThreshold += _loc3_;
            _loc5_ = (100 + 1 * (_loc4_ - 1)) / (100 + 1 * (_loc4_ - 2)) * 100 - 100;
            _loc3_ = ship.shieldRegenBase * _loc5_ / 100;
            ship.shieldRegenBase += _loc3_;
            ship.shieldRegen += _loc3_;
            if (level == 2) {
                _loc5_ = 8;
            } else {
                _loc5_ = (100 + 8 * (_loc4_ - 1)) / (100 + 8 * (_loc4_ - 2)) * 100 - 100;
            }
            refreshWeapons();
            level = _loc1_;
        }
    }

    private function initWarpPathLicensesFromMessage(m:Message, i:int):int {
        var _loc4_:int = 0;
        var _loc3_:int = m.getInt(i++);
        warpPathLicenses = [];
        _loc4_ = 0;
        while (_loc4_ < _loc3_) {
            warpPathLicenses.push(m.getString(i++));
            _loc4_++;
        }
        return i;
    }

    private function initSolarSystemLicensesFromMessage(m:Message, i:int):int {
        var _loc4_:int = 0;
        var _loc3_:int = m.getInt(i++);
        solarSystemLicenses = [];
        _loc4_ = 0;
        while (_loc4_ < _loc3_) {
            solarSystemLicenses.push(m.getString(i++));
            _loc4_++;
        }
        trace("my id: " + id);
        return i;
    }

    private function initArtifactsFromMessage(m:Message, startIndex:int):int {
        var setups:int;
        var keysToLoad:Array;
        var setup:Array;
        var count:int;
        var artifactId:String;
        artifacts = g.dataManager.getArtifacts();
        artifactSetups.length = 0;
        setups = m.getInt(startIndex++);
        keysToLoad = [];
        while (setups > 0) {
            setup = [];
            count = m.getInt(startIndex++);
            while (count > 0) {
                artifactId = m.getString(startIndex++);
                setup.push(artifactId);
                if (keysToLoad.indexOf(artifactId) == -1 && getArtifactById(artifactId) == null) {
                    keysToLoad.push(artifactId);
                }
                count--;
            }
            artifactSetups.push(setup);
            setups--;
        }
        if (keysToLoad.length != 0) {
            ArtifactFactory.createArtifacts(keysToLoad, g, this, function ():void {
                applyArtifactStats();
            });
        } else {
            Starling.juggler.delayCall(applyArtifactStats, 1);
        }
        return startIndex;
    }

    private function applySkinArtifact():void {
        var _loc1_:Object = DataLocator.getService().loadKey("Skins", activeSkin);
        addArtifactStat(ArtifactFactory.createArtifactFromSkin(_loc1_), false);
    }

    private function applyArtifactStats():void {
        var _loc1_:Artifact = null;
        if (ship == null) {
            return;
        }
        applySkinArtifact();
        for each(var _loc2_ in activeArtifacts) {
            _loc1_ = getArtifactById(_loc2_);
            if (_loc1_ != null) {
                addArtifactStat(_loc1_, false);
            }
        }
        ship.hp = ship.hpMax;
        ship.shieldHp = ship.shieldHpMax;
    }

    private function loadArtifactsFromMessage(m:Message, startIndex:int, isLoot:Boolean = false):int {
        var id:String;
        var nrOfArtifacts:int = m.getInt(startIndex++);
        var i:int = 0;
        while (i < nrOfArtifacts) {
            id = m.getString(startIndex++);
            ArtifactFactory.createArtifact(id, g, this, function (param1:Artifact):void {
                if (param1 == null) {
                    return;
                }
                if (isLoot) {
                    if (param1.isUnique) {
                        MessageLog.writeChatMsg("loot", "<FONT COLOR=\'ffaa44\'>You found a new Unique artifact: " + param1.name + ".</FONT>");
                        g.textManager.createDropText("You found a new Unique Artifact!", 1, 20, 5000, 0xffaa44);
                    } else {
                        MessageLog.writeChatMsg("loot", "<FONT COLOR=\'#4488ff\'>You found a new artifact: " + param1.name + ".</FONT>");
                        g.textManager.createDropText("You found a new Artifact!", 1, 20, 5000, 0x4488ff);
                    }
                }
                artifacts.push(param1);
            });
            i++;
        }
        return startIndex;
    }

    private function refreshWeapons(autoSetHotKeys:Boolean = true):void {
        if (ship != null) {
            ship.weaponIsChanging = true;
            ShipFactory.CreatePlayerShipWeapon(g, this, 0, weapons, ship);
            if (isMe) {
                if (autoSetHotKeys) {
                    autoSetHotkeysForWeapons();
                }
                g.hud.weaponHotkeys.refresh();
            }
            ship.weaponIsChanging = false;
        }
    }

    private function autoSetHotkeysForWeapons():void {
        var _loc2_:Vector.<Weapon> = ship.weapons;
        for each(var _loc1_ in _loc2_) {
            if (_loc1_.hotkey == 0) {
                g.playerManager.trySetActiveWeapons(this, -1, _loc1_.key);
            }
        }
    }

    private function addRemoveArtifactStat(a:Artifact, active:Boolean, notifyServer:Boolean = true):void {
        var _loc8_:* = null;
        var _loc10_:int = 0;
        var _loc7_:Object = null;
        var _loc9_:String = null;
        var _loc6_:PetSpawner = null;
        if (ship == null) {
            return;
        }
        if (notifyServer) {
            g.send("toggleArtifact", a.id);
        }
        var _loc4_:Number = 1;
        if (!active) {
            _loc4_ = -1;
        }
        for each(var _loc5_ in a.stats) {
            if (_loc5_.type == "healthAdd" || _loc5_.type == "healthAdd2" || _loc5_.type == "healthAdd3") {
                ship.removeConvert();
                ship.hpMax += int(_loc4_ * 2 * _loc5_.value);
                ship.addConvert();
            } else if (_loc5_.type == "healthMulti") {
                ship.removeConvert();
                ship.hpMax += int(_loc4_ * ship.hpBase * (1.35 * _loc5_.value) / 100);
                ship.addConvert();
            } else if (_loc5_.type == "healthRegenAdd") {
                ship.removeConvert();
                ship.hpRegen += _loc4_ * 1 * _loc5_.value * 0.01;
                ship.addConvert();
            } else if (_loc5_.type == "armorAdd" || _loc5_.type == "armorAdd2" || _loc5_.type == "armorAdd3") {
                ship.armorThreshold += int(_loc4_ * 7.5 * _loc5_.value);
            } else if (_loc5_.type == "armorMulti") {
                ship.armorThreshold += int(_loc4_ * ship.armorThresholdBase * 1 * _loc5_.value / 100);
            } else if (_loc5_.type == "shieldAdd" || _loc5_.type == "shieldAdd2" || _loc5_.type == "shieldAdd3") {
                ship.removeConvert();
                ship.shieldHpMax += int(_loc4_ * 1.75 * _loc5_.value);
                ship.shieldRegen += int(_loc4_ * ship.shieldRegenBase * (0.0025 * _loc5_.value) / 100);
                ship.addConvert();
            } else if (_loc5_.type == "shieldMulti") {
                ship.removeConvert();
                ship.shieldHpMax += int(_loc4_ * ship.shieldHpBase * (1.35 * _loc5_.value) / 100);
                ship.shieldRegen += int(_loc4_ * ship.shieldRegenBase * (0.25 * _loc5_.value) / 100);
                ship.addConvert();
            } else if (_loc5_.type == "shieldRegen") {
                ship.removeConvert();
                ship.shieldRegen += int(_loc4_ * ship.shieldRegenBase * (1 * _loc5_.value) / 100);
                ship.addConvert();
            } else if (_loc5_.type == "corrosiveAdd" || _loc5_.type == "corrosiveAdd2" || _loc5_.type == "corrosiveAdd3") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 2);
                    if (_loc8_.multiNrOfP > 1) {
                        _loc8_.debuffValue.addDmgInt(int(1.5 / _loc8_.multiNrOfP * 4 * _loc4_ * _loc5_.value), 2);
                        _loc8_.debuffValue2.addDmgInt(int(1.5 / _loc8_.multiNrOfP * 4 * _loc4_ * _loc5_.value), 2);
                    } else {
                        _loc8_.debuffValue.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 2);
                        _loc8_.debuffValue2.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 2);
                    }
                }
            } else if (_loc5_.type == "corrosiveMulti") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgPercent(_loc4_ * 1 * _loc5_.value, 2);
                    _loc8_.debuffValue.addDmgPercent(_loc4_ * 1 * _loc5_.value, 2);
                    _loc8_.debuffValue2.addDmgPercent(_loc4_ * 1 * _loc5_.value, 2);
                }
            } else if (_loc5_.type == "energyAdd" || _loc5_.type == "energyAdd2" || _loc5_.type == "energyAdd3") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 1);
                    if (_loc8_.multiNrOfP > 1) {
                        _loc8_.debuffValue.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 4 * _loc5_.value), 1);
                        _loc8_.debuffValue2.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 4 * _loc5_.value), 1);
                    } else {
                        _loc8_.debuffValue.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 1);
                        _loc8_.debuffValue2.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 1);
                    }
                }
            } else if (_loc5_.type == "energyMulti") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgPercent(_loc4_ * 1 * _loc5_.value, 1);
                    _loc8_.debuffValue.addDmgPercent(_loc4_ * 1 * _loc5_.value, 1);
                    _loc8_.debuffValue2.addDmgPercent(_loc4_ * 1 * _loc5_.value, 1);
                }
            } else if (_loc5_.type == "kineticAdd" || _loc5_.type == "kineticAdd2" || _loc5_.type == "kineticAdd3") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 0);
                    if (_loc8_.multiNrOfP > 1) {
                        _loc8_.debuffValue.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 4 * _loc5_.value), 0);
                        _loc8_.debuffValue2.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 4 * _loc5_.value), 0);
                    } else {
                        _loc8_.debuffValue.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 0);
                        _loc8_.debuffValue2.addDmgInt(int(_loc4_ * 4 * _loc5_.value), 0);
                    }
                }
            } else if (_loc5_.type == "kineticMulti") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgPercent(_loc4_ * 1 * _loc5_.value, 0);
                    _loc8_.debuffValue.addDmgPercent(_loc4_ * 1 * _loc5_.value, 0);
                    _loc8_.debuffValue2.addDmgPercent(_loc4_ * 1 * _loc5_.value, 0);
                }
            } else if (_loc5_.type == "allAdd" || _loc5_.type == "allAdd2" || _loc5_.type == "allAdd3") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgInt(int(_loc4_ * 1.5 * _loc5_.value), 5);
                    if (_loc8_.multiNrOfP > 1) {
                        _loc8_.debuffValue.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 1.5 * _loc5_.value), 5);
                        _loc8_.debuffValue2.addDmgInt(int(1.5 / _loc8_.multiNrOfP * _loc4_ * 1.5 * _loc5_.value), 5);
                    } else {
                        _loc8_.debuffValue.addDmgInt(int(_loc4_ * 1.5 * _loc5_.value), 5);
                        _loc8_.debuffValue2.addDmgInt(int(_loc4_ * 1.5 * _loc5_.value), 5);
                    }
                }
            } else if (_loc5_.type == "allMulti") {
                for each(_loc8_ in ship.weapons) {
                    _loc8_.dmg.addDmgPercent(_loc4_ * 1.5 * _loc5_.value, 5);
                    _loc8_.debuffValue.addDmgPercent(_loc4_ * 1.5 * _loc5_.value, 5);
                    _loc8_.debuffValue2.addDmgPercent(_loc4_ * 1.5 * _loc5_.value, 5);
                }
            } else if (_loc5_.type == "allResist") {
                _loc10_ = 0;
                while (_loc10_ < 5) {
                    var _loc12_:* = _loc10_;
                    var _loc11_:* = ship.resistances[_loc12_] + _loc4_ * 1 * _loc5_.value * Damage.stats[5][_loc10_];
                    ship.resistances[_loc12_] = _loc11_;
                    if (ship.resistances[_loc10_] < 0) {
                        ship.resistances[_loc10_] = 0;
                    }
                    _loc10_++;
                }
            } else if (_loc5_.type == "kineticResist") {
                var _loc14_:int = 0;
                var _loc13_:* = ship.resistances[_loc14_] + _loc4_ * 1 * _loc5_.value;
                ship.resistances[_loc14_] = _loc13_;
                if (ship.resistances[0] < 0) {
                    ship.resistances[0] = 0;
                }
            } else if (_loc5_.type == "energyResist") {
                var _loc16_:int = 1;
                var _loc15_:* = ship.resistances[_loc16_] + _loc4_ * 1 * _loc5_.value;
                ship.resistances[_loc16_] = _loc15_;
                if (ship.resistances[1] < 0) {
                    ship.resistances[1] = 0;
                }
            } else if (_loc5_.type == "corrosiveResist") {
                var _loc18_:int = 2;
                var _loc17_:* = ship.resistances[_loc18_] + _loc4_ * 1 * _loc5_.value;
                ship.resistances[_loc18_] = _loc17_;
                if (ship.resistances[2] < 0) {
                    ship.resistances[2] = 0;
                }
            } else if (_loc5_.type == "speed" || _loc5_.type == "speed2" || _loc5_.type == "speed3" || _loc5_.type == "velocityCore") {
                ship.engine.speed /= 1 + ship.artifact_speed;
                ship.artifact_speed += _loc4_ * 0.001 * 2 * _loc5_.value;
                ship.engine.speed *= 1 + ship.artifact_speed;
            } else if (_loc5_.type == "refire" || _loc5_.type == "refire2" || _loc5_.type == "refire3") {
                _loc10_ = 0;
                while (_loc10_ < ship.weapons.length) {
                    if (ship.weapons[_loc10_] is Teleport) {
                        ship.weapons[_loc10_].speed /= 1 + 0.5 * ship.artifact_refire;
                    } else if (!(ship.weapons[_loc10_] is Cloak)) {
                        ship.weapons[_loc10_].reloadTime *= 1 + ship.artifact_refire;
                        ship.weapons[_loc10_].heatCost *= 1 + ship.artifact_refire;
                    }
                    _loc10_++;
                }
                ship.artifact_refire += _loc4_ * 3 * 0.001 * _loc5_.value;
                _loc10_ = 0;
                while (_loc10_ < ship.weapons.length) {
                    if (ship.weapons[_loc10_] is Teleport) {
                        ship.weapons[_loc10_].speed *= 1 + 0.5 * ship.artifact_refire;
                    } else if (!(ship.weapons[_loc10_] is Cloak)) {
                        ship.weapons[_loc10_].reloadTime /= 1 + ship.artifact_refire;
                        ship.weapons[_loc10_].heatCost /= 1 + ship.artifact_refire;
                    }
                    _loc10_++;
                }
            } else if (_loc5_.type == "convHp") {
                ship.removeConvert();
                ship.artifact_convAmount -= _loc4_ * 0.001 * _loc5_.value;
                ship.addConvert();
            } else if (_loc5_.type == "convShield") {
                ship.removeConvert();
                ship.artifact_convAmount += _loc4_ * 0.001 * _loc5_.value;
                ship.addConvert();
            } else if (_loc5_.type == "powerReg" || _loc5_.type == "powerReg2" || _loc5_.type == "powerReg3") {
                ship.powerRegBonus += _loc4_ * 0.001 * 1.5 * _loc5_.value;
                ship.weaponHeat.setBonuses(ship.maxPower + ship.artifact_powerMax, ship.powerRegBonus + ship.artifact_powerRegen);
            } else if (_loc5_.type == "powerMax") {
                ship.artifact_powerMax += _loc4_ * 0.01 * 1.5 * _loc5_.value;
                ship.weaponHeat.setBonuses(ship.maxPower + ship.artifact_powerMax, ship.powerRegBonus + ship.artifact_powerRegen);
            } else if (_loc5_.type == "cooldown" || _loc5_.type == "cooldown2" || _loc5_.type == "cooldown3") {
                _loc10_ = 0;
                while (_loc10_ < ship.weapons.length) {
                    if (ship.weapons[_loc10_] is Teleport || ship.weapons[_loc10_] is Cloak) {
                        ship.weapons[_loc10_].reloadTime *= 1 + ship.artifact_cooldownReduction;
                    }
                    _loc10_++;
                }
                ship.artifact_cooldownReduction += _loc4_ * 1 * 0.001 * _loc5_.value;
                _loc10_ = 0;
                while (_loc10_ < ship.weapons.length) {
                    if (ship.weapons[_loc10_] is Teleport || ship.weapons[_loc10_] is Cloak) {
                        ship.weapons[_loc10_].reloadTime /= 1 + ship.artifact_cooldownReduction;
                    }
                    _loc10_++;
                }
            } else if (_loc5_.type != "kineticChanceToPenetrateShield") {
                if (_loc5_.type != "corrosiveChanceToIgnite") {
                    if (_loc5_.type != "energyChanceToShieldOverload") {
                        if (_loc5_.type != "increaseRecyleRate") {
                            if (_loc5_.type == "upgrade") {
                                _loc7_ = ship.obj;
                                _loc9_ = ship.name;
                                if (_loc9_.indexOf("Nexar") != -1) {
                                    break;
                                }
                                ship.removeConvert();
                                if (_loc7_.armor < 20) {
                                    ship.armorThreshold += _loc4_ * MathUtil.min(ship.armorThresholdBase * (20 / _loc7_.armor) * 0.8, ship.armorThresholdBase * 2);
                                }
                                if (_loc7_.hp < 800) {
                                    ship.hpMax += _loc4_ * MathUtil.min(ship.hpBase * (800 / _loc7_.hp) * 0.8, ship.hpBase * 2);
                                }
                                if (_loc7_.shieldHp < 800) {
                                    ship.shieldHpMax += _loc4_ * MathUtil.min(ship.shieldHpBase * (800 / _loc7_.shieldHp) * 0.8, ship.shieldHpBase * 2);
                                }
                                if (_loc7_.shieldRegen * 1.5 < 80) {
                                    ship.shieldRegen += _loc4_ * MathUtil.min(ship.shieldRegenBase * (80 / _loc7_.shieldRegen * 1.5) * 0.8, ship.shieldRegenBase * 2);
                                }
                                ship.addConvert();
                            } else if (_loc5_.type != "recycleCatalyst") {
                                if (_loc5_.type == "slowDown") {
                                    if (_loc4_ > 0) {
                                        for each(_loc8_ in ship.weapons) {
                                            _loc8_.addDebuff(11, 4, new Damage(_loc5_.value, 8), "F4806EAE-35F4-6E5D-5938-EAC8248D4702");
                                        }
                                    } else {
                                        for each(_loc8_ in ship.weapons) {
                                            _loc8_.removeDebuff(11, new Damage(_loc5_.value, 8));
                                        }
                                    }
                                } else if (_loc5_.type == "beamAndMissileDoesBonusDamage") {
                                    for each(_loc8_ in ship.weapons) {
                                        if (_loc8_ is Beam || _loc8_.isMissileWeapon) {
                                            _loc8_.dmg.addDmgPercent(_loc4_ * _loc5_.value, 5);
                                            _loc8_.debuffValue.addDmgPercent(_loc4_ * _loc5_.value, 5);
                                            _loc8_.debuffValue2.addDmgPercent(_loc4_ * _loc5_.value, 5);
                                        }
                                    }
                                } else if (_loc5_.type == "overmind") {
                                    for each(_loc8_ in ship.weapons) {
                                        if (_loc8_ is PetSpawner) {
                                            _loc6_ = _loc8_ as PetSpawner;
                                            if (_loc4_ > 0) {
                                                _loc6_.maxPets *= 2;
                                            } else {
                                                _loc6_.maxPets /= 2;
                                            }
                                        }
                                    }
                                } else if (_loc5_.type != "thermofangCore") {
                                    if (_loc5_.type == "lucaniteCore") {
                                        if (_loc4_ > 0) {
                                            for each(_loc8_ in ship.weapons) {
                                                _loc8_.addDebuff(7, 4, new Damage(_loc5_.value, 8), "xYk7ubyao0uh8j9SDJYeWw");
                                            }
                                        } else {
                                            for each(_loc8_ in ship.weapons) {
                                                _loc8_.removeDebuff(7, new Damage(_loc5_.value, 8));
                                            }
                                        }
                                    } else if (_loc5_.type != "mantisCore") {
                                        if (_loc5_.type == "reduceKineticResistance") {
                                            if (_loc4_ > 0) {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.addDebuff(8, 4, new Damage(_loc5_.value, 8), "Tk7JFixDAkuw6mB-BLXQwg");
                                                }
                                            } else {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.removeDebuff(8, new Damage(_loc5_.value, 8));
                                                }
                                            }
                                        } else if (_loc5_.type == "reduceCorrosiveResistance") {
                                            if (_loc4_ > 0) {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.addDebuff(10, 4, new Damage(_loc5_.value, 8), "U4WOoDzOV0iXNmVwM3SELA");
                                                }
                                            } else {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.removeDebuff(10, new Damage(_loc5_.value, 8));
                                                }
                                            }
                                        } else if (_loc5_.type == "reduceEnergyResistance") {
                                            if (_loc4_ > 0) {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.addDebuff(9, 4, new Damage(_loc5_.value, 8), "9kIM0A-0d0uPHMjJ1qg5pg");
                                                }
                                            } else {
                                                for each(_loc8_ in ship.weapons) {
                                                    _loc8_.removeDebuff(9, new Damage(_loc5_.value, 8));
                                                }
                                            }
                                        } else if (_loc5_.type != "crownOfXhersix") {
                                            if (_loc5_.type != "veilOfYhgvis") {
                                                if (_loc5_.type != "fistOfZharix") {
                                                    if (_loc5_.type == "dotDamageUnique" || _loc5_.type == "dotDamage") {
                                                        for each(_loc8_ in ship.weapons) {
                                                            _loc8_.debuffValue.addDmgPercent(_loc4_ * 1 * _loc5_.value, 5);
                                                            _loc8_.debuffValue2.addDmgPercent(_loc4_ * 1 * _loc5_.value, 5);
                                                        }
                                                    } else if (_loc5_.type == "dotDuration") {
                                                        for each(_loc8_ in ship.weapons) {
                                                            _loc8_.debuffDuration += _loc4_ * 1 * _loc5_.value * 0.01;
                                                            _loc8_.debuffDuration2 += _loc4_ * 1 * _loc5_.value * 0.01;
                                                        }
                                                    } else if (_loc5_.type == "directDamageUnique" || _loc5_.type == "directDamage") {
                                                        for each(_loc8_ in ship.weapons) {
                                                            _loc8_.dmg.addDmgPercent(_loc4_ * 1 * _loc5_.value, 5);
                                                        }
                                                    } else if (_loc5_.type == "healthVamp") {
                                                        for each(_loc8_ in ship.weapons) {
                                                            _loc8_.healthVamp += _loc4_ * _loc5_.value * 1;
                                                        }
                                                    } else if (_loc5_.type == "shieldVamp") {
                                                        for each(_loc8_ in ship.weapons) {
                                                            _loc8_.shieldVamp += _loc4_ * _loc5_.value * 1;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (isMe) {
            if (!g.hud.isLoaded) {
                return;
            }
            g.hud.healthAndShield.update();
            g.hud.weaponHotkeys.refresh();
            g.hud.abilities.refresh();
        }
    }

    private function getMissionById(id:String):Mission {
        for each(var _loc2_ in missions) {
            if (_loc2_.id == id) {
                return _loc2_;
            }
        }
        return null;
    }
}
}

