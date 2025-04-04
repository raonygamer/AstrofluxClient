package textures {
import playerio.Client;

import starling.textures.Texture;
import starling.textures.TextureAtlas;

public interface ITextureManager {
    function get percLoaded():int;

    function set client(value:Client):void;

    function loadTextures(itemsArray:Array):void;

    function getTextureMainByKey(textureObjKey:String):Texture;

    function getTextureGUIByTextureName(textureName:String):Texture;

    function getTextureGUIByKey(key:String):Texture;

    function getTexturesByKey(textureObjKey:String, atlas:String):Vector.<Texture>;

    function getTexturesMainByKey(textureObjKey:String):Vector.<Texture>;

    function getTexturesMainByTextureName(textureName:String):Vector.<Texture>;

    function getTextureMainByTextureName(textureName:String):Texture;

    function getTextureByTextureName(textureName:String, textureAtlas:String):Texture;

    function getTextureAtlas(atlasName:String):TextureAtlas;

    function disposeCustomTextures():void;

    function addEventListener(type:String, listener:Function):void;

    function removeEventListener(type:String, listener:Function):void;
}
}

