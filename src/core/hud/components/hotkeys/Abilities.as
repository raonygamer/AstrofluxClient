package core.hud.components.hotkeys {
	import core.hud.components.ToolTip;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import data.DataLocator;
	import data.IDataManager;
	import data.KeyBinds;
	import debug.Console;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Abilities extends Sprite {
		private var hotkeys:Vector.<AbilityHotkey> = new Vector.<AbilityHotkey>();
		private var g:Game;
		private var dataManager:IDataManager;
		private var textureManager:ITextureManager;
		private var keyBinds:KeyBinds;
		
		public function Abilities(g:Game) {
			super();
			this.g = g;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
		}
		
		public function load() : void {
			var _local8:Object = null;
			var _local7:String = null;
			var _local2:Boolean = false;
			var _local6:Function = null;
			var _local3:String = null;
			var _local5:int = 0;
			var _local1:Object = null;
			var _local10:AbilityHotkey = null;
			keyBinds = SceneBase.settings.keybinds;
			var _local4:PlayerShip = g.me.ship;
			if(_local4 == null) {
				Console.write("No ship for weapon hotkeys.");
				return;
			}
			var _local11:int = 0;
			for each(var _local9 in g.me.techSkills) {
				if(_local9.tech == "m4yG1IRPIUeyRQHrC3h5kQ" || _local9.tech == "QgKEEj8a-0yzYAJ06eSLqA" || _local9.tech == "rSr1sn-_oUOY6E0hpAhh0Q" || _local9.tech == "kwlCdExeJk-oEJZopIz5kg") {
					_local8 = dataManager.loadKey(_local9.table,_local9.tech);
					_local7 = "";
					_local2 = false;
					_local6 = null;
					_local3 = "";
					_local5 = 0;
					if(_local8.name == "Engine") {
						_local6 = g.commandManager.addBoostCommand;
						_local7 = "E";
						_local2 = _local4.hasBoost;
						if(_local4.aritfact_cooldownReduction > 0.4) {
							_local5 = _local4.boostCD * 0.6;
						} else {
							_local5 = _local4.boostCD * (1 - _local4.aritfact_cooldownReduction);
						}
						_local3 = Localize.t("Boost your engine with <FONT COLOR=\'#ffffff\'>[boostBonus]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[boostBonus]",_local4.boostBonus).replace("[duration]",_local4.boostDuration / 1000);
					} else if(_local8.name == "Shield") {
						_local6 = g.commandManager.addHardenedShieldCommand;
						_local7 = "Q";
						_local2 = _local4.hasHardenedShield;
						if(_local4.aritfact_cooldownReduction > 0.4) {
							_local5 = _local4.hardenCD * 0.6;
						} else {
							_local5 = _local4.hardenCD * (1 - _local4.aritfact_cooldownReduction);
						}
						_local3 = Localize.t("Creates a hardened shield that protects you from all damage over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[duration]",_local4.hardenDuration / 1000);
					} else if(_local8.name == "Armor") {
						_local6 = g.commandManager.addShieldConvertCommand;
						_local7 = "F";
						_local2 = _local4.hasArmorConverter;
						if(_local4.aritfact_cooldownReduction > 0.4) {
							_local5 = _local4.convCD * 0.6;
						} else {
							_local5 = _local4.convCD * (1 - _local4.aritfact_cooldownReduction);
						}
						_local3 = Localize.t("Use <FONT COLOR=\'#ffffff\'>[convCost]%</FONT> of your shield energy to repair ship with <FONT COLOR=\'#ffffff\'>[convGain]%</FONT> of the energy consumed.").replace("[convCost]",_local4.convCost).replace("[convGain]",_local4.convGain);
					} else if(_local8.name == "Power") {
						_local6 = g.commandManager.addDmgBoostCommand;
						_local7 = "R";
						_local2 = _local4.hasDmgBoost;
						if(_local4.aritfact_cooldownReduction > 0.4) {
							_local5 = _local4.dmgBoostCD * 0.6;
						} else {
							_local5 = _local4.dmgBoostCD * (1 - _local4.aritfact_cooldownReduction);
						}
						_local3 = Localize.t("Damage is increased by <FONT COLOR=\'#ffffff\'>[damage]%</FONT> but power consumtion is increased by <FONT COLOR=\'#ffffff\'>[cost]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[damage]",_local4.dmgBoostBonus * 100).replace("[cost]",_local4.dmgBoostCost * 100).replace("[duration]",_local4.dmgBoostDuration / 1000);
					}
					_local1 = dataManager.loadKey("Images",_local8.techIcon);
					_local10 = new AbilityHotkey(_local6,textureManager.getTextureGUIByTextureName(_local1.textureName),textureManager.getTextureGUIByTextureName(_local1.textureName + "_inactive"),textureManager.getTextureGUIByTextureName(_local1.textureName + "_cooldown"),_local7);
					_local10.cooldownTime = _local5;
					_local10.obj = _local8;
					_local10.y = 50 * _local11;
					_local10.visible = _local2;
					hotkeys.push(_local10);
					new ToolTip(g,_local10,_local3,null,"abilities");
					addChild(_local10);
					_local11++;
				}
			}
		}
		
		public function update() : void {
			for each(var _local1 in hotkeys) {
				_local1.update();
			}
		}
		
		private function createHotkey(obj:Object, visible:Boolean, command:Function, level:int, caption:String, toolTip:String, i:int) : Function {
			return function(param1:Texture):void {
			};
		}
		
		public function initiateCooldown(name:String) : void {
			for each(var _local2 in hotkeys) {
				if(_local2.obj.name == name) {
					_local2.initiateCooldown();
				}
			}
		}
		
		public function refresh() : void {
			for each(var _local1 in hotkeys) {
				removeChild(_local1);
				ToolTip.disposeType("abiltites");
			}
			hotkeys.splice(0,hotkeys.length);
			load();
		}
	}
}

