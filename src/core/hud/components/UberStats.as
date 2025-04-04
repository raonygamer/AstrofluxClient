package core.hud.components
{
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class UberStats extends Sprite
	{
		private var g:Game;
		public var uberMaxLevel:Number = 100;
		public var uberMinLevel:Number = 1;
		public var uberDifficultyAtTopRank:Number = 2000;
		public var uberTopRank:Number = 10;
		public var uberLevel:Number = 0;
		public var uberLives:Number = 3;
		public var uberRank:Number = 0;
		private var oldScore:Number = 0;
		private var oldXpLeft:int = 0;
		private var oldBossesLeft:int = 0;
		private var oldMiniBossesLeft:int = 0;
		private var oldSpawnerLeft:int = 0;
		private var oldUberRank:int = 0;
		private var optionalRank:int = 3;
		private var scoreTime:Number = 0;
		private var lives:Dictionary = new Dictionary();
		private var rankText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var challengeText:TextBitmap = new TextBitmap();
		private var missionText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var optionalMissionText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var xpText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var optionalText:TextBitmap = new TextBitmap();
		private var scoreText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var highscoreText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		private var lifes:TextBitmap = new TextBitmap();
		private var oldCompleted:Boolean = false;
		private var oldOptionalCompleted:Boolean = false;
		
		public function UberStats(g:Game)
		{
			super();
			this.g = g;
			addChild(rankText);
			addChild(challengeText);
			addChild(xpText);
			addChild(missionText);
			addChild(optionalText);
			addChild(optionalMissionText);
			addChild(scoreText);
			addChild(highscoreText);
			addChild(lifes);
		}
		
		public function update(m:Message) : void
		{
			var _loc14_:int = 0;
			var _loc13_:* = 0;
			var _loc27_:Object = null;
			var _loc18_:TextBitmap = null;
			var _loc23_:int = 0;
			uberRank = m.getNumber(_loc23_++);
			uberLevel = m.getNumber(_loc23_++);
			var _loc22_:int = m.getInt(_loc23_++);
			var _loc7_:Number = m.getNumber(_loc23_++);
			var _loc20_:Number = m.getNumber(_loc23_++);
			var _loc3_:int = m.getInt(_loc23_++);
			var _loc24_:int = m.getInt(_loc23_++);
			var _loc8_:int = m.getInt(_loc23_++);
			var _loc9_:int = m.getInt(_loc23_++);
			var _loc15_:int = m.getInt(_loc23_++);
			var _loc26_:int = m.getInt(_loc23_++);
			var _loc6_:int = m.getInt(_loc23_++);
			var _loc4_:String = m.getString(_loc23_++);
			var _loc10_:String = m.getString(_loc23_++);
			var _loc16_:Boolean = m.getBoolean(_loc23_++);
			var _loc25_:Boolean = m.getBoolean(_loc23_++);
			var _loc2_:int = m.getInt(_loc23_++);
			var _loc21_:Array = [];
			if(uberRank == oldUberRank + 1)
			{
				g.textManager.createUberRankCompleteText("START RANK " + uberRank + "");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_loc16_ && !oldCompleted)
			{
				g.textManager.createUberRankCompleteText("RANK " + uberRank + " COMPLETE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_loc25_ && !oldOptionalCompleted && uberRank >= optionalRank)
			{
				g.textManager.createUberExtraLifeText("EXTRA LIFE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(oldScore < _loc20_ && _loc7_ > _loc20_)
			{
				g.textManager.createUberExtraLifeText("NEW HIGHSCORE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			var _loc5_:int = _loc3_ - _loc22_;
			var _loc17_:int = _loc8_ - _loc24_;
			var _loc12_:int = _loc15_ - _loc9_;
			var _loc11_:int = _loc6_ - _loc26_;
			if(_loc17_ < oldBossesLeft && (_loc10_ == "boss" && uberRank >= optionalRank || _loc4_ == "boss"))
			{
				g.textManager.createUberTaskText(_loc24_ + " of " + _loc8_ + " bosses destroyed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_loc12_ < oldMiniBossesLeft && (_loc10_ == "miniboss" && uberRank >= optionalRank || _loc4_ == "miniboss"))
			{
				g.textManager.createUberTaskText(_loc9_ + " of " + _loc15_ + " mini bosses killed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_loc11_ < oldSpawnerLeft && (_loc10_ == "spawner" && uberRank >= optionalRank || _loc4_ == "spawner"))
			{
				g.textManager.createUberTaskText(_loc26_ + " of " + _loc6_ + " spawners smashed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(g.time > scoreTime && _loc7_ > oldScore)
			{
				g.textManager.createScoreText(_loc7_ - oldScore);
			}
			var _loc19_:String = "<FONT COLOR=\'#88FF88\'>complete</FONT>";
			missionText.format.size = 14;
			missionText.format.color = Style.COLOR_HIGHLIGHT;
			missionText.format.horizontalAlign = "right";
			missionText.alignPivot("right");
			missionText.isHtmlText = true;
			if(_loc4_ == "boss")
			{
				missionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_loc17_ == 0 ? _loc19_ : _loc24_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc8_) + "</FONT></FONT>";
			}
			else if(_loc4_ == "miniboss")
			{
				missionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_loc12_ == 0 ? _loc19_ : _loc9_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc15_) + "</FONT></FONT>";
			}
			else if(_loc4_ == "spawner")
			{
				missionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_loc11_ == 0 ? _loc19_ : _loc26_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc6_) + "</FONT></FONT>";
			}
			else
			{
				missionText.text = "";
			}
			rankText.format.color = Style.COLOR_HIGHLIGHT;
			rankText.isHtmlText = true;
			rankText.format.horizontalAlign = "right";
			rankText.alignPivot("right");
			rankText.text = "Rank <FONT COLOR=\'#FFFFFF\'>" + Math.floor(uberRank) + "</FONT>, Level > <FONT COLOR=\'#FFFFFF\'>" + Math.floor(uberLevel) + "</FONT>";
			challengeText.format.color = 0xaaaaaa;
			challengeText.y = rankText.y + rankText.height + 25;
			challengeText.alignRight();
			xpText.format.color = Style.COLOR_HIGHLIGHT;
			xpText.format.size = 14;
			xpText.isHtmlText = true;
			xpText.format.horizontalAlign = "right";
			xpText.alignPivot("right");
			xpText.text = "Troons: <FONT COLOR=\'#FFFFFF\'>" + (_loc5_ == 0 ? _loc19_ : Math.floor(_loc22_ / 10) + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + Math.floor(_loc3_ / 10)) + "</FONT></FONT>";
			xpText.y = challengeText.y + challengeText.height + 5;
			missionText.y = xpText.y + xpText.height + 5;
			optionalText.text = "(extra life)";
			optionalText.format.color = 0xaaaaaa;
			optionalText.y = missionText.y + missionText.height + 10;
			optionalText.alignRight();
			optionalMissionText.format.color = Style.COLOR_HIGHLIGHT;
			optionalMissionText.isHtmlText = true;
			optionalMissionText.format.horizontalAlign = "right";
			optionalMissionText.alignPivot("right");
			optionalMissionText.y = optionalText.y + optionalText.height + 5;
			if(_loc10_ == "boss")
			{
				optionalMissionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_loc17_ == 0 ? _loc19_ : _loc24_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc8_) + "</FONT></FONT>";
			}
			else if(_loc10_ == "miniboss")
			{
				optionalMissionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_loc12_ == 0 ? _loc19_ : _loc9_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc15_) + "</FONT></FONT>";
			}
			else if(_loc10_ == "spawner")
			{
				optionalMissionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_loc11_ == 0 ? _loc19_ : _loc26_ + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _loc6_) + "</FONT></FONT>";
			}
			if(uberRank >= optionalRank)
			{
				optionalText.visible = true;
				optionalMissionText.visible = true;
			}
			else
			{
				optionalText.visible = false;
				optionalMissionText.visible = false;
			}
			scoreText.format.color = Style.COLOR_HIGHLIGHT;
			scoreText.format.size = 16;
			scoreText.isHtmlText = true;
			scoreText.format.horizontalAlign = "right";
			scoreText.alignPivot("right");
			scoreText.text = "Total Troons: <FONT COLOR=\'#FF44aa\'>" + Math.floor(_loc7_) + "</FONT>";
			scoreText.y = optionalMissionText.y + optionalMissionText.height + 25;
			highscoreText.format.color = Style.COLOR_HIGHLIGHT;
			highscoreText.isHtmlText = true;
			highscoreText.format.horizontalAlign = "right";
			highscoreText.alignPivot("right");
			highscoreText.text = "Highscore: <FONT COLOR=\'#FFFFFF\'>" + Math.floor(_loc20_) + "</FONT>";
			highscoreText.y = scoreText.y + scoreText.height + 5;
			lifes.text = "Lives";
			lifes.format.color = 0xaaaaaa;
			lifes.y = highscoreText.y + highscoreText.height + 25;
			lifes.alignRight();
			_loc14_ = 0;
			_loc13_ = _loc23_;
			while(_loc13_ < _loc23_ + 3 * _loc2_)
			{
				_loc27_ = {};
				_loc27_.key = m.getString(_loc13_);
				_loc27_.name = m.getString(_loc13_ + 1);
				_loc27_.lives = m.getInt(_loc13_ + 2);
				lives[_loc27_.key] = _loc27_.lives;
				_loc21_.push(_loc27_);
				_loc18_ = TextBitmap(getChildByName(_loc27_.key));
				if(_loc18_ == null)
				{
					_loc18_ = new TextBitmap();
					addChild(_loc18_);
				}
				_loc18_.name = _loc27_.key;
				_loc18_.text = _loc27_.name + ": " + _loc27_.lives;
				_loc18_.y = lifes.y + lifes.height + 2 + _loc14_ * (lifes.height + 2);
				_loc18_.alignRight();
				_loc14_++;
				_loc13_ += 3;
			}
			oldXpLeft = _loc5_;
			oldBossesLeft = _loc17_;
			oldMiniBossesLeft = _loc12_;
			oldSpawnerLeft = _loc11_;
			oldCompleted = _loc16_;
			oldOptionalCompleted = _loc25_;
			oldUberRank = uberRank;
			if(g.time > scoreTime)
			{
				scoreTime = g.time + 1000;
				oldScore = _loc7_;
			}
		}
		
		public function CalculateUberRankFromLevel(level:Number) : Number
		{
			var _loc2_:int = uberMaxLevel - uberMinLevel;
			if(level <= uberMinLevel + _loc2_ * 0.9)
			{
				return (level - uberMinLevel) * uberTopRank / (_loc2_ * 0.9);
			}
			return (level - uberMinLevel - _loc2_ * 0.9) * uberTopRank / (_loc2_ * 0.1) + uberTopRank;
		}
		
		public function CalculateUberLevelFromRank(rank:Number) : Number
		{
			var _loc2_:Number = NaN;
			var _loc3_:int = uberMaxLevel - uberMinLevel;
			if(rank <= uberTopRank)
			{
				return uberMinLevel + _loc3_ * 0.9 * (rank / uberTopRank);
			}
			_loc2_ = uberMinLevel + _loc3_ * 0.9 + _loc3_ * 0.1 * ((rank - uberTopRank) / uberTopRank);
			return _loc2_ > uberMaxLevel ? uberMaxLevel : _loc2_;
		}
		
		public function CalculateUberDifficultyFromRank(rank:Number, originalLevel:Number) : Number
		{
			var _loc3_:Number = 1 / Math.pow(originalLevel,1.2);
			if(rank <= uberTopRank)
			{
				return 1 + uberDifficultyAtTopRank * (rank / uberTopRank) * _loc3_;
			}
			return 1 + uberDifficultyAtTopRank * _loc3_ * Math.pow(1.2,rank - uberTopRank);
		}
		
		public function getMyLives() : int
		{
			return lives[g.me.id];
		}
	}
}

