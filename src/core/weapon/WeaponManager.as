package core.weapon {
import core.scene.Game;

public class WeaponManager {
    public function WeaponManager(g:Game) {
        super();
        this.g = g;
    }
    public var weapons:Vector.<Weapon> = new Vector.<Weapon>();
    private var g:Game;

    public function update():void {
        var _loc2_:int = 0;
        var _loc1_:Weapon = null;
        var _loc3_:int = int(weapons.length);
        _loc2_ = _loc3_ - 1;
        while (_loc2_ > -1) {
            _loc1_ = weapons[_loc2_];
            if (!_loc1_.alive) {
                removeWeapon(_loc2_);
            }
            _loc2_--;
        }
    }

    public function getWeapon(type:String):Weapon {
        var _loc2_:Weapon = null;
        switch (type) {
            case "blaster":
                _loc2_ = new Blaster(g);
                break;
            case "instant":
                _loc2_ = new Instant(g);
                break;
            case "beam":
                _loc2_ = new Beam(g);
                break;
            case "smartGun":
                _loc2_ = new SmartGun(g);
                break;
            case "teleport":
                _loc2_ = new Teleport(g);
                break;
            case "cloak":
                _loc2_ = new Cloak(g);
                break;
            case "petSpawner":
                _loc2_ = new PetSpawner(g);
                break;
            default:
                _loc2_ = new ProjectileGun(g);
        }
        _loc2_.reset();
        weapons.push(_loc2_);
        return _loc2_;
    }

    private function removeWeapon(index:int):void {
        weapons.splice(index, 1);
    }
}
}

