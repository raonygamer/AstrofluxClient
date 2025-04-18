package core.artifact {
import com.greensock.TweenMax;

import core.hud.components.ToolTip;
import core.player.CrewMember;
import core.player.Player;
import core.scene.Game;

import generics.Util;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.filters.GlowFilter;

import textures.ITextureManager;
import textures.TextureLocator;

public class ArtifactBox extends Sprite {
    public function ArtifactBox(g:Game, a:Artifact) {
        super();
        this.g = g;
        this.p = g.me;
        this.a = a;
        toolTip = new ToolTip(g, this, "", null, "artifactBox");
        textureManager = TextureLocator.getService();
    }
    public var a:Artifact;
    public var locked:Boolean;
    public var unlockable:Boolean;
    public var slot:int;
    private var p:Player;
    private var g:Game;
    private var textureManager:ITextureManager;
    private var frame:Image;
    private var toolTip:ToolTip;
    private var colors:Array = [0xaaaaaa, 0x4488ff, 0x44ee44, 0xff44ff, 16761634];

    public function get isEmpty():Boolean {
        return a == null;
    }

    override public function dispose():void {
        if (frame && frame.filter) {
            frame.filter.dispose();
            frame.filter = null;
        }
        super.dispose();
    }

    public function update():void {
        removeChildren();
        drawFrame();
        toolTip.text = "";
        useHandCursor = false;
        removeEventListener("touch", onTouch);
        if (locked) {
            setLocked();
            if (unlockable) {
                toolTip.text = "Locked slot, click to buy.";
                addListeners();
            }
        } else if (a != null) {
            setArtifact();
            addListeners();
            addUpgradeIcon();
        }
    }

    public function setEmpty():void {
        a = null;
        update();
    }

    public function setActive(a:Artifact):void {
        this.a = a;
        update();
    }

    private function addUpgradeIcon():void {
        var _loc1_:Image = null;
        if (a.upgrading) {
            _loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgrading"));
        } else if (a.upgraded >= 10) {
            _loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded_max"));
        } else if (a.upgraded > 6) {
            _loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded3"));
        } else if (a.upgraded > 3) {
            _loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded2"));
        } else if (a.upgraded > 0) {
            _loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded"));
        }
        if (_loc1_ != null) {
            _loc1_.x = 35;
            _loc1_.y = 11;
            addChild(_loc1_);
        }
    }

    private function drawFrame():void {
        frame = new Image(textureManager.getTextureGUIByTextureName("artifact_box"));
        addChild(frame);
    }

    private function setArtifact():void {
        var _loc2_:int = 0;
        var _loc3_:CrewMember = null;
        var _loc4_:String = null;
        frame.filter = new GlowFilter(0xffffff, 1, 8, 1);
        frame.filter.cache();
        var artifactImage:starling.display.Image = new Image(textureManager.getTextureGUIByKey(a.bitmap));
        addChild(artifactImage);
        artifactImage.pivotX = artifactImage.width / 2;
        artifactImage.pivotY = artifactImage.height / 2;
        artifactImage.x = 8 + artifactImage.width / 2 * 0.5;
        artifactImage.y = 8 + artifactImage.height / 2 * 0.5;
        artifactImage.scaleX = 0;
        artifactImage.scaleY = 0;
        TweenMax.to(artifactImage, 0.3, {
            "scaleX": 0.5,
            "scaleY": 0.5
        });
        if (!a.revealed) {
            toolTip.text = "Click to reveal!";
            return;
        }
        _loc2_ = 0;
        while (_loc2_ < p.crewMembers.length) {
            _loc3_ = p.crewMembers[_loc2_];
            if (_loc3_.artifact == a.id) {
                a.upgradeTime = _loc3_.artifactEnd;
            }
            _loc2_++;
        }
        _loc4_ = a.name + "<br>Level " + a.levelPotential + ", strength " + a.level + "<br>";
        if (a.upgraded > 0) {
            _loc4_ += a.upgraded + " upgrades<br>";
        }
        if (a.upgrading) {
            _loc4_ += "Upgrading: " + Util.getFormattedTime(a.upgradeTime - g.time) + "<br>";
        }
        for each(var _loc1_ in a.stats) {
            _loc4_ += ArtifactStat.parseTextFromStatType(_loc1_.type, _loc1_.value, _loc1_.isUnique) + "<br>";
        }
        toolTip.text = _loc4_;
        toolTip.color = a.getColor();
    }

    private function setLocked():void {
        var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("lock"));
        _loc1_.scaleX = _loc1_.scaleY = 1.2;
        _loc1_.x = 16;
        _loc1_.y = 12;
        addChild(_loc1_);
    }

    private function addListeners():void {
        useHandCursor = true;
        addEventListener("touch", onTouch);
    }

    private function onTouch(e:TouchEvent):void {
        if (e.getTouch(this, "ended")) {
            onClick(e);
        }
    }

    private function onClick(e:TouchEvent):void {
        if (locked && unlockable) {
            dispatchEventWith("artifactSlotUnlock", true);
        } else {
            dispatchEventWith("activeArtifactRemoved", true);
        }
    }
}
}

