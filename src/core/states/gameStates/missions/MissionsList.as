package core.states.gameStates.missions {
	import core.hud.components.ToolTip;
	import core.player.Mission;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class MissionsList extends Sprite {
		public static var instance:MissionsList;
		private var g:Game;
		private var missions:Vector.<Mission>;
		private var missionViews:Vector.<MissionView> = new Vector.<MissionView>();
		private var missionsContainer:ScrollContainer;
		private var majorType:String;
		
		public function MissionsList(g:Game) {
			super();
			this.g = g;
			instance = this;
			missionsContainer = new ScrollContainer();
			missionsContainer.width = 12 * 60;
			missionsContainer.height = 500;
			missionsContainer.x = 0;
			missionsContainer.y = 40;
			addChild(missionsContainer);
		}
		
		public static function reload() : void {
			if(instance != null) {
				instance.reload();
			}
		}
		
		public function loadStoryMissions() : void {
			this.majorType = "static";
			load();
		}
		
		public function loadTimedMissions() : void {
			this.majorType = "time";
			load();
		}
		
		public function load() : void {
			var majorType:String = this.majorType;
			missions = g.me.missions.filter(function(param1:Mission, param2:int, param3:Vector.<Mission>):Boolean {
				return param1.majorType == majorType;
			});
			sortByDate();
		}
		
		private function sortByDate() : void {
			missions = missions.sort((function():* {
				var f:Function;
				return f = function(param1:Mission, param2:Mission):int {
					if(param1.created < param2.created) {
						return 1;
					}
					if(param1.created > param2.created) {
						return -1;
					}
					return 0;
				};
			})());
		}
		
		private function reload(e:Event = null) : void {
			missionViews.length = 0;
			missionsContainer.removeChildren(0,-1,true);
			load();
			drawMissions();
		}
		
		public function drawMissions() : void {
			var _local4:int = 0;
			var _local2:Mission = null;
			var _local3:MissionView = null;
			var _local1:int = 635;
			if(missions.length > 2) {
				_local1 = 620;
			}
			_local4 = 0;
			while(_local4 < missions.length) {
				_local2 = missions[_local4];
				_local3 = new MissionView(g,_local2,_local1);
				missionViews.push(_local3);
				missionsContainer.addChild(_local3);
				_local3.init();
				_local3.addEventListener("reload",reload);
				_local4++;
			}
			positionMissions();
			trySetMissionsViewed();
		}
		
		private function positionMissions() : void {
			var _local4:int = 0;
			var _local1:MissionView = null;
			var _local3:Number = 62;
			var _local2:Number = 23;
			_local4 = 0;
			while(_local4 < missionViews.length) {
				_local1 = missionViews[_local4];
				_local1.x = _local3;
				_local1.y = _local2;
				_local2 += _local1.height;
				_local4++;
			}
		}
		
		private function trySetMissionsViewed() : void {
			var _local1:Boolean = false;
			for each(var _local2:* in missions) {
				if(!_local2.viewed) {
					_local2.viewed = true;
					_local1 = true;
				}
			}
			if(_local1) {
				g.rpc("setMissionsViewed",null);
			}
			g.hud.missionsButton.hideHintNew();
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:MissionView = null;
			_local2 = 0;
			while(_local2 < missionViews.length) {
				_local1 = missionViews[_local2];
				_local1.update();
				_local2++;
			}
		}
		
		override public function dispose() : void {
			missionsContainer.removeChildren(0,-1,true);
			ToolTip.disposeType("missionView");
			instance = null;
			super.dispose();
		}
	}
}

