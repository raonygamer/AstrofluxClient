package startSetup {
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class StartShipBaseStats extends Sprite {
		private var skinObj:Object;
		private var speed:int;
		private var tweenDelay:Number = 0.7;
		
		public function StartShipBaseStats(skinObj:Object, speed:int) {
			super();
			this.skinObj = skinObj;
			this.speed = speed;
			var _local4:int = 7;
			var _local3:int = 27;
			addStat("statHealth","Health",_local4);
			_local4 += _local3;
			addStat("statArmor","Armor",_local4);
			_local4 += _local3;
			addStat("statShield","Shield",_local4);
			_local4 += _local3;
			addStat("statShieldRegen","Speed",_local4);
			_local4 += _local3;
			addWeapon(_local4);
		}
		
		private function addWeapon(yPos:int) : void {
			var _local5:int = 0;
			var _local3:Object = null;
			var _local4:Text = null;
			var _local2:Text = null;
			_local5 = 0;
			while(_local5 < skinObj.upgrades.length - 1) {
				_local3 = skinObj.upgrades[_local5];
				if(_local3.table == "Weapons") {
					_local4 = new Text();
					_local4.y = yPos;
					_local4.text = "WEAPON:";
					_local4.size = 12;
					_local4.color = 16689475;
					addChild(_local4);
					_local2 = new Text();
					_local2.y = yPos;
					_local2.x = 114;
					_local2.text = _local3.name.toUpperCase();
					_local2.size = 12;
					_local2.color = 54271;
					addChild(_local2);
					return;
				}
				_local5++;
			}
		}
		
		private function addStat(type:String, name:String, yPos:int) : void {
			var _local6:int = 0;
			var _local7:int = 0;
			var _local5:Quad = null;
			var _local4:Text = new Text();
			_local4.y = yPos;
			_local4.text = name.toUpperCase() + ":";
			_local4.size = 12;
			_local4.color = 16689475;
			addChild(_local4);
			if(name == "Speed") {
				_local6 = speed;
			} else {
				_local6 = int(skinObj[type]);
			}
			_local7 = 0;
			while(_local7 < 10) {
				_local5 = new Quad(12,12,54271);
				_local5.alpha = 0.2;
				if(_local6 > _local7) {
					TweenMax.to(_local5,1,{
						"alpha":0.7,
						"delay":tweenDelay,
						"ease":Elastic.easeInOut
					});
					tweenDelay += 0.07;
				}
				_local5.y = yPos + 3;
				_local5.x = 114 + _local7 * 16;
				addChild(_local5);
				_local7++;
			}
		}
	}
}

