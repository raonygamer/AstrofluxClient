package core.scene {
import camerafocus.StarlingCameraFocus;

import com.greensock.TweenMax;

import core.hud.components.ToolTip;
import core.hud.components.cargo.Cargo;
import core.hud.components.chat.MessageLog;
import core.hud.components.dialogs.PopupConfirmMessage;
import core.hud.components.dialogs.PopupMessage;
import core.particle.Emitter;
import core.states.ISceneState;
import core.states.SceneStateMachine;

import data.Settings;

import debug.Console;

import flash.display.Bitmap;
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import joinRoom.Room;

import playerio.Client;
import playerio.Connection;
import playerio.Message;
import playerio.PlayerIOError;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;

import startSetup.StartSetup;

public class SceneBase extends DisplayObjectContainer implements ISceneState {
    public const CANVAS_BACKGROUND:String = "canvasBackground";
    public const CANVAS_BODIES:String = "canvasBodies";
    public const CANVAS_DROPS:String = "canvasDrops";
    public const CANVAS_SPAWNERS:String = "canvasSpawmers";
    public const CANVAS_TURRETS:String = "canvasTurrets";
    public const CANVAS_BOSSES:String = "canvasBosses";
    public const CANVAS_ENEMY_SHIPS:String = "canvasEnemyShip";
    public const CANVAS_PLAYER_SHIPS:String = "canvasPlayerShip";
    public const CANVAS_PROJECTILES:String = "canvasProjectiles";
    public const CANVAS_EFFECTS:String = "canvasEffects";
    public const CANVAS_TEXTS:String = "canvasTexts";
    public static var settings:Settings;

    public function SceneBase(client:Client, serviceConnection:Connection, connection:Connection, room:Room) {
        this.client = client;
        this.serviceConnection = serviceConnection;
        this.serviceRoomId = serviceConnection.roomId;
        this.connection = connection;
        this.room = room;
        super();
        this.alpha = 0.999;
        super.addChildAt(canvas, 0);
        super.addChildAt(hud, 1);
        super.addChildAt(menu, 2);
        super.addChildAt(overlay, 3);
        canvas.addChild(canvasBackground);
        canvas.addChild(canvasBodies);
        canvas.addChild(canvasSpawners);
        canvas.addChild(canvasTurrets);
        canvas.addChild(canvasBosses);
        canvas.addChild(canvasEnemyShips);
        canvas.addChild(canvasDrops);
        canvas.addChild(canvasPlayerShips);
        canvas.addChild(canvasProjectiles);
        canvas.addChild(canvasEffects);
        canvas.addChild(canvasTexts);
        Login.fadeScreen.repositionScreen(overlay);
        canvas.touchable = false;
        layersInfo = [{
            "name": "canvasBackground",
            "instance": this.canvasBackground,
            "ratio": 1
        }, {
            "name": "canvasBodies",
            "instance": this.canvasBodies,
            "ratio": 0
        }, {
            "name": "canvasSpawmers",
            "instance": this.canvasSpawners,
            "ratio": 0
        }, {
            "name": "canvasTurrets",
            "instance": this.canvasTurrets,
            "ratio": 0
        }, {
            "name": "canvasBosses",
            "instance": this.canvasBosses,
            "ratio": 0
        }, {
            "name": "canvasEnemyShip",
            "instance": this.canvasEnemyShips,
            "ratio": 0
        }, {
            "name": "canvasDrops",
            "instance": this.canvasDrops,
            "ratio": 0
        }, {
            "name": "canvasPlayerShip",
            "instance": this.canvasPlayerShips,
            "ratio": 0
        }, {
            "name": "canvasProjectiles",
            "instance": this.canvasProjectiles,
            "ratio": 0
        }, {
            "name": "canvasEffects",
            "instance": this.canvasEffects,
            "ratio": 0
        }, {
            "name": "canvasTexts",
            "instance": this.canvasTexts,
            "ratio": 0
        }];
        initConnection(connection);
    }
    public var myCargo:Cargo;
    public var room:Room;
    public var client:Client;
    public var serviceConnection:Connection;
    public var canvas:Sprite = new Sprite();
    public var canvasBackground:DisplayObjectContainer = new Sprite();
    public var canvasBodies:Sprite = new Sprite();
    public var canvasDrops:Sprite = new Sprite();
    public var canvasSpawners:Sprite = new Sprite();
    public var canvasTurrets:Sprite = new Sprite();
    public var canvasBosses:Sprite = new Sprite();
    public var canvasEnemyShips:Sprite = new Sprite();
    public var canvasPlayerShips:Sprite = new Sprite();
    public var canvasProjectiles:Sprite = new Sprite();
    public var canvasEffects:Sprite = new Sprite();
    public var canvasTexts:Sprite = new Sprite();
    public var blockHotkeys:Boolean = false;
    public var camera:StarlingCameraFocus;
    public var time:Number = 0;
    public var messageCounter:Dictionary = new Dictionary();
    protected var roomId:String;
    protected var serviceRoomId:String;
    protected var clock:Clock;
    protected var _leaving:Boolean;
    private var clockInitComplete:Boolean;
    private var userJoinedComplete:Boolean;
    private var connection:Connection;
    private var hud:Sprite = new Sprite();
    private var menu:Sprite = new Sprite();
    private var overlay:Sprite = new Sprite();
    private var layersInfo:Array;
    private var connectionHandlers:Dictionary = new Dictionary();
    private var serviceHandlers:Dictionary = new Dictionary();
    private var resizeCallbacks:Array = [];

    protected var _stateMachine:SceneStateMachine;

    public function set stateMachine(value:SceneStateMachine):void {
        _stateMachine = value;
    }

    public function get connected():Boolean {
        if (connection != null && connection.connected) {
            return true;
        }
        return false;
    }

    public function get isLeaving():Boolean {
        return _leaving;
    }

    public function set touchableCanvas(value:Boolean):void {
        canvas.touchable = value;
    }

    override public function addChild(child:DisplayObject):DisplayObject {
        return hud.addChild(child);
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
        return hud.addChildAt(child, index);
    }

    override public function removeChild(child:DisplayObject, dispose:Boolean = false):DisplayObject {
        if (!hud.contains(child)) {
            return null;
        }
        return hud.removeChild(child, dispose);
    }

    public function traceDisplayObjectCounts():void {
        var _loc1_:int = 0;
        _loc1_ += canvasBackground.numChildren;
        _loc1_ += canvasBodies.numChildren;
        _loc1_ += canvasDrops.numChildren;
        _loc1_ += canvasSpawners.numChildren;
        _loc1_ += canvasTurrets.numChildren;
        _loc1_ += canvasBosses.numChildren;
        _loc1_ += canvasEnemyShips.numChildren;
        _loc1_ += canvasPlayerShips.numChildren;
        _loc1_ += canvasProjectiles.numChildren;
        _loc1_ += canvasEffects.numChildren;
        _loc1_ += canvasTexts.numChildren;
        _loc1_ += hud.numChildren;
        _loc1_ += menu.numChildren;
        _loc1_ += overlay.numChildren;
        MessageLog.writeChatMsg("system", "Background: " + canvasBackground.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Bodies: " + canvasBodies.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Drops: " + canvasDrops.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Spawners: " + canvasSpawners.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Turrets: " + canvasTurrets.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Bosses: " + canvasBosses.numChildren, null, "");
        MessageLog.writeChatMsg("system", "EnemyShips: " + canvasEnemyShips.numChildren, null, "");
        MessageLog.writeChatMsg("system", "PlayerShips: " + canvasPlayerShips.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Projectiles: " + canvasProjectiles.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Effects: " + canvasEffects.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Texts: " + canvasTexts.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Hud: " + hud.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Menu: " + menu.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Overlay: " + overlay.numChildren, null, "");
        MessageLog.writeChatMsg("system", "Total: " + _loc1_, null, "");
        TweenMax.delayedCall(1, traceDisplayObjectCounts);
    }

    public function toggleRoamingCanvases(value:Boolean):void {
        canvasEffects.visible = value;
        canvasDrops.visible = value;
        canvasBackground.visible = value;
        canvasProjectiles.visible = value;
        canvasBodies.visible = value;
        canvasSpawners.visible = value;
        canvasTurrets.visible = value;
        canvasBosses.visible = value;
        canvasEnemyShips.visible = value;
        canvasTexts.visible = value;
        hud.visible = value;
    }

    public function enter():void {
        if (stage) {
            init();
        } else {
            addEventListener("addedToStage", init);
        }
    }

    public function execute():void {
    }

    public function exit():void {
        _leaving = true;
        camera = null;
        settings = null;
        myCargo.dispose();
        myCargo = null;
        canvas.removeChild(canvasBackground, true);
        canvas.removeChild(canvasBodies, true);
        canvas.removeChild(canvasBosses, true);
        canvas.removeChild(canvasDrops, true);
        canvas.removeChild(canvasEffects, true);
        canvas.removeChild(canvasEnemyShips, true);
        canvas.removeChild(canvasPlayerShips, true);
        canvas.removeChild(canvasProjectiles, true);
        canvas.removeChild(canvasSpawners, true);
        canvas.removeChild(canvasTexts, true);
        canvas.removeChild(canvasTurrets, true);
        canvasBackground = null;
        canvasBodies = null;
        canvasBosses = null;
        canvasDrops = null;
        canvasEffects = null;
        canvasEnemyShips = null;
        canvasPlayerShips = null;
        canvasProjectiles = null;
        canvasSpawners = null;
        canvasTexts = null;
        canvasTurrets = null;
        Login.fadeScreen.repositionScreen(stage);
        removeChild(canvas, true);
        removeChild(hud, true);
        removeChild(menu, true);
        removeChild(overlay, true);
        canvas = null;
        menu = null;
        hud = null;
        overlay = null;
        for (var _loc2_ in connectionHandlers) {
            removeMessageHandler(_loc2_, connectionHandlers[_loc2_]);
        }
        for (_loc2_ in serviceHandlers) {
            removeServiceMessageHandler(_loc2_, serviceHandlers[_loc2_]);
        }
        if (connection) {
            connection.removeDisconnectHandler(handleDisconnect);
        }
        if (serviceConnection) {
            serviceConnection.removeDisconnectHandler(handleDisconnect);
        }
        TweenMax.killAll();
        ToolTip.disposeAll();
        Starling.juggler.purge();
        stage.removeEventListener("resize", resize);
        for each(var _loc1_ in resizeCallbacks) {
            stage.removeEventListener("resize", _loc1_);
        }
        removeEventListeners();
        removeChildren(0, -1, true);
    }

    public function addChildToBackground(child:DisplayObject):void {
        canvasBackground.addChild(child);
    }

    public function addChildToBackgroundAt(child:DisplayObject, index:int):void {
        canvasBackground.addChildAt(child, index);
    }

    public function removeChildFromBackground(child:DisplayObject, dispose:Boolean = false):void {
        if (!canvasBackground.contains(child)) {
            return;
        }
        canvasBackground.removeChild(child, dispose);
    }

    public function addChildToCanvas(child:DisplayObject):void {
        canvas.addChild(child);
    }

    public function addChildToCanvasAt(child:DisplayObject, index:int):void {
        canvas.addChildAt(child, index);
    }

    public function removeChildFromCanvas(child:DisplayObject, dispose:Boolean = false):void {
        if (!canvas.contains(child)) {
            return;
        }
        canvas.removeChild(child, dispose);
    }

    public function addChildToMenu(child:DisplayObject):void {
        menu.addChild(child);
    }

    public function addChildToMenuAt(child:DisplayObject, index:int):void {
        menu.addChildAt(child, index);
    }

    public function removeChildFromMenu(child:DisplayObject, dispose:Boolean = false):void {
        if (!menu.contains(child)) {
            return;
        }
        menu.removeChild(child, dispose);
    }

    public function addChildToHud(child:DisplayObject):void {
        hud.addChild(child);
    }

    public function removeChildFromHud(child:DisplayObject, dispose:Boolean = false):void {
        if (!hud.contains(child)) {
            return;
        }
        hud.removeChild(child, dispose);
    }

    public function addChildToOverlay(child:DisplayObject, blockHotkeys:Boolean = false):void {
        if (!this.blockHotkeys && blockHotkeys) {
            this.blockHotkeys = true;
        }
        overlay.addChild(child);
    }

    public function addChildToOverlayAt(child:DisplayObject, index:int):void {
        if (index >= overlay.numChildren) {
            index = overlay.numChildren - 1;
        }
        overlay.addChildAt(child, index);
    }

    public function removeChildFromOverlay(child:DisplayObject, dispose:Boolean = false):void {
        this.blockHotkeys = false;
        if (overlay == null || !overlay.contains(child)) {
            return;
        }
        overlay.removeChild(child, dispose);
    }

    public function addToCanvasLayer(canvasName:String, child:DisplayObject):void {
        var _loc5_:int = 0;
        var _loc3_:Object = null;
        var _loc4_:Sprite = null;
        var _loc6_:int = int(layersInfo.length);
        _loc5_ = 0;
        while (_loc5_ < _loc6_) {
            _loc3_ = layersInfo[_loc5_];
            if (canvasName == _loc3_.name) {
                _loc4_ = _loc3_.instance;
                _loc4_.addChild(child);
            }
            _loc5_++;
        }
    }

    public function removeFromCanvasLayer(canvasName:String, child:DisplayObject):void {
        var _loc5_:int = 0;
        var _loc3_:Object = null;
        var _loc4_:Sprite = null;
        var _loc6_:int = int(layersInfo.length);
        _loc5_ = 0;
        while (_loc5_ < _loc6_) {
            _loc3_ = layersInfo[_loc5_];
            if (canvasName == _loc3_.name) {
                _loc4_ = _loc3_.instance;
                _loc4_.removeChild(child);
            }
            _loc5_++;
        }
    }

    public function rpc(type:String, handler:Function, ...rest):void {
        var m:Message;
        var i:int;
        var args:Array = rest;
        connection.addMessageHandler(type, (function ():* {
            var rpcHandler:Function;
            return rpcHandler = function (param1:Message):void {
                connection.removeMessageHandler(type, rpcHandler);
                handler(param1);
            };
        })());
        m = connection.createMessage(type);
        i = 0;
        while (i < args.length) {
            m.add(args[i]);
            i++;
        }
        connection.sendMessage(m);
    }

    public function rpcMessage(mess:Message, handler:Function):void {
        connection.addMessageHandler(mess.type, (function ():* {
            var rpcHandler:Function;
            return rpcHandler = function (param1:Message):void {
                connection.removeMessageHandler(param1.type, rpcHandler);
                handler(param1);
            };
        })());
        connection.sendMessage(mess);
    }

    public function addMessageHandler(type:String, handler:Function):void {
        connectionHandlers[type] = handler;
        connection.addMessageHandler(type, handler);
    }

    public function removeMessageHandler(type:String, handler:Function):void {
        if (connectionHandlers.hasOwnProperty(type)) {
            delete connectionHandlers[type];
        }
        if (connection) {
            connection.removeMessageHandler(type, handler);
        }
    }

    public function increaseMessageCounter(type:String):void {
        if (type == "msgPack") {
            return;
        }
        if (messageCounter[type] == null) {
            messageCounter[type] = 0;
        }
        var _loc2_:* = type;
        var _loc3_:* = messageCounter[_loc2_] + 1;
        messageCounter[_loc2_] = _loc3_;
    }

    public function traceMessageCount():void {
        var _loc1_:Array = [];
        for (var _loc3_ in messageCounter) {
            if (messageCounter[_loc3_] != 0) {
                _loc1_.push({
                    "type": _loc3_,
                    "count": messageCounter[_loc3_]
                });
            }
        }
        _loc1_.sortOn("count", 0x10 | 2);
        for each(var _loc2_ in _loc1_) {
            Console.write(_loc2_.type + ": " + _loc2_.count);
        }
    }

    public function send(type:String, ...rest):void {
        var _loc3_:int = 0;
        var _loc4_:Message = connection.createMessage(type);
        if (rest.length > 0) {
            _loc3_ = 0;
            while (_loc3_ < rest.length) {
                _loc4_.add(rest[_loc3_]);
                _loc3_++;
            }
            sendMessage(_loc4_);
        } else {
            sendMessage(_loc4_);
        }
    }

    public function sendToServiceRoom(type:String, ...rest):void {
        var _loc3_:int = 0;
        var _loc4_:Message = serviceConnection.createMessage(type);
        if (rest.length > 0) {
            _loc3_ = 0;
            while (_loc3_ < rest.length) {
                _loc4_.add(rest[_loc3_]);
                _loc3_++;
            }
            sendMessageToServiceRoom(_loc4_);
        } else {
            sendMessageToServiceRoom(_loc4_);
        }
    }

    public function rpcServiceRoom(type:String, handler:Function, ...rest):void {
        var m:Message;
        var i:int;
        var args:Array = rest;
        serviceConnection.addMessageHandler(type, (function ():* {
            var rpcHandler:Function;
            return rpcHandler = function (param1:Message):void {
                serviceConnection.removeMessageHandler(type, rpcHandler);
                handler(param1);
            };
        })());
        m = serviceConnection.createMessage(type);
        i = 0;
        while (i < args.length) {
            m.add(args[i]);
            i++;
        }
        serviceConnection.sendMessage(m);
    }

    public function addServiceMessageHandler(type:String, handler:Function):void {
        serviceHandlers[type] = handler;
        serviceConnection.addMessageHandler(type, handler);
    }

    public function removeServiceMessageHandler(type:String, handler:Function):void {
        if (serviceHandlers.hasOwnProperty(type)) {
            delete serviceHandlers[type];
        }
        serviceConnection.removeMessageHandler(type, handler);
    }

    public function sendMessageToServiceRoom(m:Message):void {
        serviceConnection.sendMessage(m);
    }

    public function sendMessage(m:Message):void {
        connection.sendMessage(m);
    }

    public function createMessage(type:String, ...rest):Message {
        var _loc3_:int = 0;
        var _loc4_:Message = connection.createMessage(type);
        _loc3_ = 0;
        while (_loc3_ < rest.length) {
            _loc4_.add(rest[_loc3_]);
            _loc3_++;
        }
        return _loc4_;
    }

    public function showErrorDialog(m:String, sendToErrorLog:Boolean = false, callback:Function = null):void {
        var dialog:PopupMessage = new PopupMessage();
        dialog.text = m;
        if (isLeaving) {
            return;
        }
        addChildToOverlay(dialog);
        if (sendToErrorLog) {
            client.errorLog.writeError(m, "", "", {});
        }
        dialog.addEventListener("close", function (param1:Event):void {
            dialogClose(param1);
            if (callback != null) {
                callback();
            }
        });
    }

    public function showConfirmDialog(m:String, callback:Function = null, closeCallback:Function = null):void {
        var dialog:PopupMessage = new PopupConfirmMessage();
        dialog.text = m;
        addChildToOverlay(dialog);
        dialog.addEventListener("close", function (param1:Event):void {
            dialogClose(param1);
            if (closeCallback != null) {
                closeCallback();
            }
        });
        dialog.addEventListener("accept", function (param1:Event):void {
            dialogClose(param1);
            if (callback != null) {
                callback();
            }
        });
    }

    public function showMessageDialog(m:String, callback:Function = null):void {
        var dialog:PopupMessage = new PopupMessage();
        dialog.text = m;
        addChildToOverlay(dialog);
        dialog.addEventListener("close", function (param1:Event):void {
            dialogClose(param1);
            if (callback != null) {
                callback();
            }
        });
    }

    public function infoMessageDialog(m:String):void {
        var _loc2_:PopupMessage = new PopupMessage();
        _loc2_.text = m;
        addChildToOverlay(_loc2_);
        _loc2_.addEventListener("close", dialogClose);
    }

    public function disconnect():void {
        if (connection) {
            connection.disconnect();
        }
    }

    public function draw():void {
        throw new IllegalOperationError("Subclasses of RoomBase has to override draw().");
    }

    public function drawGUIEffect(layer:Bitmap, effect:Vector.<Emitter>):void {
        throw new IllegalOperationError("Subclasses of RoomBase has to override drawGUIEffect().");
    }

    public function refreshClock():void {
        clock.start();
        clock.addEventListener("clockReady", onRefreshClockReady);
    }

    public function addResizeListener(callback:Function):void {
        resizeCallbacks.push(callback);
    }

    public function removeResizeListener(callback:Function):void {
        resizeCallbacks.splice(resizeCallbacks.indexOf(callback), 1);
    }

    public function isSystemTypeClan():Boolean {
        return room.data.systemType == "clan";
    }

    public function isSystemTypeSurvival():Boolean {
        return room.data.systemType == "survival";
    }

    public function isSystemTypeHostile():Boolean {
        return room.data.systemType == "hostile";
    }

    public function isSystemTypeDomination():Boolean {
        return room.data.systemType == "domination";
    }

    public function isSystemTypeDeathMatch():Boolean {
        return room.data.systemType == "deathmatch";
    }

    public function isSystemPvPEnabled():Boolean {
        var _loc1_:String = room.data.systemType;
        return _loc1_ == "hostile" || _loc1_ == "deathmatch" || _loc1_ == "domination" || _loc1_ == "clan" || _loc1_ == "arena";
    }

    protected function handleDisconnect():void {
        Console.write("Disconnected from server");
    }

    protected function getServerTime():Number {
        if (clock != null) {
            time = clock.getServerTime();
            return time;
        }
        return 0;
    }

    protected function userJoined(m:Message):void {
        Console.write("User joined");
    }

    protected function userLeft(m:Message):void {
        Console.write("User left");
    }

    private function initConnection(connection:Connection):void {
        this.connection = connection;
        addMessageHandler("joined", joined);
        addMessageHandler("userJoined", userJoined);
        addMessageHandler("userLeft", userLeft);
        addMessageHandler("duplicateLogin", duplicateLogin);
        addMessageHandler("error", errorFromServer);
        addMessageHandler("message", message);
        addMessageHandler("debug", debugMessage);
        addMessageHandler("*", anyMessage);
        initClock();
    }

    private function joined(m:Message):void {
        Console.write("joined ...");
        roomId = m.getString(0);
        userJoinedComplete = true;
        joinReady();
    }

    private function handleError(error:PlayerIOError):void {
        Console.write(error);
    }

    private function initClock():void {
        StartSetup.showProgressText("Synchronizing");
        Console.write("Synchronising ...");
        clock = new Clock(connection, client);
        clock.start();
        clock.addEventListener("clockReady", onClockReady);
    }

    private function joinReady():void {
        Console.write("joinReady");
        if (clockInitComplete && userJoinedComplete) {
            Console.write("clockinit and userjoined");
            onJoinAndClockSynched();
            connection.addDisconnectHandler(handleDisconnect);
            serviceConnection.addDisconnectHandler(handleDisconnect);
        }
    }

    private function errorFromServer(m:Message):void {
        showErrorDialog(m.getString(0));
    }

    private function message(m:Message):void {
        showErrorDialog(m.getString(0));
    }

    private function anyMessage(m:Message):void {
        Console.write(m);
    }

    private function duplicateLogin(m:Message):void {
        showErrorDialog("You were disconnected because you signed in from another place.");
        exit();
    }

    private function debugMessage(m:Message):void {
        var _loc4_:String = m.getString(0);
        var _loc2_:String = "";
        var _loc3_:int = 1;
        switch (_loc4_) {
            case "update":
                _loc3_;
                while (_loc3_ < m.length) {
                    _loc2_ += m.getInt(_loc3_) + ", ";
                    if (_loc3_ % 10 == 0) {
                        MessageLog.write("update times: " + _loc2_);
                        _loc2_ = "";
                    }
                    _loc3_++;
                }
                return;
            case "artifact":
                MessageLog.write("unique art drop: " + m.getString(1));
                return;
            default:
                MessageLog.write("default: " + m.getString(1));
                return;
        }
    }

    protected function init(e:Event = null):void {
        StartSetup.showProgressText("Init game room");
        removeEventListener("addedToStage", init);
        _leaving = false;
        Console.write("Init Camera...");
        camera = new StarlingCameraFocus(stage, canvas, new Sprite(), layersInfo, false);
        camera.start();
        camera.update();
        stage.addEventListener("resize", resize);
    }

    protected function resize(e:Event):void {
        if (stage == null || stage.starling == null) {
            return;
        }
        if (stage.starling.stage3D == null) {
            return;
        }
        if (stage.starling.context == null) {
            return;
        }
        if (stage.starling.context.driverInfo == "Disposed") {
            return;
        }
        for each(var _loc2_ in resizeCallbacks) {
            _loc2_(e);
        }
        if (camera != null) {
            camera.setFocusPosition(stage.stageWidth / 2, stage.stageHeight / 2);
        }
    }

    protected function onJoinAndClockSynched(e:Event = null):void {
        StartSetup.showProgressText("Joined and synched game room");
        removeEventListener("addedToStage", onJoinAndClockSynched);
        time = clock.time;
    }

    private function onClockReady(e:Event):void {
        clock.removeEventListener("clockReady", onClockReady);
        Console.write("latency: " + clock.latency);
        MessageLog.write("Latency: " + clock.latency);
        StartSetup.showProgressText("Optimizing latency");
        clockInitComplete = true;
        joinReady();
    }

    private function dialogClose(e:Event):void {
        var _loc2_:Sprite = e.target as Sprite;
        if (_loc2_ == null) {
            return;
        }
        if (overlay != null && overlay.contains(_loc2_)) {
            removeChildFromOverlay(_loc2_);
        }
        _loc2_.removeEventListeners();
        _loc2_.dispose();
    }

    private function onRefreshClockReady(e:Event):void {
        clock.removeEventListener("clockReady", onRefreshClockReady);
        if (settings.showLatency) {
            MessageLog.write("Latency: " + Math.round(clock.latency) + " ms");
        }
    }
}
}

