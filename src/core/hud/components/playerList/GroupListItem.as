package core.hud.components.playerList {
	import core.group.Group;
	import core.player.Player;
	import core.scene.Game;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class GroupListItem extends Sprite {
		private var g:Game;
		private var group:Group;
		private var playerListItems:Vector.<PlayerListItem>;
		private var separator:Quad;
		
		public function GroupListItem(g:Game, group:Group) {
			var _local5:int = 0;
			var _local4:Player = null;
			var _local3:PlayerListItem = null;
			playerListItems = new Vector.<PlayerListItem>();
			separator = new Quad(620,2,0x666666);
			super();
			this.g = g;
			this.group = group;
			_local5 = 0;
			while(_local5 < group.length) {
				_local4 = group.players[_local5];
				_local3 = new PlayerListItem(g,_local4,640,60);
				_local3.x = 0;
				_local3.y = 5 + _local5 * (60);
				addChild(_local3);
				playerListItems.push(_local3);
				_local5++;
			}
			if(group.length > 0) {
				separator.x = 0;
				separator.y = height;
				separator.alpha = 0.7;
				addChild(separator);
			} else {
				removeChild(separator);
			}
		}
		
		override public function get height() : Number {
			return group.length * (60) + 5;
		}
		
		override public function dispose() : void {
			removeChildren(0,-1,true);
			playerListItems = null;
		}
	}
}

