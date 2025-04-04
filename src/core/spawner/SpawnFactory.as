package core.spawner {
import core.boss.Boss;
import core.scene.Game;

public class SpawnFactory {
    public static function createSpawner(obj:Object, key:String, g:Game, b:Boss = null):Spawner {
        var _loc5_:Spawner = g.spawnManager.getSpawner(obj.type);
        _loc5_.obj = obj;
        _loc5_.isHostile = true;
        if (obj.hasOwnProperty("AIFaction1") && obj.AIFaction1 != "") {
            _loc5_.factions.push(obj.AIFaction1);
        }
        if (obj.hasOwnProperty("AIFaction2") && obj.AIFaction2 != "") {
            _loc5_.factions.push(obj.AIFaction2);
        }
        _loc5_.bodyName = obj.name;
        _loc5_.key = key;
        _loc5_.objKey = obj.key;
        _loc5_.innerRadius = obj.innerRadius;
        _loc5_.outerRadius = obj.outerRadius;
        _loc5_.collisionRadius = obj.collisionRadius;
        _loc5_.orbitRadius = obj.orbitRadius;
        _loc5_.spawnerType = obj.type;
        if (_loc5_.orbitRadius == 0) {
            _loc5_.angleVelocity = 0;
        } else {
            _loc5_.angleVelocity = 1 / (_loc5_.orbitRadius * 3.141592653589793);
        }
        _loc5_.rotationSpeed = 0;
        _loc5_.hidden = obj.hidden;
        _loc5_.level = obj.level;
        _loc5_.hp = obj.hp;
        _loc5_.hpMax = _loc5_.hp;
        _loc5_.shieldHp = obj.shieldHp;
        _loc5_.shieldHpMax = _loc5_.shieldHp;
        _loc5_.tryAdjustUberStats(b);
        _loc5_.initialHardenedShield = b == null ? true : false;
        _loc5_.explosionSound = obj.explosionSound;
        _loc5_.explosionEffect = obj.explosionEffect;
        if (_loc5_.isMech() && obj.explosionEffect == null) {
            _loc5_.explosionEffect = "Vk5Hgk-n2UqelveFMqdCfw";
        } else if (_loc5_.spawnerType == "organic" && obj.explosionEffect == null) {
            _loc5_.explosionEffect = "QZPBVWcMEUqxnySWvkwTAw";
        }
        _loc5_.switchTexturesByObj(obj);
        if (obj.turrets != null) {
            _loc5_.addTurrets(obj);
        }
        _loc5_.alive = true;
        return _loc5_;
    }

    public function SpawnFactory() {
        super();
    }
}
}

