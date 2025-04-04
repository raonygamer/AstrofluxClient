package core.hud.components
{
	import core.artifact.ArtifactCargoBox;
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.hud.components.explore.ExploreArea;
	import core.player.CrewMember;
	import core.player.Explore;
	import core.player.Player;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.states.menuStates.CrewState;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewDisplayBox extends Sprite
	{
		private static const HEIGHT:int = 128;
		private static const WIDTH:int = 117;
		public static const IMAGES_SPECIALS:Vector.<String> = Vector.<String>(["spec_cold.png","spec_heat.png","spec_radiation.png","spec_first_contact.png","spec_trade.png","spec_collaboration.png","spec_kinetic.png","spec_energy.png","spec_bio_weapons.png"]);
		public static const IMAGES_SKILLS:Vector.<String> = Vector.<String>(["skill_environment.png","skill_diplomacy.png","skill_combat.png"]);
		private var exploreTimer:HudTimer;
		private var img:Image;
		private var selectedFlash:Quad = new Quad(5 * 60,190,0xffffff);
		private var crewMember:CrewMember;
		private var area:ExploreArea;
		private var injuryTimer:HudTimer;
		private var injuryStatus:TextBitmap;
		private var upgradeArtifactBox:ArtifactCargoBox;
		private var upgradeInstantButton:Button;
		private var upgradeArtifactTimer:HudTimer;
		private var box:GradientBox;
		private var nextY:int = 30;
		public var selected:Boolean;
		private var g:Game;
		private var confirmBox:PopupConfirmMessage;
		private var p:Player;
		private var crewState:CrewState;
		private var inSelectState:Boolean;
		private var upgradeStatus:Text = new Text();
		private var textY:int = 155;
		private var selectButton:Button;
		private var inUse:Boolean = false;
		
		public function CrewDisplayBox(g:Game, crewMember:CrewMember, area:ExploreArea, p:Player = null, inSelectState:Boolean = true, crewState:CrewState = null)
		{
			this.crewMember = crewMember;
			this.crewState = crewState;
			this.area = area;
			this.g = g;
			this.p = p;
			super();
			selectedFlash.alpha = 0.1;
			selectedFlash.blendMode = "add";
			selectedFlash.touchable = false;
			selectedFlash.visible = false;
			selectedFlash.x = -15;
			selectedFlash.y = -15;
			selected = false;
			this.inSelectState = inSelectState;
			var _loc10_:ITextureManager = TextureLocator.getService();
			img = new Image(_loc10_.getTextureGUIByKey(crewMember.imageKey));
			img.x = 0;
			img.y = -15;
			img.height = 128;
			img.width = 117;
			img.visible = true;
			img.blendMode = "add";
			var _loc9_:TextField = new TextField(117,20,crewMember.name,new TextFormat("font13",14,0xffffff));
			_loc9_.x = 0;
			_loc9_.y = 117;
			box = new GradientBox(270,125,0,0.2);
			box.load();
			box.addChild(_loc9_);
			box.addChild(img);
			var _loc7_:TextBitmap = new TextBitmap(0,-7,crewMember.missions + " missions ");
			_loc7_.x = 278 - _loc7_.width;
			_loc7_.format.color = 0x686868;
			box.addChild(_loc7_);
			var _loc8_:TextBitmap = new TextBitmap(0,-7,CrewMember.getRank(crewMember.rank));
			_loc8_.x = _loc7_.x - _loc8_.width - 10;
			_loc8_.format.color = 16689475;
			box.addChild(_loc8_);
			addSkills(box);
			addChild(box);
			if(inSelectState)
			{
				useHandCursor = true;
			}
			addEventListener("touch",onTouch);
			addLocation(box,inSelectState);
			addChild(selectedFlash);
			addEventListener("removedFromStage",clean);
		}
		
		public function get key() : String
		{
			return crewMember.key;
		}
		
		public function getLevel(i:int) : int
		{
			return crewMember.skills[i];
		}
		
		public function showLackSpecialSkill() : void
		{
			var _loc1_:TextBitmap = new TextBitmap(-15,textY,"Not skilled enough");
			_loc1_.format.color = 0xff0000;
			addChild(_loc1_);
		}
		
		public function update() : void
		{
			var _loc1_:TextBitmap = null;
			var _loc2_:TextBitmap = null;
			if(exploreTimer != null)
			{
				if(exploreTimer.isComplete())
				{
					box.removeChild(exploreTimer);
					exploreTimer = null;
					_loc1_ = new TextBitmap(box.x + 285,textY,"Waiting for pickup");
					_loc1_.format.color = 0x55ff55;
					_loc1_.alignRight();
					box.addChild(_loc1_);
				}
				else
				{
					exploreTimer.update();
				}
			}
			if(injuryTimer != null)
			{
				if(injuryTimer.isComplete())
				{
					removeChild(injuryTimer);
					removeChild(injuryStatus);
					injuryTimer = null;
					_loc2_ = new TextBitmap(box.x + 285,textY,"Onboard ship");
					_loc2_.format.color = 0x686868;
					_loc2_.alignRight();
					box.addChild(_loc2_);
				}
				else
				{
					injuryTimer.update();
				}
			}
			if(upgradeArtifactTimer != null)
			{
				if(upgradeArtifactTimer.isComplete())
				{
					upgradeArtifactComplete();
				}
				else
				{
					upgradeArtifactTimer.update();
				}
			}
			else if(crewMember.isUpgrading)
			{
				addUpgradeTimer();
			}
		}
		
		public function toggleSelected() : Boolean
		{
			var _loc1_:String = "ADD";
			if(selected)
			{
				selected = false;
				selectButton.x = 215;
				selectedFlash.visible = false;
			}
			else
			{
				_loc1_ = "REMOVE";
				selected = true;
				selectButton.x = 185;
				selectedFlash.visible = true;
			}
			if(selectButton != null)
			{
				selectButton.text = _loc1_;
			}
			return selected;
		}
		
		public function getChance() : Number
		{
			return Area.getSuccessChance(area.level,area.type,crewMember,area.specialTypes);
		}
		
		public function getTime() : Number
		{
			return Area.getTime(area.size,area.level,area.rewardLevel,area.specialTypes,crewMember.skills[area.type]);
		}
		
		private function upgradeArtifactComplete() : void
		{
			var _loc1_:TextBitmap = null;
			removeChild(upgradeArtifactTimer);
			removeChild(upgradeArtifactBox);
			removeChild(upgradeInstantButton);
			upgradeArtifactTimer = null;
			_loc1_ = new TextBitmap(box.x + 285,textY,"Onboard ship");
			_loc1_.format.color = 0x686868;
			_loc1_.alignRight();
			box.addChild(_loc1_);
		}
		
		private function addUpgradeTimer() : void
		{
			if(crewMember.artifactEnd == 0)
			{
				return;
			}
			if(crewMember.artifactEnd < g.time)
			{
				return;
			}
			if(upgradeArtifactTimer != null)
			{
				return;
			}
			upgradeArtifactTimer = new HudTimer(g,10);
			upgradeArtifactTimer.start(g.time,crewMember.artifactEnd);
			upgradeArtifactTimer.x = box.x + 200;
			upgradeArtifactTimer.y = textY;
			addChild(upgradeArtifactTimer);
			upgradeStatus.x = box.x;
			upgradeStatus.y = textY;
			upgradeStatus.text = "Upgrading";
			addChild(upgradeStatus);
			upgradeArtifactBox = new ArtifactCargoBox(g,g.me.getArtifactById(crewMember.artifact));
			upgradeArtifactBox.scaleX = upgradeArtifactBox.scaleY = 0.75;
			upgradeArtifactBox.x = upgradeStatus.x + upgradeStatus.width + 5;
			upgradeArtifactBox.y = textY;
			addChild(upgradeArtifactBox);
		}
		
		private function instantArtifactUpgrade(m:Message) : void
		{
			if(m.getBoolean(0))
			{
				crewMember.artifactEnd = m.getNumber(1);
				upgradeArtifactComplete();
			}
			else if(m.length > 1)
			{
				g.showErrorDialog(m.getString(1),false);
			}
		}
		
		private function addLocation(box:GradientBox, inSelectState:Boolean) : void
		{
			var _loc4_:TextBitmap = null;
			var _loc6_:TextBitmap = null;
			var _loc3_:TextBitmap = null;
			if(crewMember.fullLocation != null && crewMember.fullLocation != "")
			{
				_loc4_ = new TextBitmap(box.x - 15,textY);
				_loc4_.format.color = 0xffff00;
				_loc4_.text = crewMember.getCompactFullLocation();
				box.addChild(_loc4_);
				for each(var _loc5_ in p.explores)
				{
					if(_loc5_.areaKey == crewMember.area)
					{
						if(_loc5_.finishTime >= g.time)
						{
							exploreTimer = new HudTimer(g);
							exploreTimer.start(_loc5_.startTime,_loc5_.finishTime);
							exploreTimer.x = box.x + 200;
							exploreTimer.y = textY;
							box.addChild(exploreTimer);
							break;
						}
						_loc4_ = new TextBitmap(box.x + 285,textY,"Waiting for pickup");
						_loc4_.format.color = 0x55ff55;
						_loc4_.alignRight();
						box.addChild(_loc4_);
					}
				}
			}
			else if(crewMember.isInjured)
			{
				injuryStatus = new TextBitmap(-15,textY,"In sick bay, injured");
				injuryStatus.format.color = 0xff0000;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = box.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(crewMember.injuryStart,crewMember.injuryEnd);
				addChild(injuryTimer);
			}
			else if(crewMember.isTraining)
			{
				if(crewMember.isTrainingComplete)
				{
					injuryStatus = new TextBitmap(-15,textY,"Training complete");
					injuryStatus.format.color = 0xff00;
					addChild(injuryStatus);
					return;
				}
				injuryStatus = new TextBitmap(-15,textY,"Training");
				injuryStatus.format.color = Style.COLOR_DARK_GREEN;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = box.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(g.time,crewMember.trainingEnd);
				addChild(injuryTimer);
			}
			else if(crewMember.isUpgrading)
			{
				addUpgradeTimer();
			}
			else if(inSelectState)
			{
				_loc6_ = new TextBitmap(-15,textY,"INJURY RISK: ");
				addChild(_loc6_);
				_loc3_ = Area.injuryRiskText(area.level,area.type,area.size,crewMember,area.specialTypes);
				_loc3_.x = _loc6_.x + _loc6_.width + 5;
				_loc3_.y = textY;
				addChild(_loc3_);
				selectButton = new Button(null,"ADD");
				selectButton.x = 215;
				selectButton.y = textY;
				selectButton.alignWithText();
				selectButton.autoEnableAfterClick = true;
				addChild(selectButton);
			}
			else
			{
				_loc6_ = new TextBitmap(box.x + 285,textY,"Onboard ship");
				_loc6_.format.color = 0x686868;
				_loc6_.alignRight();
				box.addChild(_loc6_);
			}
		}
		
		override public function get height() : Number
		{
			return 190;
		}
		
		private function addSkills(box:GradientBox) : void
		{
			var _loc2_:int = 160;
			var _loc3_:int = 30;
			addSkill("Survival",_loc2_,_loc3_);
			addSkill("Diplomacy",_loc2_,_loc3_ + 30);
			addSkill("Combat",_loc2_,_loc3_ + 60);
			addSpecialSkills();
		}
		
		private function addSpecialSkills() : void
		{
			var _loc1_:Quad = null;
			var _loc5_:Quad = null;
			var _loc4_:int = 0;
			var _loc2_:int = 115;
			var _loc3_:int = 110;
			_loc4_ = 0;
			while(_loc4_ < 9)
			{
				_loc1_ = new Quad(11,2,0x888888);
				if(crewMember.specials[_loc4_] > 0 && crewMember.specials[_loc4_] < 1)
				{
					_loc5_ = new Quad(11,2,0x88ff88);
					_loc5_.x = _loc2_ + 3;
					_loc5_.y = _loc3_ + 25;
					_loc1_.x = _loc2_ + 3;
					_loc1_.y = _loc3_ + 25;
					_loc1_.width = 11 * crewMember.specials[_loc4_];
					box.addChild(_loc5_);
					box.addChild(_loc1_);
					addSpecialIcon(box,_loc4_,_loc2_,_loc3_,true);
				}
				else if(crewMember.specials[_loc4_] == 0)
				{
					addSpecialIcon(box,_loc4_,_loc2_,_loc3_,true);
				}
				else if(crewMember.specials[_loc4_] >= 1)
				{
					addSpecialIcon(box,_loc4_,_loc2_,_loc3_);
				}
				_loc2_ += 18;
				_loc4_++;
			}
		}
		
		private function addSkill(name:String, x:int, y:int) : void
		{
			var _loc4_:String = null;
			if(name == "Survival")
			{
				_loc4_ = "skill_environment.png";
			}
			else if(name == "Diplomacy")
			{
				_loc4_ = "skill_diplomacy.png";
			}
			else
			{
				_loc4_ = "skill_combat.png";
			}
			var _loc8_:int = crewMember.getSkillValueByName(name);
			var _loc7_:TextBitmap = new TextBitmap(x + 20,y - 2,"lvl",14);
			_loc7_.format.color = 0x4a4a4a;
			box.addChild(_loc7_);
			var _loc10_:TextBitmap = new TextBitmap(x + 2 * 60,y - 10,"" + _loc8_,28);
			_loc10_.x = x + 2 * 60 - _loc10_.width;
			_loc10_.format.color = getSkillColor(_loc8_);
			box.addChild(_loc10_);
			var _loc9_:ITextureManager = TextureLocator.getService();
			var _loc5_:Image = new Image(_loc9_.getTextureGUIByTextureName(_loc4_));
			_loc5_.x = x;
			_loc5_.y = y;
			var _loc6_:Sprite = new Sprite();
			_loc6_.addChild(_loc5_);
			new ToolTip(g,_loc6_,name,null,"crewSkill");
			box.addChild(_loc6_);
		}
		
		private function getSkillColor(skillValue:int) : uint
		{
			var _loc3_:int = 0;
			var _loc4_:int = 0;
			var _loc2_:int = 0;
			_loc3_ = 0;
			while(_loc3_ < crewMember.skills.length)
			{
				_loc4_ = int(crewMember.skills[_loc3_]);
				if(skillValue > _loc4_)
				{
					_loc2_++;
				}
				_loc3_++;
			}
			if(_loc2_ == 2)
			{
				return 0xffffff;
			}
			if(_loc2_ == 1)
			{
				return 0xadadad;
			}
			return 0x4a4a4a;
		}
		
		private function addSpecialIcon(box:GradientBox, i:int, xpos:int, ypos:int, gray:Boolean = false) : void
		{
			var _loc6_:Image = null;
			var _loc8_:ITextureManager = TextureLocator.getService();
			if(gray)
			{
				_loc6_ = new Image(_loc8_.getTextureGUIByTextureName(IMAGES_SPECIALS[i] + "_inactive"));
			}
			else
			{
				_loc6_ = new Image(_loc8_.getTextureGUIByTextureName(IMAGES_SPECIALS[i]));
			}
			_loc6_.x = xpos + 4;
			_loc6_.y = ypos + 8;
			var _loc7_:Sprite = new Sprite();
			_loc7_.addChild(_loc6_);
			new ToolTip(g,_loc7_,Area.SPECIALTYPE[i],null,"crewSkill");
			box.addChild(_loc7_);
		}
		
		private function useTeam(e:TouchEvent = null) : void
		{
			inUse = !inUse;
			if(crewMember.isInjured)
			{
				g.showErrorDialog("This crew member is injured.");
				return;
			}
			if(crewMember.isDeployed)
			{
				g.showErrorDialog("This crew member is already deployed.");
				return;
			}
			dispatchEvent(new Event("teamSelected"));
		}
		
		public function mOver(e:TouchEvent) : void
		{
			if(inUse)
			{
				return;
			}
		}
		
		public function mOut(e:TouchEvent) : void
		{
			if(inUse)
			{
				return;
			}
		}
		
		public function dismiss(e:TouchEvent) : void
		{
			confirmBox = new PopupConfirmMessage("Fire","No, don\'t.");
			confirmBox.text = "Are you sure you want to fire " + crewMember.name + " from your crew?";
			g.addChildToOverlay(confirmBox,true);
			confirmBox.addEventListener("accept",onAccept);
			confirmBox.addEventListener("close",onClose);
		}
		
		private function onAccept(e:Event) : void
		{
			var _loc3_:CrewMember = null;
			var _loc2_:int = 0;
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
			g.send("removeCrewMember",crewMember.key);
			_loc2_ = 0;
			while(_loc2_ < p.crewMembers.length)
			{
				_loc3_ = p.crewMembers[_loc2_];
				if(_loc3_ == crewMember)
				{
					p.crewMembers.splice(_loc2_,1);
					break;
				}
				_loc2_++;
			}
			if(crewState != null)
			{
				crewState.refresh();
			}
		}
		
		private function onClose(e:Event) : void
		{
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			if(!inSelectState)
			{
				return;
			}
			if(e.getTouch(this,"ended"))
			{
				useTeam(e);
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
			ToolTip.disposeType("crewSkill");
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
		}
	}
}

