package core.artifact {
	import generics.Localize;
	
	public class ArtifactStat {
		public var type:String;
		public var value:Number;
		
		public function ArtifactStat(type:String, value:Number) {
			super();
			this.type = type;
			this.value = value;
		}
		
		public static function parseTextFromStatType(type:String, value:Number) : String {
			var _local5:String = "";
			var _local3:String = "<FONT COLOR=\'#ffffff\'>";
			var _local4:String = "</FONT>";
			switch(type) {
				case "healthAdd":
				case "healthAdd2":
				case "healthAdd3":
					_local5 = _local3 + "+" + (2 * value).toFixed(1) + _local4 + " " + Localize.t("health");
					break;
				case "healthMulti":
					_local5 = _local3 + "+" + (1.35 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("health");
					break;
				case "armorAdd":
				case "armorAdd2":
				case "armorAdd3":
					_local5 = _local3 + "+" + (7.5 * value).toFixed(1) + _local4 + " " + Localize.t("armor");
					break;
				case "armorMulti":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("armor");
					break;
				case "corrosiveAdd":
				case "corrosiveAdd2":
				case "corrosiveAdd3":
					_local5 = _local3 + "+" + (4 * value).toFixed(1) + _local4 + " " + Localize.t("corrosive dmg");
					break;
				case "corrosiveMulti":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("corrosive dmg");
					break;
				case "energyAdd":
				case "energyAdd2":
				case "energyAdd3":
					_local5 = _local3 + "+" + (4 * value).toFixed(1) + _local4 + " " + Localize.t("energy dmg");
					break;
				case "energyMulti":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("energy dmg");
					break;
				case "kineticAdd":
				case "kineticAdd2":
				case "kineticAdd3":
					_local5 = _local3 + "+" + (4 * value).toFixed(1) + _local4 + " " + Localize.t("kinetic dmg");
					break;
				case "kineticMulti":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("kinetic dmg");
					break;
				case "shieldAdd":
				case "shieldAdd2":
				case "shieldAdd3":
					_local5 = _local3 + "+" + (1.75 * value).toFixed(1) + _local4 + " " + Localize.t("shield");
					break;
				case "shieldMulti":
					_local5 = _local3 + "+" + (1.35 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("shield");
					break;
				case "shieldRegen":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("shield regen");
					break;
				case "corrosiveResist":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("corrosive resist");
					break;
				case "energyResist":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("energy resist");
					break;
				case "kineticResist":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("kinetic resist");
					break;
				case "allResist":
					_local5 = _local3 + "+" + value.toFixed(1) + "%" + _local4 + " " + Localize.t("all resist");
					break;
				case "allAdd":
				case "allAdd2":
				case "allAdd3":
					_local5 = _local3 + "+" + (1.5 * value).toFixed(1) + _local4 + " " + Localize.t("to all dmg");
					break;
				case "allMulti":
					_local5 = _local3 + "+" + (1.5 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("to all dmg");
					break;
				case "speed":
				case "speed2":
				case "speed3":
					_local5 = _local3 + "+" + (0.2 * value).toFixed(2) + "%" + _local4 + " " + Localize.t("inc speed");
					break;
				case "refire":
				case "refire2":
				case "refire3":
					_local5 = _local3 + "+" + (0.30000000000000004 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("inc attack speed");
					break;
				case "convHp":
					if(0.1 * value > 100) {
						_local5 = _local3 + "-100%" + _local4 + " " + Localize.t("hp to 150% shield");
					} else {
						_local5 = _local3 + "-" + (0.1 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("hp to 150% shield");
					}
					break;
				case "convShield":
					if(0.1 * value > 100) {
						_local5 = _local3 + "-100%" + _local4 + " " + Localize.t("shield to 150% hp");
					} else {
						_local5 = _local3 + "-" + (0.1 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("shield to 150% hp");
					}
					break;
				case "powerReg":
				case "powerReg2":
				case "powerReg3":
					_local5 = _local3 + "+" + (0.15000000000000002 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("inc power regen");
					break;
				case "powerMax":
					_local5 = _local3 + "+" + (1.5 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("inc maximum power");
					break;
				case "cooldown":
				case "cooldown2":
				case "cooldown3":
					_local5 = _local3 + "+" + (0.1 * value).toFixed(1) + "%" + _local4 + " " + Localize.t("reduced cooldown");
			}
			return _local5;
		}
		
		public static function parseTextFromStatTypeShort(type:String, value:Number) : String {
			var _local3:String = "+";
			if(value < 0) {
				_local3 = "";
			}
			switch(type) {
				case "healthAdd":
				case "healthAdd2":
				case "healthAdd3":
					break;
				case "healthMulti":
					return _local3 + (1.35 * value).toFixed(1) + "% " + Localize.t("health");
				case "armorAdd":
				case "armorAdd2":
				case "armorAdd3":
					return _local3 + (7.5 * value).toFixed(0) + " " + Localize.t("armor");
				case "armorMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("armor");
				case "corrosiveAdd":
				case "corrosiveAdd2":
				case "corrosiveAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("corrosive dmg");
				case "corrosiveMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("corrosive dmg");
				case "energyAdd":
				case "energyAdd2":
				case "energyAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("energy dmg");
				case "energyMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("energy dmg");
				case "kineticAdd":
				case "kineticAdd2":
				case "kineticAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("kinetic dmg");
				case "kineticMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("kinetic dmg");
				case "shieldAdd":
				case "shieldAdd2":
				case "shieldAdd3":
					return _local3 + (2 * value).toFixed(0) + " " + Localize.t("shield");
				case "shieldMulti":
					return _local3 + (1.35 * value).toFixed(1) + "% " + Localize.t("shield");
				case "shieldRegen":
					return _local3 + value.toFixed(0) + "% " + Localize.t("shield regen");
				case "corrosiveResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("corrosive resist");
				case "energyResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("energy resist");
				case "kineticResist":
					return value.toFixed(1) + "% " + Localize.t("kinetic resist");
				case "allResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("all resist");
				case "allAdd":
				case "allAdd2":
				case "allAdd3":
					return _local3 + (1.5 * value).toFixed(1) + " " + Localize.t("to all dmg");
				case "allMulti":
					return _local3 + (1.35 * value).toFixed(1) + "% " + Localize.t("to all dmg");
				case "speed":
				case "speed2":
				case "speed3":
					return _local3 + (0.1 * value).toFixed(2) + "% " + Localize.t("speed");
				case "refire":
				case "refire2":
				case "refire3":
					return _local3 + (0.30000000000000004 * value).toFixed(1) + "% " + Localize.t("attack speed");
				case "convHp":
					if(0.1 * value > 100) {
						return "-100% " + Localize.t("hp to 150% shield");
					}
					return _local3 + (0.1 * value).toFixed(1) + "% " + Localize.t("hp to 150% shield");
					break;
				case "convShield":
					if(0.1 * value > 100) {
						return "-100% " + Localize.t("shield to 150% hp");
					}
					return _local3 + (0.1 * value).toFixed(1) + "% " + Localize.t("shield to 150% hp");
					break;
				case "powerReg":
				case "powerReg2":
				case "powerReg3":
					return _local3 + (0.1 * (1 * value)).toFixed(1) + "% " + Localize.t("power regen");
				case "powerMax":
					return _local3 + (1 * value).toFixed(1) + "% " + Localize.t("max power");
				case "cooldown":
				case "cooldown2":
				case "cooldown3":
					return "-" + (0.1 * value).toFixed(1) + "% " + Localize.t("cooldown");
				default:
					return "ERROR - artifact not found";
			}
			return _local3 + (2 * value).toFixed(0) + " " + Localize.t("health");
		}
	}
}

