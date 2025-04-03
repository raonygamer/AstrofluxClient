package core.text
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import core.player.Player;
	import core.scene.Game;
	import core.unit.Unit;
	import flash.geom.Point;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class TextManager
	{
		public var inactiveTexts:Vector.<TextParticle>;
		
		public var textHandler:TextHandler;
		
		private var g:Game;
		
		private var dmgTextCounter:int = 0;
		
		private var missionCompleteText:TextParticle;
		
		private var bossSpawnedText:TextParticle;
		
		private var uberRankCompleteText:TextParticle;
		
		private var uberRankExtraLifeText:TextParticle;
		
		private var uberTaskText:TextParticle;
		
		private var latestMissionUpdateText:TextParticle;
		
		private var isPlayingNewMissionArrived:Boolean = false;
		
		public function TextManager(g:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:TextParticle = null;
			super();
			this.g = g;
			inactiveTexts = new Vector.<TextParticle>();
			while(_loc3_ < 40)
			{
				_loc2_ = new TextParticle(_loc3_,g);
				inactiveTexts.push(_loc2_);
				_loc3_++;
			}
		}
		
		public function loadHandlers() : void
		{
			textHandler = new TextHandler(g);
		}
		
		public function update() : void
		{
			textHandler.update();
		}
		
		public function createDebuffText(debuffText:String, target:Unit) : void
		{
		}
		
		public function createDmgText(dmg:int, target:Unit, shieldHeal:Boolean = false) : void
		{
			var _loc7_:TextParticle = null;
			var _loc8_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:Point = null;
			if(target.lastDmgTime > g.time - 250 && dmg > 0)
			{
				target.lastDmgTime = g.time;
				target.lastDmg += dmg;
				_loc7_ = target.lastDmgText;
				if(_loc7_ != null)
				{
					_loc8_ = 1 - (1000 - _loc7_.ttl) / 1000;
					_loc7_.ttl = 1000;
					_loc7_.speed.x *= _loc8_;
					_loc7_.speed.y *= _loc8_;
					_loc7_.text = target.lastDmg.toString();
					if(target.lastDmg > 1000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.2;
					}
					else if(target.lastDmg > 10000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.5;
					}
				}
			}
			else if(target.lastHealTime > g.time - 250 && dmg < 0)
			{
				target.lastHealTime = g.time;
				target.lastHeal -= dmg;
				_loc7_ = target.lastHealText;
				if(_loc7_ != null)
				{
					_loc8_ = 1 - (1000 - _loc7_.ttl) / 1000;
					_loc7_.ttl = 1000;
					_loc7_.speed.x *= _loc8_;
					_loc7_.speed.y *= _loc8_;
					_loc7_.text = target.lastHeal.toString();
					if(target.lastHeal > 1000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.2;
					}
					else if(target.lastHeal > 10000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.5;
					}
				}
			}
			else
			{
				_loc5_ = 5;
				_loc6_ = -40;
				_loc4_ = target.pos.clone();
				_loc4_.y = _loc4_.y - 15;
				if(dmg > 0)
				{
					target.lastDmgTime = g.time;
					target.lastDmgText = textHandler.add(dmg.toString(),_loc4_,new Point(_loc5_,_loc6_),1000,0xff2222,15);
					target.lastDmg = dmg;
					target.lastDmgTextOffset = 0;
					_loc7_ = target.lastDmgText;
					if(target.lastDmg > 1000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.2;
					}
					else if(target.lastDmg > 10000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.5;
					}
				}
				else if(dmg < 0)
				{
					target.lastHealTime = g.time;
					target.lastHealText = textHandler.add((-dmg).toString(),_loc4_,new Point(_loc5_,_loc6_),1000,5890137,15);
					target.lastHeal = -dmg;
					target.lastHealTextOffset = 0;
					_loc7_ = target.lastHealText;
					if(target.lastHeal > 1000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.2;
					}
					else if(target.lastHeal > 10000)
					{
						_loc7_.scaleX = _loc7_.scaleY = 1.5;
					}
				}
				dmgTextCounter += 1;
			}
		}
		
		public function createXpText(xp:int) : void
		{
			var _loc4_:int = 0;
			var _loc3_:Number = -15 - Math.random() * 8;
			var _loc2_:Number = (Math.random() - 0.5) * 15;
			var _loc5_:Point = new Point(g.stage.stageWidth / 2 - 20 + _loc2_,g.stage.stageHeight / 2 + 200);
			if(xp > 0)
			{
				_loc4_ = 20;
				if(xp < 10)
				{
					_loc4_ = 17;
				}
				if(g.me.hasExpBoost)
				{
					textHandler.add("+" + xp.toFixed(0).toString() + " xp",_loc5_,new Point(_loc2_,_loc3_),50 * 60,0x66ff66,_loc4_,true);
				}
				else
				{
					textHandler.add("+" + xp.toString() + " xp",_loc5_,new Point(_loc2_,_loc3_),50 * 60,0xaaaa33,_loc4_,true);
				}
			}
			else
			{
				textHandler.add(xp.toString() + " xp",_loc5_,new Point(_loc2_,_loc3_),5000,0xff3333,_loc4_,true);
			}
		}
		
		public function createScoreText(score:int) : void
		{
			var _loc3_:Number = -15 - Math.random() * 15;
			var _loc2_:Number = (Math.random() - 0.5) * 15;
			var _loc5_:Point = new Point(g.stage.stageWidth / 2 - 20 + _loc2_,g.stage.stageHeight / 2 + 3 * 60);
			var _loc4_:int = 26;
			if(score < 10)
			{
				_loc4_ = 20;
			}
			textHandler.add("+" + score.toFixed(0).toString() + " troons",_loc5_,new Point(_loc2_,_loc3_),50 * 60,0xff44aa,_loc4_,true);
		}
		
		public function createPvpText(txt:String, offset:int = 0, size:int = 40, colour:uint = 5635925) : void
		{
			var _loc6_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 3 + offset);
			var _loc5_:Number = -5;
			textHandler.add(txt,_loc6_,new Point(0,_loc5_),5000,colour,size,true);
		}
		
		public function createLevelUpText(level:int) : void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _loc2_:Number = -20;
			textHandler.add("You reached level " + level + "!",_loc3_,new Point(0,_loc2_),7000,0xd8d8d8,40,true);
			SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
		}
		
		public function createTroonsText(troons:int) : void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _loc2_:Number = -25;
			textHandler.add("You gained " + troons + " troons!",_loc3_,new Point(0,_loc2_),7000,0x8888ff,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createBonusXpText(bonusXp:int) : void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _loc2_:Number = -20;
			textHandler.add("New Encounter!",_loc3_,new Point(0,_loc2_ + 15),7000,0x44ff44,16,true);
			textHandler.add("+" + bonusXp + " Bonus XP!",_loc3_,new Point(0,_loc2_),7000,0xaaaa33,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createFragScore(fragFactor:int) : void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _loc2_:Number = -20;
			textHandler.add("+" + fragFactor + " frag score!",_loc3_,new Point(0,_loc2_),7000,0xffaa33,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createLevelUpDetailsText() : void
		{
			var vx:Number = 0;
			var vy:Number = -35;
			var pos1:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 230);
			var pos2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 260);
			var pos3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 290);
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(2.5,function():void
			{
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% shield",pos1,new Point(vx,vy),0x1f40,98768,20,true);
			});
			TweenMax.delayedCall(3.5,function():void
			{
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% health",pos2,new Point(-vx,vy - 6),0x1f40,4902913,20,true);
			});
			TweenMax.delayedCall(4.5,function():void
			{
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% damage",pos3,new Point(0,vy - 12),0x1f40,0xff4444,20,true);
			});
			TweenMax.delayedCall(5.5,function():void
			{
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+1% shield regen",pos3,new Point(0,vy - 12),0x1f40,98768,20,true);
			});
		}
		
		public function createMissionCompleteText() : void
		{
			var _loc1_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 100);
			missionCompleteText = textHandler.add("Reward claimed!",_loc1_,new Point(0,0),0x1f40,0xd8d8d8,40,true);
			missionCompleteText.alpha = 0;
			missionCompleteText.scaleX = 30;
			missionCompleteText.scaleY = 30;
			TweenMax.to(missionCompleteText,0.7,{
				"alpha":1,
				"scaleX":1,
				"scaleY":1,
				"onComplete":missionCompleteTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		public function createBossSpawnedText(s:String) : void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 150);
			bossSpawnedText = textHandler.add(s,_loc2_,new Point(0,0),0x1f40,12787744,40,true);
			bossSpawnedText.alpha = 0;
			TweenMax.to(bossSpawnedText,3,{
				"alpha":1,
				"onComplete":bossSpawnedTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function bossSpawnedTextStep2() : void
		{
			TweenMax.delayedCall(1.2,function():void
			{
				bossSpawnedText.speed = new Point(0,-20);
			});
		}
		
		public function createUberRankCompleteText(s:String) : void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 50);
			uberRankCompleteText = textHandler.add(s,_loc2_,new Point(0,0),0x1f40,0x44ff44,50,true);
			uberRankCompleteText.alpha = 0;
			TweenMax.to(uberRankCompleteText,3,{
				"alpha":1,
				"onComplete":uberRankCompleteTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberRankCompleteTextStep2() : void
		{
			TweenMax.delayedCall(1.2,function():void
			{
				uberRankCompleteText.speed = new Point(0,-20);
			});
		}
		
		public function createUberExtraLifeText(s:String) : void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 50);
			uberRankExtraLifeText = textHandler.add(s,_loc2_,new Point(0,0),100 * 60,0x88ff88,40,true);
			uberRankExtraLifeText.alpha = 0;
			TweenMax.to(uberRankExtraLifeText,3,{
				"alpha":1,
				"onComplete":uberExtraLifeTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberExtraLifeTextStep2() : void
		{
			TweenMax.delayedCall(1.2,function():void
			{
				uberRankExtraLifeText.speed = new Point(0,-30);
			});
		}
		
		public function createUberTaskText(s:String) : void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 100);
			uberTaskText = textHandler.add(s,_loc2_,new Point(0,0),5000,0xffff88,30,true);
			uberTaskText.alpha = 0;
			TweenMax.to(uberTaskText,3,{
				"alpha":1,
				"onComplete":uberTaskTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberTaskTextStep2() : void
		{
			TweenMax.delayedCall(1.2,function():void
			{
				uberTaskText.speed = new Point(0,-30);
			});
		}
		
		private function missionCompleteTextStep2() : void
		{
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			TweenMax.delayedCall(1.2,function():void
			{
				missionCompleteText.speed = new Point(0,-20);
			});
		}
		
		public function createMissionUpdateText(count:int, amount:int) : void
		{
			if(amount == 0)
			{
				return;
			}
			TweenMax.delayedCall(0.5,function():void
			{
				if(latestMissionUpdateText != null)
				{
					latestMissionUpdateText.alive = false;
				}
				var _loc1_:Point = new Point(g.stage.stageWidth - 15,g.hud.missionsButton.y - 20);
				SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
				latestMissionUpdateText = textHandler.add("" + count + " of " + amount,_loc1_,new Point(0,-10),5000,0xd8d8d8,13,true,"right");
			});
		}
		
		public function createMissionFinishedText() : void
		{
			SoundLocator.getService().preCacheSound("0CELPmI080ujs_ZTFg8iyA");
			TweenMax.delayedCall(1.5,function():void
			{
				var _loc1_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
				textHandler.add("Mission complete!",_loc1_,new Point(0,-10),7000,4902913,20,true);
				SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
			});
		}
		
		public function createMissionBestTimeText() : void
		{
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(4,function():void
			{
				var _loc1_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
				textHandler.add("New time record!",_loc1_,new Point(0,-9),7000,14340097,12,true);
				SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
			});
		}
		
		public function createNewMissionArrivedText() : void
		{
			if(isPlayingNewMissionArrived)
			{
				return;
			}
			isPlayingNewMissionArrived = true;
			SoundLocator.getService().preCacheSound("6_sJLdnMgEKbvAjTspuOMg",function():void
			{
				SoundLocator.getService().play("6_sJLdnMgEKbvAjTspuOMg");
				TweenMax.delayedCall(2,function():void
				{
					var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
					var _loc1_:Number = -20;
					textHandler.add("Incoming mission...",_loc2_,new Point(0,_loc1_),7000,16776205,20,true);
					isPlayingNewMissionArrived = false;
				});
			});
		}
		
		public function createDailyUpdate(text:String) : void
		{
			TweenMax.delayedCall(0.5,function():void
			{
				if(latestMissionUpdateText != null)
				{
					latestMissionUpdateText.alive = false;
				}
				SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
				var _loc1_:Point = new Point(g.stage.stageWidth + 15,g.hud.missionsButton.y - 38);
				latestMissionUpdateText = textHandler.add(text,_loc1_,new Point(0,-10),5000,11061482,13,true,"right");
			});
		}
		
		public function createKillText(s:String, size:Number = 15, ttl:int = 5000, color:uint = 11184810) : void
		{
			var _loc6_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 100);
			var _loc5_:Number = -20;
			textHandler.add(s,_loc6_,new Point(0,_loc5_),ttl,color,size,true);
		}
		
		public function createDropText(name:String, amount:int = 1, size:Number = 15, ttl:int = 5000, color:uint = 11184810, offset:int = 0) : void
		{
			var _loc9_:int = 0;
			var _loc7_:int = 0;
			var _loc8_:Number = NaN;
			var _loc12_:Point = null;
			var _loc14_:TextParticle = null;
			var _loc10_:Player = g.me;
			var _loc11_:TextParticle = null;
			var _loc13_:* = null;
			_loc9_ = _loc10_.pickUpLog.length - 1;
			while(_loc9_ > -1)
			{
				_loc11_ = _loc10_.pickUpLog[_loc9_];
				if(_loc11_.ttl <= 0)
				{
					_loc10_.pickUpLog.splice(_loc9_,1);
				}
				else if(contains(_loc11_.text,name))
				{
					_loc13_ = _loc11_;
					break;
				}
				_loc9_--;
			}
			if(_loc13_ != null)
			{
				_loc7_ = getQuantity(_loc13_.text) + amount;
				_loc13_.text = name + " x" + _loc7_;
				_loc13_.ttl = ttl;
				_loc13_.alpha = 1;
			}
			else
			{
				_loc8_ = -10;
				_loc12_ = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 175 + _loc10_.pickUpLog.length * 15 - offset);
				_loc14_ = textHandler.add(name + " x" + amount,_loc12_,new Point(0,_loc8_),ttl,color,size,true);
				_loc10_.pickUpLog.push(_loc14_);
			}
		}
		
		private function contains(t:String, s:String) : Boolean
		{
			var _loc3_:int = 0;
			while(_loc3_ < s.length)
			{
				if(t.charAt(_loc3_) != s.charAt(_loc3_))
				{
					return false;
				}
				_loc3_++;
			}
			return true;
		}
		
		private function getQuantity(s:String) : int
		{
			var _loc2_:Array = s.split(" x");
			return int(_loc2_[1]);
		}
		
		public function createMapEntryText() : void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
			var _loc1_:Number = -5;
			textHandler.add("New map entry updated, press [TAB]",_loc2_,new Point(0,_loc1_),5000,0x33ff33,16,true);
		}
		
		public function createReputationText(mod:int, target:Unit) : void
		{
			if(target == null)
			{
				return;
			}
			var _loc4_:Number = 5;
			var _loc5_:Number = -30;
			var _loc3_:Point = new Point(target.pos.x,target.pos.y);
			_loc3_.y -= 15;
			if(mod > 0)
			{
				textHandler.add("+" + mod.toString() + " police reputation",_loc3_,new Point(_loc4_,_loc5_),50 * 60,3103982,15,true);
			}
			else
			{
				textHandler.add("+" + (-mod).toString() + " pirate reputation",_loc3_,new Point(_loc4_,_loc5_),50 * 60,11690209,15,true);
			}
		}
		
		public function dispose() : void
		{
			textHandler.dispose();
		}
	}
}

