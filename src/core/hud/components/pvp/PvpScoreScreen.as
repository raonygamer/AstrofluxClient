package core.hud.components.pvp
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class PvpScoreScreen extends PvpScreen
	{
		private var leaveButton:Button;
		
		private var addedItems:Vector.<PvpScoreHolder>;
		
		private var scrollArea:ScrollContainer;
		
		private var mainBody:Sprite;
		
		private var infoBox:Box;
		
		private var rewardBox:Box;
		
		private var contentBody:Sprite;
		
		public function PvpScoreScreen(g:Game)
		{
			super(g);
		}
		
		override public function load() : void
		{
			super.load();
			if(g.pvpManager != null)
			{
				g.pvpManager.scoreListUpdated = true;
			}
			leaveButton = new Button(showConfirmDialog,Localize.t("Leave Match"),"negative");
			leaveButton.x = 560;
			leaveButton.y = 520;
			addChild(leaveButton);
		}
		
		private function leaveMatch() : void
		{
			g.send("leavePvpMatch");
		}
		
		private function showConfirmDialog(e:TouchEvent) : void
		{
			var _loc2_:String = null;
			if(g.pvpManager.matchEnded == false)
			{
				_loc2_ = "Are you sure you want to leave? You will lose rating as if you lost the match!";
				g.showConfirmDialog(_loc2_,leaveMatch);
			}
			else
			{
				leaveMatch();
			}
		}
		
		override public function unload() : void
		{
			for each(var _loc1_ in addedItems)
			{
				if(mainBody.contains(_loc1_.img))
				{
					mainBody.removeChild(_loc1_.img);
				}
			}
			addedItems = new Vector.<PvpScoreHolder>();
		}
		
		override public function update() : void
		{
			var _loc1_:* = undefined;
			if(!g.pvpManager.scoreListUpdated)
			{
				return;
			}
			g.pvpManager.scoreListUpdated = false;
			if(contentBody != null && contains(contentBody))
			{
				removeChild(contentBody);
			}
			addedItems = new Vector.<PvpScoreHolder>();
			contentBody = new Sprite();
			mainBody = new Sprite();
			addChild(contentBody);
			var _loc4_:int = 70;
			var _loc6_:int = 0;
			if(g.pvpManager != null && g.pvpManager.matchEnded)
			{
				addInfoBox(_loc4_,_loc6_);
				addRewardBox(_loc4_,_loc6_);
				_loc6_ = 220;
			}
			else
			{
				_loc6_ = 40;
			}
			var _loc7_:Text = new Text();
			if(g.solarSystem.type == "pvp dom")
			{
				_loc7_.text = Localize.t("Team");
			}
			else
			{
				_loc7_.text = Localize.t("Rank");
			}
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x55ff55;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			_loc4_ += 60;
			_loc7_ = new Text();
			_loc7_.text = Localize.t("Name");
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x55ff55;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			_loc4_ += 160;
			if(g.solarSystem.type == "pvp dom")
			{
				_loc4_ -= 20;
				_loc7_ = new Text();
				_loc7_.text = Localize.t("Score");
				_loc7_.x = _loc4_;
				_loc7_.y = _loc6_;
				_loc7_.color = 0x55ff55;
				_loc7_.size = 12;
				contentBody.addChild(_loc7_);
				_loc4_ += 50;
				_loc7_ = new Text();
				_loc7_.text = Localize.t("Kills");
				_loc7_.x = _loc4_;
				_loc7_.y = _loc6_;
				_loc7_.color = 0x55ff55;
				_loc7_.size = 12;
				contentBody.addChild(_loc7_);
				_loc4_ += 50;
			}
			else
			{
				_loc7_ = new Text();
				_loc7_.text = Localize.t("Kills");
				_loc7_.x = _loc4_;
				_loc7_.y = _loc6_;
				_loc7_.color = 0x55ff55;
				_loc7_.size = 12;
				contentBody.addChild(_loc7_);
				_loc4_ += 50;
			}
			_loc7_ = new Text();
			_loc7_.text = Localize.t("Deaths");
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x55ff55;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			if(g.solarSystem.type == "pvp dom")
			{
				_loc4_ += 50;
			}
			else
			{
				_loc4_ += 70;
			}
			_loc7_ = new Text();
			_loc7_.text = Localize.t("Damage");
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x55ff55;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			_loc4_ += 80;
			_loc7_ = new Text();
			_loc7_.text = Localize.t("Reward Bonus");
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x5555ff;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			_loc4_ += 110;
			_loc7_ = new Text();
			_loc7_.text = Localize.t("Rating");
			_loc7_.x = _loc4_;
			_loc7_.y = _loc6_;
			_loc7_.color = 0x5555ff;
			_loc7_.size = 12;
			contentBody.addChild(_loc7_);
			_loc4_ += 60;
			_loc6_ += 30;
			scrollArea = new ScrollContainer();
			scrollArea.y = _loc6_;
			scrollArea.x = 4;
			scrollArea.width = 700;
			if(g.pvpManager != null && g.pvpManager.matchEnded)
			{
				scrollArea.height = 250;
			}
			else
			{
				scrollArea.height = 430;
			}
			_loc1_ = g.pvpManager.getScoreList();
			if(_loc1_ == null || _loc1_.length == 0)
			{
				return;
			}
			_loc6_ = 10;
			var _loc2_:Boolean = false;
			var _loc5_:Boolean = false;
			if(g.pvpManager is DominationManager)
			{
				_loc2_ = true;
			}
			for each(var _loc3_ in _loc1_)
			{
				_loc3_.load();
				_loc3_.img.x = 60;
				_loc3_.img.y = _loc6_;
				if(_loc2_)
				{
					if(g.me.team == _loc3_.team)
					{
						_loc5_ = true;
					}
					else
					{
						_loc5_ = false;
					}
				}
				_loc3_.update(_loc2_,_loc5_);
				mainBody.addChild(_loc3_.img);
				addedItems.push(_loc3_);
				_loc6_ = _loc6_ + _loc3_.img.height + 5;
			}
			contentBody.addChild(scrollArea);
			scrollArea.addChild(mainBody);
		}
		
		private function addInfoBox(x:int, y:int) : void
		{
			var _loc3_:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(infoBox != null && contains(infoBox))
			{
				removeChild(infoBox);
			}
			infoBox = new Box(280,140,"highlight",0.5,10);
			infoBox.x = x - 10;
			infoBox.y = y + 60;
			addChild(infoBox);
			var _loc5_:Text = new Text();
			_loc5_.text = Localize.t("Achievement");
			_loc5_.x = 0;
			_loc5_.y = 0;
			_loc5_.color = 0x5555ff;
			_loc5_.size = 14;
			infoBox.addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.text = Localize.t("Bonus");
			_loc5_.x = 100;
			_loc5_.y = 0;
			_loc5_.color = 0x5555ff;
			_loc5_.size = 14;
			infoBox.addChild(_loc5_);
			if(_loc3_ == null)
			{
				return;
			}
			var _loc4_:int = 20;
			if(_loc3_.afk == true)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Inactive/Afk") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = "-100%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
				Game.trackEvent("pvp","afk",g.me.name);
				return;
			}
			if(_loc3_.first > 0)
			{
				_loc5_ = new Text();
				if(g.pvpManager is DominationManager)
				{
					_loc5_.text = Localize.t("Victory") + ":";
				}
				else
				{
					_loc5_.text = Localize.t("First place") + ":";
				}
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.first.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.second > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Second place") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.second.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.third > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Third place") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.third.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.hotStreak3 > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Hot Streak x3") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.hotStreak3.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.hotStreak10 > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Hot Streak x10") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.hotStreak10.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.noDeaths > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Undying") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.noDeaths.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.capZone > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Successful Assult") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.capZone.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.defZone > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Dedicated Defence") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.defZone.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.brokeKillingSpree > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Broke a Spree") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.brokeKillingSpree.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.pickups > 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Pickup Bonus") + ":";
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc5_ = new Text();
				_loc5_.text = _loc3_.pickups.toString() + "%";
				_loc5_.x = 220;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x5555ff;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
			if(_loc3_.dailyBonus >= 0)
			{
				_loc5_ = new Text();
				_loc5_.text = Localize.t("Daily Bonus Reward!");
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x33ff33;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
				_loc5_ = new Text();
				_loc5_.text = "(" + _loc3_.dailyBonus + Localize.t("x matches left today)");
				_loc5_.x = 5;
				_loc5_.y = _loc4_;
				_loc5_.color = 0x33ff33;
				_loc5_.size = 12;
				infoBox.addChild(_loc5_);
				_loc4_ += 16;
			}
		}
		
		private function addRewardBox(x:int, y:int) : void
		{
			var _loc9_:Number = NaN;
			var _loc3_:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(rewardBox != null && contains(rewardBox))
			{
				removeChild(rewardBox);
			}
			var _loc7_:Number = 0.5;
			if(g.solarSystem.type == "pvp dm")
			{
				_loc7_ = 2;
			}
			else if(g.solarSystem.type == "pvp dom")
			{
				_loc7_ = 2;
			}
			rewardBox = new Box(280,140,"highlight",0.5,10);
			rewardBox.x = x + 320;
			rewardBox.y = y + 60;
			addChild(rewardBox);
			var _loc8_:Text = new Text();
			_loc8_.y = 0;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 14;
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.x = 10;
				_loc8_.htmlText = Localize.t("Reward <font color=\'#33ff33\'>(Daily Bonus)</font>");
				_loc9_ = 0;
				if(g.solarSystem.type == "pvp dm")
				{
					_loc9_ = 2;
				}
				else if(g.solarSystem.type == "pvp dom")
				{
					_loc9_ = 2;
				}
				else
				{
					_loc9_ = 0.5;
				}
			}
			else
			{
				_loc8_.x = 50;
				_loc8_.htmlText = Localize.t("Reward");
			}
			rewardBox.addChild(_loc8_);
			if(_loc3_ == null)
			{
				return;
			}
			if(_loc3_.afk == true)
			{
				return;
			}
			var _loc6_:int = 20;
			_loc8_ = new Text();
			_loc8_.text = Localize.t("XP") + ":";
			_loc8_.x = 5;
			_loc8_.y = _loc6_;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 12;
			rewardBox.addChild(_loc8_);
			_loc8_ = new Text();
			_loc8_.color = 0x5555ff;
			_loc8_.alignRight();
			_loc8_.x = 285;
			_loc8_.y = _loc6_;
			_loc8_.size = 12;
			var _loc4_:int = Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (32 * g.me.level + 158 + _loc3_.xpSum));
			var _loc5_:int = Math.ceil(0.01 * _loc3_.bonusPercent * _loc9_ * (32 * g.me.level + 158 + _loc3_.xpSum));
			_loc4_ = Math.ceil(_loc4_ * (0.2 + 8 / (10 + (g.me.level - 1))));
			_loc5_ = Math.ceil(_loc5_ * (0.2 + 8 / (10 + (g.me.level - 1))));
			if(g.me.hasExpBoost)
			{
				_loc4_ = Math.ceil(_loc4_ * (1 + 0.3));
				_loc5_ = Math.ceil(_loc5_ * (1 + 0.3));
			}
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.htmlText = _loc4_ + " <font color=\'#33ff33\'>(" + _loc5_ + ")</font>";
			}
			else
			{
				_loc8_.htmlText = _loc4_.toString();
			}
			rewardBox.addChild(_loc8_);
			_loc6_ += 16;
			_loc8_ = new Text();
			_loc8_.text = Localize.t("Steel") + ":";
			_loc8_.x = 5;
			_loc8_.y = _loc6_;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 12;
			rewardBox.addChild(_loc8_);
			_loc8_ = new Text();
			_loc8_.color = 0x5555ff;
			_loc8_.alignRight();
			_loc8_.x = 285;
			_loc8_.y = _loc6_;
			_loc8_.size = 12;
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (12 * g.me.level + 138 + _loc3_.steelSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc9_ * (12 * g.me.level + 138 + _loc3_.steelSum))) + ")</font>";
			}
			else
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (12 * g.me.level + 138 + _loc3_.steelSum))).toString();
			}
			rewardBox.addChild(_loc8_);
			_loc6_ += 16;
			_loc8_ = new Text();
			_loc8_.text = Localize.t("Hyrdogen Crystals") + ":";
			_loc8_.x = 5;
			_loc8_.y = _loc6_;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 12;
			rewardBox.addChild(_loc8_);
			_loc8_ = new Text();
			_loc8_.color = 0x5555ff;
			_loc8_.alignRight();
			_loc8_.x = 285;
			_loc8_.y = _loc6_;
			_loc8_.size = 12;
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (3 * g.me.level + 52 + _loc3_.hydrogenSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc9_ * (3 * g.me.level + 52 + _loc3_.hydrogenSum))) + ")</font>";
			}
			else
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (3 * g.me.level + 52 + _loc3_.hydrogenSum))).toString();
			}
			rewardBox.addChild(_loc8_);
			_loc6_ += 16;
			_loc8_ = new Text();
			_loc8_.text = Localize.t("Plasma Fluid") + ":";
			_loc8_.x = 5;
			_loc8_.y = _loc6_;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 12;
			rewardBox.addChild(_loc8_);
			_loc8_ = new Text();
			_loc8_.color = 0x5555ff;
			_loc8_.alignRight();
			_loc8_.x = 285;
			_loc8_.y = _loc6_;
			_loc8_.size = 12;
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (2.5 * g.me.level + 40 + _loc3_.plasmaSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc9_ * (2.5 * g.me.level + 40 + _loc3_.plasmaSum))) + ")</font>";
			}
			else
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (2.5 * g.me.level + 40 + _loc3_.plasmaSum))).toString();
			}
			rewardBox.addChild(_loc8_);
			_loc6_ += 16;
			_loc8_ = new Text();
			_loc8_.text = Localize.t("Iridium") + ":";
			_loc8_.x = 5;
			_loc8_.y = _loc6_;
			_loc8_.color = 0x5555ff;
			_loc8_.size = 12;
			rewardBox.addChild(_loc8_);
			_loc8_ = new Text();
			_loc8_.color = 0x5555ff;
			_loc8_.alignRight();
			_loc8_.x = 285;
			_loc8_.y = _loc6_;
			_loc8_.size = 12;
			if(_loc3_.dailyBonus >= 0)
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (2 * g.me.level + 28 + _loc3_.iridiumSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc9_ * (2 * g.me.level + 28 + _loc3_.iridiumSum))) + ")</font>";
			}
			else
			{
				_loc8_.htmlText = int(Math.ceil(0.01 * _loc3_.bonusPercent * _loc7_ * (2 * g.me.level + 28 + _loc3_.iridiumSum))).toString();
			}
			rewardBox.addChild(_loc8_);
			_loc6_ += 16;
		}
	}
}

