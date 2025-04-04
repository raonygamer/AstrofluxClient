package core.hud.components.playerList
{
	import core.group.Group;
	import core.player.Player;
	import core.scene.Game;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class GroupListItem extends Sprite
	{
		private var g:Game;
		private var group:Group;
		private var playerListItems:Vector.<PlayerListItem>;
		private var separator:Quad;
		
		public function GroupListItem(g:Game, group:Group)
		{
			var _loc5_:int = 0;
			var _loc3_:Player = null;
			var _loc4_:PlayerListItem = null;
			playerListItems = new Vector.<PlayerListItem>();
			separator = new Quad(620,2,0x666666);
			super();
			this.g = g;
			this.group = group;
			_loc5_ = 0;
			while(_loc5_ < group.length)
			{
				_loc3_ = group.players[_loc5_];
				_loc4_ = new PlayerListItem(g,_loc3_,640,60);
				_loc4_.x = 0;
				_loc4_.y = 5 + _loc5_ * (60);
				addChild(_loc4_);
				playerListItems.push(_loc4_);
				_loc5_++;
			}
			if(group.length > 0)
			{
				separator.x = 0;
				separator.y = height;
				separator.alpha = 0.7;
				addChild(separator);
			}
			else
			{
				removeChild(separator);
			}
		}
		
		override public function get height() : Number
		{
			return group.length * (60) + 5;
		}
		
		override public function dispose() : void
		{
			removeChildren(0,-1,true);
			playerListItems = null;
		}
	}
}

