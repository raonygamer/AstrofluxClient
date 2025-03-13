package core.hud.components.hangar {
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class SkinItemBaseStats extends Sprite {
		private var skinObj:Object;
		private var tweenDelay:Number = 0;
		
		public function SkinItemBaseStats(skinObj:Object) {
			super();
			this.skinObj = skinObj;
			addStat("statHealth","Health",23);
			addStat("statArmor","Armor",43);
			addStat("statShield","Shield",63);
			addStat("statShieldRegen","S. regen",83);
		}
		
		private function addStat(type:String, name:String, yPos:int) : void {
			var _local7:int = 0;
			var _local5:Quad = null;
			var _local4:Text = new Text(0,yPos,true,"Verdana");
			_local4.text = name + ":";
			_local4.size = 13;
			_local4.color = 0xffffff;
			addChild(_local4);
			var _local6:int = int(skinObj[type]);
			_local7 = 0;
			while(_local7 < 10) {
				_local5 = new Quad(8,8,111062);
				_local5.alpha = 0.3;
				if(_local6 > _local7) {
					TweenMax.to(_local5,0.2,{
						"alpha":1,
						"delay":tweenDelay
					});
					tweenDelay += 0.05;
				}
				_local5.y = yPos + 8;
				_local5.x = 84 + _local7 * 11;
				addChild(_local5);
				_local7++;
			}
		}
	}
}

