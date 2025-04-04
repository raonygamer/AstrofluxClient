package startSetup
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class StartShipBaseStats extends Sprite
	{
		private var skinObj:Object;
		private var speed:int;
		private var tweenDelay:Number = 0.7;
		
		public function StartShipBaseStats(skinObj:Object, speed:int)
		{
			super();
			this.skinObj = skinObj;
			this.speed = speed;
			var _loc3_:int = 7;
			var _loc4_:int = 27;
			addStat("statHealth","Health",_loc3_);
			_loc3_ += _loc4_;
			addStat("statArmor","Armor",_loc3_);
			_loc3_ += _loc4_;
			addStat("statShield","Shield",_loc3_);
			_loc3_ += _loc4_;
			addStat("statShieldRegen","Speed",_loc3_);
			_loc3_ += _loc4_;
			addWeapon(_loc3_);
		}
		
		private function addWeapon(yPos:int) : void
		{
			var _loc4_:int = 0;
			var _loc3_:Object = null;
			var _loc2_:Text = null;
			var _loc5_:Text = null;
			_loc4_ = 0;
			while(_loc4_ < skinObj.upgrades.length - 1)
			{
				_loc3_ = skinObj.upgrades[_loc4_];
				if(_loc3_.table == "Weapons")
				{
					_loc2_ = new Text();
					_loc2_.y = yPos;
					_loc2_.text = "WEAPON:";
					_loc2_.size = 12;
					_loc2_.color = 16689475;
					addChild(_loc2_);
					_loc5_ = new Text();
					_loc5_.y = yPos;
					_loc5_.x = 114;
					_loc5_.text = _loc3_.name.toUpperCase();
					_loc5_.size = 12;
					_loc5_.color = 54271;
					addChild(_loc5_);
					return;
				}
				_loc4_++;
			}
		}
		
		private function addStat(type:String, name:String, yPos:int) : void
		{
			var _loc7_:int = 0;
			var _loc6_:int = 0;
			var _loc4_:Quad = null;
			var _loc5_:Text = new Text();
			_loc5_.y = yPos;
			_loc5_.text = name.toUpperCase() + ":";
			_loc5_.size = 12;
			_loc5_.color = 16689475;
			addChild(_loc5_);
			if(name == "Speed")
			{
				_loc7_ = speed;
			}
			else
			{
				_loc7_ = int(skinObj[type]);
			}
			_loc6_ = 0;
			while(_loc6_ < 10)
			{
				_loc4_ = new Quad(12,12,54271);
				_loc4_.alpha = 0.2;
				if(_loc7_ > _loc6_)
				{
					TweenMax.to(_loc4_,1,{
						"alpha":0.7,
						"delay":tweenDelay,
						"ease":Elastic.easeInOut
					});
					tweenDelay += 0.07;
				}
				_loc4_.y = yPos + 3;
				_loc4_.x = 114 + _loc6_ * 16;
				addChild(_loc4_);
				_loc6_++;
			}
		}
	}
}

