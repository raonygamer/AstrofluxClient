package core.hud.components
{
	import core.scene.SceneBase;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ToolTip
	{
		private static var g:SceneBase;
		
		private static var toolTips:Vector.<ToolTip> = new Vector.<ToolTip>();
		
		private var container:ScrollContainer;
		
		private var target:DisplayObject;
		
		private var s:String;
		
		private var imgs:Vector.<Image>;
		
		private var imgsData:Array;
		
		private var maxWidth:int;
		
		private var hover:Boolean;
		
		private var c:uint;
		
		public var type:String;
		
		public function ToolTip(m:SceneBase, target:DisplayObject, tooltip:String, images:Array = null, type:String = "", maxWidth:int = 200)
		{
			super();
			g = m;
			this.type = type;
			this.maxWidth = maxWidth;
			this.target = target;
			this.imgsData = images;
			imgs = new Vector.<Image>();
			for each(var _loc7_ in imgsData)
			{
				addImage(_loc7_);
			}
			s = tooltip;
			toolTips.push(this);
			addListeners();
		}
		
		public static function disposeType(s:String = "all") : void
		{
			var _loc2_:ToolTip = null;
			var _loc3_:int = 0;
			if(g == null)
			{
				return;
			}
			_loc3_ = toolTips.length - 1;
			while(_loc3_ > -1)
			{
				_loc2_ = toolTips[_loc3_];
				if(_loc2_.type == s || s == "all")
				{
					_loc2_.dispose();
					toolTips.splice(_loc3_,1);
				}
				_loc3_--;
			}
		}
		
		public static function disposeAll() : void
		{
			disposeType();
		}
		
		public function set text(value:String) : void
		{
			s = value;
		}
		
		public function set color(value:uint) : void
		{
			c = value;
		}
		
		public function addImage(obj:Object) : void
		{
			var _loc3_:ITextureManager = TextureLocator.getService();
			var _loc2_:Image = new Image(_loc3_.getTextureGUIByTextureName(obj.img));
			_loc2_.x = obj.x;
			_loc2_.y = obj.y;
			imgs.push(_loc2_);
		}
		
		private function mOver(e:TouchEvent) : void
		{
			var _loc3_:Label = null;
			if(s == null || s == "")
			{
				return;
			}
			if(hover && container)
			{
				container.x = e.getTouch(target).globalX + 10;
				container.y = e.getTouch(target).globalY + 14;
				if(container.x + container.width + 5 > g.stage.stageWidth)
				{
					container.x = g.stage.stageWidth - container.width - 5;
				}
				if(container.y + container.height + 5 > g.stage.stageHeight)
				{
					container.y = g.stage.stageHeight - container.height - 35;
				}
				return;
			}
			hover = true;
			if(container != null)
			{
				g.addChildToOverlay(container);
			}
			else
			{
				container = new ScrollContainer();
				container.touchable = false;
				container.backgroundSkin = new Quad(40,5,0);
				container.padding = 4;
				g.addChildToOverlay(container);
				_loc3_ = new Label();
				_loc3_.styleNameList.add("tooltip");
				_loc3_.text = s;
				_loc3_.maxWidth = maxWidth;
				container.addChild(_loc3_);
				_loc3_.textRendererProperties.textFormat.color = c != 0 ? c : Style.COLOR_HIGHLIGHT;
				_loc3_.validate();
				_loc3_.width += 5;
				_loc3_.invalidate();
				for each(var _loc2_ in imgs)
				{
					container.addChild(_loc2_);
				}
			}
			container.x = e.getTouch(target).globalX + 10;
			container.y = e.getTouch(target).globalY + 14;
			if(container.x + container.width + 5 > g.stage.stageWidth)
			{
				container.x = g.stage.stageWidth - container.width - 5;
			}
			if(container.y + container.height + 5 > g.stage.stageHeight)
			{
				container.y = g.stage.stageHeight - container.height - 35;
			}
		}
		
		private function mOut(e:TouchEvent) : void
		{
			if(!hover)
			{
				return;
			}
			hover = false;
			if(container != null)
			{
				g.removeChildFromOverlay(container,true);
				container = null;
			}
		}
		
		private function onClick(e:TouchEvent) : void
		{
			hover = false;
			if(container != null)
			{
				g.removeChildFromOverlay(container,true);
				container = null;
			}
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			if(e.getTouch(target,"ended"))
			{
				onClick(e);
			}
			else if(e.interactsWith(target))
			{
				mOver(e);
			}
			else if(!e.interactsWith(target))
			{
				mOut(e);
			}
		}
		
		public function removeListeners() : void
		{
			target.removeEventListener("touch",onTouch);
		}
		
		private function addListeners() : void
		{
			target.addEventListener("touch",onTouch);
		}
		
		public function dispose() : void
		{
			if(container != null)
			{
				g.removeChildFromOverlay(container,true);
				container = null;
			}
			removeListeners();
			target = null;
			imgs = null;
			imgsData = null;
		}
	}
}

