package core.hud.components.credits {
import core.credits.Sale;
import core.hud.components.NativeImageButton;
import core.hud.components.SaleTimer;
import core.hud.components.Style;
import core.hud.components.Text;
import core.hud.components.dialogs.PopupMessage;
import core.scene.Game;

import facebook.FB;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import playerio.Message;
import playerio.PayVault;
import playerio.PlayerIOError;
import playerio.generated.messages.PayVaultBuyItemInfo;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;

public class CreditPackageItem extends CreditBaseItem {
    public function CreditPackageItem(g:Game, parent:starling.display.Sprite, spinner:Boolean = false) {
        super(g, parent, spinner);
    }
    public var button:NativeImageButton;
    public var buyContainer:starling.display.Sprite = new starling.display.Sprite();
    protected var descriptionContainer:starling.display.Sprite = new starling.display.Sprite();
    protected var waitingContainer:starling.display.Sprite = new starling.display.Sprite();
    protected var aquiredContainer:starling.display.Sprite = new starling.display.Sprite();
    protected var aquiredText:Text = new Text();
    protected var aquired:Boolean = false;
    protected var description:String = "";
    protected var checkoutDescription:String = "";
    protected var checkoutDescriptionShort:String = "";
    protected var preview:String = "";
    protected var buyButtonText:String = "";
    protected var itemKey:String = "";
    protected var rpcFunction:String = "";
    private var price:Text;
    private var nativeLayer:flash.display.Sprite = new flash.display.Sprite();

    override protected function load():void {
        if (g.salesManager.isPackageSale(itemKey + "_sale")) {
            itemKey += "_sale";
        }
        addBuyButton();
        addDescription();
        addAquired();
        addWaiting();
        updateAquiredText();
        updateContainers();
        super.load();
    }

    override protected function showInfo(value:Boolean):void {
        var _loc2_:Point = null;
        if (value == true) {
            Starling.current.nativeStage.addChild(nativeLayer);
        } else if (Starling.current.nativeStage.contains(nativeLayer)) {
            Starling.current.nativeStage.removeChild(nativeLayer);
        }
        button.visible = value;
        if (aquired) {
            button.visible = false;
        }
        super.showInfo(value);
        if (value == true && price != null) {
            _loc2_ = price.localToGlobal(new Point(price.x, price.y));
            if (itemKey.search("_sale") == -1) {
                button.x = _loc2_.x + price.width + 1;
                button.y = _loc2_.y - price.height + 4;
            } else {
                button.x = _loc2_.x;
                button.y = _loc2_.y - price.height + 8;
            }
        }
    }

    override public function exit():void {
        if (Starling.current.nativeStage.contains(nativeLayer)) {
            Starling.current.nativeStage.removeChild(nativeLayer);
        }
    }

    public function redraw():void {
        var _loc1_:Point = price.localToGlobal(new Point(price.x, price.y));
        button.x = _loc1_.x;
        button.y = _loc1_.y - price.height + 10;
    }

    protected function onSuccess(m:Message):void {
        updateAquiredText();
    }

    protected function addDescription():void {
        var _loc2_:int = 0;
        var _loc4_:Image = null;
        var _loc1_:Quad = null;
        var _loc3_:Text = new Text();
        _loc3_.color = 0xaaaaaa;
        _loc3_.htmlText = description;
        _loc3_.width = 5 * 60;
        _loc3_.height = 5 * 60;
        _loc3_.wordWrap = true;
        _loc3_.y = 2 * 60;
        descriptionContainer.addChild(_loc3_);
        if (preview != null) {
            _loc2_ = 4;
            _loc4_ = new Image(textureManager.getTextureGUIByTextureName(preview));
            _loc4_.x = 4;
            _loc4_.y = 0;
            _loc1_ = new Quad(_loc4_.width + 6, _loc4_.height + 6, 0xaaaaaa);
            _loc1_.x = _loc4_.x - 3;
            _loc1_.y = _loc4_.y - 3;
            descriptionContainer.addChild(_loc1_);
            descriptionContainer.addChild(_loc4_);
        }
        descriptionContainer.y = 70;
        infoContainer.addChild(descriptionContainer);
    }

    protected function addWaiting():void {
        var _loc1_:Text = new Text();
        _loc1_.text = "waiting...";
        _loc1_.x = 60;
        _loc1_.y = 20;
        waitingContainer.addChild(_loc1_);
        waitingContainer.visible = false;
        infoContainer.addChild(waitingContainer);
    }

    protected function addAquired():void {
        aquiredText.x = 0;
        aquiredText.y = 20;
        aquiredText.color = Style.COLOR_HIGHLIGHT;
        aquiredText.wordWrap = true;
        aquiredText.width = 5 * 60;
        aquiredContainer.addChild(aquiredText);
        aquiredContainer.visible = false;
        infoContainer.addChild(aquiredContainer);
    }

    protected function updateContainers():void {
        buyContainer.visible = !aquired;
        aquiredContainer.visible = aquired;
        waitingContainer.visible = false;
    }

    protected function updateAquiredText():void {
        if (aquired) {
            aquiredText.text = "Aquired!";
        }
    }

    protected function showFailed(s:String):void {
        g.showErrorDialog(s);
        buyContainer.visible = true;
        waitingContainer.visible = false;
    }

    private function addBuyButton():void {
        var obj:Object;
        var unit:String;
        var extraZero:String;
        var oldPrice:Text;
        var sale:Sale;
        var crossOver:Image;
        var saleTimer:SaleTimer;
        var bitmap:Bitmap = new EmbeddedAssets.BuyButtonBitmap();
        button = new NativeImageButton(function ():void {
            Starling.current.nativeStage.removeChild(nativeLayer);
            if (Login.currentState == "facebook") {
                onBuyFacebook();
            } else if (Login.currentState == "steam") {
                onBuySteam();
            } else if (Login.currentState == "kongregate") {
                onBuyKred();
            } else {
                onBuyPaypal();
            }
        }, bitmap.bitmapData);
        button.x = 30;
        button.y = 20;
        button.visible = false;
        nativeLayer.addChild(button);
        if (!spinner) {
            infoContainer.addChild(buyContainer);
        }
        obj = g.dataManager.loadKey("PayVaultItems", itemKey);
        unit = Login.currentState != "kongregate" ? "$" : "Kreds ";
        extraZero = Login.currentState != "kongregate" ? "" : "0";
        if (itemKey.search("_sale") == -1) {
            price = new Text();
            price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
            price.size = 16;
            price.x = 5;
            price.y = 18;
            buyContainer.addChild(price);
        } else {
            oldPrice = new Text();
            sale = g.salesManager.getPackageSale(itemKey);
            if (sale == null) {
                return;
            }
            oldPrice.text = unit + Math.floor(sale.normalPrice / 100) + extraZero;
            oldPrice.size = 18;
            oldPrice.color = 0xaaaaaa;
            oldPrice.x = 5;
            oldPrice.y = 18;
            buyContainer.addChild(oldPrice);
            crossOver = new Image(textureManager.getTextureGUIByTextureName("cross_over"));
            crossOver.x = oldPrice.x + oldPrice.width / 2;
            crossOver.y = oldPrice.y + oldPrice.height / 2;
            crossOver.pivotX = crossOver.width / 2;
            crossOver.pivotY = crossOver.height / 2;
            buyContainer.addChild(crossOver);
            price = new Text();
            price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
            price.size = 18;
            price.x = crossOver.x + crossOver.width / 2 + 7;
            price.y = 18;
            buyContainer.addChild(price);
            if (!spinner) {
                saleTimer = new SaleTimer(g, sale.startTime, sale.endTime, function ():void {
                    if (button != null) {
                        button.visible = !aquired;
                    }
                });
                saleTimer.x = price.x + 140;
                buyContainer.addChild(saleTimer);
            }
        }
        if (spinner) {
            select();
        }
    }

    private function onBuyPaypal():void {
        var popup:PopupMessage;
        g.client.payVault.getBuyDirectInfo("paypal", {
            "currency": "USD",
            "item_name": itemLabel
        }, [{"itemKey": itemKey}], function (param1:Object):void {
            navigateToURL(new URLRequest(param1.paypalurl + "&os0=" + Login.currentState + "&on0=Info"), "_blank");
        }, function (param1:PlayerIOError):void {
            g.showMessageDialog("Unable to buy item");
            Starling.current.nativeStage.addChild(nativeLayer);
        });
        popup = new PopupMessage();
        popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
        g.addChildToOverlay(popup);
        popup.addEventListener("close", (function ():* {
            var closePopup:Function;
            return closePopup = function (param1:Event):void {
                g.removeChildFromOverlay(popup);
                popup.removeEventListeners();
                onClose();
            };
        })());
    }

    private function onBuySteam():void {
        var info:Object = {
            "steamid": RymdenRunt.info.userId,
            "appid": RymdenRunt.info.appId,
            "language": "EN",
            "currency": "USD"
        };
        var vault:PayVault = g.client.payVault;
        var buyItemInfo:PayVaultBuyItemInfo = new PayVaultBuyItemInfo();
        buyItemInfo.itemKey = itemKey;
        vault.getBuyDirectInfo("steam", info, [buyItemInfo], function (param1:Object):void {
            var SteamBuySuccess:Function;
            var SteamBuyFail:Function;
            var obj:Object = param1;
            info.orderid = obj.orderid;
            SteamBuySuccess = function ():void {
                RymdenRunt.instance.removeEventListener("steambuysuccess", SteamBuySuccess);
                RymdenRunt.instance.removeEventListener("steambuyfail", SteamBuyFail);
                vault.usePaymentInfo("steam", info, function (param1:Object):void {
                    onClose();
                }, function (param1:PlayerIOError):void {
                    g.showErrorDialog(param1.message, false);
                    Starling.current.nativeStage.addChild(nativeLayer);
                });
            };
            SteamBuyFail = function ():void {
                RymdenRunt.instance.removeEventListener("steambuysuccess", SteamBuySuccess);
                RymdenRunt.instance.removeEventListener("steambuyfail", SteamBuyFail);
                Starling.current.nativeStage.addChild(nativeLayer);
            };
            RymdenRunt.instance.addEventListener("steambuysuccess", SteamBuySuccess);
            RymdenRunt.instance.addEventListener("steambuyfail", SteamBuyFail);
        }, function (param1:PlayerIOError):void {
            g.showErrorDialog("Buying package failed! " + param1.message, false);
            Starling.current.nativeStage.addChild(nativeLayer);
        });
    }

    private function onBuyFacebook():void {
        var popup:PopupMessage;
        Starling.current.nativeStage.displayState = "normal";
        g.client.payVault.getBuyDirectInfo("facebookv2", {
            "title": itemLabel,
            "description": checkoutDescription,
            "image": g.client.gameFS.getUrl("/img/techicons/" + bitmap, Login.useSecure),
            "currencies": "USD"
        }, [{"itemKey": itemKey}], function (param1:Object):void {
            var info:Object = param1;
            FB.ui(info, function (param1:Object):void {
                if (param1.status != "completed") {
                    g.showErrorDialog("Buying package failed!", false);
                    Starling.current.nativeStage.addChild(nativeLayer);
                }
            });
        }, function (param1:PlayerIOError):void {
            g.showErrorDialog("Unable to buy item!");
            Starling.current.nativeStage.addChild(nativeLayer);
        });
        popup = new PopupMessage();
        popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
        g.addChildToOverlay(popup);
        popup.addEventListener("close", (function ():* {
            var closePopup:Function;
            return closePopup = function (param1:Event):void {
                g.removeChildFromOverlay(popup);
                popup.removeEventListeners();
                onClose();
            };
        })());
    }

    private function onBuyKred():void {
        Starling.current.nativeStage.displayState = "normal";
        Login.kongregate.mtx.purchaseItems(["item" + itemKey], function (param1:Object):void {
            if (param1.success) {
                onClose(null);
            } else {
                g.showMessageDialog("Buying package failed!");
            }
        });
    }

    private function onClose(e:TouchEvent = null):void {
        g.rpc(rpcFunction, function (param1:Message):void {
            if (param1.getBoolean(0)) {
                onSuccess(param1);
            } else {
                g.showErrorDialog(param1.getString(1), true);
            }
        });
    }
}
}

