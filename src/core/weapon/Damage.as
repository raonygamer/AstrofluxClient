package core.weapon
{
	import generics.Localize;
	
	public class Damage
	{
		public static const SINGLETYPES:int = 5;
		
		public static const TOTALTYPES:int = 10;
		
		public static const KINETIC:int = 0;
		
		public static const ENERGY:int = 1;
		
		public static const CORROSIVE:int = 2;
		
		public static const KINNETICENERGY:int = 3;
		
		public static const CORROSIVEKINNETIC:int = 4;
		
		public static const ALL:int = 5;
		
		public static const HEAL:int = 6;
		
		public static const KINNETICENERGYCORROSIVE:int = 7;
		
		public static const DONT_SCALE:int = 8;
		
		public static const ENERGYCORROSIVE:int = 9;
		
		public static const RESISTANCE_CAP:int = 75;
		
		public static const TYPE:Vector.<String> = Vector.<String>(["Kinetic","Energy","Corrosive","50% Kinetic + 50% Energy","50% Corrosive + 50% Kinetic","","Health","33% Energy + 33% Kinetic + 33% Corrosive","None","50% Energy + 50% Corrosive"]);
		
		public static const TYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#00ffff\'>Kinetic</FONT> + <FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT> + <FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ffffff\'>All</FONT>","<FONT COLOR=\'#00ff00\'>Health</FONT>","<FONT COLOR=\'#00ffff\'>Kinetic</FONT> + <FONT COLOR=\'#ff030d\'>Energy</FONT> + <FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#ff0000\'>Don\'t scale</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT> + <FONT COLOR=\'#009900\'>Corrosive</FONT>"]);
		
		public static const SINGLETYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#00ff00\'>Health</FONT>","<FONT COLOR=\'#ff0000\'>Special</FONT>"]);
		
		public static const stats:Vector.<Vector.<Number>> = Vector.<Vector.<Number>>([Vector.<Number>([1,0,0,0,0]),Vector.<Number>([0,1,0,0,0]),Vector.<Number>([0,0,1,0,0]),Vector.<Number>([0.5,0.5,0,0,0]),Vector.<Number>([0.5,0,0.5,0,0]),Vector.<Number>([1,1,1,0,0]),Vector.<Number>([0,0,0,1,0]),Vector.<Number>([0.33,0.33,0.33,0,0]),Vector.<Number>([0,0,0,0,1]),Vector.<Number>([0,0.5,0.5,0,0])]);
		
		public var type:int;
		
		private var damage:Vector.<Number>;
		
		private var damageBase:Vector.<Number>;
		
		public function Damage(dmg:Number, type:int)
		{
			var _loc3_:int = 0;
			super();
			this.type = type;
			damage = new Vector.<Number>();
			damageBase = new Vector.<Number>();
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				damageBase.push(dmg * stats[type][_loc3_]);
				damage.push(dmg * stats[type][_loc3_]);
				_loc3_++;
			}
		}
		
		public function dmg() : Number
		{
			var _loc1_:int = 0;
			var _loc2_:Number = 0;
			_loc1_ = 0;
			while(_loc1_ < 5)
			{
				_loc2_ += damage[_loc1_];
				_loc1_++;
			}
			return _loc2_;
		}
		
		public function damageText() : String
		{
			var _loc1_:int = 0;
			var _loc2_:String = "";
			_loc1_ = 0;
			while(_loc1_ < 3)
			{
				if(damage[_loc1_] > 0)
				{
					if(_loc2_ == "")
					{
						_loc2_ += "Deals: ";
					}
					else
					{
						_loc2_ += " + ";
					}
					_loc2_ += "<FONT COLOR=\'#eeeeee\'>" + damage[_loc1_].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_loc1_] + " Damage";
				}
				_loc1_++;
			}
			if(damage[_loc1_] > 0)
			{
				_loc2_ += "Repairs: <FONT COLOR=\'#eeeeee\'>" + damage[_loc1_].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_loc1_];
			}
			if(_loc2_ != "")
			{
				_loc2_ += " per hit. \n";
			}
			return _loc2_;
		}
		
		public function debuffdamageText(debuffMod:Number, debuffDuration:int, s:String) : String
		{
			var _loc4_:int = 0;
			var _loc5_:String = "";
			_loc4_ = 0;
			while(_loc4_ < 3)
			{
				if(damage[_loc4_] > 0)
				{
					_loc5_ += Localize.t("Deals <FONT COLOR=\'#eeeeee\'>[damage]</FONT> [type] " + s + " <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[damage]",Math.ceil(debuffMod * damage[_loc4_]).toFixed(0)).replace("[type]",Damage.SINGLETYPE_HTML[_loc4_]).replace("[duration]",debuffDuration);
				}
				_loc4_++;
			}
			if(damage[_loc4_] > 0)
			{
				_loc5_ += Localize.t("Repairs <FONT COLOR=\'#eeeeee\'>[damage]</FONT> [type] " + s + " <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[damage]",Math.ceil(debuffMod * damage[_loc4_]).toFixed(0)).replace("[type]",Damage.SINGLETYPE_HTML[_loc4_]).replace("[duration]",debuffDuration);
			}
			return _loc5_;
		}
		
		public function setBaseDmg(dmg:Number) : void
		{
			var _loc2_:int = 0;
			if(type == 8)
			{
				return;
			}
			_loc2_ = 0;
			while(_loc2_ < 5)
			{
				damageBase[_loc2_] = dmg * stats[type][_loc2_];
				damage[_loc2_] = dmg * stats[type][_loc2_];
				_loc2_++;
			}
		}
		
		public function addBaseDmg(dmg:Number, type:int = -1) : void
		{
			var _loc3_:int = 0;
			if(type == 8)
			{
				return;
			}
			if(type == -1)
			{
				type = this.type;
			}
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				var _loc4_:* = _loc3_;
				var _loc5_:* = damage[_loc4_] + dmg * stats[type][_loc3_];
				damage[_loc4_] = _loc5_;
				damageBase[_loc3_] += dmg * stats[type][_loc3_];
				_loc3_++;
			}
		}
		
		public function addBasePercent(percent:Number, type:int = -1) : void
		{
			var _loc3_:int = 0;
			if(type == 8)
			{
				return;
			}
			if(type == -1)
			{
				type = this.type;
			}
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				var _loc4_:* = _loc3_;
				var _loc5_:* = damage[_loc4_] + damageBase[_loc3_] * percent * stats[type][_loc3_] / 100;
				damage[_loc4_] = _loc5_;
				damageBase[_loc3_] += damageBase[_loc3_] * percent * stats[type][_loc3_] / 100;
				_loc3_++;
			}
		}
		
		public function addDmgInt(dmg:int, type:int = -1) : void
		{
			var _loc3_:int = 0;
			if(type == -1)
			{
				type = this.type;
			}
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				if(damage[_loc3_] > 0)
				{
					var _loc4_:* = _loc3_;
					var _loc5_:* = damage[_loc4_] + dmg * stats[type][_loc3_];
					damage[_loc4_] = _loc5_;
				}
				_loc3_++;
			}
		}
		
		public function addDmgPercent(bonus:Number, type:int = -1) : void
		{
			var _loc3_:int = 0;
			if(type == -1)
			{
				type = this.type;
			}
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				if(stats[type][_loc3_] > 0)
				{
					var _loc4_:* = _loc3_;
					var _loc5_:* = damage[_loc4_] + damageBase[_loc3_] * bonus / 100;
					damage[_loc4_] = _loc5_;
				}
				_loc3_++;
			}
		}
		
		public function addLevelBonus(level:int, bonus:Number) : void
		{
			var _loc3_:int = 0;
			if(type == 8)
			{
				return;
			}
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				damage[_loc3_] = damageBase[_loc3_] * (100 + bonus * (level - 1)) / 100;
				damageBase[_loc3_] = damageBase[_loc3_] * (100 + bonus * (level - 1)) / 100;
				_loc3_++;
			}
		}
	}
}

