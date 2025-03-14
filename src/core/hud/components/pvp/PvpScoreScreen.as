package core.hud.components.pvp {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class PvpScoreScreen extends PvpScreen {
		private var leaveButton:Button;
		private var addedItems:Vector.<PvpScoreHolder>;
		private var scrollArea:ScrollContainer;
		private var mainBody:Sprite;
		private var infoBox:Box;
		private var rewardBox:Box;
		private var contentBody:Sprite;
		
		public function PvpScoreScreen(g:Game) {
			super(g);
		}
		
		override public function load() : void {
			super.load();
			if(g.pvpManager != null) {
				g.pvpManager.scoreListUpdated = true;
			}
			leaveButton = new Button(showConfirmDialog,Localize.t("Leave Match"),"negative");
			leaveButton.x = 560;
			leaveButton.y = 520;
			addChild(leaveButton);
		}
		
		private function leaveMatch() : void {
			g.send("leavePvpMatch");
		}
		
		private function showConfirmDialog(e:TouchEvent) : void {
			var _local2:String = null;
			if(g.pvpManager.matchEnded == false) {
				_local2 = "Are you sure you want to leave? You will lose rating as if you lost the match!";
				g.showConfirmDialog(_local2,leaveMatch);
			} else {
				leaveMatch();
			}
		}
		
		override public function unload() : void {
			for each(var _local1:* in addedItems) {
				if(mainBody.contains(_local1.img)) {
					mainBody.removeChild(_local1.img);
				}
			}
			addedItems = new Vector.<PvpScoreHolder>();
		}
		
		override public function update() : void {
			var _local6:* = undefined;
			if(!g.pvpManager.scoreListUpdated) {
				return;
			}
			g.pvpManager.scoreListUpdated = false;
			if(contentBody != null && contains(contentBody)) {
				removeChild(contentBody);
			}
			addedItems = new Vector.<PvpScoreHolder>();
			contentBody = new Sprite();
			mainBody = new Sprite();
			addChild(contentBody);
			var _local7:int = 70;
			var _local5:int = 0;
			if(g.pvpManager != null && g.pvpManager.matchEnded) {
				addInfoBox(_local7,_local5);
				addRewardBox(_local7,_local5);
				_local5 = 220;
			} else {
				_local5 = 40;
			}
			var _local1:Text = new Text();
			if(g.solarSystem.type == "pvp dom") {
				_local1.text = Localize.t("Team");
			} else {
				_local1.text = Localize.t("Rank");
			}
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x55ff55;
			_local1.size = 12;
			contentBody.addChild(_local1);
			_local7 += 60;
			_local1 = new Text();
			_local1.text = Localize.t("Name");
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x55ff55;
			_local1.size = 12;
			contentBody.addChild(_local1);
			_local7 += 160;
			if(g.solarSystem.type == "pvp dom") {
				_local7 -= 20;
				_local1 = new Text();
				_local1.text = Localize.t("Score");
				_local1.x = _local7;
				_local1.y = _local5;
				_local1.color = 0x55ff55;
				_local1.size = 12;
				contentBody.addChild(_local1);
				_local7 += 50;
				_local1 = new Text();
				_local1.text = Localize.t("Kills");
				_local1.x = _local7;
				_local1.y = _local5;
				_local1.color = 0x55ff55;
				_local1.size = 12;
				contentBody.addChild(_local1);
				_local7 += 50;
			} else {
				_local1 = new Text();
				_local1.text = Localize.t("Kills");
				_local1.x = _local7;
				_local1.y = _local5;
				_local1.color = 0x55ff55;
				_local1.size = 12;
				contentBody.addChild(_local1);
				_local7 += 50;
			}
			_local1 = new Text();
			_local1.text = Localize.t("Deaths");
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x55ff55;
			_local1.size = 12;
			contentBody.addChild(_local1);
			if(g.solarSystem.type == "pvp dom") {
				_local7 += 50;
			} else {
				_local7 += 70;
			}
			_local1 = new Text();
			_local1.text = Localize.t("Damage");
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x55ff55;
			_local1.size = 12;
			contentBody.addChild(_local1);
			_local7 += 80;
			_local1 = new Text();
			_local1.text = Localize.t("Reward Bonus");
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x5555ff;
			_local1.size = 12;
			contentBody.addChild(_local1);
			_local7 += 110;
			_local1 = new Text();
			_local1.text = Localize.t("Rating");
			_local1.x = _local7;
			_local1.y = _local5;
			_local1.color = 0x5555ff;
			_local1.size = 12;
			contentBody.addChild(_local1);
			_local7 += 60;
			_local5 += 30;
			scrollArea = new ScrollContainer();
			scrollArea.y = _local5;
			scrollArea.x = 4;
			scrollArea.width = 700;
			if(g.pvpManager != null && g.pvpManager.matchEnded) {
				scrollArea.height = 250;
			} else {
				scrollArea.height = 430;
			}
			_local6 = g.pvpManager.getScoreList();
			if(_local6 == null || _local6.length == 0) {
				return;
			}
			_local5 = 10;
			var _local4:Boolean = false;
			var _local3:Boolean = false;
			if(g.pvpManager is DominationManager) {
				_local4 = true;
			}
			for each(var _local2:* in _local6) {
				_local2.load();
				_local2.img.x = 60;
				_local2.img.y = _local5;
				if(_local4) {
					if(g.me.team == _local2.team) {
						_local3 = true;
					} else {
						_local3 = false;
					}
				}
				_local2.update(_local4,_local3);
				mainBody.addChild(_local2.img);
				addedItems.push(_local2);
				_local5 = _local5 + _local2.img.height + 5;
			}
			contentBody.addChild(scrollArea);
			scrollArea.addChild(mainBody);
		}
		
		private function addInfoBox(x:int, y:int) : void {
			var _local4:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(infoBox != null && contains(infoBox)) {
				removeChild(infoBox);
			}
			infoBox = new Box(280,140,"highlight",0.5,10);
			infoBox.x = x - 10;
			infoBox.y = y + 60;
			addChild(infoBox);
			var _local3:Text = new Text();
			_local3.text = Localize.t("Achievement");
			_local3.x = 0;
			_local3.y = 0;
			_local3.color = 0x5555ff;
			_local3.size = 14;
			infoBox.addChild(_local3);
			_local3 = new Text();
			_local3.text = Localize.t("Bonus");
			_local3.x = 100;
			_local3.y = 0;
			_local3.color = 0x5555ff;
			_local3.size = 14;
			infoBox.addChild(_local3);
			if(_local4 == null) {
				return;
			}
			var _local5:int = 20;
			if(_local4.afk == true) {
				_local3 = new Text();
				_local3.text = Localize.t("Inactive/Afk") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = "-100%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
				Game.trackEvent("pvp","afk",g.me.name);
				return;
			}
			if(_local4.first > 0) {
				_local3 = new Text();
				if(g.pvpManager is DominationManager) {
					_local3.text = Localize.t("Victory") + ":";
				} else {
					_local3.text = Localize.t("First place") + ":";
				}
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.first.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.second > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Second place") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.second.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.third > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Third place") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.third.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.hotStreak3 > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Hot Streak x3") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.hotStreak3.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.hotStreak10 > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Hot Streak x10") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.hotStreak10.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.noDeaths > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Undying") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.noDeaths.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.capZone > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Successful Assult") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.capZone.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.defZone > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Dedicated Defence") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.defZone.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.brokeKillingSpree > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Broke a Spree") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.brokeKillingSpree.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.pickups > 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Pickup Bonus") + ":";
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local3 = new Text();
				_local3.text = _local4.pickups.toString() + "%";
				_local3.x = 220;
				_local3.y = _local5;
				_local3.color = 0x5555ff;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
			if(_local4.dailyBonus >= 0) {
				_local3 = new Text();
				_local3.text = Localize.t("Daily Bonus Reward!");
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x33ff33;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
				_local3 = new Text();
				_local3.text = "(" + _local4.dailyBonus + Localize.t("x matches left today)");
				_local3.x = 5;
				_local3.y = _local5;
				_local3.color = 0x33ff33;
				_local3.size = 12;
				infoBox.addChild(_local3);
				_local5 += 16;
			}
		}
		
		private function addRewardBox(x:int, y:int) : void {
			var _local7:Number = NaN;
			var _local4:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(rewardBox != null && contains(rewardBox)) {
				removeChild(rewardBox);
			}
			var _local8:Number = 0.5;
			if(g.solarSystem.type == "pvp dm") {
				_local8 = 2;
			} else if(g.solarSystem.type == "pvp dom") {
				_local8 = 2;
			}
			rewardBox = new Box(280,140,"highlight",0.5,10);
			rewardBox.x = x + 320;
			rewardBox.y = y + 60;
			addChild(rewardBox);
			var _local3:Text = new Text();
			_local3.y = 0;
			_local3.color = 0x5555ff;
			_local3.size = 14;
			if(_local4.dailyBonus >= 0) {
				_local3.x = 10;
				_local3.htmlText = Localize.t("Reward <font color=\'#33ff33\'>(Daily Bonus)</font>");
				_local7 = 0;
				if(g.solarSystem.type == "pvp dm") {
					_local7 = 2;
				} else if(g.solarSystem.type == "pvp dom") {
					_local7 = 2;
				} else {
					_local7 = 0.5;
				}
			} else {
				_local3.x = 50;
				_local3.htmlText = Localize.t("Reward");
			}
			rewardBox.addChild(_local3);
			if(_local4 == null) {
				return;
			}
			if(_local4.afk == true) {
				return;
			}
			var _local6:int = 20;
			_local3 = new Text();
			_local3.text = Localize.t("XP") + ":";
			_local3.x = 5;
			_local3.y = _local6;
			_local3.color = 0x5555ff;
			_local3.size = 12;
			rewardBox.addChild(_local3);
			_local3 = new Text();
			_local3.color = 0x5555ff;
			_local3.alignRight();
			_local3.x = 285;
			_local3.y = _local6;
			_local3.size = 12;
			var _local9:int = Math.ceil(0.01 * _local4.bonusPercent * _local8 * (32 * g.me.level + 158 + _local4.xpSum));
			var _local5:int = Math.ceil(0.01 * _local4.bonusPercent * _local7 * (32 * g.me.level + 158 + _local4.xpSum));
			_local9 = Math.ceil(_local9 * (0.2 + 8 / (10 + (g.me.level - 1))));
			_local5 = Math.ceil(_local5 * (0.2 + 8 / (10 + (g.me.level - 1))));
			if(g.me.hasExpBoost) {
				_local9 = Math.ceil(_local9 * (1 + 0.3));
				_local5 = Math.ceil(_local5 * (1 + 0.3));
			}
			if(_local4.dailyBonus >= 0) {
				_local3.htmlText = _local9 + " <font color=\'#33ff33\'>(" + _local5 + ")</font>";
			} else {
				_local3.htmlText = _local9.toString();
			}
			rewardBox.addChild(_local3);
			_local6 += 16;
			_local3 = new Text();
			_local3.text = Localize.t("Steel") + ":";
			_local3.x = 5;
			_local3.y = _local6;
			_local3.color = 0x5555ff;
			_local3.size = 12;
			rewardBox.addChild(_local3);
			_local3 = new Text();
			_local3.color = 0x5555ff;
			_local3.alignRight();
			_local3.x = 285;
			_local3.y = _local6;
			_local3.size = 12;
			if(_local4.dailyBonus >= 0) {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (12 * g.me.level + 138 + _local4.steelSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local4.bonusPercent * _local7 * (12 * g.me.level + 138 + _local4.steelSum))) + ")</font>";
			} else {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (12 * g.me.level + 138 + _local4.steelSum))).toString();
			}
			rewardBox.addChild(_local3);
			_local6 += 16;
			_local3 = new Text();
			_local3.text = Localize.t("Hyrdogen Crystals") + ":";
			_local3.x = 5;
			_local3.y = _local6;
			_local3.color = 0x5555ff;
			_local3.size = 12;
			rewardBox.addChild(_local3);
			_local3 = new Text();
			_local3.color = 0x5555ff;
			_local3.alignRight();
			_local3.x = 285;
			_local3.y = _local6;
			_local3.size = 12;
			if(_local4.dailyBonus >= 0) {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (3 * g.me.level + 52 + _local4.hydrogenSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local4.bonusPercent * _local7 * (3 * g.me.level + 52 + _local4.hydrogenSum))) + ")</font>";
			} else {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (3 * g.me.level + 52 + _local4.hydrogenSum))).toString();
			}
			rewardBox.addChild(_local3);
			_local6 += 16;
			_local3 = new Text();
			_local3.text = Localize.t("Plasma Fluid") + ":";
			_local3.x = 5;
			_local3.y = _local6;
			_local3.color = 0x5555ff;
			_local3.size = 12;
			rewardBox.addChild(_local3);
			_local3 = new Text();
			_local3.color = 0x5555ff;
			_local3.alignRight();
			_local3.x = 285;
			_local3.y = _local6;
			_local3.size = 12;
			if(_local4.dailyBonus >= 0) {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (2.5 * g.me.level + 40 + _local4.plasmaSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local4.bonusPercent * _local7 * (2.5 * g.me.level + 40 + _local4.plasmaSum))) + ")</font>";
			} else {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (2.5 * g.me.level + 40 + _local4.plasmaSum))).toString();
			}
			rewardBox.addChild(_local3);
			_local6 += 16;
			_local3 = new Text();
			_local3.text = Localize.t("Iridium") + ":";
			_local3.x = 5;
			_local3.y = _local6;
			_local3.color = 0x5555ff;
			_local3.size = 12;
			rewardBox.addChild(_local3);
			_local3 = new Text();
			_local3.color = 0x5555ff;
			_local3.alignRight();
			_local3.x = 285;
			_local3.y = _local6;
			_local3.size = 12;
			if(_local4.dailyBonus >= 0) {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (2 * g.me.level + 28 + _local4.iridiumSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local4.bonusPercent * _local7 * (2 * g.me.level + 28 + _local4.iridiumSum))) + ")</font>";
			} else {
				_local3.htmlText = int(Math.ceil(0.01 * _local4.bonusPercent * _local8 * (2 * g.me.level + 28 + _local4.iridiumSum))).toString();
			}
			rewardBox.addChild(_local3);
			_local6 += 16;
		}
	}
}

