package core.hud.components.pvp
{
	import core.hud.components.Text;
	import core.hud.components.map.Map;
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.PvpScreenState;
	import playerio.Message;
	import starling.events.Event;
	
	public class PvpManager
	{
		public static const MATCH_WARMUP:int = 0;
		public static const MATCH_STARTING:int = 1;
		public static const MATCH_RUNNING:int = 2;
		public static const MATCH_ENDED:int = 3;
		public static const MATCH_CLOSED:int = 4;
		public static const ITEM_HEALTH:String = "health";
		public static const ITEM_HEALTH_SMALL:String = "healthSmall";
		public static const ITEM_SHIELD:String = "shield";
		public static const ITEM_SHIELD_SMALL:String = "shieldSmall";
		public static const ITEM_QUAD:String = "quad";
		public static const ITEM_DOMINATION_ZONE:String = "dominationZone";
		public static const ITEM_TEAM1_SAFE_ZONE:String = "safezoneT1";
		public static const ITEM_TEAM2_SAFE_ZONE:String = "safezoneT2";
		protected var g:Game;
		public var type:String;
		protected var scoreLimit:int;
		protected var matchState:int;
		protected var roomStartTime:Number;
		protected var matchStartTime:Number;
		protected var matchEndTime:Number;
		protected var roomEndTime:Number;
		protected var endGameScreenTime:Number;
		protected var requestTime:Number;
		public var matchEnded:Boolean;
		public var scoreListUpdated:Boolean;
		protected var scoreList:Vector.<PvpScoreHolder>;
		protected var timerText:Text;
		protected var scoreText:Text;
		protected var leaderText:Text;
		protected var map:Map;
		protected var isLoaded:Boolean = false;
		
		public function PvpManager(g:Game, addTexts:Boolean = true)
		{
			super();
			g.addMessageHandler("setHostile",m_setHostile);
			g.addMessageHandler("pvpInitPlayers",m_pvpInitPlayers);
			g.addMessageHandler("gameEnded",m_gameEnded);
			g.addMessageHandler("updateScore",m_updateScore);
			g.addMessageHandler("usingQuad",m_startQuad);
			scoreList = new Vector.<PvpScoreHolder>();
			scoreListUpdated = false;
			matchEnded = false;
			matchState = 0;
			matchStartTime = 0;
			matchEndTime = 0;
			if(addTexts)
			{
				timerText = new Text();
				timerText.htmlText = "Starting in: <FONT COLOR=\'#7777ff\'>x:xx</FONT>";
				timerText.alignLeft();
				timerText.size = 16;
				timerText.color = 0x55ff55;
				g.addChildToOverlay(timerText);
				scoreText = new Text();
				scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>xx</FONT>";
				scoreText.alignRight();
				scoreText.size = 16;
				scoreText.color = 0x55ff55;
				g.addChildToOverlay(scoreText);
				leaderText = new Text();
				leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>None</FONT>";
				leaderText.alignLeft();
				leaderText.size = 16;
				leaderText.color = 0x55ff55;
				g.addChildToOverlay(leaderText);
			}
			roomStartTime = 0;
			requestTime = g.time;
			map = new Map(g);
			g.addChildToOverlay(map);
			g.addResizeListener(resize);
			this.g = g;
			resize();
		}
		
		private static function compareFunction(psh1:PvpScoreHolder, psh2:PvpScoreHolder) : int
		{
			if(psh1.score < psh2.score)
			{
				return 1;
			}
			if(psh1.score > psh2.score)
			{
				return -1;
			}
			if(psh1.deaths > psh2.deaths)
			{
				return 1;
			}
			if(psh1.deaths < psh2.deaths)
			{
				return -1;
			}
			if(psh1.damageSum < psh2.damageSum)
			{
				return 1;
			}
			if(psh1.damageSum > psh2.damageSum)
			{
				return -1;
			}
			return 1;
		}
		
		public function updateMap(p:Player) : void
		{
			map.playerJoined(p);
		}
		
		public function addZones(items:Array) : void
		{
		}
		
		public function formatTime(time:Number) : String
		{
			if(time < 0 || time.toString() == "NaN")
			{
				return "0:00";
			}
			var _loc3_:int = time;
			var _loc2_:int = _loc3_ % (60);
			_loc3_ = (_loc3_ - _loc2_) / (60);
			if(_loc2_ < 2)
			{
				return _loc3_ + ":01";
			}
			if(_loc2_ < 10)
			{
				return _loc3_ + ":0" + _loc2_;
			}
			return _loc3_ + ":" + _loc2_;
		}
		
		protected function loadMap() : void
		{
			map.load(0.035,160,160,0,0,true);
			isLoaded = true;
		}
		
		public function update() : void
		{
			if(!isLoaded)
			{
				loadMap();
			}
			if(requestTime < g.time && (roomStartTime == 0 || g.playerManager.players.length > scoreList.length))
			{
				requestTime = g.time + 2000;
				g.send("requestInitPlayers");
			}
			map.update();
			switch(matchState)
			{
				case 0:
					if(timerText != null)
					{
						timerText.htmlText = "Starting in: <FONT COLOR=\'#7777ff\'>" + formatTime((matchStartTime - g.time) / 1000) + "</FONT>";
						scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>" + scoreLimit + "</FONT>";
						leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>None</FONT>";
					}
					if(matchStartTime != 0 && matchStartTime < g.time)
					{
						matchState = 2;
						g.textManager.createPvpText("The Match begins! Fight!",0,50);
					}
					for each(var _loc1_ in g.playerManager.players)
					{
						_loc1_.inSafeZone = true;
					}
					break;
				case 2:
					if(timerText != null)
					{
						timerText.htmlText = "Time Left: <FONT COLOR=\'#7777ff\'>" + formatTime((matchEndTime - g.time) / 1000) + "</FONT>";
						if(scoreList.length > 0)
						{
							scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>" + (scoreLimit - scoreList[0].score).toString() + "</FONT>";
							if(scoreList[0].playerKey == g.me.id)
							{
								leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>You</FONT>";
							}
							else
							{
								leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>" + scoreList[0].playerName + "</FONT>";
							}
						}
					}
					if(matchEndTime != 0 && matchEndTime < g.time)
					{
						matchState = 3;
						matchEnded = true;
					}
					break;
				case 3:
					if(timerText != null)
					{
						timerText.htmlText = "Closing in: <FONT COLOR=\'#7777ff\'>" + formatTime((roomEndTime - g.time) / 1000) + "</FONT>";
						scoreText.htmlText = "<FONT COLOR=\'#7777ff\'>Game over!</FONT>";
						if(scoreList.length == 1)
						{
							if(scoreList[0].playerKey == g.me.id)
							{
								leaderText.htmlText = "Winner: <FONT COLOR=\'#7777ff\'>You</FONT>";
							}
							else
							{
								leaderText.htmlText = "Winner: <FONT COLOR=\'#7777ff\'>" + scoreList[0].playerName + "</FONT>";
							}
						}
					}
					if(endGameScreenTime != 0 && endGameScreenTime < g.time)
					{
						g.enterState(new PvpScreenState(g));
						endGameScreenTime = g.time + 60 * 1000;
					}
					if(roomEndTime != 0 && roomEndTime < g.time)
					{
						matchState = 4;
					}
			}
		}
		
		public function hideText() : void
		{
			timerText.visible = false;
			scoreText.visible = false;
			leaderText.visible = false;
		}
		
		public function showText() : void
		{
			timerText.visible = true;
			scoreText.visible = true;
			leaderText.visible = true;
		}
		
		protected function m_gameEnded(m:Message) : void
		{
			var _loc5_:Number = NaN;
			var _loc4_:int = 0;
			matchEndTime = m.getNumber(_loc4_++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = m.getNumber(_loc4_++);
			saveScore(m,_loc4_);
			for each(var _loc2_ in g.playerManager.players)
			{
				if(_loc2_.ship != null)
				{
					_loc2_.ship.hp = _loc2_.ship.hpMax;
					_loc2_.ship.shieldHp = _loc2_.ship.shieldHpMax;
				}
			}
			if(scoreList.length > 0)
			{
				if(scoreList[0].playerKey == g.me.id)
				{
					g.textManager.createPvpText("The Match has Ended!",-50);
					g.textManager.createPvpText("You won with " + scoreList[0].score + " points!");
					if(g.solarSystem.type == "pvp arena")
					{
						Game.trackEvent("pvp","pvp arena won",g.me.name,scoreList[0].score);
					}
					else if(g.solarSystem.type == "pvp dm")
					{
						Game.trackEvent("pvp","pvp dm won",g.me.name,g.me.level);
					}
					else if(g.solarSystem.type == "pvp dom")
					{
						Game.trackEvent("pvp","pvp dom won",g.me.name,g.me.level);
					}
					if(scoreList[0].deaths == 0)
					{
						g.textManager.createPvpText("Flawless victory!",-110,50);
					}
				}
				else
				{
					g.textManager.createPvpText("The Match has Ended!",-50);
					g.textManager.createPvpText(scoreList[0].playerName + " won with " + scoreList[0].score + " points!");
				}
			}
			var _loc3_:PvpScoreHolder = getScoreHolder(g.me.id,g.me.name);
			if(_loc3_ == null)
			{
				return;
			}
			if(_loc3_.deaths == 0)
			{
				_loc5_ = _loc3_.kills * 2;
			}
			else
			{
				_loc5_ = _loc3_.kills / _loc3_.deaths;
			}
			Game.trackEvent("pvp","match stats",g.me.level.toString(),_loc5_);
		}
		
		protected function m_updateScore(m:Message) : void
		{
			saveScore(m,0);
		}
		
		protected function saveScore(m:Message, startIndex:int) : void
		{
			var _loc6_:* = 0;
			var _loc8_:String = null;
			var _loc5_:String = null;
			var _loc7_:int = 0;
			var _loc4_:PvpScoreHolder = null;
			var _loc3_:Player = null;
			_loc6_ = startIndex;
			while(_loc6_ < m.length)
			{
				_loc8_ = m.getString(_loc6_++);
				_loc5_ = m.getString(_loc6_++);
				_loc7_ = m.getInt(_loc6_++);
				_loc4_ = getScoreHolder(_loc8_,_loc5_);
				if(_loc4_ == null)
				{
					return;
				}
				if(g.playerManager && g.playerManager.playersById)
				{
					_loc3_ = g.playerManager.playersById[_loc8_];
					if(_loc3_ != null)
					{
						_loc3_.team = _loc7_;
					}
				}
				_loc4_.team = _loc7_;
				_loc4_.rank = m.getInt(_loc6_++);
				_loc4_.score = m.getInt(_loc6_++);
				_loc4_.kills = m.getInt(_loc6_++);
				_loc4_.deaths = m.getInt(_loc6_++);
				_loc4_.xpSum = m.getInt(_loc6_++);
				_loc4_.steelSum = m.getInt(_loc6_++);
				_loc4_.hydrogenSum = m.getInt(_loc6_++);
				_loc4_.plasmaSum = m.getInt(_loc6_++);
				_loc4_.iridiumSum = m.getInt(_loc6_++);
				_loc4_.damageSum = m.getInt(_loc6_++);
				_loc4_.healingSum = m.getInt(_loc6_++);
				_loc4_.bonusPercent = m.getInt(_loc6_++);
				_loc4_.first = m.getInt(_loc6_++);
				_loc4_.second = m.getInt(_loc6_++);
				_loc4_.third = m.getInt(_loc6_++);
				_loc4_.hotStreak3 = m.getInt(_loc6_++);
				_loc4_.hotStreak10 = m.getInt(_loc6_++);
				_loc4_.noDeaths = m.getInt(_loc6_++);
				_loc4_.capZone = m.getInt(_loc6_++);
				_loc4_.defZone = m.getInt(_loc6_++);
				_loc4_.brokeKillingSpree = m.getInt(_loc6_++);
				_loc4_.pickups = m.getInt(_loc6_++);
				_loc4_.rating = m.getNumber(_loc6_++);
				_loc4_.ratingChange = m.getNumber(_loc6_++);
				_loc4_.dailyBonus = m.getInt(_loc6_++);
				_loc4_.afk = m.getBoolean(_loc6_);
				_loc6_++;
			}
			scoreList.sort(compareFunction);
			_loc6_ = 0;
			while(_loc6_ < scoreList.length)
			{
				scoreList[_loc6_].rank = _loc6_ + 1;
				_loc6_++;
			}
			scoreListUpdated = true;
		}
		
		public function addDamage(key:String, dmg:int) : void
		{
			var _loc3_:PvpScoreHolder = getScoreItem(key);
			if(_loc3_ != null)
			{
				_loc3_.addDamage(dmg);
			}
			scoreListUpdated = true;
		}
		
		public function addHealing(key:String, heal:int) : void
		{
			var _loc3_:PvpScoreHolder = getScoreItem(key);
			if(_loc3_ != null)
			{
				_loc3_.addHealing(heal);
			}
			scoreListUpdated = true;
		}
		
		public function getScoreItem(key:String) : PvpScoreHolder
		{
			for each(var _loc2_ in scoreList)
			{
				if(_loc2_.playerKey == key)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getScoreList() : Vector.<PvpScoreHolder>
		{
			return scoreList;
		}
		
		public function getScoreHolder(key:String, name:String) : PvpScoreHolder
		{
			for each(var _loc3_ in scoreList)
			{
				if(_loc3_.playerKey == key)
				{
					return _loc3_;
				}
			}
			if(g.me == null)
			{
				return null;
			}
			_loc3_ = new PvpScoreHolder(key,name,key == g.me.id,type);
			scoreList.push(_loc3_);
			return _loc3_;
		}
		
		private function m_pvpInitPlayers(m:Message) : void
		{
			var _loc8_:String = null;
			var _loc4_:String = null;
			var _loc7_:int = 0;
			var _loc2_:Player = null;
			var _loc3_:PvpScoreHolder = null;
			var _loc5_:int = 0;
			type = m.getString(_loc5_++);
			scoreLimit = m.getInt(_loc5_++);
			var _loc6_:int = m.getInt(_loc5_++);
			if(_loc6_ > 0)
			{
				matchState = _loc6_;
			}
			roomStartTime = m.getNumber(_loc5_++);
			matchStartTime = m.getNumber(_loc5_++);
			matchEndTime = m.getNumber(_loc5_++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = m.getNumber(_loc5_++);
			_loc5_;
			while(_loc5_ < m.length)
			{
				_loc8_ = m.getString(_loc5_++);
				_loc4_ = m.getString(_loc5_++);
				_loc7_ = m.getInt(_loc5_);
				_loc2_ = g.playerManager.playersById[_loc8_];
				if(_loc2_ != null)
				{
					_loc2_.team = _loc7_;
				}
				_loc3_ = getScoreHolder(_loc8_,_loc4_);
				_loc3_.team = _loc7_;
				_loc5_++;
			}
			scoreList.sort(compareFunction);
		}
		
		private function m_startQuad(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:Number = m.getNumber(1);
			var _loc4_:Player = g.playerManager.playersById[_loc3_];
			if(_loc4_ == null || _loc4_.ship == null)
			{
				return;
			}
			_loc4_.ship.useQuad(_loc2_);
		}
		
		private function m_setHostile(m:Message) : void
		{
			var _loc3_:String = null;
			var _loc4_:Player = null;
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < m.length - 1)
			{
				_loc3_ = m.getString(_loc2_);
				_loc4_ = g.playerManager.playersById[_loc3_];
				if(_loc4_ != null)
				{
					_loc4_.isHostile = m.getBoolean(_loc2_ + 1);
				}
				_loc2_ += 2;
			}
		}
		
		public function resize(e:Event = null) : void
		{
			if(timerText != null)
			{
				timerText.y = 25;
				timerText.x = 0.5 * g.stage.stageWidth - 214;
			}
			if(scoreText != null)
			{
				scoreText.x = 0.5 * g.stage.stageWidth + 40;
				scoreText.y = timerText.y;
			}
			if(leaderText != null)
			{
				leaderText.x = 0.5 * g.stage.stageWidth + 52;
				leaderText.y = scoreText.y;
			}
			if(map != null)
			{
				map.x = 0;
				map.y = g.stage.stageHeight - 170;
			}
		}
	}
}

