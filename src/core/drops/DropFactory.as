package core.drops {
import core.scene.Game;

import data.*;

import sound.ISound;
import sound.SoundLocator;

public class DropFactory {
    public static function createDrop(key:String, g:Game):Drop {
        var _loc4_:IDataManager = DataLocator.getService();
        var _loc3_:Object = _loc4_.loadKey("Drops", key);
        return setDropProps(g, _loc3_, key);
    }

    public static function createDropFromCargo(name:String, g:Game):Drop {
        var _loc4_:Object = null;
        var _loc5_:IDataManager = DataLocator.getService();
        var _loc3_:Object = _loc5_.loadRange("Drops", "name", name);
        for (var _loc6_ in _loc3_) {
            _loc4_ = _loc3_[_loc6_];
            if (_loc4_.name == name) {
                return setDropProps(g, _loc4_, _loc6_.toString());
            }
        }
        return null;
    }

    public static function setDropProps(g:Game, obj:Object, key:String):Drop {
        var _loc4_:Drop = g.dropManager.getDrop();
        _loc4_.obj = obj;
        _loc4_.name = obj.name;
        _loc4_.key = key;
        _loc4_.collisionRadius = obj.collisionRadius;
        _loc4_.switchTexturesByObj(obj);
        var _loc5_:ISound = SoundLocator.getService();
        _loc5_.preCacheSound("05TMoG1kxEiXVZJ_OPhD_A", null);
        return _loc4_;
    }

    public function DropFactory() {
        super();
    }
}
}

