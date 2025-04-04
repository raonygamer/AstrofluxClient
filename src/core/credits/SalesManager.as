package core.credits {
import core.scene.Game;

import playerio.Message;

public class SalesManager {
    public static const TYPE_FLUX:String = "flux";
    public static const TYPE_ITEM:String = "item";
    public static const TYPE_SPECIAL_SKIN:String = "sskin";
    public static const TYPE_PACKAGE:String = "pack";
    public static var eventList:Vector.<SaleEvent> = null;

    public static function isSalePeriod():Boolean {
        var _loc2_:SaleEvent = null;
        if (eventList == null) {
            eventList = new Vector.<SaleEvent>();
            _loc2_ = new SaleEvent(2016, 10, 28, 7, 96);
            eventList.push(_loc2_);
        }
        for each(var _loc1_ in eventList) {
            if (_loc1_.isNow()) {
                return true;
            }
        }
        return false;
    }

    public function SalesManager(g:Game) {
        super();
        this.g = g;
    }
    public var saleList:Vector.<Sale> = new Vector.<Sale>();
    private var g:Game;

    public function refresh():void {
        g.rpc("refreshSales", listArrived);
    }

    public function isSkinSale(key:String = null):Boolean {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "item" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return true;
            }
        }
        return false;
    }

    public function getSkinSale(key:String):Sale {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "item" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return _loc2_;
            }
        }
        return null;
    }

    public function isPackageSale(key:String = null):Boolean {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "pack" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return true;
            }
        }
        return false;
    }

    public function getPackageSale(key:String):Sale {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "pack" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return _loc2_;
            }
        }
        return null;
    }

    public function isSpecialSkinSale(key:String = null):Boolean {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "sskin" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return true;
            }
        }
        return false;
    }

    public function getSpecialSkinSale(key:String = null):Boolean {
        for each(var _loc2_ in saleList) {
            if (_loc2_.type == "sskin" && _loc2_.isNow() && (key == null || _loc2_.key == key || _loc2_.vaultKey == key)) {
                return _loc2_;
            }
        }
        return null;
    }

    public function isFluxSale():Boolean {
        for each(var _loc1_ in saleList) {
            if (_loc1_.type == "flux" && _loc1_.isNow()) {
                return true;
            }
        }
        return false;
    }

    public function getSkinSales():Vector.<Sale> {
        var _loc2_:Vector.<Sale> = new Vector.<Sale>();
        for each(var _loc1_ in saleList) {
            if (_loc1_.type == "item" && _loc1_.isNow()) {
                _loc2_.push(_loc1_);
            }
        }
        return _loc2_;
    }

    public function getSpecialSkinSales():Vector.<Sale> {
        var _loc2_:Vector.<Sale> = new Vector.<Sale>();
        for each(var _loc1_ in saleList) {
            if (_loc1_.type == "sskin" && _loc1_.isNow()) {
                _loc2_.push(_loc1_);
            }
        }
        return _loc2_;
    }

    public function getPackageSales():Vector.<Sale> {
        var _loc2_:Vector.<Sale> = new Vector.<Sale>();
        for each(var _loc1_ in saleList) {
            if (_loc1_.type == "pack" && _loc1_.isNow()) {
                _loc2_.push(_loc1_);
            }
        }
        return _loc2_;
    }

    public function isSale():Boolean {
        for each(var _loc1_ in saleList) {
            if (_loc1_.isNow()) {
                return true;
            }
        }
        return false;
    }

    public function getFluxSale():Sale {
        for each(var _loc1_ in saleList) {
            if (_loc1_.type == "flux" && _loc1_.isNow()) {
                return _loc1_;
            }
        }
        return null;
    }

    private function listArrived(m:Message):void {
        var _loc3_:int = 0;
        var _loc2_:Sale = null;
        _loc3_ = 0;
        while (_loc3_ < m.length) {
            _loc2_ = new Sale(g);
            _loc2_.type = m.getString(_loc3_++);
            _loc2_.startTime = m.getNumber(_loc3_++);
            _loc2_.endTime = m.getNumber(_loc3_++);
            _loc2_.key = m.getString(_loc3_++);
            _loc2_.vaultKey = m.getString(_loc3_++);
            _loc2_.saleBonus = m.getInt(_loc3_++);
            _loc2_.normalPrice = m.getInt(_loc3_++);
            _loc2_.salePrice = m.getInt(_loc3_++);
            _loc2_.description = m.getString(_loc3_);
            saleList.push(_loc2_);
            _loc3_++;
        }
    }
}
}

