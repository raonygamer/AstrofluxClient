package core.deathLine {
	import core.hud.components.Line;
	import core.scene.Game;
	import flash.geom.Point;
	
	public class DeathLine extends Line {
		private var g:Game;
		public var nextDistanceCalculation:Number = -1;
		private var distanceToCamera:Number = 0;
		public var id:String = "";
		
		public function DeathLine(g:Game, color:uint = 16777215, alpha:Number = 1) {
			super("line2");
			init("line2",6,color,alpha,true);
			this.g = g;
			this.visible = false;
		}
		
		public function update() : void {
			if(nextDistanceCalculation <= 0) {
				updateIsNear();
			} else {
				nextDistanceCalculation -= 33;
			}
		}
		
		public function updateIsNear() : void {
			if(g.me.ship == null) {
				return;
			}
			var _local5:Point = g.camera.getCameraCenter();
			var _local6:Number = x - _local5.x;
			var _local7:Number = y - _local5.y;
			var _local4:Number = toX - _local5.x;
			var _local2:Number = toY - _local5.y;
			var _local3:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(Math.min(_local6 * _local6 + _local7 * _local7,_local4 * _local4 + _local2 * _local2));
			var _local1:Number = distanceToCamera - _local3;
			nextDistanceCalculation = _local1 / (10 * 60) * 1000;
			visible = distanceToCamera < _local3;
		}
		
		public function lineIntersection(x3:Number, y3:Number, x4:Number, y4:Number, targetRadius:Number) : Boolean {
			var _local7:Number = toY - y;
			var _local20:Number = x - toX;
			var _local6:Number = y4 - y3;
			var _local9:Number = x3 - x4;
			var _local10:Number = _local7 * _local9 - _local6 * _local20;
			if(_local10 == 0) {
				return false;
			}
			var _local18:Number = _local7 * x + _local20 * y;
			var _local19:Number = _local6 * x3 + _local9 * y3;
			var _local11:Number = (_local9 * _local18 - _local20 * _local19) / _local10;
			var _local8:Number = (_local7 * _local19 - _local6 * _local18) / _local10;
			var _local14:Number = Math.min(x,toX);
			var _local13:Number = Math.max(x,toX);
			var _local15:Number = Math.min(y,toY);
			var _local12:Number = Math.max(y,toY);
			if(_local11 < _local14 - targetRadius || _local11 > _local13 + targetRadius || _local8 < _local15 - targetRadius || _local8 > _local12 + targetRadius) {
				return false;
			}
			var _local22:Number = Math.min(x3,x4);
			var _local17:Number = Math.max(x3,x4);
			var _local21:Number = Math.min(y3,y4);
			var _local16:Number = Math.max(y3,y4);
			if(_local11 < _local22 - targetRadius || _local11 > _local17 + targetRadius || _local8 < _local21 - targetRadius || _local8 > _local16 + targetRadius) {
				return false;
			}
			return true;
		}
		
		public function lineIntersection2(px:Number, py:Number, x4:Number, y4:Number, targetRadius:Number) : Boolean {
			var _local13:Number = Math.min(x,toX);
			var _local9:Number = Math.max(x,toX);
			var _local14:Number = Math.min(y,toY);
			var _local8:Number = Math.max(y,toY);
			if(px < _local13 - targetRadius || px > _local9 + targetRadius || py < _local14 - targetRadius || py > _local8 + targetRadius) {
				return false;
			}
			var _local12:Number = toX - x;
			var _local11:Number = toY - y;
			var _local10:Number = Math.sqrt(_local12 * _local12 + _local11 * _local11);
			_local12 /= _local10;
			_local11 /= _local10;
			var _local6:Number = x - px;
			var _local7:Number = y - py;
			var _local15:Number = _local6 * _local12 + _local7 * _local11;
			var _local16:Number = Math.sqrt(Math.pow(_local6 - _local15 * _local12,2) + Math.pow(_local7 - _local15 * _local11,2));
			return _local16 < targetRadius;
		}
	}
}

