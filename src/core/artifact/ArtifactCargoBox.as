package core.artifact {
import core.hud.components.ToolTip;
import core.player.CrewMember;
import core.player.Player;
import core.scene.Game;

import generics.Localize;
import generics.Util;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;

import textures.ITextureManager;
import textures.TextureLocator;

public class ArtifactCargoBox extends Sprite {
    private static const COLOR_ACTIVE:uint = 16777215;
    private static const COLOR_SELECTED_RECYCLE:uint = 12203572;
    private static const COLOR_SELECTED_UPGRADE:uint = 8978312;

    public function ArtifactCargoBox(g:Game, a:Artifact) {
        super();
        this.g = g;
        this.p = g.me;
        this.a = a;
        toolTip = new ToolTip(g, this, "", null, "artifactBox");
        textureManager = TextureLocator.getService();
        update();
    }
    public var hint:Boolean = false;
    public var a:Artifact;
    protected var hintNewContainer:Image;
    private var p:Player;
    private var g:Game;
    private var recycleMode:Boolean;
    private var upgradeMode:Boolean;
    private var isInSetup:Boolean;
    private var textureManager:ITextureManager;
    private var frame:Image;
    private var toolTip:ToolTip;
    private var lock:Image;
    private var artifactImage:Image;
    private var upgradingImage:Image;

    public function update():void {
        removeChildren();
        drawFrame();
        toolTip.text = "";
        useHandCursor = false;
        removeEventListener("touch", onTouch);
        if (a != null) {
            addImages();
            addTouch();
            addToolTip();
            addUpgradeIcon();
            addHint();
        }
    }

    public function showHint():void {
        hint = true;
        update();
    }

    public function hideHint():void {
        hint = false;
        update();
    }

    public function isUsedInSetup():Boolean {
        return isInSetup;
    }

    public function setSelectedForRecycle():void {
        if (a == null) {
            return;
        }
        setFrameColor(12203572);
    }

    public function setNotSelected():void {
        if (a == null) {
            return;
        }
        if (isInSetup) {
            setFrameColor(16777215);
        } else {
            var COLOR_NORMAL:uint = 6513507;
            setFrameColor(COLOR_NORMAL);
        }
    }

    public function toggleUpgrade():void {
        if (a == null) {
            return;
        }
        var COLOR_NORMAL:uint = 6513507;
        if (frame.color == COLOR_NORMAL) {
            setFrameColor(8978312);
        } else if (frame.color == 16777215) {
            setFrameColor(8978312);
        } else if (isInSetup) {
            setFrameColor(16777215);
        } else {
            setFrameColor(COLOR_NORMAL);
        }
    }

    public function toggleRecycle():void {
        if (a == null) {
            return;
        }
        var COLOR_NORMAL:uint = 6513507;
        if (frame.color == COLOR_NORMAL) {
            setFrameColor(12203572);
        } else {
            setFrameColor(COLOR_NORMAL);
        }
    }

    public function setUpgradeState():void {
        upgradeMode = true;
        if (a == null) {
            return;
        }
        isInSetup = p.isArtifactInSetup(a);
        if (isInSetup) {
            setFrameColor(16777215);
        } else {
            var COLOR_NORMAL:uint = 6513507;
            setFrameColor(COLOR_NORMAL);
        }
        removeTouch();
        addTouch();
        update();
    }

    public function removeUpgradeState():void {
        upgradeMode = false;
        var COLOR_NORMAL:uint = 6513507;
        if (a == null) {
            setFrameColor(COLOR_NORMAL);
            return;
        }
        var _loc1_:Boolean = p.isActiveArtifact(a);
        if (_loc1_) {
            setFrameColor(16777215);
        } else {
            setFrameColor(COLOR_NORMAL);
        }
        removeTouch();
        addTouch();
        update();
    }

    public function setRecycleState():void {
        recycleMode = true;
        if (a == null) {
            return;
        }
        isInSetup = p.isArtifactInSetup(a);
        if (isInSetup) {
            setFrameColor(16777215);
        } else {
            var COLOR_NORMAL:uint = 6513507;
            setFrameColor(COLOR_NORMAL);
        }
        removeTouch();
        addTouch();
        update();
    }

    public function removeRecycleState():void {
        recycleMode = false;
        var COLOR_NORMAL:uint = 6513507;
        if (a == null) {
            setFrameColor(COLOR_NORMAL);
            return;
        }
        var _loc1_:Boolean = p.isActiveArtifact(a);
        if (_loc1_) {
            setFrameColor(16777215);
        } else {
            setFrameColor(COLOR_NORMAL);
        }
        removeTouch();
        addTouch();
        update();
    }

    public function stateNormal():void {
        var COLOR_NORMAL:uint = 6513507;
        setFrameColor(COLOR_NORMAL);
    }

    public function updateSetupChange():void {
        var COLOR_NORMAL:uint = 6513507;
        frame.color = COLOR_NORMAL;
        if (a == null) {
            return;
        }
        var _loc1_:Boolean = p.isActiveArtifact(a);
        if (_loc1_) {
            setFrameColor(16777215);
        }
    }

    public function setEmpty():void {
        a = null;
        update();
    }

    private function addImages():void {
        if (!a.revealed) {
            lock = new Image(textureManager.getTextureGUIByTextureName("new_artifact"));
            lock.x = Math.round(frame.width / 2 - lock.width / 2);
            lock.y = Math.round(frame.height / 2 - lock.width / 2);
            addChild(lock);
        } else {
            artifactImage = new Image(textureManager.getTextureGUIByKey(a.bitmap));
            artifactImage.scaleX = artifactImage.scaleY = 0.25;
            artifactImage.x = Math.round(frame.width / 2 - artifactImage.width / 2);
            artifactImage.y = Math.round(frame.height / 2 - artifactImage.width / 2);
            addChild(artifactImage);
        }
    }

    private function addHint():void {
        if (hint) {
            hintNewContainer = new Image(textureManager.getTextureGUIByTextureName("notification.png"));
            hintNewContainer.x = 0;
            hintNewContainer.y = -4;
            hintNewContainer.touchable = false;
            addChild(hintNewContainer);
        }
    }

    private function addUpgradeIcon():void {
        if (a.upgrading) {
            upgradingImage = new Image(textureManager.getTextureGUIByTextureName("upgrading"));
        } else if (a.upgraded >= 10) {
            upgradingImage = new Image(textureManager.getTextureGUIByTextureName("upgraded_max"));
        } else if (a.upgraded > 6) {
            upgradingImage = new Image(textureManager.getTextureGUIByTextureName("upgraded3"));
        } else if (a.upgraded > 3) {
            upgradingImage = new Image(textureManager.getTextureGUIByTextureName("upgraded2"));
        } else if (a.upgraded > 0) {
            upgradingImage = new Image(textureManager.getTextureGUIByTextureName("upgraded"));
        }
        if (upgradingImage != null) {
            upgradingImage.x = 20;
            addChild(upgradingImage);
        }
    }

    private function drawFrame():void {
        frame = new Image(textureManager.getTextureGUIByTextureName("artifact_box_small"));
        var COLOR_NORMAL:uint = 6513507;
        frame.color = COLOR_NORMAL;
        addChild(frame);
        if (a == null) {
            return;
        }
        var _loc1_:Boolean = p.isActiveArtifact(a);
        if (_loc1_) {
            setFrameColor(16777215);
        }
    }

    private function addToolTip():void {
        var _loc2_:int = 0;
        var _loc3_:CrewMember = null;
        if (!a.revealed && recycleMode) {
            toolTip.text = Localize.t("You can\'t reveal in recycle mode!");
            return;
        }
        if (!a.revealed) {
            toolTip.text = Localize.t("Click to reveal!");
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
        var _loc4_:String = a.name + "<br>";
        if (a.revealed && a.isRestricted) {
            _loc4_ += Localize.t("<font color=\'#ff0000\'>Requires level [level]</font>").replace("[level]", a.requiredPlayerLevel) + "<br>";
        }
        _loc4_ += Localize.t("Level [potential], strength [level]").replace("[level]", a.level).replace("[potential]", a.levelPotential) + "<br>";
        if (a.upgraded >= 10) {
            _loc4_ += Localize.t("Max Upgraded") + "<br>";
        } else if (a.upgraded > 0) {
            _loc4_ += Localize.t("[nr] upgrades").replace("[nr]", a.upgraded) + "<br>";
        }
        if (a.upgrading) {
            _loc4_ += Localize.t("Upgrading") + ": " + Util.getFormattedTime(a.upgradeTime - g.time) + "<br>";
        }
        for each(var _loc1_ in a.stats) {
            _loc4_ += ArtifactStat.parseTextFromStatType(_loc1_.type, _loc1_.value, _loc1_.isUnique) + "<br>";
        }
        toolTip.text = _loc4_;
        toolTip.color = a.getColor();
    }

    private function addTouch():void {
        if (a.revealed && a.isRestricted && !recycleMode && !upgradeMode) {
            if (artifactImage != null) {
                artifactImage.alpha = 0.5;
            }
            if (lock != null) {
                lock.alpha = 0.5;
            }
            if (hintNewContainer != null) {
                hintNewContainer.alpha = 0.5;
            }
            return;
        }
        useHandCursor = true;
        addEventListener("touch", onTouch);
    }

    private function removeTouch():void {
        if (hasEventListener("touch", onTouch)) {
            removeEventListener("touch", onTouch);
            useHandCursor = false;
        }
        if (artifactImage != null) {
            artifactImage.alpha = 1;
        }
        if (lock != null) {
            lock.alpha = 1;
        }
        if (hintNewContainer != null) {
            hintNewContainer.alpha = 1;
        }
    }

    private function setFrameColor(color:uint):void {
        if (frame.color === color) {
            return;
        }
        frame.color = color;
    }

    private function onTouch(e:TouchEvent):void {
        if (e.getTouch(this, "ended")) {
            onClick(e);
        } else if (e.interactsWith(this)) {
            addToolTip();
            if (hint) {
                hideHint();
            }
        }
    }

    private function onClick(e:TouchEvent):void {
        if (!a.revealed && !recycleMode) {
            a.revealed = true;
            g.send("revealArtifact", a.id);
            update();
            return;
        }
        if (!g.me.isLanded && !g.me.inSafeZone && !recycleMode) {
            g.showErrorDialog(Localize.t("Artifacts can only be changed inside the safe zones."));
            return;
        }
        if (!recycleMode && !upgradeMode) {
            dispatchEventWith("artifactSelected", true);
            return;
        }
        if (upgradeMode) {
            if (a.upgrading) {
                return;
            }
            if (a.upgraded >= 10) {
                g.showMessageDialog(Localize.t("This artifact has already been upgraded [times] times.").replace("[times]", 10));
                return;
            }
            if (a.isUnique) {
                g.showMessageDialog(Localize.t("Unique artifacts can\'t be upgraded, yet."));
                return;
            }
            toggleUpgrade();
            dispatchEventWith("artifactUpgradeSelected", true);
        } else {
            if (a.upgrading) {
                return;
            }
            if (isInSetup) {
                return;
            }
            toggleRecycle();
            dispatchEventWith("artifactRecycleSelected", true);
        }
    }
}
}

