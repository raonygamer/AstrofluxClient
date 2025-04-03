package generics
{
	public class Random
	{
		private var r:uint;
		
		public function Random(seed:Number)
		{
			super();
			if(seed > 1000000)
			{
				seed %= 1000000;
			}
			r = seed * 4294967293 + 1;
		}
		
		public function stepTo(n:int) : void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < n)
			{
				random(20);
				_loc2_++;
			}
		}
		
		public function random(max:int) : int
		{
			r ^= r << 21;
			r ^= r >>> 35;
			r ^= r << 4;
			return r / 4294967295 * max;
		}
		
		public function randomNumber() : Number
		{
			var _loc1_:Number = random(100000);
			return _loc1_ / 100000;
		}
	}
}

