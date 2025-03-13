package core.weapon {
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
	
	public class Beam extends Weapon {
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
		
		public function Beam(g:Game) {
			super(g);
			lineBatch.blendMode = "add";
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void {
			var _local7:int = 0;
			var _local5:Object = null;
			var _local6:int = 0;
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
			this.obj = obj;
			drawBeam = false;
			if(obj.hasOwnProperty("nrTargets")) {
				nrTargets = obj.nrTargets;
			} else {
				nrTargets = 1;
			}
			if(obj.hasOwnProperty("chargeUp")) {
				chargeUpMax = obj.chargeUp;
			} else {
				chargeUpMax = 0;
			}
			if(obj.hasOwnProperty("twin")) {
				twin = obj.twin;
				twinOffset = obj.twinOffset;
			}
			beamNodes = obj.beamNodes;
			if(techLevel > 0) {
				_local6 = 100;
				_local7 = 0;
				while(_local7 < techLevel) {
					_local5 = obj.techLevels[_local7];
					_local6 += _local5.incInterval;
					if(_local5.hasOwnProperty("incNrTargets")) {
						nrTargets += _local5.incNrTargets;
					}
					if(_local5.hasOwnProperty("incChargeUp")) {
						chargeUpMax += _local5.incChargeUp;
					}
					if(_local7 == techLevel - 1) {
						beamColor = _local5.beamColor;
						beams = _local5.beams;
						beamAmplitude = _local5.beamAmplitude;
						beamThickness = _local5.beamThickness;
						beamAlpha = _local5.beamAlpha;
						startBeamAlpha = beamAlpha;
						glowColor = _local5.glowColor;
					}
					_local7++;
				}
			} else {
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
		
		private function initEffects() : void {
			var _local4:int = 0;
			var _local1:BeamLine = null;
			startEffect = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
			endEffect = EmitterFactory.create(obj.hitEffect,g,0,0,null,false);
			var _local2:int = 0;
			var _local3:int = beams;
			_local4 = 0;
			while(_local4 < nrTargets) {
				_local2 += _local3 <= 0 ? 1 : _local3;
				_local3--;
				_local4++;
			}
			if(twin) {
				startEffect2 = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
				_local2 = 2 * _local2;
			}
			_local4 = 0;
			while(_local4 < _local2) {
				_local1 = g.beamLinePool.getLine();
				_local1.init(beamThickness,beamNodes,beamAmplitude,beamColor,beamAlpha,4,glowColor);
				lines.push(_local1);
				_local4++;
			}
			effectsInitialized = true;
		}
		
		override public function destroy() : void {
			for each(var _local2 in startEffect) {
				_local2.alive = false;
			}
			if(twin) {
				for each(_local2 in startEffect2) {
					_local2.alive = false;
				}
			}
			for each(var _local1 in endEffect) {
				_local1.alive = false;
			}
			fire = false;
			effectsInitialized = false;
			lineBatch.clear();
			g.canvasEffects.removeChild(lineBatch);
			super.destroy();
		}
		
		override protected function shoot() : void {
			var _local10:ISound = null;
			var _local3:PlayerShip = null;
			if(!effectsInitialized) {
				initEffects();
			}
			if(targetBody != null) {
				return;
			}
			if(g.time - lastDamaged > chargeUpExpire) {
				chargeUPCurrent = 0;
			}
			if(drawBeam && !oldDrawBeam) {
				if(fireSound != null && g.camera.isCircleOnScreen(unit.x,unit.y,unit.radius)) {
					_local10 = SoundLocator.getService();
					_local10.play(fireSound);
				}
			}
			oldDrawBeam = drawBeam;
			var _local5:Number = unit.weaponPos.y + positionOffsetY;
			var _local4:Number = unit.weaponPos.x + positionOffsetX;
			var _local7:Number = Math.sqrt(_local4 * _local4 + _local5 * _local5);
			var _local9:Number = Math.atan2(_local5,_local4);
			if(unit.forcedRotation) {
				if(twin) {
					startPos.x = unit.x + Math.cos(_local9 + unit.forcedRotationAngle) * _local7 + Math.cos(_local9 + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos.y = unit.y + Math.sin(_local9 + unit.forcedRotationAngle) * _local7 + Math.sin(_local9 + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos2.x = unit.x + Math.cos(_local9 + unit.forcedRotationAngle) * _local7 + Math.cos(_local9 + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
					startPos2.y = unit.y + Math.sin(_local9 + unit.forcedRotationAngle) * _local7 + Math.sin(_local9 + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
				} else {
					startPos.x = unit.x + Math.cos(_local9 + unit.forcedRotationAngle) * _local7;
					startPos.y = unit.y + Math.sin(_local9 + unit.forcedRotationAngle) * _local7;
				}
			} else if(twin) {
				startPos.x = unit.x + Math.cos(unit.rotation + _local9) * _local7 + Math.cos(unit.rotation + _local9 + 0.5 * 3.141592653589793) * twinOffset;
				startPos.y = unit.y + Math.sin(unit.rotation + _local9) * _local7 + Math.sin(unit.rotation + _local9 + 0.5 * 3.141592653589793) * twinOffset;
				startPos2.x = unit.x + Math.cos(unit.rotation + _local9) * _local7 + Math.cos(unit.rotation + _local9 - 0.5 * 3.141592653589793) * twinOffset;
				startPos2.y = unit.y + Math.sin(unit.rotation + _local9) * _local7 + Math.sin(unit.rotation + _local9 - 0.5 * 3.141592653589793) * twinOffset;
			} else {
				startPos.x = unit.x + Math.cos(unit.rotation + _local9) * _local7;
				startPos.y = unit.y + Math.sin(unit.rotation + _local9) * _local7;
			}
			updateTargetOrder();
			var _local8:Number = unit.rotation;
			for each(var _local2 in startEffect) {
				_local2.posX = startPos.x;
				_local2.posY = startPos.y;
				_local2.angle = _local8;
			}
			if(twin) {
				for each(_local2 in startEffect2) {
					_local2.posX = startPos2.x;
					_local2.posY = startPos2.y;
					_local2.angle = _local8;
				}
			}
			if(target == null || !target.alive) {
				chargeUpCounter = 0;
				target = null;
				beamAlpha = startBeamAlpha / 3;
				endPos.x = unit.x + Math.cos(unit.rotation + _local9) * range;
				endPos.y = unit.y + Math.sin(unit.rotation + _local9) * range;
				for each(var _local1 in endEffect) {
					_local1.posX = endPos.x;
					_local1.posY = endPos.y;
					_local1.angle = _local8 - 3.141592653589793;
				}
				drawBeam = true;
				updateEmitters();
				return;
			}
			beamAlpha = startBeamAlpha;
			lastDamaged = g.time;
			if(fireNextTime < g.time) {
				if(unit is PlayerShip) {
					_local3 = unit as PlayerShip;
					if(!_local3.weaponHeat.canFire(heatCost)) {
						fireNextTime += reloadTime;
						return;
					}
				}
				if(lastFire == 0 || fireNextTime == 0) {
					fireNextTime = g.time + reloadTime - 33;
				} else {
					fireNextTime += reloadTime;
				}
				lastFire = g.time;
				chargeUpCounter++;
				if(chargeUpCounter > chargeUpNext && chargeUPCurrent < chargeUpMax) {
					chargeUpCounter = 0;
					chargeUPCurrent++;
				}
			}
			endPos.x = target.pos.x;
			endPos.y = target.pos.y;
			var _local6:Number = endPos.x - startPos.x;
			var _local11:Number = endPos.y - startPos.y;
			_local8 = Math.atan2(_local11,_local6);
			for each(_local1 in endEffect) {
				_local1.posX = endPos.x;
				_local1.posY = endPos.y;
				_local1.angle = _local8 - 3.141592653589793;
			}
			drawBeam = true;
			updateEmitters();
		}
		
		private function updateTargetOrder() : void {
			var _local1:Unit = null;
			if(target == null || !target.alive) {
				while(secondaryTargets.length > 0) {
					_local1 = secondaryTargets[0];
					secondaryTargets.splice(0,1);
					if(_local1.alive) {
						target = _local1;
						return;
					}
				}
			}
		}
		
		private function updateEmitters() : void {
			if(drawBeam == oldDrawBeam) {
				return;
			}
			if(drawBeam) {
				for each(var _local3 in lines) {
					lineBatch.addMesh(_local3);
				}
				g.canvasEffects.addChild(lineBatch);
				for each(var _local2 in endEffect) {
					_local2.play();
				}
			} else {
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _local1 in endEffect) {
					_local1.stop();
				}
			}
		}
		
		public function fireAtBody(b:Body) : void {
			var _local9:Number = NaN;
			targetBody = b;
			if(b == null) {
				drawBeam = false;
				fire = false;
				updateEmitters();
				return;
			}
			oldDrawBeam = drawBeam;
			_local9 = unit.rotation;
			var _local5:Number = unit.weaponPos.y;
			var _local4:Number = unit.weaponPos.x;
			var _local7:Number = Math.sqrt(_local4 * _local4 + _local5 * _local5);
			var _local8:Number = Math.atan2(_local5,_local4);
			startPos.x = unit.x + Math.cos(unit.rotation + _local8 + unit.forcedRotationAngle) * _local7;
			startPos.y = unit.y + Math.sin(unit.rotation + _local8 + unit.forcedRotationAngle) * _local7;
			for each(var _local3 in startEffect) {
				_local3.posX = startPos.x;
				_local3.posY = startPos.y;
				_local3.angle = _local9;
			}
			endPos.x = b.pos.x;
			endPos.y = b.pos.y;
			drawBeam = true;
			var _local6:Number = endPos.x - startPos.x;
			var _local10:Number = endPos.y - startPos.y;
			_local7 = Math.sqrt(_local6 * _local6 + _local10 * _local10);
			if(_local7 > 0.6 * b.radius) {
				_local7 = (_local7 - 0.6 * b.radius) / _local7;
			} else {
				_local7 = _local7 * 0.6 / _local7;
			}
			endPos.x = startPos.x + _local6 * _local7;
			endPos.y = startPos.y + _local10 * _local7;
			_local9 = Math.atan2(_local10,_local6);
			for each(var _local2 in endEffect) {
				_local2.posX = endPos.x;
				_local2.posY = endPos.y;
				_local2.angle = _local9 - 3.141592653589793;
			}
			updateEmitters();
		}
		
		private function drawBeamEffect(i:int, sPos:Point, ePos:Point, nrBeams:int) : int {
			var _local8:int = 0;
			var _local7:BeamLine = null;
			var _local6:Number = ePos.x - sPos.x;
			var _local10:Number = ePos.y - sPos.y;
			var _local5:int = _local6 * _local6 + _local10 * _local10;
			if(_local5 < 1 || _local5 > 400 * 60 * 60 || lines.length < 1 || lines.length - 1 < i) {
				return i + 1;
			}
			var _local9:Number = 0;
			_local8 = 0;
			while(_local8 < nrBeams) {
				if(chargeUpMax > 0) {
					_local9 = chargeUPCurrent / chargeUpMax * 1 * beamThickness;
				} else {
					_local9 = 0;
				}
				_local7 = lines[i];
				_local7.x = sPos.x;
				_local7.y = sPos.y;
				_local7.lineTo(ePos.x,ePos.y,_local9);
				_local7.visible = true;
				i += 1;
				_local8++;
			}
			return i;
		}
		
		override public function draw() : void {
			var _local3:BeamLine = null;
			var _local7:int = 0;
			var _local6:Heat = null;
			var _local4:int = 0;
			var _local1:Unit = null;
			if(!drawBeam) {
				return;
			}
			var _local5:Number = 0;
			if(g.me.ship != null) {
				_local6 = g.me.ship.weaponHeat;
				_local5 = _local6.heat / _local6.max * 1.5;
				if(_local5 > 1) {
					_local5 = 1;
				}
			}
			if(_local5 < 0.3) {
				_local5 = 0.3;
			}
			_local7 = 0;
			while(_local7 < lines.length) {
				_local3 = lines[_local7];
				_local3.alpha = _local5 * beamAlpha;
				_local3.visible = false;
				_local7++;
			}
			if(twin) {
				_local7 = drawBeamEffect(0,startPos,endPos,beams);
				_local7 = drawBeamEffect(_local7,startPos2,endPos,beams);
			} else {
				_local7 = drawBeamEffect(0,startPos,endPos,beams);
			}
			lastPos.x = endPos.x;
			lastPos.y = endPos.y;
			var _local2:int = beams;
			_local4 = 0;
			while(_local4 < secondaryTargets.length) {
				_local1 = secondaryTargets[_local4];
				if(_local1.alive) {
					if(_local2 > 1) {
						_local2--;
					}
					_local7 = drawBeamEffect(_local7,lastPos,_local1.pos,_local2);
					lastPos.x = _local1.pos.x;
					lastPos.y = _local1.pos.y;
				}
				_local4++;
			}
			lineBatch.clear();
			_local7 = 0;
			while(_local7 < lines.length) {
				_local3 = lines[_local7];
				if(_local3.visible) {
					lineBatch.addMesh(lines[_local7]);
				}
				_local7++;
			}
			lineBatch.alpha = _local5 * beamAlpha;
		}
		
		override public function set fire(value:Boolean) : void {
			if(targetBody != null || value == _fire) {
				return;
			}
			_fire = value;
			lastFire = 0;
			if(_fire == true) {
				for each(var _local5 in startEffect) {
					_local5.play();
				}
				if(twin) {
					for each(_local5 in startEffect2) {
						_local5.play();
					}
				}
			} else {
				drawBeam = false;
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _local4 in lines) {
					_local4.clear();
				}
				for each(var _local3 in startEffect) {
					_local3.stop();
				}
				if(twin) {
					for each(_local3 in startEffect2) {
						_local3.stop();
					}
				}
				for each(var _local2 in endEffect) {
					_local2.stop();
				}
			}
		}
	}
}

