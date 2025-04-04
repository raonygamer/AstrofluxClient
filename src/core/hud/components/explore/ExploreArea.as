package core.hud.components.explore {
import core.credits.CreditManager;
import core.hud.components.Box;
import core.hud.components.Button;
import core.hud.components.CrewDisplayBox;
import core.hud.components.HudTimer;
import core.hud.components.TextBitmap;
import core.hud.components.ToolTip;
import core.hud.components.dialogs.CreditBuyBox;
import core.player.Explore;
import core.scene.Game;
import core.solarSystem.Area;
import core.solarSystem.Body;

import debug.Console;

import flash.utils.Dictionary;
import flash.utils.Timer;

import playerio.Message;

import sound.SoundLocator;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class ExploreArea extends Sprite {
    public static var COLOR:uint = 3225899;

    public function ExploreArea(g:Game, expMap:ExploreMap, body:Body, areaKey:String, teamKey:String, level:Number, rewardLevel:Number, size:int, type:int, specialTypes:Array, name:String, successfulEvents:int, failed:Boolean, finished:Boolean, lootClaimed:Boolean, failTime:Number, finishTime:Number, startTime:Number) {
        this.level = level;
        this.rewardLevel = rewardLevel;
        this.size = size;
        this.type = type;
        this.specialTypes = specialTypes;
        this.name = name;
        this.g = g;
        this.body = body;
        this.areaKey = areaKey;
        this.teamKey = teamKey;
        this.finished = finished;
        this.failed = failed;
        this.successfulEvents = successfulEvents;
        this.totalEvents = size + 4;
        this.lootClaimed = lootClaimed;
        this.failTime = failTime;
        this.finishTime = finishTime;
        this.startTime = startTime;
        super();
        var _loc23_:String = "9iZrZ9p5nEWqrPhkxTYNgA";
        var _loc19_:* = 2868903748;
        exploreMapArea = expMap.getMapArea(areaKey);
        if (type == 0) {
            _loc23_ = "oGIhRDJPa0mDobL-DLecdA";
            _loc19_ = Area.COLORTYPE[0];
        } else if (type == 1) {
            _loc23_ = "xGIhC6OP6k-ynT1KpLQX3w";
            _loc19_ = Area.COLORTYPE[1];
        } else if (type == 2) {
            _loc23_ = "xGIhC6OP6k-ynT1KpLQX3w";
            _loc19_ = Area.COLORTYPE[2];
        }
        var box:core.hud.components.Box = new Box(610, 60, "light", 0.95, 12);
        addChild(box);
        areaName = new TextBitmap();
        areaName.size = 22;
        areaName.format.color = Area.COLORTYPE[type];
        areaName.text = name;
        areaName.x = 4;
        areaName.y = -6;
        addChild(areaName);
        while (areaName.width > 390) {
            areaName.size--;
        }
        var _loc21_:ITextureManager = TextureLocator.getService();
        var _loc20_:int = 0;
        addSkillIcon(_loc21_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[type]), _loc20_, Area.SKILLTYPE[type]);
        for each(var _loc22_ in specialTypes) {
            _loc20_++;
            addSkillIcon(_loc21_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_loc22_]), _loc20_, Area.SPECIALTYPE[_loc22_]);
        }
        actionButton = new Button(null, "DEPLOY TEAM", "positive");
        actionButton.y = 0;
        actionButton.x = 0;
        actionButton.size = 13;
        actionButton.visible = false;
        addChild(actionButton);
        progressBar = new ExploreProgressBar(g, body, progressBarOnComplete, type);
        progressBar.x = 6;
        progressBar.y = 36;
        addChild(progressBar);
        if (successfulEvents == 0 && failTime == 0) {
            handleNotStarted();
        } else if (!lootClaimed && failTime < g.time) {
            handleClaimLoot();
        } else if (successfulEvents < totalEvents && failTime < g.time) {
            handleFailed();
        } else if (finished && successfulEvents == totalEvents && failTime < g.time) {
            handleFinished();
        } else {
            resume();
        }
    }
    public var lootClaimed:Boolean = false;
    public var body:Body;
    public var areaKey:String;
    public var level:Number;
    public var rewardLevel:Number;
    public var size:int;
    public var type:int;
    public var specialTypes:Array;
    private var min:Number = 0;
    private var max:Number = 1;
    private var value:Number = 0;
    private var finished:Boolean = false;
    private var failed:Boolean = false;
    private var successfulEvents:int = 0;
    private var totalEvents:int = 0;
    private var confirmInstantExploreBox:CreditBuyBox;
    private var actionButton:Button;
    private var g:Game;
    private var timer:Timer = new Timer(1000, 1);
    private var startTime:Number = 0;
    private var finishTime:Number = 0;
    private var failTime:Number = 0;
    private var areaTypes:Dictionary = areaTypes;
    private var playerExplores:Dictionary = playerExplores;
    private var areaName:TextBitmap;
    private var teamKey:String = null;
    private var progressBar:ExploreProgressBar;
    private var exploreMapArea:ExploreMapArea;
    private var exploreTimer:HudTimer;
    private var overlay:Sprite;

    private var exploreStartedCallback:Function = null;

    private var _exploring:Boolean = false;

    public function set exploring(value:Boolean):void {
        this._exploring = value;
    }

    public function get success():Boolean {
        if (finished && lootClaimed) {
            return true;
        }
        return false;
    }

    public function get failedValue():Number {
        return (failTime - startTime) / (finishTime - startTime);
    }

    override public function dispose():void {
        if (exploreMapArea) {
            exploreMapArea.dispose();
        }
        super.dispose();
    }

    public function addSkillIcon(txt:Texture, i:int, toolTipText:String):void {
        var _loc4_:Image = new Image(txt);
        _loc4_.x = areaName.x + areaName.width + 10 + 20 * i;
        _loc4_.y = 4;
        var _loc5_:Sprite = new Sprite();
        _loc5_.addChild(_loc4_);
        new ToolTip(g, _loc5_, toolTipText, null, "skill");
        addChild(_loc5_);
    }

    public function adjustTimeEstimate(value:Number):Number {
        if (successfulEvents > 0) {
            value = value * (totalEvents - successfulEvents) / totalEvents;
        } else if (failTime != 0 && failTime > g.time) {
            value *= 1 - (g.time - startTime) / (finishTime - startTime);
        }
        return value;
    }

    public function updateExploreObj():void {
        var _loc1_:Explore = g.me.getExploreByKey(areaKey);
        if (_loc1_ != null) {
            _loc1_.lootClaimed = true;
            _loc1_.finished = true;
            _loc1_.failed = true;
            _loc1_.finished = true;
        }
    }

    public function updateState(lootClaimed:Boolean):void {
        this.lootClaimed = lootClaimed;
        if (successfulEvents < totalEvents) {
            failed = true;
        }
        if (successfulEvents == totalEvents) {
            finished = true;
        }
        updateExploreObj();
        if (successfulEvents == 0 && !failed && failTime < g.time) {
            handleNotStarted();
        } else if (!lootClaimed && failTime < g.time) {
            handleClaimLoot();
        } else if (successfulEvents < totalEvents && failTime < g.time) {
            handleFailed();
        } else if (finished && successfulEvents == totalEvents && failTime < g.time) {
            handleFinished();
        } else {
            resume();
        }
    }

    public function handleFinished():void {
        Console.write("handle finished");
        removeChild(actionButton);
        progressBar.setMax();
        var boxFinished:core.hud.components.Box = new Box(610, 60, "normal", 0.8, 13);
        var _loc1_:TextField = new TextField(610, 60, "EXPLORED!", new TextFormat("font13", 20, 0xffffff));
        boxFinished.x = 0;
        boxFinished.y = 0;
        addChild(boxFinished);
        addChild(_loc1_);
        removeChild(progressBar);
    }

    public function startExplore(selectedTeams:Vector.<CrewDisplayBox>, callback:Function = null):void {
        exploreStartedCallback = callback;
        requestStartExplore(selectedTeams);
    }

    public function update():void {
        exploreMapArea.update();
        progressBar.update();
        if (exploreTimer != null) {
            exploreTimer.update();
        }
    }

    public function stopEffect():void {
        progressBar.stopEffect();
    }

    private function handleStarted():void {
        adjustActionButton();
        actionButton.visible = false;
    }

    private function adjustActionButton():void {
        actionButton.x = progressBar.x + progressBar.width + 10;
        actionButton.y = progressBar.y - 6;
        actionButton.visible = true;
    }

    private function progressBarOnComplete():void {
        Console.write("progressBarOnComplete");
        actionButton.visible = true;
        actionButton.callback = showRewardScreen;
        if (exploreTimer != null && contains(exploreTimer)) {
            removeChild(exploreTimer);
        }
        actionButton.text = "CLAIM REWARD";
        adjustActionButton();
        actionButton.enabled = true;
    }

    private function handleClaimLoot():void {
        Console.write("handle claim loot");
        progressBarOnComplete();
        progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1), successfulEvents < totalEvents);
    }

    private function handleFailed():void {
        Console.write("handle failed");
        actionButton.visible = true;
        progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1), true);
        actionButton.callback = showSelectTeam;
        actionButton.text = "DEPLOY TEAM";
        adjustActionButton();
        actionButton.enabled = true;
    }

    private function handleNotStarted():void {
        Console.write("hadnle not started");
        actionButton.visible = true;
        progressBar.setValueAndEffect(0);
        actionButton.callback = showSelectTeam;
        actionButton.text = "DEPLOY TEAM";
        adjustActionButton();
        actionButton.enabled = true;
    }

    private function requestStartExplore(teams:Vector.<CrewDisplayBox> = null):void {
        if (teams == null) {
            return;
        }
        var _loc2_:String = "";
        for each(var _loc3_ in teams) {
            if (_loc2_ != "") {
                _loc2_ += " ";
            }
            _loc2_ += _loc3_.key;
        }
        actionButton.enabled = false;
        g.rpc("startExplore", exploreStarted, areaKey, teams.length, _loc2_);
    }

    private function resume():void {
        Console.write("resume");
        progressBar.start(startTime, finishTime, failTime);
        if (exploreTimer != null && contains(exploreTimer)) {
            exploreTimer.stop();
            removeChild(exploreTimer);
        }
        exploreTimer = new HudTimer(g);
        exploreTimer.start(startTime, finishTime);
        exploreTimer.x = 520;
        exploreTimer.y = 0;
        actionButton.callback = instant;
        actionButton.text = " Speed up! ";
        actionButton.enabled = true;
        adjustActionButton();
        addChild(exploreTimer);
    }

    private function exploreStarted(m:Message):void {
        var _loc3_:Explore = null;
        var _loc5_:int = 0;
        var _loc6_:int = 0;
        var _loc7_:String = null;
        var _loc4_:String = null;
        if (m.getBoolean(0)) {
            if (exploreStartedCallback != null) {
                exploreStartedCallback();
            }
            g.tutorial.showExploreAdvice2();
            _loc3_ = g.me.getExploreByKey(areaKey);
            if (_loc3_ == null) {
                _loc3_ = new Explore();
            }
            startTime = m.getNumber(1);
            finishTime = m.getNumber(2);
            failTime = m.getNumber(3);
            successfulEvents = m.getNumber(4);
            _loc3_.areaKey = areaKey;
            _loc3_.bodyKey = body.key;
            _loc3_.finished = false;
            _loc3_.failTime = failTime;
            _loc3_.startTime = startTime;
            _loc3_.finishTime = finishTime;
            _loc3_.lootClaimed = false;
            _loc3_.successfulEvents = successfulEvents;
            _loc3_.startEvent = 0;
            g.me.explores.push(_loc3_);
            progressBar.start(startTime, finishTime, failTime);
            if (exploreTimer != null && contains(exploreTimer)) {
                exploreTimer.stop();
                removeChild(exploreTimer);
            }
            exploreTimer = new HudTimer(g);
            exploreTimer.start(startTime, finishTime);
            exploreTimer.x = 520;
            exploreTimer.y = 0;
            actionButton.callback = instant;
            actionButton.visible = true;
            actionButton.text = " Speed up! ";
            actionButton.enabled = true;
            addChild(exploreTimer);
            if (contains(actionButton)) {
                removeChild(actionButton);
            }
            addChild(actionButton);
            _loc5_ = m.getInt(5);
            _loc6_ = 6;
            while (_loc6_ < 7 + (_loc5_ - 1) * 5) {
                _loc7_ = m.getString(_loc6_);
                for each(var _loc2_ in g.me.crewMembers) {
                    if (_loc2_.key == _loc7_) {
                        _loc2_.solarSystem = m.getString(_loc6_ + 1);
                        _loc2_.body = m.getString(_loc6_ + 2);
                        _loc2_.area = m.getString(_loc6_ + 3);
                        _loc2_.fullLocation = m.getString(_loc6_ + 4);
                        break;
                    }
                }
                _loc6_ += 5;
            }
            exploreMapArea.explore = _loc3_;
        } else {
            actionButton.enabled = true;
            _loc4_ = m.getString(1);
            if (_loc4_ == "occupied") {
                g.showErrorDialog("One of crew members is occupied exploring somewhere else.");
                return;
            }
            if (_loc4_ == "injured") {
                g.showErrorDialog("One of crew members is injured.");
                return;
            }
            if (_loc4_ == "training") {
                g.showErrorDialog("One of crew members is busy training.");
                return;
            }
            if (_loc4_ == "explored") {
                g.showErrorDialog("You can\'t explore this area.");

            }
        }
    }

    private function instantExplore(m:Message):void {
        if (!m.getBoolean(0)) {
            actionButton.enabled = true;
            g.showErrorDialog(m.getString(1));
            return;
        }
        var _loc2_:int = CreditManager.getCostInstant(size);
        Game.trackEvent("used flux", "instant explore", "size " + size, _loc2_);
        SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
        g.creditManager.refresh();
        g.showErrorDialog("Explore completed!");
        var _loc3_:Explore = g.me.getExploreByKey(areaKey);
        _loc3_.finishTime = m.getNumber(1);
        finishTime = _loc3_.finishTime;
        _loc3_.failTime = m.getNumber(2);
        failTime = _loc3_.failTime;
        _loc3_.successfulEvents = m.getInt(3);
        successfulEvents = _loc3_.successfulEvents;
        _loc3_.finished = true;
        finished = true;
        _loc3_.lootClaimed = false;
        lootClaimed = false;
        if (contains(exploreTimer)) {
            exploreTimer.stop();
            removeChild(exploreTimer);
        }
        progressBar.stop();
        progressBar.setValueAndEffect(1, false);
        progressBarOnComplete();
        exploreMapArea.explore = _loc3_;
    }

    private function sendInstant():void {
        g.rpc("buyInstantExplore", instantExplore, areaKey);
    }

    private function showSelectTeam(e:TouchEvent = null):void {
        dispatchEvent(new Event("showSelectTeam"));
    }

    private function showRewardScreen(e:TouchEvent = null):void {
        actionButton.enabled = false;
        dispatchEvent(new Event("showRewardScreen"));
    }

    private function instant(e:TouchEvent = null):void {
        g.creditManager.refresh(function ():void {
            var _loc1_:int = CreditManager.getCostInstant(size);
            confirmInstantExploreBox = new CreditBuyBox(g, _loc1_, "Are you sure you want to buy instant explore?");
            g.addChildToOverlay(confirmInstantExploreBox);
            confirmInstantExploreBox.addEventListener("accept", onAccept);
            confirmInstantExploreBox.addEventListener("close", onClose);
        });
    }

    private function onAccept(e:Event):void {
        sendInstant();
        confirmInstantExploreBox.removeEventListener("accept", onAccept);
        confirmInstantExploreBox.removeEventListener("close", onClose);
    }

    private function onClose(e:Event):void {
        actionButton.enabled = true;
        confirmInstantExploreBox.removeEventListener("accept", onAccept);
        confirmInstantExploreBox.removeEventListener("close", onClose);
    }

    private function send(e:TouchEvent):void {
        g.removeChildFromOverlay(overlay);
        actionButton.enabled = true;
        showSelectTeam();
    }
}
}

