package core.states.gameStates
{
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
	
	public class LeaderBoardState2 extends PlayState
	{
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
		
		public function LeaderBoardState2(g:Game)
		{
			super(g);
		}
		
		override public function enter() : void
		{
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
			defaultButton = new Button(function():void
			{
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
			topRankButton = new Button(function():void
			{
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
			topSurvivorButton = new Button(function():void
			{
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
			topPvpPlayerButton = new Button(function():void
			{
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
			topPlayerButton = new Button(function():void
			{
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
			g.controlZoneManager.load(function():void
			{
				topTroonsPerMinuteList = g.controlZoneManager.getTopTroonsPerMinuteClans();
				drawTopTroonsPerMinute();
			});
			if(topRankList == null)
			{
				g.dataManager.loadRangeFromBigDB("Clans","ByRank",null,function(param1:Array):void
				{
					var array:Array = param1;
					topRankList = array;
					loadCompleted();
					drawTopRank();
					scrollArea.readjustLayout();
					if(topPvpPlayersList == null)
					{
						g.rpcServiceRoom("requestPvpHighscore",function(param1:Message):void
						{
							var _loc3_:int = 0;
							var _loc2_:Object = null;
							topPvpPlayersList = [];
							_loc3_ = 0;
							while(_loc3_ < param1.length)
							{
								_loc2_ = {};
								_loc2_.rank = param1.getInt(_loc3_);
								_loc2_.name = param1.getString(_loc3_ + 1);
								_loc2_.key = param1.getString(_loc3_ + 2);
								_loc2_.level = param1.getInt(_loc3_ + 3);
								_loc2_.clan = param1.getString(_loc3_ + 4);
								_loc2_.value = param1.getNumber(_loc3_ + 5);
								topPvpPlayersList.push(_loc2_);
								_loc3_ += 6;
							}
							drawTopPvpPlayers();
						});
					}
					else
					{
						drawTopPvpPlayers();
					}
					if(topPlayersList == null)
					{
						g.rpcServiceRoom("requestTroonsHighscore",function(param1:Message):void
						{
							var _loc3_:int = 0;
							var _loc2_:Object = null;
							topPlayersList = [];
							_loc3_ = 0;
							while(_loc3_ < param1.length)
							{
								_loc2_ = {};
								_loc2_.rank = param1.getInt(_loc3_);
								_loc2_.name = param1.getString(_loc3_ + 1);
								_loc2_.key = param1.getString(_loc3_ + 2);
								_loc2_.level = param1.getInt(_loc3_ + 3);
								_loc2_.clan = param1.getString(_loc3_ + 4);
								_loc2_.value = param1.getNumber(_loc3_ + 5);
								topPlayersList.push(_loc2_);
								_loc3_ += 6;
							}
							drawTopPlayers();
						});
					}
					else
					{
						drawTopPlayers();
					}
				},50);
			}
			else
			{
				drawTopRank();
				drawTopPlayers();
				drawTopPvpPlayers();
			}
			if(topSurvivorList == null)
			{
				g.dataManager.loadRangeFromBigDB("Clans","ByHighscore",null,function(param1:Array):void
				{
					topSurvivorList = param1;
					loadCompleted();
					drawTopSurvivor();
					scrollArea.readjustLayout();
				},50);
			}
			else
			{
				drawTopSurvivor();
			}
			nextReset = new Text();
			date = new Date();
			month = date.month;
			if(month == 11)
			{
				month = 0;
			}
			year = date.fullYear;
			months = [Localize.t("January"),Localize.t("February"),Localize.t("March"),Localize.t("April"),Localize.t("May"),Localize.t("June"),Localize.t("July"),Localize.t("August"),Localize.t("September"),Localize.t("October"),Localize.t("November"),Localize.t("December")];
			nextReset.htmlText = Localize.t("Next season starts at:") + " <font color=\'#ffff88\'>1 " + months[month + 1] + " " + year + "</font>";
			nextReset.y = 40;
			nextReset.x = 50;
			addChild(nextReset);
		}
		
		public function drawTopRank() : void
		{
			var _loc2_:int = 0;
			for each(var _loc1_ in topRankList)
			{
				drawClanObject(_loc1_,_loc2_,topRankContainer);
				_loc2_++;
			}
		}
		
		public function drawTopSurvivor() : void
		{
			var _loc2_:int = 0;
			for each(var _loc1_ in topSurvivorList)
			{
				drawClanObject(_loc1_,_loc2_,topSurvivorContainer,false,true);
				_loc2_++;
			}
		}
		
		public function drawTopTroonsPerMinute() : void
		{
			var _loc1_:Text = null;
			var _loc3_:int = 0;
			for each(var _loc2_ in topTroonsPerMinuteList)
			{
				drawClanObject(_loc2_,_loc3_,topTroonsPerMinuteContainer,true);
				_loc3_++;
			}
			if(_loc3_ == 0)
			{
				_loc1_ = new Text();
				_loc1_.text = Localize.t("No clans have any any control right now.");
				topTroonsPerMinuteContainer.addChild(_loc1_);
			}
		}
		
		private function drawClanObject(clan:Object, i:int, canvas:Sprite, perMinute:Boolean = false, survivor:* = false) : void
		{
			var rank:Text;
			var logo:Image;
			var name:Text;
			var troons:Text;
			var troonIcon:Image;
			var y:int = i * 45;
			var quad:Quad = new Quad(670,40,0x212121);
			quad.y = y;
			quad.addEventListener("touch",function(param1:TouchEvent):void
			{
				if(param1.getTouch(quad,"began"))
				{
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
			if(survivor)
			{
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
		
		private function drawTopPlayers() : void
		{
			var _loc3_:int = 0;
			var _loc1_:int = 0;
			var _loc2_:int = 0;
			_loc3_ = 0;
			while(_loc3_ < topPlayersList.length)
			{
				if(topPlayersList[_loc3_].rank != _loc1_ + 1)
				{
					drawBlank(_loc3_,topPlayersContainer);
					_loc2_ = 1;
				}
				drawPlayerObject(topPlayersList[_loc3_],_loc3_,_loc2_,topPlayersContainer,false);
				_loc1_ = int(topPlayersList[_loc3_].rank);
				_loc3_++;
			}
		}
		
		private function drawTopPvpPlayers() : void
		{
			var _loc3_:int = 0;
			var _loc1_:int = 0;
			var _loc2_:int = 0;
			_loc3_ = 0;
			while(_loc3_ < topPvpPlayersList.length)
			{
				if(topPvpPlayersList[_loc3_].rank != _loc1_ + 1)
				{
					drawBlank(_loc3_,topPvpPlayersContainer);
					_loc2_ = 1;
				}
				drawPlayerObject(topPvpPlayersList[_loc3_],_loc3_,_loc2_,topPvpPlayersContainer,true);
				_loc1_ = int(topPvpPlayersList[_loc3_].rank);
				_loc3_++;
			}
		}
		
		private function drawBlank(i:int, canvas:Sprite) : void
		{
			var _loc4_:int = i * 45;
			var _loc3_:Quad = new Quad(670,40,0x212121);
			_loc3_.y = _loc4_;
			_loc4_ += 10;
			var _loc5_:Text = new Text();
			_loc5_.text = "...";
			_loc5_.size = 14;
			_loc5_.y = _loc4_;
			_loc5_.x = 10;
			canvas.addChild(_loc3_);
			canvas.addChild(_loc5_);
		}
		
		private function drawPlayerObject(player:Object, i:int, offset:int, canvas:Sprite, isPvp:Boolean) : void
		{
			var _loc9_:Quad = null;
			var _loc10_:Object = null;
			var _loc14_:Image = null;
			var _loc15_:Image = null;
			var _loc12_:int = (i + offset) * 45;
			if(player.key == g.me.id)
			{
				_loc9_ = new Quad(670,40,0x424242);
			}
			else
			{
				_loc9_ = new Quad(670,40,0x212121);
			}
			_loc9_.y = _loc12_;
			_loc12_ += 10;
			var _loc13_:Text = new Text();
			if(isPvp == true)
			{
				_loc13_.text = topPvpPlayersList[i].rank;
				_loc10_ = getPlayerClanObj(topPvpPlayersList[i].clan);
			}
			else
			{
				_loc13_.text = topPlayersList[i].rank;
				_loc10_ = getPlayerClanObj(topPlayersList[i].clan);
			}
			_loc13_.size = 14;
			_loc13_.y = _loc12_;
			_loc13_.x = 10;
			var _loc7_:* = 11184810;
			if(_loc10_ != null)
			{
				_loc7_ = uint(_loc10_.color);
				_loc14_ = new Image(textureManager.getTextureGUIByTextureName(_loc10_.logo));
				new ToolTip(g,_loc14_,_loc10_.name);
			}
			else
			{
				_loc14_ = new Image(textureManager.getTextureGUIByTextureName("clan_logo1"));
				_loc14_.color = 0x666666;
				_loc14_.alpha = 0.1;
			}
			_loc14_.y = _loc12_ - 2;
			_loc14_.x = _loc13_.x + _loc13_.width + 10;
			_loc14_.color = _loc7_;
			_loc14_.scaleX = _loc14_.scaleY = 0.25;
			var _loc11_:Text = new Text();
			_loc11_.text = player.name;
			_loc11_.y = _loc12_;
			_loc11_.size = 14;
			_loc11_.color = _loc7_;
			_loc11_.x = _loc14_.x + _loc14_.width + 10;
			var _loc6_:Text = new Text();
			_loc6_.text = "(Lv. " + player.level + ")";
			_loc6_.y = _loc12_;
			_loc6_.size = 14;
			_loc6_.color = _loc7_;
			_loc6_.x = _loc11_.x + _loc11_.width + 10;
			var _loc8_:Text = new Text();
			_loc8_.text = Util.formatAmount(player.value.toFixed(1));
			_loc8_.y = _loc12_;
			_loc8_.size = 14;
			_loc8_.color = Style.COLOR_YELLOW;
			_loc8_.x = 610 - _loc8_.width - 10;
			if(!isPvp)
			{
				_loc15_ = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
				_loc15_.y = _loc12_;
				_loc15_.x = _loc8_.x + _loc8_.width + 10;
			}
			else
			{
				_loc15_ = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
				_loc15_.y = _loc12_ + 20;
				_loc15_.color = 0xff0000;
				_loc15_.x = _loc8_.x + _loc8_.width + 10;
				_loc15_.scaleX = _loc15_.scaleY = 0.25;
				_loc15_.rotation = -0.5 * 3.141592653589793;
			}
			canvas.addChild(_loc9_);
			canvas.addChild(_loc13_);
			canvas.addChild(_loc14_);
			canvas.addChild(_loc11_);
			canvas.addChild(_loc6_);
			canvas.addChild(_loc8_);
			canvas.addChild(_loc15_);
		}
		
		private function getPlayerClanObj(clanKey:String) : Object
		{
			for each(var _loc2_ in topRankList)
			{
				if(_loc2_.key == clanKey)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		override public function execute() : void
		{
			updateInput();
			super.execute();
		}
		
		private function updateInput() : void
		{
			if(!loaded)
			{
				return;
			}
			checkAccelerate(true);
			if(keybinds.isEscPressed)
			{
				close();
				return;
			}
		}
		
		private function close() : void
		{
			sm.changeState(new RoamingState(g));
		}
	}
}

