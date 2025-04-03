package {
	import flash.utils.getTimer;
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class Clock extends EventDispatcher
	{
		public static const CLOCK_READY:String = "clockReady";
		
		private var connection:Connection;
		
		private var client:Client;
		
		private var deltas:Array;
		
		private var responsePending:Boolean;
		
		private var lockedInServerTime:Boolean;
		
		private var timeRequestSent:Number;
		
		private var syncTimeDelta:Number = 0;
		
		private var maxDeltas:Number;
		
		private var latencyError:Number;
		
		public var latency:Number;
		
		private var beginning:Number;
		
		public function Clock(connection:Connection, client:Client)
		{
			super();
			this.connection = connection;
			this.client = client;
			maxDeltas = 10;
			beginning = getTimer();
		}
		
		public function start() : void
		{
			deltas = [];
			lockedInServerTime = false;
			responsePending = false;
			connection.addMessageHandler("serverTime",onServerTime);
			requestServerTime();
		}
		
		private function requestServerTime() : void
		{
			if(!responsePending)
			{
				connection.send("timeRequest",client.connectUserId);
				responsePending = true;
				timeRequestSent = getTimer();
			}
		}
		
		private function onServerTime(m:Message) : void
		{
			responsePending = false;
			var _loc2_:Number = m.getNumber(0);
			addTimeDelta(timeRequestSent,getTimer(),_loc2_);
			if(deltas.length == maxDeltas)
			{
				dispatchEvent(new Event("clockReady"));
				connection.removeMessageHandler("serverTime",onServerTime);
			}
			else
			{
				requestServerTime();
			}
		}
		
		public function getServerTime() : Number
		{
			var _loc1_:Number = getTimer();
			return _loc1_ + syncTimeDelta;
		}
		
		public function addTimeDelta(clientSendTime:Number, clientReceiveTime:Number, serverTime:Number) : void
		{
			var _loc4_:Number = (clientReceiveTime - clientSendTime) / 2;
			var _loc6_:Number = serverTime - clientReceiveTime;
			var _loc7_:Number = _loc6_ + _loc4_;
			var _loc5_:TimeDelta = new TimeDelta(_loc4_,_loc7_);
			deltas.push(_loc5_);
			if(deltas.length > maxDeltas)
			{
				deltas.shift();
			}
			recalculate();
		}
		
		private function recalculate() : void
		{
			var _loc1_:Number = NaN;
			var _loc3_:Array = deltas.slice(0);
			_loc3_.sort(compare);
			var _loc2_:Number = determineMedian(_loc3_);
			pruneOutliers(_loc3_,_loc2_,1.5);
			latency = determineAverageLatency(_loc3_);
			if(!lockedInServerTime)
			{
				_loc1_ = determineAverage(_loc3_);
				syncTimeDelta = Math.round(_loc1_);
				lockedInServerTime = deltas.length == maxDeltas;
			}
		}
		
		private function determineAverage(arr:Array) : Number
		{
			var _loc4_:Number = NaN;
			var _loc2_:TimeDelta = null;
			var _loc3_:Number = 0;
			_loc4_ = 0;
			while(_loc4_ < arr.length)
			{
				_loc2_ = arr[_loc4_];
				_loc3_ += _loc2_.timeSyncDelta;
				_loc4_++;
			}
			return _loc3_ / arr.length;
		}
		
		private function determineAverageLatency(arr:Array) : Number
		{
			var _loc4_:Number = NaN;
			var _loc2_:TimeDelta = null;
			var _loc3_:Number = 0;
			_loc4_ = 0;
			while(_loc4_ < arr.length)
			{
				_loc2_ = arr[_loc4_];
				_loc3_ += _loc2_.latency;
				_loc4_++;
			}
			var _loc5_:Number = _loc3_ / arr.length;
			latencyError = Math.abs(TimeDelta(arr[arr.length - 1]).latency - _loc5_);
			return _loc5_;
		}
		
		private function pruneOutliers(arr:Array, median:Number, threshold:Number) : void
		{
			var _loc6_:Number = NaN;
			var _loc4_:TimeDelta = null;
			var _loc5_:Number = median * threshold;
			_loc6_ = arr.length - 1;
			while(_loc6_ >= 0)
			{
				_loc4_ = arr[_loc6_];
				if(_loc4_.latency <= _loc5_)
				{
					break;
				}
				arr.splice(_loc6_,1);
				_loc6_--;
			}
		}
		
		private function determineMedian(arr:Array) : Number
		{
			var _loc2_:Number = NaN;
			if(arr.length % 2 == 0)
			{
				_loc2_ = arr.length / 2 - 1;
				return (arr[_loc2_].latency + arr[_loc2_ + 1].latency) / 2;
			}
			_loc2_ = Math.floor(arr.length / 2);
			return arr[_loc2_].latency;
		}
		
		private function compare(a:TimeDelta, b:TimeDelta) : Number
		{
			if(a.latency < b.latency)
			{
				return -1;
			}
			if(a.latency > b.latency)
			{
				return 1;
			}
			return 0;
		}
		
		public function get time() : Number
		{
			var _loc1_:Number = getTimer();
			return _loc1_ + syncTimeDelta;
		}
		
		public function get elapsedTime() : Number
		{
			return getTimer() - beginning;
		}
	}
}

