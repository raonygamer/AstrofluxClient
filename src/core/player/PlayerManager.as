package core.player
{
	import com.greensock.TweenMax;
	import core.hud.components.cargo.Cargo;
	import core.hud.components.chat.MessageLog;
	import core.hud.components.credits.FBInvite;
	import core.hud.components.credits.KongInvite;
	import core.hud.components.dialogs.CreditGainBox;
	import core.hud.components.dialogs.CrewJoinOffer;
	import core.hud.components.dialogs.DailyRewardMessage;
	import core.hud.components.dialogs.PopupMessage;
	import core.hud.components.pvp.DominationManager;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.gameStates.IntroState;
	import core.states.gameStates.WarpJumpState;
	import core.states.gameStates.missions.MissionsList;
	import core.unit.Unit;
	import core.weapon.Beam;
	import core.weapon.Heat;
	import core.weapon.Teleport;
	import core.weapon.Weapon;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import flash.utils.Dictionary;
	import generics.Localize;
	import joinRoom.IJoinRoomManager;
	import joinRoom.JoinRoomLocator;
	import movement.Heading;
	import playerio.Message;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class PlayerManager extends EventDispatcher
	{
		public static var banMinutes:int = 0;
		
		public static var isAllChannels:Boolean = false;
		
		private var _me:Player;
		
		private var _playersById:Dictionary;
		
		private var _players:Vector.<Player>;
		
		private var _enemyPlayers:Vector.<Player>;
		
		private var g:Game;
		
		public function PlayerManager(g:Game)
		{
			super();
			this.g = g;
			_players = new Vector.<Player>();
			_enemyPlayers = new Vector.<Player>();
			_playersById = new Dictionary();
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("reputationChange",reputationChange);
			g.addMessageHandler("playerKilled",killed);
			g.addMessageHandler("spawnDrop",spawnDrop);
			g.addMessageHandler("playerLanded",landed);
			g.addMessageHandler("playerEnterRoaming",initRoaming);
			g.addMessageHandler("playerLandFailed",landFailed);
			g.addMessageHandler("heatLockout",heatLockout);
			g.addMessageHandler("playerWeaponChangeFailed",weaponChangeFailed);
			g.addMessageHandler("playerEnterWarpJump",initWarpJump);
			g.addMessageHandler("payVaultCreditGain",payVaultCreditGain);
			g.addServiceMessageHandler("clientPrintMsg",printMsg);
			g.addServiceMessageHandler("modWarpToUser",modWarpToUser);
			g.addServiceMessageHandler("chatMsg",chatMsg);
			g.addMessageHandler("chatMsg",chatMsg);
			g.addMessageHandler("clientPrintMsg",printMsg);
			g.addServiceMessageHandler("chatBan",handleChatBan);
			g.addServiceMessageHandler("kicked",handleKicked);
			g.addMessageHandler("syncHeat",syncHeat);
			g.addMessageHandler("changeSkin",changeSkin);
			g.addMessageHandler("newMission",addNewMission);
			g.addMessageHandler("missionExpired",removeMission);
			g.addMessageHandler("addCompletedMission",m_AddCompletedMission);
			g.addMessageHandler("triggerMission",m_TriggerMission);
			g.addMessageHandler("addMissionArtifacts",m_MissionArtifacts);
			g.addMessageHandler("freeCrewJoinOffer",crewJoinOffer);
			g.addMessageHandler("killedPlayerTooManyTimes",tooManyKillsNotify);
			g.addMessageHandler("addWeapon",addWeapon);
			g.addMessageHandler("addSkin",addSkin);
			g.addMessageHandler("playerRotationSpeedChanged",setRotationSpeed);
			g.addMessageHandler("playerSpeedChanged",setSpeed);
			g.addMessageHandler("newEncounter",newEncounter);
			g.addMessageHandler("teleportToPosition",m_teleportToPosition);
			g.addMessageHandler("playerUpdate",onPlayerUpdate);
			g.addMessageHandler("pvpTimeoutWarning",m_pvpTimeout);
			g.addMessageHandler("newWeapon",m_newWeapon);
			g.addMessageHandler("pvpArtifact",m_pickupArtifact);
			g.addServiceMessageHandler("requestUpdateInviteReward",m_requestUpdateInviteReward);
			g.addMessageHandler("addFaction",m_AddFaction);
			g.addMessageHandler("removeFaction",m_RemoveFaction);
			g.addMessageHandler("dropJunk",m_DropJunk);
			g.addMessageHandler("receivedFlux",m_receivedFlux);
			g.addMessageHandler("GiftFlux",m_GiftFlux);
			g.addMessageHandler("uberUpdate",m_UberUpdate);
			g.addMessageHandler("startCloakSelf",m_startCloakSelf);
			g.addMessageHandler("endCloakSelf",m_endCloakSelf);
			g.addMessageHandler("startCloak",m_startCloak);
			g.addMessageHandler("endCloak",m_endCloak);
			g.addMessageHandler("updateCredits",m_updateCredits);
			g.addMessageHandler("softDisconnect",m_softDisconnect);
		}
		
		private function handleChatBan(m:Message) : void
		{
			var _loc2_:int = m.getInt(0);
			isAllChannels = m.getBoolean(1);
			banMinutes = _loc2_;
			TweenMax.delayedCall(60,reduceBanMinutes);
		}
		
		private function handleKicked(m:Message) : void
		{
			g.showMessageDialog("You were kicked out of the game by a moderator");
			g.disconnect();
		}
		
		private function showInvitePopup() : void
		{
			var invButton:FBInvite;
			var invButton2:KongInvite;
			var popup:PopupMessage = new PopupMessage(Localize.t("No thanks!"));
			popup.text = "The game is more fun if played with friends! Would you like to invite someone to join your epic adventure?\n\n\n";
			if(Login.currentState == "facebook")
			{
				invButton = new FBInvite(g);
				invButton.x = g.stage.stageWidth / 2 - 85;
				invButton.y = g.stage.stageHeight / 2;
				invButton.width = 150;
				popup.addChild(invButton);
			}
			else if(Login.currentState == "kongregate")
			{
				invButton2 = new KongInvite(g);
				invButton2.x = g.stage.stageWidth / 2 - 85;
				invButton2.y = g.stage.stageHeight / 2;
				invButton2.width = 150;
				popup.addChild(invButton2);
			}
			g.addChildToOverlay(popup);
			g.creditManager.refresh();
			popup.addEventListener("close",(function():*
			{
				var closePopup:Function;
				return closePopup = function(param1:Event):void
				{
					g.removeChildFromOverlay(popup);
					popup.removeEventListeners();
				};
			})());
		}
		
		private function m_GiftFlux(m:Message) : void
		{
			var type:String;
			var value:int;
			var value2:int;
			var popup:PopupMessage;
			if(g.me != null)
			{
				type = m.getString(0);
				value = m.getInt(1);
				value2 = m.getInt(2);
				if(type == "testRecp")
				{
					popup = new PopupMessage();
					popup.text = "Congratulations Captain! \n\nWell done reaching " + value2 + "! Have " + value + " Flux for free! \nGet yourself something nice! :)";
					g.addChildToOverlay(popup);
					g.creditManager.refresh();
					popup.addEventListener("close",(function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							if(Login.currentState == "facebook" || Login.currentState == "kongregate")
							{
								TweenMax.delayedCall(5,showInvitePopup);
							}
						};
					})());
				}
			}
			g.creditManager.refresh();
		}
		
		private function m_receivedFlux(m:Message) : void
		{
			var popup:PopupMessage;
			var value:int;
			if(g.me != null)
			{
				popup = new PopupMessage();
				value = m.getInt(0);
				popup.text = Localize.t("You have received your " + value + " bonus flux!");
				g.addChildToOverlay(popup);
				g.creditManager.refresh();
				popup.addEventListener("close",(function():*
				{
					var closePopup:Function;
					return closePopup = function(param1:Event):void
					{
						g.removeChildFromOverlay(popup);
						popup.removeEventListeners();
					};
				})());
			}
		}
		
		private function reduceBanMinutes() : void
		{
			banMinutes--;
			if(banMinutes < 1)
			{
				return;
			}
			TweenMax.delayedCall(60,reduceBanMinutes);
		}
		
		private function heatLockout(m:Message) : void
		{
			var _loc2_:Heat = null;
			var _loc3_:Player = g.me;
			if(_loc3_.ship != null)
			{
				_loc2_ = _loc3_.ship.weaponHeat;
				_loc2_.pause(m.getNumber(0));
				_loc2_.setHeat(m.getNumber(1));
			}
		}
		
		private function m_startCloak(m:Message) : void
		{
			var _loc2_:Heading = null;
			var _loc3_:Player = playersById[m.getString(0)];
			if(_loc3_ != null && _loc3_.ship != null)
			{
				_loc3_.ship.isTeleporting = true;
				_loc2_ = _loc3_.ship.course;
				_loc2_.pos.x = 824124;
				_loc2_.pos.y = -725215;
				_loc3_.ship.course = _loc2_;
				_loc3_.ship.x = 824124;
				_loc3_.ship.y = -725215;
			}
		}
		
		private function m_endCloak(m:Message) : void
		{
			var _loc2_:Heading = null;
			var _loc3_:Player = playersById[m.getString(0)];
			if(_loc3_ != null && _loc3_.ship != null)
			{
				_loc2_ = new Heading();
				_loc3_.ship.isTeleporting = false;
				_loc2_.parseMessage(m,1);
				_loc3_.ship.course = _loc2_;
				_loc3_.ship.x = _loc2_.pos.x;
				_loc3_.ship.y = _loc2_.pos.y;
				_loc3_.ship.addToCanvasForReal();
			}
		}
		
		private function m_startCloakSelf(m:Message) : void
		{
			var _loc2_:Heat = null;
			trace("startSelfCloak");
			var _loc3_:Player = g.me;
			if(_loc3_.ship != null)
			{
				_loc2_ = _loc3_.ship.weaponHeat;
				_loc2_.setHeat(m.getNumber(0));
				_loc3_.ship.alpha = 0.1;
			}
		}
		
		private function m_endCloakSelf(m:Message) : void
		{
			trace("endSelfCloak");
			var _loc2_:Player = g.me;
			if(_loc2_.ship != null)
			{
				_loc2_.ship.alpha = 1;
			}
		}
		
		public function update() : void
		{
			for each(var _loc2_ in _players)
			{
				_loc2_.update();
				if(!(_loc2_.ship == null || _loc2_.ship.course == null))
				{
					if(!(!_loc2_.ship.isAddedToCanvas || _loc2_.isLanded))
					{
						if(g.pvpManager == null || !(g.pvpManager is DominationManager))
						{
							_loc2_.inSafeZone = false;
							for each(var _loc1_ in g.bodyManager.bodies)
							{
								_loc1_.setInSafeZone(_loc2_);
							}
						}
					}
				}
			}
		}
		
		private function m_requestUpdateInviteReward(m:Message) : void
		{
			g.send("requestInviteReward");
		}
		
		private function m_pickupArtifact(m:Message) : void
		{
			g.me.pickupArtifact(m);
		}
		
		public function listAll() : void
		{
			for each(var _loc1_ in _players)
			{
				if(!(_loc1_.isDeveloper || _loc1_.isModerator))
				{
					MessageLog.writeChatMsg("list","lvl " + _loc1_.level,_loc1_.id,_loc1_.name);
				}
			}
		}
		
		private function addMe(id:String) : Player
		{
			_me = new Player(g,id);
			_me.isMe = true;
			g.myCargo = new Cargo(g,id);
			g.myCargo.reloadCargoView();
			_playersById[_me.id] = _me;
			_players.push(_me);
			return _me;
		}
		
		private function addPlayer(id:String) : Player
		{
			var _loc2_:Player = new Player(g,id);
			_playersById[id] = _loc2_;
			_players.push(_loc2_);
			_enemyPlayers.push(_loc2_);
			return _loc2_;
		}
		
		public function initPlayer(m:Message, i:int = 0) : int
		{
			var _loc4_:Player = null;
			var _loc3_:String = m.getString(i++);
			if(_loc3_ == g.client.connectUserId)
			{
				_loc4_ = addMe(_loc3_);
			}
			else
			{
				_loc4_ = addPlayer(_loc3_);
			}
			return _loc4_.init(m,i);
		}
		
		public function m_pvpTimeout(m:Message) : void
		{
			var _loc2_:Number = m.getNumber(0);
			g.textManager.createPvpText("Not enough players",0,30);
			g.textManager.createPvpText("Match ending in " + int(_loc2_) + " seconds",-35,30);
		}
		
		public function m_newWeapon(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			Action.unlockWeapon(_loc2_);
		}
		
		public function removePlayer(m:Message) : void
		{
			var _loc2_:int = 0;
			var _loc3_:String = m.getString(0);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc5_:Boolean = m.getBoolean(2);
			if(!_loc5_)
			{
				MessageLog.writeSysInfo(m.getString(1) + " has left the system.");
			}
			if(_loc4_ != null)
			{
				_loc4_.unloadShip();
				delete _playersById[_loc3_];
				_loc2_ = 0;
				while(_loc2_ < _players.length)
				{
					if(_players[_loc2_] == _loc4_)
					{
						_players.splice(_loc2_,1);
						break;
					}
					_loc2_++;
				}
				_loc2_ = 0;
				while(_loc2_ < _enemyPlayers.length)
				{
					if(_enemyPlayers[_loc2_] == _loc4_)
					{
						_enemyPlayers.splice(_loc2_,1);
						break;
					}
					_loc2_++;
				}
				_loc4_.dispose();
			}
		}
		
		private function tooManyKillsNotify(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			MessageLog.writeChatMsg("death","You have killed " + _loc2_ + " more than four times in a row, " + _loc2_ + " can not give more experince untill you kill someone else.");
		}
		
		private function setRotationSpeed(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if(_loc3_ != null)
			{
				_loc3_.rotationSpeedMod = m.getNumber(1);
				if(_loc3_.ship != null && _loc3_.ship.engine != null)
				{
					_loc3_.ship.engine.rotationMod = _loc3_.rotationSpeedMod;
				}
			}
		}
		
		private function setSpeed(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if(_loc3_ != null)
			{
				_loc3_.ship.engine.speed = m.getNumber(1);
			}
		}
		
		private function addWeapon(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc2_:String = m.getString(1);
			if(_loc4_ != null)
			{
				_loc4_.addWeapon(_loc2_);
			}
		}
		
		private function addSkin(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc2_:String = m.getString(1);
			if(_loc4_ != null)
			{
				_loc4_.addNewSkin(_loc2_);
			}
		}
		
		private function spawnDrop(m:Message) : void
		{
			if(g.dropManager != null)
			{
				g.dropManager.spawn(m,0);
			}
		}
		
		private function killed(m:Message) : void
		{
			if(m == null)
			{
				return;
			}
			if(m.length < 4)
			{
				return;
			}
			var _loc4_:String = m.getString(0);
			var _loc5_:String = m.getString(1);
			var _loc2_:String = m.getString(2);
			var _loc6_:String = m.getString(3);
			var _loc3_:int = m.getInt(4);
			if(g.dropManager != null)
			{
				g.dropManager.spawn(m,5);
			}
			var _loc7_:Player = _playersById[_loc4_];
			if(_loc7_ == null)
			{
				return;
			}
			if(_loc7_.ship == null)
			{
				return;
			}
			MessageLog.writeDeathNote(_loc7_,_loc5_,_loc2_);
			if(_loc7_.spree == 4)
			{
				MessageLog.writeChatMsg("death",_loc7_.name + " died after killing 4.");
			}
			else if(_loc7_.spree > 4 && _loc2_ != "suicide")
			{
				MessageLog.writeChatMsg("death",_loc5_ + " ended " + _loc7_.name + "s " + _loc7_.spree + " kills long frenzy!");
			}
			if(_loc7_.isMe && g.solarSystem.isPvpSystemInEditor && _loc2_ != "" && _loc2_ != "Death Line")
			{
				Game.trackEvent("pvp",g.solarSystem.type + " killedBy",_loc2_,_loc7_.level);
			}
			_loc7_.enterKilled(m);
		}
		
		public function xpGain(m:Message, i:int) : void
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			var _loc7_:int = 0;
			var _loc5_:String = null;
			var _loc6_:String = m.getString(i);
			var _loc8_:Player = _playersById[_loc6_];
			if(_loc8_ != null)
			{
				_loc4_ = m.getInt(i + 1);
				_loc3_ = m.getInt(i + 2);
				_loc8_.increaseXp(_loc4_,_loc3_);
				_loc7_ = m.getInt(i + 3);
				_loc8_.setSpree(_loc7_);
				_loc5_ = m.getString(i + 5);
				if(_loc8_ == g.me && _loc5_ != "")
				{
					if(_loc7_ > 15)
					{
						g.textManager.createKillText("You killed " + _loc5_ + "! Godlike!",50,5000,0xffffff);
					}
					else if(_loc7_ > 10)
					{
						g.textManager.createKillText("You killed " + _loc5_ + "! Rampage!",40,5000,0xffffff);
					}
					else if(_loc7_ > 4)
					{
						g.textManager.createKillText("You killed " + _loc5_ + "! Killing Spree!",38,5000,0xffffff);
					}
					else
					{
						g.textManager.createKillText("You killed " + _loc5_ + "!",35,5000,0xffffff);
					}
				}
			}
		}
		
		private function reputationChange(m:Message) : void
		{
			var _loc2_:int = 0;
			var _loc4_:int = 0;
			var _loc3_:String = m.getString(0);
			var _loc5_:Player = _playersById[_loc3_];
			if(_loc5_ != null)
			{
				_loc2_ = m.getInt(1);
				_loc4_ = m.getInt(2);
				_loc5_.updateReputation(_loc2_,_loc4_);
			}
		}
		
		public function xpLoss(m:Message, i:int) : void
		{
			var _loc6_:int = 0;
			var _loc3_:int = 0;
			var _loc4_:String = m.getString(i);
			var _loc5_:Player = _playersById[_loc4_];
			if(_loc5_ != null)
			{
				_loc6_ = m.getInt(i + 1);
				_loc3_ = m.getInt(i + 2);
				_loc5_.decreaseXp(_loc6_,_loc3_);
			}
		}
		
		private function payVaultCreditGain(m:Message) : void
		{
			var creditBox:CreditGainBox;
			var pods:int;
			var type:String = m.getString(1);
			var name:String = "";
			if(m.length > 3)
			{
				name = m.getString(3);
			}
			if(type == "daily")
			{
				creditBox = new DailyRewardMessage(g,m.getInt(0),m.getInt(2));
			}
			else if(type == "missions" || type == "level")
			{
				pods = m.getInt(0);
				creditBox = new CreditGainBox(g,0,pods,type);
				if(pods > 0)
				{
					creditBox.callback = function():void
					{
						g.removeChildFromOverlay(creditBox);
						g.rpc("getPodCount",function(param1:Message):void
						{
							g.hud.updatePodCount(param1.getInt(0));
						});
					};
				}
			}
			else if(type == "pvp")
			{
				name = m.getString(2);
				creditBox = new CreditGainBox(g,m.getInt(0),0,type,name);
			}
			else
			{
				creditBox = new CreditGainBox(g,m.getInt(0),0,type,name);
			}
			g.addChildToOverlay(creditBox);
			if(type == "fbLike")
			{
				g.me.fbLike = true;
			}
			creditBox.addEventListener("close",(function():*
			{
				var close:Function;
				return close = function(param1:Event):void
				{
					g.creditManager.refresh();
					g.hud.buyFluxButton.flash();
					g.removeChildFromOverlay(creditBox);
				};
			})());
		}
		
		private function modWarpToUser(m:Message) : void
		{
			var _loc2_:IJoinRoomManager = null;
			var _loc3_:String = m.getString(0);
			var _loc4_:String = m.getString(1);
			if(_loc3_ != null && _loc3_ != "" && _loc4_ != null)
			{
				MessageLog.writeChatMsg("join_leave","Warping to system: " + _loc3_,"system");
				_loc2_ = JoinRoomLocator.getService();
				_loc2_.desiredRoomId = null;
				_loc2_.desiredSystemType = "friendly";
				_loc2_.desiredRoomId = _loc3_;
				g.send("modWarp","Hyperion");
			}
		}
		
		private function printMsg(m:Message) : void
		{
			var _loc2_:String = "system";
			if(m.length > 1)
			{
				_loc2_ = m.getString(1);
			}
			MessageLog.write(m.getString(0),_loc2_);
		}
		
		private function chatMsg(m:Message) : void
		{
			if(m.length <= 2)
			{
				return printMsg(m);
			}
			var _loc7_:int = 0;
			var _loc3_:String = m.getString(_loc7_++);
			var _loc2_:String = m.getString(_loc7_++);
			var _loc4_:String = m.getString(_loc7_++);
			var _loc5_:String = m.getString(_loc7_++);
			var _loc6_:String = m.getString(_loc7_++);
			var _loc8_:Boolean = m.getBoolean(_loc7_++);
			MessageLog.writeChatMsg(_loc3_,_loc2_,_loc4_,_loc5_,_loc6_,_loc8_);
			if(_loc3_ == "private" && _loc4_ != me.id)
			{
				g.chatInput.lastPrivateReceived = _loc5_;
			}
		}
		
		public function dmgBoost(m:Message, i:int) : void
		{
			var _loc4_:String = m.getString(i);
			var _loc5_:Player = _playersById[_loc4_];
			if(_loc5_ == null || _loc5_.isMe)
			{
				return;
			}
			var _loc3_:PlayerShip = _loc5_.ship;
			if(_loc3_ == null)
			{
				return;
			}
			_loc3_.usingDmgBoost = true;
			_loc3_.dmgBoostEndTime = g.time + _loc3_.dmgBoostDuration;
			_loc3_.damageBoostEffect();
		}
		
		public function hardenShield(m:Message, i:int) : void
		{
			var _loc4_:String = m.getString(i);
			var _loc5_:Player = _playersById[_loc4_];
			if(_loc5_ == null || _loc5_.isMe)
			{
				return;
			}
			var _loc3_:PlayerShip = _loc5_.ship;
			if(_loc3_ == null)
			{
				return;
			}
			_loc3_.usingHardenedShield = true;
			_loc3_.hardenEndTimer = g.time + _loc3_.hardenDuration;
			_loc3_.hardenShieldEffect();
		}
		
		public function convShield(m:Message, i:int) : void
		{
			var _loc5_:String = m.getString(i);
			var _loc6_:Player = _playersById[_loc5_];
			var _loc3_:int = m.getInt(i + 1);
			var _loc7_:int = m.getInt(i + 2);
			if(_loc6_ == null)
			{
				return;
			}
			var _loc4_:PlayerShip = _loc6_.ship;
			if(_loc4_ == null)
			{
				return;
			}
			_loc4_.shieldHp -= _loc3_;
			_loc4_.hp += _loc7_;
			if(_loc6_.ship.hp > _loc4_.hpMax)
			{
				_loc7_ -= _loc4_.hp - _loc4_.hpMax;
				_loc4_.hp = _loc4_.hpMax;
			}
			_loc4_.converShieldEffect();
			g.textManager.createDmgText(-_loc7_,_loc4_);
			if(_loc6_.isMe && g.hud != null)
			{
				g.hud.healthAndShield.update();
			}
		}
		
		public function powerUpHeal(m:Message, i:int) : void
		{
			var _loc6_:String = null;
			var _loc3_:int = 0;
			var _loc5_:int = 0;
			var _loc4_:String = m.getString(i++);
			var _loc7_:Player = _playersById[_loc4_];
			if(_loc7_ != null && _loc7_.ship != null)
			{
				_loc6_ = m.getString(i++);
				_loc3_ = m.getInt(i++);
				_loc5_ = m.getInt(i++);
				_loc7_.ship.hp = m.getInt(i++);
				_loc7_.ship.shieldHp = m.getInt(i++);
				if(_loc6_ == "health" || _loc6_ == "healthSmall")
				{
					g.textManager.createDmgText(-_loc3_,_loc7_.ship,false);
				}
				else
				{
					g.textManager.createDmgText(-_loc5_,_loc7_.ship,true);
				}
				if(_loc7_.isMe)
				{
					g.hud.healthAndShield.update();
				}
			}
		}
		
		public function damaged(m:Message, i:int) : void
		{
			var _loc4_:int = 0;
			var _loc6_:int = 0;
			var _loc3_:String = m.getString(i);
			var _loc5_:Player = _playersById[_loc3_];
			if(_loc5_ != null && _loc5_.ship != null)
			{
				_loc4_ = m.getInt(i + 1);
				_loc6_ = m.getInt(i + 2);
				_loc5_.ship.shieldHp = m.getInt(i + 3);
				_loc5_.ship.hp = m.getInt(i + 4);
				_loc5_.ship.takeDamage(_loc6_);
				if(m.getBoolean(i + 5))
				{
					_loc5_.ship.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8),m.getString(i + 9));
				}
				if(_loc5_.isMe)
				{
					g.hud.healthAndShield.update();
				}
			}
		}
		
		private function landed(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc5_:Player = _playersById[_loc3_];
			var _loc2_:String = m.getString(1);
			if(g.bodyManager == null)
			{
				Console.write("Land failed! Too early g == null");
				return;
			}
			if(_loc5_ == null)
			{
				Console.write("Land failed! Player is null, id: " + _loc3_);
				return;
			}
			if(_loc5_.ship == null)
			{
				Console.write("ship is null");
				return;
			}
			var _loc4_:Body = g.bodyManager.getBodyByKey(_loc2_);
			if(_loc4_ == null)
			{
				Console.write("Land failed! Body is null, bodyKey: " + _loc2_);
				return;
			}
			_loc5_.land(_loc4_);
		}
		
		private function initRoaming(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if(_loc3_ != null)
			{
				_loc3_.initRoaming(m,1);
			}
			else
			{
				Console.write("No player on initRoaming!");
			}
		}
		
		private function landFailed(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc2_:Heading = new Heading();
			_loc2_.parseMessage(m,1);
			_loc4_.loadCourse(_loc2_);
			_loc4_.enterRoaming();
		}
		
		public function get me() : Player
		{
			return _me;
		}
		
		public function get players() : Vector.<Player>
		{
			return _players;
		}
		
		public function get enemyPlayers() : Vector.<Player>
		{
			return _enemyPlayers;
		}
		
		public function get playersById() : Dictionary
		{
			return _playersById;
		}
		
		public function weaponChanged(m:Message, i:int) : void
		{
			var _loc4_:Dictionary = g.playerManager.playersById;
			var _loc3_:String = m.getString(i);
			var _loc5_:Player = _loc4_[_loc3_];
			if(_loc5_ == null)
			{
				return;
			}
			_loc5_.changeWeapon(m,i);
		}
		
		private function weaponChangeFailed(m:Message) : void
		{
			var _loc3_:Dictionary = g.playerManager.playersById;
			var _loc2_:String = m.getString(0);
			var _loc4_:Player = _loc3_[_loc2_];
			if(_loc4_ == null || _loc4_.ship == null)
			{
				return;
			}
			_loc4_.ship.weaponIsChanging = false;
		}
		
		public function trySetActiveWeapons(player:Player, slot:int, key:String) : void
		{
			var _loc8_:Weapon = null;
			var _loc9_:int = 0;
			var _loc5_:int = 0;
			if(player == null || player.ship == null)
			{
				return;
			}
			player.ship.weaponIsChanging = true;
			var _loc10_:* = -1;
			var _loc11_:Vector.<Weapon> = player.ship.weapons;
			var _loc4_:int = 0;
			var _loc7_:Array = [];
			_loc9_ = 0;
			while(_loc9_ < player.unlockedWeaponSlots)
			{
				_loc7_.push(_loc9_ + 1);
				_loc9_++;
			}
			_loc9_ = 0;
			while(_loc9_ < _loc11_.length)
			{
				_loc8_ = _loc11_[_loc9_];
				if(_loc8_.hotkey > 0)
				{
					_loc5_ = int(_loc7_.indexOf(_loc8_.hotkey));
					if(_loc5_ != -1)
					{
						_loc7_.splice(_loc5_,1);
					}
					_loc4_++;
				}
				if(_loc8_.key == key)
				{
					_loc10_ = _loc9_;
				}
				_loc9_++;
			}
			_loc9_ = 0;
			while(_loc9_ < _loc11_.length)
			{
				_loc8_ = _loc11_[_loc9_];
				if(_loc8_.hotkey == slot && _loc9_ != _loc10_)
				{
					_loc7_.push(slot);
					_loc8_.setActive(player.ship,false);
					_loc8_.hotkey = 0;
					player.weaponsHotkeys[_loc9_] = 0;
					player.weaponsState[_loc9_] = false;
				}
				_loc9_++;
			}
			if(slot == -1 && _loc7_.length > 0)
			{
				slot = int(_loc7_[0]);
			}
			if(_loc10_ < 0 || _loc10_ >= _loc11_.length || slot < 0 || slot > player.unlockedWeaponSlots)
			{
				player.ship.weaponIsChanging = false;
				return;
			}
			var _loc6_:Weapon = null;
			if(_loc10_ < _loc11_.length)
			{
				_loc6_ = _loc11_[_loc10_];
			}
			if(_loc6_ == null)
			{
				Console.write("Weapon index is null when tried to set it to active.");
				player.ship.weaponIsChanging = false;
				return;
			}
			if(_loc6_.active)
			{
				_loc6_.setActive(player.ship,false);
				_loc6_.hotkey = 0;
				player.weaponsHotkeys[_loc10_] = 0;
				player.weaponsState[_loc10_] = false;
			}
			if(_loc6_.setActive(player.ship,true))
			{
				_loc6_.hotkey = slot;
				player.weaponsHotkeys[_loc10_] = slot;
				player.weaponsState[_loc10_] = true;
				player.selectedWeaponIndex = _loc10_;
				Console.write("slot: " + slot," Weapon index: " + _loc10_," key: " + key);
			}
			var _loc12_:Message = g.createMessage("trySetActiveWeapons");
			_loc12_.add(_loc10_);
			_loc12_.add(slot);
			_loc12_.add(true);
			g.sendMessage(_loc12_);
		}
		
		public function fire(m:Message, i:int = 0, len:int = 0) : void
		{
			var _loc4_:int = 0;
			var _loc7_:Beam = null;
			var _loc6_:int = 0;
			var _loc12_:String = m.getString(i);
			var _loc8_:int = m.getInt(i + 1);
			var _loc11_:Boolean = m.getBoolean(i + 2);
			var _loc14_:Player = playersById[_loc12_];
			if(_loc14_ == null)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc14_.ship;
			if(_loc5_ == null)
			{
				return;
			}
			var _loc13_:Vector.<Weapon> = _loc14_.ship.weapons;
			if(_loc13_ == null)
			{
				return;
			}
			if(_loc8_ > -1 && _loc8_ < _loc13_.length)
			{
				_loc14_.selectedWeaponIndex = _loc8_;
			}
			var _loc9_:Unit = null;
			if(m.length > len)
			{
				_loc4_ = m.getInt(i + 3);
				if(_loc4_ != -1)
				{
					_loc9_ = g.unitManager.getTarget(_loc4_);
				}
			}
			if(m.length > len)
			{
				if(_loc5_.weaponHeat == null)
				{
					return;
				}
				_loc5_.weaponHeat.setHeat(m.getNumber(i + 4));
			}
			var _loc10_:Weapon = _loc5_.weapon;
			if(_loc10_ == null)
			{
				return;
			}
			_loc10_.fire = _loc11_;
			_loc10_.target = _loc9_;
			if(_loc10_ is Beam)
			{
				_loc7_ = _loc10_ as Beam;
				_loc7_.secondaryTargets = new Vector.<Unit>();
				_loc6_ = i + 5;
				while(_loc6_ < len)
				{
					_loc9_ = g.unitManager.getTarget(m.getInt(_loc6_));
					if(_loc9_ != null)
					{
						_loc7_.secondaryTargets.push(_loc9_);
					}
					_loc6_++;
				}
			}
			else if(m.length > len && len > 5 && !(_loc10_ is Teleport))
			{
				_loc10_.reloadTime = m.getNumber(i + 5);
			}
		}
		
		private function initWarpJump(m:Message) : void
		{
			var _loc9_:String = m.getString(0);
			var _loc2_:Player = playersById[_loc9_];
			if(_loc2_ == null || _loc2_.isWarpJumping)
			{
				return;
			}
			_loc2_.isWarpJumping = true;
			var _loc6_:int = _loc2_.initRoaming(m,1,false);
			var _loc4_:String = m.getString(_loc6_);
			var _loc8_:String = m.getString(_loc6_ + 1);
			var _loc5_:String = m.getString(_loc6_ + 2);
			var _loc7_:IDataManager = DataLocator.getService();
			var _loc3_:Object = _loc7_.loadKey("SolarSystems",_loc4_);
			MessageLog.writeChatMsg("join_leave",_loc2_.name + " warp jumped to " + _loc3_.name);
			if(_loc2_.isMe)
			{
				g.fadeIntoState(new WarpJumpState(g,_loc4_,_loc8_,_loc5_));
			}
			else
			{
				_loc2_.ship.enterWarpJump();
			}
		}
		
		public function updateMission(m:Message, i:int) : void
		{
			var _loc3_:String = m.getString(i);
			var _loc4_:Player = _playersById[_loc3_];
			if(_loc4_ != null && _loc4_.isMe)
			{
				_loc4_.updateMission(m,i + 1);
			}
		}
		
		public function updatePlayerStats(m:Message, i:int) : void
		{
			var _loc3_:PlayerShip = null;
			var _loc4_:String = m.getString(i);
			var _loc5_:Player = _playersById[_loc4_];
			if(_loc5_ != null && _loc5_.ship != null)
			{
				if(_loc5_.isMe)
				{
					return;
				}
				_loc3_ = _loc5_.ship;
				_loc3_.hpMax = m.getInt(i + 1);
				_loc3_.shieldHpMax = m.getInt(i + 2);
				_loc3_.shieldRegen = m.getInt(i + 3);
				_loc3_.armorThreshold = m.getInt(i + 4);
			}
		}
		
		private function syncHeat(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc4_:Player = playersById[_loc3_];
			if(_loc4_ == null)
			{
				return;
			}
			var _loc2_:PlayerShip = _loc4_.ship;
			if(_loc2_ == null)
			{
				return;
			}
			_loc2_.weaponHeat.setHeat(m.getNumber(1));
		}
		
		private function crewJoinOffer(m:Message) : void
		{
			var _loc3_:int = 0;
			var _loc4_:CrewMember = new CrewMember(g);
			var _loc2_:Array = [];
			_loc2_.push(m.getInt(0));
			_loc2_.push(m.getInt(1));
			_loc2_.push(m.getInt(2));
			_loc4_.skills = _loc2_;
			_loc2_ = [];
			_loc3_ = 0;
			while(_loc3_ < 9)
			{
				_loc2_.push(0);
				_loc3_++;
			}
			_loc4_.specials = _loc2_;
			new CrewJoinOffer(g,_loc4_,null,m.getString(3));
		}
		
		private function addNewMission(m:Message) : void
		{
			var _loc2_:Boolean = false;
			var _loc5_:String = m.getString(1);
			if(me.hasMission(m.getString(0)))
			{
				return;
			}
			me.addMission(m,0);
			if(_loc5_ == "KG4YJCr9tU6IH0rJRYo7HQ")
			{
				_loc2_ = false;
				for each(var _loc3_ in g.bodyManager.bodies)
				{
					if(_loc3_.key == "SWqDETtcD0i6Wc3s81yccQ" || _loc3_.key == "U8PYtFoC5U6c2A_gar9j2A" || _loc3_.key == "TLYpHghGOU6FaZtxDiVXBA")
					{
						for each(var _loc4_ in _loc3_.spawners)
						{
							if(_loc4_.alive)
							{
								_loc2_ = true;
								g.hud.compas.addHintArrowByKey(_loc3_.key);
								break;
							}
						}
						if(_loc2_)
						{
							break;
						}
					}
				}
			}
			else if(_loc5_ == "9XyiJ1g9cESeNd0Nlr1FQQ")
			{
				g.hud.compas.addHintArrowByKey("oFryHqwA-0-_rwKhqFdiCA");
			}
			else if(_loc5_ == "adD2AhOuRkSzHkV3WrO3xQ")
			{
				g.hud.compas.addHintArrowByKey("aRJ7Qhctpkyq1FyiXQ8uSQ");
			}
			else if(_loc5_ == "YJ_P6Mr6L0CsKYagk-PCDw")
			{
				g.hud.compas.addHintArrowByKey("Yy5Xu1GjZU6fxe8yqNjEFQ");
			}
			else if(_loc5_ == "R162TWIx1kCr-sH6dLC-Ew" || _loc5_ == "LTtEVCP7IUm_qk6vrlhSmg")
			{
				g.hud.compas.addHintArrowByKey("fkytuRMpyUSciHkBfVXLYw");
			}
			else if(_loc5_ == "FTnXLOVBJEOeutHvbkV1nw")
			{
				g.hud.compas.addHintArrowByKey("tsKIlfSL9EG0CgVY3A5f_A");
			}
			else if(_loc5_ == "zNhe7EvwDk-uh_QVxSQKng" || _loc5_ == "fnXpQicG8Ee36-y67_gWDA")
			{
				g.hud.compas.clear();
			}
			if(g.gameStateMachine.inState(IntroState))
			{
				return;
			}
			g.hud.showNewMissionsButton();
			MissionsList.reload();
		}
		
		private function removeMission(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			me.removeMissionById(_loc2_);
		}
		
		private function changeSkin(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			var _loc3_:Player = playersById[_loc2_];
			if(_loc3_ == null)
			{
				return;
			}
			_loc3_.activeSkin = m.getString(1);
		}
		
		private function newEncounter(m:Message) : void
		{
			g.me.addEncounter(m);
		}
		
		private function onPlayerUpdate(m:Message) : void
		{
			var _loc12_:Unit = null;
			var _loc7_:Boolean = false;
			var _loc3_:int = 0;
			var _loc2_:Weapon = null;
			var _loc5_:int = 0;
			var _loc8_:String = m.getString(_loc5_++);
			var _loc11_:Player = playersById[_loc8_];
			if(_loc11_ == null)
			{
				return;
			}
			var _loc6_:PlayerShip = _loc11_.ship;
			if(_loc6_ == null)
			{
				return;
			}
			_loc6_.hp = m.getInt(_loc5_++);
			_loc6_.shieldHp = m.getInt(_loc5_++);
			if(_loc6_.hp < _loc6_.hpMax || _loc6_.shieldHp < _loc6_.shieldHpMax)
			{
				_loc6_.isInjured = true;
			}
			if(m.length <= _loc5_)
			{
				return;
			}
			var _loc9_:Vector.<Weapon> = _loc11_.ship.weapons;
			if(_loc9_ == null)
			{
				return;
			}
			for each(var _loc4_ in _loc9_)
			{
				_loc4_.fire = false;
				_loc4_.target = null;
			}
			var _loc10_:int = m.getInt(_loc5_++);
			if(_loc10_ > -1 && _loc10_ < _loc9_.length)
			{
				_loc11_.selectedWeaponIndex = _loc10_;
				_loc6_.weaponHeat.setHeat(m.getNumber(_loc5_++));
				_loc12_ = null;
				_loc7_ = m.getBoolean(_loc5_++);
				_loc3_ = m.getInt(_loc5_++);
				if(_loc3_ != -1)
				{
					_loc12_ = g.unitManager.getTarget(_loc3_);
				}
				_loc2_ = _loc6_.weapon;
				_loc2_.fire = _loc7_;
				_loc2_.target = _loc12_;
			}
		}
		
		private function m_teleportToPosition(m:Message) : void
		{
			var line:int;
			var playerId:String;
			var channelingEnd:Number;
			var player:Player;
			var ship:PlayerShip;
			var w:Weapon;
			var p:Projectile;
			var tele:Teleport;
			var stopCourse:Heading;
			var i:int;
			var heading:Heading;
			var timeDiff:Number;
			var emitters:Vector.<Emitter>;
			if(g.isLeaving)
			{
				return;
			}
			line = 0;
			try
			{
				playerId = m.getString(0);
				channelingEnd = m.getNumber(1);
				player = playersById[playerId];
				if(player == null)
				{
					return;
				}
				line++;
				ship = player.ship;
				if(ship == null)
				{
					return;
				}
				ship.isTeleporting = true;
				if(ship.weapon && ship.weapon.fire)
				{
					ship.weapon.fire = false;
				}
				line++;
				for each(w in ship.weapons)
				{
					for each(p in w.projectiles)
					{
						p.ttl = 0;
					}
				}
				if(ship.weapon is Teleport)
				{
					tele = ship.weapon as Teleport;
					tele.updateCooldown();
				}
				line++;
				ship.channelingEnd = channelingEnd;
				stopCourse = new Heading();
				i = stopCourse.parseMessage(m,2);
				ship.course = stopCourse;
				line++;
				heading = new Heading();
				heading.parseMessage(m,i);
				line++;
				timeDiff = (channelingEnd - g.time) / 1000;
				EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A",g,ship.pos.x,ship.pos.y,ship,true);
				line++;
				emitters = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,heading.pos.x,heading.pos.y,null,true);
				TweenMax.delayedCall(timeDiff,function():void
				{
					g.emitterManager.clean(ship);
					line++;
					EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw",g,ship.pos.x,ship.pos.y,ship,true);
					TweenMax.delayedCall(0.24000000000000002,function():void
					{
						line++;
						for each(var _loc1_ in emitters)
						{
							_loc1_.killEmitter();
						}
						line++;
						ship.course = heading;
						ship.isTeleporting = false;
						line++;
						if(ship == g.me.ship)
						{
							g.focusGameObject(g.me.ship,true);
							EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw",g,ship.pos.x,ship.pos.y,ship,true);
						}
						line++;
					});
				});
			}
			catch(e:Error)
			{
				g.client.errorLog.writeError(e.toString(),"teleport failed",e.getStackTrace(),{"line":line});
			}
		}
		
		private function m_AddCompletedMission(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:int = m.getNumber(1);
			g.me.addCompletedMission(_loc3_,_loc2_);
		}
		
		private function m_AddFaction(m:Message) : void
		{
			if(g.me != null)
			{
				g.me.factions.push(m.getString(0));
			}
		}
		
		private function m_RemoveFaction(m:Message) : void
		{
			var _loc3_:Player = null;
			var _loc2_:String = null;
			var _loc4_:int = 0;
			if(g.me != null)
			{
				_loc3_ = g.me;
				_loc2_ = m.getString(0);
				_loc4_ = 0;
				while(_loc4_ < _loc3_.factions.length)
				{
					if(_loc3_.factions[_loc4_] == _loc2_)
					{
						_loc3_.factions.splice(_loc4_,1);
						return;
					}
					_loc4_++;
				}
			}
		}
		
		private function m_TriggerMission(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			g.me.addTriggeredMission(_loc2_);
			var _loc3_:Object = g.dataManager.loadKey("MissionTypes",_loc2_);
			if(_loc3_.majorType == "time")
			{
				g.tutorial.showFoundNewTimeMission(_loc3_);
			}
			else
			{
				g.tutorial.showFoundNewStaticMission(_loc3_);
			}
		}
		
		public function troonGain(m:Message, i:int) : void
		{
			var playerKey:String = m.getString(i++);
			var player:Player = playersById[playerKey];
			var troons:Number = m.getNumber(i++);
			player.troons += troons;
			if(!player.isMe)
			{
				return;
			}
			TweenMax.delayedCall(1.2,function():void
			{
				g.textManager.createTroonsText(troons);
			});
		}
		
		private function m_MissionArtifacts(m:Message) : void
		{
			me.pickupArtifacts(m);
		}
		
		private function m_DropJunk(m:Message) : void
		{
			g.dropManager.spawn(m);
		}
		
		private function m_UberUpdate(m:Message) : void
		{
			g.hud.uberStats.update(m);
		}
		
		private function m_updateCredits(m:Message) : void
		{
			g.creditManager.refresh();
		}
		
		private function m_softDisconnect(m:Message) : void
		{
			g.softDisconnect(m.getString(0));
		}
	}
}

