package core.group
{
	import core.hud.components.chat.MessageLog;
	import core.player.Invite;
	import core.player.Player;
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	import starling.events.EventDispatcher;
	
	public class GroupManager extends EventDispatcher
	{
		private var g:Game;
		private var _groups:Vector.<Group>;
		private var _invites:Vector.<Invite>;
		
		public function GroupManager(g:Game)
		{
			super();
			this.g = g;
			_groups = new Vector.<Group>();
			_invites = new Vector.<Invite>();
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("addToGroup",addToGroup);
			g.addMessageHandler("removeFromGroup",removeFromGroup);
			g.addMessageHandler("addGroupInvite",addGroupInvite);
			g.addMessageHandler("cancelGroupInvite",cancelGroupInvite);
		}
		
		public function get groups() : Vector.<Group>
		{
			return _groups;
		}
		
		private function addToGroup(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:String = m.getString(1);
			var _loc4_:Player = g.playerManager.playersById[_loc2_];
			if(_loc4_ == null)
			{
				Console.write("Add to group failed, player is null! Key: " + _loc2_);
				return;
			}
			var _loc5_:Group = getGroupById(_loc3_);
			if(_loc5_ == null)
			{
				Console.write("Created new group, id: " + _loc3_);
				_loc5_ = new Group(g,_loc3_);
				_groups.push(_loc5_);
			}
			if(_loc4_ == g.me || _loc5_ == g.me.group)
			{
				removeInvites();
			}
			_loc5_.addPlayer(_loc4_);
			dispatchEventWith("update");
		}
		
		public function autoJoinOrCreateGroup(player:Player, id:String) : void
		{
			var _loc3_:Group = getGroupById(id);
			if(_loc3_ == null)
			{
				_loc3_ = new Group(g,id);
				_groups.push(_loc3_);
			}
			_loc3_.addPlayer(player);
			dispatchEventWith("update");
		}
		
		private function removeFromGroup(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:String = m.getString(1);
			var _loc4_:Group = getGroupById(_loc3_);
			if(_loc4_ == null)
			{
				Console.write("Group doesn\'t exist on remove.");
				return;
			}
			var _loc5_:Player = g.playerManager.playersById[_loc2_];
			if(_loc5_ == null)
			{
				Console.write("Remove from group failed, player is null! Key: " + _loc2_);
				return;
			}
			_loc5_.group = new Group(g,_loc5_.id);
			_loc4_.removePlayer(_loc5_);
			if(_loc4_.length == 0)
			{
				_groups.splice(_groups.indexOf(_loc4_),1);
			}
			dispatchEventWith("update");
		}
		
		private function addGroupInvite(m:Message) : void
		{
			var _loc4_:String = m.getString(0);
			var _loc3_:String = m.getString(1);
			var _loc2_:String = m.getString(2);
			var _loc5_:Player = g.playerManager.playersById[_loc3_];
			var _loc8_:Group = getGroupById(_loc4_);
			if(_loc5_ == null)
			{
				Console.write("Invite failed, invited player is null! Key: " + _loc3_);
				return;
			}
			var _loc6_:Player = g.playerManager.playersById[_loc2_];
			if(_loc6_ == null)
			{
				Console.write("Invite failed, inviter is null! Key: " + _loc2_);
				return;
			}
			if(findInvite(_loc4_,_loc5_) != null)
			{
				Console.write("player is already invited. Name: " + _loc5_.name);
				return;
			}
			var _loc7_:Invite = new Invite(g,_loc4_,_loc5_,_loc6_);
			_loc7_.x = 100;
			_loc7_.y = 100;
			_invites.push(_loc7_);
			g.hud.playerListButton.hintNew();
			MessageLog.write(_loc6_.name + " has invited you to a group. Type <FONT COLOR=\'#44ff44\'>/y</FONT> to accept");
			dispatchEventWith("update");
		}
		
		public function findInvite(groupId:String, invited:Player) : Invite
		{
			for each(var _loc3_ in _invites)
			{
				if(_loc3_.id == groupId && invited == _loc3_.invited)
				{
					return _loc3_;
				}
			}
			return null;
		}
		
		private function removeInvites() : void
		{
			_invites.splice(0,_invites.length);
		}
		
		public function acceptGroupInvite(id:String = null) : void
		{
			if(id == null && _invites.length > 0)
			{
				id = _invites[_invites.length - 1].id;
			}
			if(id != null)
			{
				g.send("acceptGroupInvite",id);
			}
		}
		
		public function cancelGroupInvite(id:String) : void
		{
			var _loc3_:int = 0;
			var _loc2_:Invite = null;
			_loc3_ = _invites.length - 1;
			while(_loc3_ > -1)
			{
				_loc2_ = _invites[_loc3_];
				if(_loc2_.id == id)
				{
					_invites.splice(_invites.indexOf(_loc2_),1);
				}
				_loc3_--;
			}
			g.send("cancelGroupInvite",id);
		}
		
		public function getGroupById(id:String) : Group
		{
			for each(var _loc2_ in _groups)
			{
				if(_loc2_.id == id)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function invitePlayer(player:Player) : void
		{
			g.send("inviteToGroup",player.id);
		}
		
		public function leaveGroup() : void
		{
			g.send("leaveGroup");
		}
	}
}

