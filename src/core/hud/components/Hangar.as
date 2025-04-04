package core.hud.components {
import core.hud.components.hangar.SkinItem;
import core.player.FleetObj;
import core.scene.Game;
import core.ship.ShipFactory;
import core.solarSystem.Body;

import feathers.controls.List;
import feathers.controls.ScrollContainer;
import feathers.data.ListCollection;

import generics.Localize;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.filters.ColorMatrixFilter;

import textures.ITextureManager;
import textures.TextureLocator;

public class Hangar extends Sprite {
    private const MODE_SHOP:int = 1;
    private const MODE_SWITCH_SKIN:int = 2;

    public function Hangar(g:Game, body:Body = null) {
        super();
        this.g = g;
        this.body = body;
        if (body == null) {
            mode = 2;
        } else {
            mode = 1;
        }
        textureManager = TextureLocator.getService();
        var _loc3_:Text = new Text();
        _loc3_.size = 36;
        mode == 1 ? (_loc3_.text = Localize.t("Hangar")) : (_loc3_.text = Localize.t("Fleet"));
        _loc3_.y = 60;
        _loc3_.x = 60;
        addChild(_loc3_);
        selectedItemContainer.x = 330;
        selectedItemContainer.y = 50;
        selectedItemContainer.width = 390;
        selectedItemContainer.height = 500;
        addChild(selectedItemContainer);
        drawMenu();
    }
    private var textureManager:ITextureManager;
    private var selectedItemContainer:ScrollContainer = new ScrollContainer();
    private var g:Game;
    private var body:Body;
    private var mode:int;
    private var skins:Array = [];
    private var skinsItems:Array;
    private var list:List = new List();

    private function drawMenu():void {
        var s:Object;
        var f:FleetObj;
        var keys:Array;
        var skin:Object;
        var array:Array;
        var obj:Object;
        var emptySlot:Object;
        if (mode == 1) {
            for each(s in body.obj.shopItems) {
                if (s.available) {
                    skins.push(s.item);
                }
            }
        } else if (mode == 2) {
            g.me.fleet.sort(function (param1:FleetObj, param2:FleetObj):int {
                if (param1.lastUsed > param2.lastUsed) {
                    return 1;
                }
                return -1;
            });
            for each(f in g.me.fleet) {
                skins.push(f.skin);
            }
            skins.reverse();
        }
        skinsItems = g.dataManager.loadKeys("Skins", skins);
        keys = [];
        for each(skin in skinsItems) {
            if (skin.payVaultItem != null) {
                keys.push(skin.payVaultItem);
            }
        }
        if (mode == 1) {
            array = g.dataManager.loadKeys("PayVaultItems", keys);
            for each(obj in array) {
                if (obj != null) {
                    for each(skin in skinsItems) {
                        if (skin.payVaultItem == obj.key) {
                            skin.price = obj.PriceCoins;
                            if (g.salesManager.isSkinSale(skin.key)) {
                                skin.salePrice = g.salesManager.getSkinSale(skin.key).salePrice;
                            }
                        }
                    }
                }
            }
            skinsItems.sortOn("price", 16);
            drawList();
        } else if (mode == 2) {
            if (skinsItems.length == 1) {
                emptySlot = {
                    "name": Localize.t("Empty Slot"),
                    "emptySlot": true,
                    "ship": skinsItems[0].ship
                };
                skinsItems.push(emptySlot);
            }
            drawList();
        }
    }

    private function drawList():void {
        var _loc7_:int = 0;
        var _loc4_:Object = null;
        var _loc10_:FleetObj = null;
        var _loc8_:Object = null;
        var _loc11_:Object = null;
        var _loc5_:Sprite = null;
        var _loc2_:Image = null;
        var _loc6_:int = 0;
        var _loc1_:Quad = null;
        var _loc9_:ColorMatrixFilter = null;
        _loc7_ = 0;
        while (_loc7_ < skinsItems.length) {
            _loc4_ = skinsItems[_loc7_];
            _loc10_ = g.me.getFleetObj(_loc4_.key);
            _loc8_ = g.dataManager.loadKey("Ships", _loc4_.ship);
            _loc11_ = g.dataManager.loadKey("Images", _loc8_.bitmap);
            _loc5_ = new Sprite();
            _loc2_ = new Image(textureManager.getTextureMainByTextureName(_loc11_.textureName + "1"));
            _loc6_ = _loc2_.height % 2 == 0 ? _loc2_.height : _loc2_.height + 1;
            _loc1_ = new Quad(40, _loc6_, 0);
            _loc1_.alpha = 0;
            if (_loc4_.emptySlot) {
                _loc9_ = new ColorMatrixFilter();
                _loc9_.adjustSaturation(-1);
                _loc9_.adjustBrightness(-0.35);
                _loc9_.adjustHue(0.75);
                _loc2_.filter = _loc9_;
                _loc2_.filter.cache();
            }
            if (mode == 2 && !_loc4_.emptySlot) {
                _loc2_.filter = ShipFactory.createPlayerShipColorMatrixFilter(_loc10_);
            }
            _loc5_.addChild(_loc1_);
            _loc5_.addChild(_loc2_);
            _loc4_.icon = _loc5_;
            _loc7_++;
        }
        var _loc3_:ListCollection = new ListCollection(skinsItems);
        list.width = 270;
        list.height = 400;
        list.y = 140;
        list.x = 50;
        list.styleNameList.add("shop");
        addChild(list);
        list.dataProvider = _loc3_;
        list.itemRendererProperties.labelField = "name";
        list.addEventListener("change", onSelect);
        setSelectedItem();
    }

    private function setSelectedItem():void {
        var _loc1_:* = null;
        if (mode == 1) {
            _loc1_ = skinsItems.length > 0 ? skinsItems[0] : null;
        } else if (mode == 2) {
            for each(var _loc2_ in skinsItems) {
                if (_loc2_.key == g.me.activeSkin) {
                    _loc1_ = _loc2_;
                    break;
                }
            }
        }
        if (_loc1_) {
            list.selectedItem = _loc1_;
        }
    }

    private function onSelect(event:Event):void {
        var _loc2_:Sprite = null;
        var _loc3_:Text = null;
        var _loc4_:List = List(event.currentTarget);
        selectedItemContainer.removeChildren(0, -1, true);
        var _loc5_:int = 0;
        if (mode == 1) {
            _loc5_ = 1;
        }
        if (_loc4_.selectedItem.emptySlot) {
            _loc2_ = new Sprite();
            _loc3_ = new Text(15, 110);
            _loc3_.text = Localize.t("Visit the hangar to get more ships.");
            _loc3_.size = 14;
            _loc3_.width = 370;
            _loc2_.addChild(_loc3_);
            selectedItemContainer.addChild(_loc2_);
        } else {
            selectedItemContainer.addChild(new SkinItem(g, _loc4_.selectedItem, _loc5_));
        }
    }
}
}

