package core.hud.components {
	import core.scene.Game;
	import starling.display.MeshBatch;
	
	public class BeamLine extends MeshBatch {
		private var period:int = 100;
		public var nodeFrequence:int;
		public var thickness:Number;
		public var amplitude:Number;
		private var ampFactor:Number;
		private var glowWidth:Number;
		private var glowColor:Number;
		private var _color:uint;
		private var lineTexture:String;
		private var lines:Vector.<Line> = new Vector.<Line>();
		private var g:Game;
		
		public function BeamLine(g:Game) {
			super();
			this.g = g;
		}
		
		public function init(thickness:Number = 3, nodeFrequence:int = 3, amplitude:Number = 2, color:uint = 16777215, alpha:Number = 1, glowWidth:Number = 3, glowColor:uint = 16711680, lineTexture:String = "line2") : void {
			this.thickness = thickness * 2;
			this.nodeFrequence = nodeFrequence;
			this.amplitude = amplitude;
			this.ampFactor = ampFactor;
			this.alpha = alpha;
			this.glowWidth = glowWidth;
			this.glowColor = glowColor;
			this.lineTexture = lineTexture;
			this.blendMode = "add";
			_color = color;
			this.touchable = true;
		}
		
		public function lineTo(toX:Number, toY:Number, chargeUpEffect:Number = 1) : void {
			var _local14:int = 0;
			var _local9:Line = null;
			var _local8:int = 0;
			var _local6:Line = null;
			var _local16:Number = NaN;
			var _local15:Number = NaN;
			var _local5:Number = toX - x;
			var _local13:Number = toY - y;
			var _local4:Number = _local5 * _local5 + _local13 * _local13;
			var _local10:Number = Math.sqrt(_local4);
			var _local7:Number = Math.round(_local10 / period * nodeFrequence);
			if(_local7 == 0) {
				_local7 = 1;
			}
			if(_local7 > lines.length) {
				_local8 = _local7 - lines.length;
				_local14 = 0;
				while(_local14 < _local8) {
					_local9 = g.linePool.getLine();
					_local9.init(lineTexture,thickness,color,1,true);
					_local9.blendMode = "add";
					lines.push(_local9);
					_local14++;
				}
			} else if(_local7 < lines.length) {
				_local14 = _local7;
				while(_local14 < lines.length) {
					g.linePool.removeLine(lines[_local14]);
					_local14++;
				}
				lines.length = _local7;
			}
			super.clear();
			var _local12:* = 0;
			var _local11:* = 0;
			_local14 = 0;
			while(_local14 < lines.length) {
				_local6 = lines[_local14];
				_local16 = 2 - Math.abs((_local7 / 2 - _local14) / _local7) * 2;
				_local6.x = _local12;
				_local6.y = _local11;
				_local15 = (_local14 + 1) / _local7;
				_local12 = _local5 * _local15 + (amplitude - Math.random() * amplitude * 2) * _local16;
				_local11 = _local13 * _local15 + (amplitude - Math.random() * amplitude * 2) * _local16;
				if(_local14 == _local7 - 1) {
					_local12 = _local5;
					_local11 = _local13;
				}
				_local6.lineTo(_local12,_local11);
				_local6.thickness = thickness + chargeUpEffect;
				this.addMesh(_local6);
				_local14++;
			}
		}
		
		override public function set touchable(value:Boolean) : void {
			var _local3:int = 0;
			var _local2:Line = null;
			_local3 = 0;
			while(_local3 < lines.length) {
				_local2 = lines[0];
				_local2.touchable = value;
				_local3++;
			}
			super.touchable = value;
		}
		
		override public function clear() : void {
			var _local1:int = 0;
			super.clear();
			_local1 = 0;
			while(_local1 < lines.length) {
				g.linePool.removeLine(lines[_local1]);
				_local1++;
			}
			lines.length = 0;
		}
		
		override public function set color(value:uint) : void {
			var _local3:int = 0;
			var _local2:Line = null;
			_local3 = 0;
			while(_local3 < lines.length) {
				_local2 = lines[_local3];
				_local2.color = value;
				_local3++;
			}
			_color = value;
		}
		
		override public function get color() : uint {
			return _color;
		}
	}
}

