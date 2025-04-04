package core.solarSystem
{
	import flash.geom.Point;
	
	public class BodyHeading
	{
		public var time:Number = 0;
		public var pos:Point = new Point();
		public var angle:Number = 0;
		public var orbitAngle:Number = 0;
		public var orbitRadius:Number = 0;
		public var orbitSpeed:Number = 0;
		public var rotationSpeed:Number = 0;
		private var body:Body;
		
		public function BodyHeading(body:Body)
		{
			super();
			this.body = body;
			pos = new Point();
		}
		
		public function update(startTime:Number, currentTime:Number) : void
		{
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			if(body.parentBody != null)
			{
				_loc3_ = body.parentBody.pos.x;
				_loc4_ = body.parentBody.pos.y;
				_loc5_ = orbitRadius * Math.cos(orbitAngle + orbitSpeed * (33 / 1000) * (currentTime - startTime));
				_loc6_ = orbitRadius * Math.sin(orbitAngle + orbitSpeed * (33 / 1000) * (currentTime - startTime));
				pos.x = _loc5_ + _loc3_;
				pos.y = _loc6_ + _loc4_;
			}
			angle += rotationSpeed;
			time += 33;
		}
		
		public function parseJSON(obj:Object) : void
		{
			this.time = obj.time;
			this.pos.x = obj.x;
			this.pos.y = obj.y;
			this.angle = obj.angle;
			this.orbitAngle = obj.orbitAngle;
			this.orbitRadius = obj.orbitRadius;
			this.orbitSpeed = obj.orbitSpeed;
			this.rotationSpeed = obj.rotationSpeed;
		}
		
		public function clone() : BodyHeading
		{
			var _loc1_:BodyHeading = new BodyHeading(body);
			_loc1_.angle = this.angle;
			_loc1_.orbitAngle = this.orbitAngle;
			_loc1_.orbitRadius = this.orbitRadius;
			_loc1_.orbitSpeed = this.orbitSpeed;
			_loc1_.rotationSpeed = this.rotationSpeed;
			_loc1_.pos.x = this.pos.x;
			_loc1_.pos.y = this.pos.y;
			_loc1_.time = this.time;
			return _loc1_;
		}
		
		public function toString() : String
		{
			return "pos: " + pos.toString() + ", orbitAngle: " + orbitAngle + ", orbitSpeed: " + orbitSpeed + ", orbitRadius: " + orbitRadius + ", rotationSpeed: " + rotationSpeed + ", time:" + time;
		}
	}
}

