package core.hud.components.starMap
{
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import generics.Util;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class SolarSystem extends Sprite
	{
		public static const EDITOR_TYPE_REGULAR:String = "regular";
		
		public static const EDITOR_TYPE_DEBUG:String = "debug";
		
		public static const EDITOR_TYPE_PVP:String = "pvp";
		
		public static const EDITOR_TYPE_PVP_DOMINATION:String = "pvp dom";
		
		public static const EDITOR_TYPE_PVP_DM:String = "pvp dm";
		
		public static const EDITOR_TYPE_PVP_ARENA:String = "pvp arena";
		
		public static const EDITOR_TYPE_INSTANCE:String = "instance";
		
		public static const START_SYSTEM:String = "HrAjOBivt0SHPYtxKyiB_Q";
		
		public var pvpLvlCap:int;
		
		public var pvpAboveCap:Boolean;
		
		private var _discovered:Boolean;
		
		private var _hovered:Boolean;
		
		private var _selected:Boolean;
		
		private var _currentSolarSystemKey:String;
		
		private var obj:Object;
		
		public var key:String;
		
		public var textureManager:ITextureManager;
		
		private var fractionText:TextBitmap;
		
		public var nameText:TextBitmap;
		
		private var _hasFriends:Boolean = false;
		
		private var _hasCrew:Boolean = false;
		
		private var destroyed:TextBitmap;
		
		private var iconCurrent:Image;
		
		private var iconSelected:Image;
		
		private var iconHover:Image;
		
		private var iconNormal:Image;
		
		private var friendBullet:Image;
		
		private var crewBullet:Image;
		
		public var isPvpSystemInEditor:Boolean;
		
		public var type:String;
		
		private var g:Game;
		
		public function SolarSystem(g:Game, obj:Object, key:String, discovered:Boolean = true, currentSolarSystemKey:String = "")
		{
			var _loc9_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc15_:IDataManager = null;
			var _loc7_:Object = null;
			var _loc10_:Object = null;
			var _loc8_:TextBitmap = null;
			fractionText = new TextBitmap();
			nameText = new TextBitmap();
			destroyed = new TextBitmap();
			super();
			textureManager = TextureLocator.getService();
			this.obj = obj;
			this.key = key;
			this.g = g;
			type = obj.type;
			name = obj.name;
			isPvpSystemInEditor = type == "pvp" || type == "pvp dm" || type == "pvp dom" || type == "pvp arena";
			g.hud.uberStats.uberMaxLevel = obj.uberMaxLevel;
			g.hud.uberStats.uberMinLevel = obj.uberMinLevel;
			_currentSolarSystemKey = currentSolarSystemKey;
			if(obj.hasOwnProperty("pvpLvlCap"))
			{
				pvpLvlCap = obj.pvpLvlCap;
			}
			crewBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_crew"));
			friendBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_friend"));
			crewBullet.pivotX = crewBullet.width / 2;
			crewBullet.pivotY = crewBullet.height / 2;
			crewBullet.color = Style.COLOR_CREW;
			friendBullet.pivotX = friendBullet.width / 2;
			friendBullet.pivotY = friendBullet.height / 2;
			friendBullet.color = Style.COLOR_FRIENDS;
			addChild(crewBullet);
			addChild(friendBullet);
			iconCurrent = new Image(textureManager.getTextureGUIByTextureName("solarsystem_current"));
			iconSelected = new Image(textureManager.getTextureGUIByTextureName("solarsystem_selected"));
			iconHover = new Image(textureManager.getTextureGUIByTextureName("solarsystem_hover"));
			iconNormal = new Image(textureManager.getTextureGUIByTextureName("solarsystem_normal"));
			iconCurrent.pivotX = iconSelected.pivotX = iconHover.pivotX = iconNormal.pivotX = iconCurrent.width / 2;
			iconCurrent.pivotY = iconSelected.pivotY = iconHover.pivotY = iconNormal.pivotY = iconCurrent.height / 2;
			iconCurrent.width = iconSelected.width = iconHover.width = iconNormal.width = size * 4;
			iconCurrent.height = iconSelected.height = iconHover.height = iconNormal.height = size * 4;
			addChild(iconCurrent);
			addChild(iconSelected);
			addChild(iconHover);
			addChild(iconNormal);
			x = obj.x;
			y = obj.y;
			this._discovered = discovered;
			var _loc11_:Number = 0;
			if(g != null && g.me != null)
			{
				_loc9_ = 0;
				_loc12_ = 0;
				_loc15_ = DataLocator.getService();
				_loc7_ = _loc15_.loadRange("Bodies","solarSystem",key);
				for(var _loc13_ in _loc7_)
				{
					_loc10_ = _loc7_[_loc13_];
					if(_loc10_.hasOwnProperty("exploreAreas"))
					{
						for each(var _loc6_ in _loc10_.exploreAreas)
						{
							if(g.me.hasExploredArea(_loc6_))
							{
								_loc9_++;
							}
							_loc12_++;
						}
					}
				}
				if(_loc12_ > 0)
				{
					_loc11_ = _loc9_ / _loc12_ * 100;
				}
			}
			var _loc14_:int = size >= 12 ? 12 : size;
			nameText.text = obj.name;
			nameText.size = 20;
			nameText.scaleX = nameText.scaleY = 1 * (_loc14_ / 16);
			nameText.x = size + 12;
			nameText.y = -2;
			nameText.center();
			nameText.alignLeft();
			if(obj.key == "ic3w-BxdMU6qWhX9t3_EaA")
			{
				_loc8_ = new TextBitmap(nameText.x - 2,10,Localize.t("PvE battle area"),11);
				_loc8_.format.color = Style.COLOR_H2;
				addChild(_loc8_);
			}
			nameText.useHandCursor = false;
			addChild(nameText);
			if(type == "pvp" || obj.key == "ic3w-BxdMU6qWhX9t3_EaA")
			{
				iconCurrent.color = Style.COLOR_HOSTILE;
				iconSelected.color = Style.COLOR_HOSTILE;
				iconHover.color = Style.COLOR_HOSTILE;
				iconNormal.color = Style.COLOR_HOSTILE;
				nameText.format.color = Style.COLOR_HOSTILE;
			}
			else if(type == "regular")
			{
				fractionText.size = 20;
				fractionText.text = Util.formatDecimal(_loc11_).toString() + "%";
				fractionText.scaleX = fractionText.scaleY = 1 * (_loc14_ / 16);
				fractionText.format.color = 0x787878;
				fractionText.x = nameText.x + 2 + nameText.width;
				fractionText.y = -2;
				fractionText.center();
				fractionText.alignLeft();
				fractionText.useHandCursor = false;
				addChild(fractionText);
			}
			destroyed.text = Localize.t("Destroyed");
			destroyed.size = 10;
			destroyed.rotation = 3.141592653589793 / 6;
			destroyed.pivotX = destroyed.width / 2;
			destroyed.format.color = 0xff0000;
			destroyed.alignLeft();
			destroyed.useHandCursor = false;
			destroyed.visible = false;
			draw();
			addChild(destroyed);
			blendMode = "add";
			if(isDestroyed)
			{
				return;
			}
			this.useHandCursor = true;
			this.addEventListener("touch",onTouch);
			addEventListener("removedFromStage",clean);
		}
		
		public function set discovered(value:Boolean) : void
		{
			_discovered = value;
			draw();
		}
		
		public function get discovered() : Boolean
		{
			return _discovered;
		}
		
		public function get destinations() : Array
		{
			return obj.destinations;
		}
		
		public function set selected(value:Boolean) : void
		{
			_selected = value;
			draw();
		}
		
		public function get size() : Number
		{
			return obj.size;
		}
		
		public function get color() : uint
		{
			return obj.color;
		}
		
		public function set hasFriends(v:Boolean) : void
		{
			_hasFriends = v;
			draw();
		}
		
		public function get hasFriends() : Boolean
		{
			return _hasFriends;
		}
		
		public function set hasCrew(v:Boolean) : void
		{
			_hasCrew = v;
			draw();
		}
		
		public function get hasCrew() : Boolean
		{
			return _hasCrew;
		}
		
		public function get galaxy() : String
		{
			return obj.galaxy;
		}
		
		private function draw() : void
		{
			if(obj.size == null || obj.color == null)
			{
				return;
			}
			iconCurrent.visible = false;
			iconHover.visible = false;
			iconNormal.visible = false;
			iconSelected.visible = false;
			friendBullet.visible = false;
			crewBullet.visible = false;
			if(isCurrentSolarSystem)
			{
				iconCurrent.visible = true;
			}
			else if(_selected)
			{
				iconSelected.visible = true;
			}
			else if(_hovered)
			{
				iconHover.visible = true;
			}
			else if(!_discovered)
			{
				iconNormal.visible = true;
				iconNormal.alpha = 0.2;
			}
			else if(_discovered)
			{
				iconNormal.visible = true;
				iconNormal.alpha = 1;
			}
			var _loc1_:Number = size + 14;
			var _loc2_:Number = size + 10;
			if(_hasFriends)
			{
				friendBullet.visible = true;
				friendBullet.x = _loc1_;
				friendBullet.y = _loc2_;
				_loc1_ += 14;
			}
			if(_hasCrew)
			{
				crewBullet.visible = true;
				crewBullet.x = _loc1_;
				crewBullet.y = _loc2_;
			}
			if(isDestroyed)
			{
				destroyed.visible = true;
			}
		}
		
		public function get isDestroyed() : Boolean
		{
			if(key == "DrMy6JjyO0OI0ui7c80bNw" && !isCurrentSolarSystem)
			{
				return true;
			}
			return false;
		}
		
		private function mClick(e:TouchEvent) : void
		{
			if(isDestroyed)
			{
				e.stopPropagation();
				return;
			}
			_selected = true;
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			draw();
		}
		
		private function mOver(e:TouchEvent) : void
		{
			if(isDestroyed)
			{
				return;
			}
			_hovered = true;
			draw();
		}
		
		private function mOut(e:TouchEvent) : void
		{
			if(isDestroyed)
			{
				return;
			}
			_hovered = false;
			draw();
		}
		
		public function get dev() : Boolean
		{
			return obj.dev;
		}
		
		public function get isCurrentSolarSystem() : Boolean
		{
			return key == _currentSolarSystemKey;
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			if(e.getTouch(this,"ended"))
			{
				mClick(e);
			}
			else if(e.interactsWith(this))
			{
				mOver(e);
			}
			else if(!e.interactsWith(this))
			{
				mOut(e);
			}
		}
		
		public function clean(e:Event = null) : void
		{
			this.removeEventListeners();
			dispose();
		}
		
		public function getInvasionText() : String
		{
			return obj.invasionText;
		}
	}
}

