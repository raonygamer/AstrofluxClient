package {
	import flash.utils.getTimer;
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class Clock extends EventDispatcher {
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
		
		public function Clock(connection:Connection, client:Client) {
			super();
			this.connection = connection;
			this.client = client;
			maxDeltas = 10;
			beginning = getTimer();
		}
		
		public function start() : void {
			deltas = [];
			lockedInServerTime = false;
			responsePending = false;
			connection.addMessageHandler("serverTime",onServerTime);
			requestServerTime();
		}
		
		private function requestServerTime() : void {
			if(!responsePending) {
				connection.send("timeRequest",client.connectUserId);
				responsePending = true;
				timeRequestSent = getTimer();
			}
		}
		
		private function onServerTime(m:Message) : void {
			responsePending = false;
			var _local2:Number = m.getNumber(0);
			addTimeDelta(timeRequestSent,getTimer(),_local2);
			if(deltas.length == maxDeltas) {
				dispatchEvent(new Event("clockReady"));
				connection.removeMessageHandler("serverTime",onServerTime);
			} else {
				requestServerTime();
			}
		}
		
		public function getServerTime() : Number {
			var _local1:Number = getTimer();
			return _local1 + syncTimeDelta;
		}
		
		public function addTimeDelta(clientSendTime:Number, clientReceiveTime:Number, serverTime:Number) : void {
			var _local5:Number = (clientReceiveTime - clientSendTime) / 2;
			var _local7:Number = serverTime - clientReceiveTime;
			var _local4:Number = _local7 + _local5;
			var _local6:TimeDelta = new TimeDelta(_local5,_local4);
			deltas.push(_local6);
			if(deltas.length > maxDeltas) {
				deltas.shift();
			}
			recalculate();
		}
		
		private function recalculate() : void {
			var _local2:Number = NaN;
			var _local3:Array = deltas.slice(0);
			_local3.sort(compare);
			var _local1:Number = determineMedian(_local3);
			pruneOutliers(_local3,_local1,1.5);
			latency = determineAverageLatency(_local3);
			if(!lockedInServerTime) {
				_local2 = determineAverage(_local3);
				syncTimeDelta = Math.round(_local2);
				lockedInServerTime = deltas.length == maxDeltas;
			}
		}
		
		private function determineAverage(arr:Array) : Number {
			var _local4:Number = NaN;
			var _local3:TimeDelta = null;
			var _local2:Number = 0;
			_local4 = 0;
			while(_local4 < arr.length) {
				_local3 = arr[_local4];
				_local2 += _local3.timeSyncDelta;
				_local4++;
			}
			return _local2 / arr.length;
		}
		
		private function determineAverageLatency(arr:Array) : Number {
			var _local5:Number = NaN;
			var _local3:TimeDelta = null;
			var _local2:Number = 0;
			_local5 = 0;
			while(_local5 < arr.length) {
				_local3 = arr[_local5];
				_local2 += _local3.latency;
				_local5++;
			}
			var _local4:Number = _local2 / arr.length;
			latencyError = Math.abs(TimeDelta(arr[arr.length - 1]).latency - _local4);
			return _local4;
		}
		
		private function pruneOutliers(arr:Array, median:Number, threshold:Number) : void {
			var _local5:Number = NaN;
			var _local4:TimeDelta = null;
			var _local6:Number = median * threshold;
			_local5 = arr.length - 1;
			while(_local5 >= 0) {
				_local4 = arr[_local5];
				if(_local4.latency <= _local6) {
					break;
				}
				arr.splice(_local5,1);
				_local5--;
			}
		}
		
		private function determineMedian(arr:Array) : Number {
			var _local2:Number = NaN;
			if(arr.length % 2 == 0) {
				_local2 = arr.length / 2 - 1;
				return (arr[_local2].latency + arr[_local2 + 1].latency) / 2;
			}
			_local2 = Math.floor(arr.length / 2);
			return arr[_local2].latency;
		}
		
		private function compare(a:TimeDelta, b:TimeDelta) : Number {
			if(a.latency < b.latency) {
				return -1;
			}
			if(a.latency > b.latency) {
				return 1;
			}
			return 0;
		}
		
		public function get time() : Number {
			var _local1:Number = getTimer();
			return _local1 + syncTimeDelta;
		}
		
		public function get elapsedTime() : Number {
			return getTimer() - beginning;
		}
	}
}

