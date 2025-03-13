package core.hud.components {
	import flash.geom.Rectangle;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ButtonExpandableHud extends DisplayObjectContainer {
		private static var bgrLeftTexture:Texture;
		private static var bgrMidTexture:Texture;
		private static var bgrRightTexture:Texture;
		private static var hoverLeftTexture:Texture;
		private static var hoverMidTexture:Texture;
		private static var hoverRightTexture:Texture;
		private var captionText:TextBitmap;
		private var padding:Number = 8;
		private var hoverContainer:Sprite = new Sprite();
		private var callback:Function;
		private var _enabled:Boolean = true;
		
		public function ButtonExpandableHud(clickCallback:Function, caption:String) {
			super();
			callback = clickCallback;
			captionText = new TextBitmap(padding,2,caption);
			captionText.format.color = Style.COLOR_HIGHLIGHT;
			useHandCursor = true;
			addEventListener("removedFromStage",clean);
			load();
		}
		
		public function set text(value:String) : void {
			captionText.text = value;
		}
		
		public function load() : void {
			var _local1:ITextureManager = TextureLocator.getService();
			var _local9:Texture = _local1.getTextureGUIByTextureName("button.png");
			if(bgrLeftTexture == null) {
				bgrLeftTexture = Texture.fromTexture(_local9,new Rectangle(0,0,padding,21));
				bgrMidTexture = Texture.fromTexture(_local9,new Rectangle(padding,0,padding,21));
				bgrRightTexture = Texture.fromTexture(_local9,new Rectangle(_local9.width - padding,0,padding,21));
			}
			var _local8:Image = new Image(bgrLeftTexture);
			var _local3:Image = new Image(bgrMidTexture);
			var _local6:Image = new Image(bgrRightTexture);
			_local3.x = padding;
			_local3.width = captionText.width;
			_local6.x = _local3.x + _local3.width;
			addChild(_local8);
			addChild(_local3);
			addChild(_local6);
			var _local2:Texture = _local1.getTextureGUIByTextureName("button_hover.png");
			if(hoverLeftTexture == null) {
				hoverLeftTexture = Texture.fromTexture(_local2,new Rectangle(0,0,padding,21));
				hoverMidTexture = Texture.fromTexture(_local2,new Rectangle(padding,0,padding,21));
				hoverRightTexture = Texture.fromTexture(_local2,new Rectangle(_local9.width - padding,0,padding,21));
			}
			var _local5:Image = new Image(hoverLeftTexture);
			var _local7:Image = new Image(hoverMidTexture);
			var _local4:Image = new Image(hoverRightTexture);
			_local7.x = padding;
			_local7.width = captionText.width;
			_local4.x = _local3.x + _local3.width;
			hoverContainer.addChild(_local5);
			hoverContainer.addChild(_local7);
			hoverContainer.addChild(_local4);
			hoverContainer.visible = false;
			addChild(hoverContainer);
			addEventListener("touch",onTouch);
			addChild(captionText);
		}
		
		private function onMouseOver(e:TouchEvent) : void {
			hoverContainer.visible = true;
		}
		
		private function onMouseOut(e:TouchEvent) : void {
			hoverContainer.visible = false;
		}
		
		private function onClick(e:TouchEvent) : void {
			var _local2:ISound = SoundLocator.getService();
			if(_local2 != null) {
				_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
			}
			hoverContainer.visible = false;
			enabled = false;
			if(callback == null) {
				return;
			}
			callback();
		}
		
		public function set enabled(value:Boolean) : void {
			_enabled = value;
			if(value) {
				alpha = 1;
			} else {
				alpha = 0.5;
			}
		}
		
		public function get enabled() : Boolean {
			return _enabled;
		}
		
		public function set select(value:Boolean) : void {
			if(value) {
				captionText.format.color = 0xffffaa;
			} else {
				captionText.format.color = Style.COLOR_HIGHLIGHT;
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(!_enabled) {
				return;
			}
			if(e.getTouch(this,"ended")) {
				onClick(e);
			} else if(e.interactsWith(this)) {
				onMouseOver(e);
			} else if(!e.interactsWith(this)) {
				onMouseOut(e);
			}
		}
		
		private function clean(e:Event = null) : void {
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
		}
	}
}

