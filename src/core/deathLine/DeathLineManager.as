package core.deathLine
{
	import core.scene.Game;
	import flash.geom.Point;
	import generics.GUID;
	import playerio.Message;
	import starling.display.MeshBatch;
	import starling.events.TouchEvent;
	
	public class DeathLineManager
	{
		private var g:Game;
		public var lines:Vector.<DeathLine> = new Vector.<DeathLine>();
		private var last:Point = new Point();
		private var isCut:Boolean = true;
		public var lineBatch:MeshBatch = new MeshBatch();
		private var selectedLineId:String = "";
		
		public function DeathLineManager(g:Game)
		{
			super();
			this.g = g;
			lineBatch.blendMode = "add";
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("addDeathLine",m_addDeathLine);
			g.addMessageHandler("clearDeathLines",m_clearDeathLines);
			g.addMessageHandler("undoDeathLine",m_undoDeathLine);
			g.addMessageHandler("deleteDeathLine",m_deleteDeathLine);
		}
		
		private function m_undoDeathLine(m:Message) : void
		{
			undo();
		}
		
		private function m_deleteDeathLine(m:Message) : void
		{
			deleteSelected(m.getString(0));
		}
		
		private function m_clearDeathLines(m:Message) : void
		{
			clear();
		}
		
		private function m_addDeathLine(m:Message) : void
		{
			addLine(m.getInt(0),m.getInt(1),m.getInt(2),m.getInt(3),m.getString(4));
		}
		
		public function addCoord(x:int, y:int) : void
		{
			if(isCut)
			{
				last.x = x;
				last.y = y;
				isCut = false;
				return;
			}
			addLine(last.x,last.y,x,y,"",true);
			last.x = x;
			last.y = y;
		}
		
		public function addLine(x:int, y:int, x2:int, y2:int, id:String = "", send:Boolean = false) : void
		{
			if(!g.stage.contains(lineBatch))
			{
				if(g.me != null && g.me.isDeveloper)
				{
					g.touchableCanvas = true;
				}
				g.addChildToCanvas(lineBatch);
			}
			var _loc7_:DeathLine = new DeathLine(g,13307920,1);
			_loc7_.blendMode = "add";
			_loc7_.x = x;
			_loc7_.y = y;
			_loc7_.id = id == "" ? GUID.create() : id;
			_loc7_.lineTo(x2,y2);
			if(g.me != null && g.me.isDeveloper)
			{
				lineBatch.root.touchable = true;
				_loc7_.touchable = true;
				lineBatch.touchable = true;
				_loc7_.addEventListener("touch",onTouch);
			}
			lines.push(_loc7_);
			lineBatch.addMesh(_loc7_);
			if(send)
			{
				g.sendMessage(g.createMessage("addDeathLine",x,y,x2,y2,_loc7_.id));
			}
		}
		
		public function cut() : void
		{
			isCut = true;
		}
		
		private function lineById(id:String) : DeathLine
		{
			for each(var _loc2_ in lines)
			{
				if(_loc2_.id == id)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function forceUpdate() : void
		{
			for each(var _loc1_ in lines)
			{
				_loc1_.nextDistanceCalculation = -1;
			}
		}
		
		public function deleteSelected(id:String = "", send:Boolean = false) : void
		{
			selectedLineId = id == "" ? selectedLineId : id;
			var line:DeathLine = lineById(selectedLineId);
			if(!line)
			{
				return;
			}
			line.removeEventListeners();
			lines = lines.filter(function(param1:DeathLine, param2:int, param3:Array):Boolean
			{
				return param1 != line;
			});
			updateBatch();
			if(send)
			{
				g.send("deleteDeathLine",selectedLineId);
			}
		}
		
		public function clear(send:Boolean = false) : void
		{
			lineBatch.clear();
			for each(var _loc2_ in lines)
			{
				_loc2_.removeEventListeners();
			}
			lines.length = 0;
			isCut = true;
			if(send)
			{
				g.send("clearDeathLines");
			}
		}
		
		public function save() : void
		{
			g.send("saveDeathLines");
		}
		
		public function undo(send:Boolean = false) : void
		{
			var _loc2_:DeathLine = lines.pop();
			if(!_loc2_)
			{
				return;
			}
			_loc2_.removeEventListeners();
			updateBatch();
			last.x = _loc2_.x;
			last.y = _loc2_.y;
			if(send)
			{
				g.send("undoDeathLine");
			}
		}
		
		private function updateBatch() : void
		{
			lineBatch.clear();
			for each(var _loc1_ in lines)
			{
				lineBatch.addMesh(_loc1_);
			}
		}
		
		public function update() : void
		{
			for each(var _loc1_ in lines)
			{
				_loc1_.update();
			}
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			var _loc2_:DeathLine = e.currentTarget as DeathLine;
			if(e.getTouch(_loc2_,"ended"))
			{
				selectedLineId = _loc2_.id;
			}
			else if(e.interactsWith(_loc2_))
			{
				_loc2_.color = 0xffffff;
			}
			else
			{
				_loc2_.color = 0xff4444;
			}
		}
	}
}

