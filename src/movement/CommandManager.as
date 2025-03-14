package movement {
	import core.hud.components.hotkeys.AbilityHotkey;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class CommandManager {
		public var commands:Vector.<Command> = new Vector.<Command>();
		private var sendBuffer:Vector.<Command> = new Vector.<Command>();
		private var g:Game;
		
		public function CommandManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("command",commandReceived);
		}
		
		public function flush() : void {
			if(sendBuffer.length == 0) {
				return;
			}
			var _local1:Message = g.createMessage("command");
			for each(var _local2:* in sendBuffer) {
				_local1.add(_local2.type);
				_local1.add(_local2.active);
				_local1.add(_local2.time);
			}
			g.sendMessage(_local1);
			sendBuffer = new Vector.<Command>();
		}
		
		public function addCommand(type:int, active:Boolean) : void {
			var _local4:PlayerShip = g.playerManager.me.ship;
			var _local3:Heading = _local4.course;
			var _local5:Command = new Command();
			_local5.type = type;
			_local5.active = active;
			while(_local3.time < g.time - 2 * 33) {
				_local4.convergerUpdateHeading(_local3);
			}
			_local5.time = _local3.time;
			commands.push(_local5);
			sendCommand(_local5);
			_local4.clearConvergeTarget();
			_local4.runCommand(_local5);
		}
		
		private function sendCommand(cmd:Command) : void {
			var _local2:Message = g.createMessage("command");
			_local2.add(cmd.type);
			_local2.add(cmd.active);
			_local2.add(cmd.time);
			g.sendMessage(_local2);
		}
		
		public function commandReceived(m:Message) : void {
			var _local5:Dictionary = g.playerManager.playersById;
			var _local4:String = m.getString(0);
			var _local2:Command = new Command();
			_local2.type = m.getInt(1);
			_local2.active = m.getBoolean(2);
			_local2.time = m.getNumber(3);
			var _local3:Player = _local5[_local4];
			if(_local3 != null && _local3.ship != null) {
				_local3.ship.runCommand(_local2);
			}
		}
		
		public function runCommand(heading:Heading, cmdTime:Number) : void {
			var _local4:int = 0;
			var _local3:Command = null;
			_local4 = 0;
			while(_local4 < commands.length) {
				_local3 = commands[_local4];
				if(_local3.time >= cmdTime) {
					if(_local3.time != cmdTime) {
						break;
					}
					heading.runCommand(_local3);
				}
				_local4++;
			}
		}
		
		public function clearCommands(time:Number) : void {
			var _local3:int = 0;
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < commands.length) {
				if(commands[_local3].time >= time) {
					break;
				}
				_local2++;
				_local3++;
			}
			if(_local2 != 0) {
				commands.splice(0,_local2);
			}
		}
		
		public function addBoostCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.boostNextRdy < g.time && _local2.hasBoost) {
				g.hud.abilities.initiateCooldown("Engine");
				_local2.boost();
				addCommand(4,true);
			}
		}
		
		public function addDmgBoostCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hasDmgBoost && _local2.dmgBoostNextRdy < g.time) {
				g.hud.abilities.initiateCooldown("Power");
				_local2.dmgBoost();
				addCommand(7,true);
			}
		}
		
		public function addShieldConvertCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hasArmorConverter && _local2.convNextRdy < g.time) {
				g.hud.abilities.initiateCooldown("Armor");
				_local2.convertShield();
				addCommand(6,true);
			}
		}
		
		public function addHardenedShieldCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hardenNextRdy < g.time && _local2.hasHardenedShield) {
				g.hud.abilities.initiateCooldown("Shield");
				_local2.hardenShield();
				addCommand(5,true);
			}
		}
	}
}

