package core.hud.components.map {
import core.controlZones.ControlZone;
import core.hud.components.CrewDisplayBox;
import core.hud.components.Style;
import core.hud.components.ToolTip;
import core.scene.Game;
import core.solarSystem.Area;
import core.solarSystem.Body;

import data.DataLocator;
import data.IDataManager;

import generics.Util;

import starling.display.Image;
import starling.display.Sprite;

public class MapPlanet extends MapBodyBase {
    public function MapPlanet(g:Game, container:Sprite, body:Body) {
        super(g, container, body);
        container.addChild(crew);
        container.addChild(text);
        container.addChild(percentage);
        layer.useHandCursor = true;
        addImage();
        addCrew();
        addTooltip();
        addOrbits();
        addText();
        init();
    }

    private function addImage():void {
        if (body.texture == null) {
            return;
        }
        var _loc1_:Number = Map.SCALE * 1.5;
        radius = body.texture.width / 2 * _loc1_;
        if (radius < 4) {
            _loc1_ = 4 / (body.texture.width / 2);
        }
        radius = body.texture.width / 2 * _loc1_;
        var _loc2_:Image = new Image(body.texture);
        _loc2_.scaleX = _loc1_;
        _loc2_.scaleY = _loc1_;
        layer.addChild(_loc2_);
        imgHover = new Image(body.texture);
        imgHover.scaleX = _loc1_;
        imgHover.scaleY = _loc1_;
        imgHover.blendMode = "add";
        imgSelected = imgHover;
    }

    private function addCrew():void {
        var _loc1_:Image = null;
        var _loc2_:int = 0;
        for each(var _loc3_ in g.me.crewMembers) {
            if (_loc3_.body == body.key) {
                _loc1_ = new Image(_loc3_.texture);
                _loc1_.height *= 0.2;
                _loc1_.width *= 0.2;
                _loc1_.x = _loc2_ * (_loc1_.width + 4);
                crew.addChild(_loc1_);
                _loc2_++;
            }
        }
    }

    private function addTooltip():void {
        var _loc4_:int = 0;
        var _loc12_:IDataManager = null;
        var _loc3_:Object = null;
        var _loc9_:ControlZone = null;
        var _loc13_:Number = NaN;
        var _loc11_:Boolean = false;
        for each(var _loc10_ in g.me.landedBodies) {
            if (_loc10_.key == body.key) {
                _loc11_ = true;
                break;
            }
        }
        var _loc5_:String = "";
        if (!_loc11_) {
            _loc5_ = "Name: " + body.name + "\nAreas: Unknown";
            new ToolTip(g, layer, _loc5_, null, "Map", 400);
            return;
        }
        var _loc2_:Array = [];
        var _loc6_:int = 0;
        var _loc7_:int = 0;
        _loc5_ += "Name: " + body.name + "\nAreas: ";
        for each(var _loc1_ in body.obj.exploreAreas) {
            _loc12_ = DataLocator.getService();
            _loc3_ = _loc12_.loadKey("BodyAreas", _loc1_);
            if (_loc3_.skillLevel > 99) {
                _loc4_ = 34;
            } else {
                _loc4_ = 26;
            }
            _loc5_ += "\n<FONT COLOR=\'" + Area.COLORTYPESTR[_loc3_.majorType] + "\'> " + _loc3_.skillLevel + "      </FONT>";
            _loc2_.push({
                "img": CrewDisplayBox.IMAGES_SKILLS[_loc3_.majorType],
                "x": _loc4_,
                "y": 38 + 19 * _loc6_
            });
            _loc7_ = 0;
            for each(var _loc8_ in _loc3_.types) {
                _loc7_++;
                _loc5_ += "    ";
                _loc2_.push({
                    "img": CrewDisplayBox.IMAGES_SPECIALS[_loc8_],
                    "x": _loc4_ + _loc7_ * 18,
                    "y": 38 + 19 * _loc6_
                });
            }
            if (g.me.hasExploredArea(_loc1_)) {
                _loc5_ += "  Complete";
            } else {
                _loc5_ += "  Unexplored";
            }
            _loc6_++;
        }
        if (body.explorable && g.me.clanId != "" && g.isSystemTypeHostile()) {
            _loc9_ = g.controlZoneManager.getZoneByKey(body.key);
            if (_loc9_) {
                _loc5_ += "\n\n";
                _loc5_ = _loc5_ + "Controlled by\n";
                _loc5_ = _loc5_ + (_loc9_.clanName + "\n");
                if (_loc9_.releaseTime > g.time) {
                    _loc13_ = _loc9_.releaseTime - g.time;
                    _loc5_ += "<FONT COLOR=\"#ff0000\">locked for " + Util.getFormattedTime(_loc13_) + "</FONT>\n";
                }
            }
        }
        new ToolTip(g, layer, _loc5_, _loc2_, "Map", 400);
    }

    private function addText():void {
        var _loc3_:ControlZone = null;
        if (!body.landable) {
            return;
        }
        text.size = 11;
        text.format.color = Style.COLOR_MAP_PLANET;
        text.text = body.name;
        if (body.explorable && g.me.clanId != "" && g.isSystemTypeHostile()) {
            _loc3_ = g.controlZoneManager.getZoneByKey(body.key);
            if (!_loc3_ || _loc3_.releaseTime < g.time) {
                text.format.color = Style.COLOR_LIGHT_GREEN;
            }
        }
        var _loc2_:int = 0;
        var _loc4_:int = 0;
        for each(var _loc1_ in body.obj.exploreAreas) {
            if (g.me.hasExploredArea(_loc1_)) {
                _loc4_++;
            }
            _loc2_++;
        }
        if (_loc2_ > 0) {
            percentage.size = 11;
            percentage.format.color = Style.COLOR_BYLINE;
            percentage.text = Math.floor(_loc4_ / _loc2_ * 100).toString() + "%";
        }
    }
}
}

