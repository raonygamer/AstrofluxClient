package core.states.exploreStates
{
	import core.GameObject;
	import core.controlZones.ControlZone;
	import core.controlZones.ControlZoneManager;
	import core.hud.components.Box;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.HudTimer;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.explore.ExploreArea;
	import core.hud.components.explore.ExploreMap;
	import core.particle.Emitter;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.DisplayState;
	import extensions.PixelHitArea;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ExploreState extends DisplayState
	{
		public static var COLOR:uint = 3225899;
		
		private static var planetExploreAreas:Dictionary = null;
		
		private var min:Number = 0;
		
		private var max:Number = 1;
		
		private var value:Number = 0;
		
		private var _exploring:Boolean = false;
		
		private var exploreEffect:Vector.<Emitter>;
		
		private var effectBackground:Bitmap;
		
		private var effectContainer:Bitmap;
		
		private var effectTarget:GameObject;
		
		private var hasDrawnBody:Boolean = false;
		
		private var exploreText:Text;
		
		private var closeButton:ButtonExpandableHud;
		
		private var timer:Timer = new Timer(1000,1);
		
		private var startTime:Number = 0;
		
		private var finishTime:Number = 0;
		
		private var areaTypes:Dictionary = new Dictionary();
		
		private var areas:Vector.<ExploreArea>;
		
		private var planetGfx:Image;
		
		private var areaBox:Sprite;
		
		private var areasText:Text;
		
		private var exploreMap:ExploreMap;
		
		private var b:Body;
		
		private var hasCollectedReward:Boolean = false;
		
		private var bodyAreas:Array;
		
		private var exploredAreas:Array;
		
		private var zoneExpireTimer:HudTimer;
		
		private var updateInterval:int = 5;
		
		public function ExploreState(g:Game, b:Body)
		{
			super(g,ExploreState);
			this.b = b;
			zoneExpireTimer = new HudTimer(g,10);
		}
		
		override public function enter() : void
		{
			var defX:int;
			var planetName:TextBitmap;
			var subHeader:TextBitmap;
			var box:Box;
			var obj:Object;
			super.enter();
			defX = 60;
			planetName = new TextBitmap(defX + 80,44,b.name,26);
			addChild(planetName);
			subHeader = new TextBitmap(planetName.x,planetName.y + planetName.height,"Planet overview");
			subHeader.format.color = 0x666666;
			addChild(subHeader);
			addClanControl();
			areaBox = new Sprite();
			box = new Box(610,50,"normal",0.95,12);
			areaBox.addChild(box);
			areaBox.x = 80;
			areaBox.y = 8 * 60;
			bodyAreas = b.getExploreAreaTypes();
			if(bodyAreas.length == 0)
			{
				areasText.text = "No areas to explore.";
				areasText.color = 0xa9a9a9;
				areasText.size = 14;
				return;
			}
			for each(obj in bodyAreas)
			{
				areaTypes[obj.key] = obj;
			}
			if(exploredAreas)
			{
				createMap();
			}
			else
			{
				g.me.getExploredAreas(b,function(param1:Array):void
				{
					if(container == null)
					{
						return;
					}
					exploredAreas = param1;
					createMap();
				});
			}
		}
		
		private function addClanControl() : void
		{
			var _loc4_:TextBitmap = null;
			var _loc3_:ControlZone = g.controlZoneManager.getZoneByKey(b.key);
			if(!_loc3_ || !g.isSystemTypeHostile())
			{
				return;
			}
			var _loc6_:int = 700;
			var _loc2_:int = 44;
			var _loc5_:TextBitmap = new TextBitmap(_loc6_,_loc2_,"Controlled by clan:",12);
			_loc5_.alignRight();
			addChild(_loc5_);
			_loc2_ += 15;
			var _loc9_:TextBitmap = new TextBitmap(_loc6_,_loc2_,_loc3_.clanName,26);
			_loc9_.alignRight();
			_loc9_.format.color = 0xff0000;
			addChild(_loc9_);
			var _loc7_:ITextureManager = TextureLocator.getService();
			var _loc1_:Texture = _loc7_.getTextureGUIByTextureName(_loc3_.clanLogo);
			var _loc8_:Image = new Image(_loc1_);
			_loc8_.scaleX = _loc8_.scaleY = 0.25;
			_loc8_.color = _loc3_.clanColor;
			_loc8_.x = _loc6_ - _loc9_.width - _loc8_.width - 10;
			_loc8_.y = _loc2_ + _loc9_.height - _loc8_.height - 2;
			addChild(_loc8_);
			_loc2_ += 30;
			if(_loc3_.releaseTime > g.time)
			{
				zoneExpireTimer.start(g.time,_loc3_.releaseTime);
				zoneExpireTimer.x = _loc6_ - 90;
				zoneExpireTimer.y = _loc2_;
				addChild(zoneExpireTimer);
			}
			else
			{
				_loc4_ = new TextBitmap(_loc6_,_loc2_,"expired",12);
				_loc4_.alignRight();
				addChild(_loc4_);
			}
		}
		
		private function createMap() : void
		{
			exploreMap = new ExploreMap(g,bodyAreas,exploredAreas,b);
			exploreMap.x = 50;
			exploreMap.y = 110;
			addChild(exploreMap);
			addExploreAreas(exploreMap);
			addChild(areaBox);
			var _loc1_:Box = new Box(610,45,"normal",0.95,12);
			_loc1_.x = 80;
			_loc1_.y = 45;
			addImg(_loc1_);
		}
		
		private function showSelectTeam(e:Event) : void
		{
			var _loc2_:ExploreArea = e.target as ExploreArea;
			sm.changeState(new SelectTeamState(g,b,_loc2_));
		}
		
		private function addExploreAreas(expMap:ExploreMap) : void
		{
			var _loc20_:* = null;
			var _loc2_:Object = null;
			var _loc4_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc14_:int = 0;
			var _loc5_:Array = null;
			var _loc10_:int = 0;
			var _loc17_:String = null;
			var _loc15_:Explore = null;
			var _loc18_:int = 0;
			var _loc9_:Boolean = false;
			var _loc8_:Boolean = false;
			var _loc11_:Boolean = false;
			var _loc16_:String = null;
			var _loc6_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc19_:Number = NaN;
			var _loc3_:ExploreArea = null;
			areas = new Vector.<ExploreArea>();
			if(b.obj.exploreAreas != null)
			{
				for each(var _loc13_ in b.obj.exploreAreas)
				{
					_loc20_ = _loc13_;
					_loc2_ = areaTypes[_loc20_];
					_loc4_ = Number(_loc2_.skillLevel);
					_loc7_ = Number(_loc2_.rewardLevel);
					_loc14_ = int(_loc2_.size);
					_loc5_ = _loc2_.types;
					_loc10_ = int(_loc2_.majorType);
					_loc17_ = _loc2_.name;
					_loc15_ = g.me.getExploreByKey(_loc20_);
					_loc18_ = 0;
					_loc9_ = false;
					_loc8_ = false;
					_loc11_ = false;
					_loc16_ = null;
					_loc6_ = 0;
					_loc12_ = 0;
					_loc19_ = 0;
					if(_loc15_)
					{
						_loc18_ = _loc15_.successfulEvents;
						_loc8_ = _loc15_.finished;
						_loc9_ = _loc15_.failed;
						_loc11_ = _loc15_.lootClaimed;
						_loc12_ = _loc15_.failTime;
						_loc19_ = _loc15_.finishTime;
						_loc6_ = _loc15_.startTime;
					}
					_loc3_ = new ExploreArea(g,expMap,b,_loc20_,_loc16_,_loc4_,_loc7_,_loc14_,_loc10_,_loc5_,_loc17_,_loc18_,_loc9_,_loc8_,_loc11_,_loc12_,_loc19_,_loc6_);
					_loc3_.addEventListener("showSelectTeam",showSelectTeam);
					_loc3_.addEventListener("showRewardScreen",showRewardScreen);
					areas.push(_loc3_);
					areaBox.addChild(_loc3_);
					g.tutorial.showExploreAdvice(_loc3_);
					g.tutorial.showSpecialUnlocks(_loc3_);
				}
			}
		}
		
		public function showRewardScreen(e:Event) : void
		{
			var _loc2_:ExploreArea = e.target as ExploreArea;
			sm.changeState(new ReportState(g,_loc2_));
		}
		
		private function addImg(box:Box) : void
		{
			var _loc2_:Number = NaN;
			if(b.texture != null)
			{
				_loc2_ = 50 / b.texture.width;
				planetGfx = new Image(b.texture);
				planetGfx.scaleX = _loc2_;
				planetGfx.scaleY = _loc2_;
				planetGfx.x = 80;
				planetGfx.y = 45;
				addChild(planetGfx);
				hasDrawnBody = true;
			}
		}
		
		override public function execute() : void
		{
			if(updateInterval-- > 0)
			{
				return;
			}
			if(ControlZoneManager.claimData)
			{
				sm.changeState(new ControlZoneState(g,b));
			}
			updateInterval = 5;
			for each(var _loc1_ in areas)
			{
				if(areaBox.contains(_loc1_))
				{
					_loc1_.visible = false;
				}
				if(ExploreMap.selectedArea != null && ExploreMap.selectedArea.key == _loc1_.areaKey)
				{
					_loc1_.visible = true;
				}
				_loc1_.update();
			}
			zoneExpireTimer.update();
			super.execute();
		}
		
		public function stopEffect() : void
		{
			for each(var _loc1_ in areas)
			{
				_loc1_.stopEffect();
			}
		}
		
		override public function get type() : String
		{
			return "ExploreState";
		}
		
		override public function exit() : void
		{
			removeChild(areaBox,true);
			PixelHitArea.dispose();
			ToolTip.disposeType("skill");
			super.exit();
		}
	}
}

