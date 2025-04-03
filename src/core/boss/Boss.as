package core.boss
{
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.turret.Turret;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import textures.TextureLocator;
	
	public class Boss extends GameObject
	{
		public var alive:Boolean;
		
		public var isHostile:Boolean;
		
		public var key:String;
		
		public var xp:int;
		
		public var level:int;
		
		public var hp:int;
		
		public var hpMax:int;
		
		public var resetTime:Number;
		
		public var respawnTime:Number;
		
		public var speed:Number;
		
		public var acceleration:Number;
		
		public var rotationSpeed:Number;
		
		public var rotationForced:Boolean;
		
		public var targetRange:int;
		
		public var holonomic:Boolean;
		
		public var orbitOrign:Point;
		
		public var orbitRadius:Point;
		
		public var turrets:Vector.<Turret>;
		
		public var spawners:Vector.<Spawner>;
		
		public var bossComponents:Vector.<BossComponent>;
		
		public var allComponents:Vector.<Unit>;
		
		public var target:Unit;
		
		public var angleTargetPos:Point;
		
		public var course:Heading;
		
		public var parentBody:Body;
		
		public var explosionEffect:String;
		
		public var explosionSound:String;
		
		public var bossRadius:int;
		
		public var currentWaypoint:Waypoint = null;
		
		public var waypoints:Vector.<Waypoint>;
		
		public var bodyDestroyStart:Number = 0;
		
		public var bodyDestroyEnd:Number = 0;
		
		public var bodyTarget:Body;
		
		public var awaitingActivation:Boolean;
		
		public var stateMachine:StateMachine = new StateMachine();
		
		protected var g:Game;
		
		private var error:Point = null;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		
		private var convergeStartTime:Number;
		
		private var errorOldTime:Number;
		
		private var oldAngle:Number;
		
		public var teleportExitTime:Number = 0;
		
		public var teleportExitPoint:Point;
		
		public var hpRegen:int;
		
		public var factions:Vector.<String> = new Vector.<String>();
		
		public var uberDifficulty:Number = 0;
		
		public var uberLevelFactor:Number = 0;
		
		private var teleportDestinationImage:Image;
		
		private var teleportChannelImage:Image;
		
		public function Boss(g:Game)
		{
			super();
			canvas = g.canvasBosses;
			turrets = new Vector.<Turret>();
			spawners = new Vector.<Spawner>();
			bossComponents = new Vector.<BossComponent>();
			allComponents = new Vector.<Unit>();
			stateMachine = new StateMachine();
			course = new Heading();
			waypoints = new Vector.<Waypoint>();
			this.g = g;
			distanceToCamera = 0;
		}
		
		public function startTeleportEffect() : void
		{
			teleportDestinationImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			teleportDestinationImage.scaleX = teleportDestinationImage.scaleY = bossRadius * 2 / teleportDestinationImage.width;
			teleportDestinationImage.x = teleportExitPoint.x;
			teleportDestinationImage.y = teleportExitPoint.y;
			teleportDestinationImage.pivotX = teleportDestinationImage.texture.width / 2;
			teleportDestinationImage.pivotY = teleportDestinationImage.texture.height / 2;
			teleportDestinationImage.blendMode = "add";
			teleportDestinationImage.color = 0xff4444;
			TweenMax.fromTo(teleportDestinationImage,0.2,{"alpha":0.8},{
				"alpha":0.2,
				"yoyo":true,
				"repeat":-1
			});
			g.addChildToCanvas(teleportDestinationImage);
			teleportChannelImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			teleportChannelImage.scaleX = teleportChannelImage.scaleY = bossRadius * 2 / teleportChannelImage.width * 1.6;
			teleportChannelImage.x = this.x;
			teleportChannelImage.y = this.y;
			teleportChannelImage.pivotX = teleportChannelImage.texture.width / 2;
			teleportChannelImage.pivotY = teleportChannelImage.texture.height / 2;
			teleportChannelImage.blendMode = "add";
			teleportChannelImage.color = 0xff4444;
			TweenMax.fromTo(teleportChannelImage,(teleportExitTime - g.time) / 1000 / 3,{
				"alpha":0,
				"scaleX":teleportChannelImage.scaleX,
				"scaleY":teleportChannelImage.scaleY
			},{
				"alpha":0.8,
				"scaleX":teleportChannelImage.scaleX / 1.6,
				"scaleY":teleportChannelImage.scaleY / 1.6,
				"repeat":3,
				"onComplete":function():void
				{
					g.removeChildFromCanvas(teleportChannelImage);
				}
			});
			g.addChildToCanvas(teleportChannelImage);
		}
		
		public function endTeleportEffect() : void
		{
			var splashImage1:Image;
			var splashImage2:Image;
			var splashImage3:Image;
			TweenMax.killTweensOf(teleportDestinationImage);
			g.removeChildFromCanvas(teleportDestinationImage);
			splashImage1 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage1.scaleX = splashImage1.scaleY = bossRadius * 2 / splashImage1.width;
			splashImage1.x = teleportExitPoint.x;
			splashImage1.y = teleportExitPoint.y;
			splashImage1.pivotX = splashImage1.texture.width / 2;
			splashImage1.pivotY = splashImage1.texture.height / 2;
			splashImage1.blendMode = "add";
			splashImage1.color = 0xff4444;
			g.addChildToCanvas(splashImage1);
			TweenMax.fromTo(splashImage1,0.3,{
				"scaleX":splashImage1.scaleX,
				"scaleY":splashImage1.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage1.scaleX * 2,
				"scaleY":splashImage1.scaleY * 2,
				"alpha":0,
				"onComplete":function():void
				{
					g.removeChildFromCanvas(splashImage1);
				}
			});
			splashImage2 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage2.scaleX = splashImage2.scaleY = bossRadius * 2 / splashImage2.width;
			splashImage2.x = teleportExitPoint.x;
			splashImage2.y = teleportExitPoint.y;
			splashImage2.pivotX = splashImage2.texture.width / 2;
			splashImage2.pivotY = splashImage2.texture.height / 2;
			splashImage2.blendMode = "add";
			splashImage2.color = 0xff4444;
			g.addChildToCanvas(splashImage2);
			TweenMax.fromTo(splashImage2,0.4,{
				"scaleX":splashImage2.scaleX,
				"scaleY":splashImage2.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage2.scaleX * 2,
				"scaleY":splashImage2.scaleY * 2,
				"alpha":0,
				"onComplete":function():void
				{
					g.removeChildFromCanvas(splashImage2);
				}
			});
			splashImage3 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage3.scaleX = splashImage3.scaleY = bossRadius * 2 / splashImage3.width;
			splashImage3.x = teleportExitPoint.x;
			splashImage3.y = teleportExitPoint.y;
			splashImage3.pivotX = splashImage3.texture.width / 2;
			splashImage3.pivotY = splashImage3.texture.height / 2;
			splashImage3.blendMode = "add";
			splashImage3.color = 0xff4444;
			g.addChildToCanvas(splashImage3);
			TweenMax.fromTo(splashImage3,0.6,{
				"scaleX":splashImage3.scaleX,
				"scaleY":splashImage3.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage3.scaleX * 2,
				"scaleY":splashImage3.scaleY * 2,
				"alpha":0,
				"onComplete":function():void
				{
					g.removeChildFromCanvas(splashImage3);
				}
			});
		}
		
		override public function update() : void
		{
			var _loc1_:Point = null;
			var _loc3_:Point = null;
			if(!alive || awaitingActivation)
			{
				return;
			}
			if(g.me.ship != null)
			{
				_loc1_ = this.pos;
				_loc3_ = g.me.ship.pos;
				distanceToCameraX = _loc1_.x - _loc3_.x;
				distanceToCameraY = _loc1_.y - _loc3_.y;
				distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			}
			if(nextDistanceCalculation <= 0)
			{
				updateIsNear();
			}
			else
			{
				nextDistanceCalculation -= 33;
			}
			stateMachine.update();
			var _loc4_:int = 0;
			hp = 0;
			for each(var _loc2_ in allComponents)
			{
				_loc2_.update();
				if(_loc2_.alive && _loc2_.essential)
				{
					hp += _loc2_.hp + _loc2_.shieldHp;
					_loc4_++;
				}
				if((!_loc2_.alive || !_loc2_.active) && !(_loc2_ is Spawner))
				{
					_loc2_.visible = false;
				}
			}
		}
		
		private function updateIsNear() : void
		{
			var _loc2_:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _loc1_:Number = distanceToCamera - _loc2_;
			nextDistanceCalculation = _loc1_ / (10 * 60) * 100;
			if(nextDistanceCalculation > 5000)
			{
				nextDistanceCalculation = 5000;
			}
			if(distanceToCamera < _loc2_)
			{
				if(isAddedToCanvas)
				{
					return;
				}
				addToCanvas();
			}
			else
			{
				if(!isAddedToCanvas)
				{
					return;
				}
				removeFromCanvas();
			}
		}
		
		override public function removeFromCanvas() : void
		{
			isAddedToCanvas = false;
			for each(var _loc1_ in allComponents)
			{
				_loc1_.removeFromCanvas();
			}
		}
		
		override public function addToCanvas() : void
		{
			isAddedToCanvas = true;
			for each(var _loc1_ in allComponents)
			{
				_loc1_.addToCanvas();
			}
		}
		
		public function addFactions() : void
		{
			for each(var _loc1_ in allComponents)
			{
				_loc1_.factions = factions;
			}
		}
		
		public function updateHeading(heading:Heading) : void
		{
			var _loc10_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc14_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc9_:int = 33;
			aiRemoveError(heading);
			oldAngle = course.rotation;
			if(angleTargetPos != null)
			{
				if(holonomic || rotationForced)
				{
					heading.rotation = Math.atan2(angleTargetPos.y - course.pos.y,angleTargetPos.x - course.pos.x);
				}
				else
				{
					_loc10_ = Math.atan2(angleTargetPos.y - course.pos.y,angleTargetPos.x - course.pos.x);
					_loc11_ = Util.angleDifference(course.rotation,_loc10_ + 3.141592653589793);
					_loc12_ = rotationSpeed * _loc9_ / 1000;
					if(_loc11_ > 0 && _loc11_ < 3.141592653589793 - _loc12_)
					{
						heading.rotation += _loc12_;
						heading.rotation = Util.clampRadians(heading.rotation);
					}
					else if(_loc11_ <= 0 && _loc11_ > -3.141592653589793 + _loc12_)
					{
						heading.rotation -= _loc12_;
						heading.rotation = Util.clampRadians(heading.rotation);
					}
					else
					{
						heading.rotation = Util.clampRadians(_loc10_);
					}
				}
			}
			if(heading.accelerate)
			{
				if(angleTargetPos != null && (holonomic || rotationForced))
				{
					_loc2_ = pos.x - angleTargetPos.x;
					_loc5_ = pos.y - angleTargetPos.y;
					_loc14_ = _loc2_ * _loc2_ + _loc5_ * _loc5_;
					if(_loc14_ > 1.1025 * (targetRange * targetRange))
					{
						_loc13_ = 1;
					}
					else if(_loc14_ < 0.9025 * (targetRange * targetRange))
					{
						_loc13_ = -1;
					}
					else
					{
						_loc13_ = 0;
						heading.speed.x = 0.98 * heading.speed.x;
						heading.speed.y = 0.98 * heading.speed.y;
					}
				}
				else
				{
					_loc13_ = 1;
				}
				_loc3_ = heading.speed.x;
				_loc4_ = heading.speed.y;
				_loc3_ += _loc13_ * (Math.cos(heading.rotation) * acceleration * 0.5 * Math.pow(_loc9_,2));
				_loc4_ += _loc13_ * (Math.sin(heading.rotation) * acceleration * 0.5 * Math.pow(_loc9_,2));
				if(_loc3_ * _loc3_ + _loc4_ * _loc4_ <= speed * speed)
				{
					heading.speed.x = _loc3_;
					heading.speed.y = _loc4_;
				}
				else
				{
					_loc6_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
					_loc8_ = _loc3_ / _loc6_ * speed;
					_loc7_ = _loc4_ / _loc6_ * speed;
					heading.speed.x = _loc8_;
					heading.speed.y = _loc7_;
				}
			}
			heading.speed.x -= 0.009 * heading.speed.x;
			heading.speed.y -= 0.009 * heading.speed.y;
			heading.pos.x += heading.speed.x * _loc9_ / 1000;
			heading.pos.y += heading.speed.y * _loc9_ / 1000;
			heading.time += _loc9_;
			if(holonomic || rotationForced)
			{
				course.rotation = oldAngle;
			}
			aiAddError(heading);
		}
		
		public function calcHpMax() : void
		{
			hp = 0;
			hpMax = 0;
			for each(var _loc1_ in allComponents)
			{
				if(_loc1_.essential)
				{
					hp += _loc1_.hp + _loc1_.shieldHp;
					hpMax += _loc1_.hpMax + _loc1_.shieldHpMax;
				}
			}
		}
		
		private function aiAddError(heading:Heading) : void
		{
			var _loc2_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = NaN;
			if(error != null)
			{
				_loc2_ = g.time;
				_loc4_ = (convergeTime - (_loc2_ - convergeStartTime)) / convergeTime;
				_loc3_ = 3 * _loc4_ * _loc4_ - 2 * _loc4_ * _loc4_ * _loc4_;
				if(_loc4_ > 0)
				{
					heading.pos.x += _loc3_ * error.x;
					heading.pos.y += _loc3_ * error.y;
					heading.rotation += _loc3_ * errorAngle;
					errorOldTime = _loc2_;
				}
				else
				{
					error = null;
					errorOldTime = 0;
				}
			}
		}
		
		private function aiRemoveError(heading:Heading) : void
		{
			var _loc3_:Number = NaN;
			var _loc2_:Number = NaN;
			if(error != null && errorOldTime != 0)
			{
				_loc3_ = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
				_loc2_ = 3 * _loc3_ * _loc3_ - 2 * _loc3_ * _loc3_ * _loc3_;
				heading.pos.x -= _loc2_ * error.x;
				heading.pos.y -= _loc2_ * error.y;
				heading.rotation -= _loc2_ * errorAngle;
			}
		}
		
		public function setConvergeTarget(t:Heading) : void
		{
			error = new Point(course.pos.x - t.pos.x,course.pos.y - t.pos.y);
			errorAngle = Util.angleDifference(course.rotation,t.rotation);
			convergeStartTime = g.time;
			course.speed = t.speed;
			course.pos = t.pos;
			course.rotation = t.rotation;
			course.time = t.time;
			aiAddError(course);
		}
		
		public function overrideConvergeTarget(posx:Number, posy:Number) : void
		{
			error = null;
			errorAngle = 0;
			errorOldTime = 0;
			convergeStartTime = g.time;
			course.pos.x = posx;
			course.pos.y = posy;
			course.time = g.time;
		}
		
		public function destroy() : void
		{
			var _loc2_:Turret = null;
			var _loc1_:Spawner = null;
			var _loc4_:ISound = null;
			alive = false;
			for each(var _loc3_ in allComponents)
			{
				_loc3_.destroy(_loc3_.alive);
				_loc3_.alive = false;
				_loc3_.active = false;
				_loc3_.visible = false;
				if(_loc3_ is Turret)
				{
					_loc2_ = _loc3_ as Turret;
					if(_loc2_.weapon != null)
					{
						_loc2_.weapon.fire = false;
					}
					_loc2_.visible = false;
					g.turretManager.removeTurret(_loc2_);
				}
				if(_loc3_ is Spawner)
				{
					_loc1_ = _loc3_ as Spawner;
					_loc3_.destroy();
					g.spawnManager.removeSpawner(_loc1_);
				}
				g.unitManager.remove(_loc3_);
			}
			if(g.camera.isCircleOnScreen(pos.x,pos.y,radius))
			{
				if(explosionSound != "")
				{
					_loc4_ = SoundLocator.getService();
					_loc4_.play(explosionSound);
				}
				if(explosionEffect != "")
				{
					EmitterFactory.create(explosionEffect,g,pos.x,pos.y,null,true);
				}
			}
		}
		
		public function getComponent(id:int) : Unit
		{
			for each(var _loc2_ in allComponents)
			{
				if(_loc2_.syncId == id)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		override public function draw() : void
		{
			if(awaitingActivation)
			{
				return;
			}
			for each(var _loc1_ in allComponents)
			{
				_loc1_.draw();
			}
		}
	}
}

