package core.hud.components.credits {
	import core.hud.components.Button;
	import core.scene.Game;
	import facebook.FB;
	import playerio.Message;
	import starling.events.Event;
	
	public class FBInvite extends Button {
		private var g:Game;
		
		public function FBInvite(g:Game) {
			this.g = g;
			super(invite,"Invite friends","positive");
		}
		
		public function invite(e:Event) : void {
			var _local2:Object = {};
			_local2.method = "apprequests";
			_local2.message = "Play together with your friends, explore a vast universe, kill epic space monsters!";
			_local2.title = "Come play Astroflux with me!";
			_local2.filters = ["app_non_users"];
			FB.ui(_local2,onUICallback);
		}
		
		private function onUICallback(result:Object) : void {
			var _local3:Message = null;
			var _local5:int = 0;
			var _local2:String = null;
			if(result == null) {
				return;
			}
			var _local4:Array = [];
			_local4 = result.to as Array;
			if(_local4.length > 0) {
				_local3 = g.createMessage("FBinvitedUsers");
				_local5 = 0;
				while(_local5 < _local4.length) {
					_local2 = _local4[_local5];
					_local2 = "fb" + _local2;
					_local3.add(_local2);
					_local5++;
				}
				g.sendMessage(_local3);
				Game.trackEvent("FBinvite","invite sent","to " + _local4.length.toString() + " users",_local4.length);
			}
		}
	}
}

