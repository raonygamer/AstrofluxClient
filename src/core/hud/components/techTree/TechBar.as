package core.hud.components.techTree
{
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class TechBar extends Sprite
	{
		private var maxLevel:int;
		public var tech:String;
		public var table:String;
		public var eti:EliteTechIcon;
		private var _playerLevel:int;
		private var techIcons:Vector.<TechLevelIcon>;
		private var eliteTechIcon:EliteTechIcon;
		private var me:Player;
		private var _selectedTechLevelIcon:TechLevelIcon;
		
		public function TechBar(g:Game, techSkill:TechSkill, me:Player, showCanBeUpgraded:Boolean = true, showTooltip:Boolean = false, overrideSkinLevel:int = -1)
		{
			var _loc9_:int = 0;
			var _loc7_:int = 0;
			var _loc8_:TechLevelIcon = null;
			super();
			this.me = me;
			maxLevel = 6;
			techIcons = new Vector.<TechLevelIcon>();
			_playerLevel = techSkill.level;
			table = techSkill.table;
			tech = techSkill.tech;
			var _loc10_:int = overrideSkinLevel == -1 ? Player.getSkinTechLevel(tech,me.activeSkin) : overrideSkinLevel;
			var _loc11_:String = "";
			_loc11_ = "upgraded";
			var _loc12_:TechLevelIcon = new TechLevelIcon(this,_loc11_,0,techSkill,showCanBeUpgraded);
			_loc12_.x = TechLevelIcon.ICON_WIDTH / 2;
			_loc12_.y = TechLevelIcon.ICON_WIDTH / 2;
			_loc12_.pivotX = TechLevelIcon.ICON_WIDTH / 2;
			_loc12_.pivotY = TechLevelIcon.ICON_WIDTH / 2;
			techIcons.push(_loc12_);
			addChild(_loc12_);
			_loc9_ = 0;
			while(_loc9_ < maxLevel)
			{
				_loc7_ = _loc9_ + 1;
				if(_loc7_ <= _playerLevel)
				{
					_loc11_ = "upgraded";
				}
				else if(!TechTree.hasRequiredLevel(_loc7_,me.level) && showCanBeUpgraded)
				{
					_loc11_ = "locked";
				}
				else if(_loc7_ == _playerLevel + 1 && showCanBeUpgraded)
				{
					_loc11_ = "can be upgraded";
				}
				else if(_loc7_ > _playerLevel)
				{
					_loc11_ = "can\'t be upgraded";
				}
				if(_loc10_ >= _loc7_)
				{
					_loc11_ = "skin locked";
				}
				_loc8_ = new TechLevelIcon(this,_loc11_,_loc7_,techSkill,showTooltip);
				_loc8_.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + _loc9_ * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
				_loc8_.y = TechLevelIcon.ICON_WIDTH / 2;
				_loc8_.pivotX = TechLevelIcon.ICON_WIDTH / 2;
				_loc8_.pivotY = TechLevelIcon.ICON_WIDTH / 2;
				techIcons.push(_loc8_);
				addChild(_loc8_);
				_loc9_++;
			}
			if(techSkill.level < 6)
			{
				_loc11_ = "locked";
			}
			else if(techSkill.activeEliteTech == "")
			{
				_loc11_ = "no special selected";
			}
			else if(techSkill.activeEliteTechLevel < 100)
			{
				_loc11_ = "special selected and can be upgraded";
			}
			else
			{
				_loc11_ = "fully upgraded";
			}
			eti = new EliteTechIcon(g,this,_loc11_,techSkill,showTooltip,showCanBeUpgraded);
			eti.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + 6 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
			eti.y = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotX = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotY = EliteTechIcon.ICON_WIDTH / 2;
			eliteTechIcon = eti;
			addChild(eliteTechIcon);
		}
		
		public function reset() : void
		{
			var _loc2_:int = 0;
			var _loc1_:TechLevelIcon = null;
			var _loc3_:int = Player.getSkinTechLevel(tech,me.activeSkin);
			_playerLevel = _loc3_;
			eliteTechIcon.level = -1;
			eliteTechIcon.updateState("locked");
			_loc2_ = 0;
			while(_loc2_ < techIcons.length)
			{
				_loc1_ = techIcons[_loc2_];
				_loc1_.playerLevel = _loc3_;
				if(_loc2_ != 0)
				{
					if(!TechTree.hasRequiredLevel(_loc2_,me.level))
					{
						_loc1_.updateState("locked");
					}
					else if(_loc2_ == _loc3_ + 1)
					{
						_loc1_.updateState("can be upgraded");
					}
					else
					{
						_loc1_.updateState("can\'t be upgraded");
					}
					_loc1_.visible = true;
					if(_loc3_ >= _loc1_.level)
					{
						_loc1_.updateState("skin locked");
					}
				}
				_loc2_++;
			}
		}
		
		override public function dispose() : void
		{
			for each(var _loc1_ in techIcons)
			{
				_loc1_.dispose();
			}
			removeEventListeners();
			super.dispose();
		}
		
		override public function set touchable(value:Boolean) : void
		{
			for each(var _loc2_ in techIcons)
			{
				_loc2_.touchable = value;
			}
			eliteTechIcon.touchable = value;
		}
		
		private function getUpgradeByLevel(level:int) : TechLevelIcon
		{
			for each(var _loc2_ in techIcons)
			{
				if(_loc2_.level == level)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function upgrade(tli:TechLevelIcon) : void
		{
			tli.updateState("upgraded");
			var _loc2_:TechLevelIcon = getUpgradeByLevel(tli.level + 1);
			if(tli.level == 6)
			{
				eliteTechIcon.updateState("no special selected");
			}
			if(_loc2_ != null && TechTree.hasRequiredLevel(_loc2_.level,me.level))
			{
				_loc2_.updateState("can be upgraded");
				_loc2_.playerLevel = tli.level;
			}
		}
	}
}

