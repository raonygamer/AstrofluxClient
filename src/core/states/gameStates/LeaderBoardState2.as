package core.states.gameStates {
	import core.hud.components.Button;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import generics.Util;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class LeaderBoardState2 extends PlayState {
		private static const START_HEIGHT:int = 20;
		private static const START_WIDTH:int = 50;
		private static var topRankList:Array;
		private static var topSurvivorList:Array;
		private static var topPvpPlayersList:Array;
		private static var topPlayersList:Array;
		private static var topPlayerClans:Array;
		private static var topRankContainer:Sprite = new Sprite();
		private static var topSurvivorContainer:Sprite = new Sprite();
		private static var topPvpPlayersContainer:Sprite = new Sprite();
		private static var topPlayersContainer:Sprite = new Sprite();
		private var goTo:String;
		private var currentHeight:Number = 20;
		private var currentWidth:Number = 50;
		private var bgr:Image;
		private var closeButton:ButtonExpandableHud;
		private var scrollArea:ScrollContainer;
		private var topTroonsPerMinuteList:Vector.<Object>;
		private var topTroonsPerMinuteContainer:Sprite = new Sprite();
		private var dataManager:IDataManager;
		
		public function LeaderBoardState2(g:Game) {
			super(g);
		}
		
		override public function enter() : void {
			var defaultButton:Button;
			var topRankButton:Button;
			var topSurvivorButton:Button;
			var topPvpPlayerButton:Button;
			var topPlayerButton:Button;
			var nextReset:Text;
			var date:Date;
			var month:Number;
			var year:Number;
			var months:Array;
			super.enter();
			dataManager = DataLocator.getService();
			g.hud.show = false;
			drawBlackBackground();
			bgr = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			addChild(bgr);
			topTroonsPerMinuteContainer.visible = true;
			topRankContainer.visible = false;
			topPlayersContainer.visible = false;
			topSurvivorContainer.visible = false;
			topPvpPlayersContainer.visible = false;
			defaultButton = new Button(function():void {
				defaultButton.enabled = false;
				topRankButton.enabled = true;
				topPlayerButton.enabled = true;
				topSurvivorButton.enabled = true;
				topPvpPlayerButton.enabled = true;
				topTroonsPerMinuteContainer.visible = true;
				topRankContainer.visible = false;
				topPlayersContainer.visible = false;
				topSurvivorContainer.visible = false;
				topPvpPlayersContainer.visible = false;
				scrollArea.scrollToPosition(0,0);
			},Localize.t("Planet Wars"));
			defaultButton.x = 50;
			defaultButton.y = 60;
			addChild(defaultButton);
			defaultButton.enabled = false;
			topRankButton = new Button(function():void {
				defaultButton.enabled = true;
				topRankButton.enabled = false;
				topPlayerButton.enabled = true;
				topSurvivorButton.enabled = true;
				topPvpPlayerButton.enabled = true;
				topTroonsPerMinuteContainer.visible = false;
				topRankContainer.visible = true;
				topPlayersContainer.visible = false;
				topSurvivorContainer.visible = false;
				topPvpPlayersContainer.visible = false;
				scrollArea.scrollToPosition(0,0);
			},Localize.t("Power Clans"));
			topRankButton.x = defaultButton.x + defaultButton.width + 10;
			topRankButton.y = 60;
			addChild(topRankButton);
			topSurvivorButton = new Button(function():void {
				defaultButton.enabled = true;
				topRankButton.enabled = true;
				topPlayerButton.enabled = true;
				topSurvivorButton.enabled = false;
				topPvpPlayerButton.enabled = true;
				topTroonsPerMinuteContainer.visible = false;
				topRankContainer.visible = false;
				topSurvivorContainer.visible = true;
				topPlayersContainer.visible = false;
				topPvpPlayersContainer.visible = false;
				scrollArea.scrollToPosition(0,0);
			},Localize.t("Survivor Clans"));
			topSurvivorButton.x = topRankButton.x + topRankButton.width + 10;
			topSurvivorButton.y = 60;
			addChild(topSurvivorButton);
			topPvpPlayerButton = new Button(function():void {
				defaultButton.enabled = true;
				topRankButton.enabled = true;
				topPlayerButton.enabled = true;
				topPvpPlayerButton.enabled = false;
				topSurvivorButton.enabled = true;
				topTroonsPerMinuteContainer.visible = false;
				topRankContainer.visible = false;
				topPlayersContainer.visible = false;
				topPvpPlayersContainer.visible = true;
				topSurvivorContainer.visible = false;
				scrollArea.scrollToPosition(0,0);
			},Localize.t("Top PvP Players"));
			topPvpPlayerButton.x = topSurvivorButton.x + topSurvivorButton.width + 10;
			topPvpPlayerButton.y = 60;
			addChild(topPvpPlayerButton);
			topPlayerButton = new Button(function():void {
				defaultButton.enabled = true;
				topRankButton.enabled = true;
				topPlayerButton.enabled = false;
				topPvpPlayerButton.enabled = true;
				topSurvivorButton.enabled = true;
				topTroonsPerMinuteContainer.visible = false;
				topRankContainer.visible = false;
				topPlayersContainer.visible = true;
				topSurvivorContainer.visible = false;
				topPvpPlayersContainer.visible = false;
				scrollArea.scrollToPosition(0,0);
			},Localize.t("Top Players"));
			topPlayerButton.x = topPvpPlayerButton.x + topPvpPlayerButton.width + 10;
			topPlayerButton.y = 60;
			addChild(topPlayerButton);
			closeButton = new ButtonExpandableHud(close,Localize.t("close"));
			closeButton.x = bgr.width - 46 - closeButton.width;
			closeButton.y = 0;
			addChild(closeButton);
			scrollArea = new ScrollContainer();
			scrollArea.y = 100;
			scrollArea.x = 50;
			scrollArea.width = 670;
			scrollArea.height = 460;
			addChild(scrollArea);
			scrollArea.addChild(topRankContainer);
			scrollArea.addChild(topTroonsPerMinuteContainer);
			scrollArea.addChild(topSurvivorContainer);
			scrollArea.addChild(topPlayersContainer);
			scrollArea.addChild(topPvpPlayersContainer);
			g.controlZoneManager.load(function():void {
				topTroonsPerMinuteList = g.controlZoneManager.getTopTroonsPerMinuteClans();
				drawTopTroonsPerMinute();
			});
			if(topRankList == null) {
				g.dataManager.loadRangeFromBigDB("Clans","ByRank",null,function(param1:Array):void {
					var array:Array = param1;
					topRankList = array;
					loadCompleted();
					drawTopRank();
					scrollArea.readjustLayout();
					if(topPvpPlayersList == null) {
						g.rpcServiceRoom("requestPvpHighscore",function(param1:Message):void {
							var _local3:int = 0;
							var _local2:Object = null;
							topPvpPlayersList = [];
							_local3 = 0;
							while(_local3 < param1.length) {
								_local2 = {};
								_local2.rank = param1.getInt(_local3);
								_local2.name = param1.getString(_local3 + 1);
								_local2.key = param1.getString(_local3 + 2);
								_local2.level = param1.getInt(_local3 + 3);
								_local2.clan = param1.getString(_local3 + 4);
								_local2.value = param1.getNumber(_local3 + 5);
								topPvpPlayersList.push(_local2);
								_local3 += 6;
							}
							drawTopPvpPlayers();
						});
					} else {
						drawTopPvpPlayers();
					}
					if(topPlayersList == null) {
						g.rpcServiceRoom("requestTroonsHighscore",function(param1:Message):void {
							var _local3:int = 0;
							var _local2:Object = null;
							topPlayersList = [];
							_local3 = 0;
							while(_local3 < param1.length) {
								_local2 = {};
								_local2.rank = param1.getInt(_local3);
								_local2.name = param1.getString(_local3 + 1);
								_local2.key = param1.getString(_local3 + 2);
								_local2.level = param1.getInt(_local3 + 3);
								_local2.clan = param1.getString(_local3 + 4);
								_local2.value = param1.getNumber(_local3 + 5);
								topPlayersList.push(_local2);
								_local3 += 6;
							}
							drawTopPlayers();
						});
					} else {
						drawTopPlayers();
					}
				},50);
			} else {
				drawTopRank();
				drawTopPlayers();
				drawTopPvpPlayers();
			}
			if(topSurvivorList == null) {
				g.dataManager.loadRangeFromBigDB("Clans","ByHighscore",null,function(param1:Array):void {
					topSurvivorList = param1;
					loadCompleted();
					drawTopSurvivor();
					scrollArea.readjustLayout();
				},50);
			} else {
				drawTopSurvivor();
			}
			nextReset = new Text();
			date = new Date();
			month = date.month;
			if(month == 11) {
				month = 0;
			}
			year = date.fullYear;
			months = [Localize.t("January"),Localize.t("February"),Localize.t("March"),Localize.t("April"),Localize.t("May"),Localize.t("June"),Localize.t("July"),Localize.t("August"),Localize.t("September"),Localize.t("October"),Localize.t("November"),Localize.t("December")];
			nextReset.htmlText = Localize.t("Next season starts at:") + " <font color=\'#ffff88\'>1 " + months[month + 1] + " " + year + "</font>";
			nextReset.y = 40;
			nextReset.x = 50;
			addChild(nextReset);
		}
		
		public function drawTopRank() : void {
			var _local2:int = 0;
			for each(var _local1:* in topRankList) {
				drawClanObject(_local1,_local2,topRankContainer);
				_local2++;
			}
		}
		
		public function drawTopSurvivor() : void {
			var _local2:int = 0;
			for each(var _local1:* in topSurvivorList) {
				drawClanObject(_local1,_local2,topSurvivorContainer,false,true);
				_local2++;
			}
		}
		
		public function drawTopTroonsPerMinute() : void {
			var _local2:Text = null;
			var _local3:int = 0;
			for each(var _local1:* in topTroonsPerMinuteList) {
				drawClanObject(_local1,_local3,topTroonsPerMinuteContainer,true);
				_local3++;
			}
			if(_local3 == 0) {
				_local2 = new Text();
				_local2.text = Localize.t("No clans have any any control right now.");
				topTroonsPerMinuteContainer.addChild(_local2);
			}
		}
		
		private function drawClanObject(clan:Object, i:int, canvas:Sprite, perMinute:Boolean = false, survivor:* = false) : void {
			var rank:Text;
			var logo:Image;
			var name:Text;
			var troons:Text;
			var troonIcon:Image;
			var y:int = i * 45;
			var quad:Quad = new Quad(670,40,0x212121);
			quad.y = y;
			quad.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(quad,"began")) {
					sm.changeState(new ClanState(g,clan.key));
					param1.stopPropagation();
				}
			});
			quad.useHandCursor = true;
			y += 10;
			rank = new Text();
			rank.text = (i + 1).toString();
			rank.size = 14;
			rank.y = y;
			rank.x = 10;
			logo = new Image(textureManager.getTextureGUIByTextureName(clan.logo));
			logo.y = y - 2;
			logo.x = rank.x + rank.width + 10;
			logo.color = clan.color;
			logo.scaleX = logo.scaleY = 0.25;
			name = new Text();
			name.text = clan.name;
			name.y = y;
			name.size = 14;
			name.color = clan.color;
			name.x = logo.x + logo.width + 10;
			troons = new Text();
			troons.text = perMinute ? Localize.t("[troons] / min").replace("[troons]",clan.troons) : Util.formatAmount(clan.troons);
			if(survivor) {
				troons.text = Math.floor(clan["highscoreic3w-BxdMU6qWhX9t3_EaA"]).toString();
			}
			troons.y = y;
			troons.size = 14;
			troons.color = Style.COLOR_YELLOW;
			troons.x = 610 - troons.width - 10;
			troonIcon = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			troonIcon.y = y;
			troonIcon.x = troons.x + troons.width + 10;
			canvas.addChild(quad);
			canvas.addChild(rank);
			canvas.addChild(logo);
			canvas.addChild(name);
			canvas.addChild(troons);
			canvas.addChild(troonIcon);
		}
		
		private function drawTopPlayers() : void {
			var _local3:int = 0;
			var _local1:int = 0;
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < topPlayersList.length) {
				if(topPlayersList[_local3].rank != _local1 + 1) {
					drawBlank(_local3,topPlayersContainer);
					_local2 = 1;
				}
				drawPlayerObject(topPlayersList[_local3],_local3,_local2,topPlayersContainer,false);
				_local1 = int(topPlayersList[_local3].rank);
				_local3++;
			}
		}
		
		private function drawTopPvpPlayers() : void {
			var _local3:int = 0;
			var _local1:int = 0;
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < topPvpPlayersList.length) {
				if(topPvpPlayersList[_local3].rank != _local1 + 1) {
					drawBlank(_local3,topPvpPlayersContainer);
					_local2 = 1;
				}
				drawPlayerObject(topPvpPlayersList[_local3],_local3,_local2,topPvpPlayersContainer,true);
				_local1 = int(topPvpPlayersList[_local3].rank);
				_local3++;
			}
		}
		
		private function drawBlank(i:int, canvas:Sprite) : void {
			var _local5:int = i * 45;
			var _local4:Quad = new Quad(670,40,0x212121);
			_local4.y = _local5;
			_local5 += 10;
			var _local3:Text = new Text();
			_local3.text = "...";
			_local3.size = 14;
			_local3.y = _local5;
			_local3.x = 10;
			canvas.addChild(_local4);
			canvas.addChild(_local3);
		}
		
		private function drawPlayerObject(player:Object, i:int, offset:int, canvas:Sprite, isPvp:Boolean) : void {
			var _local10:Quad = null;
			var _local12:Object = null;
			var _local6:Image = null;
			var _local7:Image = null;
			var _local15:int = (i + offset) * 45;
			if(player.key == g.me.id) {
				_local10 = new Quad(670,40,0x424242);
			} else {
				_local10 = new Quad(670,40,0x212121);
			}
			_local10.y = _local15;
			_local15 += 10;
			var _local9:Text = new Text();
			if(isPvp == true) {
				_local9.text = topPvpPlayersList[i].rank;
				_local12 = getPlayerClanObj(topPvpPlayersList[i].clan);
			} else {
				_local9.text = topPlayersList[i].rank;
				_local12 = getPlayerClanObj(topPlayersList[i].clan);
			}
			_local9.size = 14;
			_local9.y = _local15;
			_local9.x = 10;
			var _local13:* = 11184810;
			if(_local12 != null) {
				_local13 = uint(_local12.color);
				_local6 = new Image(textureManager.getTextureGUIByTextureName(_local12.logo));
				new ToolTip(g,_local6,_local12.name);
			} else {
				_local6 = new Image(textureManager.getTextureGUIByTextureName("clan_logo1"));
				_local6.color = 0x666666;
				_local6.alpha = 0.1;
			}
			_local6.y = _local15 - 2;
			_local6.x = _local9.x + _local9.width + 10;
			_local6.color = _local13;
			_local6.scaleX = _local6.scaleY = 0.25;
			var _local14:Text = new Text();
			_local14.text = player.name;
			_local14.y = _local15;
			_local14.size = 14;
			_local14.color = _local13;
			_local14.x = _local6.x + _local6.width + 10;
			var _local11:Text = new Text();
			_local11.text = "(Lv. " + player.level + ")";
			_local11.y = _local15;
			_local11.size = 14;
			_local11.color = _local13;
			_local11.x = _local14.x + _local14.width + 10;
			var _local8:Text = new Text();
			_local8.text = Util.formatAmount(player.value.toFixed(1));
			_local8.y = _local15;
			_local8.size = 14;
			_local8.color = Style.COLOR_YELLOW;
			_local8.x = 610 - _local8.width - 10;
			if(!isPvp) {
				_local7 = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
				_local7.y = _local15;
				_local7.x = _local8.x + _local8.width + 10;
			} else {
				_local7 = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
				_local7.y = _local15 + 20;
				_local7.color = 0xff0000;
				_local7.x = _local8.x + _local8.width + 10;
				_local7.scaleX = _local7.scaleY = 0.25;
				_local7.rotation = -0.5 * 3.141592653589793;
			}
			canvas.addChild(_local10);
			canvas.addChild(_local9);
			canvas.addChild(_local6);
			canvas.addChild(_local14);
			canvas.addChild(_local11);
			canvas.addChild(_local8);
			canvas.addChild(_local7);
		}
		
		private function getPlayerClanObj(clanKey:String) : Object {
			for each(var _local2:* in topRankList) {
				if(_local2.key == clanKey) {
					return _local2;
				}
			}
			return null;
		}
		
		override public function execute() : void {
			updateInput();
			super.execute();
		}
		
		private function updateInput() : void {
			if(!loaded) {
				return;
			}
			checkAccelerate(true);
			if(keybinds.isEscPressed) {
				close();
				return;
			}
		}
		
		private function close() : void {
			sm.changeState(new RoamingState(g));
		}
	}
}

