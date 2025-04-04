package core.states.gameStates
{
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Util;
	import io.InputLocator;
	import movement.Heading;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import textures.TextureLocator;
	
	public class PlayState extends GameState
	{
		private static var autoCruise:Boolean = false;
		private static var mouseBlocked:Boolean = false;
		private static var mouseIntegrator:int = 0;
		private static var oldMouseX:int = 0;
		private static var oldMouseY:int = 0;
		protected var container:Sprite = new Sprite();
		private var isInHostileZone:Boolean = false;
		private var blackBackground:Quad = new Quad(10,10,0);
		private var fireWithHotkeys:Boolean = false;
		
		public function PlayState(g:Game)
		{
			super(g);
			g.messageLog.visible = false;
			input = InputLocator.getService();
			textureManager = TextureLocator.getService();
			soundManager = SoundLocator.getService();
			blackBackground.alpha = 0.8;
			container.addChild(blackBackground);
			blackBackground.visible = false;
		}
		
		override public function enter() : void
		{
			isInHostileZone = !g.hud.radar.inHostileZone();
			g.addChildToMenu(container);
			resize();
			g.addResizeListener(resize);
		}
		
		public function resize(e:Event = null) : void
		{
			container.x = g.stage.stageWidth / 2 - 380;
			container.y = g.stage.stageHeight / 2 - 5 * 60;
			if(blackBackground.visible)
			{
				drawBlackBackground();
			}
		}
		
		override public function loadCompleted() : void
		{
			Login.fadeScreen.fadeOut();
			_loaded = true;
		}
		
		override public function execute() : void
		{
			if(!g.isLeaving)
			{
				g.draw();
			}
		}
		
		override public function exit(callback:Function) : void
		{
			g.removeChildFromMenu(container);
			g.removeResizeListener(resize);
			unloadCompleted();
			callback();
		}
		
		override public function tickUpdate() : void
		{
			super.tickUpdate();
		}
		
		protected function addChild(child:DisplayObject) : void
		{
			container.addChild(child);
		}
		
		private function updateMouseIntegrator() : void
		{
			var _loc1_:int = Starling.current.nativeOverlay.mouseX;
			var _loc2_:int = Starling.current.nativeOverlay.mouseY;
			if(oldMouseX != 0 && oldMouseY != 0)
			{
				mouseIntegrator += (_loc1_ - oldMouseX) * (_loc1_ - oldMouseX) + (_loc2_ - oldMouseY) * (_loc2_ - oldMouseY);
			}
			if(mouseIntegrator > 100000)
			{
				mouseBlocked = false;
				mouseIntegrator = 0;
				oldMouseX = 0;
				oldMouseY = 0;
			}
			oldMouseX = _loc1_;
			oldMouseY = _loc2_;
			mouseIntegrator -= 350;
			if(mouseIntegrator < 0)
			{
				mouseIntegrator = 0;
			}
		}
		
		public function updateMouseAim() : void
		{
			var _loc3_:PlayerShip = me.ship;
			var _loc4_:Heading = _loc3_.course;
			var _loc6_:Point = _loc3_.getGlobalPos();
			var _loc7_:Number = _loc6_.x;
			var _loc8_:Number = _loc6_.y;
			var _loc5_:Number = _loc3_.engine.rotationSpeed / 33;
			var _loc1_:Number = Math.atan2(Starling.current.nativeOverlay.mouseY - _loc8_,Starling.current.nativeOverlay.mouseX - _loc7_);
			var _loc2_:Number = Util.angleDifference(_loc3_.rotation,_loc1_);
			if(_loc2_ < _loc5_ && _loc2_ > -_loc5_)
			{
				if(_loc4_.rotateLeft)
				{
					sendCommand(1,false);
				}
				if(_loc4_.rotateRight)
				{
					sendCommand(2,false);
				}
			}
			else if(_loc2_ > _loc5_)
			{
				if(_loc4_.rotateRight)
				{
					sendCommand(2,false);
				}
				else if(!_loc4_.rotateLeft)
				{
					sendCommand(1,true);
				}
			}
			else if(_loc2_ < -_loc5_)
			{
				if(_loc4_.rotateLeft)
				{
					sendCommand(1,false);
				}
				else if(!_loc4_.rotateRight)
				{
					sendCommand(2,true);
				}
			}
		}
		
		public function checkAccelerate(menuIsActive:Boolean = false) : void
		{
			if(!me.commandable)
			{
				return;
			}
			if(!_loaded)
			{
				return;
			}
			var _loc2_:PlayerShip = me.ship;
			var _loc3_:Heading = _loc2_.course;
			if(keybinds.isInputPressed(26))
			{
				autoCruise = autoCruise ? false : true;
			}
			if(keybinds.isInputPressed(11) || keybinds.isInputPressed(12))
			{
				autoCruise = false;
			}
			if((!_loc3_.accelerate || _loc2_.boostEndedLastTick) && !menuIsActive && !_loc2_.usingBoost && keybinds.isInputDown(11) || !_loc3_.accelerate && autoCruise)
			{
				_loc2_.boostEndedLastTick = false;
				sendCommand(0,true);
				g.camera.zoomFocus(0.85,100);
			}
			if((_loc3_.accelerate || _loc2_.boostEndedLastTick) && !_loc2_.usingBoost && keybinds.isInputUp(11) && !autoCruise)
			{
				_loc2_.boostEndedLastTick = false;
				sendCommand(0,false);
				g.camera.zoomFocus(1,100);
			}
			if(!_loc3_.accelerate && !_loc3_.deaccelerate && !menuIsActive && !_loc2_.usingBoost && keybinds.isInputDown(12))
			{
				sendCommand(8,true);
				g.camera.zoomFocus(1,100);
			}
			if(_loc3_.deaccelerate && !_loc2_.usingBoost && keybinds.isInputUp(12))
			{
				sendCommand(8,false);
				g.camera.zoomFocus(1,100);
			}
		}
		
		public function updateCommands() : void
		{
			if(!me.commandable)
			{
				return;
			}
			if(!_loaded)
			{
				return;
			}
			var _loc1_:PlayerShip = me.ship;
			if(_loc1_.channelingEnd > g.time)
			{
				_loc1_.course.rotateLeft = false;
				_loc1_.course.rotateRight = false;
				_loc1_.course.accelerate = false;
				return;
			}
			checkBoost();
			checkShield();
			checkConvert();
			checkPower();
			checkAccelerate();
			if(!_loc1_.isTeleporting && !_loc1_.usingBoost)
			{
				handleTurn();
			}
			handleWeaponFire();
			if(g.me.isDeveloper)
			{
				handleDeathlines();
			}
		}
		
		private function handleTurn() : void
		{
			if(keybinds.isInputDown(13) || keybinds.isInputDown(14))
			{
				mouseBlocked = true;
				mouseIntegrator = 0;
			}
			if(SceneBase.settings.mouseAim && !mouseBlocked)
			{
				return updateMouseAim();
			}
			var _loc1_:Heading = me.ship.course;
			if(!_loc1_.rotateLeft && keybinds.isInputDown(13))
			{
				sendCommand(1,true);
			}
			else if(_loc1_.rotateLeft && keybinds.isInputUp(13))
			{
				sendCommand(1,false);
			}
			if(!_loc1_.rotateRight && keybinds.isInputDown(14))
			{
				sendCommand(2,true);
			}
			else if(_loc1_.rotateRight && keybinds.isInputUp(14))
			{
				sendCommand(2,false);
			}
			if(SceneBase.settings.mouseAim)
			{
				updateMouseIntegrator();
			}
		}
		
		private function handleWeaponFire() : void
		{
			var _loc3_:PlayerShip = me.ship;
			fireWithHotkeys = false;
			var _loc1_:int = 0;
			if(keybinds.isInputDown(20))
			{
				_loc1_ = 1;
			}
			else if(keybinds.isInputDown(21))
			{
				_loc1_ = 2;
			}
			else if(keybinds.isInputDown(22))
			{
				_loc1_ = 3;
			}
			else if(keybinds.isInputDown(23))
			{
				_loc1_ = 4;
			}
			else if(keybinds.isInputDown(24))
			{
				_loc1_ = 5;
			}
			if(_loc1_ > 0 && _loc1_ < 6)
			{
				if(g.hud.weaponHotkeys.selectedHotkey == null || _loc1_ != g.hud.weaponHotkeys.selectedHotkey.key && !_loc3_.weaponIsChanging)
				{
					g.me.sendChangeWeapon(_loc1_);
				}
				if(SceneBase.settings.fireWithHotkeys)
				{
					fireWithHotkeys = true;
				}
			}
			if(!_loc3_.isShooting && (keybinds.isInputDown(19) || fireWithHotkeys))
			{
				sendCommand(3,true);
			}
			else if(_loc3_.isShooting && keybinds.isInputUp(19) && !fireWithHotkeys)
			{
				for each(var _loc2_ in _loc3_.weapons)
				{
					_loc2_.fire = false;
				}
				sendCommand(3,false);
			}
		}
		
		private function handleDeathlines() : void
		{
			var _loc1_:PlayerShip = me.ship;
			if(input.isKeyPressed(89))
			{
				g.deathLineManager.addCoord(_loc1_.pos.x,_loc1_.pos.y);
			}
			if(input.isKeyPressed(75))
			{
				g.deathLineManager.cut();
			}
			if(input.isKeyPressed(85))
			{
				g.deathLineManager.undo(true);
			}
			if(input.isKeyPressed(8))
			{
				g.deathLineManager.deleteSelected("",true);
			}
			if(input.isKeyPressed(112))
			{
				g.deathLineManager.save();
				g.textManager.createBossSpawnedText("Death lines saved!");
			}
			if(input.isKeyPressed(74))
			{
				g.deathLineManager.clear(true);
			}
		}
		
		private function checkPower() : void
		{
			if(keybinds.isInputPressed(18))
			{
				g.commandManager.addDmgBoostCommand();
			}
		}
		
		private function checkConvert() : void
		{
			if(keybinds.isInputPressed(17))
			{
				g.commandManager.addShieldConvertCommand();
			}
		}
		
		private function checkShield() : void
		{
			if(keybinds.isInputPressed(16))
			{
				g.commandManager.addHardenedShieldCommand();
			}
		}
		
		private function checkBoost() : void
		{
			if(keybinds.isInputPressed(15))
			{
				g.commandManager.addBoostCommand();
				if(me.ship.usingBoost)
				{
					g.camera.zoomFocus(0.75,80);
				}
			}
		}
		
		private function sendCommand(type:int, active:Boolean) : void
		{
			g.commandManager.addCommand(type,active);
		}
		
		protected function drawBlackBackground(e:Event = null) : void
		{
			blackBackground.x = -container.x;
			blackBackground.y = -container.y;
			blackBackground.width = g.stage.stageWidth;
			blackBackground.height = g.stage.stageHeight;
			blackBackground.visible = true;
		}
		
		protected function clearBackground(e:Event = null) : void
		{
			blackBackground.visible = false;
		}
	}
}

