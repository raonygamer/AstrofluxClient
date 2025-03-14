package core.hud.components.techTree {
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class TechBar extends Sprite {
		private var maxLevel:int;
		public var tech:String;
		public var table:String;
		public var eti:EliteTechIcon;
		private var _playerLevel:int;
		private var techIcons:Vector.<TechLevelIcon>;
		private var eliteTechIcon:EliteTechIcon;
		private var me:Player;
		private var _selectedTechLevelIcon:TechLevelIcon;
		
		public function TechBar(g:Game, techSkill:TechSkill, me:Player, showCanBeUpgraded:Boolean = true, showTooltip:Boolean = false, overrideSkinLevel:int = -1) {
			var _local12:int = 0;
			var _local8:int = 0;
			var _local10:TechLevelIcon = null;
			super();
			this.me = me;
			maxLevel = 6;
			techIcons = new Vector.<TechLevelIcon>();
			_playerLevel = techSkill.level;
			table = techSkill.table;
			tech = techSkill.tech;
			var _local7:int = overrideSkinLevel == -1 ? Player.getSkinTechLevel(tech,me.activeSkin) : overrideSkinLevel;
			var _local9:String = "";
			_local9 = "upgraded";
			var _local11:TechLevelIcon = new TechLevelIcon(this,_local9,0,techSkill,showCanBeUpgraded);
			_local11.x = TechLevelIcon.ICON_WIDTH / 2;
			_local11.y = TechLevelIcon.ICON_WIDTH / 2;
			_local11.pivotX = TechLevelIcon.ICON_WIDTH / 2;
			_local11.pivotY = TechLevelIcon.ICON_WIDTH / 2;
			techIcons.push(_local11);
			addChild(_local11);
			_local12 = 0;
			while(_local12 < maxLevel) {
				_local8 = _local12 + 1;
				if(_local8 <= _playerLevel) {
					_local9 = "upgraded";
				} else if(!TechTree.hasRequiredLevel(_local8,me.level) && showCanBeUpgraded) {
					_local9 = "locked";
				} else if(_local8 == _playerLevel + 1 && showCanBeUpgraded) {
					_local9 = "can be upgraded";
				} else if(_local8 > _playerLevel) {
					_local9 = "can\'t be upgraded";
				}
				if(_local7 >= _local8) {
					_local9 = "skin locked";
				}
				_local10 = new TechLevelIcon(this,_local9,_local8,techSkill,showTooltip);
				_local10.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + _local12 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
				_local10.y = TechLevelIcon.ICON_WIDTH / 2;
				_local10.pivotX = TechLevelIcon.ICON_WIDTH / 2;
				_local10.pivotY = TechLevelIcon.ICON_WIDTH / 2;
				techIcons.push(_local10);
				addChild(_local10);
				_local12++;
			}
			if(techSkill.level < 6) {
				_local9 = "locked";
			} else if(techSkill.activeEliteTech == "") {
				_local9 = "no special selected";
			} else if(techSkill.activeEliteTechLevel < 100) {
				_local9 = "special selected and can be upgraded";
			} else {
				_local9 = "fully upgraded";
			}
			eti = new EliteTechIcon(g,this,_local9,techSkill,showTooltip,showCanBeUpgraded);
			eti.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + 6 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
			eti.y = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotX = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotY = EliteTechIcon.ICON_WIDTH / 2;
			eliteTechIcon = eti;
			addChild(eliteTechIcon);
		}
		
		public function reset() : void {
			var _local3:int = 0;
			var _local2:TechLevelIcon = null;
			var _local1:int = Player.getSkinTechLevel(tech,me.activeSkin);
			_playerLevel = _local1;
			eliteTechIcon.level = -1;
			eliteTechIcon.updateState("locked");
			_local3 = 0;
			while(_local3 < techIcons.length) {
				_local2 = techIcons[_local3];
				_local2.playerLevel = _local1;
				if(_local3 != 0) {
					if(!TechTree.hasRequiredLevel(_local3,me.level)) {
						_local2.updateState("locked");
					} else if(_local3 == _local1 + 1) {
						_local2.updateState("can be upgraded");
					} else {
						_local2.updateState("can\'t be upgraded");
					}
					_local2.visible = true;
					if(_local1 >= _local2.level) {
						_local2.updateState("skin locked");
					}
				}
				_local3++;
			}
		}
		
		override public function dispose() : void {
			for each(var _local1:* in techIcons) {
				_local1.dispose();
			}
			removeEventListeners();
			super.dispose();
		}
		
		override public function set touchable(value:Boolean) : void {
			for each(var _local2:* in techIcons) {
				_local2.touchable = value;
			}
			eliteTechIcon.touchable = value;
		}
		
		private function getUpgradeByLevel(level:int) : TechLevelIcon {
			for each(var _local2:* in techIcons) {
				if(_local2.level == level) {
					return _local2;
				}
			}
			return null;
		}
		
		public function upgrade(tli:TechLevelIcon) : void {
			tli.updateState("upgraded");
			var _local2:TechLevelIcon = getUpgradeByLevel(tli.level + 1);
			if(tli.level == 6) {
				eliteTechIcon.updateState("no special selected");
			}
			if(_local2 != null && TechTree.hasRequiredLevel(_local2.level,me.level)) {
				_local2.updateState("can be upgraded");
				_local2.playerLevel = tli.level;
			}
		}
	}
}

