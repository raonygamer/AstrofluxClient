package core.ship {
	import core.particle.EmitterFactory;
	import core.player.Player;
	import core.scene.Game;
	import core.states.AIStates.AIChase;
	import core.states.AIStates.AIExit;
	import core.states.AIStates.AIFlee;
	import core.states.AIStates.AIFollow;
	import core.states.AIStates.AIIdle;
	import core.states.AIStates.AIKamikaze;
	import core.states.AIStates.AIMelee;
	import core.states.AIStates.AIObserve;
	import core.states.AIStates.AIOrbit;
	import core.states.AIStates.AIResurect;
	import core.states.AIStates.AIReturnOrbit;
	import core.states.AIStates.AITeleport;
	import core.states.AIStates.AITeleportExit;
	import core.sync.Converger;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import movement.Heading;
	import playerio.Message;
	
	public class ShipSync {
		private var g:Game;
		
		public function ShipSync(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("aiCourse",aiCourse);
			g.addMessageHandler("mirrorCourse",mirrorCourse);
			g.addMessageHandler("AIStickyStart",aiStickyStart);
			g.addMessageHandler("AIStickyEnd",aiStickyEnd);
		}
		
		public function playerCourse(m:Message, i:int = 0) : void {
			var _local5:Dictionary = g.playerManager.playersById;
			var _local4:String = m.getString(i);
			var _local9:Heading = new Heading();
			_local9.parseMessage(m,i + 1);
			var _local6:Player = _local5[_local4];
			if(_local6 == null || _local6.ship == null) {
				return;
			}
			var _local7:Ship = _local6.ship;
			if(_local7.getConverger() == null || _local7.course == null) {
				return;
			}
			var _local8:Converger = _local7.getConverger();
			var _local3:Heading = _local7.course;
			if(_local3 == null) {
				return;
			}
			if(_local6.isMe) {
				fastforwardMe(_local7,_local9);
				if(!_local3.almostEqual(_local9)) {
					_local8.setConvergeTarget(_local9);
				}
			} else {
				_local3.accelerate = _local9.accelerate;
				_local3.rotateLeft = _local9.rotateLeft;
				_local3.rotateRight = _local9.rotateRight;
				_local8.setConvergeTarget(_local9);
			}
		}
		
		public function playerUsedBoost(m:Message, i:int) : void {
			var _local5:Dictionary = g.playerManager.playersById;
			var _local4:String = m.getString(i);
			var _local9:Heading = new Heading();
			_local9.parseMessage(m,i + 1);
			var _local6:Player = _local5[_local4];
			if(_local6 == null || _local6.ship == null) {
				return;
			}
			var _local7:PlayerShip = _local6.ship;
			var _local8:Converger = _local7.getConverger();
			var _local3:Heading = _local7.course;
			if(_local3 == null || _local8 == null) {
				return;
			}
			if(_local6.isMe) {
				fastforwardMe(_local7,_local9);
				if(!_local3.almostEqual(_local9)) {
					_local8.setConvergeTarget(_local9);
				}
			} else {
				_local3.accelerate = true;
				_local3.deaccelerate = false;
				_local3.rotateLeft = false;
				_local3.rotateRight = false;
				_local7.boost();
				_local8.setConvergeTarget(_local9);
			}
		}
		
		public function aiCourse(m:Message) : void {
			var _local9:int = 0;
			var _local11:int = 0;
			var _local15:Heading = null;
			var _local2:EnemyShip = null;
			var _local7:int = 0;
			var _local12:String = null;
			var _local14:Unit = null;
			var _local5:int = 0;
			var _local8:int = 0;
			var _local3:String = null;
			var _local6:Boolean = false;
			var _local4:Unit = null;
			var _local13:Dictionary = g.shipManager.enemiesById;
			_local9 = 0;
			while(_local9 < m.length) {
				_local11 = m.getInt(_local9);
				_local15 = new Heading();
				_local15.parseMessage(m,_local9 + 1);
				_local2 = _local13[_local11];
				if(_local2 == null) {
					Console.write("Error bad enemy id in course sync: " + _local11);
					return;
				}
				if(!_local2.aiCloak) {
					_local2.setConvergeTarget(_local15);
				}
				_local7 = m.getInt(_local9 + 1 + 10);
				_local12 = m.getString(_local9 + 2 + 10);
				_local14 = g.unitManager.getTarget(_local7);
				_local2.target = _local14;
				if(!_local2.stateMachine.inState(_local12)) {
					switch(_local6) {
						case "AIChase":
							_local2.stateMachine.changeState(new AIChase(g,_local2,_local14,_local15,0));
							break;
						case "AIFollow":
							_local2.stateMachine.changeState(new AIFollow(g,_local2,_local14,_local15,0));
							break;
						case "AIMelee":
							_local2.stateMachine.changeState(new AIMelee(g,_local2,_local14,_local15,0));
					}
				}
				_local5 = m.getInt(_local9 + 3 + 10);
				_local8 = 0;
				while(_local8 < _local5) {
					_local3 = m.getString(_local9 + _local8 * 3 + 4 + 10);
					_local6 = m.getBoolean(_local9 + _local8 * 3 + 5 + 10);
					_local4 = g.unitManager.getTarget(m.getInt(_local9 + _local8 * 3 + 6 + 10));
					for each(var _local10 in _local2.weapons) {
						if(_local10.name == _local3) {
							_local10.fire = _local6;
							_local10.target = _local4;
						}
					}
					_local8++;
				}
				_local9 += _local5 * 3;
				_local9 = _local9 + (4 + 10);
			}
		}
		
		public function mirrorCourse(m:Message) : void {
			var _local2:Ship = g.playerManager.me.mirror;
			if(_local2 == null) {
				return;
			}
			var _local3:Heading = new Heading();
			_local3.parseMessage(m,0);
			_local2.course = _local3;
		}
		
		public function aiStickyStart(m:Message) : void {
			var _local4:Dictionary = g.shipManager.enemiesById;
			var _local3:int = m.getInt(0);
			var _local6:int = m.getInt(1);
			var _local2:EnemyShip = _local4[_local3];
			var _local5:Unit = g.unitManager.getTarget(_local6);
			if(_local2 == null || !_local2.alive || _local5 == null) {
				return;
			}
			if(_local2.meleeChargeEndTime != 0) {
				_local2.meleeChargeEndTime = 1;
			}
			_local2.target = _local5;
			_local2.meleeOffset = new Point(m.getNumber(2),m.getNumber(3));
			_local2.meleeTargetStartAngle = m.getNumber(4);
			_local2.meleeTargetAngleDiff = m.getNumber(5);
			_local2.meleeStuck = true;
		}
		
		public function aiStickyEnd(m:Message) : void {
			var _local4:Dictionary = g.shipManager.enemiesById;
			var _local3:int = m.getInt(0);
			var _local2:EnemyShip = _local4[_local3];
			if(_local2 == null || !_local2.alive) {
				return;
			}
			_local2.meleeStuck = false;
		}
		
		public function aiCharge(m:Message, i:int) : void {
			var _local5:Dictionary = g.shipManager.enemiesById;
			var _local4:int = m.getInt(i);
			var _local3:EnemyShip = _local5[_local4];
			if(_local3 == null || !_local3.alive) {
				return;
			}
			_local3.meleeChargeEndTime = g.time + _local3.meleeChargeDuration;
			_local3.oldSpeed = _local3.engine.speed;
			_local3.oldTurningSpeed = _local3.engine.rotationSpeed;
			_local3.engine.rotationSpeed = 0;
			_local3.course.rotation = m.getNumber(i + 1);
			_local3.engine.speed = (1 + _local3.meleeChargeSpeedBonus) * _local3.engine.speed;
			_local3.chargeEffect = EmitterFactory.create("nHVuxJzeyE-JVcn7M-UOwA",g,_local3.pos.x,_local3.pos.y,_local3,true);
		}
		
		public function aiStateChanged(m:Message, i:int = 0) : void {
			var _local11:Dictionary = null;
			var _local9:int = 0;
			var _local4:String = null;
			var _local7:int = 0;
			var _local13:Heading = null;
			var _local3:EnemyShip = null;
			var _local5:int = 0;
			var _local12:Unit = null;
			var _local8:Number = NaN;
			var _local10:Number = NaN;
			var _local6:Point = null;
			try {
				_local11 = g.shipManager.enemiesById;
				_local9 = m.getInt(i);
				_local4 = m.getString(i + 1);
				_local7 = m.getInt(i + 2);
				_local13 = new Heading();
				i = _local13.parseMessage(m,i + 3);
				_local3 = _local11[_local9];
				if(_local3 == null || !_local3.alive) {
					return;
				}
				switch(_local4) {
					case "AICloakStarted":
						_local3.cloakStart();
						break;
					case "AICloakEnded":
						_local3.cloakEnd(_local13);
						break;
					case "AIHardenShield":
						_local3.hardenShield();
						break;
					case "AIObserve":
						_local5 = m.getInt(i);
						_local12 = g.unitManager.getTarget(_local5);
						if(_local12 != null) {
							_local3.stateMachine.changeState(new AIObserve(g,_local3,_local12,_local13,_local7));
						} else {
							Console.write("No Ai target: " + _local5);
						}
						break;
					case "AIChase":
						_local5 = m.getInt(i);
						_local12 = g.unitManager.getTarget(_local5);
						if(_local12 != null) {
							_local3.stateMachine.changeState(new AIChase(g,_local3,_local12,_local13,_local7));
						} else {
							Console.write("No Ai target: " + _local5);
						}
						break;
					case "AIResurect":
						_local3.stateMachine.changeState(new AIResurect(g,_local3));
					case "AIFollow":
						_local5 = m.getInt(i);
						_local12 = g.unitManager.getTarget(_local5);
						if(_local12 != null) {
							_local3.stateMachine.changeState(new AIFollow(g,_local3,_local12,_local13,_local7));
						} else {
							Console.write("No Ai target: " + _local5);
						}
						break;
					case "AIMelee":
						_local5 = m.getInt(i);
						_local12 = g.unitManager.getTarget(_local5);
						if(_local12 != null) {
							_local3.stateMachine.changeState(new AIMelee(g,_local3,_local12,_local13,_local7));
						} else {
							Console.write("No Ai target: " + _local5);
						}
						break;
					case "AIOrbit":
						_local3.stateMachine.changeState(new AIOrbit(g,_local3));
						break;
					case "AIIdle":
						_local3.stateMachine.changeState(new AIIdle(g,_local3,_local3.course));
						break;
					case "AIReturn":
						_local8 = m.getNumber(i);
						_local10 = m.getNumber(i + 1);
						_local3.stateMachine.changeState(new AIReturnOrbit(g,_local3,_local8,_local10,_local13,_local7));
						break;
					case "AIKamikaze":
						_local5 = m.getInt(i);
						_local12 = g.unitManager.getTarget(_local5);
						if(_local12 != null) {
							_local3.stateMachine.changeState(new AIKamikaze(g,_local3,_local12,_local13,_local7));
						} else {
							Console.write("No Ai target: " + _local5);
						}
						break;
					case "AIFlee":
						_local6 = new Point(m.getNumber(i),m.getNumber(i + 1));
						_local3.stateMachine.changeState(new AIFlee(g,_local3,_local6,_local13,_local7));
						break;
					case "AITeleport":
						_local3.stateMachine.changeState(new AITeleport(g,_local3,_local3.target,_local7,m.getNumber(i),m.getNumber(i + 1)));
						break;
					case "AITeleportExit":
						_local3.stateMachine.changeState(new AITeleportExit(g,_local3));
						break;
					case "AIExit":
						_local3.stateMachine.changeState(new AIExit(g,_local3));
				}
			}
			catch(e:Error) {
				g.client.errorLog.writeError("MSG PACK: " + e.toString(),"State: " + _local4,e.getStackTrace(),{});
			}
		}
		
		private function fastforwardMe(myShip:Ship, heading:Heading) : void {
			g.commandManager.clearCommands(heading.time);
			while(heading.time < myShip.course.time) {
				g.commandManager.runCommand(heading,heading.time);
				myShip.convergerUpdateHeading(heading);
			}
		}
		
		private function fastforward(ship:Ship, heading:Heading) : void {
			var _local3:Heading = ship.course;
			while(heading.time < _local3.time) {
				ship.convergerUpdateHeading(heading);
			}
		}
	}
}

