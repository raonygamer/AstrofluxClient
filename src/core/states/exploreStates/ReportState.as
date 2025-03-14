package core.states.exploreStates {
	import com.greensock.TweenMax;
	import core.artifact.Artifact;
	import core.artifact.ArtifactBox;
	import core.artifact.ArtifactFactory;
	import core.hud.components.Button;
	import core.hud.components.CrewDetails;
	import core.hud.components.LootItem;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.explore.ExploreArea;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.states.DisplayState;
	import debug.Console;
	import generics.Util;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class ReportState extends DisplayState {
		private var area:ExploreArea;
		private var loadText:TextBitmap = new TextBitmap();
		private var levelUpHeading:TextBitmap = new TextBitmap();
		private var firstStepContainer:Sprite = new Sprite();
		private var crewStepContainers:Vector.<Sprite> = new Vector.<Sprite>();
		private var rewardStepContainer:Sprite = new Sprite();
		private var nextButton:Button;
		private var rewardTweens:Vector.<TweenMax> = new Vector.<TweenMax>();
		private var crewTweens:Vector.<Vector.<TweenMax>> = new Vector.<Vector.<TweenMax>>();
		private var currentCrewIndex:int;
		private var crewMembers:Array = [];
		
		public function ReportState(g:Game, area:ExploreArea) {
			super(g,ExploreState);
			this.area = area;
		}
		
		override public function enter() : void {
			super.enter();
			backButton.visible = false;
			loadText.text = "Loading explore report...";
			loadText.size = 28;
			loadText.x = 760 / 2;
			loadText.y = 10 * 60 / 2;
			loadText.center();
			addChild(loadText);
			g.rpc("getExploreReport",reportArrived,area.areaKey);
		}
		
		private function reportArrived(m:Message) : void {
			var _local11:int = 0;
			var _local6:String = null;
			var _local16:String = null;
			var _local14:Number = NaN;
			var _local4:LootItem = null;
			var _local12:String = null;
			var _local10:ArtifactBox = null;
			loadText.visible = false;
			area.updateState(true);
			var _local15:Text = new Text();
			_local15.size = 12;
			_local15.color = 0x666666;
			_local15.x = 760 / 2;
			_local15.y = 200;
			_local15.center();
			var _local2:String = area.body.name + ", " + area.name + ", ";
			for each(var _local3:* in area.specialTypes) {
				_local2 += Area.SPECIALTYPEHTML[_local3] + " ";
			}
			_local15.htmlText = _local2;
			var _local9:TextBitmap = new TextBitmap();
			_local9.x = 760 / 2;
			_local9.size = 30;
			_local9.y = _local15.y + _local15.height + 20;
			if(area.success) {
				_local9.format.color = Style.COLOR_VALID;
				_local9.text = "SUCCESS!";
				_local9.center();
				TweenMax.fromTo(_local9,1,{
					"scaleX":2,
					"scaleY":2,
					"rotation":2
				},{
					"scaleX":1,
					"scaleY":1,
					"rotation":0
				});
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			} else {
				_local9.format.color = Style.COLOR_INVALID;
				_local9.text = "FAILED!";
				_local9.center();
				TweenMax.fromTo(_local9,1,{
					"scaleX":2,
					"scaleY":2,
					"rotation":-2
				},{
					"scaleX":1,
					"scaleY":1,
					"rotation":0
				});
				SoundLocator.getService().play("14BaNTN3tEmfQKMGWfEE6w");
			}
			var _local17:TextBitmap = new TextBitmap();
			_local17.size = 18;
			_local17.text = Util.formatDecimal(area.failedValue * 100,1).toString() + "% explored";
			_local17.x = 760 / 2;
			_local17.y = _local9.y + 50 + 20;
			_local17.center();
			nextButton = new Button(initiateCrewStep,"Next","highlight");
			setNextButtonPosition();
			firstStepContainer.addChild(nextButton);
			firstStepContainer.addChild(_local9);
			firstStepContainer.addChild(_local15);
			firstStepContainer.addChild(_local17);
			addChild(firstStepContainer);
			var _local5:int = m.getInt(0);
			var _local7:int = 0;
			var _local8:int = 0;
			_local11 = 1;
			while(_local11 < _local5) {
				_local6 = m.getString(_local11);
				_local16 = m.getString(_local11 + 1);
				_local14 = m.getInt(_local11 + 2);
				g.myCargo.addItem(_local6,_local16,_local14);
				_local4 = new LootItem(_local6,_local16,_local14);
				_local4.x = 760 / 2 - _local4.width / 2;
				_local4.y = 310 + _local8 * (_local4.height + 5);
				rewardTweens.push(TweenMax.from(_local4,1,{
					"alpha":0,
					"paused":true
				}));
				rewardStepContainer.addChild(_local4);
				if(_local14 > 0) {
					_local7 += 1;
				}
				_local11 += 3;
				_local8++;
			}
			_local5 = m.getInt(_local11);
			_local7 = 0;
			_local11 += 1;
			var _local13:* = _local5;
			var _local18:Text = new Text();
			_local18.size = 36;
			_local18.text = Area.getRewardAction(area.type);
			_local18.color = Area.COLORTYPE[area.type];
			_local18.x = 760 / 2;
			_local18.y = 105;
			_local18.center();
			rewardTweens.push(TweenMax.from(_local18,1.4,{
				"alpha":0,
				"scaleX":4,
				"scaleY":4,
				"paused":true
			}));
			rewardStepContainer.addChild(_local18);
			_local7;
			while(_local7 < 3) {
				if(_local7 < _local5) {
					_local12 = m.getString(_local11);
					ArtifactFactory.createArtifact(_local12,g,g.me,createArtifactFunction(_local13,_local7,_local12));
					_local11++;
				} else {
					_local10 = new ArtifactBox(g,null);
					_local10.update();
					_local10.y = 200;
					_local10.x = 760 / 2 - 3 * (_local10.width + 15) / 2 + (_local10.width + 15) * _local7;
					rewardTweens.push(TweenMax.from(_local10,1 + _local7,{
						"alpha":0,
						"scaleX":2,
						"scaleY":2,
						"paused":true
					}));
					rewardStepContainer.addChild(_local10);
				}
				_local7++;
			}
			levelUp(m,_local11);
		}
		
		private function createArtifactFunction(artifactCount:int, i:int, id:String) : Function {
			return function(param1:Artifact):void {
				if(param1 == null) {
					g.client.errorLog.writeError("Error #1009","explore artifact is null: " + id,"",null);
					return;
				}
				var _local2:ArtifactBox = new ArtifactBox(g,param1);
				_local2.update();
				_local2.y = 200;
				_local2.x = 760 / 2 - 3 * (_local2.width + 15) / 2 + (_local2.width + 15) * i;
				rewardTweens.push(TweenMax.from(_local2,1 + i,{
					"alpha":0,
					"scaleX":2,
					"scaleY":2,
					"paused":true
				}));
				rewardStepContainer.addChild(_local2);
				g.me.artifacts.push(param1);
			};
		}
		
		private function setNextButtonPosition() : void {
			nextButton.size = 13;
			nextButton.x = 760 - nextButton.width - 73;
			nextButton.y = 500;
		}
		
		private function initiateCrewStep(e:TouchEvent) : void {
			firstStepContainer.visible = false;
			nextCrewStep();
		}
		
		private function nextCrewStep(i:int = 0) : void {
			var tween:TweenMax;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			currentCrewIndex = i;
			if(i > 0) {
				crewStepContainers[i - 1].visible = false;
			}
			if(i >= crewStepContainers.length) {
				initiateRewardStep();
				return;
			}
			for each(tween in crewTweens[i]) {
				tween.play();
			}
			nextButton = new Button(null,"next");
			setNextButtonPosition();
			nextButton.callback = function(param1:TouchEvent):void {
				nextCrewStep(i + 1);
			};
			crewStepContainers[i].addChild(nextButton);
			addChild(crewStepContainers[i]);
		}
		
		private function initiateRewardStep() : void {
			var tween:TweenMax;
			rewardStepContainer.visible = true;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			nextButton = new Button(null,"Close Report");
			nextButton.size = 12;
			nextButton.y = 8 * 60;
			nextButton.callback = function(param1:TouchEvent):void {
				sm.changeState(new ExploreState(g,area.body));
			};
			g.tutorial.showArtifactFound(area);
			nextButton.x = 760 / 2 - nextButton.width / 2;
			rewardStepContainer.addChild(nextButton);
			for each(tween in rewardTweens) {
				tween.play();
			}
			addChild(rewardStepContainer);
		}
		
		override public function get type() : String {
			return "ReportState";
		}
		
		private function placeCrewSkills(e:Event) : void {
			var _local6:int = 0;
			var _local2:DisplayObject = null;
			var _local4:Sprite = crewStepContainers[currentCrewIndex];
			_local6 = 0;
			while(_local6 < _local4.numChildren - 1) {
				_local2 = _local4.getChildAt(_local6);
				_local2.visible = false;
				_local6++;
			}
			nextButton.visible = true;
			var _local5:CrewMember = crewMembers[currentCrewIndex];
			var _local3:CrewDetails = new CrewDetails(g,_local5,null,false,2);
			_local3.x = 200;
			_local3.y = 80;
			_local4.addChild(_local3);
		}
		
		private function levelUp(m:Message, i:int) : void {
			var _local9:Array = null;
			var _local3:* = undefined;
			var _local18:Sprite = null;
			var _local19:String = null;
			var _local10:CrewMember = null;
			var _local7:int = 0;
			var _local11:String = null;
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			var _local17:Number = NaN;
			var _local15:Image = null;
			var _local5:TextBitmap = null;
			var _local14:Text = null;
			var _local12:Button = null;
			var _local16:Text = null;
			var _local8:int = 0;
			var _local13:Text = null;
			i;
			while(i < m.length) {
				_local9 = [];
				_local3 = new Vector.<TweenMax>();
				crewTweens.push(_local3);
				_local18 = new Sprite();
				_local19 = m.getString(i);
				_local10 = g.me.getCrewMember(_local19);
				_local10.missions++;
				crewMembers.push(_local10);
				if(_local10 == null) {
					Console.write("Error: CrewMember is null!");
					return;
				}
				_local7 = m.getInt(i + 1);
				_local11 = Area.getSkillTypeHtml(_local7);
				_local6 = m.getNumber(i + 2);
				_local4 = m.getNumber(i + 3);
				_local17 = m.getNumber(i + 4);
				_local10.skillPoints += _local6;
				_local10.injuryEnd = _local17;
				_local10.injuryStart = _local4;
				_local10.fullLocation = "";
				_local10.body = "";
				_local10.area = "";
				_local10.solarSystem = "";
				_local15 = new Image(textureManager.getTextureGUIByKey(_local10.imageKey));
				_local15.x = 760 / 2 - _local15.width / 2;
				_local15.y = 100;
				_local3.push(TweenMax.from(_local15,1,{
					"alpha":0,
					"paused":true
				}));
				_local18.addChild(_local15);
				_local5 = new TextBitmap(760 / 2,_local15.y + _local15.height + 20);
				_local5.size = 18;
				_local5.text = _local10.name;
				_local5.center();
				_local3.push(TweenMax.from(_local5,1,{
					"alpha":0,
					"paused":true
				}));
				_local18.addChild(_local5);
				_local14 = new Text(100,_local5.y + _local5.height + 20);
				_local14.size = 20;
				_local14.text = "New skill points: " + _local6;
				_local14.color = 0xffffff;
				_local3.push(TweenMax.from(_local14,0.5,{
					"scaleX":1.2,
					"scaleY":1.2,
					"paused":true
				}));
				_local9.push(_local14);
				_local12 = new Button(placeCrewSkills,"Place skill points","reward");
				_local12.x = 760 / 2 - _local12.width / 2;
				_local12.y = 500;
				_local18.addChild(_local12);
				if(_local10.injuryTime > 0) {
					_local16 = new Text(550,_local5.y + _local5.height + 20);
					_local16.size = 18;
					_local16.color = Style.COLOR_INJURED;
					_local16.text = "Injured " + Util.formatDecimal(_local10.injuryTime / 1000 / (60),1) + " min ";
					_local9.push(_local16);
					_local3.push(TweenMax.fromTo(_local16,1,{
						"scaleX":2,
						"scaleY":2,
						"rotation":-2
					},{
						"paused":true,
						"scaleX":1,
						"scaleY":1,
						"rotation":0
					}));
				}
				_local8 = 0;
				while(_local8 < _local9.length) {
					_local13 = _local9[_local8];
					_local13.x = 760 / 2;
					_local13.y = _local5.y + _local5.height + 20 + _local8 * (_local13.size + 10);
					_local13.center();
					_local18.addChild(_local13);
					_local8++;
				}
				crewStepContainers.push(_local18);
				i += 5;
			}
		}
	}
}

