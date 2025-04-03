package movement
{
	import core.hud.components.hotkeys.AbilityHotkey;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class CommandManager
	{
		public var commands:Vector.<Command> = new Vector.<Command>();
		
		private var sendBuffer:Vector.<Command> = new Vector.<Command>();
		
		private var g:Game;
		
		public function CommandManager(g:Game)
		{
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("command",commandReceived);
		}
		
		public function flush() : void
		{
			if(sendBuffer.length == 0)
			{
				return;
			}
			var _loc2_:Message = g.createMessage("command");
			for each(var _loc1_ in sendBuffer)
			{
				_loc2_.add(_loc1_.type);
				_loc2_.add(_loc1_.active);
				_loc2_.add(_loc1_.time);
			}
			g.sendMessage(_loc2_);
			sendBuffer = new Vector.<Command>();
		}
		
		public function addCommand(type:int, active:Boolean) : void
		{
			var _loc3_:PlayerShip = g.playerManager.me.ship;
			var _loc4_:Heading = _loc3_.course;
			var _loc5_:Command = new Command();
			_loc5_.type = type;
			_loc5_.active = active;
			while(_loc4_.time < g.time - 2 * 33)
			{
				_loc3_.convergerUpdateHeading(_loc4_);
			}
			_loc5_.time = _loc4_.time;
			commands.push(_loc5_);
			sendCommand(_loc5_);
			_loc3_.clearConvergeTarget();
			_loc3_.runCommand(_loc5_);
		}
		
		private function sendCommand(cmd:Command) : void
		{
			var _loc2_:Message = g.createMessage("command");
			_loc2_.add(cmd.type);
			_loc2_.add(cmd.active);
			_loc2_.add(cmd.time);
			g.sendMessage(_loc2_);
		}
		
		public function commandReceived(m:Message) : void
		{
			var _loc2_:Dictionary = g.playerManager.playersById;
			var _loc3_:String = m.getString(0);
			var _loc4_:Command = new Command();
			_loc4_.type = m.getInt(1);
			_loc4_.active = m.getBoolean(2);
			_loc4_.time = m.getNumber(3);
			var _loc5_:Player = _loc2_[_loc3_];
			if(_loc5_ != null && _loc5_.ship != null)
			{
				_loc5_.ship.runCommand(_loc4_);
			}
		}
		
		public function runCommand(heading:Heading, cmdTime:Number) : void
		{
			var _loc3_:int = 0;
			var _loc4_:Command = null;
			_loc3_ = 0;
			while(_loc3_ < commands.length)
			{
				_loc4_ = commands[_loc3_];
				if(_loc4_.time >= cmdTime)
				{
					if(_loc4_.time != cmdTime)
					{
						break;
					}
					heading.runCommand(_loc4_);
				}
				_loc3_++;
			}
		}
		
		public function clearCommands(time:Number) : void
		{
			var _loc2_:int = 0;
			var _loc3_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < commands.length)
			{
				if(commands[_loc2_].time >= time)
				{
					break;
				}
				_loc3_++;
				_loc2_++;
			}
			if(_loc3_ != 0)
			{
				commands.splice(0,_loc3_);
			}
		}
		
		public function addBoostCommand(ab:AbilityHotkey = null) : void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if(_loc2_.boostNextRdy < g.time && _loc2_.hasBoost)
			{
				g.hud.abilities.initiateCooldown("Engine");
				_loc2_.boost();
				addCommand(4,true);
			}
		}
		
		public function addDmgBoostCommand(ab:AbilityHotkey = null) : void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if(_loc2_.hasDmgBoost && _loc2_.dmgBoostNextRdy < g.time)
			{
				g.hud.abilities.initiateCooldown("Power");
				_loc2_.dmgBoost();
				addCommand(7,true);
			}
		}
		
		public function addShieldConvertCommand(ab:AbilityHotkey = null) : void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if(_loc2_.hasArmorConverter && _loc2_.convNextRdy < g.time)
			{
				g.hud.abilities.initiateCooldown("Armor");
				_loc2_.convertShield();
				addCommand(6,true);
			}
		}
		
		public function addHardenedShieldCommand(ab:AbilityHotkey = null) : void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if(_loc2_.hardenNextRdy < g.time && _loc2_.hasHardenedShield)
			{
				g.hud.abilities.initiateCooldown("Shield");
				_loc2_.hardenShield();
				addCommand(5,true);
			}
		}
	}
}

