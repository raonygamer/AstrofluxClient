package core.states.exploreStates
{
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
	
	public class ReportState extends DisplayState
	{
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
		
		public function ReportState(g:Game, area:ExploreArea)
		{
			super(g,ExploreState);
			this.area = area;
		}
		
		override public function enter() : void
		{
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
		
		private function reportArrived(m:Message) : void
		{
			var _loc6_:int = 0;
			var _loc18_:String = null;
			var _loc3_:String = null;
			var _loc4_:Number = NaN;
			var _loc15_:LootItem = null;
			var _loc16_:String = null;
			var _loc12_:ArtifactBox = null;
			loadText.visible = false;
			area.updateState(true);
			var _loc5_:Text = new Text();
			_loc5_.size = 12;
			_loc5_.color = 0x666666;
			_loc5_.x = 760 / 2;
			_loc5_.y = 200;
			_loc5_.center();
			var _loc2_:String = area.body.name + ", " + area.name + ", ";
			for each(var _loc13_ in area.specialTypes)
			{
				_loc2_ += Area.SPECIALTYPEHTML[_loc13_] + " ";
			}
			_loc5_.htmlText = _loc2_;
			var _loc14_:TextBitmap = new TextBitmap();
			_loc14_.x = 760 / 2;
			_loc14_.size = 30;
			_loc14_.y = _loc5_.y + _loc5_.height + 20;
			if(area.success)
			{
				_loc14_.format.color = Style.COLOR_VALID;
				_loc14_.text = "SUCCESS!";
				_loc14_.center();
				TweenMax.fromTo(_loc14_,1,{
					"scaleX":2,
					"scaleY":2,
					"rotation":2
				},{
					"scaleX":1,
					"scaleY":1,
					"rotation":0
				});
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			}
			else
			{
				_loc14_.format.color = Style.COLOR_INVALID;
				_loc14_.text = "FAILED!";
				_loc14_.center();
				TweenMax.fromTo(_loc14_,1,{
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
			var _loc7_:TextBitmap = new TextBitmap();
			_loc7_.size = 18;
			_loc7_.text = Util.formatDecimal(area.failedValue * 100,1).toString() + "% explored";
			_loc7_.x = 760 / 2;
			_loc7_.y = _loc14_.y + 50 + 20;
			_loc7_.center();
			nextButton = new Button(initiateCrewStep,"Next","highlight");
			setNextButtonPosition();
			firstStepContainer.addChild(nextButton);
			firstStepContainer.addChild(_loc14_);
			firstStepContainer.addChild(_loc5_);
			firstStepContainer.addChild(_loc7_);
			addChild(firstStepContainer);
			var _loc11_:int = m.getInt(0);
			var _loc8_:int = 0;
			var _loc10_:int = 0;
			_loc6_ = 1;
			while(_loc6_ < _loc11_)
			{
				_loc18_ = m.getString(_loc6_);
				_loc3_ = m.getString(_loc6_ + 1);
				_loc4_ = m.getInt(_loc6_ + 2);
				g.myCargo.addItem(_loc18_,_loc3_,_loc4_);
				_loc15_ = new LootItem(_loc18_,_loc3_,_loc4_);
				_loc15_.x = 760 / 2 - _loc15_.width / 2;
				_loc15_.y = 310 + _loc10_ * (_loc15_.height + 5);
				rewardTweens.push(TweenMax.from(_loc15_,1,{
					"alpha":0,
					"paused":true
				}));
				rewardStepContainer.addChild(_loc15_);
				if(_loc4_ > 0)
				{
					_loc8_ += 1;
				}
				_loc6_ += 3;
				_loc10_++;
			}
			_loc11_ = m.getInt(_loc6_);
			_loc8_ = 0;
			_loc6_ += 1;
			var _loc9_:* = _loc11_;
			var _loc17_:Text = new Text();
			_loc17_.size = 36;
			_loc17_.text = Area.getRewardAction(area.type);
			_loc17_.color = Area.COLORTYPE[area.type];
			_loc17_.x = 760 / 2;
			_loc17_.y = 105;
			_loc17_.center();
			rewardTweens.push(TweenMax.from(_loc17_,1.4,{
				"alpha":0,
				"scaleX":4,
				"scaleY":4,
				"paused":true
			}));
			rewardStepContainer.addChild(_loc17_);
			_loc8_;
			while(_loc8_ < 3)
			{
				if(_loc8_ < _loc11_)
				{
					_loc16_ = m.getString(_loc6_);
					ArtifactFactory.createArtifact(_loc16_,g,g.me,createArtifactFunction(_loc9_,_loc8_,_loc16_));
					_loc6_++;
				}
				else
				{
					_loc12_ = new ArtifactBox(g,null);
					_loc12_.update();
					_loc12_.y = 200;
					_loc12_.x = 760 / 2 - 3 * (_loc12_.width + 15) / 2 + (_loc12_.width + 15) * _loc8_;
					rewardTweens.push(TweenMax.from(_loc12_,1 + _loc8_,{
						"alpha":0,
						"scaleX":2,
						"scaleY":2,
						"paused":true
					}));
					rewardStepContainer.addChild(_loc12_);
				}
				_loc8_++;
			}
			levelUp(m,_loc6_);
		}
		
		private function createArtifactFunction(artifactCount:int, i:int, id:String) : Function
		{
			return function(param1:Artifact):void
			{
				if(param1 == null)
				{
					g.client.errorLog.writeError("Error #1009","explore artifact is null: " + id,"",null);
					return;
				}
				var _loc2_:ArtifactBox = new ArtifactBox(g,param1);
				_loc2_.update();
				_loc2_.y = 200;
				_loc2_.x = 760 / 2 - 3 * (_loc2_.width + 15) / 2 + (_loc2_.width + 15) * i;
				rewardTweens.push(TweenMax.from(_loc2_,1 + i,{
					"alpha":0,
					"scaleX":2,
					"scaleY":2,
					"paused":true
				}));
				rewardStepContainer.addChild(_loc2_);
				g.me.artifacts.push(param1);
			};
		}
		
		private function setNextButtonPosition() : void
		{
			nextButton.size = 13;
			nextButton.x = 760 - nextButton.width - 73;
			nextButton.y = 500;
		}
		
		private function initiateCrewStep(e:TouchEvent) : void
		{
			firstStepContainer.visible = false;
			nextCrewStep();
		}
		
		private function nextCrewStep(i:int = 0) : void
		{
			var tween:TweenMax;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			currentCrewIndex = i;
			if(i > 0)
			{
				crewStepContainers[i - 1].visible = false;
			}
			if(i >= crewStepContainers.length)
			{
				initiateRewardStep();
				return;
			}
			for each(tween in crewTweens[i])
			{
				tween.play();
			}
			nextButton = new Button(null,"next");
			setNextButtonPosition();
			nextButton.callback = function(param1:TouchEvent):void
			{
				nextCrewStep(i + 1);
			};
			crewStepContainers[i].addChild(nextButton);
			addChild(crewStepContainers[i]);
		}
		
		private function initiateRewardStep() : void
		{
			var tween:TweenMax;
			rewardStepContainer.visible = true;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			nextButton = new Button(null,"Close Report");
			nextButton.size = 12;
			nextButton.y = 8 * 60;
			nextButton.callback = function(param1:TouchEvent):void
			{
				sm.changeState(new ExploreState(g,area.body));
			};
			g.tutorial.showArtifactFound(area);
			nextButton.x = 760 / 2 - nextButton.width / 2;
			rewardStepContainer.addChild(nextButton);
			for each(tween in rewardTweens)
			{
				tween.play();
			}
			addChild(rewardStepContainer);
		}
		
		override public function get type() : String
		{
			return "ReportState";
		}
		
		private function placeCrewSkills(e:Event) : void
		{
			var _loc6_:int = 0;
			var _loc2_:DisplayObject = null;
			var _loc4_:Sprite = crewStepContainers[currentCrewIndex];
			_loc6_ = 0;
			while(_loc6_ < _loc4_.numChildren - 1)
			{
				_loc2_ = _loc4_.getChildAt(_loc6_);
				_loc2_.visible = false;
				_loc6_++;
			}
			nextButton.visible = true;
			var _loc5_:CrewMember = crewMembers[currentCrewIndex];
			var _loc3_:CrewDetails = new CrewDetails(g,_loc5_,null,false,2);
			_loc3_.x = 200;
			_loc3_.y = 80;
			_loc4_.addChild(_loc3_);
		}
		
		private function levelUp(m:Message, i:int) : void
		{
			var _loc3_:Array = null;
			var _loc11_:* = undefined;
			var _loc15_:Sprite = null;
			var _loc19_:String = null;
			var _loc16_:CrewMember = null;
			var _loc13_:int = 0;
			var _loc12_:String = null;
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc7_:Image = null;
			var _loc8_:TextBitmap = null;
			var _loc10_:Text = null;
			var _loc17_:Button = null;
			var _loc18_:Text = null;
			var _loc9_:int = 0;
			var _loc14_:Text = null;
			i;
			while(i < m.length)
			{
				_loc3_ = [];
				_loc11_ = new Vector.<TweenMax>();
				crewTweens.push(_loc11_);
				_loc15_ = new Sprite();
				_loc19_ = m.getString(i);
				_loc16_ = g.me.getCrewMember(_loc19_);
				_loc16_.missions++;
				crewMembers.push(_loc16_);
				if(_loc16_ == null)
				{
					Console.write("Error: CrewMember is null!");
					return;
				}
				_loc13_ = m.getInt(i + 1);
				_loc12_ = Area.getSkillTypeHtml(_loc13_);
				_loc4_ = m.getNumber(i + 2);
				_loc5_ = m.getNumber(i + 3);
				_loc6_ = m.getNumber(i + 4);
				_loc16_.skillPoints += _loc4_;
				_loc16_.injuryEnd = _loc6_;
				_loc16_.injuryStart = _loc5_;
				_loc16_.fullLocation = "";
				_loc16_.body = "";
				_loc16_.area = "";
				_loc16_.solarSystem = "";
				_loc7_ = new Image(textureManager.getTextureGUIByKey(_loc16_.imageKey));
				_loc7_.x = 760 / 2 - _loc7_.width / 2;
				_loc7_.y = 100;
				_loc11_.push(TweenMax.from(_loc7_,1,{
					"alpha":0,
					"paused":true
				}));
				_loc15_.addChild(_loc7_);
				_loc8_ = new TextBitmap(760 / 2,_loc7_.y + _loc7_.height + 20);
				_loc8_.size = 18;
				_loc8_.text = _loc16_.name;
				_loc8_.center();
				_loc11_.push(TweenMax.from(_loc8_,1,{
					"alpha":0,
					"paused":true
				}));
				_loc15_.addChild(_loc8_);
				_loc10_ = new Text(100,_loc8_.y + _loc8_.height + 20);
				_loc10_.size = 20;
				_loc10_.text = "New skill points: " + _loc4_;
				_loc10_.color = 0xffffff;
				_loc11_.push(TweenMax.from(_loc10_,0.5,{
					"scaleX":1.2,
					"scaleY":1.2,
					"paused":true
				}));
				_loc3_.push(_loc10_);
				_loc17_ = new Button(placeCrewSkills,"Place skill points","reward");
				_loc17_.x = 760 / 2 - _loc17_.width / 2;
				_loc17_.y = 500;
				_loc15_.addChild(_loc17_);
				if(_loc16_.injuryTime > 0)
				{
					_loc18_ = new Text(550,_loc8_.y + _loc8_.height + 20);
					_loc18_.size = 18;
					_loc18_.color = Style.COLOR_INJURED;
					_loc18_.text = "Injured " + Util.formatDecimal(_loc16_.injuryTime / 1000 / (60),1) + " min ";
					_loc3_.push(_loc18_);
					_loc11_.push(TweenMax.fromTo(_loc18_,1,{
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
				_loc9_ = 0;
				while(_loc9_ < _loc3_.length)
				{
					_loc14_ = _loc3_[_loc9_];
					_loc14_.x = 760 / 2;
					_loc14_.y = _loc8_.y + _loc8_.height + 20 + _loc9_ * (_loc14_.size + 10);
					_loc14_.center();
					_loc15_.addChild(_loc14_);
					_loc9_++;
				}
				crewStepContainers.push(_loc15_);
				i += 5;
			}
		}
	}
}

