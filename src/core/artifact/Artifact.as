package core.artifact {
	import core.scene.Game;
	
	public class Artifact {
		public static const TYPE_CORROSIVE_ADD:String = "corrosiveAdd";
		public static const TYPE_CORROSIVE_ADD_SUPERIOR:String = "corrosiveAdd2";
		public static const TYPE_CORROSIVE_ADD_EXCEPTIONAL:String = "corrosiveAdd3";
		public static const TYPE_CORROSIVE_MULTI:String = "corrosiveMulti";
		public static const TYPE_KINETIC_ADD:String = "kineticAdd";
		public static const TYPE_KINETIC_ADD_SUPERIOR:String = "kineticAdd2";
		public static const TYPE_KINETIC_ADD_EXCEPTIONAL:String = "kineticAdd3";
		public static const TYPE_KINETIC_MULTI:String = "kineticMulti";
		public static const TYPE_ENERGY_ADD:String = "energyAdd";
		public static const TYPE_ENERGY_ADD_SUPERIOR:String = "energyAdd2";
		public static const TYPE_ENERGY_ADD_EXCEPTIONAL:String = "energyAdd3";
		public static const TYPE_ENERGY_MULTI:String = "energyMulti";
		public static const TYPE_CORROSIVE_RESIST:String = "corrosiveResist";
		public static const TYPE_KINETIC_RESIST:String = "kineticResist";
		public static const TYPE_ENERGY_RESIST:String = "energyResist";
		public static const TYPE_SHIELD_ADD:String = "shieldAdd";
		public static const TYPE_SHIELD_ADD_SUPERIOR:String = "shieldAdd2";
		public static const TYPE_SHIELD_ADD_EXCEPTIONAL:String = "shieldAdd3";
		public static const TYPE_SHIELD_MULTI:String = "shieldMulti";
		public static const TYPE_SHIELD_REGEN:String = "shieldRegen";
		public static const TYPE_HEALTH_ADD:String = "healthAdd";
		public static const TYPE_HEALTH_ADD_SUPERIOR:String = "healthAdd2";
		public static const TYPE_HEALTH_ADD_EXCEPTIONAL:String = "healthAdd3";
		public static const TYPE_HEALTH_MULTI:String = "healthMulti";
		public static const TYPE_ARMOR_ADD:String = "armorAdd";
		public static const TYPE_ARMOR_ADD_SUPERIOR:String = "armorAdd2";
		public static const TYPE_ARMOR_ADD_EXCEPTIONAL:String = "armorAdd3";
		public static const TYPE_ARMOR_MULTI:String = "armorMulti";
		public static const TYPE_ALL_ADD:String = "allAdd";
		public static const TYPE_ALL_ADD_SUPERIOR:String = "allAdd2";
		public static const TYPE_ALL_ADD_EXCEPTIONAL:String = "allAdd3";
		public static const TYPE_ALL_MULTI:String = "allMulti";
		public static const TYPE_ALL_RESIST:String = "allResist";
		public static const TYPE_SPEED:String = "speed";
		public static const TYPE_SPEED_SUPERIOR:String = "speed2";
		public static const TYPE_SPEED_EXCEPTIONAL:String = "speed3";
		public static const TYPE_REFIRE:String = "refire";
		public static const TYPE_REFIRE_SUPERIOR:String = "refire2";
		public static const TYPE_REFIRE_EXCEPTIONAL:String = "refire3";
		public static const TYPE_CONV_HP:String = "convHp";
		public static const TYPE_CONV_SHIELD:String = "convShield";
		public static const TYPE_POWER_REG:String = "powerReg";
		public static const TYPE_POWER_REG_SUPERIOR:String = "powerReg2";
		public static const TYPE_POWER_REG_EXCEPTIONAL:String = "powerReg3";
		public static const TYPE_POWER_MAX:String = "powerMax";
		public static const TYPE_COOLDOWN:String = "cooldown";
		public static const TYPE_COOLDOWN_SUPERIOR:String = "cooldown2";
		public static const TYPE_COOLDOWN_EXCEPTIONAL:String = "cooldown3";
		public static const MAX_UPGRADES:int = 10;
		public static var currentTypeOrder:String = "healthAdd";
		private var colors:Array = [0xaaaaaa,0x4488ff,0x44ee44,0xff44ff,16761634];
		public var name:String;
		public var id:String;
		public var bitmap:String;
		public var level:int;
		public var levelPotential:int;
		public var revealed:Boolean;
		public var upgraded:int;
		public var upgrading:Boolean = false;
		public var upgradeTime:Number;
		public var stats:Vector.<ArtifactStat> = new Vector.<ArtifactStat>();
		
		public function Artifact(obj:Object) {
			super();
			this.id = obj.key;
			this.name = obj.name;
			this.bitmap = obj.bitmap;
			this.level = obj.level;
			this.levelPotential = obj.levelPotential == null ? obj.level : obj.levelPotential;
			this.revealed = obj.revealed;
			this.upgraded = obj.upgraded;
			for each(var _local2:* in obj.stats) {
				stats.push(new ArtifactStat(_local2.type,_local2.value));
			}
		}
		
		public static function orderStat(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local3:Number = a.getStat(Artifact.currentTypeOrder);
			var _local4:Number = b.getStat(Artifact.currentTypeOrder);
			if(_local3 < _local4) {
				return 1;
			}
			if(_local3 > _local4) {
				return -1;
			}
			return 0;
		}
		
		public static function orderHighestLevel(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local4:int = a.level;
			var _local3:int = b.level;
			if(_local4 > _local3) {
				return -1;
			}
			if(_local4 < _local3) {
				return 1;
			}
			return 0;
		}
		
		public static function orderStatCountAsc(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local3:Number = a.stats.length;
			var _local4:Number = b.stats.length;
			if(_local3 > _local4) {
				return 1;
			}
			if(_local3 < _local4) {
				return -1;
			}
			return 0;
		}
		
		public static function orderStatCountDesc(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local3:Number = a.stats.length;
			var _local4:Number = b.stats.length;
			if(_local3 < _local4) {
				return 1;
			}
			if(_local3 > _local4) {
				return -1;
			}
			return 0;
		}
		
		public static function orderLevelHigh(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local3:Number = a.level;
			var _local4:Number = b.level;
			if(_local3 < _local4) {
				return 1;
			}
			if(_local3 > _local4) {
				return -1;
			}
			return 0;
		}
		
		public static function orderLevelLow(a:Artifact, b:Artifact) : int {
			if(!a.revealed || !b.revealed) {
				return orderRevealed(a,b);
			}
			var _local3:Number = a.level;
			var _local4:Number = b.level;
			if(_local3 > _local4) {
				return 1;
			}
			if(_local3 < _local4) {
				return -1;
			}
			return 0;
		}
		
		public static function orderRevealed(a:Artifact, b:Artifact) : int {
			if(!a.revealed && b.revealed) {
				return 1;
			}
			if(a.revealed && !b.revealed) {
				return -1;
			}
			return 0;
		}
		
		public function getStat(type:String) : Number {
			var _local4:int = 0;
			var _local3:ArtifactStat = null;
			var _local2:Number = 0;
			_local4 = 0;
			while(_local4 < stats.length) {
				_local3 = stats[_local4];
				if(_local3.type.indexOf(type) != -1) {
					_local2 += _local3.value;
				}
				_local4++;
			}
			return _local2;
		}
		
		public function getColor() : uint {
			return colors[stats.length - 1];
		}
		
		public function get isRestricted() : Boolean {
			var _local1:int = Game.instance.me.level;
			var _local2:int = Math.ceil(1.2 * _local1 + 10);
			if(_local2 > 150) {
				_local2 = 150;
			}
			return levelPotential > _local2;
		}
		
		public function get requiredPlayerLevel() : int {
			return Math.ceil((levelPotential - 10) / 1.2);
		}
	}
}

