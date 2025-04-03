package core.hud.components
{
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewBuySlot extends Sprite
	{
		private static const HEIGHT:int = 58;
		
		private static const WIDTH:int = 52;
		
		private var box:Quad;
		
		private var img:Image;
		
		private var g:Game;
		
		private var bgColor:uint = 1717572;
		
		private var isSelected:Boolean = false;
		
		private var hovering:Boolean = false;
		
		public function CrewBuySlot(g:Game)
		{
			super();
			this.g = g;
			box = new Quad(273,58,bgColor);
			addChild(box);
			var _loc2_:Text = new Text(60,20);
			_loc2_.text = "Empty slot";
			_loc2_.color = 16623682;
			_loc2_.size = 14;
			addChild(_loc2_);
			var _loc3_:ITextureManager = TextureLocator.getService();
			img = new Image(_loc3_.getTextureGUIByKey("xsUjTub_WUKwn9VSbMrrbg"));
			img.height = 58;
			img.width = 52;
			var _loc4_:ColorMatrixFilter = new ColorMatrixFilter();
			_loc4_.adjustSaturation(-1);
			_loc4_.adjustBrightness(-0.35);
			_loc4_.adjustHue(0.75);
			img.filter = _loc4_;
			img.filter.cache();
			addChild(img);
			addEventListener("touch",onTouch);
			setSelected(false);
			addEventListener("removedFromStage",clean);
		}
		
		public function setSelected(value:Boolean) : void
		{
			value ? (box.alpha = 1) : (box.alpha = 0);
			isSelected = value;
			if(!value)
			{
				return;
			}
			dispatchEventWith("crewSelected",true);
		}
		
		private function onClick(e:TouchEvent = null) : void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < parent.numChildren)
			{
				if(parent.getChildAt(_loc2_) is CrewDisplayBoxNew)
				{
					(parent.getChildAt(_loc2_) as CrewDisplayBoxNew).setSelected(false);
				}
				if(parent.getChildAt(_loc2_) is CrewBuySlot)
				{
					(parent.getChildAt(_loc2_) as CrewBuySlot).setSelected(false);
				}
				_loc2_++;
			}
			setSelected(true);
		}
		
		public function mOver(e:TouchEvent) : void
		{
			if(hovering)
			{
				return;
			}
			hovering = true;
			if(isSelected)
			{
				return;
			}
			box.alpha = 0.6;
		}
		
		public function mOut(e:TouchEvent) : void
		{
			if(!hovering)
			{
				return;
			}
			hovering = false;
			if(isSelected)
			{
				box.alpha = 1;
				return;
			}
			box.alpha = 0;
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			if(e.getTouch(this,"ended"))
			{
				onClick(e);
			}
			else if(e.interactsWith(this))
			{
				mOver(e);
			}
			else if(!e.interactsWith(this))
			{
				mOut(e);
			}
		}
		
		public function clean(e:Event = null) : void
		{
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
		}
	}
}

