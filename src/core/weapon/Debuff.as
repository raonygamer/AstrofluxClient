package core.weapon
{
	import generics.Localize;
	
	public class Debuff
	{
		public static const TOTALTYPES:int = 12;
		public static const DOT:int = 0;
		public static const DOT_STACKING:int = 1;
		public static const BOMB:int = 2;
		public static const REDUCE_ARMOR:int = 3;
		public static const BURN:int = 4;
		public static const DISABLE_REGEN:int = 5;
		public static const DISABLE_HEAL:int = 6;
		public static const REDUCED_DAMAGE:int = 7;
		public static const REDUCED_KINETIC_RESIST:int = 8;
		public static const REDUCED_ENERGY_RESIST:int = 9;
		public static const REDUCED_CORROSIVE_RESIST:int = 10;
		public static const SLOW_DOWN:int = 11;
		
		public function Debuff()
		{
			super();
		}
		
		public static function debuffText(debuffType:int, debuffDuration:int, debuffValue:Damage) : String
		{
			var _loc5_:String = "";
			var _loc4_:String = "";
			if(debuffType == 0 || debuffType == 1)
			{
				_loc4_ = " over";
				_loc5_ += debuffValue.debuffdamageText(debuffDuration,debuffDuration,_loc4_);
				if(debuffType == 1)
				{
					_loc5_ += Localize.t("\nThe debuff stacks.\n");
				}
			}
			else if(debuffType == 2)
			{
				_loc4_ = " after";
				_loc5_ += debuffValue.debuffdamageText(3,debuffDuration,_loc4_);
			}
			else if(debuffType == 3)
			{
				_loc5_ += Localize.t("<FONT COLOR=\'#eeeeee\'>[value]</FONT> reduced armor per stack for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
				_loc5_ = _loc5_ + Localize.t("\nCan reduce armor below zero for a maximum bonus of +50%.\n");
				_loc5_ = _loc5_ + Localize.t("\nThe debuff stacks up to 100x.\n");
			}
			else if(debuffType == 4)
			{
				_loc4_ = " over";
				_loc5_ += debuffValue.debuffdamageText(0.5 * debuffDuration,debuffDuration,_loc4_);
				_loc5_ = _loc5_ + Localize.t("\nThe debuff decays over time\n");
			}
			else if(debuffType == 5)
			{
				_loc5_ += Localize.t("Disables shield regeneration for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[duration]",debuffDuration);
			}
			else if(debuffType == 6)
			{
				_loc5_ += Localize.t("Disables healing for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[duration]",debuffDuration);
			}
			else if(debuffType == 7)
			{
				_loc5_ += Localize.t("Reduces target\'s damage by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			else if(debuffType == 8)
			{
				_loc5_ += Localize.t("Reduces target\'s <FONT COLOR=\'#00ffff\'>Kinetic</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			else if(debuffType == 9)
			{
				_loc5_ += Localize.t("Reduces target\'s <FONT COLOR=\'#ff030d\'>Energy</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			else if(debuffType == 10)
			{
				_loc5_ += Localize.t("Reduces target\'s <FONT COLOR=\'#009900\'>Corrosive</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			else if(debuffType == 11)
			{
				_loc5_ += Localize.t("Reduces target\'s speed by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			return _loc5_;
		}
	}
}

