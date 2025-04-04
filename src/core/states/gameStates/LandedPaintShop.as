package core.states.gameStates {
import core.GameObject;
import core.credits.CreditManager;
import core.hud.components.Button;
import core.hud.components.Text;
import core.hud.components.dialogs.CreditBuyBox;
import core.hud.components.dialogs.PopupConfirmMessage;
import core.particle.Emitter;
import core.particle.EmitterFactory;
import core.player.FleetObj;
import core.scene.Game;
import core.ship.ShipFactory;
import core.solarSystem.Body;

import feathers.controls.Slider;

import generics.Localize;
import generics.Util;

import playerio.Message;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.filters.ColorMatrixFilter;

public class LandedPaintShop extends LandedState {
    public function LandedPaintShop(g:Game, body:Body) {
        super(g, body, body.name);
    }
    private var preview:GameObject;
    private var sliderShipHue:Slider;
    private var sliderShipBrightness:Slider;
    private var sliderShipSaturation:Slider;
    private var sliderShipContrast:Slider;
    private var sliderEngineHue:Slider;
    private var fleetObj:FleetObj;
    private var emitters:Vector.<Emitter> = new Vector.<Emitter>();

    override public function enter():void {
        var obj:Object;
        var labelShipHue:Text;
        var labelShipBrightness:Text;
        var labelShipSaturation:Text;
        var labelShipContrast:Text;
        var labelEngineHue:Text;
        var buyWithFluxButton:Button;
        var freePaintJobs:Text;
        super.enter();
        fleetObj = g.me.getActiveFleetObj();
        addShip();
        obj = dataManager.loadKey("Skins", g.me.activeSkin);
        labelShipHue = new Text();
        labelShipHue.text = Localize.t("Ship color");
        labelShipHue.x = 250;
        labelShipHue.y = 160;
        sliderShipHue = new Slider();
        sliderShipHue.x = 400;
        sliderShipHue.y = 160;
        sliderShipHue.minimum = 0;
        sliderShipHue.maximum = 1.8707963267948966;
        sliderShipHue.width = 200;
        sliderShipHue.step = 0.01;
        sliderShipHue.value = fleetObj.shipHue;
        sliderShipHue.direction == "horizontal";
        sliderShipHue.useHandCursor = true;
        sliderShipHue.addEventListener("change", function (param1:Event):void {
            var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
            _loc2_.adjustHue(sliderShipHue.value);
            _loc2_.adjustBrightness(sliderShipBrightness.value);
            _loc2_.adjustSaturation(sliderShipSaturation.value);
            _loc2_.adjustContrast(sliderShipContrast.value);
            preview.movieClip.filter = _loc2_;
        });
        labelShipBrightness = new Text();
        labelShipBrightness.text = Localize.t("Ship brightness");
        labelShipBrightness.x = 250;
        labelShipBrightness.y = 200;
        sliderShipBrightness = new Slider();
        sliderShipBrightness.x = 400;
        sliderShipBrightness.y = 200;
        sliderShipBrightness.minimum = -0.18;
        sliderShipBrightness.maximum = 0.04;
        sliderShipBrightness.width = 200;
        sliderShipBrightness.step = 0.01;
        sliderShipBrightness.value = fleetObj.shipBrightness;
        sliderShipBrightness.direction == "horizontal";
        sliderShipBrightness.useHandCursor = true;
        sliderShipBrightness.addEventListener("change", function (param1:Event):void {
            var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
            _loc2_.adjustHue(sliderShipHue.value);
            _loc2_.adjustBrightness(sliderShipBrightness.value);
            _loc2_.adjustSaturation(sliderShipSaturation.value);
            _loc2_.adjustContrast(sliderShipContrast.value);
            preview.movieClip.filter = _loc2_;
        });
        labelShipSaturation = new Text();
        labelShipSaturation.text = Localize.t("Ship saturation");
        labelShipSaturation.x = 250;
        labelShipSaturation.y = 4 * 60;
        sliderShipSaturation = new Slider();
        sliderShipSaturation.x = 400;
        sliderShipSaturation.y = 4 * 60;
        sliderShipSaturation.minimum = -1;
        sliderShipSaturation.maximum = 1;
        sliderShipSaturation.width = 200;
        sliderShipSaturation.step = 0.01;
        sliderShipSaturation.value = fleetObj.shipSaturation;
        sliderShipSaturation.direction == "horizontal";
        sliderShipSaturation.useHandCursor = true;
        sliderShipSaturation.addEventListener("change", function (param1:Event):void {
            var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
            _loc2_.adjustHue(sliderShipHue.value);
            _loc2_.adjustBrightness(sliderShipBrightness.value);
            _loc2_.adjustSaturation(sliderShipSaturation.value);
            _loc2_.adjustContrast(sliderShipContrast.value);
            preview.movieClip.filter = _loc2_;
        });
        labelShipContrast = new Text();
        labelShipContrast.text = Localize.t("Ship contrast");
        labelShipContrast.x = 250;
        labelShipContrast.y = 280;
        sliderShipContrast = new Slider();
        sliderShipContrast.x = 400;
        sliderShipContrast.y = 280;
        sliderShipContrast.minimum = 0;
        sliderShipContrast.maximum = 1;
        sliderShipContrast.width = 200;
        sliderShipContrast.step = 0.01;
        sliderShipContrast.value = fleetObj.shipContrast;
        sliderShipContrast.direction == "horizontal";
        sliderShipContrast.useHandCursor = true;
        sliderShipContrast.addEventListener("change", function (param1:Event):void {
            var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
            _loc2_.adjustHue(sliderShipHue.value);
            _loc2_.adjustBrightness(sliderShipBrightness.value);
            _loc2_.adjustSaturation(sliderShipSaturation.value);
            _loc2_.adjustContrast(sliderShipContrast.value);
            preview.movieClip.filter = _loc2_;
        });
        labelEngineHue = new Text();
        labelEngineHue.text = Localize.t("Engine color");
        labelEngineHue.x = 250;
        labelEngineHue.y = 340;
        sliderEngineHue = new Slider();
        sliderEngineHue.x = 400;
        sliderEngineHue.y = 340;
        sliderEngineHue.minimum = 0;
        sliderEngineHue.maximum = 3.141592653589793;
        sliderEngineHue.width = 200;
        sliderEngineHue.step = 0.01;
        sliderEngineHue.value = fleetObj.engineHue;
        sliderEngineHue.direction == "horizontal";
        sliderEngineHue.useHandCursor = true;
        sliderEngineHue.addEventListener("change", function (param1:Event):void {
            for each(var _loc2_ in emitters) {
                _loc2_.changeHue(sliderEngineHue.value);
            }
        });
        if (me.freePaintJobs > 0) {
            buyWithFluxButton = new Button(function (param1:TouchEvent):void {
                var e:TouchEvent = param1;
                var confirmBox:PopupConfirmMessage = new PopupConfirmMessage();
                confirmBox.text = "Are you sure you want to buy the paint job? You have <FONT COLOR=\'#adff2f\'>" + me.freePaintJobs + "</FONT> free paint jobs left.";
                g.addChildToOverlay(confirmBox, true);
                confirmBox.addEventListener("accept", function ():void {
                    var m:Message = g.createMessage("buyPaintJob", sliderShipHue.value, sliderShipBrightness.value, sliderShipSaturation.value, sliderShipContrast.value, sliderEngineHue.value);
                    g.rpcMessage(m, function (param1:Message):void {
                        boughtPaintJob(param1);
                        confirmBox.removeEventListeners();
                        g.removeChildFromOverlay(confirmBox, true);
                    });
                });
                confirmBox.addEventListener("close", function ():void {
                    buyWithFluxButton.enabled = true;
                    confirmBox.removeEventListeners();
                    g.removeChildFromOverlay(confirmBox, true);
                });
            }, Localize.t("Buy for Free"), "positive");
            freePaintJobs = new Text();
            freePaintJobs.htmlText = "You have <FONT COLOR=\'#adff2f\'>" + me.freePaintJobs + "</FONT> free paint jobs left.";
            freePaintJobs.x = 395;
            freePaintJobs.y = 445;
            addChild(freePaintJobs);
        } else {
            buyWithFluxButton = new Button(function (param1:TouchEvent):void {
                var e:TouchEvent = param1;
                g.creditManager.refresh(function ():void {
                    var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostPaintJob(), Localize.t("Are you sure you want to buy the paint job?"));
                    g.addChildToOverlay(confirmBuyWithFlux);
                    confirmBuyWithFlux.addEventListener("accept", function ():void {
                        var m:Message = g.createMessage("buyPaintJob", sliderShipHue.value, sliderShipBrightness.value, sliderShipSaturation.value, sliderShipContrast.value, sliderEngineHue.value);
                        g.rpcMessage(m, function (param1:Message):void {
                            boughtPaintJob(param1);
                            confirmBuyWithFlux.removeEventListeners();
                            g.removeChildFromOverlay(confirmBuyWithFlux, true);
                        });
                    });
                    confirmBuyWithFlux.addEventListener("close", function ():void {
                        buyWithFluxButton.enabled = true;
                        confirmBuyWithFlux.removeEventListeners();
                        g.removeChildFromOverlay(confirmBuyWithFlux, true);
                    });
                });
            }, Localize.t("Buy for [flux] Flux").replace("[flux]", CreditManager.getCostPaintJob()), "positive");
        }
        buyWithFluxButton.x = 270;
        buyWithFluxButton.y = 440;
        addChild(buyWithFluxButton);
        addChild(labelShipHue);
        addChild(sliderShipHue);
        addChild(labelShipBrightness);
        addChild(sliderShipBrightness);
        addChild(labelShipSaturation);
        addChild(sliderShipSaturation);
        addChild(labelShipContrast);
        addChild(sliderShipContrast);
        addChild(labelEngineHue);
        addChild(sliderEngineHue);
        loadCompleted();
        if (RymdenRunt.isBuggedFlashVersion) {
            g.showErrorDialog("Sorry but the repaint stations is currently closed due to a bug in your version of Flash (version 23). We are expecting Adobe to release a new version the coming days.", false, leave);
        }
    }

    override public function execute():void {
        super.execute();
    }

    override public function exit(callback:Function):void {
        for each(var _loc2_ in emitters) {
            _loc2_.killEmitter();
        }
        super.exit(callback);
    }

    private function boughtPaintJob(m:Message):void {
        if (!m.getBoolean(0)) {
            g.showErrorDialog(m.getString(1));
            return;
        }
        Game.trackEvent("used flux", "bought paint job", "player level " + g.me.level, CreditManager.getCostPaintJob());
        fleetObj.shipHue = sliderShipHue.value;
        fleetObj.shipBrightness = sliderShipBrightness.value;
        fleetObj.shipSaturation = sliderShipSaturation.value;
        fleetObj.shipContrast = sliderShipContrast.value;
        fleetObj.engineHue = sliderEngineHue.value;
        if (g.me.freePaintJobs > 0) {
            g.me.freePaintJobs--;
        }
        leave();
    }

    private function addShip():void {
        var _loc4_:* = null;
        var _loc2_:* = undefined;
        var _loc1_:Sprite = new Sprite();
        var _loc5_:Object = dataManager.loadKey("Skins", g.me.activeSkin);
        var _loc9_:Object = g.dataManager.loadKey("Ships", _loc5_.ship);
        var _loc7_:Object = g.dataManager.loadKey("Engines", _loc5_.engine);
        preview = new GameObject();
        preview.switchTexturesByObj(_loc9_);
        var _loc8_:Number = !!fleetObj.engineHue ? fleetObj.engineHue : 0;
        preview.movieClip.filter = ShipFactory.createPlayerShipColorMatrixFilter(fleetObj);
        var _loc6_:Vector.<Emitter> = EmitterFactory.create(_loc7_.effect, g, _loc9_.enginePosX, 0, preview, true, true, true, _loc1_);
        var _loc3_:Sprite = new Sprite();
        preview.canvas = _loc3_;
        preview.addToCanvas();
        _loc3_.x = 380;
        _loc3_.y = 100;
        addChild(_loc3_);
        if (_loc7_.dual) {
            _loc2_ = EmitterFactory.create(_loc7_.effect, g, _loc9_.enginePosX, 0, preview, true, true, true, _loc1_);
            for each(_loc4_ in _loc6_) {
                _loc4_.global = true;
                _loc4_.delay = 0;
                _loc4_.followTarget = false;
                _loc4_.posX = _loc3_.x + preview.pivotX * 2 - _loc9_.enginePosX - _loc3_.width;
                _loc4_.posY = _loc3_.y + preview.pivotY - _loc3_.height / 2 + _loc7_.dualDistance / 2;
                _loc4_.angle = Util.degreesToRadians(3 * 60);
                emitters.push(_loc4_);
            }
            for each(_loc4_ in _loc2_) {
                _loc4_.global = true;
                _loc4_.delay = 0;
                _loc4_.followTarget = false;
                _loc4_.posX = _loc3_.x + preview.pivotX * 2 - _loc9_.enginePosX - _loc3_.width;
                _loc4_.posY = _loc3_.y + preview.pivotY - _loc3_.height / 2 - _loc7_.dualDistance / 2;
                _loc4_.angle = Util.degreesToRadians(3 * 60);
                emitters.push(_loc4_);
            }
        } else {
            for each(_loc4_ in _loc6_) {
                _loc4_.global = true;
                _loc4_.delay = 0;
                _loc4_.followTarget = false;
                _loc4_.posX = _loc3_.x + preview.pivotX - _loc3_.width;
                _loc4_.posY = _loc3_.y + preview.pivotY - _loc3_.height / 2;
                _loc4_.angle = Util.degreesToRadians(3 * 60);
                emitters.push(_loc4_);
            }
        }
        if (_loc7_.changeThrustColors) {
            for each(var _loc10_ in emitters) {
                _loc10_.startColor = _loc7_.thrustStartColor;
                _loc10_.finishColor = _loc7_.thrustFinishColor;
                _loc10_.changeHue(_loc8_);
            }
        } else {
            for each(_loc10_ in emitters) {
                _loc10_.changeHue(_loc8_);
            }
        }
        addChild(_loc1_);
    }
}
}

