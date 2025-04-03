package core.text
{
	import core.scene.Game;
	import flash.geom.Point;
	
	public class TextHandler
	{
		public var texts:Vector.<TextParticle>;
		
		private var inactiveTexts:Vector.<TextParticle>;
		
		private var g:Game;
		
		public function TextHandler(g:Game)
		{
			super();
			this.inactiveTexts = g.textManager.inactiveTexts;
			this.g = g;
			texts = new Vector.<TextParticle>();
		}
		
		public function update() : void
		{
			var _loc2_:int = 0;
			var _loc1_:TextParticle = null;
			var _loc4_:Number = NaN;
			var _loc3_:int = int(texts.length);
			_loc2_ = _loc3_ - 1;
			while(_loc2_ > -1)
			{
				_loc1_ = texts[_loc2_];
				if(!_loc1_.alive)
				{
					remove(_loc1_,_loc2_);
				}
				else
				{
					_loc1_.update();
					_loc1_.x += _loc1_.speed.x * 33 / 1000;
					_loc1_.y += _loc1_.speed.y * 33 / 1000;
					_loc4_ = _loc1_.ttl / _loc1_.maxTtl;
					if(_loc4_ <= 0.5)
					{
						_loc1_.alpha = _loc4_;
					}
				}
				_loc2_--;
			}
		}
		
		public function add(text:String, pos:Point, speed:Point, ttl:Number = 400, color:uint = 16777215, size:Number = 20, fixed:Boolean = false, align:String = "center", blendMode:String = "normal") : TextParticle
		{
			var _loc11_:TextParticle = null;
			if(inactiveTexts.length > 0)
			{
				_loc11_ = inactiveTexts.pop();
			}
			else
			{
				_loc11_ = texts.shift();
				_loc11_.reset();
			}
			_loc11_.scaleX = _loc11_.scaleY = 1;
			_loc11_.ttl = ttl;
			_loc11_.maxTtl = ttl;
			var _loc10_:String = "font13";
			if(size > 18)
			{
				_loc10_ = "font26";
			}
			_loc11_.width = 800;
			_loc11_.height = 100;
			_loc11_.format.font = _loc10_;
			_loc11_.format.size = size;
			_loc11_.format.color = color;
			_loc11_.text = text;
			_loc11_.height = _loc11_.textBounds.height + 42;
			_loc11_.width = _loc11_.textBounds.width + 45;
			_loc11_.touchable = false;
			_loc11_.blendMode = "normal";
			if(align == "center")
			{
				_loc11_.pivotX = _loc11_.width / 2;
			}
			else if(align == "right")
			{
				_loc11_.pivotX = _loc11_.width;
			}
			_loc11_.x = pos.x;
			_loc11_.y = pos.y;
			_loc11_.speed = speed;
			_loc11_.fixed = fixed;
			_loc11_.alive = true;
			texts.push(_loc11_);
			if(fixed)
			{
				g.addChild(_loc11_);
			}
			else
			{
				g.canvasTexts.addChild(_loc11_);
			}
			return _loc11_;
		}
		
		public function remove(t:TextParticle, index:int) : void
		{
			t.reset();
			texts.splice(index,1);
			inactiveTexts.push(t);
			if(t.fixed)
			{
				g.removeChild(t);
			}
			else
			{
				g.canvasTexts.removeChild(t);
			}
		}
		
		public function dispose() : void
		{
			for each(var _loc1_ in texts)
			{
				if(_loc1_.fixed)
				{
					g.removeChild(_loc1_);
				}
				else
				{
					g.canvasTexts.removeChild(_loc1_);
				}
				_loc1_.dispose();
			}
			texts = null;
			inactiveTexts = null;
		}
	}
}

