package core.hud.components {
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class UberStats extends Sprite {
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
		
		public function UberStats(g:Game) {
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
		
		public function update(m:Message) : void {
			var _local22:int = 0;
			var _local24:* = 0;
			var _local9:Object = null;
			var _local3:TextBitmap = null;
			var _local27:int = 0;
			uberRank = m.getNumber(_local27++);
			uberLevel = m.getNumber(_local27++);
			var _local6:int = m.getInt(_local27++);
			var _local5:Number = m.getNumber(_local27++);
			var _local17:Number = m.getNumber(_local27++);
			var _local12:int = m.getInt(_local27++);
			var _local26:int = m.getInt(_local27++);
			var _local15:int = m.getInt(_local27++);
			var _local4:int = m.getInt(_local27++);
			var _local20:int = m.getInt(_local27++);
			var _local10:int = m.getInt(_local27++);
			var _local2:int = m.getInt(_local27++);
			var _local11:String = m.getString(_local27++);
			var _local25:String = m.getString(_local27++);
			var _local16:Boolean = m.getBoolean(_local27++);
			var _local7:Boolean = m.getBoolean(_local27++);
			var _local21:int = m.getInt(_local27++);
			var _local18:Array = [];
			if(uberRank == oldUberRank + 1) {
				g.textManager.createUberRankCompleteText("START RANK " + uberRank + "");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_local16 && !oldCompleted) {
				g.textManager.createUberRankCompleteText("RANK " + uberRank + " COMPLETE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_local7 && !oldOptionalCompleted && uberRank >= optionalRank) {
				g.textManager.createUberExtraLifeText("EXTRA LIFE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(oldScore < _local17 && _local5 > _local17) {
				g.textManager.createUberExtraLifeText("NEW HIGHSCORE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			var _local13:int = _local12 - _local6;
			var _local19:int = _local15 - _local26;
			var _local14:int = _local20 - _local4;
			var _local8:int = _local2 - _local10;
			if(_local19 < oldBossesLeft && (_local25 == "boss" && uberRank >= optionalRank || _local11 == "boss")) {
				g.textManager.createUberTaskText(_local26 + " of " + _local15 + " bosses destroyed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_local14 < oldMiniBossesLeft && (_local25 == "miniboss" && uberRank >= optionalRank || _local11 == "miniboss")) {
				g.textManager.createUberTaskText(_local4 + " of " + _local20 + " mini bosses killed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_local8 < oldSpawnerLeft && (_local25 == "spawner" && uberRank >= optionalRank || _local11 == "spawner")) {
				g.textManager.createUberTaskText(_local10 + " of " + _local2 + " spawners smashed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(g.time > scoreTime && _local5 > oldScore) {
				g.textManager.createScoreText(_local5 - oldScore);
			}
			var _local23:String = "<FONT COLOR=\'#88FF88\'>complete</FONT>";
			missionText.format.size = 14;
			missionText.format.color = Style.COLOR_HIGHLIGHT;
			missionText.format.horizontalAlign = "right";
			missionText.alignPivot("right");
			missionText.isHtmlText = true;
			if(_local11 == "boss") {
				missionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local19 == 0 ? _local23 : _local26 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local15) + "</FONT></FONT>";
			} else if(_local11 == "miniboss") {
				missionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local14 == 0 ? _local23 : _local4 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local20) + "</FONT></FONT>";
			} else if(_local11 == "spawner") {
				missionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_local8 == 0 ? _local23 : _local10 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local2) + "</FONT></FONT>";
			} else {
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
			xpText.text = "Troons: <FONT COLOR=\'#FFFFFF\'>" + (_local13 == 0 ? _local23 : Math.floor(_local6 / 10) + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + Math.floor(_local12 / 10)) + "</FONT></FONT>";
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
			if(_local25 == "boss") {
				optionalMissionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local19 == 0 ? _local23 : _local26 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local15) + "</FONT></FONT>";
			} else if(_local25 == "miniboss") {
				optionalMissionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local14 == 0 ? _local23 : _local4 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local20) + "</FONT></FONT>";
			} else if(_local25 == "spawner") {
				optionalMissionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_local8 == 0 ? _local23 : _local10 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local2) + "</FONT></FONT>";
			}
			if(uberRank >= optionalRank) {
				optionalText.visible = true;
				optionalMissionText.visible = true;
			} else {
				optionalText.visible = false;
				optionalMissionText.visible = false;
			}
			scoreText.format.color = Style.COLOR_HIGHLIGHT;
			scoreText.format.size = 16;
			scoreText.isHtmlText = true;
			scoreText.format.horizontalAlign = "right";
			scoreText.alignPivot("right");
			scoreText.text = "Total Troons: <FONT COLOR=\'#FF44aa\'>" + Math.floor(_local5) + "</FONT>";
			scoreText.y = optionalMissionText.y + optionalMissionText.height + 25;
			highscoreText.format.color = Style.COLOR_HIGHLIGHT;
			highscoreText.isHtmlText = true;
			highscoreText.format.horizontalAlign = "right";
			highscoreText.alignPivot("right");
			highscoreText.text = "Highscore: <FONT COLOR=\'#FFFFFF\'>" + Math.floor(_local17) + "</FONT>";
			highscoreText.y = scoreText.y + scoreText.height + 5;
			lifes.text = "Lives";
			lifes.format.color = 0xaaaaaa;
			lifes.y = highscoreText.y + highscoreText.height + 25;
			lifes.alignRight();
			_local22 = 0;
			_local24 = _local27;
			while(_local24 < _local27 + 3 * _local21) {
				_local9 = {};
				_local9.key = m.getString(_local24);
				_local9.name = m.getString(_local24 + 1);
				_local9.lives = m.getInt(_local24 + 2);
				lives[_local9.key] = _local9.lives;
				_local18.push(_local9);
				_local3 = TextBitmap(getChildByName(_local9.key));
				if(_local3 == null) {
					_local3 = new TextBitmap();
					addChild(_local3);
				}
				_local3.name = _local9.key;
				_local3.text = _local9.name + ": " + _local9.lives;
				_local3.y = lifes.y + lifes.height + 2 + _local22 * (lifes.height + 2);
				_local3.alignRight();
				_local22++;
				_local24 += 3;
			}
			oldXpLeft = _local13;
			oldBossesLeft = _local19;
			oldMiniBossesLeft = _local14;
			oldSpawnerLeft = _local8;
			oldCompleted = _local16;
			oldOptionalCompleted = _local7;
			oldUberRank = uberRank;
			if(g.time > scoreTime) {
				scoreTime = g.time + 1000;
				oldScore = _local5;
			}
		}
		
		public function CalculateUberRankFromLevel(level:Number) : Number {
			var _local2:int = uberMaxLevel - uberMinLevel;
			if(level <= uberMinLevel + _local2 * 0.9) {
				return (level - uberMinLevel) * uberTopRank / (_local2 * 0.9);
			}
			return (level - uberMinLevel - _local2 * 0.9) * uberTopRank / (_local2 * 0.1) + uberTopRank;
		}
		
		public function CalculateUberLevelFromRank(rank:Number) : Number {
			var _local2:Number = NaN;
			var _local3:int = uberMaxLevel - uberMinLevel;
			if(rank <= uberTopRank) {
				return uberMinLevel + _local3 * 0.9 * (rank / uberTopRank);
			}
			_local2 = uberMinLevel + _local3 * 0.9 + _local3 * 0.1 * ((rank - uberTopRank) / uberTopRank);
			return _local2 > uberMaxLevel ? uberMaxLevel : _local2;
		}
		
		public function CalculateUberDifficultyFromRank(rank:Number, originalLevel:Number) : Number {
			var _local3:Number = 1 / Math.pow(originalLevel,1.2);
			if(rank <= uberTopRank) {
				return 1 + uberDifficultyAtTopRank * (rank / uberTopRank) * _local3;
			}
			return 1 + uberDifficultyAtTopRank * _local3 * Math.pow(1.2,rank - uberTopRank);
		}
		
		public function getMyLives() : int {
			return lives[g.me.id];
		}
	}
}

