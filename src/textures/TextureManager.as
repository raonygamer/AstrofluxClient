package textures {
import data.DataLocator;
import data.IDataManager;

import debug.Console;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

import playerio.Client;
import playerio.GameFS;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class TextureManager extends starling.display.Sprite implements ITextureManager {
    private static const pathToTextures:String = "/textures/";
    public static var BASIC_TEXTURE:Texture;
    public static var BASIC_TEXTURES:Vector.<Texture>;
    private static var xmlDict:Dictionary;
    private static var textureAtlasDict:Dictionary = new Dictionary();

    public static function imageFromSprite(displayObject:DisplayObject, name:String = null):Image {
        var _loc3_:Rectangle = displayObject.getBounds(displayObject);
        var _loc4_:Image = new Image(textureFromDisplayObject(displayObject, name));
        _loc4_.x = _loc3_.x;
        _loc4_.y = _loc3_.y;
        return _loc4_;
    }

    public static function textureFromDisplayObject(displayObject:DisplayObject, name:String = null):Texture {
        var rect:Rectangle;
        var tempSprite:flash.display.Sprite;
        var bmd:BitmapData;
        var matrix:Matrix;
        var texture:Texture;
        if (name != null && Boolean(textureAtlasDict.hasOwnProperty(name)) && textureAtlasDict[name] != null) {
            return textureAtlasDict[name];
        }
        rect = displayObject.getBounds(displayObject);
        if (rect.width > 2048) {
            rect.width = 2048;
            Console.write("Bitmap too big, shrinking");
        }
        if (rect.height > 2048) {
            rect.height = 2048;
            Console.write("Bitmap too big, shrinking");
        }
        if (rect.width <= 2 || rect.height <= 2) {
            tempSprite = new flash.display.Sprite();
            tempSprite.graphics.beginFill(0xff0000);
            tempSprite.graphics.drawRect(0, 0, 50, 50);
            displayObject = tempSprite;
            rect = displayObject.getBounds(displayObject);
        }
        bmd = new BitmapData(rect.width, rect.height, true, 0);
        matrix = new Matrix();
        matrix.translate(-rect.x, -rect.y);
        bmd.draw(displayObject, matrix);
        texture = Texture.fromBitmapData(bmd, false);
        texture.root.onRestore = function ():void {
            var _loc1_:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
            var _loc2_:Matrix = new Matrix();
            _loc2_.translate(-rect.x, -rect.y);
            _loc1_.draw(displayObject, _loc2_);
            try {
                texture.root.uploadBitmapData(_loc1_);
            } catch (e:Error) {
                trace("Texture restoration failed: " + e.message);
            }
            _loc1_.dispose();
            _loc1_ = null;
        };
        bmd.dispose();
        bmd = null;
        if (name == null) {
            return texture;
        }
        textureAtlasDict[name] = texture;
        return texture;
    }

    public static function getCustomTextureFromName(name:String):Texture {
        if (textureAtlasDict.hasOwnProperty(name)) {
            return textureAtlasDict[name];
        }
        return null;
    }

    public function TextureManager(client:Client) {
        super();
        this.client = client;
        xmlDict = new Dictionary();
        var callbackQueue:flash.utils.Dictionary = new Dictionary();
        itemsArray = [];
        pLoaded = 0;
        itemsArray = [];
        totalItems = 0;
        BASIC_TEXTURE = Texture.empty(1, 1);
        BASIC_TEXTURES = Vector.<Texture>([BASIC_TEXTURE]);
        dataManager = DataLocator.getService();
    }
    private var pLoaded:int = 0;
    private var itemsArray:Array = [];
    private var totalItems:int;
    private var currItem:int = 1;
    private var currentRequest:String = "";
    private var fs:GameFS;
    private var dataManager:IDataManager;

    public function set client(value:Client):void {
        var _client:playerio.Client = value;
        fs = value.gameFS;
    }

    public function get percLoaded():int {
        return pLoaded;
    }

    public function loadTextures(itemsArray:Array):void {
        currItem = 1;
        this.itemsArray = itemsArray;
        totalItems = itemsArray.length;
        loadOne(currItem - 1, itemsArray);
    }

    public function getTextureGUIByTextureName(textureName:String):Texture {
        var _loc2_:Texture = getTextureByTextureName(textureName, "texture_gui1_test.png");
        if (_loc2_ == null) {
            _loc2_ = getTextureByTextureName(textureName, "texture_gui2.png");
        }
        return _loc2_;
    }

    public function getTextureGUIByKey(key:String):Texture {
        var _loc2_:Texture = getTextureByKey(key, "texture_gui1_test.png");
        if (_loc2_ == null) {
            _loc2_ = getTextureByKey(key, "texture_gui2.png");
        }
        return _loc2_;
    }

    public function getTextureMainByKey(textureObjKey:String):Texture {
        return getTextureByKey(textureObjKey, "texture_main_NEW.png");
    }

    public function getTexturesMainByKey(textureObjKey:String):Vector.<Texture> {
        return getTexturesByKey(textureObjKey, "texture_main_NEW.png");
    }

    public function getTextureMainByTextureName(textureName:String):Texture {
        return getTextureByTextureName(textureName, "texture_main_NEW.png");
    }

    public function getTexturesMainByTextureName(textureName:String):Vector.<Texture> {
        return getTexturesByTextureName(textureName, "texture_main_NEW.png");
    }

    public function getTextureAtlas(atlasName:String):TextureAtlas {
        return textureAtlasDict[atlasName];
    }

    public function getTexturesByKey(textureObjKey:String, atlas:String):Vector.<Texture> {
        if (textureObjKey == null || textureObjKey.length == 0) {
            Console.write("Texture key can not be null or empty.");
            return null;
        }
        var _loc3_:Object = dataManager.loadKey("Images", textureObjKey);
        if (_loc3_ == null) {
            Console.write("Texture data is null: " + textureObjKey);
            return null;
        }
        return getTexturesByTextureName(_loc3_.textureName, atlas);
    }

    public function getTextureByTextureName(textureName:String, textureAtlas:String):Texture {
        if (textureName == null || textureName.length == 0) {
            throw new Error("Texture filename can not be null or empty.");
        }
        if (textureAtlas == null || textureAtlas.length == 0) {
            throw new Error("Texture atlas can not be null or empty.");
        }
        var _loc4_:TextureAtlas = textureAtlasDict[textureAtlas];
        if (_loc4_ == null) {
            throw new Error("Texture atlas is null! key: " + textureAtlas);
        }
        textureName = textureName.replace(".png", "");
        textureName = textureName.replace(".jpg", "");
        var _loc3_:Texture = _loc4_.getTexture(textureName);
        if (_loc3_ == null) {
            _loc3_ = _loc4_.getTexture(textureName + "1");
        }
        return _loc3_;
    }

    public function getTexturesByTextureName(prefix:String, textureAtlas:String):Vector.<Texture> {
        if (prefix == null || prefix.length == 0) {
            throw new Error("Texture filename can not be null or empty.");
        }
        if (textureAtlas == null || textureAtlas.length == 0) {
            throw new Error("Texture atlas can not be null or empty.");
        }
        var _loc4_:TextureAtlas = textureAtlasDict[textureAtlas];
        if (_loc4_ == null) {
            throw new Error("Texture atlas is null! key: " + textureAtlas);
        }
        var _loc3_:Vector.<Texture> = _loc4_.getTextures(prefix.replace(".png", ""));
        if (_loc3_ == null) {
            throw new Error("Texture is null, can not be!!! FileName: " + prefix + " atlas: " + textureAtlas);
        }
        return _loc3_;
    }

    public function disposeCustomTextures():void {
        var _loc1_:Boolean = false;
        var _loc4_:TextureAtlas = null;
        var _loc2_:Texture = null;
        var _loc3_:Array = [];
        for (var _loc5_ in textureAtlasDict) {
            _loc1_ = false;
            if (_loc5_ == "texture_gui1_test.png" || _loc5_ == "texture_gui2.png" || _loc5_ == "texture_main_NEW.png" || _loc5_ == "texture_body.png") {
                _loc1_ = true;
            }
            if (!_loc1_) {
                _loc3_.push(_loc5_);
            }
        }
        for each(_loc5_ in _loc3_) {
            if (textureAtlasDict[_loc5_] is TextureAtlas) {
                _loc4_ = TextureAtlas(textureAtlasDict[_loc5_]);
                if (_loc4_ != null) {
                    _loc4_.dispose();
                    _loc4_ = null;
                    delete xmlDict[_loc5_.replace("jpg", "xml")];
                    delete textureAtlasDict[_loc5_];
                    continue;
                }
            }
            _loc2_ = Texture(textureAtlasDict[_loc5_]);
            if (_loc2_ != null) {
                _loc2_.dispose();
                _loc2_.base.dispose();
                _loc2_ = null;
                delete textureAtlasDict[_loc5_];
            }
        }
    }

    private function loadOne(what:int, itemsArray:Array):void {
        var _loc5_:Loader = null;
        var _loc3_:LoaderContext = null;
        var _loc4_:URLLoader = null;
        currentRequest = itemsArray[what].toString();
        if (currentRequest.match("png|jpg")) {
            _loc5_ = new Loader();
            _loc5_.contentLoaderInfo.addEventListener("progress", onInternalProgress);
            _loc5_.contentLoaderInfo.addEventListener("complete", onInternalComplete);
            _loc5_.contentLoaderInfo.addEventListener("ioError", onIOError);
            _loc3_ = new LoaderContext(true);
            _loc3_.imageDecodingPolicy = "onLoad";
            _loc5_.load(new URLRequest(fs.getUrl("/textures/" + itemsArray[what].toString(), Login.useSecure)), _loc3_);
        } else if (currentRequest.match("xml")) {
            _loc4_ = new URLLoader(new URLRequest(fs.getUrl("/textures/" + itemsArray[what].toString(), Login.useSecure)));
            _loc4_.addEventListener("progress", onInternalProgress);
            _loc4_.addEventListener("complete", onInternalComplete);
            _loc4_.addEventListener("ioError", onIOError);
        }
    }

    private function getTextureByKey(textureObjKey:String, atlas:String):Texture {
        if (textureObjKey == null || textureObjKey.length == 0) {
            textureObjKey = "nFdCy6w1p06Of4v-ql53fg";
        }
        var _loc3_:Object = dataManager.loadKey("Images", textureObjKey);
        if (_loc3_ == null) {
            Console.write("Texture data is null: " + textureObjKey);
        }
        return getTextureByTextureName(_loc3_.textureName, atlas);
    }

    private function onInternalProgress(e:flash.events.Event):void {
        var _loc2_:int = Math.ceil(e.target.bytesLoaded / e.target.bytesTotal * 100 * currItem / totalItems);
        if (_loc2_ > pLoaded) {
            pLoaded = _loc2_;
        }
        dispatchEvent(new starling.events.Event("preloadProgress"));
    }

    private function onInternalComplete(e:flash.events.Event):void {
        var _loc3_:Bitmap = null;
        var _loc2_:Texture = null;
        if (currentRequest.match("png|jpg")) {
            currentRequest = currentRequest.replace(".png", ".xml");
            currentRequest = currentRequest.replace(".jpg", ".xml");
            _loc3_ = e.target.content as Bitmap;
            _loc2_ = Texture.fromBitmap(_loc3_, false);
            textureAtlasDict[itemsArray[currItem - 1]] = new TextureAtlas(_loc2_, xmlDict[currentRequest]);
        } else if (currentRequest.match("xml")) {
            xmlDict[itemsArray[currItem - 1]] = new XML(e.target.data);
        }
        if (currItem == totalItems) {
            e.target.removeEventListener("progress", onInternalProgress);
            e.target.removeEventListener("complete", onInternalComplete);
            dispatchEvent(new starling.events.Event("preloadComplete"));
        } else {
            currItem += 1;
            loadOne(currItem - 1, itemsArray);
        }
    }

    private function onIOError(error:IOErrorEvent):void {
        Console.write("Error loading texture: " + error);
    }
}
}

