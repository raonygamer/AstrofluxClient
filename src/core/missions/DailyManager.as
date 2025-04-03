package core.missions
{
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.missions.Daily;
	import playerio.Message;
	
	public class DailyManager
	{
		private var g:Game;
		
		public var resetTime:Number;
		
		public function DailyManager(g:Game)
		{
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("dailyMissionsProgress",m_updateProgress);
			g.addMessageHandler("dailyMissionsComplete",m_setComplete);
			g.addMessageHandler("dailyMissionsReset",m_reset);
			g.addMessageHandler("dailyMissionArtifact",m_addArtifactReward);
		}
		
		public function initDailyMissionsFromMessage(m:Message, startIndex:int) : int
		{
			var _loc3_:Daily = null;
			var _loc6_:Object = g.dataManager.loadTable("DailyMissions");
			for(var _loc7_ in _loc6_)
			{
				g.me.dailyMissions.push(new Daily(_loc7_,_loc6_[_loc7_]));
			}
			resetTime = m.getNumber(startIndex);
			var _loc4_:int = m.getInt(startIndex + 1);
			var _loc5_:int = startIndex + 2;
			while(_loc4_ > 0)
			{
				_loc3_ = getDaily(m.getString(_loc5_++));
				if(_loc3_)
				{
					_loc3_.status = m.getInt(_loc5_++);
					_loc3_.progress = m.getInt(_loc5_++);
				}
				else
				{
					_loc5_ += 2;
				}
				_loc4_--;
			}
			return _loc5_;
		}
		
		private function getDaily(key:String) : Daily
		{
			for each(var _loc2_ in g.me.dailyMissions)
			{
				if(_loc2_.key == key)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		private function m_updateProgress(m:Message) : void
		{
			var _loc4_:String = m.getString(0);
			var _loc3_:int = m.getInt(1);
			var _loc2_:Daily = getDaily(_loc4_);
			if(_loc2_)
			{
				_loc2_.progress = _loc3_;
				g.textManager.createDailyUpdate(_loc2_.name + " " + Math.floor(_loc3_ / _loc2_.missionGoal * 100) + "%");
			}
		}
		
		private function m_setComplete(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:Daily = getDaily(_loc3_);
			if(_loc2_)
			{
				_loc2_.status = 1;
				g.hud.missionsButton.hintFinished();
				g.textManager.createDailyUpdate("Daily complete!");
			}
		}
		
		private function m_reset(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:Daily = getDaily(_loc3_);
			if(_loc2_)
			{
				_loc2_.status = 0;
				_loc2_.progress = 0;
			}
		}
		
		public function addReward(m:Message) : void
		{
			var _loc5_:int = 0;
			var _loc4_:String = null;
			var _loc2_:String = null;
			var _loc3_:int = 0;
			if(g.me == null || g.myCargo == null)
			{
				return;
			}
			_loc5_ = 0;
			while(_loc5_ < m.length)
			{
				_loc4_ = m.getString(_loc5_);
				_loc2_ = m.getString(_loc5_ + 1);
				_loc3_ = m.getInt(_loc5_ + 2);
				if(_loc4_ != "xp")
				{
					g.myCargo.addItem("Commodities",_loc2_,_loc3_);
					g.hud.resourceBox.update();
				}
				_loc5_ += 3;
			}
		}
		
		private function m_addArtifactReward(m:Message) : void
		{
			var _loc2_:Player = g.me;
			if(_loc2_ == null)
			{
				return;
			}
			g.me.pickupArtifact(m);
		}
	}
}

