package core.states.gameStates.missions {
import com.greensock.TweenMax;
import com.greensock.easing.Circ;

import core.credits.CreditManager;
import core.drops.DropBase;
import core.drops.DropItem;
import core.hud.components.Button;
import core.hud.components.GradientBox;
import core.hud.components.Text;
import core.hud.components.ToolTip;
import core.hud.components.dialogs.CreditBuyBox;
import core.player.Mission;
import core.scene.Game;
import core.states.gameStates.RoamingState;
import core.states.gameStates.ShopState;

import data.DataLocator;
import data.IDataManager;

import generics.Localize;

import playerio.Message;

import sound.ISound;
import sound.SoundLocator;

import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.text.TextFormat;

import textures.ITextureManager;
import textures.TextureLocator;

public class MissionView extends Sprite {
    public static function fixText(g:Game, missionType:Object, s:String):String {
        if (missionType.value != null) {
            s = s.replace("[amount]", "<font color=\'#ffffff\'>" + missionType.value + "</font>");
        }
        s = s.replace("[player]", g.me.name);
        s = s.replace("[h]", "<font color=\'#ffffff\'>");
        return s.replace("[/h]", "</font>");
    }

    public function MissionView(game:Game, mission:Mission, boxWidth:int) {
        super();
        this.mission = mission;
        this.g = game;
        this.boxWidth = boxWidth;
        this.textureManager = TextureLocator.getService();
    }
    private var mission:Mission;
    private var g:Game;
    private var heading:Text;
    private var description:Text;
    private var missionType:Object;
    private var box:GradientBox;
    private var dataManager:IDataManager;
    private var fluxIcon:Image;
    private var dropBase:DropBase;
    private var boxWidth:int;
    private var textureManager:ITextureManager;
    private var timeLeft:Text = new Text();

    public function init():void {
        var instance:MissionView;
        var rewardY:Number;
        var cancelButton:Button;
        if (mission.majorType == "time") {
            box = new GradientBox(boxWidth, 160, 0, 1, 15, 0xff8844);
        } else {
            box = new GradientBox(boxWidth, 160, 0, 1, 15, 0x88ff88);
        }
        instance = this;
        box.load();
        addChild(box);
        dataManager = DataLocator.getService();
        missionType = dataManager.loadKey("MissionTypes", mission.missionTypeKey);
        addHeading();
        rewardY = addReward();
        addDescription();
        addRewardButton(rewardY);
        if (mission.majorType == "time" && !mission.finished) {
            cancelButton = new Button(function ():void {
                g.creditManager.refresh(function ():void {
                    var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostSkipMission(), Localize.t("Skip this timed mission and receive a new one!"));
                    g.addChildToOverlay(confirmBuyWithFlux);
                    confirmBuyWithFlux.addEventListener("accept", function (param1:Event):void {
                        var e:Event = param1;
                        g.rpc("skipMission", function (param1:Message):void {
                            if (param1.getBoolean(0)) {
                                Game.trackEvent("used flux", "skipped mission", "player level " + g.me.level, CreditManager.getCostSkipMission());
                                removeAndRedrawList();
                                g.creditManager.refresh();
                            } else {
                                g.showErrorDialog(param1.getString(1), false);
                            }
                        }, mission.id);
                        confirmBuyWithFlux.removeEventListeners();
                    });
                    confirmBuyWithFlux.addEventListener("close", function (param1:Event):void {
                        confirmBuyWithFlux.removeEventListeners();
                        cancelButton.enabled = true;
                        g.removeChildFromOverlay(confirmBuyWithFlux, true);
                    });
                });
            }, Localize.t("Skip Mission"), "normal", 12);
            cancelButton.x = width - cancelButton.width - box.padding * 2;
            cancelButton.y = height - cancelButton.height - box.padding * 2;
            addChild(cancelButton);
        }
        instance[missionType.type]();
    }

    public function level():void {
    }

    public function transport():void {
        var _loc4_:Object = null;
        var _loc1_:Text = null;
        var _loc2_:Vector.<Object> = new Vector.<Object>();
        var _loc3_:int = 1;
        var _loc6_:String = description.htmlText;
        for each(var _loc5_ in missionType.addedBodies) {
            _loc4_ = dataManager.loadKey("Bodies", _loc5_);
            _loc2_.push(_loc4_);
            _loc6_ = _loc6_.replace("[location" + _loc3_ + "]", "<font color=\'#ffffff\'>" + _loc4_.name + "</font>");
            _loc3_++;
        }
        description.htmlText = _loc6_;
        _loc3_ = 1;
        for each(var _loc7_ in _loc2_) {
            _loc1_ = new Text();
            _loc1_.size = 13;
            _loc1_.x = 0;
            _loc1_.y = description.height + 10 + _loc3_ * 20;
            if (_loc3_ == 1) {
                _loc1_.htmlText = Localize.t("Go to") + ": <font color=\'#ae7108\'>" + _loc7_.name;
            } else {
                _loc1_.htmlText = Localize.t("Then to") + ": <font color=\'#ae7108\'>" + _loc7_.name;
            }
            box.addChild(_loc1_);
            _loc3_++;
        }
    }

    public function update():void {
        if (mission.majorType == "time") {
            drawExpireTime();
        }
    }

    private function kill():void {
        var _loc1_:* = this;
        _loc1_[missionType.subtype]();
    }

    private function pvpStart():void {
    }

    private function player():void {
        var _loc1_:Text = new Text();
        _loc1_.size = 13;
        _loc1_.x = 0;
        _loc1_.y = 145;
        _loc1_.htmlText = Localize.t("Killed") + ": <font color=\'#ae0808\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc1_);
    }

    private function frenzy():void {
        var _loc1_:Text = new Text();
        _loc1_.size = 13;
        _loc1_.x = 0;
        _loc1_.y = 145;
        _loc1_.htmlText = Localize.t("Longest killing frenzy") + ": <font color=\'#ae0808\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc1_);
    }

    private function explore():void {
    }

    private function pickup():void {
        var _loc2_:Object = null;
        var _loc3_:Image = null;
        if (missionType.item != null) {
            _loc2_ = dataManager.loadKey("Commodities", missionType.item);
            _loc3_ = new Image(textureManager.getTextureGUIByKey(_loc2_.bitmap));
            _loc3_.y = description.y + description.height + 20;
            box.addChild(_loc3_);
        }
        var _loc1_:Text = new Text();
        _loc1_.size = 13;
        _loc1_.x = 0;
        _loc1_.y = 145;
        _loc1_.htmlText = Localize.t("Picked up") + ": <font color=\'#08ae08\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc1_);
    }

    private function recycle():void {
        var _loc2_:Object = null;
        var _loc3_:Image = null;
        if (missionType.item != null) {
            _loc2_ = dataManager.loadKey("Commodities", missionType.item);
            _loc3_ = new Image(textureManager.getTextureGUIByKey(_loc2_.bitmap));
            _loc3_.y = description.y + description.height + 20;
            box.addChild(_loc3_);
        }
        var _loc1_:Text = new Text();
        _loc1_.size = 13;
        _loc1_.x = 0;
        _loc1_.y = 145;
        _loc1_.htmlText = Localize.t("Recycled") + ": <font color=\'#08ae08\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc1_);
    }

    private function reputation():void {
    }

    private function boss():void {
        var _loc1_:Text = new Text();
        _loc1_.size = 13;
        _loc1_.x = 0;
        _loc1_.y = 145;
        _loc1_.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / 1";
        box.addChild(_loc1_);
    }

    private function ship():void {
        var _loc1_:Object = null;
        var _loc11_:Object = null;
        var _loc8_:Object = null;
        var _loc6_:MovieClip = null;
        var _loc10_:Vector.<Object> = new Vector.<Object>();
        for each(var _loc12_ in missionType.addedEnemies) {
            _loc1_ = dataManager.loadKey("Enemies", _loc12_);
            _loc11_ = {};
            if (_loc1_ != null) {
                _loc8_ = dataManager.loadKey("Ships", _loc1_.ship);
                _loc11_.ship = _loc8_;
                _loc11_.enemy = _loc1_;
                _loc10_.push(_loc11_);
            }
        }
        var _loc5_:String = "";
        var _loc3_:Number = 0;
        var _loc7_:int = 5;
        var _loc9_:int = description.y + description.height + 20;
        for each(var _loc4_ in _loc10_) {
            if (_loc5_ != _loc4_.ship.bitmap) {
                _loc5_ = _loc4_.ship.bitmap;
                _loc6_ = new MovieClip(textureManager.getTexturesMainByKey(_loc4_.ship.bitmap));
                _loc6_.x = _loc7_;
                _loc6_.y = _loc9_;
                _loc7_ += _loc6_.width + 15;
                if (_loc7_ > 400) {
                    _loc9_ += _loc6_.height + 5;
                    _loc7_ = 5;
                }
                new ToolTip(g, _loc6_, _loc4_.enemy.name, null, "missionView");
                _loc3_ = Math.max(_loc3_, _loc6_.height);
                box.addChild(_loc6_);
            }
        }
        var _loc2_:Text = new Text();
        _loc2_.size = 13;
        _loc2_.x = 0;
        _loc2_.y = _loc9_ + _loc3_ + 20;
        _loc2_.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc2_);
    }

    private function spawner():void {
        var _loc3_:String = null;
        var _loc2_:Text = new Text();
        _loc2_.size = 13;
        _loc2_.x = 70;
        _loc2_.y = 125;
        _loc2_.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / " + missionType.value;
        box.addChild(_loc2_);
        if (missionType.hasOwnProperty("bitmap")) {
            _loc3_ = missionType.bitmap;
        } else {
            _loc3_ = "MSpsdfGpTU2S9DE5B393Tw";
        }
        var _loc1_:MovieClip = new MovieClip(textureManager.getTexturesMainByKey(_loc3_));
        _loc1_.x = 0;
        _loc1_.y = 110;
        _loc1_.scaleX = _loc1_.scaleY = 0.7;
        box.addChild(_loc1_);
    }

    private function addReward():Number {
        var x:int;
        var rewardY:int;
        var d:DropItem;
        var fluxText:Text;
        var artifactText:Text;
        var artifactIcon:Image;
        var t:ToolTip;
        var xpText:TextField;
        var s:String;
        var boostXp:int;
        var toolTipText:String;
        var xpBoostIcon:Image;
        var repImg:String;
        var reputationIcon:Image;
        var reputationText:Text;
        dropBase = g.dropManager.getDropItems(missionType.drop, g, mission.created);
        var rewardHeading:Text = new Text();
        rewardHeading.color = 11432200;
        rewardHeading.size = 14;
        rewardHeading.text = Localize.t("REWARD").toUpperCase();
        rewardHeading.x = 560;
        rewardHeading.y = 10;
        rewardHeading.alignCenter();
        box.addChild(rewardHeading);
        x = rewardHeading.x;
        rewardY = rewardHeading.y + 25;
        if (dropBase == null) {
            g.showErrorDialog(Localize.t("Error with mission") + ": " + missionType.title, true);
            return 0;
        }
        for each(d in dropBase.items) {
            rewardY = addRewardItem(d, x, rewardY);
        }
        rewardY += 5;
        if (dropBase.flux > 0) {
            fluxText = new Text();
            fluxText.color = 0xffffff;
            fluxText.size = 16;
            fluxText.alignCenter();
            fluxText.text = "" + dropBase.flux;
            fluxText.x = x;
            fluxText.y = rewardY;
            fluxIcon = new Image(textureManager.getTextureGUIByTextureName("credit_small.png"));
            fluxIcon.x = x - fluxText.width / 2 - fluxIcon.width / 2 - 4;
            fluxIcon.y = rewardY + fluxText.height / 2 - fluxIcon.height / 2 - 2;
            fluxText.x += fluxIcon.width / 2 - 2;
            addChild(fluxIcon);
            addChild(fluxText);
            rewardY += 20;
        }
        if (dropBase.artifactAmount > 0) {
            artifactText = new Text();
            artifactText.color = 0xffffff;
            artifactText.size = 16;
            artifactText.alignCenter();
            artifactText.text = "" + dropBase.artifactAmount;
            artifactText.x = x;
            artifactText.y = rewardY;
            artifactIcon = new Image(textureManager.getTextureGUIByTextureName("artifact_icon.png"));
            artifactIcon.x = x - artifactText.width / 2 - artifactIcon.width / 2 - 4;
            artifactIcon.y = rewardY + artifactText.height / 2 - artifactIcon.height / 2 - 2;
            artifactText.x += artifactIcon.width / 2 - 2;
            addChild(artifactIcon);
            addChild(artifactText);
            rewardY += 20;
            t = new ToolTip(g, artifactIcon, Localize.t("[amount]x (lvl [level]) artifacts").replace("[amount]", dropBase.artifactAmount).replace("[level]", dropBase.artifactLevel), null, "missionView");
        }
        if (dropBase.xp > 0) {
            xpText = new TextField(100, 30, "", new TextFormat("DAIDRR"));
            xpText.format.color = 0xffffff;
            xpText.autoSize = "bothDirections";
            xpText.isHtmlText = true;
            dropBase.xp = 0.75 * dropBase.xp + 0.5;
            s = Localize.t("XP") + ": " + dropBase.xp;
            boostXp = Math.ceil(dropBase.xp * 0.3);
            if (g.me.hasExpBoost) {
                s += " <FONT COLOR=\'#88ff88\'>(+" + boostXp + ")</FONT>";
                xpText.text = s;
                new ToolTip(g, xpText, Localize.t("You have XP BOOST enabled!."), null, "missionView");
            } else {
                s += " <FONT COLOR=\'#333333\'>(+" + boostXp + ")</FONT>";
                xpText.text = s;
                new ToolTip(g, xpText, Localize.t("You don\'t have any XP BOOST active, get one if you want to gain <FONT COLOR=\'#FFFFFF\'>[xpBoost]%</FONT> more XP.").replace("[xpBoost]", 0.3 * 100), null, "missionView");
            }
            xpText.x = x;
            xpText.y = rewardY + 5;
            xpText.pivotX = xpText.width / 2;
            if (!g.me.hasExpBoost) {
                toolTipText = Localize.t("Get XP BOOST now!");
                xpBoostIcon = new Image(textureManager.getTextureGUIByTextureName("button_pay"));
                xpBoostIcon.useHandCursor = true;
                xpBoostIcon.addEventListener("touch", function (param1:TouchEvent):void {
                    if (param1.getTouch(xpBoostIcon, "ended")) {
                        g.enterState(new RoamingState(g));
                        g.enterState(new ShopState(g, "xpBoost"));
                    }
                });
                xpBoostIcon.x = xpText.x + xpText.width / 2 + 5;
                xpBoostIcon.y = xpText.y;
                addChild(xpBoostIcon);
                new ToolTip(g, xpBoostIcon, toolTipText, null, "shopIcons");
            }
            addChild(xpText);
            rewardY += 20;
        }
        if (mission.majorType == "time") {
            timeLeft.font = "Verdana";
            timeLeft.color = 11432200;
            timeLeft.size = 12;
            timeLeft.x = heading.x + heading.width + 20;
            timeLeft.y = heading.y;
            addChild(timeLeft);
        }
        if (dropBase.reputation > 0) {
            if (g.me.reputation > 0) {
                repImg = "police_icon.png";
            } else {
                repImg = "pirate_icon.png";
            }
            reputationIcon = new Image(textureManager.getTextureGUIByTextureName(repImg));
            reputationIcon.scaleX = 0.5;
            reputationIcon.scaleY = 0.5;
            reputationText = new Text();
            reputationText.color = 0xffffff;
            reputationText.size = 16;
            reputationText.alignCenter();
            reputationText.text = "" + dropBase.reputation;
            reputationText.y = rewardY;
            reputationIcon.x = x - reputationText.width / 2 - reputationText.width / 2;
            reputationIcon.y = rewardY + reputationText.height / 2 - reputationText.height / 2 + 3;
            reputationText.x = x + reputationText.width / 2 - 2;
            addChild(reputationIcon);
            addChild(reputationText);
            rewardY += 20;
        }
        return rewardY;
    }

    private function drawExpireTime():void {
        var _loc1_:int = (mission.expires - g.time) / 1000;
        if (_loc1_ < 0) {
            removeAndRedrawList();
            return;
        }
        if (timeLeft != null) {
            timeLeft.htmlText = "" + _loc1_;
        }
        var _loc2_:int = Math.floor(_loc1_ / (60 * 60));
        _loc1_ -= _loc2_ * (60) * (60);
        var _loc5_:int = Math.floor(_loc1_ / (60));
        _loc1_ -= _loc5_ * (60);
        var _loc3_:int = Math.floor(_loc1_);
        var _loc6_:String = _loc2_ < 10 ? "0" + _loc2_ : "" + _loc2_;
        var _loc7_:String = _loc5_ < 10 ? "0" + _loc5_ : "" + _loc5_;
        var _loc4_:String = _loc3_ < 10 ? "0" + _loc3_ : "" + _loc3_;
        if (timeLeft != null) {
            timeLeft.htmlText = "(" + Localize.t("expires in") + ": " + _loc6_ + ":" + _loc7_ + ":" + _loc4_ + ")";
        }
    }

    private function addRewardItem(item:DropItem, x:int, y:int):int {
        var _loc7_:Image = null;
        var _loc4_:Text = new Text();
        _loc4_.color = 0xffffff;
        _loc4_.size = 14;
        _loc4_.alignCenter();
        _loc4_.x = x;
        _loc4_.y = y;
        var _loc8_:String = item.name;
        _loc8_.toLocaleUpperCase();
        _loc4_.htmlText = item.quantity.toString();
        while (_loc4_.width > 160) {
            _loc4_.size--;
        }
        var _loc5_:Sprite = new Sprite();
        if (item.table == "Skins") {
            _loc7_ = new Image(textureManager.getTexturesMainByKey(item.bitmapKey)[0]);
        } else {
            _loc7_ = new Image(textureManager.getTextureGUIByKey(item.bitmapKey));
        }
        if (_loc7_.height > 30) {
            _loc7_.scaleX = _loc7_.scaleY = 20 / _loc7_.height;
        }
        _loc7_.x = x - _loc4_.width / 2 - _loc7_.width / 2 - 4;
        _loc7_.y = y + _loc4_.height / 2 - _loc7_.height / 2 - 2;
        _loc4_.x += _loc7_.width / 2 - 2;
        var _loc6_:ToolTip = new ToolTip(g, _loc5_, _loc8_, null, "missionView");
        _loc5_.addChild(_loc7_);
        box.addChild(_loc5_);
        box.addChild(_loc4_);
        return y + _loc7_.height + 5;
    }

    private function addRewardButton(rewardY:Number):void {
        var _loc2_:Button = new Button(tryCollectReward, Localize.t("COLLECT REWARD").toUpperCase(), "positive");
        _loc2_.visible = mission.finished;
        if (box.height < rewardY + _loc2_.height + box.padding * 2) {
            box.height = rewardY + _loc2_.height + box.padding;
        }
        _loc2_.x = box.width - _loc2_.width - box.padding * 2;
        _loc2_.y = height - _loc2_.height - box.padding * 2;
        addChild(_loc2_);
    }

    private function addHeading():void {
        heading = new Text();
        heading.y = -5;
        heading.color = 0xffffff;
        heading.size = 13;
        var _loc1_:String = missionType.title;
        heading.htmlText = fixText(g, missionType, _loc1_);
        addChild(heading);
    }

    private function addDescription():void {
        description = new Text();
        description.font = "Verdana";
        description.color = 0xa1a1a1;
        description.size = 12;
        description.wordWrap = true;
        description.width = 380;
        var _loc1_:String = missionType.description;
        if (mission.finished && missionType.completeDescription != null) {
            if (missionType.hasOwnProperty("nextMission")) {
                description.htmlText = Localize.t("Mission Completed! Click claim reward to proceed to next step.");
            } else {
                description.htmlText = missionType.completeDescription;
            }
        } else {
            description.htmlText = fixText(g, missionType, _loc1_);
        }
        description.y = 22;
        if (description.height > 90) {
            description.width = 460;
        }
        if (description.height > 90) {
            description.size--;
        }
        addChild(description);
    }

    private function rewardArrived(m:Message):void {
        var _loc3_:Boolean = m.getBoolean(0);
        if (!_loc3_) {
            g.showErrorDialog(Localize.t("Mission not complete."));
            return;
        }
        if (missionType.majorType == "static") {
            Game.trackEvent("missions", "static", missionType.title);
        } else if (missionType.majorType == "time") {
            Game.trackEvent("missions", "timed", missionType.title);
        }
        g.me.removeMission(mission);
        g.creditManager.refresh();
        for each(var _loc2_ in dropBase.items) {
            transferItemToCargo(_loc2_);
        }
        g.hud.cargoButton.update();
        g.hud.resourceBox.update();
        g.hud.cargoButton.flash();
        animateCollectReward();
    }

    private function removeAndRedrawList():void {
        var tween:com.greensock.TweenMax = TweenMax.to(this, 0.3, {
            "alpha": 0,
            "onComplete": redrawParentList,
            "ease": Circ.easeIn
        });
    }

    private function redrawParentList():void {
        g.me.removeMission(mission);
        dispatchEventWith("reload");
    }

    private function animateCollectReward():void {
        var tween:com.greensock.TweenMax = TweenMax.to(this, 0.3, {
            "alpha": 0,
            "onComplete": collectReward,
            "ease": Circ.easeIn
        });
        var _loc1_:ISound = SoundLocator.getService();
        _loc1_.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q");
    }

    private function collectReward():void {
        dispatchEventWith("animateCollectReward", true);
        g.textManager.createMissionCompleteText();
    }

    private function transferItemToCargo(d:Object):void {
        var _loc4_:String = d.table;
        var _loc2_:String = d.item;
        var _loc3_:Number = Number(d.quantity);
        g.myCargo.addItem(_loc4_, _loc2_, _loc3_);
    }

    private function tryCollectReward(e:TouchEvent):void {
        g.rpc("requestMissionReward", rewardArrived, mission.id, mission.majorType);
    }
}
}

