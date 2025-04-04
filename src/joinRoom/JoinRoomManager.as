package joinRoom
{
	import com.adobe.crypto.MD5;
	import core.hud.components.dialogs.PopupMessage;
	import core.hud.components.starMap.StarMap;
	import core.player.Player;
	import core.scene.Game;
	import core.states.SceneStateMachine;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import feathers.core.FocusManager;
	import generics.GUID;
	import generics.Localize;
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import startSetup.StartSetup;
	
	public class JoinRoomManager extends EventDispatcher implements IJoinRoomManager
	{
		private var stage:Stage;
		private var client:Client;
		private var serviceConnection:Connection;
		private var connection:Connection;
		private var room:Room;
		private var roomStateMachine:SceneStateMachine;
		private var dataManager:IDataManager;
		private var joinData:Object;
		private var playerInfo:Object = {};
		private var _desiredRoomId:String = null;
		private var _desiredSystemType:String = "friendly";
		private var inited:Boolean = false;
		private var session:String = GUID.create();
		private var login:Login;
		
		public function JoinRoomManager(client:Client, stage:Stage, joinData:Object, login:Login)
		{
			super();
			this.client = client;
			this.joinData = joinData;
			this.stage = stage;
			this.login = login;
			dataManager = DataLocator.getService();
			roomStateMachine = new SceneStateMachine(stage);
		}
		
		public static function getServiceRoomID(index:int) : String
		{
			return "Service-1388_" + index;
		}
		
		public function init() : void
		{
			if(inited)
			{
				client.errorLog.writeError("Tried to init joinroom more than once.","","",{});
				return;
			}
			Console.write("Joinroom init.");
			inited = true;
			StartSetup.showProgressText(Localize.t("List service room"));
			client.multiplayer.listRooms("service",null,1000,0,handleServiceRooms,function(param1:PlayerIOError):void
			{
				showErrorDialog("Listing of service room failed.",true);
			});
		}
		
		private function handleServiceRooms(rooms:Array) : void
		{
			var _loc4_:String = null;
			var _loc5_:RoomInfo = null;
			var _loc2_:Room = new Room();
			_loc2_.roomType = "service";
			var _loc6_:Array = [];
			for each(var _loc3_ in rooms)
			{
				_loc4_ = _loc3_.id.substr(8,4);
				if((int(_loc4_)) >= 1388)
				{
					_loc2_.id = _loc3_.id;
					_loc6_.push(_loc3_);
				}
			}
			StartSetup.showProgressText(Localize.t("Joining service room"));
			if(_loc6_.length == 0)
			{
				return joinServiceRoom(getServiceRoomID(0));
			}
			if(_loc6_.length == 1)
			{
				_loc5_ = _loc6_[0];
				if(_loc5_.onlineUsers < 950)
				{
					return joinServiceRoom(_loc5_.id);
				}
			}
			login.selectServiceRoom(_loc6_,joinServiceRoom);
		}
		
		public function joinServiceRoom(id:String) : void
		{
			login.removeEffects();
			client.multiplayer.createJoinRoom(id,"service",true,{},{"client_version":1388},handleJoinServiceRoom,function(param1:PlayerIOError):void
			{
				if(param1.errorID != 2)
				{
					showErrorDialog("Join service room failed, please try again later. Contact us on Astroflux Discord for support.",true,param1);
				}
			});
		}
		
		private function handleJoinServiceRoom(serviceConnection:Connection) : void
		{
			StartSetup.showProgressText(Localize.t("Joined service room"));
			FocusManager.setEnabledForStage(stage,false);
			this.serviceConnection = serviceConnection;
			serviceConnection.addMessageHandler("error",function(param1:Message):void
			{
				showErrorDialog(param1.getString(0));
			});
			serviceConnection.addMessageHandler("joined",onJoinedServiceRoom);
		}
		
		private function onJoinedServiceRoom(m:Message) : void
		{
			serviceConnection.removeMessageHandler("joined",onJoinedServiceRoom);
			var _loc2_:int = 0;
			playerInfo = {};
			playerInfo.key = m.getString(_loc2_++);
			playerInfo.level = m.getInt(_loc2_++);
			playerInfo.split = m.getString(_loc2_++);
			playerInfo.musicVolume = m.getNumber(_loc2_++);
			playerInfo.effectVolume = m.getNumber(_loc2_++);
			playerInfo.xp = m.getInt(_loc2_++);
			playerInfo.enemyKills = m.getInt(_loc2_++);
			playerInfo.bossKills = m.getInt(_loc2_++);
			playerInfo.suicides = m.getInt(_loc2_++);
			playerInfo.troons = m.getNumber(_loc2_++);
			playerInfo.enemyEncounters = m.getInt(_loc2_++);
			playerInfo.bossEncounters = m.getInt(_loc2_++);
			playerInfo.exploredPlanets = m.getInt(_loc2_++);
			playerInfo.systemType = m.getString(_loc2_++);
			playerInfo.currentRoom = m.getString(_loc2_++);
			playerInfo.currentRoomId = m.getString(_loc2_++);
			playerInfo.currentSolarSystem = m.getString(_loc2_++);
			playerInfo.systemType = m.getString(_loc2_++);
			playerInfo.clan = m.getString(_loc2_++);
			joinData["client_version"] = 1388;
			joinData["session"] = session;
			joinData["warpJump"] = false;
			joinData["level"] = playerInfo.level > 0 ? playerInfo.level : 1;
			_desiredSystemType = playerInfo.systemType != "" ? playerInfo.systemType : "friendly";
			_desiredRoomId = playerInfo.currentRoomId != "" ? playerInfo.currentRoomId : null;
			dispatchEventWith("joinedServiceRoom",true,playerInfo);
		}
		
		public function rpcServiceRoom(type:String, handler:Function, ... rest) : void
		{
			var m:Message;
			var i:int;
			var args:Array = rest;
			serviceConnection.addMessageHandler(type,(function():*
			{
				var rpcHandler:Function;
				return rpcHandler = function(param1:Message):void
				{
					serviceConnection.removeMessageHandler(type,rpcHandler);
					handler(param1);
				};
			})());
			m = serviceConnection.createMessage(type);
			i = 0;
			while(i < args.length)
			{
				m.add(args[i]);
				i++;
			}
			serviceConnection.sendMessage(m);
		}
		
		public function joinCurrentSolarSystem() : void
		{
			var _loc1_:String = "HrAjOBivt0SHPYtxKyiB_Q";
			if(playerInfo.currentSolarSystem)
			{
				_loc1_ = playerInfo.currentSolarSystem;
				if(playerInfo.currentRoomId != "")
				{
					_desiredRoomId = playerInfo.currentRoomId;
				}
				if(_desiredSystemType == "clan")
				{
					if(playerInfo.clan != "")
					{
						_desiredRoomId = MD5.hash(playerInfo.currentSolarSystem + playerInfo.clan);
					}
					else
					{
						_desiredSystemType = "friendly";
						_desiredRoomId = null;
					}
				}
				if(_desiredSystemType == "survival" || _loc1_ == "ic3w-BxdMU6qWhX9t3_EaA")
				{
					_loc1_ = "DU6zMqKBIUGnUWA9eVVD-g";
					_desiredSystemType = "friendly";
					_desiredRoomId = null;
				}
			}
			if(dataManager.loadKey("SolarSystems",_loc1_) == null)
			{
				_loc1_ = "HrAjOBivt0SHPYtxKyiB_Q";
			}
			joinGame(_loc1_,joinData);
		}
		
		public function joinGame(solarSystemKey:String, joinData:Object) : void
		{
			var roomType:String;
			var dataManager:IDataManager;
			var solarSystemObj:Object;
			var roomData:Object;
			var searchCriteria:Object;
			joinData["client_version"] = 1388;
			joinData["session"] = session;
			roomStateMachine.closeCurrentRoom();
			roomType = "game";
			Console.write("Trying to join " + roomType + " room");
			dataManager = DataLocator.getService();
			solarSystemObj = dataManager.loadKey("SolarSystems",solarSystemKey);
			roomData = {};
			roomData.solarSystemKey = solarSystemKey;
			roomData.service = serviceConnection.roomId;
			roomData.pvpAboveCap = joinData.level > solarSystemObj.pvpLvlCap;
			roomData.systemType = _desiredSystemType;
			Console.write("roomData.systemType " + roomData.systemType);
			room = new Room();
			room.roomType = roomType;
			room.data = roomData;
			room.joinData = joinData;
			if(!_desiredRoomId)
			{
				searchCriteria = {
					"solarSystemKey":solarSystemKey,
					"service":serviceConnection.roomId
				};
				StartSetup.showProgressText("Getting game rooms");
				client.multiplayer.listRooms(room.roomType,searchCriteria,1000,0,handleRooms,function(param1:PlayerIOError):void
				{
					Console.write("Error: " + param1);
				});
			}
			else
			{
				room.id = _desiredRoomId;
				createJoin();
			}
		}
		
		private function handleRooms(rooms:Array) : void
		{
			var _loc5_:* = false;
			var _loc2_:* = false;
			var _loc3_:int = 15;
			for each(var _loc4_ in rooms)
			{
				if(int(_loc4_.data.version) >= 1388)
				{
					if(_loc4_.data.systemType == room.data.systemType)
					{
						if(_loc4_.onlineUsers < _loc3_)
						{
							if(_loc4_.data.modLocked != "true")
							{
								if(_loc4_.data.modClosed != "true")
								{
									if(room.data.systemType == "deathmatch" || room.data.systemType == "domination" || room.data.systemType == "arena")
									{
										room.id = _loc4_.id;
										break;
									}
									_loc5_ = _loc4_.data.systemType != "hostile";
									if(_loc5_)
									{
										room.id = _loc4_.id;
										break;
									}
									_loc2_ = _loc4_.data.pvpAboveCap == "true";
									if(_loc2_ == room.data.pvpAboveCap)
									{
										room.id = _loc4_.id;
										break;
									}
								}
							}
						}
					}
				}
			}
			if(_desiredRoomId)
			{
				room.id = _desiredRoomId;
			}
			createJoin();
		}
		
		private function createJoin() : void
		{
			Console.write("Attempting to create/join room.");
			StartSetup.showProgressText("Joining game room");
			client.multiplayer.createJoinRoom(room.id,room.roomType,false,room.data,room.joinData,handleJoin,function(param1:PlayerIOError):void
			{
				Console.write(param1);
			});
		}
		
		private function handleJoin(connection:Connection) : void
		{
			StartSetup.showProgressText("Joining game room");
			this.connection = connection;
			roomStateMachine.changeRoom(new Game(client,serviceConnection,connection,room));
			Console.write("Sucessfully connected to the multiplayer server");
		}
		
		public function tryWarpJumpToFriend(player:Player, destination:String, successCallback:Function, failedCallback:Function) : void
		{
			var searchCriteria:Object;
			if(!_desiredRoomId || _desiredSystemType == "clan")
			{
				successCallback();
				return;
			}
			searchCriteria = {"solarSystemKey":destination};
			client.multiplayer.listRooms("game",searchCriteria,100,0,(function():*
			{
				var onFound:Function;
				return onFound = function(param1:Array):void
				{
					var _loc3_:RoomInfo = null;
					var _loc5_:int = 0;
					_loc5_ = 0;
					while(_loc5_ < param1.length)
					{
						if(param1[_loc5_].id == _desiredRoomId)
						{
							_loc3_ = param1[_loc5_];
							break;
						}
						_loc5_++;
					}
					if(_loc3_ == null)
					{
						failedCallback("Friend instance not found");
						return;
					}
					if(_loc3_.data.systemType == "clan" && _loc3_.id != MD5.hash(_loc3_.data.solarSystemKey + player.clanId))
					{
						failedCallback("Your friend is in a private clan instance.");
						return;
					}
					var _loc6_:* = _loc3_.data.systemType == "hostile";
					if(!_loc6_)
					{
						successCallback();
						return;
					}
					if(StarMap.selectedSolarSystem.pvpLvlCap == 0)
					{
						_desiredSystemType = "hostile";
						successCallback();
						return;
					}
					var _loc4_:* = _loc3_.data.pvpAboveCap == "true";
					var _loc2_:* = player.level > StarMap.selectedSolarSystem.pvpLvlCap;
					if(_loc4_ == _loc2_)
					{
						_desiredSystemType = "hostile";
						successCallback();
						return;
					}
					if(_loc4_)
					{
						failedCallback("This room only allows players over level " + (StarMap.selectedSolarSystem.pvpLvlCap + 1));
					}
					else
					{
						failedCallback("This room only allows players under level " + StarMap.selectedSolarSystem.pvpLvlCap);
					}
				};
			})(),(function():*
			{
				var onError:Function;
				return onError = function(param1:PlayerIOError):void
				{
				};
			})());
		}
		
		private function showErrorDialog(m:String, sendToErrorLog:Boolean = false, e:PlayerIOError = null, closeCallback:Function = null, hideButton:Boolean = false) : void
		{
			var s:String;
			var prop:String;
			var dialog:PopupMessage = new PopupMessage();
			if(hideButton)
			{
				dialog.closeButton.visible = false;
			}
			dialog.text = m;
			stage.addChild(dialog);
			dialog.addEventListener("close",function(param1:Event):void
			{
				dialogClose(param1);
				if(closeCallback != null)
				{
					closeCallback();
				}
			});
			s = "";
			if(e != null && e.message != null)
			{
				s = e.name + ": " + e.message;
			}
			for(prop in joinData)
			{
				s += "[" + prop + "=" + joinData[prop] + "],";
			}
			if(sendToErrorLog)
			{
				client.errorLog.writeError(m,s,"",{});
			}
		}
		
		private function dialogClose(e:Event) : void
		{
			var _loc2_:Sprite = e.target as Sprite;
			if(stage != null && stage.contains(_loc2_))
			{
				stage.removeChild(_loc2_);
			}
		}
		
		public function set desiredRoomId(value:String) : void
		{
			_desiredRoomId = value;
		}
		
		public function get desiredRoomId() : String
		{
			return _desiredRoomId;
		}
		
		public function set desiredSystemType(value:String) : void
		{
			_desiredSystemType = value;
		}
		
		public function get desiredSystemType() : String
		{
			return _desiredSystemType;
		}
	}
}

