package core.drops {
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.hud.components.BeamLine;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.geom.Point;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Drop extends GameObject {
		public var key:String;
		public var collisionRadius:Number;
		public var speed:Point = new Point();
		public var size:int;
		public var quantity:int;
		public var expireTime:Number;
		public var tractorBeamPlayer:Player;
		public var effect:Vector.<Emitter>;
		public var expired:Boolean;
		protected var _picked:Boolean;
		protected var g:Game;
		private var fadeTween:TweenMax = null;
		private var randAngleSpeed:Number;
		private var beamLine:BeamLine;
		public var obj:Object;
		
		public function Drop(g:Game) {
			super();
			this.g = g;
			canvas = g.canvasDrops;
			beamLine = g.beamLinePool.getLine();
			beamLine.init(1,3,3,0xaaaaff,0.6,3,0x6699ff);
			randAngleSpeed = Math.random() / 12;
		}
		
		public function pickup(p:Player, m:Message, i:int) : Boolean {
			var _local4:PlayerShip = null;
			var _local5:Point = null;
			var _local6:ISound = null;
			if(_picked) {
				return true;
			}
			if(tractorBeamPlayer != null && tractorBeamPlayer.ship != null && tractorBeamPlayer.ship.course != null) {
				_local4 = tractorBeamPlayer.ship;
				_local5 = new Point(_local4.course.pos.x - pos.x,_local4.course.pos.y - pos.y);
				if(_local5.x * _local5.x + _local5.y * _local5.y > _local4.collisionRadius * _local4.collisionRadius) {
					return false;
				}
			}
			_picked = true;
			if(p.isMe) {
				_local6 = SoundLocator.getService();
				_local6.play("05TMoG1kxEiXVZJ_OPhD_A");
				p.checkPickupMessage(m,i);
			}
			expire();
			return true;
		}
		
		override public function update() : void {
			tractorBeamUpdate();
			pos.x += speed.x;
			pos.y += speed.y;
			speed.x *= 0.9;
			speed.y *= 0.9;
			if(isAddedToCanvas && !fadeTween && expireTime - g.time < 10000 && expireTime != 0) {
				fadeTween = TweenMax.fromTo(this,0.4,{"alpha":1},{
					"alpha":0.4,
					"yoyo":true,
					"repeat":-1
				});
			}
			if(g.time > expireTime && expireTime != 0) {
				expire();
			}
			rotation += randAngleSpeed;
			if(nextDistanceCalculation <= 0) {
				updateIsNear();
			} else {
				nextDistanceCalculation -= 33;
			}
		}
		
		public function updateIsNear() : void {
			if(g.me.ship == null) {
				return;
			}
			var _local4:Point = this.pos;
			var _local3:Point = g.camera.getCameraCenter();
			distanceToCameraX = _local4.x - _local3.x;
			distanceToCameraY = _local4.y - _local3.y;
			var _local2:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _local1:Number = distanceToCamera - _local2;
			nextDistanceCalculation = _local1 / (5 * 60) * 1000;
			if(distanceToCamera < _local2) {
				if(isAddedToCanvas) {
					return;
				}
				addToCanvasForReal();
			} else {
				if(!isAddedToCanvas) {
					return;
				}
				removeFromCanvas();
			}
		}
		
		public function addToCanvasForReal() : void {
			if(!effect && !expired) {
				effect = EmitterFactory.create(obj.effect,g,pos.x,pos.y,this,true);
				if(key == "ZhiKr_lV5ka9I-Fio7APMg") {
					effect[0].play();
				}
			}
			g.hud.radar.add(this);
			addToCanvas();
		}
		
		public function tractorBeamUpdate() : void {
			if(!isAddedToCanvas || tractorBeamPlayer == null || tractorBeamPlayer.ship == null || tractorBeamPlayer.ship.course == null) {
				beamLine.visible = false;
				return;
			}
			beamLine.visible = true;
			var _local5:PlayerShip = tractorBeamPlayer.ship;
			var _local8:Number = _local5.course.pos.x - pos.x;
			var _local9:Number = _local5.course.pos.y - pos.y;
			var _local3:Number = Math.sqrt(_local8 * _local8 + _local9 * _local9);
			var _local2:Number = _local8 / _local3;
			var _local4:Number = _local9 / _local3;
			var _local1:Number = 33;
			var _local6:Number = _local5.speed.length * _local1 / 1000;
			var _local7:Number = _local6 + 5;
			speed.x = _local2 * _local7;
			speed.y = _local4 * _local7;
		}
		
		public function expire() : void {
			if(effect) {
				for each(var _local1:* in effect) {
					_local1.killEmitter();
				}
			}
			if(fadeTween != null) {
				fadeTween.kill();
			}
			_picked = false;
			expired = true;
		}
		
		override public function reset() : void {
			collisionRadius = 0;
			speed.x = 0;
			speed.y = 0;
			g.emitterManager.clean(this);
			effect = null;
			name = "";
			key = "";
			obj = null;
			id = 0;
			_picked = false;
			expired = false;
			expireTime = 0;
			if(fadeTween != null) {
				fadeTween.kill();
			}
			fadeTween = null;
			tractorBeamPlayer = null;
			beamLine.clear();
			g.beamLinePool.removeLine(beamLine);
			super.reset();
		}
		
		override public function draw() : void {
			drawBeamEffect();
			super.draw();
		}
		
		private function drawBeamEffect() : void {
			if(!isAddedToCanvas || tractorBeamPlayer == null || tractorBeamPlayer.ship == null || beamLine == null) {
				return;
			}
			if(tractorBeamPlayer.isTractorBeamActive()) {
				beamLine.color = 12551935;
				beamLine.nodeFrequence = 6;
				beamLine.amplitude = 4;
			} else {
				beamLine.color = 0xffffff;
				beamLine.nodeFrequence = 3;
				beamLine.amplitude = 3;
			}
			var _local1:Point = tractorBeamPlayer.ship.pos;
			if(Math.abs(_local1.x - this.pos.x) > 200) {
				return;
			}
			if(Math.abs(_local1.y - this.pos.y) > 200) {
				return;
			}
			beamLine.x = this.pos.x;
			beamLine.y = this.pos.y;
			beamLine.lineTo(_local1.x,_local1.y);
		}
		
		override public function addToCanvas() : void {
			canvas.addChild(beamLine);
			super.addToCanvas();
		}
		
		override public function removeFromCanvas() : void {
			var _local1:int = 0;
			if(effect) {
				_local1 = 0;
				while(_local1 < effect.length) {
					effect[_local1].alive = false;
					_local1++;
				}
				effect = null;
			}
			canvas.removeChild(beamLine);
			g.hud.radar.remove(this);
			super.removeFromCanvas();
		}
	}
}

