package core.hud.components
{
	import core.player.Player;
	import core.scene.Game;
	import core.weapon.Heat;
	import generics.Localize;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PowerBar extends DisplayObjectContainer
	{
		private static const HEAT_WIDTH:Number = 120;
		private static const SMOOTHER_STEPS:int = 5;
		private var heatNumber:TextField;
		private var g:Game;
		private var smoother:Vector.<Number> = new Vector.<Number>();
		private var soundManager:ISound;
		private const colorRed:uint = 16724770;
		private const colorBlue:uint = 4474111;
		private var heatBar:Image;
		private var loadBar:Image;
		private var heatBarBgr:Image;
		private var turnedLow:Boolean = false;
		private var turnedOut:Boolean = false;
		
		public function PowerBar(g:Game)
		{
			super();
			this.g = g;
		}
		
		public function load() : void
		{
			var _loc1_:int = 0;
			var _loc2_:ITextureManager = TextureLocator.getService();
			heatBar = new Image(_loc2_.getTextureGUIByTextureName("power_bar_white"));
			heatBar.color = 4474111;
			loadBar = new Image(_loc2_.getTextureGUIByTextureName("power_bar_white"));
			loadBar.scaleX = 0;
			loadBar.alpha = 0.5;
			heatBarBgr = new Image(_loc2_.getTextureGUIByTextureName("power_bar_white"));
			heatBarBgr.color = 0x55333333;
			var _loc3_:Image = new Image(_loc2_.getTextureGUIByTextureName("text_power"));
			_loc3_.y = 5;
			_loc3_.x = 7;
			heatNumber = new TextField(40,16,"",new TextFormat("font13",13,12113919,"right"));
			heatNumber.batchable = true;
			heatBarBgr.y = -2;
			heatBarBgr.x = 0;
			heatBar.y = -1;
			heatBar.x = 2;
			loadBar.y = heatBar.y;
			loadBar.x = heatBar.x;
			_loc1_ = 0;
			while(_loc1_ < 5 - 1)
			{
				smoother.push(0.04 * (2 * 60));
				_loc1_++;
			}
			addChild(heatBarBgr);
			addChild(heatBar);
			addChild(loadBar);
			addChild(_loc3_);
			addChild(heatNumber);
			heatNumber.x = 2 * 60 - 43;
			heatNumber.y = 1;
			soundManager = SoundLocator.getService();
			new ToolTip(g,this,Localize.t("You need <FONT COLOR=\'#8888ff\'>POWER</FONT> to fire your weapons."),null,"power bar");
		}
		
		public function update() : void
		{
			var _loc3_:int = 0;
			var _loc1_:Player = g.playerManager.me;
			if(_loc1_.ship == null)
			{
				return;
			}
			var _loc2_:Heat = _loc1_.ship.weaponHeat;
			if(_loc2_ == null)
			{
				return;
			}
			var _loc4_:String = Math.round(_loc2_.heat * 100).toString();
			if(_loc2_.heat >= 0.4)
			{
				heatBar.color = 4474111;
				turnedLow = false;
				turnedOut = false;
			}
			else
			{
				if(!turnedLow)
				{
					turnedLow = true;
					soundManager.play("-8O67HBaKUy4hBaS3liNqw");
				}
				else if(_loc2_.heat < 0.05 && !turnedOut)
				{
					turnedOut = true;
					soundManager.play("mwJAopTgkUmewtewTWjqCg");
				}
				heatBar.color = 16724770;
			}
			heatNumber.text = _loc4_;
			smoother.push(2 * 60 * (_loc2_.heat / _loc2_.max) * 0.96 + 0.04 * (2 * 60));
			heatBar.width = 0;
			_loc3_ = 0;
			while(_loc3_ < 5)
			{
				heatBar.width += 1 / 5 * smoother[_loc3_];
				_loc3_++;
			}
			smoother.shift();
		}
		
		public function updateLoadBar(value:Number) : void
		{
			if(loadBar != null)
			{
				loadBar.scaleX = value;
			}
		}
	}
}

