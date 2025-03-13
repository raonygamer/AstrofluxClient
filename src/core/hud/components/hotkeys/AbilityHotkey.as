package core.hud.components.hotkeys {
	import core.hud.components.ImageButton;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class AbilityHotkey extends ImageButton {
		private var _cooldownTime:int = 1000;
		protected var cooldownCounter:int = 0;
		private var cooldownOverlay:Sprite;
		public var obj:Object;
		private var hotkeySymbol:Image;
		private const MIN_COOLDOWN:int = 200;
		private var quad:Quad = new Quad(10,10);
		
		public function AbilityHotkey(callback:Function, tex:Texture, inactiveTex:Texture, cooldownTex:Texture = null, caption:String = null) {
			super(callback,tex,tex,cooldownTex);
			cooldownOverlay = new Sprite();
			cooldownOverlay.addChild(new Image(inactiveTex));
			var _local6:ITextureManager = TextureLocator.getService();
			hotkeySymbol = new Image(_local6.getTextureGUIByTextureName("hotkey" + caption));
			hotkeySymbol.scaleX = hotkeySymbol.scaleY = 0.75;
			hotkeySymbol.x = 40 - hotkeySymbol.width - 2;
			hotkeySymbol.y = 2;
			addChild(hotkeySymbol);
		}
		
		public function update() : void {
			if(_cooldownTime < 200) {
				return;
			}
			if(cooldownCounter >= 0) {
				cooldownCounter -= 33;
			} else {
				cooldownCounter = 0;
			}
			if(cooldownCounter == 0 && !_enabled) {
				cooldownFinished();
				removeChild(cooldownOverlay);
				enabled = true;
			}
			draw();
		}
		
		public function cooldownFinished() : void {
		}
		
		public function initiateCooldown() : void {
			if(_cooldownTime < 200) {
				return;
			}
			if(cooldownCounter > 0) {
				return;
			}
			enabled = false;
			cooldownCounter = _cooldownTime;
			addChild(cooldownOverlay);
		}
		
		private function draw() : void {
			var _local2:Number = NaN;
			var _local1:Number = 0;
			if(cooldownCounter > 0) {
				_local1 = cooldownCounter / _cooldownTime;
				_local2 = source.width * _local1;
				quad.width = _local2;
				quad.height = source.height;
				cooldownOverlay.mask = quad;
			}
		}
		
		public function set cooldownTime(time:int) : void {
			_cooldownTime = time;
		}
		
		override protected function onClick(e:TouchEvent) : void {
			var _local2:ISound = SoundLocator.getService();
			_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
			super.onClick(e);
		}
	}
}

