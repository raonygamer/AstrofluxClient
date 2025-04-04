package core.hud.components {
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

import textures.TextureLocator;

public class SaleSticker extends Sprite {
    public function SaleSticker(caption:String = "", captionBelow:String = "", captionAbove:String = "", color:uint = 14942208, overrideTexture:Texture = null, overrideTextureFB:Texture = null) {
        var _loc11_:Image = null;
        super();
        var _loc8_:Image = new Image(overrideTexture == null ? TextureLocator.getService().getTextureGUIByTextureName("sale_sticker") : overrideTexture);
        _loc8_.pivotX = _loc8_.texture.width / 2;
        _loc8_.pivotY = _loc8_.texture.height / 2;
        _loc8_.color = color;
        addChild(_loc8_);
        if (Login.currentState == "facebook") {
            _loc11_ = new Image(overrideTexture == null ? TextureLocator.getService().getTextureGUIByTextureName("fb_sale_lg") : overrideTextureFB);
            _loc11_.y = _loc8_.y + _loc8_.height / 2 - 45;
            _loc11_.pivotX = _loc11_.width / 2;
            _loc11_.x = _loc8_.x + 1;
            addChild(_loc11_);
        }
        var _loc10_:Text = new Text();
        _loc10_.size = 36;
        _loc10_.width = 110;
        _loc10_.htmlText = caption;
        _loc10_.centerPivot();
        addChild(_loc10_);
        var _loc9_:Text = new Text();
        _loc9_.size = 18;
        _loc9_.width = 110;
        _loc9_.htmlText = captionAbove;
        _loc9_.y = -_loc10_.height / 2 - 5;
        _loc9_.centerPivot();
        addChild(_loc9_);
        var _loc7_:Text = new Text();
        _loc7_.size = 18;
        _loc7_.width = 110;
        _loc7_.htmlText = captionBelow;
        _loc7_.y = _loc10_.height / 2 + 5;
        _loc7_.centerPivot();
        addChild(_loc7_);
    }
}
}

