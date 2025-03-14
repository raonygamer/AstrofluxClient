package core.player {
	import data.DataLocator;
	import data.IDataManager;
	import playerio.Message;
	
	public class FleetObj {
		public var skin:String = "";
		public var shipHue:Number = 0;
		public var shipBrightness:Number = 0;
		public var shipSaturation:Number = 0;
		public var shipContrast:Number = 0;
		public var engineHue:Number = 0;
		public var activeWeapon:String = "";
		public var activeArtifactSetup:int;
		public var lastUsed:Number = 0;
		public var weapons:Array = [];
		public var weaponsState:Array = [];
		public var weaponsHotkeys:Array = [];
		public var techSkills:Vector.<TechSkill> = new Vector.<TechSkill>();
		public var nrOfUpgrades:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0]);
		
		public function FleetObj() {
			super();
		}
		
		public function initFromSkin(skinKey:String) : void {
			var _local4:TechSkill = null;
			var _local6:IDataManager = DataLocator.getService();
			var _local2:Object = _local6.loadKey("Skins",skinKey);
			skin = skinKey;
			var _local3:Array = _local2.upgrades;
			for each(var _local5:* in _local3) {
				_local4 = new TechSkill();
				_local4.table = _local5.table;
				_local4.tech = _local5.tech;
				_local4.name = _local5.name;
				_local4.level = _local5.level;
				techSkills.push(_local4);
				if(_local5.table == "Weapons") {
					weapons.push({"weapon":_local5.tech});
					weaponsState.push(false);
					weaponsHotkeys.push(0);
				}
			}
		}
		
		public function initFromMessage(m:Message, startIndex:int) : int {
			skin = m.getString(startIndex++);
			activeArtifactSetup = m.getInt(startIndex++);
			activeWeapon = m.getString(startIndex++);
			shipHue = m.getNumber(startIndex++);
			shipBrightness = m.getNumber(startIndex++);
			shipSaturation = m.getNumber(startIndex++);
			shipContrast = m.getNumber(startIndex++);
			engineHue = m.getNumber(startIndex++);
			lastUsed = m.getNumber(startIndex++);
			startIndex = initWeaponsFromMessage(m,startIndex);
			return initTechSkillsFromMessage(m,startIndex,skin);
		}
		
		private function initWeaponsFromMessage(m:Message, startIndex:int) : int {
			var _local4:int = 0;
			weapons = [];
			weaponsState = [];
			weaponsHotkeys = [];
			var _local3:int = m.getInt(startIndex);
			_local4 = startIndex + 1;
			while(_local4 < startIndex + _local3 * 3 + 1) {
				weapons.push({"weapon":m.getString(_local4)});
				weaponsState.push(m.getBoolean(_local4 + 1));
				weaponsHotkeys.push(m.getInt(_local4 + 2));
				_local4 += 3;
			}
			return _local4;
		}
		
		private function initTechSkillsFromMessage(m:Message, startIndex:int, skinKey:String) : int {
			var _local9:int = 0;
			var _local5:int = 0;
			var _local8:TechSkill = null;
			var _local6:int = 0;
			var _local10:int = 0;
			var _local4:int = 0;
			var _local7:int = 0;
			techSkills = new Vector.<TechSkill>();
			var _local11:int = m.getInt(startIndex);
			nrOfUpgrades = Vector.<int>([0,0,0,0,0,0,0]);
			var _local12:int = startIndex + 1;
			_local9 = 0;
			while(_local9 < _local11) {
				_local5 = m.getInt(_local12 + 3);
				_local8 = new TechSkill(m.getString(_local12),m.getString(_local12 + 1),m.getString(_local12 + 2),_local5,m.getString(_local12 + 4),m.getInt(_local12 + 5));
				_local6 = m.getInt(_local12 + 6);
				_local12 += 7;
				_local10 = 0;
				while(_local10 < _local6) {
					if(m.getString(_local12) != "") {
						_local8.addEliteTechData(m.getString(_local12),m.getInt(_local12 + 1));
					}
					_local12 += 2;
					_local10++;
				}
				techSkills.push(_local8);
				_local4 = Player.getSkinTechLevel(_local8.tech,skinKey);
				if(_local5 > _local4) {
					var _local13:* = 0;
					var _local14:* = nrOfUpgrades[_local13] + _local5;
					nrOfUpgrades[_local13] = _local14;
					if(_local5 > 0) {
						_local7 = 1;
						while(_local7 <= _local5) {
							_local14 = _local7;
							_local13 = nrOfUpgrades[_local14] + 1;
							nrOfUpgrades[_local14] = _local13;
							_local7++;
						}
					}
				}
				_local9++;
			}
			return _local12;
		}
	}
}

