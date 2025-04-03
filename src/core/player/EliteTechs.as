package core.player
{
	import core.hud.components.techTree.EliteTechBar;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.weapon.Beam;
	import core.weapon.Damage;
	import core.weapon.ProjectileGun;
	import core.weapon.Weapon;
	import generics.Localize;
	
	public class EliteTechs
	{
		public static const MAX_LEVEL:Number = 100;
		
		public static const COST_INCREASE:Number = 1.025;
		
		public static const COST_SUM:Number = 432.548654;
		
		public static const PRIMARY_COST_SUM:Number = 3200000;
		
		public static const SECONDARY_COST_SUM:Number = 540000;
		
		public static const FLUX_COST_SUM:Number = 12000;
		
		public static const HYDROGEN_CRYSTALS:String = "d6H3w_34pk2ghaQcXYBDag";
		
		public static const PLASMA_FLUIDS:String = "H5qybQDy9UindMh9yYIeqg";
		
		public static const IRIDIUM:String = "gO_f-y0QEU68vVwJ_XVmOg";
		
		public static const WEAPON_ELITE_TECHS:Vector.<String> = Vector.<String>(["AddKineticDamage","AddEnergyDamage","AddCorrosiveDamage","AddKineticBaseDamage","AddEnergyBaseDamage","AddCorrosiveBaseDamage","AddKineticDot5","AddEnergyDot5","AddCorrosiveDot5","AddKineticDot10","AddEnergyDot10","AddCorrosiveDot10","AddKineticDot20","AddEnergyDot20","AddCorrosiveDot20","AddEnergyBurn","AddCorrosiveBurn","AddHealthVamp","AddShieldVamp","AddDualVamp","KineticPenetration","EnergyPenetration","CorrosivePenetration","AddExtraProjectiles","IncreaseDirectDamage","IncreaseDebuffDamage","IncreaseRange","IncreaseRefire","IncreaseGuidance","ReducePowerCost","DisableHealing","DisableShieldRegen","ReduceTargetDamage","ReduceTargetArmor","IncreaseAOE","AddAOE","IncreaseNrHits","IncreaseSpeed","IncreasePetHp"]);
		
		public static const WEAPON_ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Kinetic Damage","Energy Damage","Corrosive Damage","Kinetic Damage","Energy Damage","Corrosive Damage","Kinetic DoT 5 Seconds","Energy DoT 5 Seconds","Corrosive DoT 5 Seconds","Kinetic DoT 10 Seconds","Energy DoT 10 Seconds","Corrosive DoT 10 Seconds","Kinetic DoT 20 Seconds","Energy DoT 20 Seconds","Corrosive DoT 20 Seconds","Energy Burn 10 Seconds","Corrosive Burn 10 Seconds","Health Leech","Shield Leech","Health and Shield Leech","Reduce Kinetic Resitance","Reduce Energy Resitance","Reduce Corrosive Resitance","Extra Projectiles","Improved Direct Damage","Improved DoT","Improved Range","Improved Attack Speed","Improved Velocity and Guidance","Reduced the Power Cost","Disables target Healing","Disables target Shield Regen","Reduce Target Damage done","Reduce Target Armor","Improved Area Of Effect","Improved Area Of Effect","Improved Number of Hits","Increase Speed","Increase Pet HP and Shield"]);
		
		public static const ELITE_TECHS:Vector.<String> = Vector.<String>(["IncreaseShield","IncreaseShieldRegen","ConvertShield","IncreaseHealth","IncreaseArmor","ConvertHealth","IncreaseSheildDuration","ReduceSheildCooldown","IncreaseSpeedBoostAmount","IncreaseSpeedBoostDuration","ReduceSpeedBoostCooldown","IncreaseArmorConvBonus","ReduceArmorConvCooldown","IncreaseDamage","IncreaseRefire","ReducePowerCost","IncreaseDmgBoostDuration","IncreaseDmgBoostBonus","ReduceDmgBoostPowerCost","IncreaseEngineSpeed","UnbreakableArmor"]);
		
		public static const ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Maximum Shield","Shield Regen","Convert Shield","Maximum Health","Improved Armor","Convert Health","Lasting Harden Shields","Rapid Recharge Harden Sheilds","Overcharged Speed Boost","Lasting Speed Boost","Rapid Recharge Speed Boost","Optimized Repair","Rapid Recharge Repair","Over-Charged Weapons","Hyper-Charged Weapons","Optimized Weapons","Lasting Power Boost","Super Charged Power Boost","Optimized Power Boost","Improved Engines","Unbreakable Armor"]);
		
		public function EliteTechs()
		{
			super();
		}
		
		public static function getStatTextByLevel(eliteTech:String, obj:Object, level:Number) : String
		{
			var _loc11_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc12_:Object = null;
			var _loc7_:int = 0;
			var _loc8_:* = NaN;
			var _loc10_:String = "";
			if(!obj.hasOwnProperty("eliteTechs"))
			{
				return _loc10_;
			}
			var _loc4_:Object = obj.eliteTechs;
			if(!_loc4_.hasOwnProperty(eliteTech))
			{
				return _loc10_;
			}
			var _loc5_:Number = Number(_loc4_[eliteTech]);
			var _loc9_:Number = _loc5_ * level / 100;
			switch(eliteTech)
			{
				case "AddKineticDamage":
					_loc10_ += Localize.t("Adds extra [value]% Kinetic Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyDamage":
					_loc10_ += Localize.t("Adds extra [value]% Energy Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveDamage":
					_loc10_ += Localize.t("Adds extra [value]% Corrosive Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddKineticBaseDamage":
					_loc10_ += Localize.t("Adds extra [value] Kinetic Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyBaseDamage":
					_loc10_ += Localize.t("Adds extra [value] Energy Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveBaseDamage":
					_loc10_ += Localize.t("Adds extra [value] Corrosive Damage").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddKineticDot5":
					_loc10_ += Localize.t("Adds extra [value]% Kinetic Damage over 5 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyDot5":
					_loc10_ += Localize.t("Adds extra [value]% Energy Damage over 5 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveDot5":
					_loc10_ += Localize.t("Adds extra [value]% Corrosive Damage over 5 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddKineticDot10":
					_loc10_ += Localize.t("Adds extra [value]% Kinetic Damage over 10 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyDot10":
					_loc10_ += Localize.t("Adds extra [value]% Energy Damage over 10 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveDot10":
					_loc10_ += Localize.t("Adds extra [value]% Corrosive Damage over 10 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddKineticDot20":
					_loc10_ += Localize.t("Adds extra [value]% Kinetic Damage over 20 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyDot20":
					_loc10_ += Localize.t("Adds extra [value]% Energy Damage over 20 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveDot20":
					_loc10_ += Localize.t("Adds extra [value]% Corrosive Damage over 20 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddEnergyBurn":
					_loc10_ += Localize.t("Adds extra [value]% Energy Burn Damage over 10 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddCorrosiveBurn":
					_loc10_ += Localize.t("Adds extra [value]% Corrosive Burn Damage over 10 Seconds").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddHealthVamp":
					_loc10_ += Localize.t("Steals [value]% of Health Damage done to targets").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddShieldVamp":
					_loc10_ += Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddDualVamp":
					_loc10_ += Localize.t("Steals [value]% of Health Damage done to targets\n").replace("[value]",_loc9_.toFixed(2));
					_loc10_ = _loc10_ + Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]",_loc9_.toFixed(2));
					break;
				case "KineticPenetration":
					_loc10_ += Localize.t("Reduces targets Kinetic Resistance by [value]% for [value2] Seconds").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "EnergyPenetration":
					_loc10_ += Localize.t("Reduces targets Energy Resistance by [value]% for [value2] Seconds").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "CorrosivePenetration":
					_loc10_ += Localize.t("Reduces targets Corrosive Resistance by [value]% for [value2] Seconds").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "AddExtraProjectiles":
					_loc11_ = level / 100;
					_loc6_ = Number(obj.multiNrOfP);
					_loc7_ = 0;
					while(_loc7_ < 6)
					{
						_loc12_ = obj.techLevels[_loc7_];
						_loc6_ += _loc12_.incMultiNrOfP;
						_loc7_++;
					}
					_loc8_ = _loc6_;
					if(_loc6_ == 1)
					{
						if(_loc11_ < 0.5)
						{
							_loc6_ = 2;
						}
						else if(_loc11_ >= 0.5)
						{
							_loc6_ = 3;
						}
					}
					else
					{
						_loc6_ += int(Math.floor(_loc11_ * _loc6_));
					}
					_loc11_ = _loc8_ / _loc6_;
					_loc9_ = Math.abs(_loc11_ * (100 + _loc9_) - 100);
					_loc10_ += Localize.t("Adds [value2] extra projectiles, each projectile deals [value]% less damage").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",_loc6_ - _loc8_);
					break;
				case "IncreaseDirectDamage":
					_loc10_ += Localize.t("Increases Direct Damage by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseDebuffDamage":
					_loc10_ += Localize.t("Increases Debuff Damage by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseRange":
					_loc10_ += Localize.t("Increases Range by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseRefire":
					if(obj.name == "Teleport Device" || obj.name == "Bionic Teleport" || obj.name == "Cloaking Device")
					{
						_loc10_ += Localize.t("Reduce cooldown by [value]%").replace("[value]",_loc9_.toFixed(2));
					}
					else
					{
						_loc10_ += Localize.t("Increases Attack Speed by [value]%").replace("[value]",_loc9_.toFixed(2));
					}
					break;
				case "IncreaseGuidance":
					_loc10_ += Localize.t("Improves Guidance by [value]%\n").replace("[value]",_loc9_.toFixed(2));
					_loc10_ = _loc10_ + Localize.t("Improves Velocity by [value]%").replace("[value]",(0.1 * _loc9_).toFixed(2));
					break;
				case "ReducePowerCost":
					_loc10_ += Localize.t("Reduce Power Cost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "DisableHealing":
					_loc10_ += Localize.t("Disables targets from Healing for [value] seconds").replace("[value]",(1 + _loc9_).toFixed(2));
					break;
				case "DisableShieldRegen":
					_loc10_ += Localize.t("Disables targets Shield Regen for [value] seconds").replace("[value]",(1 + _loc9_).toFixed(2));
					break;
				case "ReduceTargetDamage":
					_loc10_ += Localize.t("Reduces targets Damage by [value]% for [value2] Seconds").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(2));
					break;
				case "ReduceTargetArmor":
					_loc10_ += Localize.t("Reduces targets Armor by [value]% of weapon damage for [value2] Seconds").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(2));
					break;
				case "IncreaseShield":
					_loc10_ += Localize.t("Increases Shield by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseShieldRegen":
					_loc10_ += Localize.t("Increases Shield Regeneration by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ConvertShield":
					_loc10_ += Localize.t("Sacrifice [value]% Maximum Shield to regen [value2]% of Maximum Health Regen every second").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(0.06 * _loc9_).toFixed(2));
					break;
				case "IncreaseHealth":
					_loc10_ += Localize.t("Increases Health by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseArmor":
					_loc10_ += Localize.t("Increases Armor by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ConvertHealth":
					_loc10_ += Localize.t("Sacrifice [value]% Maximum Health to increase Shield Regen by [value2]%").replace("[value]",_loc9_.toFixed(2)).replace("[value2]",(3 * _loc9_).toFixed(2));
					break;
				case "IncreaseSheildDuration":
					_loc10_ += Localize.t("Increases the Duration of Harden Shield by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ReduceSheildCooldown":
					_loc10_ += Localize.t("Decreases the Cooldown of Harden Shield by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseSpeedBoostAmount":
					_loc10_ += Localize.t("Increases the Bonus Speed gained by Speed Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseSpeedBoostDuration":
					_loc10_ += Localize.t("Increases the Duration of Speed Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ReduceSpeedBoostCooldown":
					_loc10_ += Localize.t("Decreases the Cooldown of Speed Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseArmorConvBonus":
					_loc10_ += Localize.t("Increases the Amount of Health gained by Convert by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ReduceArmorConvCooldown":
					_loc10_ += Localize.t("Decreases the Cooldown of Convert by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseDamage":
					_loc10_ += Localize.t("Increases Damage done by all Weapons by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseRefire":
					_loc10_ += Localize.t("Increases Attack Speed for all Weapons by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ReducePowerCost":
					_loc10_ += Localize.t("Reduces Power Cost of all Weapons by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseDmgBoostDuration":
					_loc10_ += Localize.t("Increases the Duration of Damage Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseDmgBoostBonus":
					_loc10_ += Localize.t("Increases the Damage Bonus gained from Damage Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "ReduceDmgBoostPowerCost":
					_loc10_ += Localize.t("Reduces the Power Penalty of Damage Boost by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "IncreaseAOE":
					_loc10_ += Localize.t("Increases area of effect radius by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "AddAOE":
					_loc10_ += Localize.t("Increases area of effect radius by [value] units").replace("[value]",(5 + _loc9_).toFixed(2));
					break;
				case "IncreaseNrHits":
					_loc10_ += Localize.t("Increases Number of Hits by [value]").replace("[value]",int(1 + _loc9_));
					break;
				case "IncreaseSpeed":
					if(obj.name == "Teleport Device" || obj.name == "Bionic Teleport")
					{
						_loc10_ += Localize.t("Increases Cast Speed by [value]%").replace("[value]",_loc9_.toFixed(2));
					}
					else
					{
						_loc10_ += Localize.t("Increases Speed by [value]%").replace("[value]",_loc9_.toFixed(2));
					}
					break;
				case "IncreasePetHp":
					_loc10_ += Localize.t("Increases Pet HP and Shield by [value]%").replace("[value]",_loc9_.toFixed(2));
				case "IncreaseEngineSpeed":
					_loc10_ += Localize.t("Increases Engine Speed by [value]%").replace("[value]",_loc9_.toFixed(2));
					break;
				case "UnbreakableArmor":
					_loc10_ += Localize.t("Armor can not be reduced below [value]% of maximum").replace("[value]",_loc9_.toFixed(2));
			}
			return _loc10_ + "\n";
		}
		
		public static function addWeaponEliteTechs(w:Weapon, obj:Object, eliteTechLevel:int, eliteTech:String) : void
		{
			var _loc10_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc5_:Beam = null;
			if(!obj.hasOwnProperty("eliteTechs"))
			{
				return;
			}
			var _loc6_:Object = obj.eliteTechs;
			if(!_loc6_.hasOwnProperty(eliteTech))
			{
				return;
			}
			var _loc7_:Number = Number(_loc6_[eliteTech]);
			var _loc9_:Number = _loc7_ * eliteTechLevel / 100;
			if(_loc7_ == 0)
			{
				return;
			}
			switch(eliteTech)
			{
				case "AddKineticDamage":
					w.dmg.addBaseDmg(0.01 * _loc9_ * w.dmg.dmg(),0);
					break;
				case "AddEnergyDamage":
					w.dmg.addBaseDmg(0.01 * _loc9_ * w.dmg.dmg(),1);
					break;
				case "AddCorrosiveDamage":
					w.dmg.addBaseDmg(0.01 * _loc9_ * w.dmg.dmg(),2);
					break;
				case "AddKineticBaseDamage":
					w.dmg.addBaseDmg(_loc9_,0);
					break;
				case "AddEnergyBaseDamage":
					w.dmg.addBaseDmg(_loc9_,1);
					break;
				case "AddCorrosiveBaseDamage":
					w.dmg.addBaseDmg(_loc9_,2);
					break;
				case "AddKineticDot5":
					w.addDebuff(0,5,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 5,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot5":
					w.addDebuff(0,5,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 5,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot5":
					w.addDebuff(0,5,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 5,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddKineticDot10":
					w.addDebuff(0,10,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 10,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot10":
					w.addDebuff(0,10,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 10,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot10":
					w.addDebuff(0,10,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 10,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddKineticDot20":
					w.addDebuff(0,20,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 20,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot20":
					w.addDebuff(0,20,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 20,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot20":
					w.addDebuff(0,20,new Damage(0.01 * _loc9_ * w.dmg.dmg() / 20,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddEnergyBurn":
					w.addDebuff(4,10,new Damage(0.002 * _loc9_ * w.dmg.dmg(),1),"7XV2cuSPJ0erabUgynivBA");
					break;
				case "AddCorrosiveBurn":
					w.addDebuff(4,10,new Damage(0.002 * _loc9_ * w.dmg.dmg(),2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddHealthVamp":
					w.healthVamp += _loc9_;
					break;
				case "AddShieldVamp":
					w.shieldVamp += _loc9_;
					break;
				case "AddDualVamp":
					w.healthVamp += _loc9_;
					w.shieldVamp += _loc9_;
					break;
				case "KineticPenetration":
					w.addDebuff(8,5 + 5 * eliteTechLevel / 100,new Damage(_loc9_,8),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "EnergyPenetration":
					w.addDebuff(9,5 + 5 * eliteTechLevel / 100,new Damage(_loc9_,8),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "CorrosivePenetration":
					w.addDebuff(10,5 + 5 * eliteTechLevel / 100,new Damage(_loc9_,8),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddExtraProjectiles":
					_loc10_ = eliteTechLevel / 100;
					if(_loc10_ == 0)
					{
						return;
					}
					_loc8_ = w.multiNrOfP;
					if(w.multiNrOfP == 1)
					{
						if(_loc10_ < 0.5)
						{
							w.multiNrOfP = 2;
							w.multiOffset += 10;
						}
						else if(_loc10_ >= 0.5)
						{
							w.multiNrOfP = 3;
							w.multiOffset += 15;
						}
					}
					else
					{
						w.multiNrOfP += int(Math.floor(_loc10_ * w.multiNrOfP));
					}
					_loc10_ = _loc8_ / w.multiNrOfP;
					w.maxProjectiles = w.multiNrOfP / _loc8_ * w.maxProjectiles;
					w.dmg.addBasePercent(_loc10_ * (100 + _loc9_) - 100);
					w.debuffValue.addBasePercent(_loc10_ * (100 + _loc9_) - 100);
					w.debuffValue2.addBasePercent(_loc10_ * (100 + _loc9_) - 100);
					_loc10_ = 1 / _loc10_;
					w.multiAngleOffset += w.multiAngleOffset * 0.5 * _loc10_;
					w.multiOffset += w.multiOffset * 0.5 * _loc10_;
					if(w is ProjectileGun)
					{
						w.heatCost = w.heatCost / w.multiNrOfP * _loc8_;
					}
					break;
				case "IncreaseDirectDamage":
					w.dmg.addBasePercent(_loc9_,0);
					w.dmg.addBasePercent(_loc9_,1);
					w.dmg.addBasePercent(_loc9_,2);
					w.dmg.addBasePercent(_loc9_,6);
					break;
				case "IncreaseDebuffDamage":
					if(w.debuffValue.dmg() > 0)
					{
						w.debuffValue.addBasePercent(_loc9_,0);
						w.debuffValue.addBasePercent(_loc9_,1);
						w.debuffValue.addBasePercent(_loc9_,2);
						w.debuffValue.addBasePercent(_loc9_,6);
					}
					if(w.debuffValue2.dmg() > 0)
					{
						w.debuffValue2.addBasePercent(_loc9_,0);
						w.debuffValue2.addBasePercent(_loc9_,1);
						w.debuffValue2.addBasePercent(_loc9_,2);
						w.debuffValue2.addBasePercent(_loc9_,6);
					}
					break;
				case "IncreaseRange":
					w.range += int(w.range * 0.01 * _loc9_);
					w.ttl += int(w.ttl * 0.01 * _loc9_);
					break;
				case "IncreaseRefire":
					w.reloadTime -= w.reloadTime * 0.01 * _loc9_;
					w.heatCost -= w.heatCost * 0.01 * _loc9_;
					break;
				case "IncreaseGuidance":
					w.rotationSpeed += w.rotationSpeed * 0.01 * _loc9_;
					w.acceleration += w.acceleration * 0.01 * _loc9_;
					w.speed += w.speed * 0.002 * _loc9_;
					break;
				case "ReducePowerCost":
					w.heatCost -= w.heatCost * 0.01 * _loc9_;
					break;
				case "DisableHealing":
					w.addDebuff(6,1 + _loc9_,new Damage(0,8),"jvcmRezjZUKQUuhAlhhCqw");
					break;
				case "DisableShieldRegen":
					w.addDebuff(5,1 + _loc9_,new Damage(0,8),"jvcmRezjZUKQUuhAlhhCqw");
					break;
				case "ReduceTargetDamage":
					w.addDebuff(7,5 + 5 * eliteTechLevel / 100,new Damage(_loc9_,8),"xYk7ubyao0uh8j9SDJYeWw");
					break;
				case "ReduceTargetArmor":
					w.addDebuff(3,5 + 5 * eliteTechLevel / 100,new Damage(0.01 * _loc9_ * w.dmg.dmg(),w.dmg.type),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "IncreaseAOE":
					w.dmgRadius += int(0.01 * _loc9_ * w.dmgRadius);
					break;
				case "AddAOE":
					w.dmgRadius += int(5 + _loc9_);
					break;
				case "IncreaseNrHits":
					if(w is Beam)
					{
						_loc5_ = w as Beam;
						_loc5_.nrTargets = _loc5_.nrTargets + (int(1 + _loc9_));
					}
					else
					{
						w.numberOfHits += int(1 + _loc9_);
					}
				case "IncreaseSpeed":
					w.speed += 0.01 * _loc9_ * w.speed;
					break;
				case "IncreasePetHp":
			}
		}
		
		public static function addEliteTechs(s:PlayerShip, obj:Object, eliteTechLevel:int, eliteTech:String) : void
		{
			if(!obj.hasOwnProperty("eliteTechs"))
			{
				return;
			}
			var _loc5_:Object = obj.eliteTechs;
			if(!_loc5_.hasOwnProperty(eliteTech))
			{
				return;
			}
			var _loc6_:Number = Number(_loc5_[eliteTech]);
			var _loc8_:Number = _loc6_ * eliteTechLevel / 100;
			if(_loc6_ == 0)
			{
				return;
			}
			switch(eliteTech)
			{
				case "IncreaseShield":
					s.shieldHpBase += 0.01 * _loc8_ * s.shieldHpBase;
					s.shieldHpMax = s.shieldHpBase;
					s.shieldHp = s.shieldHpBase;
					break;
				case "IncreaseShieldRegen":
					s.shieldRegenBase += 0.01 * _loc8_ * s.shieldRegenBase;
					s.shieldRegen = s.shieldRegenBase;
					break;
				case "ConvertShield":
					s.hpRegen = 0.0006 * _loc8_;
					s.shieldHpBase -= 0.01 * _loc8_ * s.shieldHpBase;
					if(s.shieldHpBase < 1)
					{
						s.shieldHpBase = 1;
					}
					s.shieldHpMax = s.shieldHpBase;
					s.shieldHp = s.shieldHpBase;
					break;
				case "IncreaseHealth":
					s.hpBase += 0.01 * _loc8_ * s.hpBase;
					s.hpMax = s.hpBase;
					s.hp = s.hpBase;
					break;
				case "IncreaseArmor":
					s.armorThresholdBase += 0.01 * _loc8_ * s.armorThresholdBase;
					s.armorThreshold = s.armorThresholdBase;
					break;
				case "ConvertHealth":
					s.shieldRegenBase += 0.03 * _loc8_ * s.shieldRegenBase;
					s.shieldRegen = s.shieldRegenBase;
					s.hpBase -= 0.01 * _loc8_ * s.hpBase;
					if(s.hpBase < 1)
					{
						s.hpBase = 1;
					}
					s.hpMax = s.hpBase;
					s.hp = s.hpBase;
					break;
				case "IncreaseSheildDuration":
					s.hardenDuration += 0.01 * _loc8_ * s.hardenDuration;
					break;
				case "ReduceSheildCooldown":
					s.hardenCD -= Math.round(0.01 * _loc8_ * s.hardenCD);
					break;
				case "IncreaseSpeedBoostAmount":
					s.boostBonus += 0.01 * _loc8_ * s.boostBonus;
					break;
				case "IncreaseSpeedBoostDuration":
					s.boostDuration += 0.01 * _loc8_ * s.boostDuration;
					break;
				case "ReduceSpeedBoostCooldown":
					s.boostCD -= Math.round(0.01 * _loc8_ * s.boostCD);
					break;
				case "IncreaseArmorConvBonus":
					s.convGain += 0.01 * _loc8_ * s.convGain;
					break;
				case "ReduceArmorConvCooldown":
					s.convCD -= Math.round(0.01 * _loc8_ * s.convCD);
					break;
				case "IncreaseDamage":
					for each(var _loc7_ in s.weapons)
					{
						_loc7_.dmg.addBasePercent(_loc8_);
						_loc7_.debuffValue.addBasePercent(_loc8_);
						_loc7_.debuffValue2.addBasePercent(_loc8_);
					}
					break;
				case "IncreaseRefire":
					for each(_loc7_ in s.weapons)
					{
						_loc7_.reloadTime -= _loc7_.reloadTime * 0.01 * _loc8_;
						_loc7_.heatCost -= _loc7_.heatCost * 0.01 * _loc8_;
					}
					break;
				case "ReducePowerCost":
					for each(_loc7_ in s.weapons)
					{
						_loc7_.heatCost -= _loc7_.heatCost * 0.01 * _loc8_;
					}
					break;
				case "IncreaseDmgBoostDuration":
					s.dmgBoostDuration += 0.01 * _loc8_ * s.dmgBoostDuration;
					break;
				case "IncreaseDmgBoostBonus":
					s.dmgBoostBonus += 0.01 * _loc8_ * s.dmgBoostBonus;
					break;
				case "ReduceDmgBoostPowerCost":
					s.dmgBoostCost -= 0.01 * _loc8_ * s.dmgBoostCost;
					break;
				case "IncreaseEngineSpeed":
					s.engine.speed += s.engine.speed * 0.01 * _loc8_;
					break;
				case "UnbreakableArmor":
			}
		}
		
		private static function getDescription(eliteTech:String, level:int, obj:Object) : String
		{
			var _loc4_:String = "";
			if(level < 1)
			{
				level = 1;
			}
			if(level < 100)
			{
				_loc4_ += "<FONT COLOR=\'#88ff88\'>" + Localize.t("Level") + ": " + level + " " + Localize.t("Bonus") + ":</FONT>\n";
				_loc4_ = _loc4_ + getStatTextByLevel(eliteTech,obj,level);
				_loc4_ = _loc4_ + ("<FONT COLOR=\'#88ff88\'>" + Localize.t("Bonus at level") + " " + (level + 1).toString() + ":</FONT>\n");
				_loc4_ = _loc4_ + (getStatTextByLevel(eliteTech,obj,level + 1) + "\n");
			}
			else
			{
				_loc4_ += "<FONT COLOR=\'#88ff88\'>" + Localize.t("Level") + ": " + level + " " + Localize.t("Bonus") + ":</FONT>\n";
				_loc4_ = _loc4_ + (getStatTextByLevel(eliteTech,obj,level) + "\n");
			}
			return _loc4_;
		}
		
		public static function getIconName(eliteTech:String) : String
		{
			var _loc2_:String = null;
			switch(eliteTech)
			{
				case "AddKineticDamage":
					_loc2_ = "ti2_kinetic_dmg";
					break;
				case "AddEnergyDamage":
					_loc2_ = "ti2_energy_dmg";
					break;
				case "AddCorrosiveDamage":
					_loc2_ = "ti2_corrosive_dmg";
					break;
				case "AddKineticBaseDamage":
					_loc2_ = "ti2_kinetic_base_dmg";
					break;
				case "AddEnergyBaseDamage":
					_loc2_ = "ti2_energy_base_dmg";
					break;
				case "AddCorrosiveBaseDamage":
					_loc2_ = "ti2_corrosive_base_dmg";
					break;
				case "AddKineticDot5":
					_loc2_ = "ti2_kinetic_dot5";
					break;
				case "AddEnergyDot5":
					_loc2_ = "ti2_energy_dot5";
					break;
				case "AddCorrosiveDot5":
					_loc2_ = "ti2_corrosive_dot5";
					break;
				case "AddKineticDot10":
					_loc2_ = "ti2_kinetic_dot10";
					break;
				case "AddEnergyDot10":
					_loc2_ = "ti2_energy_dot10";
					break;
				case "AddCorrosiveDot10":
					_loc2_ = "ti2_corrosive_dot10";
					break;
				case "AddKineticDot20":
					_loc2_ = "ti2_kinetic_dot20";
					break;
				case "AddEnergyDot20":
					_loc2_ = "ti2_energy_dot20";
					break;
				case "AddCorrosiveDot20":
					_loc2_ = "ti2_corrosive_dot20";
					break;
				case "AddEnergyBurn":
					_loc2_ = "ti2_energy_burn";
					break;
				case "AddCorrosiveBurn":
					_loc2_ = "ti2_corrosive_burn";
					break;
				case "AddHealthVamp":
					_loc2_ = "ti2_vamp_health";
					break;
				case "AddShieldVamp":
					_loc2_ = "ti2_vamp_shield";
					break;
				case "AddDualVamp":
					_loc2_ = "ti2_vamp_all";
					break;
				case "KineticPenetration":
					_loc2_ = "ti2_pen_kinetic";
					break;
				case "EnergyPenetration":
					_loc2_ = "ti2_pen_energy";
					break;
				case "CorrosivePenetration":
					_loc2_ = "ti2_pen_corrosive";
					break;
				case "AddExtraProjectiles":
					_loc2_ = "ti2_add_projectile";
					break;
				case "IncreaseDirectDamage":
					_loc2_ = "ti2_increase_dmg";
					break;
				case "IncreaseDebuffDamage":
					_loc2_ = "ti2_increase_dot";
					break;
				case "IncreaseRange":
					_loc2_ = "ti2_increase_range";
					break;
				case "IncreaseRefire":
					_loc2_ = "ti2_increase_fire_rate";
					break;
				case "IncreaseGuidance":
					_loc2_ = "ti2_increase_guidance";
					break;
				case "ReducePowerCost":
					_loc2_ = "ti2_power_reduce_cost";
					break;
				case "DisableHealing":
					_loc2_ = "ti2_disable_healing";
					break;
				case "DisableShieldRegen":
					_loc2_ = "ti2_disable_shield_regen";
					break;
				case "ReduceTargetDamage":
					_loc2_ = "ti2_decrease_dmg";
					break;
				case "ReduceTargetArmor":
					_loc2_ = "ti2_pen_armor";
					break;
				case "IncreaseAOE":
					_loc2_ = "ti2_increase_area_dmg_radius";
					break;
				case "AddAOE":
					_loc2_ = "ti2_increase_area_dmg_radius";
					break;
				case "IncreaseNrHits":
					_loc2_ = "ti2_increase_nr_of_hits";
				case "IncreaseShield":
					_loc2_ = "ti2_shield_increase";
					break;
				case "IncreaseShieldRegen":
					_loc2_ = "ti2_shield_increase_regen";
					break;
				case "ConvertShield":
					_loc2_ = "ti2_shield_convert";
					break;
				case "IncreaseHealth":
					_loc2_ = "ti2_armor_increase_health";
					break;
				case "IncreaseArmor":
					_loc2_ = "ti2_armor_increase";
					break;
				case "ConvertHealth":
					_loc2_ = "ti2_armor_convert_health";
					break;
				case "IncreaseSheildDuration":
					_loc2_ = "ti2_shield_duration";
					break;
				case "ReduceSheildCooldown":
					_loc2_ = "ti2_shield_cooldown";
					break;
				case "IncreaseSpeedBoostAmount":
					_loc2_ = "ti2_speed_increase";
					break;
				case "IncreaseSpeedBoostDuration":
					_loc2_ = "ti2_speed_increase";
					break;
				case "ReduceSpeedBoostCooldown":
					_loc2_ = "ti2_speed_cooldown";
					break;
				case "IncreaseArmorConvBonus":
					_loc2_ = "ti2_armor_increase_convert_bonus";
					break;
				case "ReduceArmorConvCooldown":
					_loc2_ = "ti2_armor_cooldown";
					break;
				case "IncreaseDamage":
					_loc2_ = "ti2_increase_dmg";
					break;
				case "IncreaseRefire":
					_loc2_ = "ti2_increase_fire_rate";
					break;
				case "ReducePowerCost":
					_loc2_ = "ti2_power_reduce_cost";
					break;
				case "IncreaseDmgBoostDuration":
					_loc2_ = "ti2_power_boost_duration";
					break;
				case "IncreaseDmgBoostBonus":
					_loc2_ = "ti2_power_boost_dmg";
					break;
				case "ReduceDmgBoostPowerCost":
					_loc2_ = "ti2_power_reduce_cost";
					break;
				case "IncreaseSpeed":
					_loc2_ = "ti2_speed_increase";
					break;
				case "IncreasePetHp":
					_loc2_ = "ti2_armor_increase_health";
				case "IncreaseEngineSpeed":
					_loc2_ = "ti2_speed_increase";
					break;
				case "UnbreakableArmor":
					_loc2_ = "ti2_pen_armor";
			}
			return _loc2_;
		}
		
		public static function getName(eliteTech:String) : String
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < WEAPON_ELITE_TECHS.length)
			{
				if(WEAPON_ELITE_TECHS[_loc2_] == eliteTech)
				{
					return Localize.t(WEAPON_ELITE_TECHS_NAME[_loc2_]);
				}
				_loc2_++;
			}
			_loc2_ = 0;
			while(_loc2_ < ELITE_TECHS.length)
			{
				if(ELITE_TECHS[_loc2_] == eliteTech)
				{
					return Localize.t(ELITE_TECHS_NAME[_loc2_]);
				}
				_loc2_++;
			}
			return "";
		}
		
		private static function createEliteTechBar(g:Game, eliteTech:String, name:String, techSkill:TechSkill, obj:Object) : EliteTechBar
		{
			var _loc6_:int = 1;
			for each(var _loc8_ in techSkill.eliteTechs)
			{
				if(_loc8_.eliteTech == eliteTech)
				{
					_loc6_ = _loc8_.eliteTechLevel;
					break;
				}
			}
			var _loc9_:String = getDescription(eliteTech,_loc6_,obj);
			var _loc7_:String = getIconName(eliteTech);
			return new EliteTechBar(g,name,_loc9_,_loc7_,_loc6_,eliteTech,techSkill);
		}
		
		public static function getEliteTechBarList(g:Game, techSkill:TechSkill, obj:Object) : Vector.<EliteTechBar>
		{
			var _loc8_:* = undefined;
			var _loc5_:* = undefined;
			var _loc9_:String = null;
			var _loc6_:int = 0;
			var _loc7_:Vector.<EliteTechBar> = new Vector.<EliteTechBar>();
			var _loc4_:Object = obj.eliteTechs;
			if(techSkill.table == "Weapons")
			{
				_loc8_ = WEAPON_ELITE_TECHS;
				_loc5_ = WEAPON_ELITE_TECHS_NAME;
			}
			else
			{
				_loc8_ = ELITE_TECHS;
				_loc5_ = ELITE_TECHS_NAME;
			}
			_loc6_ = 0;
			while(_loc6_ < _loc8_.length)
			{
				_loc9_ = _loc8_[_loc6_];
				if(_loc4_.hasOwnProperty(_loc9_) && _loc4_[_loc9_] > 0)
				{
					_loc7_.push(createEliteTechBar(g,_loc9_,_loc5_[_loc6_],techSkill,obj));
				}
				_loc6_++;
			}
			return _loc7_;
		}
		
		public static function getResource1Cost(level:int) : int
		{
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * 3200000));
		}
		
		public static function getResource2Cost(level:int) : int
		{
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * (150 * 60 * 60)));
		}
		
		public static function getResource1CostRange(fromLevel:int, toLevel:int) : int
		{
			var _loc4_:* = 0;
			var _loc3_:int = 0;
			_loc4_ = fromLevel;
			while(_loc4_ <= toLevel)
			{
				_loc3_ += getResource1Cost(_loc4_);
				_loc4_++;
			}
			return _loc3_;
		}
		
		public static function getFluxCost(level:int) : int
		{
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * (200 * 60)));
		}
		
		public static function getFluxCostRange(fromLevel:int, toLevel:int) : int
		{
			var _loc4_:* = 0;
			var _loc3_:int = 0;
			_loc4_ = fromLevel;
			while(_loc4_ <= toLevel)
			{
				_loc3_ += getFluxCost(_loc4_);
				_loc4_++;
			}
			return _loc3_;
		}
	}
}

