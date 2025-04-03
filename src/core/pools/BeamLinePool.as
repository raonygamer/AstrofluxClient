package core.pools
{
	import core.hud.components.BeamLine;
	import core.scene.Game;
	
	public class BeamLinePool
	{
		private var inactiveLines:Vector.<BeamLine>;
		
		private var activeLines:Vector.<BeamLine>;
		
		private var g:Game;
		
		public function BeamLinePool(g:Game)
		{
			var _loc2_:int = 0;
			var _loc3_:BeamLine = null;
			inactiveLines = new Vector.<BeamLine>();
			activeLines = new Vector.<BeamLine>();
			super();
			this.g = g;
			_loc2_ = 0;
			while(_loc2_ < 4)
			{
				_loc3_ = new BeamLine(g);
				inactiveLines.push(_loc3_);
				_loc2_++;
			}
		}
		
		public function getLine() : BeamLine
		{
			var _loc1_:BeamLine = null;
			if(inactiveLines.length > 0)
			{
				_loc1_ = inactiveLines.pop();
			}
			else
			{
				_loc1_ = new BeamLine(g);
			}
			activeLines.push(_loc1_);
			return _loc1_;
		}
		
		public function removeLine(bl:BeamLine) : void
		{
			var _loc2_:int = int(activeLines.indexOf(bl));
			if(_loc2_ == -1)
			{
				return;
			}
			activeLines.splice(_loc2_,1);
			inactiveLines.push(bl);
		}
		
		public function dispose() : void
		{
			for each(var _loc1_ in inactiveLines)
			{
				_loc1_.dispose();
			}
			for each(_loc1_ in activeLines)
			{
				_loc1_.dispose();
			}
			activeLines = null;
			inactiveLines = null;
		}
	}
}

