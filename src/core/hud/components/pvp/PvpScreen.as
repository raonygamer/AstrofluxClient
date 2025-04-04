package core.hud.components.pvp {
import core.hud.components.ButtonExpandableHud;
import core.scene.Game;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

import textures.ITextureManager;
import textures.TextureLocator;

public class PvpScreen extends Sprite {
    public static var WIDTH:Number = 698;
    public static var HEIGHT:Number = 538;

    public function PvpScreen(g:Game) {
        super();
        this.g = g;
    }
    public var g:Game;

    public function load():void {
        var textureManager:ITextureManager = TextureLocator.getService();
        var bgr:starling.display.Image = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
        addChild(bgr);
        var closeButton:core.hud.components.ButtonExpandableHud = new ButtonExpandableHud(function ():void {
            dispatchEvent(new Event("close"));
        }, "close");
        closeButton.x = 760 - 46 - closeButton.width;
        closeButton.y = 0;
        addChild(closeButton);
    }

    public function unload():void {
    }

    public function update():void {
    }
}
}

