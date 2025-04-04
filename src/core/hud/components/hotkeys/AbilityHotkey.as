package core.hud.components.hotkeys
{
	import core.hud.components.ImageButton;
	import core.scene.Game;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class AbilityHotkey extends ImageButton
	{
		private var _cooldownTime:int = 1000;
		protected var cooldownEndTime:Number = 0;
		private var cooldownOverlay:Sprite;
		public var obj:Object;
		private var hotkeySymbol:Image;
		public var g:Game;
		private const MIN_COOLDOWN:int = 200;
		private var quad:Quad = new Quad(10,10);
		
		public function AbilityHotkey(callback:Function, tex:Texture, inactiveTex:Texture, cooldownTex:Texture = null, caption:String = null)
		{
			super(callback,tex,tex,cooldownTex);
			g = Game.instance;
			cooldownOverlay = new Sprite();
			cooldownOverlay.addChild(new Image(inactiveTex));
			var _loc6_:ITextureManager = TextureLocator.getService();
			hotkeySymbol = new Image(_loc6_.getTextureGUIByTextureName("hotkey" + caption));
			hotkeySymbol.scaleX = hotkeySymbol.scaleY = 0.75;
			hotkeySymbol.x = 40 - hotkeySymbol.width - 2;
			hotkeySymbol.y = 2;
			addChild(hotkeySymbol);
		}
		
		public function update() : void
		{
			if(_cooldownTime < 200)
			{
				return;
			}
			if(cooldownEndTime <= g.time && !_enabled)
			{
				cooldownFinished();
				removeChild(cooldownOverlay);
				enabled = true;
			}
			draw();
		}
		
		public function cooldownFinished() : void
		{
		}
		
		public function initiateCooldown() : void
		{
			if(_cooldownTime < 200)
			{
				return;
			}
			if(cooldownEndTime > g.time)
			{
				return;
			}
			enabled = false;
			cooldownEndTime = _cooldownTime + g.time;
			addChild(cooldownOverlay);
		}
		
		private function draw() : void
		{
			var _loc2_:Number = 0;
			if(cooldownEndTime <= g.time)
			{
				return;
			}
			var _loc3_:Number = cooldownEndTime - g.time;
			_loc2_ = _loc3_ / _cooldownTime;
			var _loc1_:Number = source.width * _loc2_;
			quad.width = _loc1_;
			quad.height = source.height;
			cooldownOverlay.mask = quad;
		}
		
		public function set cooldownTime(time:int) : void
		{
			_cooldownTime = time;
		}
		
		override protected function onClick(e:TouchEvent) : void
		{
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			super.onClick(e);
		}
	}
}

