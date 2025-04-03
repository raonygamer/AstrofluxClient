package core.states.exploreStates
{
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.hud.components.explore.ExploreArea;
	import core.hud.components.explore.ExploreMap;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import core.states.DisplayState;
	import feathers.controls.ScrollContainer;
	import flash.display.Bitmap;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class SelectTeamState extends DisplayState
	{
		public static var WIDTH:Number = 698;
		
		public static var PADDING:Number = 31;
		
		private var effectBackground:Bitmap;
		
		private var _callback:Function;
		
		private var confirmBox:PopupConfirmMessage;
		
		private var sendButton:Button;
		
		private var sizeText:TextBitmap;
		
		private var mainBody:ScrollContainer;
		
		private var clock:Image;
		
		private var hr:Image;
		
		private var time:TextBitmap;
		
		private var chance:Text;
		
		private var crewBoxes:Vector.<CrewDisplayBox> = new Vector.<CrewDisplayBox>();
		
		private var selectedCrew:Vector.<CrewDisplayBox> = new Vector.<CrewDisplayBox>();
		
		private var selectedText:TextBitmap;
		
		private var selectedText3:TextBitmap;
		
		private var b:Body;
		
		private var area:ExploreArea;
		
		public function SelectTeamState(g:Game, b:Body, area:ExploreArea)
		{
			super(g,ExploreState);
			this.b = b;
			this.area = area;
		}
		
		override public function enter() : void
		{
			var bottomY:int;
			var heading:TextBitmap;
			var textureManager:ITextureManager;
			var i:int;
			var t:int;
			var chanceText:TextBitmap;
			var level:TextBitmap;
			var lvl:TextBitmap;
			super.enter();
			super.backButton.text = "Cancel";
			super.backButton.x = 468;
			super.backButton.y = 532;
			bottomY = 538;
			heading = new TextBitmap(50,50,area.name,26);
			heading.format.color = Area.COLORTYPE[area.type];
			addChild(heading);
			sizeText = new TextBitmap();
			sizeText.size = 16;
			sizeText.format.color = 0x4a4a4a;
			sizeText.text = "(" + Area.getSizeString(area.size).toLocaleUpperCase() + ")";
			sizeText.x = heading.x + heading.width + 17;
			sizeText.y = heading.y + 10;
			addChild(sizeText);
			textureManager = TextureLocator.getService();
			i = 0;
			addSkillIcon(textureManager.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[area.type]),i,Area.SKILLTYPE[area.type]);
			for each(t in area.specialTypes)
			{
				i++;
				addSkillIcon(textureManager.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[t]),i,Area.SPECIALTYPE[t]);
			}
			chanceText = new TextBitmap(55,bottomY,"Success Chance:");
			chanceText.format.color = 0x686868;
			addChild(chanceText);
			chance = new Text();
			chance.color = 0xffffff;
			chance.htmlText = "None".toLocaleUpperCase();
			chance.x = chanceText.x + chanceText.width + 7;
			chance.y = bottomY;
			chance.size = 12;
			addChild(chance);
			time = new TextBitmap(380,bottomY,"---------",12);
			addChild(time);
			level = new TextBitmap(705,50,"" + area.level,32);
			level.x = 705 - level.width;
			addChild(level);
			lvl = new TextBitmap(0,level.y + 16,"lvl",12);
			lvl.x = level.x - lvl.width;
			lvl.format.color = 0x4a4a4a;
			addChild(lvl);
			clock = new Image(textureManager.getTextureGUIByTextureName("clock.png"));
			clock.x = time.x - 32;
			clock.y = time.y - 1;
			addChild(clock);
			hr = new Image(textureManager.getTextureGUIByTextureName("hr.png"));
			hr.x = 42;
			hr.y = bottomY - 25;
			addChild(hr);
			sendButton = new Button(function(param1:Event):void
			{
				if(selectedCrew.length > 0)
				{
					send();
				}
			},"START EXPLORE","positive");
			sendButton.x = 562;
			sendButton.y = 532;
			sendButton.size = 13;
			sendButton.enabled = false;
			sendButton.visible = true;
			addChild(sendButton);
			mainBody = new ScrollContainer();
			mainBody.width = 12 * 60;
			mainBody.height = 418;
			mainBody.x = 4;
			mainBody.y = 90;
			addChild(mainBody);
			load();
		}
		
		public function addSkillIcon(txt:Texture, i:int, toolTipText:String) : void
		{
			var _loc4_:Sprite = new Sprite();
			_loc4_.x = sizeText.x + sizeText.width + 10 + 20 * i;
			_loc4_.y = sizeText.y + 2;
			var _loc5_:Image = new Image(txt);
			_loc5_.filter = new ColorMatrixFilter();
			_loc4_.addChild(_loc5_);
			new ToolTip(g,_loc4_,toolTipText,null,"skill");
			addChild(_loc4_);
		}
		
		override public function execute() : void
		{
			for each(var _loc1_ in crewBoxes)
			{
				_loc1_.update();
			}
		}
		
		private function send() : void
		{
			confirmBox = new PopupConfirmMessage();
			confirmBox.text = "Are you sure you want to proceed? Exploring this area will take <FONT COLOR=\'#adff2f\'>" + getTime() + "</FONT> with a " + getChance() + " success chance.";
			g.addChildToOverlay(confirmBox,true);
			confirmBox.addEventListener("accept",onAccept);
			confirmBox.addEventListener("close",onClose);
		}
		
		private function onAccept(e:Event) : void
		{
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListener("accept",onAccept);
			confirmBox.removeEventListener("close",onClose);
			area.startExplore(selectedCrew,function():void
			{
				ExploreMap.forceSelectAreaKey = area.areaKey;
				sm.changeState(new ExploreState(g,area.body));
			});
		}
		
		private function onClose(e:Event) : void
		{
			var _loc3_:int = 0;
			var _loc2_:CrewDisplayBox = null;
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListener("accept",onAccept);
			confirmBox.removeEventListener("close",onClose);
			_loc3_ = 0;
			while(_loc3_ < crewBoxes.length)
			{
				_loc2_ = crewBoxes[_loc3_];
				if(_loc2_.selected)
				{
					_loc2_.toggleSelected();
				}
				_loc3_++;
			}
			selectedCrew.splice(0,selectedCrew.length);
			reload();
		}
		
		private function reload() : void
		{
			if(selectedCrew.length > 0)
			{
				sendButton.enabled = true;
			}
			else
			{
				sendButton.enabled = false;
			}
			time.text = getTime();
			clock.x = time.x - 32;
			chance.htmlText = getChance().toLocaleUpperCase();
		}
		
		private function getTime() : String
		{
			var _loc6_:Vector.<Number> = new Vector.<Number>();
			for each(var _loc7_ in selectedCrew)
			{
				_loc6_.push(_loc7_.getTime());
			}
			if(_loc6_.length == 0)
			{
				return "--------";
			}
			_loc6_.sort(16);
			var _loc2_:Number = 0;
			var _loc8_:Number = _loc6_[0];
			_loc2_ = Number(_loc6_.shift());
			while(_loc6_.length > 0)
			{
				_loc2_ -= _loc2_ * 0.35 * _loc8_ / _loc6_.shift();
			}
			if(_loc2_ < 10)
			{
				_loc2_ = 10;
			}
			_loc2_ = area.adjustTimeEstimate(_loc2_);
			var _loc4_:String = "";
			var _loc1_:int = _loc2_ % (60);
			var _loc3_:int = (_loc2_ - _loc1_) / (60) % (60);
			var _loc5_:int = (_loc2_ - _loc3_ * (60) - _loc1_) / (60 * 60) % (60);
			if(_loc5_ > 0)
			{
				_loc4_ += _loc5_ + " h  ";
			}
			if(_loc5_ > 0 || _loc3_ > 0)
			{
				_loc4_ += _loc3_ + " m  ";
			}
			if(_loc5_ == 0 && (_loc3_ > 0 || _loc1_ > 0))
			{
				_loc4_ += _loc1_ + " s";
			}
			return _loc4_;
		}
		
		private function getChance() : String
		{
			var _loc4_:Number = NaN;
			var _loc1_:Vector.<Number> = new Vector.<Number>();
			for each(var _loc5_ in selectedCrew)
			{
				_loc1_.push(_loc5_.getChance());
			}
			if(_loc1_.length == 0)
			{
				return "<FONT COLOR=\'#ff0000\'>None</FONT>";
			}
			var _loc3_:Number = 1;
			for each(var _loc2_ in _loc1_)
			{
				_loc3_ *= 1 - _loc2_;
			}
			_loc3_ = 1 - _loc3_;
			for each(_loc5_ in selectedCrew)
			{
				_loc4_ = area.level - _loc5_.getLevel(area.type);
				if(_loc4_ > 10)
				{
					_loc3_ -= 0.005 * _loc4_;
				}
			}
			if(_loc3_ < 0)
			{
				_loc3_ = 0;
			}
			if(_loc3_ > 0.95)
			{
				return "<FONT COLOR=\'#5dfc0a\'>Excellent</FONT>";
			}
			if(_loc3_ > 0.85)
			{
				return "<FONT COLOR=\'#adff2f\'>Very Good</FONT>";
			}
			if(_loc3_ > 0.75)
			{
				return "<FONT COLOR=\'#eeee00\'>Good</FONT>";
			}
			if(_loc3_ > 0.5)
			{
				return "<FONT COLOR=\'#ff6600\'>Fair</FONT>";
			}
			if(_loc3_ > 0.33)
			{
				return "<FONT COLOR=\'#ff030d\'>Poor</FONT>";
			}
			if(_loc3_ > 0)
			{
				return "<FONT COLOR=\'#ff0000\'>Very Poor</FONT>";
			}
			return "<FONT COLOR=\'#ff0000\'>None</FONT>";
		}
		
		override public function get type() : String
		{
			return "SelectTeamState";
		}
		
		private function load() : void
		{
			var c:CrewMember;
			var i:int;
			var x:int;
			var w:int;
			var y:int;
			var crewMember:CrewMember;
			var selectable:Boolean;
			var hasSkills:Boolean;
			var cdb:CrewDisplayBox;
			var crewMembers:Vector.<CrewMember> = new Vector.<CrewMember>();
			for each(c in g.me.crewMembers)
			{
				if(c.availableForExplore(area))
				{
					crewMembers.push(c);
				}
			}
			for each(c in g.me.crewMembers)
			{
				if(!c.availableForExplore(area))
				{
					crewMembers.push(c);
				}
			}
			i = 0;
			x = 70;
			w = 340;
			y = 28;
			for each(crewMember in crewMembers)
			{
				selectable = crewMember.availableForExplore(area);
				hasSkills = crewMember.hasSpecialAreaSkill(area);
				if(selectable && !hasSkills)
				{
					selectable = false;
				}
				cdb = new CrewDisplayBox(g,crewMember,area,g.me,selectable);
				if(!selectable && !hasSkills)
				{
					cdb.showLackSpecialSkill();
				}
				cdb.x = x;
				cdb.y = y;
				if(i % 2 == 0)
				{
					x += w;
				}
				else
				{
					x -= w;
					y += cdb.height + 40;
				}
				i++;
				if(!selectable)
				{
					cdb.alpha = 0.4;
				}
				mainBody.addChild(cdb);
				crewBoxes.push(cdb);
				cdb.addEventListener("teamSelected",function(param1:Event):void
				{
					var _loc3_:CrewDisplayBox = null;
					var _loc2_:int = 0;
					if(param1.target is CrewDisplayBox)
					{
						_loc3_ = param1.target as CrewDisplayBox;
						if(_loc3_.toggleSelected())
						{
							selectedCrew.push(_loc3_);
						}
						else
						{
							_loc2_ = int(selectedCrew.indexOf(_loc3_));
							if(_loc2_ != -1)
							{
								selectedCrew.splice(_loc2_,1);
							}
						}
						reload();
					}
				});
			}
			reload();
			g.tutorial.showSendCrewHint();
		}
		
		override public function exit() : void
		{
			ToolTip.disposeType("skill");
			for each(var _loc1_ in crewBoxes)
			{
				_loc1_.removeEventListeners();
			}
			super.exit();
		}
	}
}

