package core.solarSystem
{
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	
	public class Area
	{
		public static const TOTALSKILLTYPES:int = 3;
		public static const MINEVENTS:int = 4;
		public static const TOTALSPECIALTYPES:int = 9;
		public static const SKILLTYPE:Vector.<String> = Vector.<String>(["Survival","Diplomacy","Combat"]);
		public static const SKILLTYPEHTML:Vector.<String> = Vector.<String>(["Survival","Diplomacy","Combat"]);
		public static const REWARD_ACTIONS:Vector.<Array> = Vector.<Array>([["Salvaged","Discovered","Excavated"],["Bribe","Smuggled","Traded"],["Stole","Pillaged","Robbed"]]);
		public static const SPECIALTYPE:Vector.<String> = Vector.<String>(["Cold","Heat","Radiation","First Contact","Trade","Collaboration","Kinetic Weapons","Energy Weapons","Bio Weapons"]);
		public static const SPECIALTYPEHTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#4682B4\'>" + SPECIALTYPE[0] + "</FONT>","<FONT COLOR=\'#FF2400\'>" + SPECIALTYPE[1] + "</FONT>","<FONT COLOR=\'#9CCB19\'>" + SPECIALTYPE[2] + "</FONT>","<FONT COLOR=\'#8B0000\'>" + SPECIALTYPE[3] + "</FONT>","<FONT COLOR=\'#7B0000\'>" + SPECIALTYPE[4] + "</FONT>","<FONT COLOR=\'#9151ff\'>" + SPECIALTYPE[5] + "</FONT>","<FONT COLOR=\'#ffffff\'>" + SPECIALTYPE[6] + "</FONT>","<FONT COLOR=\'#ffdfdf\'>" + SPECIALTYPE[7] + "</FONT>","<FONT COLOR=\'#23ff23\'>" + SPECIALTYPE[8] + "</FONT>"]);
		public static const SPECIALCOLORTYPE:Vector.<uint> = Vector.<uint>([4620980,16720896,10275609,9109504,8060928,9523711,0xffffff,0xffdfdf,2359075]);
		public static const COLORTYPE:Vector.<uint> = Vector.<uint>([0x55ff55,0x5555ff,0xff3333]);
		public static const COLORTYPESTR:Vector.<String> = Vector.<String>(["#55ff55","#5555ff","#ff3333"]);
		public static const COLORTYPEFILL:Vector.<uint> = Vector.<uint>([0x22bb22,0x2222bb,0xbb1111]);
		public static const SIZE:Vector.<String> = Vector.<String>(["Tiny","Small","Small","Medium","Medium","Large","Large","Very Large","Very Large","Gigantic"]);
		
		public function Area()
		{
			super();
		}
		
		public static function getSkillType(i:int) : String
		{
			return SKILLTYPE[i];
		}
		
		public static function getSkillTypeHtml(i:int) : String
		{
			return SKILLTYPEHTML[i];
		}
		
		public static function getRewardAction(type:int) : String
		{
			return REWARD_ACTIONS[type][Math.floor(Math.random() * 3)];
		}
		
		public static function getSpecialIndex(name:String) : int
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < SPECIALTYPE.length)
			{
				if(SPECIALTYPE[_loc2_] == name)
				{
					return _loc2_;
				}
				_loc2_++;
			}
			return -1;
		}
		
		public static function getSizeString(i:int) : String
		{
			return SIZE[i - 1];
		}
		
		public static function getSpecialType(i:int) : String
		{
			return SPECIALTYPE[i];
		}
		
		public static function getSpecialTypeHtml(i:int) : String
		{
			return SPECIALTYPEHTML[i];
		}
		
		public static function getTime(size:int, skillLevel:int, rewardLevel:int, types:Array, crewLevel:int = 0) : int
		{
			var _loc6_:Number = skillLevel - crewLevel;
			if(_loc6_ < -12)
			{
				_loc6_ = -12;
			}
			return (0.2 * types.length + 1) * (1 + 0.05 * _loc6_ + 0.2 * rewardLevel) * (30 * Math.pow(2,size - 1));
		}
		
		public static function getSuccessChance(skillLevel:Number, type:int, crew:CrewMember, types:Array) : Number
		{
			var _loc5_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc6_:Number = Number(crew.skills[type]);
			if(_loc6_ >= skillLevel)
			{
				_loc5_ = 0.9 + 0.02 * (_loc6_ - skillLevel);
			}
			else if(_loc6_ > skillLevel - 10)
			{
				_loc8_ = 0.1 * (_loc6_ - skillLevel + 10);
				_loc5_ = Math.acos(1 - 2 * _loc8_) / 3.141592653589793;
			}
			else
			{
				_loc5_ = 0;
			}
			for each(var _loc7_ in types)
			{
				_loc5_ *= crew.specials[_loc7_] || 0;
			}
			if(_loc5_ > 1)
			{
				_loc5_ = 1;
			}
			return _loc5_;
		}
		
		public static function injuryRiskText(areaLevel:Number, type:int, size:int, crew:CrewMember, types:Array) : TextBitmap
		{
			var _loc6_:Number = Number(crew.skills[type]);
			var _loc7_:Number = 0;
			if(_loc6_ > areaLevel)
			{
				_loc7_ = 0.01;
			}
			else if(_loc6_ > areaLevel - 46)
			{
				_loc7_ = 0.01 + 0.02 * (areaLevel - _loc6_);
			}
			else
			{
				_loc7_ = 1;
			}
			var _loc8_:Number = 0;
			for each(var _loc9_ in types)
			{
				if(Number(crew.specials[_loc9_]) < 0.5)
				{
					_loc8_ += 0.5;
				}
			}
			_loc8_ += (size - 1) * 0.05;
			_loc7_ *= 1 + _loc8_;
			var _loc10_:TextBitmap = new TextBitmap();
			if(_loc7_ > 0.75)
			{
				_loc10_.text = "Extreme";
				_loc10_.format.color = 0xff0000;
			}
			else if(_loc7_ >= 0.25)
			{
				_loc10_.text = "High";
				_loc10_.format.color = 0xff0000;
			}
			else if(_loc7_ > 0.18)
			{
				_loc10_.text = "Moderate";
				_loc10_.format.color = 0xff3300;
			}
			else if(_loc7_ > 0.1)
			{
				_loc10_.text = "Some";
				_loc10_.format.color = 0xff6600;
			}
			else if(_loc7_ > 0.05)
			{
				_loc10_.text = "Low";
				_loc10_.format.color = 0xeeee00;
			}
			else if(_loc7_ > 0.01)
			{
				_loc10_.text = "Small";
				_loc10_.format.color = 11403055;
			}
			else if(_loc7_ > 0)
			{
				_loc10_.text = "Minimal";
				_loc10_.format.color = 11403055;
			}
			else
			{
				_loc10_.text = "None";
				_loc10_.format.color = 6159370;
			}
			_loc10_.text = _loc10_.text.toLocaleUpperCase();
			return _loc10_;
		}
	}
}

