package core.hud.components.hangar
{
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class SkinItemBaseStats extends Sprite
	{
		private var skinObj:Object;
		
		private var tweenDelay:Number = 0;
		
		public function SkinItemBaseStats(skinObj:Object)
		{
			super();
			this.skinObj = skinObj;
			addStat("statHealth","Health",23);
			addStat("statArmor","Armor",43);
			addStat("statShield","Shield",63);
			addStat("statShieldRegen","S. regen",83);
		}
		
		private function addStat(type:String, name:String, yPos:int) : void
		{
			var _loc6_:int = 0;
			var _loc4_:Quad = null;
			var _loc5_:Text = new Text(0,yPos,true,"Verdana");
			_loc5_.text = name + ":";
			_loc5_.size = 13;
			_loc5_.color = 0xffffff;
			addChild(_loc5_);
			var _loc7_:int = int(skinObj[type]);
			_loc6_ = 0;
			while(_loc6_ < 10)
			{
				_loc4_ = new Quad(8,8,111062);
				_loc4_.alpha = 0.3;
				if(_loc7_ > _loc6_)
				{
					TweenMax.to(_loc4_,0.2,{
						"alpha":1,
						"delay":tweenDelay
					});
					tweenDelay += 0.05;
				}
				_loc4_.y = yPos + 8;
				_loc4_.x = 84 + _loc6_ * 11;
				addChild(_loc4_);
				_loc6_++;
			}
		}
	}
}

