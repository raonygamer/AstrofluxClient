package core.controlZones {
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.DatabaseObject;
	import playerio.Message;
	
	public class ControlZoneManager {
		public static var claimData:Message;
		private var g:Game;
		public var controlZones:Vector.<ControlZone> = new Vector.<ControlZone>();
		
		public function ControlZoneManager(g:Game) {
			super();
			this.g = g;
		}
		
		private function onZoneClaimed(m:Message) : void {
			claimData = m;
		}
		
		public function init() : void {
			if(!g.isSystemTypeHostile()) {
				return;
			}
			if(g.me.clanId == "") {
				return;
			}
			load();
		}
		
		public function load(callback:Function = null) : void {
			if(controlZones.length > 0) {
				if(Boolean(callback)) {
					callback();
					return;
				}
				return;
			}
			g.dataManager.loadRangeFromBigDB("ControlZones","ByPlayer",null,function(param1:Array):void {
				onGetControlZones(param1);
				if(Boolean(callback)) {
					callback();
				}
			});
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("updateControlZones",onUpdateControlZones);
			g.addMessageHandler("zoneClaimed",onZoneClaimed);
			g.addServiceMessageHandler("updateClaimedZone",onUpdateClaimedZone);
		}
		
		private function onGetControlZones(zonesArray:Array) : void {
			var _local5:int = 0;
			var _local4:DatabaseObject = null;
			var _local2:ControlZone = null;
			controlZones.length = 0;
			var _local3:int = int(zonesArray.length);
			_local5 = 0;
			while(_local5 < _local3) {
				_local4 = zonesArray[_local5];
				_local2 = new ControlZone();
				_local2.key = _local4.key;
				_local2.claimTime = _local4.claimTime;
				_local2.releaseTime = _local4.releaseTime;
				_local2.playerKey = _local4.player;
				_local2.clanKey = _local4.clan;
				_local2.clanName = _local4.clanName;
				_local2.clanLogo = _local4.clanLogo;
				_local2.clanColor = _local4.clanColor;
				_local2.solarSystemKey = _local4.solarSystem;
				_local2.troonsPerMinute = _local4.troonsPerMinute;
				controlZones.push(_local2);
				_local5++;
			}
		}
		
		public function onUpdateControlZones(m:Message) : void {
			g.sendToServiceRoom("updateControlZones");
		}
		
		public function onUpdateClaimedZone(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local4:ControlZone = getZoneByKey(_local3);
			if(_local4 != null) {
				controlZones.splice(controlZones.indexOf(_local4),1);
			}
			var _local5:int = 1;
			var _local2:ControlZone = new ControlZone();
			_local2.key = _local3;
			_local2.claimTime = m.getNumber(_local5++);
			_local2.releaseTime = m.getNumber(_local5++);
			_local2.playerKey = m.getString(_local5++);
			_local2.clanKey = m.getString(_local5++);
			_local2.clanName = m.getString(_local5++);
			_local2.clanLogo = m.getString(_local5++);
			_local2.clanColor = m.getUInt(_local5++);
			_local2.solarSystemKey = m.getString(_local5++);
			_local2.troonsPerMinute = m.getInt(_local5++);
			controlZones.push(_local2);
			g.hud.clanButton.updateTroons();
		}
		
		public function getZoneByKey(key:String) : ControlZone {
			var _local3:int = 0;
			var _local2:ControlZone = null;
			_local3 = 0;
			while(_local3 < controlZones.length) {
				_local2 = controlZones[_local3];
				if(_local2.key == key) {
					return _local2;
				}
				_local3++;
			}
			return null;
		}
		
		public function getTotalTroonsPerMinute(clanKey:String) : int {
			var _local4:int = 0;
			var _local2:ControlZone = null;
			var _local3:int = 0;
			_local4 = 0;
			while(_local4 < controlZones.length) {
				_local2 = controlZones[_local4];
				if(clanKey == _local2.clanKey) {
					_local3 += _local2.troonsPerMinute;
				}
				_local4++;
			}
			return _local3;
		}
		
		public function getTopTroonsPerMinuteClans() : Vector.<Object> {
			var controlZone:ControlZone;
			var sortedArray:Vector.<Object>;
			var prop:String;
			var topTroonsPerMinuteDict:Dictionary = new Dictionary();
			for each(controlZone in controlZones) {
				if(topTroonsPerMinuteDict[controlZone.clanKey] == null) {
					topTroonsPerMinuteDict[controlZone.clanKey] = {};
					topTroonsPerMinuteDict[controlZone.clanKey].key = controlZone.clanKey;
					topTroonsPerMinuteDict[controlZone.clanKey].name = controlZone.clanName;
					topTroonsPerMinuteDict[controlZone.clanKey].logo = controlZone.clanLogo;
					topTroonsPerMinuteDict[controlZone.clanKey].color = controlZone.clanColor;
					topTroonsPerMinuteDict[controlZone.clanKey].troons = 0;
				}
				topTroonsPerMinuteDict[controlZone.clanKey].troons += controlZone.troonsPerMinute;
			}
			sortedArray = new Vector.<Object>();
			for(prop in topTroonsPerMinuteDict) {
				sortedArray.push(topTroonsPerMinuteDict[prop]);
			}
			sortedArray.sort(function(param1:Object, param2:Object):int {
				return param2.troons - param1.troons;
			});
			return sortedArray;
		}
	}
}

