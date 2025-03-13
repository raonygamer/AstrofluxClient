package core.artifact {
	import core.hud.components.Button;
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.ObjUtils;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactSorting extends Sprite {
		private var nextX:int = 20;
		private var nextY:int = 0;
		private var padding:int = 10;
		private var g:Game;
		private var types:Vector.<Object>;
		private var callback:Function;
		private var drawCount:int = 0;
		private var scrollArea:ScrollContainer;
		private var mainBody:Sprite;
		
		public function ArtifactSorting(g:Game, callback:Function) {
			var q:Quad;
			var headline:TextField;
			var tmp:Object;
			var sortLevelHigh:Button;
			var sortLevelLow:Button;
			var sortCountAsc:Button;
			var sortCountDesc:Button;
			super();
			this.g = g;
			this.callback = callback;
			q = new Quad(665,520,0);
			q.x = -10;
			q.y = -10;
			q.alpha = 0.9;
			addChild(q);
			headline = new TextField(5 * 60,100);
			headline.format.font = "DAIDRR";
			headline.format.size = 26;
			headline.format.color = 0xffffff;
			headline.format.horizontalAlign = "left";
			headline.format.verticalAlign = "top";
			headline.text = "Choose sorting:";
			headline.y = 20;
			headline.x = nextY;
			addChild(headline);
			scrollArea = new ScrollContainer();
			mainBody = new Sprite();
			scrollArea.y = 60;
			scrollArea.x = 4;
			scrollArea.width = 11 * 60;
			scrollArea.height = 400;
			tmp = g.dataManager.loadTable("ArtifactTypes");
			types = ObjUtils.ToVector(tmp,true,"name");
			drawOfSubset("health");
			drawOfSubset("convShield");
			newRow();
			drawOfSubset("armor");
			newRow();
			drawOfSubset("shield");
			drawOfSubset("convHp");
			newRow();
			drawOfSubset("power");
			drawOfSubset("all");
			newRow();
			drawOfSubset("kinetic");
			newRow();
			drawOfSubset("energy");
			newRow();
			drawOfSubset("corrosive");
			newRow();
			drawOfSubset("speed");
			drawOfSubset("refire");
			drawOfSubset("cooldown");
			newRow();
			scrollArea.addChild(mainBody);
			addChild(scrollArea);
			sortLevelHigh = new Button(function():void {
				closeAndSort("levelhigh");
			},"Strength high");
			sortLevelHigh.x = nextX;
			sortLevelHigh.y = 8 * 60;
			addChild(sortLevelHigh);
			sortLevelLow = new Button(function():void {
				closeAndSort("levellow");
			},"Strength low");
			sortLevelLow.x = sortLevelHigh.x + sortLevelHigh.width + 20;
			sortLevelLow.y = 8 * 60;
			addChild(sortLevelLow);
			sortCountAsc = new Button(function():void {
				closeAndSort("statcountasc");
			},"Modifiers high");
			sortCountAsc.x = sortLevelLow.x + sortLevelLow.width + 20;
			sortCountAsc.y = 8 * 60;
			addChild(sortCountAsc);
			sortCountDesc = new Button(function():void {
				closeAndSort("statcountdesc");
			},"Modifiers low");
			sortCountDesc.x = sortCountAsc.x + sortCountAsc.width + 20;
			sortCountDesc.y = 8 * 60;
			addChild(sortCountDesc);
		}
		
		private function newRow() : void {
			nextX = 20;
			nextY += 60;
		}
		
		private function drawOfSubset(name:String) : void {
			var _local4:int = 0;
			var _local3:Object = null;
			var _local2:String = null;
			_local4 = 0;
			while(_local4 < types.length) {
				_local3 = types[_local4];
				_local2 = _local3.type;
				if(!(_local2.indexOf(name) == -1 || _local2.indexOf("2") != -1 || _local2.indexOf("3") != -1)) {
					addButton(_local3);
				}
				_local4++;
			}
		}
		
		private function addButton(o:Object) : void {
			var _local2:ITextureManager = TextureLocator.getService();
			var _local4:Image = new Image(_local2.getTextureGUIByKey(o.bitmap));
			_local4.scaleX = _local4.scaleY = 0.7;
			_local4.x = nextX;
			_local4.y = nextY;
			_local4.name = o.type;
			mainBody.addChild(_local4);
			nextX += _local4.width + padding;
			var _local3:ToolTip = new ToolTip(g,_local4,o.name,null,"artifactBox");
			_local4.addEventListener("touch",onTouch);
			_local4.addEventListener("touch",onTouch);
			_local4.useHandCursor = true;
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local2:Image = e.currentTarget as Image;
			if(e.getTouch(_local2,"ended")) {
				_local2.filter = null;
				closeAndSort(_local2.name);
			} else if(e.interactsWith(_local2)) {
				_local2.alpha = 0.5;
			} else if(!e.interactsWith(_local2)) {
				_local2.alpha = 1;
			}
		}
		
		private function closeAndSort(name:String) : void {
			callback(name);
			parent.removeChild(this,true);
		}
	}
}

