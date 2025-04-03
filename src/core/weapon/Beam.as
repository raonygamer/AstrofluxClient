package core.weapon
{
	import core.hud.components.BeamLine;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import flash.geom.Point;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.MeshBatch;
	
	public class Beam extends Weapon
	{
		private var startEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var startEffect2:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var endEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		public var startPos:Point = new Point();
		
		public var startPos2:Point = new Point();
		
		public var endPos:Point = new Point();
		
		public var lastPos:Point = new Point();
		
		private var lines:Vector.<BeamLine> = new Vector.<BeamLine>();
		
		private var lineBatch:MeshBatch = new MeshBatch();
		
		private var ready:Boolean = false;
		
		public var nrTargets:int = 0;
		
		public var secondaryTargets:Vector.<Unit> = new Vector.<Unit>();
		
		private var beamColor:uint = 16777215;
		
		private var beamAmplitude:Number = 2;
		
		private var beamThickness:Number = 1;
		
		private var startBeamAlpha:Number = 1;
		
		private var beamAlpha:Number = 1;
		
		private var beams:int = 3;
		
		private var beamNodes:Number = 0;
		
		private var glowColor:uint = 16711680;
		
		private var oldDrawBeam:Boolean;
		
		private var drawBeam:Boolean;
		
		private var targetBody:Body;
		
		private var chargeUpMax:int;
		
		private var chargeUPCurrent:int = 0;
		
		private var chargeUpCounter:int = 0;
		
		private var chargeUpNext:int = 8;
		
		private var chargeUpExpire:Number = 2000;
		
		private var lastDamaged:Number = 0;
		
		private var twin:Boolean = false;
		
		private var twinOffset:Number = 0;
		
		private var obj:Object;
		
		private var effectsInitialized:Boolean = false;
		
		public function Beam(g:Game)
		{
			super(g);
			lineBatch.blendMode = "add";
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void
		{
			var _loc5_:int = 0;
			var _loc7_:Object = null;
			var _loc6_:int = 0;
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
			this.obj = obj;
			drawBeam = false;
			if(obj.hasOwnProperty("nrTargets"))
			{
				nrTargets = obj.nrTargets;
			}
			else
			{
				nrTargets = 1;
			}
			if(obj.hasOwnProperty("chargeUp"))
			{
				chargeUpMax = obj.chargeUp;
			}
			else
			{
				chargeUpMax = 0;
			}
			if(obj.hasOwnProperty("twin"))
			{
				twin = obj.twin;
				twinOffset = obj.twinOffset;
			}
			beamNodes = obj.beamNodes;
			if(techLevel > 0)
			{
				_loc6_ = 100;
				_loc5_ = 0;
				while(_loc5_ < techLevel)
				{
					_loc7_ = obj.techLevels[_loc5_];
					_loc6_ += _loc7_.incInterval;
					if(_loc7_.hasOwnProperty("incNrTargets"))
					{
						nrTargets += _loc7_.incNrTargets;
					}
					if(_loc7_.hasOwnProperty("incChargeUp"))
					{
						chargeUpMax += _loc7_.incChargeUp;
					}
					if(_loc5_ == techLevel - 1)
					{
						beamColor = _loc7_.beamColor;
						beams = _loc7_.beams;
						beamAmplitude = _loc7_.beamAmplitude;
						beamThickness = _loc7_.beamThickness;
						beamAlpha = _loc7_.beamAlpha;
						startBeamAlpha = beamAlpha;
						glowColor = _loc7_.glowColor;
					}
					_loc5_++;
				}
			}
			else
			{
				beamColor = obj.beamColor;
				beams = obj.beams;
				beamAmplitude = obj.beamAmplitude;
				beamThickness = obj.beamThickness;
				beamAlpha = obj.beamAlpha;
				startBeamAlpha = beamAlpha;
				glowColor = obj.glowColor;
			}
			ready = true;
		}
		
		private function initEffects() : void
		{
			var _loc4_:int = 0;
			var _loc3_:BeamLine = null;
			startEffect = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
			endEffect = EmitterFactory.create(obj.hitEffect,g,0,0,null,false);
			var _loc2_:int = 0;
			var _loc1_:int = beams;
			_loc4_ = 0;
			while(_loc4_ < nrTargets)
			{
				_loc2_ += _loc1_ <= 0 ? 1 : _loc1_;
				_loc1_--;
				_loc4_++;
			}
			if(twin)
			{
				startEffect2 = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
				_loc2_ = 2 * _loc2_;
			}
			_loc4_ = 0;
			while(_loc4_ < _loc2_)
			{
				_loc3_ = g.beamLinePool.getLine();
				_loc3_.init(beamThickness,beamNodes,beamAmplitude,beamColor,beamAlpha,4,glowColor);
				lines.push(_loc3_);
				_loc4_++;
			}
			effectsInitialized = true;
		}
		
		override public function destroy() : void
		{
			for each(var _loc1_ in startEffect)
			{
				_loc1_.alive = false;
			}
			if(twin)
			{
				for each(_loc1_ in startEffect2)
				{
					_loc1_.alive = false;
				}
			}
			for each(var _loc2_ in endEffect)
			{
				_loc2_.alive = false;
			}
			fire = false;
			effectsInitialized = false;
			lineBatch.clear();
			g.canvasEffects.removeChild(lineBatch);
			super.destroy();
		}
		
		override protected function shoot() : void
		{
			var _loc8_:ISound = null;
			var _loc2_:PlayerShip = null;
			if(!effectsInitialized)
			{
				initEffects();
			}
			if(targetBody != null)
			{
				return;
			}
			if(g.time - lastDamaged > chargeUpExpire)
			{
				chargeUPCurrent = 0;
			}
			if(drawBeam && !oldDrawBeam)
			{
				if(fireSound != null && g.camera.isCircleOnScreen(unit.x,unit.y,unit.radius))
				{
					_loc8_ = SoundLocator.getService();
					_loc8_.play(fireSound);
				}
			}
			oldDrawBeam = drawBeam;
			var _loc4_:Number = unit.weaponPos.y + positionOffsetY;
			var _loc3_:Number = unit.weaponPos.x + positionOffsetX;
			var _loc9_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
			var _loc7_:Number = Math.atan2(_loc4_,_loc3_);
			if(unit.forcedRotation)
			{
				if(twin)
				{
					startPos.x = unit.x + Math.cos(_loc7_ + unit.forcedRotationAngle) * _loc9_ + Math.cos(_loc7_ + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos.y = unit.y + Math.sin(_loc7_ + unit.forcedRotationAngle) * _loc9_ + Math.sin(_loc7_ + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos2.x = unit.x + Math.cos(_loc7_ + unit.forcedRotationAngle) * _loc9_ + Math.cos(_loc7_ + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
					startPos2.y = unit.y + Math.sin(_loc7_ + unit.forcedRotationAngle) * _loc9_ + Math.sin(_loc7_ + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
				}
				else
				{
					startPos.x = unit.x + Math.cos(_loc7_ + unit.forcedRotationAngle) * _loc9_;
					startPos.y = unit.y + Math.sin(_loc7_ + unit.forcedRotationAngle) * _loc9_;
				}
			}
			else if(twin)
			{
				startPos.x = unit.x + Math.cos(unit.rotation + _loc7_) * _loc9_ + Math.cos(unit.rotation + _loc7_ + 0.5 * 3.141592653589793) * twinOffset;
				startPos.y = unit.y + Math.sin(unit.rotation + _loc7_) * _loc9_ + Math.sin(unit.rotation + _loc7_ + 0.5 * 3.141592653589793) * twinOffset;
				startPos2.x = unit.x + Math.cos(unit.rotation + _loc7_) * _loc9_ + Math.cos(unit.rotation + _loc7_ - 0.5 * 3.141592653589793) * twinOffset;
				startPos2.y = unit.y + Math.sin(unit.rotation + _loc7_) * _loc9_ + Math.sin(unit.rotation + _loc7_ - 0.5 * 3.141592653589793) * twinOffset;
			}
			else
			{
				startPos.x = unit.x + Math.cos(unit.rotation + _loc7_) * _loc9_;
				startPos.y = unit.y + Math.sin(unit.rotation + _loc7_) * _loc9_;
			}
			updateTargetOrder();
			var _loc10_:Number = unit.rotation;
			for each(var _loc5_ in startEffect)
			{
				_loc5_.posX = startPos.x;
				_loc5_.posY = startPos.y;
				_loc5_.angle = _loc10_;
			}
			if(twin)
			{
				for each(_loc5_ in startEffect2)
				{
					_loc5_.posX = startPos2.x;
					_loc5_.posY = startPos2.y;
					_loc5_.angle = _loc10_;
				}
			}
			if(target == null || !target.alive)
			{
				chargeUpCounter = 0;
				target = null;
				beamAlpha = startBeamAlpha / 3;
				endPos.x = unit.x + Math.cos(unit.rotation + _loc7_) * range;
				endPos.y = unit.y + Math.sin(unit.rotation + _loc7_) * range;
				for each(var _loc11_ in endEffect)
				{
					_loc11_.posX = endPos.x;
					_loc11_.posY = endPos.y;
					_loc11_.angle = _loc10_ - 3.141592653589793;
				}
				drawBeam = true;
				updateEmitters();
				return;
			}
			beamAlpha = startBeamAlpha;
			lastDamaged = g.time;
			if(fireNextTime < g.time)
			{
				if(unit is PlayerShip)
				{
					_loc2_ = unit as PlayerShip;
					if(!_loc2_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += reloadTime;
						return;
					}
				}
				if(lastFire == 0 || fireNextTime == 0)
				{
					fireNextTime = g.time + reloadTime - 33;
				}
				else
				{
					fireNextTime += reloadTime;
				}
				lastFire = g.time;
				chargeUpCounter++;
				if(chargeUpCounter > chargeUpNext && chargeUPCurrent < chargeUpMax)
				{
					chargeUpCounter = 0;
					chargeUPCurrent++;
				}
			}
			endPos.x = target.pos.x;
			endPos.y = target.pos.y;
			var _loc1_:Number = endPos.x - startPos.x;
			var _loc6_:Number = endPos.y - startPos.y;
			_loc10_ = Math.atan2(_loc6_,_loc1_);
			for each(_loc11_ in endEffect)
			{
				_loc11_.posX = endPos.x;
				_loc11_.posY = endPos.y;
				_loc11_.angle = _loc10_ - 3.141592653589793;
			}
			drawBeam = true;
			updateEmitters();
		}
		
		private function updateTargetOrder() : void
		{
			var _loc1_:Unit = null;
			if(target == null || !target.alive)
			{
				while(secondaryTargets.length > 0)
				{
					_loc1_ = secondaryTargets[0];
					secondaryTargets.splice(0,1);
					if(_loc1_.alive)
					{
						target = _loc1_;
						return;
					}
				}
			}
		}
		
		private function updateEmitters() : void
		{
			if(drawBeam == oldDrawBeam)
			{
				return;
			}
			if(drawBeam)
			{
				for each(var _loc2_ in lines)
				{
					lineBatch.addMesh(_loc2_);
				}
				g.canvasEffects.addChild(lineBatch);
				for each(var _loc1_ in endEffect)
				{
					_loc1_.play();
				}
			}
			else
			{
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _loc3_ in endEffect)
				{
					_loc3_.stop();
				}
			}
		}
		
		public function fireAtBody(b:Body) : void
		{
			var _loc9_:Number = NaN;
			targetBody = b;
			if(b == null)
			{
				drawBeam = false;
				fire = false;
				updateEmitters();
				return;
			}
			oldDrawBeam = drawBeam;
			_loc9_ = unit.rotation;
			var _loc4_:Number = unit.weaponPos.y;
			var _loc3_:Number = unit.weaponPos.x;
			var _loc8_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
			var _loc7_:Number = Math.atan2(_loc4_,_loc3_);
			startPos.x = unit.x + Math.cos(unit.rotation + _loc7_ + unit.forcedRotationAngle) * _loc8_;
			startPos.y = unit.y + Math.sin(unit.rotation + _loc7_ + unit.forcedRotationAngle) * _loc8_;
			for each(var _loc5_ in startEffect)
			{
				_loc5_.posX = startPos.x;
				_loc5_.posY = startPos.y;
				_loc5_.angle = _loc9_;
			}
			endPos.x = b.pos.x;
			endPos.y = b.pos.y;
			drawBeam = true;
			var _loc2_:Number = endPos.x - startPos.x;
			var _loc6_:Number = endPos.y - startPos.y;
			_loc8_ = Math.sqrt(_loc2_ * _loc2_ + _loc6_ * _loc6_);
			if(_loc8_ > 0.6 * b.radius)
			{
				_loc8_ = (_loc8_ - 0.6 * b.radius) / _loc8_;
			}
			else
			{
				_loc8_ = _loc8_ * 0.6 / _loc8_;
			}
			endPos.x = startPos.x + _loc2_ * _loc8_;
			endPos.y = startPos.y + _loc6_ * _loc8_;
			_loc9_ = Math.atan2(_loc6_,_loc2_);
			for each(var _loc10_ in endEffect)
			{
				_loc10_.posX = endPos.x;
				_loc10_.posY = endPos.y;
				_loc10_.angle = _loc9_ - 3.141592653589793;
			}
			updateEmitters();
		}
		
		private function drawBeamEffect(i:int, sPos:Point, ePos:Point, nrBeams:int) : int
		{
			var _loc9_:int = 0;
			var _loc7_:BeamLine = null;
			var _loc5_:Number = ePos.x - sPos.x;
			var _loc6_:Number = ePos.y - sPos.y;
			var _loc8_:int = _loc5_ * _loc5_ + _loc6_ * _loc6_;
			if(_loc8_ < 1 || _loc8_ > 400 * 60 * 60 || lines.length < 1 || lines.length - 1 < i)
			{
				return i + 1;
			}
			var _loc10_:Number = 0;
			_loc9_ = 0;
			while(_loc9_ < nrBeams)
			{
				if(chargeUpMax > 0)
				{
					_loc10_ = chargeUPCurrent / chargeUpMax * 1 * beamThickness;
				}
				else
				{
					_loc10_ = 0;
				}
				_loc7_ = lines[i];
				_loc7_.x = sPos.x;
				_loc7_.y = sPos.y;
				_loc7_.lineTo(ePos.x,ePos.y,_loc10_);
				_loc7_.visible = true;
				i += 1;
				_loc9_++;
			}
			return i;
		}
		
		override public function draw() : void
		{
			var _loc3_:BeamLine = null;
			var _loc6_:int = 0;
			var _loc5_:Heat = null;
			var _loc7_:int = 0;
			var _loc2_:Unit = null;
			if(!drawBeam)
			{
				return;
			}
			var _loc1_:Number = 0;
			if(g.me.ship != null)
			{
				_loc5_ = g.me.ship.weaponHeat;
				_loc1_ = _loc5_.heat / _loc5_.max * 1.5;
				if(_loc1_ > 1)
				{
					_loc1_ = 1;
				}
			}
			if(_loc1_ < 0.3)
			{
				_loc1_ = 0.3;
			}
			_loc6_ = 0;
			while(_loc6_ < lines.length)
			{
				_loc3_ = lines[_loc6_];
				_loc3_.alpha = _loc1_ * beamAlpha;
				_loc3_.visible = false;
				_loc6_++;
			}
			if(twin)
			{
				_loc6_ = drawBeamEffect(0,startPos,endPos,beams);
				_loc6_ = drawBeamEffect(_loc6_,startPos2,endPos,beams);
			}
			else
			{
				_loc6_ = drawBeamEffect(0,startPos,endPos,beams);
			}
			lastPos.x = endPos.x;
			lastPos.y = endPos.y;
			var _loc4_:int = beams;
			_loc7_ = 0;
			while(_loc7_ < secondaryTargets.length)
			{
				_loc2_ = secondaryTargets[_loc7_];
				if(_loc2_.alive)
				{
					if(_loc4_ > 1)
					{
						_loc4_--;
					}
					_loc6_ = drawBeamEffect(_loc6_,lastPos,_loc2_.pos,_loc4_);
					lastPos.x = _loc2_.pos.x;
					lastPos.y = _loc2_.pos.y;
				}
				_loc7_++;
			}
			lineBatch.clear();
			_loc6_ = 0;
			while(_loc6_ < lines.length)
			{
				_loc3_ = lines[_loc6_];
				if(_loc3_.visible)
				{
					lineBatch.addMesh(lines[_loc6_]);
				}
				_loc6_++;
			}
			lineBatch.alpha = _loc1_ * beamAlpha;
		}
		
		override public function set fire(value:Boolean) : void
		{
			if(targetBody != null || value == _fire)
			{
				return;
			}
			_fire = value;
			lastFire = 0;
			if(_fire == true)
			{
				for each(var _loc3_ in startEffect)
				{
					_loc3_.play();
				}
				if(twin)
				{
					for each(_loc3_ in startEffect2)
					{
						_loc3_.play();
					}
				}
			}
			else
			{
				drawBeam = false;
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _loc2_ in lines)
				{
					_loc2_.clear();
				}
				for each(var _loc4_ in startEffect)
				{
					_loc4_.stop();
				}
				if(twin)
				{
					for each(_loc4_ in startEffect2)
					{
						_loc4_.stop();
					}
				}
				for each(var _loc5_ in endEffect)
				{
					_loc5_.stop();
				}
			}
		}
	}
}

