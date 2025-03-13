package core.states.exploreStates {
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
	
	public class ExploreState extends DisplayState {
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
		
		public function ExploreState(g:Game, b:Body) {
			super(g,ExploreState);
			this.b = b;
			zoneExpireTimer = new HudTimer(g,10);
		}
		
		override public function enter() : void {
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
			if(bodyAreas.length == 0) {
				areasText.text = "No areas to explore.";
				areasText.color = 0xa9a9a9;
				areasText.size = 14;
				return;
			}
			for each(obj in bodyAreas) {
				areaTypes[obj.key] = obj;
			}
			if(exploredAreas) {
				createMap();
			} else {
				g.me.getExploredAreas(b,function(param1:Array):void {
					if(container == null) {
						return;
					}
					exploredAreas = param1;
					createMap();
				});
			}
		}
		
		private function addClanControl() : void {
			var _local5:TextBitmap = null;
			var _local9:ControlZone = g.controlZoneManager.getZoneByKey(b.key);
			if(!_local9 || !g.isSystemTypeHostile()) {
				return;
			}
			var _local4:int = 700;
			var _local2:int = 44;
			var _local3:TextBitmap = new TextBitmap(_local4,_local2,"Controlled by clan:",12);
			_local3.alignRight();
			addChild(_local3);
			_local2 += 15;
			var _local6:TextBitmap = new TextBitmap(_local4,_local2,_local9.clanName,26);
			_local6.alignRight();
			_local6.format.color = 0xff0000;
			addChild(_local6);
			var _local1:ITextureManager = TextureLocator.getService();
			var _local8:Texture = _local1.getTextureGUIByTextureName(_local9.clanLogo);
			var _local7:Image = new Image(_local8);
			_local7.scaleX = _local7.scaleY = 0.25;
			_local7.color = _local9.clanColor;
			_local7.x = _local4 - _local6.width - _local7.width - 10;
			_local7.y = _local2 + _local6.height - _local7.height - 2;
			addChild(_local7);
			_local2 += 30;
			if(_local9.releaseTime > g.time) {
				zoneExpireTimer.start(g.time,_local9.releaseTime);
				zoneExpireTimer.x = _local4 - 90;
				zoneExpireTimer.y = _local2;
				addChild(zoneExpireTimer);
			} else {
				_local5 = new TextBitmap(_local4,_local2,"expired",12);
				_local5.alignRight();
				addChild(_local5);
			}
		}
		
		private function createMap() : void {
			exploreMap = new ExploreMap(g,bodyAreas,exploredAreas,b);
			exploreMap.x = 50;
			exploreMap.y = 110;
			addChild(exploreMap);
			addExploreAreas(exploreMap);
			addChild(areaBox);
			var _local1:Box = new Box(610,45,"normal",0.95,12);
			_local1.x = 80;
			_local1.y = 45;
			addImg(_local1);
		}
		
		private function showSelectTeam(e:Event) : void {
			var _local2:ExploreArea = e.target as ExploreArea;
			sm.changeState(new SelectTeamState(g,b,_local2));
		}
		
		private function addExploreAreas(expMap:ExploreMap) : void {
			var _local20:* = null;
			var _local13:Object = null;
			var _local14:Number = NaN;
			var _local2:Number = NaN;
			var _local9:int = 0;
			var _local7:Array = null;
			var _local8:int = 0;
			var _local18:String = null;
			var _local11:Explore = null;
			var _local19:int = 0;
			var _local4:Boolean = false;
			var _local6:Boolean = false;
			var _local12:Boolean = false;
			var _local5:String = null;
			var _local17:Number = NaN;
			var _local15:Number = NaN;
			var _local10:Number = NaN;
			var _local3:ExploreArea = null;
			areas = new Vector.<ExploreArea>();
			if(b.obj.exploreAreas != null) {
				for each(var _local16 in b.obj.exploreAreas) {
					_local20 = _local16;
					_local13 = areaTypes[_local20];
					_local14 = Number(_local13.skillLevel);
					_local2 = Number(_local13.rewardLevel);
					_local9 = int(_local13.size);
					_local7 = _local13.types;
					_local8 = int(_local13.majorType);
					_local18 = _local13.name;
					_local11 = g.me.getExploreByKey(_local20);
					_local19 = 0;
					_local4 = false;
					_local6 = false;
					_local12 = false;
					_local5 = null;
					_local17 = 0;
					_local15 = 0;
					_local10 = 0;
					if(_local11) {
						_local19 = _local11.successfulEvents;
						_local6 = _local11.finished;
						_local4 = _local11.failed;
						_local12 = _local11.lootClaimed;
						_local15 = _local11.failTime;
						_local10 = _local11.finishTime;
						_local17 = _local11.startTime;
					}
					_local3 = new ExploreArea(g,expMap,b,_local20,_local5,_local14,_local2,_local9,_local8,_local7,_local18,_local19,_local4,_local6,_local12,_local15,_local10,_local17);
					_local3.addEventListener("showSelectTeam",showSelectTeam);
					_local3.addEventListener("showRewardScreen",showRewardScreen);
					areas.push(_local3);
					areaBox.addChild(_local3);
					g.tutorial.showExploreAdvice(_local3);
					g.tutorial.showSpecialUnlocks(_local3);
				}
			}
		}
		
		public function showRewardScreen(e:Event) : void {
			var _local2:ExploreArea = e.target as ExploreArea;
			sm.changeState(new ReportState(g,_local2));
		}
		
		private function addImg(box:Box) : void {
			var _local2:Number = NaN;
			if(b.texture != null) {
				_local2 = 50 / b.texture.width;
				planetGfx = new Image(b.texture);
				planetGfx.scaleX = _local2;
				planetGfx.scaleY = _local2;
				planetGfx.x = 80;
				planetGfx.y = 45;
				addChild(planetGfx);
				hasDrawnBody = true;
			}
		}
		
		override public function execute() : void {
			if(updateInterval-- > 0) {
				return;
			}
			if(ControlZoneManager.claimData) {
				sm.changeState(new ControlZoneState(g,b));
			}
			updateInterval = 5;
			for each(var _local1 in areas) {
				if(areaBox.contains(_local1)) {
					_local1.visible = false;
				}
				if(ExploreMap.selectedArea != null && ExploreMap.selectedArea.key == _local1.areaKey) {
					_local1.visible = true;
				}
				_local1.update();
			}
			zoneExpireTimer.update();
			super.execute();
		}
		
		public function stopEffect() : void {
			for each(var _local1 in areas) {
				_local1.stopEffect();
			}
		}
		
		override public function get type() : String {
			return "ExploreState";
		}
		
		override public function exit() : void {
			removeChild(areaBox,true);
			PixelHitArea.dispose();
			ToolTip.disposeType("skill");
			super.exit();
		}
	}
}

