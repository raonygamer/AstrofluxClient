package core.scene {
import com.google.analytics.AnalyticsTracker;
import com.google.analytics.GATracker;
import com.greensock.TweenMax;

import core.GameObject;
import core.boss.BossManager;
import core.clan.ClanApplicationCheck;
import core.controlZones.ControlZoneManager;
import core.credits.CreditManager;
import core.credits.SalesManager;
import core.deathLine.DeathLineManager;
import core.drops.DropManager;
import core.friend.FriendManager;
import core.group.GroupManager;
import core.hud.Hud;
import core.hud.components.SaleSpinner;
import core.hud.components.ScreenTextField;
import core.hud.components.Style;
import core.hud.components.Text;
import core.hud.components.chat.ChatInputText;
import core.hud.components.chat.MessageLog;
import core.hud.components.dialogs.PopupMessage;
import core.hud.components.dialogs.TOSPopup;
import core.hud.components.pvp.PvpManager;
import core.hud.components.starMap.SolarSystem;
import core.missions.DailyManager;
import core.parallax.ParallaxManager;
import core.particle.Emitter;
import core.particle.EmitterManager;
import core.player.Player;
import core.player.PlayerManager;
import core.pools.BeamLinePool;
import core.pools.LinePool;
import core.pools.RibbonTrailPool;
import core.projectile.ProjectileManager;
import core.queue.QueueManager;
import core.ship.ShipManager;
import core.solarSystem.Body;
import core.solarSystem.BodyManager;
import core.spawner.SpawnManager;
import core.states.GameStateMachine;
import core.states.IGameState;
import core.states.gameStates.IntroState;
import core.states.gameStates.LandedCantina;
import core.states.gameStates.LandedExplore;
import core.states.gameStates.LandedHangar;
import core.states.gameStates.LandedLore;
import core.states.gameStates.LandedPaintShop;
import core.states.gameStates.LandedPiratebay;
import core.states.gameStates.LandedRecycle;
import core.states.gameStates.LandedUpgrade;
import core.states.gameStates.LandedWarpGate;
import core.states.gameStates.LandedWeaponFactory;
import core.states.gameStates.RoamingState;
import core.sync.MessagePackHandler;
import core.text.TextManager;
import core.turret.TurretManager;
import core.tutorial.Tutorial;
import core.unit.UnitManager;
import core.weapon.WeaponManager;

import data.DataLocator;
import data.IDataManager;
import data.Settings;

import debug.Console;

import extensions.PixelHitArea;

import facebook.FB;

import flash.events.Event;
import flash.events.SecurityErrorEvent;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.system.Security;

import generics.Localize;

import io.InputLocator;

import joinRoom.IJoinRoomManager;
import joinRoom.JoinRoomLocator;
import joinRoom.JoinRoomManager;
import joinRoom.Room;

import movement.CommandManager;

import playerio.Client;
import playerio.Connection;
import playerio.Message;

import sound.Playlist;
import sound.SoundLocator;

import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.utils.AssetManager;

import textures.ITextureManager;
import textures.TextureLocator;

public class Game extends SceneBase {
    public static const TICK_LENGTH:int = 33;
    public static const SOUND_DISTANCE:int = 250000;
    public static const FRICTION:Number = 0.009;
    public static const MAX_LEVEL:Number = 150;
    public static const SAFEZONEFULLREGENTIME:int = 10;
    public static const DEFENSEBONUS:int = 8;
    public static const DMGBONUS:int = 8;
    public static const REGENBONUS:int = 1;
    public static const SYNC_FREQUENCY:Number = 50000;
    public static var instance:Game;
    public static var highSettings:Boolean = true;
    public static var lastActive:int;
    public static var assets:AssetManager = new AssetManager();
    private static var tracker:AnalyticsTracker;

    public static function trackPageView(msg:String):void {
        try {
            if (tracker == null) {
                tracker = new GATracker(Starling.current.nativeStage, "UA-32570398-1", "AS3", false);
            }
            tracker.trackPageview("/" + msg);
        } catch (e:Error) {
        }
    }

    public static function trackEvent(category:String, action:String, label:String = null, value:Number = NaN):void {
        try {
            if (tracker == null) {
                tracker = new GATracker(Starling.current.nativeStage, "UA-32570398-1", "AS3", false);
            }
            tracker.trackEvent(category, action, label, value);
        } catch (e:Error) {
        }
    }

    public static function isFacebookUser():Boolean {
        return Login.currentState == "facebook";
    }

    public static function isKongregateUser():Boolean {
        return Login.currentState == "kongregate";
    }

    public static function playerPerformedAction():void {
        lastActive = new Date().time;
    }

    public static function printTimeStamp(message:String):void {
        trace(message);
    }

    public function Game(client:Client, serviceConnection:Connection, connection:Connection, room:Room) {
        super(client, serviceConnection, connection, room);
        addMessageHandler("sdf", m_sdf);
        addServiceMessageHandler("blg", m_blg);
        addMessageHandler("test", function ():void {
            trace("TEST RECEIVED");
        });
        instance = this;
    }
    public var solarSystem:SolarSystem;
    public var parallaxManager:ParallaxManager;
    public var playerManager:PlayerManager;
    public var unitManager:UnitManager;
    public var shipManager:ShipManager;
    public var ribbonTrailPool:RibbonTrailPool;
    public var linePool:LinePool;
    public var beamLinePool:BeamLinePool;
    public var bossManager:BossManager;
    public var emitterManager:EmitterManager;
    public var weaponManager:WeaponManager;
    public var projectileManager:ProjectileManager;
    public var bodyManager:BodyManager;
    public var spawnManager:SpawnManager;
    public var dailyManager:DailyManager;
    public var turretManager:TurretManager;
    public var messagePackHandler:MessagePackHandler;
    public var deathLineManager:DeathLineManager;
    public var gameStateMachine:GameStateMachine;
    public var hud:Hud;
    public var textManager:TextManager;
    public var dropManager:DropManager;
    public var commandManager:CommandManager;
    public var groupManager:GroupManager;
    public var friendManager:FriendManager;
    public var tutorial:Tutorial;
    public var creditManager:CreditManager;
    public var messageLog:MessageLog;
    public var chatInput:ChatInputText;
    public var dataManager:IDataManager;
    public var textureManager:ITextureManager;
    public var queueManager:QueueManager;
    public var pvpManager:PvpManager;
    public var controlZoneManager:ControlZoneManager;
    public var salesManager:SalesManager;
    public var quality:int = 10;
    public var gameStartedTime:Number = 0;
    private var initSolarSystemComplete:Boolean = false;
    private var initPlayerComplete:Boolean = false;
    private var initEnemyPlayersComplete:Boolean = false;
    private var initEnemiesComplete:Boolean = false;
    private var initDropsComplete:Boolean = false;
    private var initServerComplete:Boolean = false;
    private var isTOSPopup:Boolean = false;
    private var isSaleSpinner:Boolean = false;
    private var nextSync:Number;
    private var welcomeText:ScreenTextField = new ScreenTextField(450, 100);
    private var solarSystemData:Text = new Text();
    private var requestID:String = "";
    private var enableTrackFPS:Boolean = false;
    private var runningFPS:int = -1;
    private var frameCount:int = 0;
    private var totalTime:Number = 0;
    private var elapsedTime:Number = 0;
    private var qualityText:Text;
    private var synchedEnemies:Boolean = false;
    private var tweenCount:int = 0;
    private var rot:Number = 0;
    private var disconnectPopup:PopupMessage;
    private var loadingSprite:Sprite = new Sprite();
    private var loadingFadeTween:TweenMax;

    public function get me():Player {
        if (playerManager == null) {
            return null;
        }
        return playerManager.me;
    }

    override protected function userJoined(m:Message):void {
        if (playerManager == null) {
            return;
        }
        if (initEnemiesComplete && playerManager.playersById[m.getString(0)] == null) {
            playerManager.initPlayer(m);
            if (me != null && pvpManager != null) {
                pvpManager.updateMap(playerManager.playersById[m.getString(0)]);
            }
        }
    }

    override protected function userLeft(m:Message):void {
        if (playerManager == null) {
            return;
        }
        playerManager.removePlayer(m);
    }

    override protected function handleDisconnect():void {
        var errorData:Object;
        if (disconnectPopup) {
            return;
        }
        if (clock != null && solarSystem != null && me != null) {
            errorData = {};
            errorData.id = me.id;
            errorData.solarSystem = solarSystem.name;
            errorData.latency = clock.latency;
            errorData.elapsedTime = clock.elapsedTime / 1000;
            client.errorLog.writeError("Client Disconnect Adv. from GameRoom", "disconnect handler on client from GameRoom", "No Stacktrace", errorData);
        }
        disconnectPopup = new PopupMessage("Reload");
        disconnectPopup.text = Localize.t("You got disconnected from the server.");
        addChildToOverlay(disconnectPopup);
        disconnectPopup.addEventListener("close", function (param1:starling.events.Event):void {
            removeChildFromOverlay(disconnectPopup, true);
            disconnectPopup = null;
            reload();
        });
        removeEventListener("enterFrame", update);
    }

    override public function exit():void {
        Console.write("Exit Game");
        removeEventListeners();
        enableTrackFPS = false;
        disconnect();
        gameStateMachine.dispose();
        shipManager.dispose();
        bodyManager.dispose();
        projectileManager.dispose();
        dropManager.dispose();
        spawnManager.dispose();
        emitterManager.dispose();
        textManager.dispose();
        hud.dispose();
        ribbonTrailPool.dispose();
        linePool.dispose();
        beamLinePool.dispose();
        tutorial.dispose();
        var _loc1_:ITextureManager = TextureLocator.getService();
        _loc1_.disposeCustomTextures();
        camera.destroy();
        camera = null;
        parallaxManager = null;
        shipManager = null;
        playerManager = null;
        emitterManager = null;
        weaponManager = null;
        projectileManager = null;
        bodyManager = null;
        spawnManager = null;
        hud = null;
        textManager = null;
        dropManager = null;
        commandManager = null;
        groupManager = null;
        tutorial = null;
        creditManager = null;
        friendManager = null;
        turretManager = null;
        bossManager = null;
        unitManager = null;
        messageLog = null;
        ribbonTrailPool = null;
        linePool = null;
        beamLinePool = null;
        gameStateMachine = null;
        PixelHitArea.dispose();
        InputLocator.getService().dispose();
        room = null;
        super.exit();
    }

    override public function draw():void {
        var _loc2_:int = 0;
        var _loc1_:GameObject = null;
        parallaxManager.draw();
        var _loc3_:int = int(bodyManager.bodies.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = bodyManager.bodies[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(spawnManager.spawners.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = spawnManager.spawners[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(turretManager.turrets.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = turretManager.turrets[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(dropManager.drops.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = dropManager.drops[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(bossManager.bosses.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = bossManager.bosses[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(shipManager.ships.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = shipManager.ships[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(projectileManager.projectiles.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = projectileManager.projectiles[_loc2_];
            if (_loc1_.isAddedToCanvas) {
                _loc1_.draw();
            }
            _loc2_++;
        }
        _loc3_ = int(weaponManager.weapons.length);
        _loc2_ = 0;
        while (_loc2_ < _loc3_) {
            _loc1_ = weaponManager.weapons[_loc2_];
            _loc1_.draw();
            _loc2_++;
        }
    }

    public function toggleHighGraphics(value:Boolean):void {
        highSettings = value;
        if (value) {
            Emitter.setHighGraphics();
        } else {
            Emitter.setLowGraphics();
            for each(var _loc2_ in bodyManager.bodies) {
                _loc2_.turnOffEffects();
            }
        }
    }

    public function tryOpenSaleSpinner():void {
        var salePopup:SaleSpinner;
        if (me.hasCorrectTOSVersion && salesManager.isSale()) {
            Login.isSaleSpinner = true;
            Console.write("opened sale spinner");
            salePopup = new SaleSpinner(this);
            addChildToOverlay(salePopup);
            salePopup.addEventListener("close", function (param1:starling.events.Event):void {
                removeChildFromOverlay(salePopup, true);
            });
        }
    }

    public function sendAccept():void {
        send("acceptedTOS", 3);
    }

    public function showQuality():void {
        if (!me.isDeveloper) {
            return;
        }
        Console.write("show quality");
        qualityText = new Text(stage.stageWidth - 70, 70);
        qualityText.size = 26;
        qualityText.color = 0xffffff;
        addChildToOverlay(qualityText);
    }

    public function setQuality(q:int):void {
        if (q >= 0 && q <= 10) {
            quality = q;
        }
        if (qualityText) {
            qualityText.text = "" + q;
        }
    }

    public function enterLandedState():void {
        var _loc1_:Body = me.currentBody;
        if (_loc1_.type == "planet") {
            fadeIntoState(new LandedExplore(this, _loc1_));
        } else if (_loc1_.type == "junk yard") {
            fadeIntoState(new LandedRecycle(this, _loc1_));
        } else if (_loc1_.type == "shop") {
            fadeIntoState(new LandedWeaponFactory(this, _loc1_));
        } else if (_loc1_.type == "research") {
            fadeIntoState(new LandedUpgrade(this, _loc1_));
        } else if (_loc1_.type == "warpGate") {
            fadeIntoState(new LandedWarpGate(this, _loc1_));
        } else if (_loc1_.type == "hangar") {
            fadeIntoState(new LandedHangar(this, _loc1_));
        } else if (_loc1_.type == "cantina") {
            fadeIntoState(new LandedCantina(this, _loc1_));
        } else if (_loc1_.type == "paintShop") {
            fadeIntoState(new LandedPaintShop(this, _loc1_));
        } else if (_loc1_.type == "lore") {
            fadeIntoState(new LandedLore(this, _loc1_));
        } else if (_loc1_.type == "pirate") {
            fadeIntoState(new LandedPiratebay(this, _loc1_));
        }
        focusGameObject(_loc1_, true);
    }

    public function tickUpdate():void {
        time = getServerTime();
        playerManager.update();
        bodyManager.update();
        bossManager.update();
        dropManager.update();
        spawnManager.update();
        shipManager.update();
        weaponManager.update();
        projectileManager.update();
        emitterManager.update();
        camera.update();
        hud.update();
        deathLineManager.update();
        if (pvpManager != null) {
            pvpManager.update();
        }
        updateSync();
    }

    public function enterState(state:IGameState):void {
        if (gameStateMachine.inState(state)) {
            return;
        }
        gameStateMachine.changeState(state);
    }

    public function fadeIntoState(state:IGameState):void {
        if (gameStateMachine.inState(state)) {
            return;
        }
        Login.fadeScreen.addEventListener("fadeInComplete", (function ():* {
            var onFadeInComplete:Function;
            return onFadeInComplete = function (param1:starling.events.Event):void {
                gameStateMachine.changeState(state);
                Login.fadeScreen.removeEventListener("fadeInComplete", onFadeInComplete);
            };
        })());
        Login.fadeScreen.fadeIn();
    }

    public function softDisconnect(message:String):void {
        if (disconnectPopup) {
            return;
        }
        disconnectPopup = new PopupMessage("Ok");
        disconnectPopup.text = Localize.t(message);
        addChildToOverlay(disconnectPopup);
        disconnectPopup.addEventListener("close", function (param1:starling.events.Event):void {
            removeChildFromOverlay(disconnectPopup, true);
            disconnectPopup = null;
        });
        removeEventListener("enterFrame", update);
    }

    public function tryJoinMatch(roomId:String, solarSystem:String):void {
        if (roomId == null || roomId == "" || solarSystem == null || solarSystem == "") {
            return;
        }
        Game.trackEvent("pvp", "match", "enter", me.level);
        send("warpToPvpMatch", roomId, solarSystem);
    }

    public function warpJump(destination:String, roomId:String = "", systemType:String = ""):void {
        var joinData:Object;
        var joinRoomManager:IJoinRoomManager;
        removeEventListener("enterFrame", update);
        enableTrackFPS = false;
        joinData = {};
        joinData["warpJump"] = true;
        joinData["level"] = me.level;
        joinRoomManager = JoinRoomLocator.getService();
        if (roomId == "reset") {
            joinRoomManager.desiredRoomId = null;
        } else if (roomId != null && roomId != "") {
            joinRoomManager.desiredRoomId = roomId;
        }
        if (systemType != "") {
            joinRoomManager.desiredSystemType = systemType;
        }
        Login.fadeScreen.show();
        if (joinRoomManager.desiredSystemType == "domination" || joinRoomManager.desiredSystemType == "deathmatch") {
            rpcServiceRoom("requestTop10PvpHighscore", function (param1:Message):void {
                Login.fadeScreen.showHighscore(param1);
            });
        }
        joinRoomManager.joinGame(destination, joinData);
    }

    public function exitDesktop():void {
        Starling.current.stop();
        RymdenRunt.instance.dispatchEvent(new flash.events.Event("exitgame"));
    }

    public function focusGameObject(go:GameObject, override:Boolean = true):void {
        if (go == null) {
            return;
        }
        go.draw();
        if (override) {
            camera.jumpToFocus(go.movieClip);
        }
        bodyManager.forceUpdate();
        unitManager.forceUpdate();
        emitterManager.forceUpdate(go);
        bossManager.forceUpdate();
        deathLineManager.forceUpdate();
        projectileManager.forceUpdate();
        dropManager.forceUpdate();
    }

    public function updateServiceRoom():void {
        var _loc1_:Message = serviceConnection.createMessage("updatePlayer");
        _loc1_.add(solarSystem.key);
        _loc1_.add(solarSystem.type);
        _loc1_.add(me.name);
        _loc1_.add(me.clanId);
        _loc1_.add(roomId);
        _loc1_.add(me.level);
        _loc1_.add(me.activeSkin);
        sendMessageToServiceRoom(_loc1_);
    }

    public function showModalLoadingScreen(text:String):void {
        blockHotkeys = true;
        var _loc2_:Quad = new Quad(stage.stageWidth, stage.stageHeight, 0);
        _loc2_.alpha = 0.8;
        loadingSprite.addChild(_loc2_);
        var _loc3_:Text = new Text();
        _loc3_.size = 26;
        _loc3_.htmlText = Localize.t(text);
        loadingFadeTween = TweenMax.fromTo(_loc3_, 2, {"alpha": 1}, {
            "alpha": 0.4,
            "repeat": -1
        });
        _loc3_.centerPivot();
        _loc3_.x = stage.stageWidth / 2;
        _loc3_.y = stage.stageHeight / 2;
        loadingSprite.addChild(_loc3_);
        addChildToOverlay(loadingSprite);
    }

    public function hideModalLoadingScreen():void {
        loadingFadeTween.kill();
        blockHotkeys = false;
        loadingSprite.removeChildren(0, -1, true);
        removeChildFromOverlay(loadingSprite, true);
    }

    public function reloadTexts():void {
        var _loc1_:URLRequest = new URLRequest();
        _loc1_.url = "http://astroflux.elasticbeanstalk.com/update";
        _loc1_.requestHeaders = [new URLRequestHeader("Content-Type", "application/json")];
        _loc1_.method = "GET";
        var _loc2_:URLLoader = new URLLoader();
        _loc2_.addEventListener("complete", receive);
        _loc2_.addEventListener("securityError", notAllowed);
        _loc2_.addEventListener("ioError", notFound);
        _loc2_.load(_loc1_);
    }

    public function respawned():void {
        Playlist.next();
    }

    public function killed():void {
        SoundLocator.getService().stopMusic();
        SoundLocator.getService().playMusic("y_s45d0sJkiPm6jpZFx2ow", true);
    }

    private function trackServerEvent(m:Message):void {
        trackEvent(m.getString(0), m.getString(1), m.getString(2), m.getNumber(3));
    }

    private function handleRequestID(response:Object):void {
        var _loc2_:String = null;
        var _loc3_:Object = null;
        if (response != null && Boolean(response.hasOwnProperty("from")) && response.from.hasOwnProperty("id")) {
            Game.trackEvent("FBinvite", "invite feedback", "joined game", 1);
            _loc2_ = response.from.id;
            _loc2_ = "fb" + _loc2_;
            me.inviter_id = _loc2_;
            send("FBinviteAccepted", _loc2_);
            sendToServiceRoom("requestUpdateInviteReward", _loc2_);
            _loc3_ = {"method": "delete"};
            FB.api("/" + requestID, handleRequestID, _loc3_, "POST");
        }
    }

    private function onInitSolarSystem(m:Message):void {
        Game.printTimeStamp("onInitSolarSystem");
        if (settings == null) {
            settings = new Settings();
        }
        settings.sb = this;
        bodyManager.initSolarSystem(m);
        Console.write("Init solar system complete");
        initSolarSystemComplete = true;
        spawnManager.addEarlyMessageHandlers();
        turretManager.addEarlyMessageHandlers();
        send("initGame");
    }

    private function onInitPlayer(m:Message):void {
        Game.printTimeStamp("onInitPlayer");
        try {
            rpcServiceRoom("requestRating", (function ():* {
                var rpcHandler:Function;
                return rpcHandler = function (param1:Message):void {
                    me.ranking = param1.getInt(0);
                    me.rating = param1.getNumber(1);
                };
            })());
            playerManager.initPlayer(m, 0);
            initPlayerComplete = true;
            camera.focusTarget = me.ship.movieClip;
            controlZoneManager.init();
            updateServiceRoom();
            tryRunGameLoop();
        } catch (e:Error) {
            trace("ERROR" + e.getStackTrace());
            client.errorLog.writeError(e.toString(), " player init failed: " + client.connectUserId, e.getStackTrace(), {});
        }
    }

    private function onInitEnemyPlayers(m:Message, startIndex:int = 0):void {
        Game.printTimeStamp("onInitEnemyPlayers");
        if (m.length == 0) {
            completeOnInitEnemyPlayers();
            return;
        }
        var _loc3_:int = playerManager.initPlayer(m, startIndex);
        if (_loc3_ < m.length - 1) {
            onInitEnemyPlayers(m, _loc3_);
        } else {
            completeOnInitEnemyPlayers();
        }
    }

    private function completeOnInitEnemyPlayers():void {
        initEnemyPlayersComplete = true;
        Console.write("Init enemy players complete");
        tryRunGameLoop();
    }

    private function onInitEnemies(m:Message):void {
        Game.printTimeStamp("onInitEnemies");
        Console.write("Init enemies received");
        shipManager.addEarlyMessageHandlers();
        shipManager.initEnemies(m);
        initEnemiesComplete = true;
        Console.write("Init enemies complete");
        tryRunGameLoop();
    }

    private function onInitDrops(m:Message):void {
        Game.printTimeStamp("onInitDrops");
        initDropsComplete = true;
        tryRunGameLoop();
    }

    private function onInitServerComplete(m:Message):void {
        Game.printTimeStamp("onInitServerComplete");
        Console.write("Init server complete");
        initServerComplete = true;
        tryRunGameLoop();
    }

    private function tryRunGameLoop():void {
        if (initSolarSystemComplete && initPlayerComplete && initEnemyPlayersComplete && initEnemiesComplete && initDropsComplete && initServerComplete) {
            hud.load();
            hud.healthAndShield.update();
            send("initSyncEnemies");
            runGameLoop();
        }
    }

    private function tryOpenTOSPopup():void {
        var tosPopup:TOSPopup;
        if (Login.currentState == "steam") {
            return;
        }
        if (!me.hasCorrectTOSVersion && !Login.isNewPlayer) {
            isTOSPopup = true;
            tosPopup = new TOSPopup(this);
            addChildToOverlay(tosPopup);
            tosPopup.addEventListener("accept", function (param1:starling.events.Event):void {
                removeChildFromOverlay(tosPopup, true);
                sendAccept();
                me.hasCorrectTOSVersion = true;
            });
            tosPopup.addEventListener("close", function (param1:starling.events.Event):void {
                removeChildFromOverlay(tosPopup, true);
                hud.show = false;
                exit();
            });
        }
    }

    private function runGameLoop():void {
        var clanApplicationCheck:ClanApplicationCheck;
        var pleaseRate:PopupMessage;
        gameStartedTime = new Date().time;
        playerManager.addMessageHandlers();
        groupManager.addMessageHandlers();
        shipManager.addMessageHandlers();
        projectileManager.addMessageHandlers();
        dropManager.addMessageHandlers();
        commandManager.addMessageHandlers();
        spawnManager.addMessageHandlers();
        turretManager.addMessageHandlers();
        bossManager.addMessageHandlers();
        bodyManager.addMessageHandlers();
        friendManager.addMessageHandlers();
        deathLineManager.addMessageHandlers();
        messagePackHandler.addMessageHandlers();
        controlZoneManager.addMessageHandlers();
        dailyManager.addMessageHandlers();
        addMessageHandler("invasion", onInvasion);
        messageLog = new MessageLog(this);
        messageLog.x = 20;
        messageLog.y = 70;
        addChildToOverlay(messageLog);
        chatInput = new ChatInputText(this, stage.stageWidth / 2 - 150, stage.stageHeight - 150, 400, 25);
        addChildToOverlay(chatInput);
        nextSync = time + 50000;
        if (Login.currentState == "facebook" && Boolean(RymdenRunt.parameters.hasOwnProperty("request_ids"))) {
            requestID = RymdenRunt.parameters.request_ids;
            FB.api("/" + RymdenRunt.parameters.request_ids, handleRequestID);
        }
        if (!me.isLanded) {
            if (me.showIntro) {
                tryEnterIntro();
            } else {
                hud.initMissionsButtons();
                drawWelcomeText();
                enterState(new RoamingState(this));
                me.requestRewardsOnLogin();
                me.requestInviteReward();
                me.requestLikeReward();
            }
        } else {
            enterLandedState();
            me.requestRewardsOnLogin();
            me.requestLikeReward();
            me.requestInviteReward();
            hud.initMissionsButtons();
        }
        if (!me.showIntro) {
            clanApplicationCheck = new ClanApplicationCheck(this);
            clanApplicationCheck.check();
        }
        if (Login.currentState == "kongregate" && !me.kongRated && me.level > 10) {
            me.sendKongRated();
            pleaseRate = new PopupMessage("Close");
            pleaseRate.text = "<FONT COLOR=\'#ffff44\' SIZE=\'16\'>Hello Captain!\n\n</FONT>Great having you onboard and also, great job this far.\n\nYou can help us a lot by giving us a 5 star rating.\n\nThanks /The Astroflux team!";
            pleaseRate.addEventListener("close", function (param1:starling.events.Event):void {
                pleaseRate.removeEventListeners();
                removeChildFromOverlay(pleaseRate);
            });
            addChildToOverlay(pleaseRate);
            pleaseRate.y += 60;
        }
        if (RymdenRunt.parameters.querystring_c) {
            send("segment", "campaign: " + RymdenRunt.parameters.querystring_c);
        }
        lastActive = new Date().time;
        disconnectIfInactive();
        addEventListener("enterFrame", update);
        initTrackFPS();
        startSystemMusic();
    }

    private function trackFPS():void {
        if (runningFPS < 3) {
            return;
        }
        if (!enableTrackFPS) {
            return;
        }
        if (solarSystem == null) {
            return;
        }
        if (me.isWarpJumping) {
            return;
        }
        if (!RymdenRunt.isInFocus) {
            return;
        }
        var _loc1_:int = new Date().time - lastActive;
        if (_loc1_ > 10000) {
            return;
        }
        var _loc2_:String = "";
        if (runningFPS < 10) {
            _loc2_ = "0-10 FPS";
        } else if (runningFPS < 20) {
            _loc2_ = "10-20 FPS";
        } else if (runningFPS < 30) {
            _loc2_ = "20-30 FPS";
        } else if (runningFPS < 40) {
            _loc2_ = "30-40 FPS";
        } else if (runningFPS < 50) {
            _loc2_ = "40-50 FPS";
        } else if (runningFPS < 60) {
            _loc2_ = "50-60 FPS";
        }
        Game.trackEvent("FPS in system", solarSystem.name, _loc2_, runningFPS);
    }

    private function initTrackFPS():void {
        if ("".length > 0) {
            return;
        }
        TweenMax.delayedCall(60, function ():void {
            frameCount = 0;
            totalTime = 0;
            elapsedTime = 0;
            enableTrackFPS = true;
        });
    }

    private function tryEnterIntro():void {
        if (Login.START_SETUP_IS_DONE) {
            enterState(new IntroState(this));
        } else {
            TweenMax.delayedCall(0.1, tryEnterIntro);
        }
    }

    private function disconnectIfInactive():void {
        var diff:int = new Date().time - lastActive;
        if (diff > 500 * 60 * 60) {
            this.disconnect();
            serviceConnection.disconnect();
            removeEventListener("enterFrame", update);
            enableTrackFPS = false;
            RymdenRunt.s.nativeStage.frameRate = 1;
            showErrorDialog("Are you there captain? We lost contact. Last thing we heard on the radio was snoring sounds, you sleeping?", false, function ():void {
                showErrorDialog("Reload the game log in again.", false, function ():void {
                    if (RymdenRunt.isDesktop) {
                        exitDesktop();
                    }
                });
            });
            return;
        }
        TweenMax.delayedCall(1, disconnectIfInactive);
    }

    private function onInitSyncEnemies(m:Message):void {
        shipManager.initSyncEnemies(m);
        synchedEnemies = true;
    }

    private function updateSync():void {
        if (nextSync < time) {
            nextSync = time + 50000;
            refreshClock();
        }
    }

    private function reload():void {
        var roomId:String;
        var joinRoomManager:JoinRoomManager;
        var localMe:Player;
        var solarsystem:String;
        Login.fadeScreen.show();
        roomId = this.roomId;
        joinRoomManager = JoinRoomLocator.getService() as JoinRoomManager;
        if (solarSystem == null) {
            joinRoomManager.joinCurrentSolarSystem();
            return;
        }
        localMe = me;
        solarsystem = this.solarSystem.key;
        if (serviceConnection && serviceConnection.connected) {
            joinRoomManager.desiredRoomId = roomId;
            joinRoomManager.joinGame(solarsystem, {"level": localMe.level});
        } else {
            joinRoomManager.joinServiceRoom(this.serviceRoomId);
            joinRoomManager.addEventListener("joinedServiceRoom", function (param1:starling.events.Event):void {
                joinRoomManager.removeEventListeners("joinedServiceRoom");
                joinRoomManager.desiredRoomId = roomId;
                joinRoomManager.joinGame(solarsystem, {"level": localMe.level});
            });
        }
    }

    private function drawWelcomeText():void {
        var pvpText:String;
        if (isSystemTypeSurvival()) {
            welcomeText.start([["Welcome to " + solarSystem.name + ": " + hud.uberStats.uberRank]]);
        } else {
            welcomeText.start([["Welcome to " + solarSystem.name]]);
        }
        welcomeText.x = stage.stageWidth / 2 - 200;
        welcomeText.y = stage.stageHeight / 2 - 100;
        addChildToOverlay(welcomeText);
        solarSystemData.x = welcomeText.x;
        solarSystemData.y = welcomeText.y + 40;
        solarSystemData.color = Style.COLOR_HIGHLIGHT;
        solarSystemData.width = 450;
        pvpText = "PvP disabled for everyone in this system.";
        if (solarSystem.isPvpSystemInEditor) {
            pvpText = "";
        } else if (isSystemTypeSurvival()) {
            send("uberUpdate");
            pvpText = "You have <FONT COLOR=\'#ffffff\'>" + hud.uberStats.uberLives + "</FONT> lives left, rank <FONT COLOR=\'#ffffff\'>" + hud.uberStats.uberRank + "</FONT>.";
        } else if (isSystemTypeClan()) {
            pvpText = "Private clan instance.";
        } else if (isSystemTypeHostile()) {
            if (solarSystem.pvpLvlCap == 0) {
                pvpText = "PvP enabled for all players.";
            } else if (solarSystem.pvpAboveCap) {
                pvpText = "PvP active, only players above level <FONT COLOR=\'#ffffff\'>" + solarSystem.pvpLvlCap + "</FONT> allowed in room.";
            } else {
                pvpText = "PvP active, only players below level <FONT COLOR=\'#ffffff\'>" + (solarSystem.pvpLvlCap + 1) + "</FONT> allowed in room.";
            }
        }
        solarSystemData.htmlText = pvpText;
        solarSystemData.alpha = 0;
        solarSystemData.touchable = false;
        addChild(solarSystemData);
        TweenMax.to(solarSystemData, 2, {"alpha": 2});
        welcomeText.addEventListener("paragraphFinished", (function ():* {
            var r:Function;
            return r = function (param1:starling.events.Event):void {
                welcomeText.removeEventListener("paragraphFinished", r);
            };
        })());
        welcomeText.addEventListener("animationFinished", (function ():* {
            var r:Function;
            return r = function (param1:starling.events.Event):void {
                var e:starling.events.Event = param1;
                welcomeText.removeEventListener("animationFinished", r);
                TweenMax.to(solarSystemData, 1, {
                    "alpha": 0,
                    "onComplete": function ():void {
                        removeChild(solarSystemData, true);
                        removeChildFromOverlay(welcomeText, true);
                    }
                });
            };
        })());
    }

    private function onFBLike():void {
        send("fbLike");
    }

    private function onInvasion(m:Message):void {
        textManager.createBossSpawnedText(solarSystem.getInvasionText());
        SoundLocator.getService().play("z3gJhEGBNk-cdQCSQ0-AKA");
    }

    private function m_sdf(m:Message):void {
        sendToServiceRoom(m.type);
    }

    private function m_blg(m:Message):void {
        sendMessage(m);
    }

    private function startSystemMusic():void {
        Playlist.play(solarSystem.key);
    }

    override protected function init(e:starling.events.Event = null):void {
        super.init(e);
        dataManager = DataLocator.getService();
        textureManager = TextureLocator.getService();
        tutorial = new Tutorial(this);
        gameStateMachine = new GameStateMachine();
        parallaxManager = new ParallaxManager(this, canvasBackground);
        unitManager = new UnitManager(this);
        shipManager = new ShipManager(this);
        ribbonTrailPool = new RibbonTrailPool(this);
        linePool = new LinePool(this);
        beamLinePool = new BeamLinePool(this);
        groupManager = new GroupManager(this);
        bossManager = new BossManager(this);
        playerManager = new PlayerManager(this);
        emitterManager = new EmitterManager(this);
        weaponManager = new WeaponManager(this);
        projectileManager = new ProjectileManager(this);
        bodyManager = new BodyManager(this);
        spawnManager = new SpawnManager(this);
        turretManager = new TurretManager(this);
        hud = new Hud(this);
        textManager = new TextManager(this);
        dropManager = new DropManager(this);
        commandManager = new CommandManager(this);
        friendManager = new FriendManager(this);
        creditManager = new CreditManager(this);
        deathLineManager = new DeathLineManager(this);
        messagePackHandler = new MessagePackHandler(this);
        queueManager = new QueueManager(this);
        controlZoneManager = new ControlZoneManager(this);
        salesManager = new SalesManager(this);
        dailyManager = new DailyManager(this);
        textManager.loadHandlers();
    }

    override protected function onJoinAndClockSynched(e:starling.events.Event = null):void {
        this.canvas.visible = false;
        Console.write("onJoinAndClockSynched ");
        Game.printTimeStamp("onJoinAndClockSynched");
        super.onJoinAndClockSynched(e);
        try {
            ExternalInterface.addCallback("fbLike", onFBLike);
            ExternalInterface.marshallExceptions = true;
        } catch (e:Error) {
        }
        try {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
        } catch (e:Error) {
        }
        gameStateMachine.clock = clock;
        Console.write("Joining... adding init handlers");
        addMessageHandler("initPlayer", onInitPlayer);
        addMessageHandler("initEnemyPlayers", onInitEnemyPlayers);
        addMessageHandler("initEnemies", onInitEnemies);
        addMessageHandler("initSolarSystem", onInitSolarSystem);
        addMessageHandler("initDrops", onInitDrops);
        addMessageHandler("initServerComplete", onInitServerComplete);
        addMessageHandler("initSyncEnemies", onInitSyncEnemies);
        addMessageHandler("trackEvent", trackServerEvent);
        salesManager.refresh();
        send("initSolarSystem");
    }

    override protected function resize(e:starling.events.Event):void {
        if (stage == null) {
            return;
        }
        super.resize(e);
        if (welcomeText == null) {
            return;
        }
        welcomeText.x = stage.stageWidth / 2 - 200;
        welcomeText.y = stage.stageHeight / 2 - 100;
        if (solarSystemData == null) {
            return;
        }
        solarSystemData.x = welcomeText.x;
        solarSystemData.y = welcomeText.y + 40;
        if (chatInput != null) {
            chatInput.x = stage.stageWidth / 2 - 150;
            chatInput.y = stage.stageHeight - 100;
        }
        if (tutorial != null) {
            tutorial.resize();
        }
    }

    protected function receive(event:flash.events.Event):void {
        Localize.newData(event.target.data);
        showMessageDialog("Texts are updated!");
    }

    protected function notFound(event:flash.events.Event):void {
        showErrorDialog("not found " + event);
    }

    protected function notAllowed(event:SecurityErrorEvent):void {
        showErrorDialog("security error " + event);
    }

    private function updateFPS(event:EnterFrameEvent):void {
        totalTime += event.passedTime;
        elapsedTime += event.passedTime;
        if (++frameCount % (60) == 0) {
            runningFPS = frameCount / totalTime;
            frameCount = 0;
            totalTime = 0;
            if (elapsedTime > 2 * 60) {
                trackFPS();
                elapsedTime = 0;
            }
            if (runningFPS > 50 && quality < 10) {
                quality++;
            } else if (runningFPS < 40 && quality > 0) {
                quality--;
            }
            if (qualityText) {
                qualityText.text = "" + quality;
            }
        }
    }

    private function update(e:EnterFrameEvent):void {
        if (gameStateMachine != null) {
            gameStateMachine.update();
            updateFPS(e);
            if (synchedEnemies) {
                this.canvas.visible = true;
            }
            parallaxManager.update();
            ribbonTrailPool.update();
            textManager.update();
            queueManager.update();
            if (!isTOSPopup) {
                tryOpenTOSPopup();
            }
            if (!Login.isSaleSpinner) {
                tryOpenSaleSpinner();
            }
        }
    }
}
}

