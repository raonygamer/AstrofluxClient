package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.scene.Game;
	import facebook.FB;
	import starling.events.Event;
	
	public class FBInviteUnlock extends Button
	{
		private var g:Game;
		
		private var nrReq:int;
		
		private var successCallBack:Function;
		
		private var failCallBack:Function;
		
		public function FBInviteUnlock(g:Game, nrReq:int, successCallBack:Function, failCallBack:Function)
		{
			this.g = g;
			this.nrReq = nrReq;
			this.successCallBack = successCallBack;
			this.failCallBack = failCallBack;
			super(invite,"or Invite " + nrReq + " Friends","highlight");
		}
		
		public function setNrRequired(nrReq:int) : void
		{
			this.nrReq = nrReq;
			tf.text = "or Invite " + nrReq + " Friends";
		}
		
		public function invite(e:Event) : void
		{
			var _loc2_:Object = {};
			_loc2_.method = "apprequests";
			_loc2_.message = "Play together with your friends, explore a vast universe, kill epic space monsters!";
			_loc2_.title = "Come play Astroflux with me!";
			_loc2_.filters = ["app_non_users"];
			FB.ui(_loc2_,onUICallback);
		}
		
		private function onUICallback(result:Object) : void
		{
			if(result == null)
			{
				failCallBack();
				return;
			}
			var _loc2_:Array = [];
			_loc2_ = result.to as Array;
			if(_loc2_.length >= nrReq)
			{
				successCallBack();
				Game.trackEvent("FBinvite","unlock invite sent","to " + _loc2_.length.toString() + " users",_loc2_.length);
			}
			else
			{
				failCallBack();
			}
		}
	}
}

