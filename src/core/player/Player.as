package core.player {
	import com.greensock.TweenMax;
	import core.artifact.Artifact;
	import core.artifact.ArtifactFactory;
	import core.artifact.ArtifactStat;
	import core.friend.Friend;
	import core.group.Group;
	import core.hud.components.chat.MessageLog;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import core.ship.ShipFactory;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.states.gameStates.RoamingState;
	import core.states.player.Killed;
	import core.states.player.Landed;
	import core.states.player.Roaming;
	import core.text.TextParticle;
	import core.weapon.Beam;
	import core.weapon.Cloak;
	import core.weapon.Damage;
	import core.weapon.Teleport;
	import core.weapon.Weapon;
	import core.weapon.WeaponDataHolder;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import movement.Heading;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class Player {
		public static const SLOT_WEAPON_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		public static const SLOT_ARTIFACT_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		public static const SLOT_CREW_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		public static const SLOT_WEAPON:String = "slotWeapon";
		public static const SLOT_ARTIFACT:String = "slotArtifact";
		public static const SLOT_CREW:String = "slotCrew";
		public static const RESPAWN_TIME:Number = 10000;
		public static const RESPAWN_TIME_PVP:Number = 3000;
		public static const SUPPORTER_ICON_ASCII:String = "<font color=\'#ffff66\'>&#9733;</font>";
		
		public static const EXPBOOSTBONUS_MISSION:Number = 0.3;
		public static var friends:Vector.<Friend>;
		public static var onlineFriends:Vector.<Friend>;
		public static const SLOT_WEAPON_UNLOCK_COST:Array = [0,0,200,1000,5000];
		public static const SLOT_ARTIFACT_UNLOCK_COST:Array = [0,1000,2000,10000,25000];
		public static const SLOT_CREW_UNLOCK_COST:Array = [0,0,250,5000,25000];
		public static const ARTIFACT_CAPACITY:Array = [250,400,10 * 60,800];
		private var _name:String;
		public var isMe:Boolean = false;
		public var id:String;
		public var inviter_id:String = "";
		public var ship:PlayerShip;
		public var mirror:PlayerShip;
		public var stateMachine:StateMachine = new StateMachine();
		public var currentBody:Body;
		public var lastBody:Body;
		public var xp:int = 0;
		public var reputation:int = 0;
		public var split:String = "";
		private var _team:int = -1;
		public var respawnNextReady:Number = 0;
		public var spree:int = 0;
		public var techPoints:int = 0;
		public var clanId:String = "";
		public var clanApplicationId:String = "";
		public var troons:int = 0;
		public var rating:int = 0;
		public var ranking:int = 0;
		private var activeWeapon:String;
		public var techSkills:Vector.<TechSkill> = new Vector.<TechSkill>();
		public var weapons:Array = [];
		public var weaponsState:Array = [];
		public var weaponsHotkeys:Array = [];
		public var weaponData:Vector.<WeaponDataHolder>;
		public var selectedWeaponIndex:int = 0;
		public var unlockedWeaponSlots:int;
		public var artifactCount:int = 0;
		public var compressorLevel:int = 0;
		public var artifactCapacityLevel:int = 0;
		public var artifactAutoRecycleLevel:int = 0;
		public var activeSkin:String = "";
		public var unlockedArtifactSlots:int;
		public var artifacts:Vector.<Artifact> = new Vector.<Artifact>();
		public var activeArtifactSetup:int;
		public var artifactSetups:Array = [];
		public var unlockedCrewSlots:int;
		public var rotationSpeedMod:Number = 1;
		public var KOTSIsReady:Boolean = false;
		public var fleet:Vector.<FleetObj> = new Vector.<FleetObj>();
		public var nrOfUpgrades:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0]);
		private var _level:int = 1;
		private var _inSafeZone:Boolean = false;
		private var _isWarpJumping:Boolean = false;
		public var playerKills:int = 0;
		public var enemyKills:int = 0;
		public var playerDeaths:int = 0;
		public var expBoost:Number = 0;
		public var tractorBeam:Number = 0;
		private var tractorBeamActive:Boolean = true;
		public var xpProtection:Number = 0;
		public var cargoProtection:Number = 0;
		private var cargoProtectionActive:Boolean = true;
		public var supporter:Number = 0;
		public var beginnerPackage:Boolean = false;
		public var powerPackage:Boolean = false;
		public var megaPackage:Boolean = false;
		public var explores:Vector.<Explore> = new Vector.<Explore>();
		public var missions:Vector.<Mission> = new Vector.<Mission>();
		public var dailyMissions:Array = [];
		public var crewMembers:Vector.<CrewMember> = new Vector.<CrewMember>();
		public var encounters:Vector.<String> = new Vector.<String>();
		public var triggeredMissions:Vector.<String> = new Vector.<String>();
		public var completedMissions:Object = {};
		public var warpPathLicenses:Array;
		public var solarSystemLicenses:Array;
		public var guest:Boolean = false;
		public var fbLike:Boolean = false;
		public var showIntro:Boolean = true;
		public var kongRated:Boolean = false;
		public var isDeveloper:Boolean = false;
		public var isTester:Boolean = false;
		public var isModerator:Boolean = false;
		public var isTranslator:Boolean = false;
		private var _group:Group = null;
		private var _isHostile:Boolean = false;
		public var pickUpLog:Vector.<TextParticle> = new Vector.<TextParticle>();
		public var disableLeave:Boolean;
		private var isTakingOff:Boolean = false;
		public var clanLogo:Image;
		public var clanName:String;
		public var clanRankName:String;
		public var clanLogoColor:uint;
		public var freeResets:int;
		public var freePaintJobs:int;
		public var factions:Vector.<String> = new Vector.<String>();
		public var landedBodies:Vector.<LandedBody> = new Vector.<LandedBody>();
		public var tosVersion:int;
		private var g:Game;
		private var updateInterval:int;
		public var isLanded:Boolean = false;
		
		public function Player(g:Game, id:String) {
			super();
			this.g = g;
			this.id = id;
			disableLeave = false;
		}
		
		public static function getSkinTechLevel(tech:String, skinKey:String) : int {
			var _local5:IDataManager = DataLocator.getService();
			var _local4:Object = _local5.loadKey("Skins",skinKey);
			for each(var _local3:* in _local4.upgrades) {
				if(_local3.tech == tech) {
					return _local3.level;
				}
			}
			return 0;
		}
		
		public function get artifactLimit() : int {
			return ARTIFACT_CAPACITY[artifactCapacityLevel];
		}
		
		public function get activeArtifacts() : Array {
			return artifactSetups[activeArtifactSetup] as Array;
		}
		
		public function get group() : Group {
			return _group;
		}
		
		public function set group(value:Group) : void {
			_group = value;
			if(ship != null) {
				ship.group = value;
			}
		}
		
		public function get isHostile() : Boolean {
			return _isHostile;
		}
		
		public function get hasCorrectTOSVersion() : Boolean {
			if(Login.currentState === "steam") {
				return true;
			}
			return tosVersion == 3;
		}
		
		public function set hasCorrectTOSVersion(value:Boolean) : void {
			if(value) {
				tosVersion = 3;
			} else {
				tosVersion = -1;
			}
		}
		
		public function set isHostile(value:Boolean) : void {
			_isHostile = value;
			if(ship != null) {
				ship.isHostile = value;
			}
		}
		
		public function init(m:Message, i:int) : int {
			var _local12:Heading = null;
			var _local11:int = 0;
			_name = m.getString(i++);
			inviter_id = m.getString(i++);
			tosVersion = m.getInt(i++);
			isDeveloper = m.getBoolean(i++);
			isTester = m.getBoolean(i++);
			isModerator = m.getBoolean(i++);
			isTranslator = m.getBoolean(i++);
			level = m.getInt(i++);
			xp = m.getInt(i++);
			techPoints = m.getInt(i++);
			isHostile = m.getBoolean(i++);
			rotationSpeedMod = m.getNumber(i++);
			reputation = m.getInt(i++);
			var _local13:String = m.getString(i++);
			split = m.getString(i++);
			var _local4:String = m.getString(i++);
			spree = m.getInt(i++);
			var _local3:int = m.getInt(i++);
			var _local5:int = 0;
			var _local14:int = 0;
			var _local9:int = 0;
			var _local8:int = 0;
			var _local7:Number = 0;
			var _local10:Number = 0;
			if(_local3 != -1) {
				_local14 = m.getInt(i++);
				_local5 = m.getInt(i++);
				_local9 = m.getInt(i++);
				_local8 = m.getInt(i++);
				_local7 = m.getNumber(i++);
				_local10 = m.getNumber(i++);
				_local12 = new Heading();
				i = _local12.parseMessage(m,i);
			}
			unlockedWeaponSlots = m.getInt(i++);
			unlockedArtifactSlots = m.getInt(i++);
			unlockedCrewSlots = m.getInt(i++);
			compressorLevel = m.getInt(i++);
			artifactCapacityLevel = m.getInt(i++);
			artifactAutoRecycleLevel = m.getInt(i++);
			playerKills = m.getInt(i++);
			playerDeaths = m.getInt(i++);
			enemyKills = m.getInt(i++);
			showIntro = m.getBoolean(i++);
			expBoost = m.getNumber(i++);
			tractorBeam = m.getNumber(i++);
			xpProtection = m.getNumber(i++);
			cargoProtection = m.getNumber(i++);
			supporter = m.getNumber(i++);
			beginnerPackage = m.getBoolean(i++);
			powerPackage = m.getBoolean(i++);
			megaPackage = m.getBoolean(i++);
			guest = m.getBoolean(i++);
			clanId = m.getString(i++);
			clanApplicationId = m.getString(i++);
			troons = m.getNumber(i++);
			freeResets = m.getInt(i++);
			freePaintJobs = m.getInt(i++);
			artifactCount = m.getInt(i++);
			var _local15:int = m.getInt(i++);
			_local11 = 0;
			while(_local11 < _local15) {
				factions.push(m.getString(i++));
				_local11++;
			}
			i = initFleetFromMessage(m,i);
			if(isMe) {
				i = initEncountersFromMessage(m,i);
				i = initCompletedMissionsFromMessage(m,i);
				i = initFinishedExploresFromMessage(m,i);
				i = initExploresFromMessage(m,i);
				i = initMissionsFromMessage(m,i);
				i = g.dailyManager.initDailyMissionsFromMessage(m,i);
				i = initTriggeredMissionsFromMessage(m,i);
				i = initCrewFromMessage(m,i);
				i = initLandedBodiesFromMessage(m,i);
				i = initArtifactsFromMessage(m,i);
				i = SceneBase.settings.init(m,i);
				SceneBase.settings.setPlayerValues(g);
				g.parallaxManager.refresh();
				i = g.tutorial.init(m,i);
				i = initWarpPathLicensesFromMessage(m,i);
				i = initSolarSystemLicensesFromMessage(m,i);
				kongRated = m.getBoolean(i++);
				fbLike = m.getBoolean(i++);
				g.friendManager.init(this);
			}
			var _local6:Body = g.bodyManager.getBodyByKey(_local4);
			if(_local6 != null) {
				ship = ShipFactory.createPlayer(g,this,new PlayerShip(g),weapons);
				startLanded(_local6);
				isLanded = true;
			} else {
				loadShip(_local14,_local5,_local9,_local8);
				ship.id = _local3;
				loadCourse(_local12);
				enterRoaming();
				MessageLog.writeChatMsg("join_leave",_name + " has entered the system.");
			}
			if(!isMe && _local5 != 0) {
				ship.shieldHpMax = _local14;
				ship.hpMax = _local5;
				ship.armorThreshold = _local9;
				ship.shieldRegen = _local8;
				ship.level = level;
				ship.updateLabel();
				ship.engine.speed = _local7;
				ship.engine.acceleration = _local10;
			}
			if(supporter) {
				Game.trackEvent("logged in","supporter");
			} else {
				Game.trackEvent("logged in","not supporter");
			}
			g.groupManager.autoJoinOrCreateGroup(this,_local13);
			return i;
		}
		
		public function requestLikeReward() : void {
			if(Login.hasFacebookLiked && !fbLike) {
				g.send("fbLike");
			}
		}
		
		public function requestInviteReward() : void {
			g.send("requestInviteReward");
		}
		
		public function requestRewardsOnLogin() : void {
			g.rpc("requestRewardsOnLogin",requestResult);
		}
		
		public function sendKongRated() : void {
			kongRated = true;
			g.send("kongRated");
		}
		
		public function requestResult() : void {
		}
		
		public function getExploreByKey(key:String) : Explore {
			for each(var _local2:* in explores) {
				if(_local2.areaKey == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function loadShip(shieldHp:int, hp:int, armor:int, shieldRegen:int) : void {
			var _local5:int = 0;
			ship = null;
			ship = ShipFactory.createPlayer(g,this,g.shipManager.getPlayerShip(),weapons);
			_local5 = 0;
			while(_local5 < ship.weapons.length) {
				if(ship.weapons[_local5].key == activeWeapon) {
					selectedWeaponIndex = _local5;
					if(isMe) {
						g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_local5].hotkey);
					}
					break;
				}
				_local5++;
			}
			activateShip();
			if(hp != 0) {
				ship.shieldHp = shieldHp;
				ship.hp = hp;
				ship.armorThreshold = armor;
				ship.shieldRegen = shieldRegen;
				ship.level = level;
				ship.updateLabel();
			}
			if(spree > 4 && ship != null) {
				ship.startKillingSpreeEffect();
			}
		}
		
		private function activateShip() : void {
			g.shipManager.activatePlayerShip(ship);
			if(isMe) {
				autoSetHotkeysForWeapons();
				g.camera.focusTarget = ship.movieClip;
			}
			ship.player = this;
			ship.enterRoaming();
		}
		
		public function unloadShip() : void {
			if(ship == null) {
				return;
			}
			ship.destroy(false);
			if(mirror != null) {
				mirror.destroy(false);
				mirror = null;
			}
		}
		
		public function update() : void {
			if(isMe) {
				updateInterval++;
				if(updateInterval == 1) {
					g.hud.bossHealth.update();
				} else if(updateInterval == 2) {
					g.hud.powerBar.update();
					updateInterval = 0;
				}
			}
			stateMachine.update();
		}
		
		public function setSpree(newSpree:int) : void {
			if(spree != newSpree) {
				spree = newSpree;
				if(spree > 15) {
					MessageLog.writeChatMsg("death",_name + " is Godlike! With a " + spree + " frag long killing frenzy!");
				} else if(spree > 10) {
					MessageLog.writeChatMsg("death",_name + " is on a Rampage! " + spree + " frag long killing frenzy!");
				} else if(spree > 4) {
					MessageLog.writeChatMsg("death",_name + " is on a " + spree + " frag long killing frenzy!");
				}
				if(spree == 4 && ship != null) {
					ship.startKillingSpreeEffect();
				}
			}
		}
		
		public function getExploredAreas(body:Body, callback:Function) : void {
			if(body.obj.exploreAreas == null) {
				callback([]);
				return;
			}
			try {
				g.client.bigDB.loadRange("Explores","ByPlayerAndBodyAndArea",[id,body.key],null,null,100,function(param1:Array):void {
					callback(param1);
				});
			}
			catch(e:Error) {
				g.client.errorLog.writeError(e.toString(),"Something went wrong when loading explores: pid: " + id + " bid:" + body.key,e.getStackTrace(),{});
			}
		}
		
		public function levelUp() : void {
			var effect:Vector.<Emitter>;
			var effect2:Vector.<Emitter>;
			var soundManager:ISound;
			level += 1;
			if(ship == null) {
				return;
			}
			if(level >= 10 && Login.currentState == "facebook") {
				g.tutorial.showFacebookInviteHint();
			}
			setLevelBonusStats();
			if(g.camera.isCircleOnScreen(ship.x,ship.y,5 * 60)) {
				effect = EmitterFactory.create("wrycG8hPkEGYgMkWXyd6FQ",g,0,0,ship,false);
				effect2 = EmitterFactory.create("6SRymw3GLkqIn6YvIGoLrw",g,0,0,ship,false);
				if(isMe) {
					if(g.me.split != "") {
						Game.trackEvent("AB Splits","player flow",g.me.split + ": reached level " + level);
					}
					soundManager = SoundLocator.getService();
					soundManager.preCacheSound("5wAlzsUCPEKqX7tAdCw3UA",function():void {
						for each(var _local2:* in effect) {
							_local2.play();
						}
						for each(var _local1:* in effect2) {
							_local1.play();
						}
						g.textManager.createLevelUpText(level);
						g.textManager.createLevelUpDetailsText();
					});
					g.updateServiceRoom();
					Action.levelUp(level);
					if(inviter_id != "" && level == 10) {
						if(level == 10 || level == 2) {
							g.sendToServiceRoom("requestUpdateInviteReward",inviter_id);
						}
						if(level % 10 == 0) {
							if(Login.currentState == "facebook") {
								Game.trackEvent("FBinvite","invite feedback","reached level " + level,1);
							} else if(Login.currentState == "kongregate") {
								Game.trackEvent("KONGinvite","invite feedback","joined game",1);
							}
						}
					}
				} else {
					MessageLog.write("<FONT COLOR=\'#44ff44\'>" + name + " reached level " + level + ".</FONT>");
				}
			}
		}
		
		private function setLevelBonusStats() : void {
			var _local6:int = 0;
			var _local5:Number = NaN;
			var _local3:* = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			var _local1:int = 0;
			if(ship != null) {
				_local6 = level;
				_local5 = level;
				_local3 = _local3;
				_local4 = _local3 / 200000;
				_local5 += _local4;
				if(g.solarSystem.isPvpSystemInEditor) {
					_local5 = 100;
				}
				if(level == 2) {
					_local2 = 8;
				} else {
					_local2 = (100 + 8 * (_local5 - 1)) / (100 + 8 * (_local5 - 2)) * 100 - 100;
				}
				_local1 = ship.hpBase * _local2 / 100;
				ship.hpBase += _local1;
				ship.hpMax += _local1;
				_local1 = ship.shieldHpBase * _local2 / 100;
				ship.shieldHpBase += _local1;
				ship.shieldHpMax += _local1;
				_local1 = ship.armorThresholdBase * _local2 / 100;
				ship.armorThresholdBase += _local1;
				ship.armorThreshold += _local1;
				_local2 = (100 + 1 * (_local5 - 1)) / (100 + 1 * (_local5 - 2)) * 100 - 100;
				_local1 = ship.shieldRegenBase * _local2 / 100;
				ship.shieldRegenBase += _local1;
				ship.shieldRegen += _local1;
				if(level == 2) {
					_local2 = 8;
				} else {
					_local2 = (100 + 8 * (_local5 - 1)) / (100 + 8 * (_local5 - 2)) * 100 - 100;
				}
				refreshWeapons();
				level = _local6;
			}
		}
		
		public function increaseXp(xpGain:int, newXp:int) : void {
			xp = newXp;
			while(xp > levelXpMax) {
				levelUp();
			}
			if(isMe) {
				g.textManager.createXpText(xpGain);
			}
		}
		
		public function decreaseXp(xpLoss:int, newXp:int) : void {
			xp = newXp;
			if(isMe) {
				g.textManager.createXpText(-xpLoss);
			}
		}
		
		public function updateReputation(mod:int, rep:int) : void {
			reputation = rep;
			Login.submitKongregateStat("Reputation",mod);
			if(ship == null) {
				return;
			}
			if(mod != 0) {
				g.textManager.createReputationText(mod,ship);
			}
		}
		
		public function get levelXpMax() : int {
			if(level >= 100) {
				return int((level + 2) * level * 500 * Math.pow(1.06,level - 99));
			}
			return (level + 2) * level * 500;
		}
		
		public function get levelXpMin() : int {
			if(level >= 100) {
				return int((level + 1) * (level - 1) * 500 * Math.pow(1.06,level - 100));
			}
			if(level == 1) {
				return 0;
			}
			return (level + 1) * (level - 1) * 500;
		}
		
		public function loadCourse(heading:Heading) : void {
			if(ship != null) {
				ship.course = heading;
			}
		}
		
		public function get hasExpBoost() : Boolean {
			if(isModerator) {
				return true;
			}
			return expBoost > g.time;
		}
		
		public function set level(value:int) : void {
			_level = value;
			if(ship != null) {
				ship.level = value;
				ship.updateLabel();
			}
		}
		
		public function get level() : int {
			return _level;
		}
		
		public function initRoaming(m:Message, i:int, changeGameState:Boolean = true) : int {
			if(stateMachine.inState(RoamingState)) {
				return i;
			}
			unloadShip();
			level = m.getInt(i++);
			xp = m.getInt(i++);
			techPoints = m.getInt(i++);
			isHostile = m.getBoolean(i++);
			var _local6:String = m.getString(i++);
			var _local5:int = m.getInt(i++);
			var _local8:int = m.getInt(i++);
			var _local7:int = m.getInt(i++);
			var _local12:int = m.getInt(i++);
			var _local11:int = m.getInt(i++);
			var _local9:Number = m.getNumber(i++);
			var _local10:Number = m.getNumber(i++);
			var _local4:Heading = new Heading();
			i = _local4.parseMessage(m,i);
			playerKills = m.getInt(i++);
			playerDeaths = m.getInt(i++);
			enemyKills = m.getInt(i++);
			showIntro = m.getBoolean(i++);
			clanId = m.getString(i++);
			clanApplicationId = m.getString(i++);
			troons = m.getNumber(i++);
			i = initFleetFromMessage(m,i);
			loadShip(_local8,_local7,_local12,_local11);
			ship.id = _local5;
			loadCourse(_local4);
			if(isMe) {
				applyArtifactStats();
				ship.shieldHp = _local8;
				ship.hp = _local7;
				g.hud.weaponHotkeys.refresh();
				g.hud.abilities.refresh();
				g.hud.healthAndShield.update();
				g.hud.powerBar.update();
				if(changeGameState) {
					g.fadeIntoState(new RoamingState(g));
				}
			} else {
				ship.engine.speed = _local9;
				ship.engine.acceleration = _local10;
			}
			enterRoaming();
			g.groupManager.autoJoinOrCreateGroup(this,_local6);
			return i;
		}
		
		public function enterRoaming() : void {
			isLanded = false;
			isTakingOff = false;
			if(!stateMachine.inState(Roaming)) {
				stateMachine.changeState(new Roaming(this,g));
			}
		}
		
		public function startLanded(b:Body) : void {
			if(stateMachine.inState(Landed)) {
				return;
			}
			stateMachine.changeState(new Landed(this,b,g));
		}
		
		public function land(body:Body) : void {
			var that:Player;
			var toRot:Number;
			if(stateMachine.inState(Landed)) {
				return;
			}
			isLanded = true;
			that = this;
			toRot = 0;
			if(ship.rotation > 3.1) {
				toRot = 6.2;
			}
			ship.engine.stop();
			if(!isMe) {
				TweenMax.to(ship,1.2,{
					"x":body.x,
					"y":body.y,
					"scaleX":0.5,
					"scaleY":0.5,
					"rotation":toRot,
					"onComplete":function():void {
						stateMachine.changeState(new Landed(that,body,g));
						ship.removeFromCanvas();
						ship.land();
					}
				});
				return;
			}
			g.camera.zoomFocus(3,25);
			TweenMax.to(ship,1.2,{
				"x":body.x,
				"y":body.y,
				"scaleX":0.5,
				"scaleY":0.5,
				"rotation":toRot,
				"onComplete":function():void {
					stateMachine.changeState(new Landed(g.me,body,g));
					g.enterLandedState();
					ship.land();
					TweenMax.delayedCall(0.5,function():void {
						g.camera.zoomFocus(1,1);
					});
				}
			});
		}
		
		public function enterKilled(m:Message) : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				respawnNextReady = g.time + 50 * 60;
			} else {
				respawnNextReady = g.time + 10000;
			}
			stateMachine.changeState(new Killed(this,g,m));
		}
		
		public function hasExploredArea(areaKey:String) : Boolean {
			for each(var _local2:* in explores) {
				if(areaKey == _local2.areaKey && _local2.finished && _local2.lootClaimed) {
					return true;
				}
			}
			return false;
		}
		
		public function leaveBody() : void {
			if(!isTakingOff) {
				Console.write("Leaving body");
				isTakingOff = true;
				g.send("leaveBody");
			}
		}
		
		public function initMissionsFromMessage(m:Message, startIndex:int) : int {
			Console.write("Init missions");
			missions = new Vector.<Mission>();
			var _local3:int = m.getInt(startIndex);
			var _local4:int = startIndex + 1;
			while(_local3 > 0) {
				_local4 = addMission(m,_local4);
				_local3--;
			}
			return _local4;
		}
		
		public function addMission(m:Message, i:int) : int {
			var _local3:Mission = new Mission();
			_local3.id = m.getString(i++);
			_local3.missionTypeKey = m.getString(i++);
			_local3.type = m.getString(i++);
			_local3.majorType = m.getString(i++);
			_local3.count = m.getInt(i++);
			_local3.viewed = m.getBoolean(i++);
			_local3.finished = m.getBoolean(i++);
			_local3.claimed = m.getBoolean(i++);
			_local3.created = m.getNumber(i++);
			_local3.expires = m.getNumber(i++);
			missions.push(_local3);
			return i;
		}
		
		public function hasMission(id:String) : Boolean {
			for each(var _local2:* in missions) {
				if(_local2.id == id) {
					return true;
				}
			}
			return false;
		}
		
		public function removeMission(m:Mission) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < missions.length) {
				if(missions[_local2].missionTypeKey == m.missionTypeKey) {
					missions.splice(_local2,1);
					return;
				}
				_local2++;
			}
		}
		
		public function initFinishedExploresFromMessage(m:Message, startIndex:int) : int {
			var _local3:String = null;
			var _local7:int = 0;
			var _local4:Explore = null;
			explores = new Vector.<Explore>();
			var _local5:int = m.getInt(startIndex);
			var _local8:int = startIndex + 1;
			var _local6:Object = g.dataManager.loadTable("BodyAreas");
			while(_local5 > 0) {
				_local3 = m.getString(_local8++);
				_local7 = int(_local6[_local3] != null ? _local6[_local3].size : 0);
				_local7 = _local7 + 4;
				_local4 = new Explore();
				_local4.key = "";
				_local4.areaKey = _local3;
				_local4.bodyKey = "";
				_local4.failed = false;
				_local4.failTime = 0;
				_local4.finished = true;
				_local4.finishTime = 0;
				_local4.lootClaimed = true;
				_local4.playerKey = id;
				_local4.startEvent = 0;
				_local4.startTime = 0;
				_local4.successfulEvents = _local7;
				explores.push(_local4);
				_local5--;
			}
			return _local8;
		}
		
		public function initExploresFromMessage(m:Message, startIndex:int) : int {
			var _local3:Explore = null;
			var _local4:int = m.getInt(startIndex);
			var _local5:int = startIndex + 1;
			while(_local4 > 0) {
				_local3 = new Explore();
				_local3.key = m.getString(_local5++);
				_local3.areaKey = m.getString(_local5++);
				_local3.bodyKey = m.getString(_local5++);
				_local3.failed = m.getBoolean(_local5++);
				_local3.failTime = m.getNumber(_local5++);
				_local3.finished = m.getBoolean(_local5++);
				_local3.finishTime = m.getNumber(_local5++);
				_local3.lootClaimed = m.getBoolean(_local5++);
				_local3.playerKey = m.getString(_local5++);
				_local3.startEvent = m.getInt(_local5++);
				_local3.startTime = m.getNumber(_local5++);
				_local3.successfulEvents = m.getInt(_local5++);
				explores.push(_local3);
				_local4--;
			}
			return _local5;
		}
		
		public function initLandedBodiesFromMessage(m:Message, startIndex:int) : int {
			var _local4:int = 0;
			landedBodies = new Vector.<LandedBody>();
			var _local3:int = m.getInt(startIndex);
			_local4 = startIndex + 1;
			while(_local4 < startIndex + _local3 * 2 + 1) {
				landedBodies.push(new LandedBody(m.getString(_local4),m.getBoolean(_local4 + 1)));
				_local4 += 2;
			}
			return _local4;
		}
		
		public function initEncountersFromMessage(m:Message, startIndex:int) : int {
			var _local4:int = 0;
			encounters = new Vector.<String>();
			var _local3:int = m.getInt(startIndex);
			_local4 = startIndex + 1;
			while(_local4 < startIndex + _local3 + 1) {
				encounters.push(m.getString(_local4));
				_local4++;
			}
			return _local4;
		}
		
		public function initCompletedMissionsFromMessage(m:Message, startIndex:int) : int {
			var _local4:int = 0;
			completedMissions = {};
			var _local3:int = m.getInt(startIndex);
			_local4 = startIndex + 1;
			while(_local4 < startIndex + _local3 * 2 + 1) {
				completedMissions[m.getString(_local4)] = m.getNumber(_local4 + 1);
				_local4 += 2;
			}
			return _local4;
		}
		
		public function initTriggeredMissionsFromMessage(m:Message, startIndex:int) : int {
			var _local4:int = 0;
			triggeredMissions = new Vector.<String>();
			var _local3:int = m.getInt(startIndex);
			_local4 = startIndex + 1;
			while(_local4 < startIndex + _local3 + 1) {
				triggeredMissions.push(m.getString(_local4));
				_local4++;
			}
			return _local4;
		}
		
		public function initCrewFromMessage(m:Message, startIndex:int) : int {
			var _local7:int = 0;
			var _local5:CrewMember = null;
			var _local3:Array = null;
			var _local6:Array = null;
			crewMembers = new Vector.<CrewMember>();
			var _local4:int = m.getInt(startIndex);
			_local7 = startIndex + 1;
			while(_local7 < startIndex + _local4 * 30 + 1) {
				_local5 = new CrewMember(g);
				_local5.seed = m.getInt(_local7++);
				_local5.key = m.getString(_local7++);
				_local5.name = m.getString(_local7++);
				_local5.solarSystem = m.getString(_local7++);
				_local5.area = m.getString(_local7++);
				_local5.body = m.getString(_local7++);
				_local5.imageKey = m.getString(_local7++);
				_local5.injuryEnd = m.getNumber(_local7++);
				_local5.injuryStart = m.getNumber(_local7++);
				_local5.trainingEnd = m.getNumber(_local7++);
				_local5.trainingType = m.getInt(_local7++);
				_local5.artifactEnd = m.getNumber(_local7++);
				_local5.artifact = m.getString(_local7++);
				_local5.missions = m.getInt(_local7++);
				_local5.successMissions = m.getInt(_local7++);
				_local5.rank = m.getInt(_local7++);
				_local5.fullLocation = m.getString(_local7++);
				_local5.skillPoints = m.getInt(_local7++);
				_local3 = [];
				_local3.push(m.getNumber(_local7++));
				_local3.push(m.getNumber(_local7++));
				_local3.push(m.getNumber(_local7++));
				_local5.skills = _local3;
				_local6 = [];
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local6.push(m.getNumber(_local7++));
				_local5.specials = _local6;
				crewMembers.push(_local5);
				_local7 += 0;
			}
			return _local7;
		}
		
		public function initFleetFromMessage(m:Message, startIndex:int) : int {
			var _local6:int = 0;
			var _local4:FleetObj = null;
			fleet.length = 0;
			activeSkin = m.getString(startIndex++);
			var _local5:int = m.getInt(startIndex++);
			var _local3:* = startIndex;
			_local6 = 0;
			while(_local6 < _local5) {
				_local4 = new FleetObj();
				_local3 = _local4.initFromMessage(m,_local3);
				if(_local4.skin == activeSkin) {
					techSkills = _local4.techSkills;
					weapons = _local4.weapons;
					weaponsState = _local4.weaponsState;
					weaponsHotkeys = _local4.weaponsHotkeys;
					nrOfUpgrades = _local4.nrOfUpgrades;
					activeArtifactSetup = _local4.activeArtifactSetup;
					activeWeapon = _local4.activeWeapon;
				}
				fleet.push(_local4);
				_local6++;
			}
			return _local3;
		}
		
		public function addNewSkin(skinKey:String) : void {
			if(hasSkin(skinKey)) {
				return;
			}
			var _local2:FleetObj = new FleetObj();
			_local2.initFromSkin(skinKey);
			fleet.push(_local2);
		}
		
		private function initWarpPathLicensesFromMessage(m:Message, i:int) : int {
			var _local4:int = 0;
			var _local3:int = m.getInt(i++);
			warpPathLicenses = [];
			_local4 = 0;
			while(_local4 < _local3) {
				warpPathLicenses.push(m.getString(i++));
				_local4++;
			}
			return i;
		}
		
		private function initSolarSystemLicensesFromMessage(m:Message, i:int) : int {
			var _local4:int = 0;
			var _local3:int = m.getInt(i++);
			solarSystemLicenses = [];
			_local4 = 0;
			while(_local4 < _local3) {
				solarSystemLicenses.push(m.getString(i++));
				_local4++;
			}
			return i;
		}
		
		private function initArtifactsFromMessage(m:Message, startIndex:int) : int {
			var setups:int;
			var keysToLoad:Array;
			var setup:Array;
			var count:int;
			var artifactId:String;
			artifacts = g.dataManager.getArtifacts();
			artifactSetups.length = 0;
			setups = m.getInt(startIndex++);
			keysToLoad = [];
			while(setups > 0) {
				setup = [];
				count = m.getInt(startIndex++);
				while(count > 0) {
					artifactId = m.getString(startIndex++);
					setup.push(artifactId);
					if(keysToLoad.indexOf(artifactId) == -1 && getArtifactById(artifactId) == null) {
						keysToLoad.push(artifactId);
					}
					count--;
				}
				artifactSetups.push(setup);
				setups--;
			}
			if(keysToLoad.length != 0) {
				ArtifactFactory.createArtifacts(keysToLoad,g,this,function():void {
					applyArtifactStats();
				});
			} else {
				Starling.juggler.delayCall(applyArtifactStats,1);
			}
			return startIndex;
		}
		
		private function applySkinArtifact() : void {
			var _local1:Object = DataLocator.getService().loadKey("Skins",activeSkin);
			addArtifactStat(ArtifactFactory.createArtifactFromSkin(_local1),false);
		}
		
		private function applyArtifactStats() : void {
			var _local1:Artifact = null;
			if(ship == null) {
				return;
			}
			applySkinArtifact();
			for each(var _local2:* in activeArtifacts) {
				_local1 = getArtifactById(_local2);
				if(_local1 != null) {
					addArtifactStat(_local1,false);
				}
			}
			ship.hp = ship.hpMax;
			ship.shieldHp = ship.shieldHpMax;
		}
		
		public function changeArtifactSetup(index:int) : void {
			var _local4:* = null;
			var _local2:Artifact = null;
			var _local5:int = 0;
			var _local3:FleetObj = null;
			for each(_local4 in activeArtifacts) {
				_local2 = getArtifactById(_local4);
				if(_local2 != null) {
					removeArtifactStat(_local2,false);
				}
			}
			activeArtifactSetup = index;
			_local5 = 0;
			while(_local5 < fleet.length) {
				_local3 = fleet[_local5];
				if(_local3.skin == activeSkin) {
					_local3.activeArtifactSetup = index;
					break;
				}
				_local5++;
			}
			for each(_local4 in activeArtifacts) {
				_local2 = getArtifactById(_local4);
				if(_local2 != null) {
					addArtifactStat(_local2,false);
				}
			}
		}
		
		private function loadArtifactsFromMessage(m:Message, startIndex:int, isLoot:Boolean = false) : int {
			var id:String;
			var nrOfArtifacts:int = m.getInt(startIndex++);
			var i:int = 0;
			while(i < nrOfArtifacts) {
				id = m.getString(startIndex++);
				ArtifactFactory.createArtifact(id,g,this,function(param1:Artifact):void {
					if(param1 == null) {
						return;
					}
					if(isLoot) {
						MessageLog.writeChatMsg("loot","<FONT COLOR=\'#4488ff\'>You found a new artifact: " + param1.name + ".</FONT>");
						g.textManager.createDropText("You found a new Artifact!",1,20,5000,0x4488ff);
					}
					artifacts.push(param1);
				});
				i++;
			}
			return startIndex;
		}
		
		public function addWeapon(item:String) : void {
			weapons.push({"weapon":item});
			addTechSkill(name,"Weapons",item);
			refreshWeapons();
		}
		
		public function pickupArtifacts(m:Message) : void {
			g.hud.artifactsButton.hintNew();
			loadArtifactsFromMessage(m,0,true);
			artifactCount += m.getInt(0);
			if(artifactCount >= artifactLimit) {
				g.hud.showArtifactLimitText();
			}
		}
		
		public function pickupArtifact(m:Message) : void {
			g.hud.artifactsButton.hintNew();
			loadArtifactsFromMessage(m,0,true);
			artifactCount += 1;
			if(artifactCount >= artifactLimit) {
				g.hud.showArtifactLimitText();
			}
		}
		
		public function checkPickupMessage(m:Message, i:int) : void {
			var _local6:String = null;
			var _local3:String = null;
			var _local7:String = null;
			var _local4:int = 0;
			var _local13:Boolean = false;
			var _local10:Boolean = false;
			if(!isMe) {
				return;
			}
			var _local12:Boolean = m.getBoolean(i);
			var _local5:Boolean = m.getBoolean(i + 1);
			var _local9:Boolean = m.getBoolean(i + 2);
			i += 3;
			if(_local5) {
				g.hud.artifactsButton.hintNew();
				i = loadArtifactsFromMessage(m,i,true);
				artifactCount += 1;
				if(artifactCount >= artifactLimit) {
					g.hud.showArtifactLimitText();
				}
			}
			if(_local12) {
				MessageLog.writeChatMsg("loot","<FONT COLOR=\'#4488ff\'>You found a Crate</FONT>");
			}
			if(_local9) {
				MessageLog.writeChatMsg("loot","<FONT COLOR=\'#ffcc44\'>Auto recycled artifact</FONT>");
			}
			var _local11:int = m.getInt(i++);
			var _local8:int = i + _local11 * 6;
			i;
			while(i < _local8) {
				_local6 = m.getString(i);
				_local3 = m.getString(i + 1);
				_local7 = m.getString(i + 2);
				_local4 = m.getInt(i + 3);
				_local13 = m.getBoolean(i + 4);
				_local10 = m.getBoolean(i + 5);
				if(_local3 == "Weapons") {
					MessageLog.writeChatMsg("loot","<FONT COLOR=\'#ff3322\'>You found a new weapon: " + _local6 + "</FONT>");
					g.textManager.createDropText("You found the " + _local6 + "!",1,20,5000,0xff3322);
				} else if(_local12) {
					g.textManager.createDropText(_local6,_local4,20,5000,0xffff88);
					MessageLog.writeChatMsg("loot",_local6 + " x" + _local4);
					g.myCargo.addItem(_local3,_local7,_local4);
				} else if(_local9) {
					g.textManager.createDropText(_local6,_local4,14,5000,0xffcc44);
					g.myCargo.addItem(_local3,_local7,_local4);
				} else {
					g.textManager.createDropText(_local6,_local4);
					g.myCargo.addItem(_local3,_local7,_local4);
				}
				g.hud.cargoButton.update();
				g.hud.resourceBox.update();
				g.hud.cargoButton.flash();
				if(_local13) {
					weapons.push({"weapon":_local7});
					refreshWeapons();
				}
				if(_local10) {
					addTechSkill(_local6,_local3,_local7);
				}
				i += 6;
			}
		}
		
		public function addTechSkill(name:String, table:String, item:String) : void {
			techSkills.push(new TechSkill(name,item,table,0));
		}
		
		private function refreshWeapons(autoSetHotKeys:Boolean = true) : void {
			if(ship != null) {
				ship.weaponIsChanging = true;
				ShipFactory.CreatePlayerShipWeapon(g,this,0,weapons,ship);
				if(isMe) {
					if(autoSetHotKeys) {
						autoSetHotkeysForWeapons();
					}
					g.hud.weaponHotkeys.refresh();
				}
				ship.weaponIsChanging = false;
			}
		}
		
		private function autoSetHotkeysForWeapons() : void {
			var _local2:Vector.<Weapon> = ship.weapons;
			for each(var _local1:* in _local2) {
				if(_local1.hotkey == 0) {
					g.playerManager.trySetActiveWeapons(this,-1,_local1.key);
				}
			}
		}
		
		public function nrOfActiveArtifacts() : int {
			return activeArtifacts.length;
		}
		
		public function getArtifactById(artifactId:String) : Artifact {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < artifacts.length) {
				if(artifacts[_local2].id === artifactId) {
					return artifacts[_local2];
				}
				_local2++;
			}
			return null;
		}
		
		public function isActiveArtifact(a:Artifact) : Boolean {
			return activeArtifacts.indexOf(a.id) != -1;
		}
		
		public function isArtifactInSetup(a:Artifact) : Boolean {
			for each(var _local2:* in artifactSetups) {
				if(_local2.indexOf(a.id) != -1) {
					return true;
				}
			}
			return false;
		}
		
		public function addArtifactStat(a:Artifact, notifyServer:Boolean = true) : void {
			addRemoveArtifactStat(a,true,notifyServer);
		}
		
		public function removeArtifactStat(a:Artifact, notifyServer:Boolean = true) : void {
			addRemoveArtifactStat(a,false,notifyServer);
		}
		
		public function toggleArtifact(a:Artifact, notifyServer:Boolean = true) : void {
			var _local3:int = int(activeArtifacts.indexOf(a.id));
			if(_local3 != -1) {
				activeArtifacts.splice(_local3,1);
				removeArtifactStat(a,notifyServer);
			} else {
				activeArtifacts.push(a.id);
				addArtifactStat(a,notifyServer);
			}
		}
		
		private function addRemoveArtifactStat(a:Artifact, active:Boolean, notifyServer:Boolean = true) : void {
			var _local6:Number = NaN;
			var _local4:* = null;
			var _local7:int = 0;
			if(ship == null) {
				return;
			}
			if(notifyServer) {
				g.send("toggleArtifact",a.id);
			}
			for each(var _local5:* in a.stats) {
				_local6 = 1;
				if(!active) {
					_local6 = -1;
				}
				if(_local5.type == "healthAdd" || _local5.type == "healthAdd2" || _local5.type == "healthAdd3") {
					ship.removeConvert();
					ship.hpMax += int(_local6 * 2 * _local5.value);
					ship.addConvert();
				} else if(_local5.type == "healthMulti") {
					ship.removeConvert();
					ship.hpMax += int(_local6 * ship.hpBase * (1.35 * _local5.value) / 100);
					ship.addConvert();
				} else if(_local5.type == "armorAdd" || _local5.type == "armorAdd2" || _local5.type == "armorAdd3") {
					ship.armorThreshold += int(_local6 * 7.5 * _local5.value);
				} else if(_local5.type == "armorMulti") {
					ship.armorThreshold += int(_local6 * ship.armorThresholdBase * _local5.value / 100);
				} else if(_local5.type == "shieldAdd" || _local5.type == "shieldAdd2" || _local5.type == "shieldAdd3") {
					ship.removeConvert();
					ship.shieldHpMax += int(_local6 * 1.5 * _local5.value);
					ship.shieldRegen += int(_local6 * ship.shieldRegenBase * (0.0025 * _local5.value) / 100);
					ship.addConvert();
				} else if(_local5.type == "shieldMulti") {
					ship.removeConvert();
					ship.shieldHpMax += int(_local6 * ship.shieldHpBase * (1.35 * _local5.value) / 100);
					ship.shieldRegen += int(_local6 * ship.shieldRegenBase * (0.25 * _local5.value) / 100);
					ship.addConvert();
				} else if(_local5.type == "shieldRegen") {
					ship.removeConvert();
					ship.shieldRegen += int(_local6 * ship.shieldRegenBase * _local5.value / 100);
					ship.addConvert();
				} else if(_local5.type == "corrosiveAdd" || _local5.type == "corrosiveAdd2" || _local5.type == "corrosiveAdd3") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgInt(int(_local6 * 4 * _local5.value),2);
						if(_local4.multiNrOfP > 1) {
							_local4.debuffValue.addDmgInt(int(1.5 / _local4.multiNrOfP * 4 * _local6 * _local5.value),2);
							_local4.debuffValue2.addDmgInt(int(1.5 / _local4.multiNrOfP * 4 * _local6 * _local5.value),2);
						} else {
							_local4.debuffValue.addDmgInt(int(_local6 * 4 * _local5.value),2);
							_local4.debuffValue2.addDmgInt(int(_local6 * 4 * _local5.value),2);
						}
					}
				} else if(_local5.type == "corrosiveMulti") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgPercent(_local6 * _local5.value,2);
						_local4.debuffValue.addDmgPercent(_local6 * _local5.value,2);
						_local4.debuffValue2.addDmgPercent(_local6 * _local5.value,2);
					}
				} else if(_local5.type == "energyAdd" || _local5.type == "energyAdd2" || _local5.type == "energyAdd3") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgInt(int(_local6 * 4 * _local5.value),1);
						if(_local4.multiNrOfP > 1) {
							_local4.debuffValue.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 4 * _local5.value),1);
							_local4.debuffValue2.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 4 * _local5.value),1);
						} else {
							_local4.debuffValue.addDmgInt(int(_local6 * 4 * _local5.value),1);
							_local4.debuffValue2.addDmgInt(int(_local6 * 4 * _local5.value),1);
						}
					}
				} else if(_local5.type == "energyMulti") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgPercent(_local6 * _local5.value,1);
						_local4.debuffValue.addDmgPercent(_local6 * _local5.value,1);
						_local4.debuffValue2.addDmgPercent(_local6 * _local5.value,1);
					}
				} else if(_local5.type == "kineticAdd" || _local5.type == "kineticAdd2" || _local5.type == "kineticAdd3") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgInt(int(_local6 * 4 * _local5.value),0);
						if(_local4.multiNrOfP > 1) {
							_local4.debuffValue.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 4 * _local5.value),0);
							_local4.debuffValue2.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 4 * _local5.value),0);
						} else {
							_local4.debuffValue.addDmgInt(int(_local6 * 4 * _local5.value),0);
							_local4.debuffValue2.addDmgInt(int(_local6 * 4 * _local5.value),0);
						}
					}
				} else if(_local5.type == "kineticMulti") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgPercent(_local6 * _local5.value,0);
						_local4.debuffValue.addDmgPercent(_local6 * _local5.value,0);
						_local4.debuffValue2.addDmgPercent(_local6 * _local5.value,0);
					}
				} else if(_local5.type == "allAdd" || _local5.type == "allAdd2" || _local5.type == "allAdd3") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgInt(int(_local6 * 1.5 * _local5.value),5);
						if(_local4.multiNrOfP > 1) {
							_local4.debuffValue.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 1.5 * _local5.value),5);
							_local4.debuffValue2.addDmgInt(int(1.5 / _local4.multiNrOfP * _local6 * 1.5 * _local5.value),5);
						} else {
							_local4.debuffValue.addDmgInt(int(_local6 * 1.5 * _local5.value),5);
							_local4.debuffValue2.addDmgInt(int(_local6 * 1.5 * _local5.value),5);
						}
					}
				} else if(_local5.type == "allMulti") {
					for each(_local4 in ship.weapons) {
						_local4.dmg.addDmgPercent(_local6 * 1.5 * _local5.value,5);
						_local4.debuffValue.addDmgPercent(_local6 * 1.5 * _local5.value,5);
						_local4.debuffValue2.addDmgPercent(_local6 * 1.5 * _local5.value,5);
					}
				} else if(_local5.type == "allResist") {
					_local7 = 0;
					while(_local7 < 5) {
						var _local9:* = _local7;
						var _local8:* = ship.resistances[_local9] + _local6 * _local5.value * Damage.stats[5][_local7];
						ship.resistances[_local9] = _local8;
						if(ship.resistances[_local7] < 0) {
							ship.resistances[_local7] = 0;
						}
						_local7++;
					}
				} else if(_local5.type == "kineticResist") {
					var _local11:int = 0;
					var _local10:* = ship.resistances[_local11] + _local6 * _local5.value;
					ship.resistances[_local11] = _local10;
					if(ship.resistances[0] < 0) {
						ship.resistances[0] = 0;
					}
				} else if(_local5.type == "energyResist") {
					var _local13:int = 1;
					var _local12:* = ship.resistances[_local13] + _local6 * _local5.value;
					ship.resistances[_local13] = _local12;
					if(ship.resistances[1] < 0) {
						ship.resistances[1] = 0;
					}
				} else if(_local5.type == "corrosiveResist") {
					var _local15:int = 2;
					var _local14:* = ship.resistances[_local15] + _local6 * _local5.value;
					ship.resistances[_local15] = _local14;
					if(ship.resistances[2] < 0) {
						ship.resistances[2] = 0;
					}
				} else if(_local5.type == "speed" || _local5.type == "speed2" || _local5.type == "speed3") {
					ship.engine.speed /= 1 + ship.aritfact_speed;
					ship.aritfact_speed += _local6 * 0.001 * 2 * _local5.value;
					ship.engine.speed *= 1 + ship.aritfact_speed;
				} else if(_local5.type == "refire" || _local5.type == "refire2" || _local5.type == "refire3") {
					_local7 = 0;
					while(_local7 < ship.weapons.length) {
						if(ship.weapons[_local7] is Teleport) {
							ship.weapons[_local7].speed /= 1 + 0.5 * ship.aritfact_refire;
						} else if(!(ship.weapons[_local7] is Cloak)) {
							ship.weapons[_local7].reloadTime *= 1 + ship.aritfact_refire;
							ship.weapons[_local7].heatCost *= 1 + ship.aritfact_refire;
						}
						_local7++;
					}
					ship.aritfact_refire += _local6 * 3 * 0.001 * _local5.value;
					_local7 = 0;
					while(_local7 < ship.weapons.length) {
						if(ship.weapons[_local7] is Teleport) {
							ship.weapons[_local7].speed *= 1 + 0.5 * ship.aritfact_refire;
						} else if(!(ship.weapons[_local7] is Cloak)) {
							ship.weapons[_local7].reloadTime /= 1 + ship.aritfact_refire;
							ship.weapons[_local7].heatCost /= 1 + ship.aritfact_refire;
						}
						_local7++;
					}
				} else if(_local5.type == "convHp") {
					ship.removeConvert();
					ship.aritfact_convAmount -= _local6 * 0.001 * _local5.value;
					ship.addConvert();
				} else if(_local5.type == "convShield") {
					ship.removeConvert();
					ship.aritfact_convAmount += _local6 * 0.001 * _local5.value;
					ship.addConvert();
				} else if(_local5.type == "powerReg" || _local5.type == "powerReg2" || _local5.type == "powerReg3") {
					ship.powerRegBonus += _local6 * 0.001 * 1.5 * _local5.value;
					ship.weaponHeat.setBonuses(ship.maxPower + ship.aritfact_powerMax,ship.powerRegBonus + ship.aritfact_poweReg);
				} else if(_local5.type == "powerMax") {
					ship.aritfact_powerMax += _local6 * 0.01 * 1.5 * _local5.value;
					ship.weaponHeat.setBonuses(ship.maxPower + ship.aritfact_powerMax,ship.powerRegBonus + ship.aritfact_poweReg);
				} else if(_local5.type == "cooldown" || _local5.type == "cooldown2" || _local5.type == "cooldown3") {
					_local7 = 0;
					while(_local7 < ship.weapons.length) {
						if(ship.weapons[_local7] is Teleport || ship.weapons[_local7] is Cloak) {
							ship.weapons[_local7].reloadTime *= 1 + ship.aritfact_cooldownReduction;
						}
						_local7++;
					}
					ship.aritfact_cooldownReduction += _local6 * 0.001 * _local5.value;
					_local7 = 0;
					while(_local7 < ship.weapons.length) {
						if(ship.weapons[_local7] is Teleport || ship.weapons[_local7] is Cloak) {
							ship.weapons[_local7].reloadTime /= 1 + ship.aritfact_cooldownReduction;
						}
						_local7++;
					}
				}
			}
			if(isMe) {
				if(!g.hud.isLoaded) {
					return;
				}
				g.hud.healthAndShield.update();
				g.hud.weaponHotkeys.refresh();
				g.hud.abilities.refresh();
			}
		}
		
		public function hasTechSkill(table:String, tech:String) : Boolean {
			for each(var _local3:* in techSkills) {
				if(_local3.table == table && _local3.tech == tech) {
					return true;
				}
			}
			return false;
		}
		
		public function changeWeapon(m:Message, i:int) : void {
			var _local8:int = 0;
			var _local6:FleetObj = null;
			var _local3:Weapon = null;
			var _local4:int = m.getInt(i + 1);
			var _local5:String = m.getString(i + 2);
			if(_local5 != null && _local5 != "") {
				activeWeapon = _local5;
				_local8 = 0;
				while(_local8 < fleet.length) {
					_local6 = fleet[_local8];
					if(_local6.skin == activeSkin) {
						_local6.activeWeapon = _local5;
						break;
					}
					_local8++;
				}
			}
			if(ship == null) {
				return;
			}
			selectedWeaponIndex = _local4;
			ship.weaponIsChanging = false;
			for each(var _local7:* in weapons) {
				if(_local7 is Weapon) {
					_local3 = _local7 as Weapon;
					_local3.fire = false;
				}
			}
			if(isMe) {
				g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_local4].hotkey);
			}
		}
		
		public function sendChangeWeapon(weaponUsedHotkey:int) : void {
			var _local3:int = 0;
			if(weaponUsedHotkey != 0 && ship != null) {
				_local3 = 0;
				while(_local3 < ship.weapons.length) {
					if(ship.weapons[_local3].active && ship.weapons[_local3].hotkey == weaponUsedHotkey) {
						ship.weaponIsChanging = true;
						for each(var _local2:* in ship.weapons) {
							_local2.fire = false;
						}
						selectedWeaponIndex = _local3;
						g.send("changeWeapon",_local3);
						return;
					}
					_local3++;
				}
			}
		}
		
		public function tryUnlockSlot(type:String, index:int, callback:Function) : void {
			if(type == "slotCrew" && index + 1 < 4) {
				return;
			}
			g.rpc("tryUnlockSlot",function(param1:Message):void {
				var _local4:String = param1.getString(0);
				var _local2:int = param1.getInt(1);
				var _local5:int = 0;
				var _local3:String = "";
				if(_local4 == "slotWeapon") {
					_local5 = int(SLOT_WEAPON_UNLOCK_COST[_local2 - 1]);
					_local3 = "flpbTKautkC1QzjWT28gkw";
					unlockedWeaponSlots = _local2;
					if(ship != null) {
						ship.unlockedWeaponSlots = _local2;
					}
				} else if(_local4 == "slotArtifact") {
					_local5 = int(SLOT_ARTIFACT_UNLOCK_COST[_local2 - 1]);
					_local3 = "flpbTKautkC1QzjWT28gkw";
					unlockedArtifactSlots = _local2;
				} else if(_local4 == "slotCrew") {
					_local5 = int(SLOT_CREW_UNLOCK_COST[_local2 - 1]);
					_local3 = "flpbTKautkC1QzjWT28gkw";
					unlockedCrewSlots = _local2;
				}
				g.myCargo.removeMinerals(_local3,_local5);
				callback();
			},type,index);
		}
		
		public function get team() : int {
			return _team;
		}
		
		public function set team(value:int) : void {
			_team = value;
			if(ship != null) {
				ship.team = value;
				ship.updateLabel();
			}
		}
		
		public function get name() : String {
			return _name;
		}
		
		public function set name(value:String) : void {
			_name = value;
		}
		
		public function get inSafeZone() : Boolean {
			return _inSafeZone;
		}
		
		public function set inSafeZone(value:Boolean) : void {
			_inSafeZone = value;
		}
		
		public function set isWarpJumping(value:Boolean) : void {
			_isWarpJumping = value;
		}
		
		public function get isWarpJumping() : Boolean {
			return _isWarpJumping;
		}
		
		public function get invulnarable() : Boolean {
			if(_inSafeZone || _isWarpJumping) {
				return true;
			}
			return false;
		}
		
		public function saveWeaponData(weapList:Vector.<Weapon>) : void {
			var _local4:WeaponDataHolder = null;
			var _local3:String = "";
			weaponData = new Vector.<WeaponDataHolder>();
			for each(var _local2:* in weapList) {
				_local3 = _local2.getDescription(_local2 is Beam);
				_local4 = new WeaponDataHolder(_local2.key,_local3);
				weaponData.push(_local4);
			}
		}
		
		public function get commandable() : Boolean {
			if(ship == null || !ship.alive || isLanded || isWarpJumping) {
				return false;
			}
			return true;
		}
		
		public function getWeaponByHotkey(i:int) : Weapon {
			if(ship == null) {
				return null;
			}
			for each(var _local2:* in ship.weapons) {
				if(_local2.active && _local2.hotkey == i) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getCrewMember(key:String) : CrewMember {
			for each(var _local2:* in crewMembers) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getCrewMembersBySolarSystem(solarSystemKey:String) : Vector.<CrewMember> {
			var _local3:Vector.<CrewMember> = new Vector.<CrewMember>();
			for each(var _local2:* in crewMembers) {
				if(_local2.solarSystem == solarSystemKey) {
					_local3.push(_local2);
				}
			}
			return _local3;
		}
		
		public function isFriendWith(p:Player) : Boolean {
			for each(var _local2:* in friends) {
				if(_local2.id == p.id) {
					return true;
				}
			}
			return false;
		}
		
		public function removeMissionById(id:String) : void {
			var _local2:Mission = getMissionById(id);
			if(_local2 != null) {
				removeMission(_local2);
			}
		}
		
		private function getMissionById(id:String) : Mission {
			for each(var _local2:* in missions) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function updateMission(m:Message, i:int) : void {
			var missionType:Object;
			var id:String = m.getString(i);
			var missionTypeKey:String = m.getString(i + 1);
			var mission:Mission = getMissionById(id);
			if(mission == null) {
				return;
			}
			if(missionTypeKey == "KG4YJCr9tU6IH0rJRYo7HQ") {
				g.hud.compas.clear();
				TweenMax.delayedCall(1.5,function():void {
					var _local1:Boolean = false;
					for each(var _local3:* in g.bodyManager.bodies) {
						if(_local3.key == "SWqDETtcD0i6Wc3s81yccQ" || _local3.key == "U8PYtFoC5U6c2A_gar9j2A" || _local3.key == "TLYpHghGOU6FaZtxDiVXBA") {
							for each(var _local2:* in _local3.spawners) {
								if(_local2.alive) {
									_local1 = true;
									g.hud.compas.addHintArrowByKey(_local3.key);
									break;
								}
							}
							if(_local1) {
								break;
							}
						}
					}
				});
			}
			if(missionTypeKey == "s1l0zM-6lkq9l1jlGDBy4w") {
				g.hud.compas.clear();
			}
			g.hud.missionsButton.flash();
			mission.count = m.getInt(i + 2);
			missionType = mission.getMissionType();
			if(missionType != null && missionType.value != null) {
				g.textManager.createMissionUpdateText(mission.count,missionType.value);
			}
			mission.finished = m.getBoolean(i + 3);
			if(mission.finished) {
				g.hud.missionsButton.hintFinished();
				g.textManager.createMissionFinishedText();
				if(missionType.completeDescription != null) {
					g.tutorial.showMissionCompleteText(mission,missionType.drop,missionType.completeDescription);
				}
			}
			if(missionTypeKey == "puc60G5hKUypAIaEB4cAaA" || missionTypeKey == "mZsWmk4BUkunoD6w35aOjg" || missionTypeKey == "TYs2gVcB8UmyxfXqtIvTQA" || missionTypeKey == "m1gVvWQOGUmrFE6k4U9HOQ") {
				g.hud.compas.clear();
			}
		}
		
		public function toggleTractorBeam() : void {
			tractorBeamActive = !tractorBeamActive;
		}
		
		public function isTractorBeamActive() : Boolean {
			if(!hasTractorBeam()) {
				return false;
			}
			return tractorBeamActive;
		}
		
		public function hasTractorBeam() : Boolean {
			if(g.time == 0) {
				return false;
			}
			if(isModerator) {
				return true;
			}
			return tractorBeam > g.time;
		}
		
		public function hasXpProtection() : Boolean {
			if(g.time == 0) {
				return false;
			}
			if(level <= 15) {
				return true;
			}
			if(isModerator) {
				return true;
			}
			return xpProtection > g.time;
		}
		
		public function toggleCargoProtection() : void {
			cargoProtectionActive = !cargoProtectionActive;
		}
		
		public function isCargoProtectionActive() : Boolean {
			if(!hasCargoProtection()) {
				return false;
			}
			return cargoProtectionActive;
		}
		
		public function hasCargoProtection() : Boolean {
			if(g.time == 0) {
				return false;
			}
			if(isModerator) {
				return true;
			}
			return cargoProtection > g.time;
		}
		
		public function hasSupporter() : Boolean {
			if(g.time == 0) {
				return false;
			}
			if(isModerator) {
				return true;
			}
			return supporter > g.time;
		}
		
		public function changeSkin(skin:String) : void {
			var _local3:int = 0;
			var _local2:FleetObj = null;
			_local3 = 0;
			while(_local3 < fleet.length) {
				_local2 = fleet[_local3];
				if(skin == _local2.skin) {
					activeSkin = skin;
					g.send("changeSkin",skin);
					techSkills = _local2.techSkills;
					weapons = _local2.weapons;
					weaponsState = _local2.weaponsState;
					weaponsHotkeys = _local2.weaponsHotkeys;
					nrOfUpgrades = _local2.nrOfUpgrades;
					activeArtifactSetup = _local2.activeArtifactSetup;
					activeWeapon = _local2.activeWeapon;
					selectedWeaponIndex = 0;
					_local2.lastUsed = g.time;
					unloadShip();
					ship = ShipFactory.createPlayer(g,this,g.shipManager.getPlayerShip(),weapons);
					applyArtifactStats();
					return;
				}
				_local3++;
			}
		}
		
		public function respawnReady() : Boolean {
			return respawnNextReady < g.time && respawnNextReady > 0;
		}
		
		public function hasSkin(skin:String) : Boolean {
			for each(var _local2:* in fleet) {
				if(skin == _local2.skin) {
					return true;
				}
			}
			return false;
		}
		
		public function addEncounter(m:Message) : void {
			var _local3:Object = null;
			var _local4:String = m.getString(0);
			var _local2:int = m.getInt(1);
			if(_local4.search("enemy_") != -1) {
				_local3 = DataLocator.getService().loadKey("Enemies",_local4.replace("enemy_",""));
				if(_local3.hasOwnProperty("miniBoss") && _local3.miniBoss) {
					Game.trackEvent("encounters",_local3.name,name,level);
				}
			} else if(_local4.search("boss_") != -1) {
				_local3 = DataLocator.getService().loadKey("Bosses",_local4.replace("boss_",""));
				Game.trackEvent("encounters",_local3.name,name,level);
			}
			encounters.push(_local4);
			Action.encounter(_local4);
			MessageLog.write("<FONT COLOR=\'#44ff44\'>New Encounter!</FONT>");
			MessageLog.write(_local3.name);
			MessageLog.write("+" + _local2 + " bonus xp");
			g.hud.encountersButton.flash();
			g.hud.encountersButton.hintNew();
			g.textManager.createBonusXpText(_local2);
		}
		
		public function getFleetObj(skin:String) : FleetObj {
			for each(var _local2:* in fleet) {
				if(_local2.skin == skin) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getActiveFleetObj() : FleetObj {
			return getFleetObj(activeSkin);
		}
		
		public function addCompletedMission(missionTypeKey:String, bestTime:Number) : void {
			completedMissions[missionTypeKey] = bestTime;
			g.textManager.createMissionBestTimeText();
		}
		
		public function addTriggeredMission(typeKey:String) : void {
			triggeredMissions.push(typeKey);
		}
		
		public function hasTriggeredMission(typeKey:String) : Boolean {
			for each(var _local2:* in triggeredMissions) {
				if(_local2 == typeKey) {
					return true;
				}
			}
			return false;
		}
		
		public function dispose() : void {
			g = null;
			ship = null;
			stateMachine = null;
			currentBody = null;
			lastBody = null;
			weaponsHotkeys = null;
			weapons = null;
			weaponsState = null;
			weaponData = null;
			techSkills = null;
			artifacts = null;
			explores = null;
			missions = null;
			crewMembers = null;
			encounters = null;
			nrOfUpgrades = null;
			warpPathLicenses = null;
			solarSystemLicenses = null;
			pickUpLog = null;
			landedBodies = null;
			encounters = null;
			clanLogo = null;
		}
	}
}

