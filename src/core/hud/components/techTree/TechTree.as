package core.hud.components.techTree
{
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.hud.components.Button;
	import core.hud.components.LootItem;
	import core.hud.components.PriceCommodities;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.cargo.Cargo;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.dialogs.LootPopupConfirmMessage;
	import core.player.EliteTechSkill;
	import core.player.EliteTechs;
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.weapon.WeaponDataHolder;
	import debug.Console;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import generics.Localize;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class TechTree extends Sprite
	{
		private static const UPGRADE_LEVEL_REQUIREMENTS:Array = [1,2,4,8,12,16];
		private var container:ScrollContainer = new ScrollContainer();
		private var myCargo:Cargo;
		private var _nrOfUpgrades:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0]);
		
		private var upgradeCallback:Function;
		private var buyWithResourcesButton:Button;
		private var switchEliteTechButton:Button;
		private var buyWithFluxButton:Button;
		private var resetButton:Button;
		private var resetPackageButton:Button;
		private var cheatButton:Button;
		private var confirmBox:LootPopupConfirmMessage;
		public var techBars:Vector.<TechBar> = new Vector.<TechBar>();
		public var techSelectedForUpgrade:TechLevelIcon = null;
		public var eliteTechSelectedForUpgrade:EliteTechIcon = null;
		private var eliteSlider:Slider = new Slider();
		private var eliteSliderLabel:Text = new Text();
		private var canUpgrade:Boolean;
		private var g:Game;
		private var me:Player;
		private var scrollHeight:Number;
		private var upgradeInfo:Sprite = new Sprite();
		private var nameText:Text = new Text();
		private var description:Text = new Text();
		private var descriptionNextLevel:Text = new Text();
		private var eliteUpgradeHeading:TextBitmap = new TextBitmap();
		private var mineralType1Cost:PriceCommodities = null;
		private var mineralType2Cost:PriceCommodities = null;
		private var mineralType3Cost:PriceCommodities = null;
		private var mineralType4Cost:PriceCommodities = null;
		private var autoUpdateEliteUpgradeStartValue:int = 0;
		private var upgradeEliteLevelTo:int = 1;
		private var isUpgradingEliteTech:Boolean = false;
		private var fluxReset:int = 0;
		
		public function TechTree(g:Game, scrollHeight:Number = 400, canUpgrade:Boolean = false, upgradeCallback:Function = null)
		{
			super();
			this.g = g;
			this.me = g.me;
			this.myCargo = g.myCargo;
			this.canUpgrade = canUpgrade;
			this.upgradeCallback = upgradeCallback;
			this._nrOfUpgrades = me.nrOfUpgrades;
			this.scrollHeight = scrollHeight;
			nameText.font = "Verdana";
			description.font = "Verdana";
			descriptionNextLevel.font = "Verdana";
		}
		
		public static function hasRequiredLevel(upgradeLevel:int, playerLevel:int) : Boolean
		{
			return getRequiredLevel(upgradeLevel) <= playerLevel;
		}
		
		public static function getRequiredLevel(upgradeLevel:int) : int
		{
			return TechTree.UPGRADE_LEVEL_REQUIREMENTS[upgradeLevel - 1];
		}
		
		public function load() : void
		{
			var techSkills:Vector.<TechSkill>;
			var i:int;
			var tl:TechSkill;
			var techBar:TechBar;
			container.width = 390;
			container.height = scrollHeight;
			addChild(container);
			hideEliteSlider();
			techSkills = g.me.techSkills;
			i = 0;
			while(i < techSkills.length)
			{
				tl = techSkills[i];
				techBar = new TechBar(g,tl,me,canUpgrade);
				techBar.x = 20;
				techBar.y = i * 45;
				if(canUpgrade)
				{
					techBar.addEventListener("mClick",click);
				}
				techBar.addEventListener("mOver",over);
				techBar.addEventListener("mOut",out);
				techBars.push(techBar);
				container.addChild(techBar);
				i++;
			}
			switchEliteTechButton = new Button(changeEliteTech,"Switch Elite Tech","normal");
			switchEliteTechButton.x = 410;
			switchEliteTechButton.y = -48 - switchEliteTechButton.height;
			switchEliteTechButton.visible = false;
			buyWithResourcesButton = new Button(buyUpgrade,"Buy","normal");
			buyWithResourcesButton.x = 410;
			buyWithResourcesButton.y = -40;
			buyWithResourcesButton.visible = false;
			buyWithFluxButton = new Button(handleClickBuyWithFlux,"Buy for 100 Flux","positive");
			buyWithFluxButton.x = 410 + buyWithResourcesButton.width + 16;
			buyWithFluxButton.y = -40;
			buyWithFluxButton.visible = false;
			resetButton = new Button(buyReset,"Reset Upgrades");
			resetButton.x = 20;
			resetButton.y = 410;
			resetButton.enabled = g.me.nrOfUpgrades[0] > 0 && !isUpgradingEliteTech;
			resetPackageButton = new Button(buyResetPackage,"Get Reset Package","buy");
			resetPackageButton.x = resetButton.x + resetButton.width + 10;
			resetPackageButton.y = 410;
			resetPackageButton.enabled = g.me.nrOfUpgrades[0] > 0 && !isUpgradingEliteTech;
			resetPackageButton.visible = !g.me.hasSupporter();
			if(g.me.isDeveloper)
			{
				cheatButton = new Button(cheat,"Cheat","negative");
				cheatButton.visible = false;
				cheatButton.y = 410;
				cheatButton.x = 350;
				addChild(cheatButton);
			}
			if(canUpgrade)
			{
				addChild(buyWithResourcesButton);
				if(g.me.level >= 1)
				{
					addChild(resetButton);
					addChild(resetPackageButton);
					addChild(buyWithFluxButton);
					addChild(switchEliteTechButton);
				}
			}
			upgradeInfo.addChild(nameText);
			upgradeInfo.addChild(description);
			upgradeInfo.addChild(descriptionNextLevel);
			upgradeInfo.addChild(eliteUpgradeHeading);
			upgradeInfo.addChild(eliteSliderLabel);
			upgradeInfo.addChild(eliteSlider);
			addChild(upgradeInfo);
			upgradeInfo.visible = false;
			eliteSlider.addEventListener("change",function(param1:Event):void
			{
				updateEliteUpgradeLevels();
				updateUpgradeInfo();
				updateEliteTechUpgradeInfo(eliteTechSelectedForUpgrade);
			});
		}
		
		private function handleClickBuyWithFlux(e:TouchEvent) : void
		{
			g.creditManager.refresh(function():void
			{
				var confirmBuyWithFlux:CreditBuyBox;
				if(techSelectedForUpgrade != null)
				{
					confirmBuyWithFlux = new CreditBuyBox(g,CreditManager.getCostUpgrade(techSelectedForUpgrade.level),"Are you sure you want to buy this upgrade?");
					confirmBuyUpgradeWithFlux(e,confirmBuyWithFlux);
				}
				else
				{
					confirmBuyWithFlux = new CreditBuyBox(g,EliteTechs.getFluxCostRange(eliteTechSelectedForUpgrade.level + 1,eliteSlider.value),"Are you sure you want to buy this upgrade?");
					confirmBuyEliteUpgradeWithFlux(e,confirmBuyWithFlux);
				}
				g.addChildToOverlay(confirmBuyWithFlux);
				confirmBuyWithFlux.addEventListener("close",function():void
				{
					buyWithFluxButton.enabled = true;
					confirmBuyWithFlux.removeEventListeners();
					g.removeChildFromOverlay(confirmBuyWithFlux,true);
				});
			});
		}
		
		private function confirmBuyUpgradeWithFlux(e:TouchEvent, confirmBuyWithFlux:CreditBuyBox) : void
		{
			confirmBuyWithFlux.addEventListener("accept",function():void
			{
				var tsfu:TechLevelIcon = techSelectedForUpgrade;
				Game.trackEvent("used flux","bought upgrade","number " + techSelectedForUpgrade.level,CreditManager.getCostUpgrade(techSelectedForUpgrade.level));
				TweenMax.delayedCall(1.2,function():void
				{
					Game.trackEvent("upgrades","Techs",tsfu.name + " " + tsfu.level,g.me.level);
				});
				buyUpgradeWithFlux(e);
				confirmBuyWithFlux.removeEventListeners();
			});
		}
		
		private function confirmBuyEliteUpgradeWithFlux(e:TouchEvent, confirmBuyWithFlux:CreditBuyBox) : void
		{
			confirmBuyWithFlux.addEventListener("accept",function():void
			{
				var etsfu:EliteTechIcon = eliteTechSelectedForUpgrade;
				Game.trackEvent("used flux","bought elite upgrade","number " + eliteTechSelectedForUpgrade.level,EliteTechs.getFluxCostRange(eliteTechSelectedForUpgrade.level + 1,eliteSlider.value));
				TweenMax.delayedCall(1.2,function():void
				{
					Game.trackEvent("upgrades","EliteTechs",etsfu.name + " " + etsfu.level,g.me.level);
				});
				autoUpdateEliteUpgradeStartValue = eliteSlider.value;
				buyEliteUpgradeWithFlux(e);
				confirmBuyWithFlux.removeEventListeners();
			});
		}
		
		private function updateSliderPos(xPos:int, yPos:int) : void
		{
			if(eliteSliderLabel == null)
			{
				return;
			}
			eliteSliderLabel.y = yPos;
			eliteSlider.y = yPos + 14;
			eliteSliderLabel.x = xPos + eliteSlider.width + 10;
			eliteSlider.x = xPos;
		}
		
		private function addSlider(s:Slider, value:Number, label:String, xPos:int, yPos:int) : void
		{
			s.minimum = 1;
			s.maximum = 100;
			s.step = 1;
			s.width = 200;
			s.value = value;
			s.direction == "horizontal";
			s.useHandCursor = true;
			eliteSliderLabel.htmlText = label;
		}
		
		public function get nrOfUpgrades() : Vector.<int>
		{
			return _nrOfUpgrades;
		}
		
		private function changeEliteTech(e:TouchEvent) : void
		{
			var popup:EliteTechPopupMenu;
			autoUpdateEliteUpgradeStartValue = 0;
			if(eliteTechSelectedForUpgrade != null)
			{
				popup = new EliteTechPopupMenu(g,eliteTechSelectedForUpgrade);
				g.addChildToOverlay(popup);
				popup.addEventListener("close",(function():*
				{
					var closePopup:Function;
					return closePopup = function(param1:Event):void
					{
						g.removeChildFromOverlay(popup);
						popup.removeEventListeners();
					};
				})());
				eliteTechSelectedForUpgrade.update(eliteTechSelectedForUpgrade.level);
				return;
			}
		}
		
		private function click(e:Event) : void
		{
			if(e.target is TechLevelIcon)
			{
				handleClickTechIcon(e.target as TechLevelIcon);
			}
			else if(e.target is EliteTechIcon)
			{
				handleClickEliteTechIcon(e.target as EliteTechIcon);
			}
		}
		
		private function handleClickTechIcon(tli:TechLevelIcon) : void
		{
			hideEliteSlider();
			if(techSelectedForUpgrade != null)
			{
				techSelectedForUpgrade.updateState("can be upgraded");
				if(techSelectedForUpgrade == tli)
				{
					techSelectedForUpgrade = null;
					buyWithResourcesButton.visible = false;
					buyWithFluxButton.visible = false;
					upgradeInfo.visible = false;
					switchEliteTechButton.visible = false;
					return;
				}
			}
			else if(eliteTechSelectedForUpgrade != null)
			{
				eliteTechSelectedForUpgrade.updateState("special selected and can be upgraded");
				eliteTechSelectedForUpgrade = null;
			}
			techSelectedForUpgrade = tli;
			buyWithResourcesButton.visible = true;
			buyWithFluxButton.visible = true;
			switchEliteTechButton.visible = false;
			if(!canAfford(tli))
			{
				buyWithResourcesButton.enabled = false;
			}
			else
			{
				buyWithResourcesButton.enabled = true;
			}
			buyWithResourcesButton.text = "Buy";
			buyWithFluxButton.text = "Buy for " + CreditManager.getCostUpgrade(tli.level) + " Flux";
			updateTechUpgradeInfo(techSelectedForUpgrade);
		}
		
		private function hideEliteSlider() : void
		{
			if(eliteSlider == null)
			{
				return;
			}
			eliteSlider.visible = false;
			eliteSliderLabel.visible = false;
		}
		
		private function showEliteSlider() : void
		{
			eliteSlider.visible = true;
			eliteSliderLabel.visible = true;
		}
		
		private function handleClickEliteTechIcon(eti:EliteTechIcon) : void
		{
			if(techSelectedForUpgrade != null)
			{
				techSelectedForUpgrade.updateState("can be upgraded");
				techSelectedForUpgrade = null;
			}
			else if(eliteTechSelectedForUpgrade != null)
			{
				eliteTechSelectedForUpgrade.updateState("special selected and can be upgraded");
				if(eliteTechSelectedForUpgrade == eti && !isUpgradingEliteTech)
				{
					eliteTechSelectedForUpgrade = null;
					buyWithResourcesButton.visible = false;
					buyWithFluxButton.visible = false;
					upgradeInfo.visible = false;
					switchEliteTechButton.visible = false;
					eliteUpgradeHeading.visible = false;
					return;
				}
			}
			eliteTechSelectedForUpgrade = eti;
			if(this.eliteTechSelectedForUpgrade.level < 100 && !isUpgradingEliteTech)
			{
				buyWithResourcesButton.visible = true;
				buyWithFluxButton.visible = true;
				if(!canAffordET(eti))
				{
					buyWithResourcesButton.enabled = false;
				}
				else
				{
					buyWithResourcesButton.enabled = true;
				}
				switchEliteTechButton.y = -48 - switchEliteTechButton.height;
				showEliteSlider();
				eliteSlider.maximum = 100;
				eliteSlider.minimum = eliteTechSelectedForUpgrade.level + 1;
				eliteSlider.value = eliteSlider.minimum;
			}
			else
			{
				buyWithResourcesButton.visible = false;
				buyWithFluxButton.visible = false;
				switchEliteTechButton.visible = false;
				switchEliteTechButton.y = -40;
				hideEliteSlider();
				resetButton.enabled = false;
			}
			if(!isUpgradingEliteTech)
			{
				switchEliteTechButton.visible = true;
				switchEliteTechButton.enabled = true;
			}
			buyWithResourcesButton.text = "Buy";
			buyWithFluxButton.text = "Buy for " + EliteTechs.getFluxCostRange(eti.level + 1,eliteSlider.value) + " Flux";
			updateEliteTechUpgradeInfo(eti);
			updateEliteUpgradeLevels();
		}
		
		private function updateEliteUpgradeLevels() : void
		{
			eliteSlider.minimum = eliteTechSelectedForUpgrade.level + 1;
			eliteSlider.maximum = 100;
			eliteSlider.step = 1;
			upgradeEliteLevelTo = eliteSlider.value;
		}
		
		private function over(e:Event) : void
		{
			var _loc2_:TechLevelIcon = null;
			var _loc3_:EliteTechIcon = null;
			if(techSelectedForUpgrade != null || eliteTechSelectedForUpgrade != null)
			{
				return;
			}
			eliteSlider.visible = false;
			eliteSliderLabel.visible = false;
			if(e.target is TechLevelIcon)
			{
				_loc2_ = e.target as TechLevelIcon;
				updateTechUpgradeInfo(_loc2_);
			}
			else if(e.target is EliteTechIcon)
			{
				_loc3_ = e.target as EliteTechIcon;
				updateEliteTechUpgradeInfo(_loc3_);
			}
		}
		
		private function out(e:Event) : void
		{
			if(techSelectedForUpgrade != null || eliteTechSelectedForUpgrade != null)
			{
				return;
			}
			upgradeInfo.visible = false;
		}
		
		private function updateUpgradeInfo() : void
		{
			if(descriptionNextLevel == null || eliteTechSelectedForUpgrade == null)
			{
				return;
			}
			var _loc1_:String = Localize.t("Upgrade to level [amount]");
			var _loc2_:int = 1;
			if(eliteSlider != null)
			{
				_loc2_ = eliteSlider.value;
			}
			_loc1_ = _loc1_.replace("[amount]",_loc2_);
			eliteUpgradeHeading.text = _loc1_;
			eliteUpgradeHeading.format.color = 0xffaa44;
			eliteUpgradeHeading.format.size = 16;
			descriptionNextLevel.htmlText = eliteTechSelectedForUpgrade.getDescriptionNextLevel(_loc2_);
		}
		
		private function updateEliteTechUpgradeInfo(eti:EliteTechIcon) : void
		{
			var _loc7_:String = null;
			var _loc3_:int = 0;
			var _loc4_:int = 0;
			var _loc6_:int = 0;
			var _loc10_:int = 0;
			var _loc5_:* = 0;
			var _loc11_:int = 0;
			var _loc12_:int = 0;
			var _loc2_:int = 0;
			var _loc8_:int = 0;
			var _loc9_:Number = NaN;
			if(g.me.isDeveloper && eti.level < 100)
			{
				cheatButton.enabled = true;
				cheatButton.visible = true;
			}
			upgradeInfo.visible = true;
			upgradeInfo.x = 410;
			description.visible = false;
			descriptionNextLevel.visible = false;
			eliteUpgradeHeading.visible = false;
			removeMineralCosts();
			description.x = 2;
			description.width = 270;
			description.wordWrap = true;
			description.color = 978670;
			description.visible = true;
			description.size = 10;
			description.htmlText = eti.getDescription();
			description.y = 0;
			nameText.visible = false;
			switchEliteTechButton.y = description.y + description.height + 20;
			if(eti.level == 100)
			{
				switchEliteTechButton.visible = false;
			}
			if(eti.level < 100 && eti.techSkill.activeEliteTech != null && eti.techSkill.activeEliteTech != "")
			{
				_loc7_ = eti.mineralType1;
				_loc3_ = eliteSlider.value;
				if(_loc3_ < eti.level + 1)
				{
					_loc3_ = eti.level + 1;
				}
				descriptionNextLevel.x = 2;
				descriptionNextLevel.width = 270;
				descriptionNextLevel.wordWrap = true;
				descriptionNextLevel.color = 0xaaaaaa;
				descriptionNextLevel.visible = true;
				descriptionNextLevel.size = 12;
				updateUpgradeInfo();
				_loc4_ = container.y + container.height;
				_loc4_ = _loc4_ + -buyWithResourcesButton.height;
				if(buyWithResourcesButton.visible)
				{
					buyWithResourcesButton.y = _loc4_;
					buyWithFluxButton.y = _loc4_;
				}
				_loc4_ += -15;
				_loc6_ = EliteTechs.getResource1CostRange(eti.level + 1,_loc3_);
				if(_loc6_ > 0 && _loc7_ != null)
				{
					_loc10_ = eti.level + 1;
					_loc5_ = _loc3_;
					_loc11_ = eti.getCostForResource("d6H3w_34pk2ghaQcXYBDag",_loc10_,_loc5_);
					_loc12_ = eti.getCostForResource("H5qybQDy9UindMh9yYIeqg",_loc10_,_loc5_);
					_loc2_ = eti.getCostForResource("gO_f-y0QEU68vVwJ_XVmOg",_loc10_,_loc5_);
					_loc8_ = 2;
					_loc9_ = 0.3;
					if(_loc2_ >= 0)
					{
						mineralType4Cost = new PriceCommodities(g,"gO_f-y0QEU68vVwJ_XVmOg",_loc2_,"Verdana",12);
						mineralType4Cost.x = _loc8_;
						_loc4_ += -mineralType4Cost.height;
						mineralType4Cost.y = _loc4_;
						mineralType4Cost.visible = true;
						if(_loc2_ == 0)
						{
							mineralType4Cost.alpha = _loc9_;
						}
						upgradeInfo.addChild(mineralType4Cost);
					}
					if(_loc12_ >= 0)
					{
						mineralType3Cost = new PriceCommodities(g,"H5qybQDy9UindMh9yYIeqg",_loc12_,"Verdana",12);
						mineralType3Cost.x = _loc8_;
						_loc4_ += -mineralType3Cost.height;
						mineralType3Cost.y = _loc4_;
						mineralType3Cost.visible = true;
						if(_loc12_ == 0)
						{
							mineralType3Cost.alpha = _loc9_;
						}
						upgradeInfo.addChild(mineralType3Cost);
					}
					if(_loc11_ >= 0)
					{
						mineralType2Cost = new PriceCommodities(g,"d6H3w_34pk2ghaQcXYBDag",_loc11_,"Verdana",12);
						mineralType2Cost.x = _loc8_;
						_loc4_ += -mineralType2Cost.height;
						mineralType2Cost.y = _loc4_;
						mineralType2Cost.visible = true;
						if(_loc11_ == 0)
						{
							mineralType2Cost.alpha = _loc9_;
						}
						upgradeInfo.addChild(mineralType2Cost);
					}
					mineralType1Cost = new PriceCommodities(g,_loc7_,_loc6_,"Verdana",12);
					mineralType1Cost.x = 2;
					_loc4_ += -mineralType1Cost.height;
					mineralType1Cost.y = _loc4_;
					mineralType1Cost.visible = true;
					upgradeInfo.addChild(mineralType1Cost);
					buyWithFluxButton.text = "Buy for " + EliteTechs.getFluxCostRange(eti.level + 1,_loc3_) + " Flux";
					_loc4_ += -105;
					eliteUpgradeHeading.y = _loc4_ - eliteUpgradeHeading.height;
					updateSliderPos(0,eliteUpgradeHeading.y + eliteSlider.height);
					if(!isUpgradingEliteTech && eliteTechSelectedForUpgrade != null)
					{
						showEliteSlider();
					}
					else
					{
						hideEliteSlider();
					}
					eliteUpgradeHeading.visible = true;
					descriptionNextLevel.y = eliteSlider.y + 16;
				}
			}
		}
		
		private function updateTechUpgradeInfo(tli:TechLevelIcon) : void
		{
			var _loc9_:String = null;
			var _loc3_:int = 0;
			var _loc6_:String = null;
			var _loc4_:int = 0;
			var _loc7_:String = null;
			var _loc5_:String = null;
			var _loc8_:int = 0;
			upgradeInfo.visible = true;
			upgradeInfo.x = 410;
			description.visible = false;
			descriptionNextLevel.visible = false;
			eliteSlider.visible = false;
			eliteSliderLabel.visible = false;
			eliteUpgradeHeading.visible = false;
			removeMineralCosts();
			description.x = 2;
			description.width = 270;
			description.wordWrap = true;
			description.color = 0xaaaaaa;
			description.visible = true;
			description.size = 12;
			if(tli.level == 0)
			{
				if(tli.table == "BasicTechs")
				{
					_loc9_ = tli.description;
				}
				for each(var _loc2_ in me.weaponData)
				{
					if(_loc2_.key == tli.tech)
					{
						_loc9_ = _loc2_.desc;
					}
				}
			}
			else
			{
				_loc9_ = tli.description;
			}
			description.htmlText = "<FONT COLOR=\'#ffaa44\' size=\'16\'>" + tli.upgradeName + "</FONT>\n";
			description.htmlText += _loc9_;
			description.y = nameText.y + nameText.height;
			nameText.visible = true;
			if(tli.level > 0)
			{
				_loc3_ = description.y + description.height + 25;
				_loc6_ = tli.mineralType1;
				_loc4_ = getMineralType1Cost(tli.level,tli.playerLevel);
				if(_loc4_ > 0 && _loc6_ != null && tli.playerLevel < tli.level)
				{
					_loc7_ = hasRequiredLevel(tli.level,me.level) ? "" : "<FONT COLOR=\'#ff4444\' SIZE=\'18\'>Requires level " + getRequiredLevel(tli.level) + "</FONT>\n";
					_loc9_ = _loc7_ + _loc9_;
					mineralType1Cost = new PriceCommodities(g,_loc6_,_loc4_,"Verdana",12);
					mineralType1Cost.x = 2;
					mineralType1Cost.y = _loc3_;
					mineralType1Cost.visible = true;
					upgradeInfo.addChild(mineralType1Cost);
					_loc3_ += mineralType1Cost.height;
					_loc5_ = tli.mineralType2;
					_loc8_ = getMineralType2Cost(tli.level);
					if(_loc8_ > 0 && _loc5_ != null)
					{
						mineralType2Cost = new PriceCommodities(g,_loc5_,_loc8_,"Verdana",12);
						mineralType2Cost.x = 2;
						mineralType2Cost.y = _loc3_;
						mineralType2Cost.visible = true;
						upgradeInfo.addChild(mineralType2Cost);
						_loc3_ += 16;
					}
				}
			}
			buyWithResourcesButton.y = _loc3_ + 25;
			buyWithFluxButton.y = _loc3_ + 25;
		}
		
		private function removeMineralCosts() : void
		{
			if(mineralType1Cost != null && upgradeInfo.contains(mineralType1Cost))
			{
				upgradeInfo.removeChild(mineralType1Cost);
			}
			if(mineralType2Cost != null && upgradeInfo.contains(mineralType2Cost))
			{
				upgradeInfo.removeChild(mineralType2Cost);
			}
			if(mineralType3Cost != null && upgradeInfo.contains(mineralType3Cost))
			{
				upgradeInfo.removeChild(mineralType3Cost);
			}
			if(mineralType4Cost != null && upgradeInfo.contains(mineralType4Cost))
			{
				upgradeInfo.removeChild(mineralType4Cost);
			}
		}
		
		private function buyResetPackage(e:TouchEvent) : void
		{
			g.creditManager.refresh(function():void
			{
				var resets:int = 10;
				var confirmBox:CreditBuyBox = new CreditBuyBox(g,100,"Do you want to buy " + resets + " resets?");
				confirmBox.addEventListener("accept",function():void
				{
					g.rpc("buyResetPackage",function(param1:Message):void
					{
						if(param1.getBoolean(0))
						{
							g.me.freeResets += resets;
							g.showMessageDialog("Your purchase was successful! \nYou have " + g.me.freeResets + " resets.");
						}
					});
					confirmBox.removeEventListeners();
					g.removeChildFromOverlay(confirmBox,true);
					resetPackageButton.enabled = true;
				});
				confirmBox.addEventListener("close",function():void
				{
					confirmBox.removeEventListeners();
					g.removeChildFromOverlay(confirmBox,true);
					resetPackageButton.enabled = true;
				});
				g.addChildToOverlay(confirmBox,true);
			});
		}
		
		private function buyReset(e:TouchEvent) : void
		{
			if(g.me.nrOfUpgrades[0] == 0)
			{
				return;
			}
			g.creditManager.refresh(function():void
			{
				confirmBox = new LootPopupConfirmMessage();
				var cost:int = int(g.me.hasSupporter() ? 0 : 20);
				g.rpc("getTotalUpgradeCost",function(param1:Message):void
				{
					var _loc3_:int = 0;
					var _loc5_:String = null;
					var _loc2_:int = 0;
					var _loc4_:LootItem = null;
					var _loc6_:int = param1.length;
					confirmBox.text = "Are you sure you want to <FONT COLOR=\'#aa8822\'>reset</FONT> all upgrades for <FONT COLOR=\'#aa8822\'>" + cost + " flux</FONT>? The entire resource cost for this ship will be refunded." + "\n\nYou have: <FONT COLOR=\'#aa8822\'>" + CreditManager.FLUX + " flux</FONT>\n\nYou will get back:\n\n";
					_loc3_ = 0;
					while(_loc3_ < _loc6_)
					{
						_loc5_ = param1.getString(_loc3_);
						_loc2_ = param1.getInt(_loc3_ + 1);
						_loc4_ = new LootItem("Commodities",_loc5_,_loc2_);
						if(_loc4_.name == "Flux")
						{
							fluxReset = _loc2_;
						}
						confirmBox.addItem(_loc4_);
						_loc3_ += 2;
					}
					if(me.freeResets > 0)
					{
						confirmBox.text = "Are you sure you want to <FONT COLOR=\'#aa8822\'> reset </FONT> all upgrades? You have <FONT COLOR=\'#aa8822\'>" + me.freeResets + " free</FONT> reset remaining. The entire resource cost will be refunded." + "\n\nYou have: <FONT COLOR=\'#aa8822\'>" + CreditManager.FLUX + " flux</FONT>\n\nYou will get back:\n\n";
						confirmBox.confirmButton.enabled = true;
					}
					else if(cost > CreditManager.FLUX)
					{
						confirmBox.confirmButton.enabled = false;
					}
					g.addChildToOverlay(confirmBox,true);
					confirmBox.addEventListener("accept",onAcceptReset);
					confirmBox.addEventListener("close",onCloseReset);
				});
			});
		}
		
		public function resetTechSkills(m:Message) : void
		{
			var t:TechSkill;
			var tb:TechBar;
			if(m.getBoolean(0))
			{
				g.creditManager.refresh();
				g.me.nrOfUpgrades = Vector.<int>([0,0,0,0,0,0,0]);
				_nrOfUpgrades = g.me.nrOfUpgrades;
				if(g.me.freeResets <= 0)
				{
					Game.trackEvent("used flux","bought reset","level " + g.me.level,20);
				}
				else
				{
					g.me.freeResets -= 1;
				}
				for each(t in g.me.techSkills)
				{
					t.level = Player.getSkinTechLevel(t.tech,g.me.activeSkin);
					t.activeEliteTech = "";
					t.activeEliteTechLevel = 0;
					t.eliteTechs = new Vector.<EliteTechSkill>();
				}
				for each(tb in techBars)
				{
					tb.reset();
				}
				myCargo.reloadCargoFromServer(function():void
				{
					upgradeInfo.visible = false;
					enableTouch();
					resetButton.enabled = false;
				});
				switchEliteTechButton.visible = false;
				buyWithFluxButton.visible = false;
				buyWithResourcesButton.visible = false;
				if(fluxReset > 0)
				{
					Game.trackEvent("used flux","bought elite upgrade","reset",-fluxReset);
					trace("tracked flux reset: " + -fluxReset);
				}
				g.showErrorDialog("Reset complete! All resources spent on this ship has been refunded. You will now take off from the upgrade station.",false,function():void
				{
					g.me.leaveBody();
				});
			}
			else
			{
				enableTouch();
				g.showErrorDialog(m.getString(1));
			}
		}
		
		private function sendResetRequest() : void
		{
			g.rpc("resetUpgrades",resetTechSkills);
		}
		
		private function onAcceptReset(e:Event) : void
		{
			disableTouch();
			sendResetRequest();
			resetButton.enabled = false;
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
		}
		
		private function onCloseReset(e:Event) : void
		{
			g.removeChildFromOverlay(confirmBox,true);
			resetButton.enabled = true;
			confirmBox.removeEventListeners();
		}
		
		private function cheat(e:TouchEvent) : void
		{
			var _loc2_:Message = null;
			disableTouch();
			cheatButton.enabled = false;
			cheatButton.visible = false;
			if(eliteTechSelectedForUpgrade != null)
			{
				_loc2_ = g.createMessage("cheatUpgrade");
				_loc2_.add(eliteTechSelectedForUpgrade.table);
				_loc2_.add(eliteTechSelectedForUpgrade.tech);
				_loc2_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
				_loc2_.add(100);
				g.rpcMessage(_loc2_,upgradedEliteTech);
			}
		}
		
		private function buyUpgrade(e:TouchEvent) : void
		{
			var _loc3_:Message = null;
			var _loc2_:int = 0;
			disableTouch();
			buyWithResourcesButton.enabled = false;
			buyWithFluxButton.enabled = false;
			if(techSelectedForUpgrade != null)
			{
				_loc3_ = g.createMessage("upgrade");
				_loc3_.add(techSelectedForUpgrade.table);
				_loc3_.add(techSelectedForUpgrade.tech);
				_loc3_.add(techSelectedForUpgrade.level);
				Game.trackEvent("upgrades","Techs",techSelectedForUpgrade.name + " " + techSelectedForUpgrade.level,g.me.level);
				g.rpcMessage(_loc3_,upgraded);
			}
			else if(eliteTechSelectedForUpgrade != null)
			{
				_loc3_ = g.createMessage("upgradeEliteTech");
				_loc3_.add(eliteTechSelectedForUpgrade.table);
				_loc3_.add(eliteTechSelectedForUpgrade.tech);
				_loc3_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
				_loc3_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTechLevel + 1);
				_loc2_ = eliteSlider.value;
				autoUpdateEliteUpgradeStartValue = _loc2_;
				_loc3_.add(_loc2_);
				Game.trackEvent("upgrades","EliteTechs",eliteTechSelectedForUpgrade.name + " " + eliteTechSelectedForUpgrade.level + " to " + _loc2_,g.me.level);
				g.rpcMessage(_loc3_,upgradedEliteTech);
			}
		}
		
		private function buyUpgradeWithFlux(e:TouchEvent) : void
		{
			disableTouch();
			buyWithResourcesButton.enabled = false;
			buyWithFluxButton.enabled = false;
			var _loc2_:Message = g.createMessage("buyUpgradeWithFlux");
			_loc2_.add(techSelectedForUpgrade.table);
			_loc2_.add(techSelectedForUpgrade.tech);
			_loc2_.add(techSelectedForUpgrade.level);
			g.rpcMessage(_loc2_,upgraded);
		}
		
		private function buyEliteUpgradeWithFlux(e:TouchEvent) : void
		{
			isUpgradingEliteTech = true;
			disableTouch();
			buyWithResourcesButton.enabled = false;
			buyWithFluxButton.enabled = false;
			var _loc4_:Message = g.createMessage("buyEliteTechUpgradeWithFlux");
			_loc4_.add(eliteTechSelectedForUpgrade.table);
			_loc4_.add(eliteTechSelectedForUpgrade.tech);
			_loc4_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
			var _loc2_:int = eliteTechSelectedForUpgrade.techSkill.activeEliteTechLevel + 1;
			var _loc3_:* = _loc2_;
			if(eliteSlider.value == 100)
			{
				_loc3_ = 100;
			}
			_loc4_.add(_loc2_);
			_loc4_.add(_loc3_);
			g.rpcMessage(_loc4_,upgradedEliteTech);
		}
		
		private function upgradedEliteTech(m:Message) : void
		{
			if(m.getBoolean(0))
			{
				Console.write("Upgrade successful!");
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
				g.creditManager.refresh();
				myCargo.reloadCargoFromServer(function():void
				{
					var tech:String;
					var eliteTech:String;
					var level:int;
					var eti:EliteTechIcon;
					var ts:TechSkill;
					var tween:TweenMax;
					upgradeInfo.visible = false;
					disableTouch();
					tech = m.getString(1);
					eliteTech = m.getString(2);
					level = m.getInt(3);
					eti = eliteTechSelectedForUpgrade;
					if(eliteTechSelectedForUpgrade.tech == tech)
					{
						ts = eliteTechSelectedForUpgrade.techSkill;
						ts.activeEliteTech = eliteTech;
						ts.activeEliteTechLevel = level;
						eliteTechSelectedForUpgrade.level = level;
						ts.addEliteTechData(eliteTech,level);
						eliteTechSelectedForUpgrade.update(level);
					}
					tween = TweenMax.from(eti,1,{
						"scaleX":3,
						"scaleY":3,
						"rotation":3.141592653589793 * 8,
						"delay":0.1,
						"onComplete":function():void
						{
							eti.update(level);
							if(autoUpdateEliteUpgradeStartValue == level)
							{
								isUpgradingEliteTech = false;
								updateEliteTechUpgradeInfo(eti);
								eliteTechSelectedForUpgrade = eti;
								if(level != 100)
								{
									buyWithFluxButton.enabled = true;
									buyWithResourcesButton.enabled = true;
									buyWithFluxButton.visible = true;
									buyWithResourcesButton.visible = true;
									switchEliteTechButton.visible = true;
								}
								enableTouch();
								updateEliteUpgradeLevels();
								updateUpgradeInfo();
								if(eliteSlider.minimum < 100)
								{
									eliteSlider.value = eliteSlider.minimum;
								}
							}
							else if(autoUpdateEliteUpgradeStartValue > level)
							{
								eliteTechSelectedForUpgrade = eti;
								buyEliteUpgradeWithFlux(null);
								hideEliteSlider();
								return;
							}
						}
					});
				});
			}
			else
			{
				if(m.length > 1)
				{
					g.showErrorDialog(m.getString(1));
				}
				enableTouch();
			}
		}
		
		private function upgraded(m:Message) : void
		{
			if(m.getBoolean(0))
			{
				Console.write("Upgrade successful!");
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
				g.creditManager.refresh();
				_nrOfUpgrades[0]++;
				_nrOfUpgrades[techSelectedForUpgrade.level]++;
				myCargo.reloadCargoFromServer(function():void
				{
					var tween:TweenMax;
					upgradeInfo.visible = false;
					tween = TweenMax.from(techSelectedForUpgrade,1,{
						"scaleX":3,
						"scaleY":3,
						"rotation":3.141592653589793 * 8,
						"delay":0.1,
						"onComplete":function():void
						{
							techSelectedForUpgrade.upgrade();
							techSelectedForUpgrade = null;
							enableTouch();
						}
					});
				});
			}
			else
			{
				if(m.length > 1)
				{
					g.showErrorDialog(m.getString(1));
				}
				enableTouch();
				techSelectedForUpgrade = null;
			}
			if(g.me.nrOfUpgrades[0] == 0)
			{
				resetButton.enabled = false;
			}
			buyWithFluxButton.enabled = true;
			buyWithResourcesButton.enabled = true;
			buyWithResourcesButton.visible = false;
			buyWithFluxButton.visible = false;
			if(!isUpgradingEliteTech)
			{
				resetButton.visible = true;
			}
		}
		
		public function exit() : void
		{
			autoUpdateEliteUpgradeStartValue = 0;
			dispose();
		}
		
		override public function dispose() : void
		{
			for each(var _loc1_ in techBars)
			{
				_loc1_.dispose();
			}
			isUpgradingEliteTech = false;
			autoUpdateEliteUpgradeStartValue = 0;
			techBars = null;
			removeEventListeners();
		}
		
		private function disableTouch() : void
		{
			hideEliteSlider();
			for each(var _loc1_ in techBars)
			{
				_loc1_.touchable = false;
			}
			resetButton.enabled = false;
			switchEliteTechButton.enabled = false;
		}
		
		private function enableTouch() : void
		{
			for each(var _loc1_ in techBars)
			{
				_loc1_.touchable = true;
			}
			resetButton.enabled = true;
			switchEliteTechButton.enabled = true;
		}
		
		private function canAfford(tli:TechLevelIcon) : Boolean
		{
			return canAffordMineralType1(tli) && canAffordMineralType2(tli);
		}
		
		private function canAffordET(eti:EliteTechIcon) : Boolean
		{
			return canAffordETMineralType1(eti) && canAffordETMineralType2(eti);
		}
		
		private function canAffordETMineralType1(eti:EliteTechIcon) : Boolean
		{
			return myCargo.hasMinerals(eti.mineralType1,EliteTechs.getResource1Cost(eti.level + 1));
		}
		
		private function canAffordETMineralType2(eti:EliteTechIcon) : Boolean
		{
			eti.updateMineralType2();
			return myCargo.hasMinerals(eti.mineralType2,EliteTechs.getResource2Cost(eti.level + 1));
		}
		
		private function canAffordMineralType1(tli:TechLevelIcon) : Boolean
		{
			return myCargo.hasMinerals(tli.mineralType1,getMineralType1Cost(tli.level,tli.playerLevel));
		}
		
		private function canAffordMineralType2(tli:TechLevelIcon) : Boolean
		{
			if(tli.mineralType2 == null)
			{
				return true;
			}
			return myCargo.hasMinerals(tli.mineralType2,getMineralType2Cost(tli.level));
		}
		
		private function getMineralType1Cost(upgradeLevel:int, playerUpgradeLevel:int) : Number
		{
			return 400 * nrOfUpgrades[0] + Math.pow(4 * nrOfUpgrades[0],2) + 200 * Math.pow(2,upgradeLevel);
		}
		
		private function getMineralType2Cost(upgradeLevel:int) : int
		{
			return 160 + nrOfUpgrades[upgradeLevel] * 520 + upgradeLevel * 40;
		}
	}
}

