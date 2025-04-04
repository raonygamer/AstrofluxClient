package core.hud.components.starMap {
import core.hud.components.Line;
import core.hud.components.PriceCommodities;
import core.scene.SceneBase;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;

public class WarpPath extends Sprite {
    public function WarpPath(sb:SceneBase, obj:Object, icon1:SolarSystem, icon2:SolarSystem, bought:Boolean = false) {
        super();
        this.sb = sb;
        this.obj = obj;
        this._icon1 = icon1;
        this._icon2 = icon2;
        _bought = bought;
        addChild(line);
        forwardArrow = new TransitButton(icon2, 10453053);
        backArrow = new TransitButton(icon1, 10453053);
        forwardArrow.addEventListener("touch", onTouch);
        backArrow.addEventListener("touch", onTouch);
        addChild(forwardArrow);
        addChild(backArrow);
        draw();
    }
    private var obj:Object;
    private var sb:SceneBase;
    private var line:Line = new Line();
    private var forwardArrow:TransitButton;
    private var backArrow:TransitButton;

    override public function get name():String {
        return obj.name;
    }

    private var _icon1:SolarSystem;

    public function get icon1():SolarSystem {
        return _icon1;
    }

    private var _icon2:SolarSystem;

    public function get icon2():SolarSystem {
        return _icon2;
    }

    private var _bought:Boolean;

    public function get bought():Boolean {
        return _bought;
    }

    public function set bought(value:Boolean):void {
        _bought = value;
        draw();
    }

    private var _selected:Boolean;

    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(value:Boolean):void {
        _selected = value;
        draw();
    }

    public function get key():String {
        return obj.key;
    }

    public function get solarSystem1():String {
        return obj.solarSystem1;
    }

    public function get solarSystem2():String {
        return obj.solarSystem2;
    }

    public function get transit():Boolean {
        return obj.transit;
    }

    public function get priceItems():Array {
        return obj.priceItems;
    }

    public function get costContainer():Sprite {
        var _loc4_:PriceCommodities = null;
        var _loc1_:Sprite = new Sprite();
        var _loc5_:int = 0;
        for each(var _loc3_ in priceItems) {
            _loc4_ = new PriceCommodities(sb, _loc3_.item, _loc3_.amount);
            _loc4_.x = 10;
            _loc4_.y = 10 + 30 * _loc5_;
            _loc1_.addChild(_loc4_);
            _loc5_++;
        }
        var _loc2_:Quad = new Quad(_loc1_.width + 20, _loc1_.height + 10, 0);
        _loc1_.addChildAt(_loc2_, 0);
        return _loc1_;
    }

    public function isConnectedTo(solarSystem1:String, solarSystem2:String):Boolean {
        if (solarSystem1 == this.solarSystem1 && solarSystem2 == this.solarSystem2) {
            return true;
        }
        if (solarSystem2 == this.solarSystem1 && solarSystem1 == this.solarSystem2) {
            return true;
        }
        return false;
    }

    private function draw():void {
        forwardArrow.visible = false;
        backArrow.visible = false;
        var _loc3_:* = 1118481;
        if (_bought) {
            if (transit) {
                _loc3_ = 10453053;
            } else {
                _loc3_ = icon1.color;
            }
        }
        if (_selected) {
            _loc3_ = 0xffffff;
        }
        line.color = _loc3_;
        line.blendMode = "add";
        var _loc4_:Number = icon2.x - icon1.x;
        var _loc5_:Number = icon2.y - icon1.y;
        var _loc6_:Number = Math.atan2(_loc5_, _loc4_);
        var _loc8_:Number = Math.cos(_loc6_) * (icon1.size + 2);
        var _loc7_:Number = Math.sin(_loc6_) * (icon1.size + 2);
        line.x = _loc8_;
        line.y = _loc7_;
        var _loc2_:Number = icon2.x + Math.cos(_loc6_ + 3.141592653589793) * (icon2.size + 2) - icon1.x;
        var _loc1_:Number = icon2.y + Math.sin(_loc6_ + 3.141592653589793) * (icon2.size + 2) - icon1.y;
        line.lineTo(_loc2_, _loc1_);
        line.thickness = 5;
        var _loc9_:Vector.<Number> = new Vector.<Number>();
        _loc9_.push(_loc8_, _loc7_, _loc2_, _loc1_);
        if (transit) {
            forwardArrow.visible = true;
            forwardArrow.rotation = _loc6_ + 3.141592653589793 / 2;
            forwardArrow.x = Math.cos(_loc6_) * (icon1.size + 20);
            forwardArrow.y = Math.sin(_loc6_) * (icon1.size + 20);
            backArrow.visible = true;
            backArrow.rotation = _loc6_ + 3.141592653589793 + 3.141592653589793 / 2;
            backArrow.x = icon2.x + Math.cos(_loc6_ + 3.141592653589793) * (icon2.size + 20) - icon1.x;
            backArrow.y = icon2.y + Math.sin(_loc6_ + 3.141592653589793) * (icon2.size + 20) - icon1.y;
        }
    }

    private function onTouch(e:TouchEvent):void {
        var _loc2_:TransitButton = e.currentTarget as TransitButton;
        if (e.getTouch(_loc2_, "ended")) {
            dispatchEvent(new Event("transitClick", false, {"solarSystemKey": _loc2_.target.key}));
        }
    }
}
}

