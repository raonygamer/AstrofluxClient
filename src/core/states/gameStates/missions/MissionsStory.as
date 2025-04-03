package core.states.gameStates.missions
{
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MissionsStory extends Sprite
	{
		private var g:Game;
		
		public function MissionsStory(g:Game)
		{
			super();
			this.g = g;
			var _loc2_:MissionsList = new MissionsList(g);
			_loc2_.loadStoryMissions();
			_loc2_.drawMissions();
			addChild(_loc2_);
		}
		
		override public function dispose() : void
		{
			super.dispose();
			ToolTip.disposeType("missionView");
		}
	}
}

