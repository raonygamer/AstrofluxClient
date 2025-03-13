package core.hud.components.chat {
	import core.scene.Game;
	import feathers.controls.Label;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class ChatSimple extends Sprite {
		private var g:Game;
		private var tf:Label;
		private var maxLines:int = 10;
		private var nextTimeout:Number = 0;
		
		public function ChatSimple(g:Game) {
			super();
			this.g = g;
			tf = new Label();
			tf.styleName = "chat";
			tf.minWidth = 5 * 60;
			tf.maxWidth = 500;
			addChild(tf);
			addEventListener("addedToStage",updateTexts);
		}
		
		public function update(e:Event = null) : void {
			if(nextTimeout != 0 && nextTimeout < g.time) {
				updateTexts();
			}
		}
		
		public function updateTexts(e:Event = null) : void {
			var _local4:Object = null;
			var _local3:Vector.<Object> = MessageLog.textQueue;
			var _local2:String = "\n";
			var _local6:int = _local3.length - 1;
			var _local5:int = 0;
			_local6;
			while(_local6 >= 0) {
				_local4 = _local3[_local6];
				if(_local4.timeout < g.time) {
					break;
				}
				if(!g.messageLog.isMuted(_local4.type)) {
					_local5++;
					_local2 = _local4.text + "\n" + _local2;
					nextTimeout = _local4.nextTimeout;
					if(_local5 > maxLines) {
						break;
					}
				}
				_local6--;
			}
			if(tf.text != _local2) {
				tf.text = _local2;
			}
		}
	}
}

