package core.hud.components.techTree {
import core.hud.components.Box;
import core.hud.components.Button;
import core.player.EliteTechs;
import core.player.TechSkill;
import core.scene.Game;

import data.DataLocator;
import data.IDataManager;

import feathers.controls.ScrollContainer;

import playerio.Message;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;

import textures.ITextureManager;
import textures.TextureLocator;

public class EliteTechPopupMenu extends Sprite {
    public function EliteTechPopupMenu(g:Game, eti:EliteTechIcon) {
        super();
        this.g = g;
        this.eti = eti;
        bgr.alpha = 0.5;
        bgr.alpha = 0.5;
        var textureManager:textures.ITextureManager = TextureLocator.getService();
        dataManager = DataLocator.getService();
        load();
        addEventListener("addedToStage", stageAddHandler);
    }
    protected var bgr:Quad = new Quad(100, 100, 0x22000000);
    private var container:ScrollContainer = new ScrollContainer();
    private var box:Box = new Box(460, 430, "highlight", 1, 15);
    private var closeButton:Button;
    private var g:Game;
    private var eti:EliteTechIcon;
    private var dataManager:IDataManager;
    private var eliteTechs:Vector.<EliteTechBar> = new Vector.<EliteTechBar>();

    public function updateAndClose(m:Message):void {
        if (!m.getBoolean(0)) {
            return;
        }
        eti.update(m.getInt(1));
        close();
    }

    public function disableAll():void {
        for each(var _loc1_ in eliteTechs) {
            _loc1_.touchable = false;
        }
        closeButton.touchable = false;
    }

    private function load():void {
        var _loc2_:int = 0;
        var _loc4_:TechSkill = eti.techSkill;
        var _loc3_:Object = dataManager.loadKey(_loc4_.table, _loc4_.tech);
        container.width = 450;
        container.height = 385;
        container.x = 10;
        container.y = 10;
        box.addChild(container);
        closeButton = new Button(close, "Cancel");
        box.addChild(closeButton);
        if (_loc3_.hasOwnProperty("eliteTechs")) {
            eliteTechs = EliteTechs.getEliteTechBarList(g, _loc4_, _loc3_);
        }
        for each(var _loc1_ in eliteTechs) {
            _loc1_.y = _loc2_;
            _loc1_.x = 5;
            _loc1_.etpm = this;
            container.addChild(_loc1_);
            _loc2_ += _loc1_.height + 10;
        }
        addChild(bgr);
        addChild(box);
    }

    protected function redraw(e:Event = null):void {
        if (stage == null) {
            return;
        }
        closeButton.y = Math.round(box.height - 50);
        closeButton.x = Math.round(box.width / 2 - closeButton.width / 2 - 20);
        box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
        box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
        bgr.width = stage.stageWidth;
        bgr.height = stage.stageHeight;
    }

    protected function close(e:TouchEvent = null):void {
        dispatchEventWith("close");
        removeEventListeners();
    }

    protected function clean(e:Event):void {
        stage.removeEventListener("resize", redraw);
        removeEventListener("removedFromStage", clean);
        removeEventListener("addedToStage", stageAddHandler);
        super.dispose();
    }

    private function stageAddHandler(e:Event):void {
        addEventListener("removedFromStage", clean);
        stage.addEventListener("resize", redraw);
        bgr.width = stage.stageWidth;
        bgr.height = stage.stageHeight;
        redraw();
    }
}
}

