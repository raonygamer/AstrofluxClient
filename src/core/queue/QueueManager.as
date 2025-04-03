package core.queue
{
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.Event;
	
	public class QueueManager
	{
		public static const TYPE_PVP:String = "pvp";
		
		public static const TYPE_PVP_DM:String = "pvp dm";
		
		public static const TYPE_PVP_DOMINATION:String = "pvp dom";
		
		public static const TYPE_PVP_ARENA:String = "pvp arena";
		
		public static const TYPE_PVP_ARENA_RANKED:String = "pvp arena ranked";
		
		public static const TYPE_PVP_RANDOM:String = "pvp random";
		
		public static const TYPE_INSTANCE:String = "instance";
		
		public var g:Game;
		
		public var queues:Vector.<QueueInfoHolder>;
		
		public function QueueManager(g:Game)
		{
			super();
			this.g = g;
			queues = new Vector.<QueueInfoHolder>();
			queues.push(new QueueInfoHolder(g,"pvp random"));
			g.addServiceMessageHandler("QueueJoinSuccess",joinedQueue);
			g.addServiceMessageHandler("QueueJoinFailed",joinFailed);
			g.addServiceMessageHandler("QueueLeaveSuccess",leftQueue);
			g.addServiceMessageHandler("QueueLeaveFailed",leaveFailed);
			g.addServiceMessageHandler("QueueReady",queueReady);
			g.addServiceMessageHandler("JoinMatch",joinMatch);
			g.addServiceMessageHandler("QueueRemoved",removedFromQueue);
			g.rpcServiceRoom("RequestQueueInfo",handleQueueInfo);
		}
		
		public function handleQueueInfo(m:Message) : void
		{
			var _loc4_:int = 0;
			var _loc6_:String = null;
			var _loc2_:Boolean = false;
			var _loc5_:Number = NaN;
			var _loc3_:QueueInfoHolder = null;
			_loc4_ = 0;
			while(_loc4_ < m.length - 2)
			{
				_loc6_ = m.getString(_loc4_);
				_loc2_ = m.getBoolean(_loc4_ + 1);
				_loc5_ = m.getNumber(_loc4_ + 2);
				if(_loc2_)
				{
					_loc3_ = getQueue(_loc6_);
					_loc3_.isInQueue = true;
					_loc3_.isWaiting = false;
					_loc3_.isReady = false;
					_loc3_.accepted = false;
					_loc3_.startTime = _loc5_;
				}
				_loc4_ += 3;
			}
		}
		
		public function removedFromAllQueues() : void
		{
			for each(var _loc1_ in queues)
			{
				_loc1_.isInQueue = false;
				_loc1_.isWaiting = false;
				_loc1_.isReady = false;
			}
		}
		
		public function removedFromQueue(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == _loc3_)
				{
					_loc2_.isInQueue = false;
					_loc2_.isWaiting = false;
					_loc2_.isReady = false;
				}
			}
		}
		
		public function queueReady(m:Message) : void
		{
			var _loc3_:int = 0;
			var _loc4_:String = m.getString(0);
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == _loc4_)
				{
					_loc3_ = Math.ceil(0.001 * (g.time - _loc2_.startTime));
					if(_loc3_ > 0 && _loc3_ < 1000000)
					{
						Game.trackEvent("pvp","queue","ready",_loc3_);
					}
					_loc2_.startTime = g.time;
					_loc2_.isInQueue = false;
					_loc2_.isWaiting = false;
					_loc2_.isReady = true;
					_loc2_.createAcceptPopup();
					break;
				}
			}
		}
		
		public function joinMatch(m:Message) : void
		{
			var _loc2_:String = m.getString(0);
			var _loc4_:String = m.getString(1);
			var _loc3_:String = m.getString(2);
			g.tryJoinMatch(_loc4_,_loc3_);
		}
		
		public function joinedQueue(m:Message) : void
		{
			var errorPopup:PopupMessage;
			var qi:QueueInfoHolder;
			var type:String = m.getString(0);
			var reason:String = m.getString(1);
			var resetOthers:Boolean = m.getBoolean(2);
			if(reason != null && reason != "")
			{
				errorPopup = new PopupMessage();
				errorPopup.text = reason;
				g.addChildToOverlay(errorPopup);
				errorPopup.addEventListener("close",(function():*
				{
					var closePopup:Function;
					return closePopup = function(param1:Event):void
					{
						g.removeChildFromOverlay(errorPopup);
						errorPopup.removeEventListeners();
					};
				})());
			}
			for each(qi in queues)
			{
				if(qi.type == type)
				{
					qi.startTime = g.time;
					qi.isInQueue = true;
					qi.isWaiting = false;
					qi.isReady = false;
					qi.accepted = false;
					qi.startTime = g.time;
				}
			}
		}
		
		public function joinFailed(m:Message) : void
		{
			var errorPopup:PopupMessage;
			var qi:QueueInfoHolder;
			var type:String = m.getString(0);
			var reason:String = m.getString(1);
			if(reason != null && reason != "")
			{
				errorPopup = new PopupMessage();
				errorPopup.text = reason;
				g.addChildToOverlay(errorPopup);
				errorPopup.addEventListener("close",(function():*
				{
					var closePopup:Function;
					return closePopup = function(param1:Event):void
					{
						g.removeChildFromOverlay(errorPopup);
						errorPopup.removeEventListeners();
					};
				})());
			}
			for each(qi in queues)
			{
				if(qi.type == type)
				{
					qi.isWaiting = false;
					qi.isInQueue = false;
					qi.accepted = false;
					qi.isReady = false;
					qi.update();
				}
			}
		}
		
		public function update() : void
		{
			for each(var _loc1_ in queues)
			{
				_loc1_.update();
			}
		}
		
		public function leftQueue(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == _loc3_)
				{
					_loc2_.isInQueue = false;
					_loc2_.isWaiting = false;
					_loc2_.isReady = false;
				}
			}
		}
		
		public function leaveFailed(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == _loc3_)
				{
					_loc2_.isInQueue = false;
					_loc2_.isWaiting = false;
					_loc2_.isReady = false;
				}
			}
		}
		
		public function getQueue(type:String) : QueueInfoHolder
		{
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == type)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		private function containsQueue(type:String) : Boolean
		{
			for each(var _loc2_ in queues)
			{
				if(_loc2_.type == type)
				{
					return true;
				}
			}
			return false;
		}
	}
}

