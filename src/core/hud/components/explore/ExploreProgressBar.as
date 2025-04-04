package core.hud.components.explore {
import core.GameObject;
import core.hud.components.Text;
import core.particle.Emitter;
import core.particle.EmitterFactory;
import core.scene.Game;
import core.solarSystem.Area;
import core.solarSystem.Body;

import debug.Console;

import flash.utils.Timer;

import starling.display.Quad;
import starling.display.Sprite;

public class ExploreProgressBar extends Sprite {
    public static var COLOR:uint = 3225899;

    public function ExploreProgressBar(g:Game, body:Body, finishedCallback:Function, type:int) {
        this.g = g;
        this.body = body;
        this.type = type;
        this.finishedCallback = finishedCallback;
        var _loc5_:uint = Area.COLORTYPE[type];
        super();
        effectTarget = new GameObject();
        effectCanvas = new Sprite();
        exploreEffect = EmitterFactory.create("9iZrZ9p5nEWqrPhkxTYNgA", g, 0, 0, effectTarget, true, true, true, effectCanvas);
        for each(var _loc6_ in exploreEffect) {
            _loc6_.followEmitter = true;
            _loc6_.followTarget = true;
            _loc6_.speed = 2;
            _loc6_.maxParticles = 20;
            _loc6_.ttl = 1400;
            _loc6_.startColor = _loc5_;
            _loc6_.startSize = 2;
            _loc6_.finishSize = 0;
        }
        var barWidth:Number = 452;
        var effectBackground:starling.display.Quad = new Quad(barWidth, 17, 0);
        addChild(effectBackground);
        effectForeground = new Quad(1, 17, _loc5_);
        exploreText = new Text(width / 2, 0, true);
        exploreText.wordWrap = false;
        exploreText.size = 10;
        exploreText.alignCenter();
        exploreText.y = 1;
        if (type == 0) {
            exploreText.color = 0x111111;
        } else {
            exploreText.color = 0x555555;
        }
        if (finished) {
            exploreText.text = "EXPLORE FINISHED!";
        } else {
            exploreText.text = "NOT EXPLORED";
        }
        addChild(exploreText);
        loadFinished = true;
        if (setValueOnFinishedLoad) {
            start(0, 0, 0);
            setValueAndEffect(onFinishedLoadValue, onFinishedLoadFailed);
        }
        if (startOnFinish) {
            start(startTime, finishTime, failTime);
        }
    }
    private var min:Number = 0;
    private var exploreEffect:Vector.<Emitter>;
    private var effectForeground:Quad;
    private var effectContainer:Quad;
    private var effectTarget:GameObject;
    private var effectCanvas:Sprite;
    private var finished:Boolean = false;
    private var exploreText:Text;
    private var body:Body;
    private var g:Game;

    private var finishedCallback:Function;
    private var setValueOnFinishedLoad:Boolean = false;
    private var onFinishedLoadValue:Number;
    private var onFinishedLoadFailed:Boolean;
    private var startOnFinish:Boolean = false;
    private var timer:Timer = new Timer(1000, 1);
    private var startTime:Number = 0;
    private var finishTime:Number = 0;
    private var failTime:Number = 0;
    private var type:int;
    private var loadFinished:Boolean = false;

    private var _exploring:Boolean = false;

    public function set exploring(value:Boolean):void {
        this._exploring = value;
    }

    public function setMax():void {
        finished = true;
    }

    public function start(start:Number, finish:Number, fail:Number):void {
        Console.write("start");
        startTime = start;
        finishTime = finish;
        failTime = fail;
        if (type == 0) {
            exploreText.color = 0x111111;
        } else {
            exploreText.color = 0x555555;
        }
        if (!loadFinished) {
            startOnFinish = true;
            return;
        }
        finished = false;
        startTime = start;
        finishTime = finish;
        failTime = fail;
        if (!contains(effectForeground)) {
            addChildAt(effectForeground, 1);
        }
        addChild(effectCanvas);
        exploring = true;
    }

    public function stop():void {
        finished = true;
        stopEffect();
    }

    public function update():void {
        var _loc3_:Number = NaN;
        var _loc1_:Number = NaN;
        var _loc2_:Number = NaN;
        if (_exploring && !finished) {
            if (failTime < g.time) {
                _loc3_ = failTime - startTime;
            } else {
                _loc3_ = g.time - startTime;
            }
            _loc1_ = finishTime - startTime;
            _loc2_ = _loc3_ / _loc1_;
            setValue(_loc2_, failTime < g.time);
        }
    }

    public function stopEffect():void {
        for each(var _loc1_ in exploreEffect) {
            _loc1_.killEmitter();
        }
    }

    public function setValueAndEffect(v:Number, failed:Boolean = false):void {
        var _loc3_:int = 0;
        if (!loadFinished) {
            setValueOnFinishedLoad = true;
            onFinishedLoadValue = v;
            onFinishedLoadFailed = failed;
            return;
        }
        if (!contains(effectForeground)) {
            addChildAt(effectForeground, 1);
        }
        var max:Number = 1;
        if (v > max) {
            v = max;
        }
        var value:Number = v;
        finished = true;
        var barWidth:Number = 452;
        if (failed) {
            _loc3_ = barWidth * (value / max);
            effectForeground.width = _loc3_;
            effectTarget.x = _loc3_ - 1;
            effectTarget.y = 10;
            exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
            if (type == 2) {
                exploreText.color = 0xffffff;
            } else {
                exploreText.color = 0xaa0000;
            }
            exploreText.glow = false;
            return;
        }
        _loc3_ = barWidth * (value / max);
        effectForeground.width = _loc3_;
        effectTarget.x = _loc3_ - 1;
        effectTarget.y = 10;
        exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
        if (type == 0 && value > 0.5) {
            exploreText.color = 0;
        } else {
            exploreText.color = 0xffffff;
        }
    }

    private function setValue(v:Number, failed:Boolean = false):void {
        var _loc4_:int = 0;
        var _loc5_:Number = NaN;
        var _loc3_:Number = NaN;
        if (!loadFinished) {
            return;
        }
        var max:Number = 1;
        if (v > max) {
            v = max;
        }
        var value:Number = v;
        var barWidth:Number = 452;
        _loc4_ = barWidth * (value / max);
        effectTarget.x = _loc4_ - 1;
        effectTarget.y = 10;
        effectForeground.width = _loc4_;
        exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
        if (type == 0 && value > 0.5) {
            exploreText.color = 0;
        } else {
            exploreText.color = 0xffffff;
        }
        if (value >= max && !finished) {
            Console.write("finished explore");
            finished = true;
            if (type == 0 && value > 0.5) {
                exploreText.color = 0;
            } else {
                exploreText.color = 0xffffff;
            }
            finishedCallback();
        } else if (failed && !finished) {
            Console.write("failed explore");
            _loc5_ = failTime - startTime;
            _loc3_ = finishTime - startTime;
            value = _loc5_ / _loc3_;
            _loc4_ = barWidth * (value / max);
            effectTarget.x = _loc4_ - 1;
            effectTarget.y = 10;
            effectForeground.width = _loc4_;
            exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
            if (type == 2) {
                exploreText.color = 0xffffff;
            } else {
                exploreText.color = 0xaa0000;
            }
            exploreText.glow = false;
            _exploring = false;
            finished = true;
            finishedCallback();

        }
    }
}
}

