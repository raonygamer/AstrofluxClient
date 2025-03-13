package core.missions {
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.missions.Daily;
	import playerio.Message;
	
	public class DailyManager {
		private var g:Game;
		public var resetTime:Number;
		
		public function DailyManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("dailyMissionsProgress",m_updateProgress);
			g.addMessageHandler("dailyMissionsComplete",m_setComplete);
			g.addMessageHandler("dailyMissionsReset",m_reset);
			g.addMessageHandler("dailyMissionArtifact",m_addArtifactReward);
		}
		
		public function initDailyMissionsFromMessage(m:Message, startIndex:int) : int {
			var _local5:Daily = null;
			var _local4:Object = g.dataManager.loadTable("DailyMissions");
			for(var _local6 in _local4) {
				g.me.dailyMissions.push(new Daily(_local6,_local4[_local6]));
			}
			resetTime = m.getNumber(startIndex);
			var _local3:int = m.getInt(startIndex + 1);
			var _local7:int = startIndex + 2;
			while(_local3 > 0) {
				_local5 = getDaily(m.getString(_local7++));
				if(_local5) {
					_local5.status = m.getInt(_local7++);
					_local5.progress = m.getInt(_local7++);
				} else {
					_local7 += 2;
				}
				_local3--;
			}
			return _local7;
		}
		
		private function getDaily(key:String) : Daily {
			for each(var _local2 in g.me.dailyMissions) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		private function m_updateProgress(m:Message) : void {
			var _local4:String = m.getString(0);
			var _local2:int = m.getInt(1);
			var _local3:Daily = getDaily(_local4);
			if(_local3) {
				_local3.progress = _local2;
				g.textManager.createDailyUpdate(_local3.name + " " + Math.floor(_local2 / _local3.missionGoal * 100) + "%");
			}
		}
		
		private function m_setComplete(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:Daily = getDaily(_local3);
			if(_local2) {
				_local2.status = 1;
				g.hud.missionsButton.hintFinished();
				g.textManager.createDailyUpdate("Daily complete!");
			}
		}
		
		private function m_reset(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:Daily = getDaily(_local3);
			if(_local2) {
				_local2.status = 0;
				_local2.progress = 0;
			}
		}
		
		public function addReward(m:Message) : void {
			var _local5:int = 0;
			var _local4:String = null;
			var _local3:String = null;
			var _local2:int = 0;
			if(g.me == null || g.myCargo == null) {
				return;
			}
			_local5 = 0;
			while(_local5 < m.length) {
				_local4 = m.getString(_local5);
				_local3 = m.getString(_local5 + 1);
				_local2 = m.getInt(_local5 + 2);
				if(_local4 != "xp") {
					g.myCargo.addItem("Commodities",_local3,_local2);
					g.hud.resourceBox.update();
				}
				_local5 += 3;
			}
		}
		
		private function m_addArtifactReward(m:Message) : void {
			var _local2:Player = g.me;
			if(_local2 == null) {
				return;
			}
			g.me.pickupArtifact(m);
		}
	}
}

