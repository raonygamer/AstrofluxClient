package core.hud.components.radar
{
	import core.GameObject;
	import core.scene.Game;
	import core.solarSystem.Body;
	
	public class Compas
	{
		public static const WIDTH:Number = 700;
		
		public static const HEIGHT:Number = 450;
		
		private var arrows:Vector.<TargetArrow> = new Vector.<TargetArrow>();
		
		private var g:Game;
		
		public function Compas(g:Game)
		{
			this.g = g;
			super();
		}
		
		public function update() : void
		{
			if(g.me.ship == null)
			{
				return;
			}
			for each(var _loc1_ in arrows)
			{
				_loc1_.update();
			}
		}
		
		public function removeArrow(go:GameObject) : void
		{
			var _loc3_:int = 0;
			var _loc2_:TargetArrow = null;
			_loc3_ = arrows.length - 1;
			while(_loc3_ > -1)
			{
				_loc2_ = arrows[_loc3_];
				if(_loc2_.target == go)
				{
					arrows.splice(_loc3_,1);
					g.removeChildFromCanvas(_loc2_,true);
				}
				_loc3_--;
			}
		}
		
		public function addArrow(go:GameObject, color:uint) : TargetArrow
		{
			var _loc3_:TargetArrow = new TargetArrow(g,go,color);
			arrows.push(_loc3_);
			g.addChildToCanvas(_loc3_);
			return _loc3_;
		}
		
		public function hasTarget(go:GameObject) : Boolean
		{
			for each(var _loc2_ in arrows)
			{
				if(_loc2_.target == go)
				{
					return true;
				}
			}
			return false;
		}
		
		public function addHintArrow(bodyType:String) : void
		{
			clear();
			var _loc2_:Vector.<Body> = g.bodyManager.bodies;
			for each(var _loc3_ in _loc2_)
			{
				if(_loc3_.type == bodyType)
				{
					addArrow(_loc3_,0x88ff88).activate();
				}
			}
		}
		
		public function addHintArrowByKey(bodyKey:String) : void
		{
			clear();
			var _loc2_:Vector.<Body> = g.bodyManager.bodies;
			for each(var _loc3_ in _loc2_)
			{
				if(_loc3_.key == bodyKey)
				{
					addArrow(_loc3_,0x88ff88).activate();
				}
			}
		}
		
		public function clearType(type:String) : void
		{
			var _loc2_:Body = null;
			var _loc4_:int = 0;
			var _loc3_:TargetArrow = null;
			_loc4_ = arrows.length - 1;
			while(_loc4_ > -1)
			{
				_loc3_ = arrows[_loc4_];
				if(_loc3_.target is Body)
				{
					_loc2_ = _loc3_.target as Body;
					if(_loc2_.type == type)
					{
						g.removeChildFromCanvas(_loc3_);
						arrows.splice(_loc4_,1);
					}
				}
				_loc4_--;
			}
		}
		
		public function clear() : void
		{
			for each(var _loc1_ in arrows)
			{
				_loc1_.deactivate();
				g.removeChildFromCanvas(_loc1_);
			}
			arrows.length = 0;
		}
	}
}

