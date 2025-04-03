package core.artifact
{
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBoxNew;
	import core.hud.components.InputText;
	import core.hud.components.LootItem;
	import core.hud.components.PriceCommodities;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.dialogs.LootPopupMessage;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.ShopState;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ToggleButton;
	import generics.Localize;
	import generics.Util;
	import playerio.DatabaseObject;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactOverview extends Sprite
	{
		private static var artifactsLoaded:Boolean;
		
		private static var textureManager:ITextureManager;
		
		private static const MAX_RECYCLE:int = 40;
		
		private var g:Game;
		
		private var p:Player;
		
		private var activeSlots:Vector.<ArtifactBox> = new Vector.<ArtifactBox>();
		
		private var cargoBoxes:Vector.<ArtifactCargoBox> = new Vector.<ArtifactCargoBox>();
		
		private var statisticSummary:TextField;
		
		private var recycleMode:Boolean;
		
		private var upgradeMode:Boolean;
		
		private var statsContainer:ScrollContainer;
		
		private var toggleRecycleButton:Button;
		
		private var toggleUpgradeButton:Button;
		
		private var upgradeButton:Button;
		
		private var cancelUpgradeButton:Button;
		
		private var chooseSortingButton:Button;
		
		private var selectAllRecycleButton:Button;
		
		private var recycleButton:Button;
		
		private var cancelRecycleButton:Button;
		
		private var recycleText:TextField;
		
		private var recycleTextInfo:TextField;
		
		private var autoRecycleButton:Button;
		
		private var buySupporter:Button;
		
		private var autoRecycleInput:InputText;
		
		private var autoRecycleText:TextField;
		
		private var autoRecycleTextInfo:TextField;
		
		private var markedForRecycle:Vector.<Artifact> = new Vector.<Artifact>();
		
		private var setups:Array = [];
		
		private var cargoContainer:ScrollContainer;
		
		private const artifactSetupButtonHeight:int = 24;
		
		private const artifactSetupY:int = 70;
		
		private var crewContainer:Sprite;
		
		private var labelSelectCrew:TextBitmap;
		
		private var loadingText:TextField;
		
		private var selectedUpgradeBox:ArtifactCargoBox;
		
		private var selectedCrewMember:CrewDisplayBoxNew;
		
		public function ArtifactOverview(g:Game)
		{
			super();
			this.g = g;
			this.p = g.me;
			addEventListener("artifactSelected",onSelect);
			addEventListener("artifactRecycleSelected",onRecycleSelect);
			addEventListener("artifactUpgradeSelected",onUpgradeSelect);
			addEventListener("artifactSlotUnlock",onUnlock);
			addEventListener("activeArtifactRemoved",onActiveRemoved);
			addEventListener("crewSelected",onCrewSelected);
			addEventListener("upgradeArtifactComplete",onUpgradeArtifactComplete);
		}
		
		public function load() : void
		{
			if(artifactsLoaded)
			{
				Starling.juggler.delayCall(drawComponents,0.1);
				return;
			}
			textureManager = TextureLocator.getService();
			loadingText = new TextField(400,100,Localize.t("Loading data..."),new TextFormat("DAIDRR",30,0xffffff));
			loadingText.x = 380 - loadingText.width / 2 - 55;
			loadingText.y = 5 * 60 - loadingText.height / 2 - 50;
			addChild(loadingText);
			TweenMax.fromTo(loadingText,1,{"alpha":1},{
				"alpha":0.5,
				"yoyo":true,
				"repeat":15
			});
			g.dataManager.loadRangeFromBigDB("Artifacts","ByPlayer",[p.id],function(param1:Array):void
			{
				var message:Message;
				var obj:DatabaseObject;
				var artifact:Artifact;
				var a:Artifact;
				var i:int;
				var cm:CrewMember;
				var array:Array = param1;
				if(array.length >= p.artifactLimit)
				{
					g.hud.showArtifactLimitText();
					g.tutorial.showArtifactLimitAdvice();
				}
				p.artifactCount = array.length;
				g.send("artifactCount",array.length);
				message = new Message("validateUniqueArts");
				for each(obj in array)
				{
					if(obj != null)
					{
						artifact = new Artifact(obj);
						if(artifact.isUnique)
						{
							message.add(artifact.id);
						}
						a = p.getArtifactById(artifact.id);
						i = 0;
						while(i < p.crewMembers.length)
						{
							cm = p.crewMembers[i];
							if(cm.artifact == artifact.id)
							{
								if(a != null)
								{
									a.upgrading = true;
								}
								else
								{
									artifact.upgrading = true;
								}
							}
							i++;
						}
						if(a == null)
						{
							p.artifacts.push(artifact);
						}
					}
				}
				if(message.length == 0)
				{
					loadComplate();
					return;
				}
				g.rpcMessage(message,function(param1:Message):void
				{
					if(param1.getBoolean(0))
					{
						loadComplate();
					}
					else
					{
						updateInvalidUniqueArts(param1);
					}
				});
			},1000);
		}
		
		private function updateInvalidUniqueArts(m:Message) : void
		{
			var keys:Array = [];
			var i:int = 1;
			while(i < m.length)
			{
				keys.push(m.getString(i));
				i++;
			}
			g.dataManager.loadKeysFromBigDB("Artifacts",keys,function(param1:Array):void
			{
				var _loc2_:Artifact = null;
				for each(var _loc3_ in param1)
				{
					if(_loc3_ != null)
					{
						_loc2_ = g.me.getArtifactById(_loc3_.key);
						if(g.me.isActiveArtifact(_loc2_))
						{
							g.me.removeArtifactStat(_loc2_,false);
							_loc2_.update(_loc3_);
							g.me.addArtifactStat(_loc2_,false);
						}
						else
						{
							_loc2_.update(_loc3_);
						}
					}
				}
				loadComplate();
			});
		}
		
		private function loadComplate() : void
		{
			artifactsLoaded = true;
			removeChild(loadingText);
			drawComponents();
		}
		
		public function drawComponents() : void
		{
			var q:Quad;
			var labelArtifactStats:TextBitmap;
			var crewMembersThatCompletedUpgrade:Vector.<CrewMember>;
			var i:int;
			var cm:CrewMember;
			var cmBox:CrewDisplayBoxNew;
			initActiveSlots();
			setActiveArtifacts();
			drawArtifactSetups();
			q = new Quad(650,1,0xaaaaaa);
			q.y = 70 + 24 - 1;
			addChildAt(q,0);
			drawArtifactsInCargo();
			statsContainer = new ScrollContainer();
			statsContainer.x = 390;
			statsContainer.y = 100;
			statsContainer.height = 365;
			statsContainer.width = 270;
			statsContainer.clipContent = true;
			addChild(statsContainer);
			labelArtifactStats = new TextBitmap(0,0,Localize.t("Artifact Stats"),16);
			labelArtifactStats.format.color = 0xffffcf;
			statsContainer.addChild(labelArtifactStats);
			statisticSummary = new TextField(250,560,"");
			statisticSummary.isHtmlText = true;
			statisticSummary.format.horizontalAlign = "left";
			statisticSummary.format.verticalAlign = "top";
			statisticSummary.format.color = 0xd3d3d3;
			statisticSummary.format.font = "Verdana";
			statisticSummary.format.size = 12;
			statisticSummary.autoSize = "vertical";
			statisticSummary.y = 30;
			statsContainer.addChild(statisticSummary);
			reloadStats();
			toggleRecycleButton = new Button(toggleRecycle,Localize.t("Recycle"));
			toggleRecycleButton.x = 97;
			toggleRecycleButton.y = 8 * 60;
			addChild(toggleRecycleButton);
			toggleUpgradeButton = new Button(toggleUpgrade,Localize.t("Upgrade"));
			toggleUpgradeButton.x = toggleRecycleButton.x + toggleRecycleButton.width + 10;
			toggleUpgradeButton.y = 8 * 60;
			addChild(toggleUpgradeButton);
			cancelUpgradeButton = new Button(toggleUpgrade,Localize.t("Cancel"));
			cancelUpgradeButton.x = 140;
			cancelUpgradeButton.y = 8 * 60;
			cancelUpgradeButton.visible = false;
			addChild(cancelUpgradeButton);
			upgradeButton = new Button(onUpgradeArtifact,Localize.t("Upgrade"),"positive");
			upgradeButton.x = cancelUpgradeButton.x + cancelUpgradeButton.width + 30;
			upgradeButton.y = 8 * 60;
			upgradeButton.visible = false;
			upgradeButton.enabled = false;
			addChild(upgradeButton);
			crewContainer = new Sprite();
			crewContainer.x = 390;
			crewContainer.y = 100;
			crewContainer.visible = false;
			addChild(crewContainer);
			labelSelectCrew = new TextBitmap();
			labelSelectCrew.text = Localize.t("Select artifact and crew");
			labelSelectCrew.size = 18;
			crewContainer.addChild(labelSelectCrew);
			crewMembersThatCompletedUpgrade = new Vector.<CrewMember>();
			i = 0;
			while(i < p.crewMembers.length)
			{
				cm = p.crewMembers[i];
				cmBox = new CrewDisplayBoxNew(g,cm,2);
				if(cm.isUpgradeComplete)
				{
					crewMembersThatCompletedUpgrade.push(cm);
				}
				cmBox.y = 30 + i * (60);
				crewContainer.addChild(cmBox);
				i++;
			}
			onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade);
			chooseSortingButton = new Button(chooseSorting,Localize.t("Sorting"));
			chooseSortingButton.x = 0;
			chooseSortingButton.y = 8 * 60;
			addChild(chooseSortingButton);
			cancelRecycleButton = new Button(toggleRecycle,Localize.t("Cancel"));
			cancelRecycleButton.x = 140;
			cancelRecycleButton.y = 8 * 60;
			cancelRecycleButton.visible = false;
			addChild(cancelRecycleButton);
			recycleButton = new Button(onRecycle,Localize.t("Recycle"),"positive");
			recycleButton.x = cancelRecycleButton.x + cancelRecycleButton.width + 30;
			recycleButton.y = 8 * 60;
			recycleButton.visible = false;
			addChild(recycleButton);
			selectAllRecycleButton = new Button(selectAllForRecycle,Localize.t("Select Max"));
			selectAllRecycleButton.x = cancelRecycleButton.x - selectAllRecycleButton.width - 10;
			selectAllRecycleButton.y = 8 * 60;
			selectAllRecycleButton.visible = false;
			addChild(selectAllRecycleButton);
			recycleText = new TextField(200,10,"",new TextFormat("DAIDRR",13,Style.COLOR_HIGHLIGHT,"left"));
			recycleText.autoSize = "vertical";
			recycleText.text = Localize.t("Recycle");
			recycleText.visible = false;
			recycleText.x = 380;
			recycleText.y = 100;
			addChild(recycleText);
			recycleTextInfo = new TextField(200,10,"",new TextFormat("Verdana",13,0xffffff,"left"));
			recycleTextInfo.autoSize = "vertical";
			recycleTextInfo.text = Localize.t("Select those artifacts you want to recycle. A recycled artifact will turn into junk that can be further recycled into minerals at the nearest recycle station.");
			recycleTextInfo.visible = false;
			recycleTextInfo.y = recycleText.y + recycleText.height + 2;
			recycleTextInfo.x = recycleText.x;
			addChild(recycleTextInfo);
			autoRecycleText = new TextField(4 * 60,10,"",new TextFormat("DAIDRR",13,Style.COLOR_HIGHLIGHT,"left"));
			autoRecycleText.isHtmlText = true;
			autoRecycleText.autoSize = "vertical";
			autoRecycleText.text = Localize.t("Auto Recycle <FONT COLOR=\'#666666\'>(Supporter Only!)</FONT>");
			autoRecycleText.visible = false;
			autoRecycleText.y = recycleTextInfo.y + recycleTextInfo.height + 10;
			autoRecycleText.x = recycleText.x;
			addChild(autoRecycleText);
			autoRecycleTextInfo = new TextField(200,10,"",new TextFormat("Verdana",13,Style.COLOR_HIGHLIGHT,"left"));
			autoRecycleTextInfo.autoSize = "vertical";
			autoRecycleTextInfo.text = Localize.t("Artifacts below a specified\x03 potential level will be auto-recycled when you pickup drops.");
			autoRecycleTextInfo.visible = false;
			autoRecycleTextInfo.y = autoRecycleText.y + autoRecycleText.height + 2;
			autoRecycleTextInfo.x = recycleText.x;
			addChild(autoRecycleTextInfo);
			buySupporter = new Button(function():void
			{
				if(g.me.isLanded)
				{
					g.me.leaveBody();
				}
				else
				{
					g.enterState(new RoamingState(g));
					g.enterState(new ShopState(g,"supporterPackage"));
				}
			},Localize.t("Buy Supporter"),"buy");
			buySupporter.y = autoRecycleTextInfo.y + autoRecycleTextInfo.height + 10;
			buySupporter.x = recycleText.x;
			buySupporter.visible = false;
			addChild(buySupporter);
			autoRecycleButton = new Button(onAutoRecycle,Localize.t("Set Level"),"positive");
			autoRecycleButton.x = recycleText.x;
			autoRecycleButton.enabled = g.me.hasSupporter();
			autoRecycleButton.visible = false;
			addChild(autoRecycleButton);
			if(g.me.hasSupporter())
			{
				autoRecycleButton.y = autoRecycleTextInfo.y + autoRecycleTextInfo.height + 10;
			}
			else
			{
				autoRecycleButton.y = buySupporter.y + buySupporter.height + 10;
			}
			autoRecycleInput = new InputText(autoRecycleButton.x + autoRecycleButton.width + 5,autoRecycleButton.y,40,25);
			autoRecycleInput.text = g.me.artifactAutoRecycleLevel.toString();
			autoRecycleInput.restrict = "0-9";
			autoRecycleInput.maxChars = 3;
			autoRecycleInput.isEnabled = g.me.hasSupporter();
			autoRecycleInput.visible = false;
			addChild(autoRecycleInput);
		}
		
		private function initActiveSlots() : void
		{
			var _loc2_:ArtifactBox = null;
			var _loc1_:int = 0;
			while(_loc1_ < 5)
			{
				_loc2_ = new ArtifactBox(g,null);
				if(_loc1_ == p.unlockedArtifactSlots)
				{
					_loc2_.locked = true;
					_loc2_.unlockable = true;
				}
				else if(_loc1_ > p.unlockedArtifactSlots)
				{
					_loc2_.locked = true;
				}
				_loc2_.update();
				_loc2_.x = (_loc2_.width + 15) * _loc1_;
				_loc2_.slot = _loc1_;
				addChild(_loc2_);
				activeSlots.push(_loc2_);
				_loc1_++;
			}
		}
		
		private function setActiveArtifacts() : void
		{
			var _loc1_:Artifact = null;
			var _loc4_:ArtifactBox = null;
			var _loc2_:int = 0;
			for each(var _loc3_ in p.activeArtifacts)
			{
				_loc1_ = p.getArtifactById(_loc3_);
				if(_loc1_ != null)
				{
					_loc4_ = activeSlots[_loc2_++];
					_loc4_.setActive(_loc1_);
					_loc4_.update();
				}
			}
		}
		
		private function drawArtifactSetups() : void
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			var _loc5_:ToggleButton = null;
			for each(var _loc1_ in setups)
			{
				_loc1_.removeEventListeners();
				removeChild(_loc1_);
			}
			setups.length = 0;
			var _loc2_:int = p.artifactSetups.length + 1;
			_loc4_ = 0;
			_loc3_ = 10;
			while(_loc4_ < _loc2_)
			{
				_loc5_ = new ToggleButton();
				_loc5_.styleNameList.add("artifact_setup");
				addChild(_loc5_);
				if(_loc4_ == 0)
				{
					_loc5_.label = Localize.t("Setup") + " 1";
					_loc5_.addEventListener("triggered",onSetupChange);
				}
				else if(_loc4_ == _loc2_ - 1)
				{
					_loc5_.defaultIcon = new Image(textureManager.getTextureGUIByTextureName("setup_buy_button"));
					_loc5_.addEventListener("triggered",onSetupBuy);
				}
				else
				{
					_loc5_.label = (_loc4_ + 1).toString();
					_loc5_.addEventListener("triggered",onSetupChange);
				}
				if(_loc4_ == p.activeArtifactSetup)
				{
					_loc5_.isSelected = true;
				}
				_loc5_.x = _loc3_;
				_loc5_.y = 70;
				_loc5_.height = 24;
				_loc5_.useHandCursor = true;
				_loc5_.validate();
				_loc3_ += _loc5_.width - 1;
				setups.push(_loc5_);
				_loc4_++;
			}
		}
		
		private function drawArtifactsInCargo() : void
		{
			var _loc6_:int = 0;
			var _loc5_:int = 0;
			var _loc1_:Artifact = null;
			var _loc3_:ArtifactCargoBox = null;
			var _loc7_:Button = null;
			var _loc2_:TextBitmap = null;
			if(cargoContainer == null)
			{
				cargoContainer = new ScrollContainer();
				cargoContainer.y = 105;
				cargoContainer.height = 365;
				cargoContainer.width = 375;
				addChild(cargoContainer);
			}
			var _loc4_:int = 0;
			var _loc8_:int = p.artifacts.length > 100 ? Math.floor(p.artifacts.length / 10) + 1 : 10;
			_loc6_ = 0;
			while(_loc6_ < _loc8_)
			{
				_loc5_ = 0;
				while(_loc5_ < 10)
				{
					_loc1_ = _loc4_ < p.artifacts.length ? p.artifacts[_loc4_] : null;
					_loc3_ = new ArtifactCargoBox(g,_loc1_);
					_loc3_.x = 36 * _loc5_;
					_loc3_.y = (_loc3_.height + 8) * _loc6_;
					cargoContainer.addChild(_loc3_);
					cargoBoxes.push(_loc3_);
					_loc4_++;
					_loc5_++;
				}
				_loc6_++;
			}
			if(p.artifactCapacityLevel < Player.ARTIFACT_CAPACITY.length - 1)
			{
				_loc7_ = new Button(onUpgradeCapacity,p.artifactCount + " / " + p.artifactLimit + " " + Localize.t("INCREASE to") + " " + Player.ARTIFACT_CAPACITY[p.artifactCapacityLevel + 1],"positive");
				_loc7_.x = 0;
				_loc7_.width = 340;
				_loc7_.y = (_loc3_.height + 8) * _loc6_;
				cargoContainer.addChild(_loc7_);
			}
			else
			{
				_loc2_ = new TextBitmap();
				_loc2_.x = 0;
				_loc2_.y = (_loc3_.height + 8) * _loc6_;
				_loc2_.text = p.artifactCount + " / " + p.artifactLimit;
				cargoContainer.addChild(_loc2_);
			}
		}
		
		private function onSelect(e:Event) : void
		{
			var _loc5_:* = null;
			var _loc2_:Artifact = null;
			var _loc4_:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _loc3_:Artifact = _loc4_.a;
			var _loc7_:Boolean = p.isActiveArtifact(_loc3_);
			if(_loc7_)
			{
				p.toggleArtifact(_loc3_);
				for each(_loc5_ in activeSlots)
				{
					if(_loc5_.a == _loc3_)
					{
						_loc5_.setEmpty();
						break;
					}
				}
				_loc4_.update();
				reloadStats();
				return;
			}
			if(p.nrOfActiveArtifacts() >= p.unlockedArtifactSlots)
			{
				return;
			}
			for each(var _loc6_ in p.activeArtifacts)
			{
				_loc2_ = p.getArtifactById(_loc6_);
				if(_loc2_.isUnique && _loc3_.isUnique && _loc2_.name == _loc3_.name)
				{
					g.showMessageDialog(Localize.t("You can\'t equip the same unique artifact twice."));
					return;
				}
			}
			for each(_loc5_ in activeSlots)
			{
				if(_loc5_.isEmpty)
				{
					if(!_loc5_.locked)
					{
						_loc5_.setActive(_loc3_);
						p.toggleArtifact(_loc3_);
						_loc4_.update();
						reloadStats();
						break;
					}
				}
			}
		}
		
		private function onRecycleSelect(e:Event) : void
		{
			var _loc5_:int = 0;
			var _loc2_:Artifact = null;
			var _loc4_:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _loc3_:Artifact = _loc4_.a;
			_loc5_ = 0;
			while(_loc5_ < markedForRecycle.length)
			{
				_loc2_ = markedForRecycle[_loc5_];
				if(_loc2_ == _loc3_)
				{
					markedForRecycle.splice(_loc5_,1);
					return;
				}
				_loc5_++;
			}
			if(markedForRecycle.length >= 40)
			{
				_loc4_.setNotSelected();
				g.showMessageDialog(Localize.t("You can\'t select more than 40 artifacts to recycle."));
				return;
			}
			markedForRecycle.push(_loc3_);
		}
		
		private function onAutoRecycle(e:Event) : void
		{
			autoRecycleButton.enabled = true;
			var _loc2_:int = int(autoRecycleInput.text);
			g.me.artifactAutoRecycleLevel = _loc2_;
			g.send("setAutoRecycle",_loc2_);
			g.showMessageDialog("Auto recycle level has been set to: <font color=\'#FFFF88\'>" + _loc2_ + "</font>");
		}
		
		private function onUpgradeSelect(e:Event) : void
		{
			var _loc3_:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _loc2_:Artifact = _loc3_.a;
			if(selectedUpgradeBox != null && selectedUpgradeBox != _loc3_)
			{
				selectedUpgradeBox.setNotSelected();
			}
			if(selectedUpgradeBox == _loc3_)
			{
				upgradeButton.enabled = false;
				selectedUpgradeBox = null;
				return;
			}
			if(selectedCrewMember != null)
			{
				upgradeButton.enabled = true;
			}
			selectedUpgradeBox = _loc3_;
		}
		
		private function onUnlock(e:Event) : void
		{
			var box:ArtifactBox = e.target as ArtifactBox;
			var unlockCost:int = int(Player.SLOT_ARTIFACT_UNLOCK_COST[box.slot]);
			var number:int = box.slot + 1;
			var fluxCost:int = CreditManager.getCostArtifactSlot(number);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = Localize.t("Artifact Slot");
			buyBox.addCost(new PriceCommodities(g,"flpbTKautkC1QzjWT28gkw",unlockCost));
			buyBox.addBuyForFluxButton(fluxCost,number,"buyArtifactSlotWithFlux",Localize.t("Are you sure you want to buy an artifact slot?"));
			buyBox.addEventListener("fluxBuy",function(param1:Event):void
			{
				p.unlockedArtifactSlots = number;
				g.removeChildFromOverlay(buyBox,true);
				onSlotUnlock(box);
				Game.trackEvent("used flux","bought artifact slot","number " + number,fluxCost);
			});
			buyBox.addEventListener("accept",function(param1:Event):void
			{
				var e:Event = param1;
				g.me.tryUnlockSlot("slotArtifact",box.slot + 1,function():void
				{
					g.removeChildFromOverlay(buyBox,true);
					onSlotUnlock(box);
				});
			});
			buyBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(buyBox,true);
			});
			g.addChildToOverlay(buyBox);
		}
		
		private function onUpgradeCapacity(e:Event) : void
		{
			var cost:int = CreditManager.getCostArtifactCapacityUpgrade(p.artifactCapacityLevel + 1);
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,cost,Localize.t("Increases artifact capacity to") + " " + Player.ARTIFACT_CAPACITY[p.artifactCapacityLevel + 1]);
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox,true);
				g.rpc("upgradeArtifactCapacity",onBuyArtifactConfirm);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox,true);
			});
		}
		
		private function onBuyArtifactConfirm(m:Message) : void
		{
			var _loc2_:Boolean = m.getBoolean(0);
			if(!_loc2_)
			{
				g.showErrorDialog(m.getString(1));
				return;
			}
			g.showErrorDialog(Localize.t("Success!"));
			p.artifactCapacityLevel += 1;
			drawArtifactsInCargo();
			g.creditManager.refresh();
		}
		
		private function onSlotUnlock(box:ArtifactBox) : void
		{
			box.locked = false;
			box.unlockable = false;
			box.update();
			var _loc2_:int = box.slot + 1;
			if(_loc2_ < activeSlots.length)
			{
				activeSlots[_loc2_].unlockable = true;
				activeSlots[_loc2_].update();
			}
		}
		
		private function onSetupChange(e:Event) : void
		{
			if(!g.me.isLanded && !g.me.inSafeZone)
			{
				g.showErrorDialog(Localize.t("Artifacts can only be changed inside the safe zones."));
				return;
			}
			if(recycleMode)
			{
				g.showErrorDialog(Localize.t("Artifact setup can\'t be changed while recycling."));
				return;
			}
			var _loc6_:ToggleButton = e.target as ToggleButton;
			for each(var _loc2_ in setups)
			{
				if(_loc2_ != _loc6_)
				{
					_loc2_.isSelected = false;
				}
			}
			var _loc4_:int = int(setups.indexOf(_loc6_));
			if(_loc4_ == p.activeArtifactSetup)
			{
				_loc6_.isSelected = false;
				return;
			}
			if(recycleMode)
			{
				toggleRecycle();
			}
			g.send("changeArtifactSetup",_loc4_);
			p.changeArtifactSetup(_loc4_);
			for each(var _loc5_ in activeSlots)
			{
				_loc5_.setEmpty();
			}
			setActiveArtifacts();
			for each(var _loc3_ in cargoBoxes)
			{
				_loc3_.updateSetupChange();
			}
			reloadStats();
		}
		
		private function onSetupBuy(e:Event) : void
		{
			var button:ToggleButton;
			var cost:int = CreditManager.getCostArtifactSetup();
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,cost,Localize.t("Unlocks one more artifact setup."));
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox,true);
				g.rpc("buyArtifactSetup",onSetupBuyConfirm);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox,true);
			});
			button = e.target as ToggleButton;
			button.isSelected = true;
		}
		
		private function onSetupBuyConfirm(m:Message) : void
		{
			var _loc2_:Boolean = m.getBoolean(0);
			if(!_loc2_)
			{
				g.showErrorDialog(m.getString(1));
				return;
			}
			g.showErrorDialog(Localize.t("Success!"));
			p.artifactSetups.push([]);
			g.creditManager.refresh();
			drawArtifactSetups();
		}
		
		private function reloadStats(e:Event = null) : void
		{
			reloadArtifactStats();
			reloadShipStats();
		}
		
		private function reloadArtifactStats() : void
		{
			if(p.artifacts.length == 0)
			{
				statisticSummary.text = Localize.t("You do not have any artifacts.");
				return;
			}
			if(p.activeArtifacts.length == 0)
			{
				statisticSummary.text = "";
				return;
			}
			var _loc1_:Object = sortStatsForSummary();
			addStatsToSummary(_loc1_);
		}
		
		private function sortStatsForSummary() : Object
		{
			var _loc2_:Artifact = null;
			var _loc5_:String = null;
			var _loc1_:Object = {};
			for each(var _loc4_ in p.activeArtifacts)
			{
				_loc2_ = p.getArtifactById(_loc4_);
				if(_loc2_ != null)
				{
					for each(var _loc3_ in _loc2_.stats)
					{
						_loc5_ = _loc3_.type;
						if(_loc5_.indexOf("2") != -1 || _loc5_.indexOf("3") != -1)
						{
							_loc5_ = _loc5_.slice(0,_loc5_.length - 1);
						}
						if(_loc5_ == "allResist")
						{
							if(!_loc1_.hasOwnProperty("kineticResist"))
							{
								_loc1_["kineticResist"] = 0;
							}
							if(!_loc1_.hasOwnProperty("energyResist"))
							{
								_loc1_["energyResist"] = 0;
							}
							if(!_loc1_.hasOwnProperty("corrosiveResist"))
							{
								_loc1_["corrosiveResist"] = 0;
							}
							var _loc6_:* = "kineticResist";
							var _loc7_:* = _loc1_[_loc6_] + _loc3_.value;
							_loc1_[_loc6_] = _loc7_;
							_loc1_["energyResist"] += _loc3_.value;
							_loc1_["corrosiveResist"] += _loc3_.value;
						}
						else if(_loc5_ == "allAdd")
						{
							if(!_loc1_.hasOwnProperty("kineticAdd"))
							{
								_loc1_["kineticAdd"] = 0;
							}
							if(!_loc1_.hasOwnProperty("energyAdd"))
							{
								_loc1_["energyAdd"] = 0;
							}
							if(!_loc1_.hasOwnProperty("corrosiveAdd"))
							{
								_loc1_["corrosiveAdd"] = 0;
							}
							_loc7_ = "kineticAdd";
							_loc6_ = _loc1_[_loc7_] + _loc3_.value * 4;
							_loc1_[_loc7_] = _loc6_;
							_loc1_["energyAdd"] += _loc3_.value * 4;
							_loc1_["corrosiveAdd"] += _loc3_.value * 4;
						}
						else if(_loc5_ == "allMulti")
						{
							if(!_loc1_.hasOwnProperty("kineticMulti"))
							{
								_loc1_["kineticMulti"] = 0;
							}
							if(!_loc1_.hasOwnProperty("energyMulti"))
							{
								_loc1_["energyMulti"] = 0;
							}
							if(!_loc1_.hasOwnProperty("corrosiveMulti"))
							{
								_loc1_["corrosiveMulti"] = 0;
							}
							_loc6_ = "kineticMulti";
							_loc7_ = _loc1_[_loc6_] + _loc3_.value * 1;
							_loc1_[_loc6_] = _loc7_;
							_loc1_["energyMulti"] += _loc3_.value * 1;
							_loc1_["corrosiveMulti"] += _loc3_.value * 1;
						}
						else
						{
							if(!_loc1_.hasOwnProperty(_loc5_))
							{
								_loc1_[_loc5_] = 0;
							}
							_loc7_ = _loc5_;
							_loc6_ = _loc1_[_loc7_] + _loc3_.value;
							_loc1_[_loc7_] = _loc6_;
						}
					}
				}
			}
			return _loc1_;
		}
		
		private function addStatsToSummary(dataValues:Object) : void
		{
			var _loc10_:Number = NaN;
			var _loc11_:String = "";
			var _loc7_:String = "";
			var _loc2_:String = "";
			var _loc4_:String = "";
			var _loc3_:String = "";
			var _loc6_:String = "";
			var _loc9_:String = "";
			var _loc8_:String = "";
			for(var _loc5_ in dataValues)
			{
				switch(_loc5_)
				{
					case "corrosiveResist":
					case "energyResist":
					case "kineticResist":
						_loc10_ = Number(dataValues[_loc5_]);
						_loc11_ += ArtifactStat.parseTextFromStatType(_loc5_,_loc10_);
						if(_loc10_ > 75)
						{
							_loc11_ += " <FONT COLOR=\'#FFCCAA\'>(75% Max)</FONT>";
						}
						_loc11_ += "<br>";
						break;
					case "healthMulti":
					case "healthAdd":
					case "healthAdd3":
					case "healthAdd2":
					case "healthRegenAdd":
						_loc7_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						break;
					case "shieldMulti":
					case "shieldAdd":
					case "shieldAdd3":
					case "shieldAdd2":
					case "shieldRegen":
						_loc2_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						break;
					case "corrosiveMulti":
					case "corrosiveAdd":
					case "corrosiveAdd3":
					case "corrosiveAdd2":
						_loc4_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						break;
					case "kineticMulti":
					case "kineticAdd":
					case "kineticAdd3":
					case "kineticAdd2":
						_loc6_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						break;
					case "energyMulti":
					case "energyAdd":
					case "energyAdd3":
					case "energyAdd2":
						_loc3_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						break;
					default:
						if(ArtifactStat.isUnique(_loc5_))
						{
							_loc8_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_],ArtifactStat.isUnique(_loc5_)) + "<br>";
						}
						else
						{
							_loc9_ += ArtifactStat.parseTextFromStatType(_loc5_,dataValues[_loc5_]) + "<br>";
						}
				}
				statisticSummary.text = "";
				if(_loc11_ != "")
				{
					statisticSummary.text += _loc11_;
				}
				if(_loc2_ != "")
				{
					statisticSummary.text += _loc2_;
				}
				if(_loc7_ != "")
				{
					statisticSummary.text += _loc7_;
				}
				if(_loc9_ != "")
				{
					statisticSummary.text += _loc9_;
				}
				if(_loc6_ != "")
				{
					statisticSummary.text += _loc6_;
				}
				if(_loc3_ != "")
				{
					statisticSummary.text += _loc3_;
				}
				if(_loc4_ != "")
				{
					statisticSummary.text += _loc4_;
				}
				if(_loc8_ != "")
				{
					statisticSummary.text += _loc8_;
				}
			}
		}
		
		private function reloadShipStats() : void
		{
		}
		
		private function chooseSorting(e:TouchEvent = null) : void
		{
			var _loc2_:ArtifactSorting = new ArtifactSorting(g,onSort);
			_loc2_.x = 0;
			_loc2_.y = 0;
			addChild(_loc2_);
		}
		
		private function toggleRecycle(e:TouchEvent = null) : void
		{
			recycleMode = !recycleMode;
			toggleRecycleButton.visible = !toggleRecycleButton.visible;
			cancelRecycleButton.visible = !cancelRecycleButton.visible;
			selectAllRecycleButton.visible = !selectAllRecycleButton.visible;
			recycleButton.visible = !recycleButton.visible;
			chooseSortingButton.visible = !chooseSortingButton.visible;
			toggleRecycleButton.enabled = toggleRecycleButton.visible;
			cancelRecycleButton.enabled = cancelRecycleButton.visible;
			recycleButton.enabled = recycleButton.visible;
			toggleUpgradeButton.visible = !toggleUpgradeButton.visible;
			statsContainer.visible = !statsContainer.visible;
			recycleText.visible = !recycleText.visible;
			recycleTextInfo.visible = !recycleTextInfo.visible;
			autoRecycleText.visible = !autoRecycleText.visible;
			autoRecycleTextInfo.visible = !autoRecycleTextInfo.visible;
			autoRecycleButton.visible = !autoRecycleButton.visible;
			autoRecycleInput.visible = !autoRecycleInput.visible;
			buySupporter.visible = !buySupporter.visible && !g.me.hasSupporter();
			markedForRecycle.splice(0,markedForRecycle.length);
			for each(var _loc2_ in cargoBoxes)
			{
				if(recycleMode)
				{
					_loc2_.setRecycleState();
				}
				else
				{
					_loc2_.removeRecycleState();
				}
			}
		}
		
		private function toggleUpgrade(e:TouchEvent = null) : void
		{
			upgradeMode = !upgradeMode;
			toggleRecycleButton.visible = !toggleRecycleButton.visible;
			chooseSortingButton.visible = !chooseSortingButton.visible;
			toggleUpgradeButton.visible = !toggleUpgradeButton.visible;
			cancelUpgradeButton.visible = !cancelUpgradeButton.visible;
			upgradeButton.visible = !upgradeButton.visible;
			toggleUpgradeButton.enabled = toggleUpgradeButton.visible;
			cancelUpgradeButton.enabled = cancelUpgradeButton.visible;
			crewContainer.visible = !crewContainer.visible;
			upgradeButton.enabled = false;
			statsContainer.visible = !statsContainer.visible;
			for each(var _loc2_ in cargoBoxes)
			{
				if(upgradeMode)
				{
					_loc2_.setUpgradeState();
				}
				else
				{
					_loc2_.removeUpgradeState();
				}
			}
			if(selectedCrewMember != null)
			{
				selectedCrewMember.setSelected(false);
				selectedCrewMember = null;
			}
			if(selectedUpgradeBox != null)
			{
				selectedUpgradeBox.setNotSelected();
				selectedUpgradeBox = null;
			}
			g.tutorial.showArtifactUpgradeAdvice();
		}
		
		private function selectAllForRecycle(e:TouchEvent = null) : void
		{
			var _loc3_:int = 0;
			markedForRecycle.splice(0,markedForRecycle.length);
			for each(var _loc2_ in cargoBoxes)
			{
				if(_loc2_.a != null)
				{
					if(!_loc2_.isUsedInSetup())
					{
						if(!_loc2_.a.upgrading)
						{
							if(!_loc2_.a.upgrading)
							{
								if(_loc2_.a.upgraded <= 0)
								{
									if(!_loc2_.a.isUnique)
									{
										if(_loc3_ == 40)
										{
											break;
										}
										_loc2_.setSelectedForRecycle();
										markedForRecycle.push(_loc2_.a);
										_loc3_++;
									}
								}
							}
						}
					}
				}
			}
			cargoContainer.scrollToPosition(0,0);
			selectAllRecycleButton.enabled = true;
		}
		
		private function onSort(type:String) : void
		{
			chooseSortingButton.enabled = true;
			Artifact.currentTypeOrder = type;
			if(type == "levelhigh")
			{
				p.artifacts.sort(Artifact.orderLevelHigh);
			}
			else if(type == "levellow")
			{
				p.artifacts.sort(Artifact.orderLevelLow);
			}
			else if(type == "statcountasc")
			{
				p.artifacts.sort(Artifact.orderStatCountAsc);
			}
			else if(type == "statcountdesc")
			{
				p.artifacts.sort(Artifact.orderStatCountDesc);
			}
			else
			{
				p.artifacts.sort(Artifact.orderStat);
			}
			cargoContainer.removeChildren(0,-1,true);
			cargoBoxes.length = 0;
			drawArtifactsInCargo();
		}
		
		private function onRecycle(e:TouchEvent) : void
		{
			if(markedForRecycle.length == 0)
			{
				recycleButton.enabled = true;
				return;
			}
			if(g.myCargo.isFull)
			{
				g.showErrorDialog(Localize.t("Your cargo compressor is overloaded!"));
				return;
			}
			var _loc3_:Message = g.createMessage("bulkRecycle");
			for each(var _loc2_ in markedForRecycle)
			{
				_loc3_.add(_loc2_.id);
			}
			g.rpcMessage(_loc3_,onRecycleMessage);
			g.showModalLoadingScreen("Recycling, please wait... \n\n <font size=\'12\'>This might take a couple of minutes</font>");
		}
		
		private function onRecycleMessage(m:Message) : void
		{
			var success:Boolean;
			var j:int;
			var i:int;
			var reason:String;
			var a:Artifact;
			var cargoBox:ArtifactCargoBox;
			var recycleBox:LootPopupMessage;
			var junk:String;
			var amount:int;
			var lootItem:LootItem;
			g.hideModalLoadingScreen();
			success = m.getBoolean(0);
			j = 0;
			if(!success)
			{
				reason = m.getString(1);
				g.showErrorDialog("Recycle failed, " + reason);
				return;
			}
			i = 0;
			while(i < markedForRecycle.length)
			{
				a = markedForRecycle[i];
				p.artifactCount -= 1;
				for each(cargoBox in cargoBoxes)
				{
					if(cargoBox.a == a)
					{
						cargoBox.setEmpty();
						break;
					}
				}
				j = 0;
				while(j < p.artifacts.length)
				{
					if(a == p.artifacts[j])
					{
						p.artifacts.splice(j,1);
						break;
					}
					j++;
				}
				i++;
			}
			if(p.artifactCount < p.artifactLimit)
			{
				g.hud.hideArtifactLimitText();
			}
			recycleBox = new LootPopupMessage();
			g.addChildToOverlay(recycleBox,true);
			i = 1;
			j = 0;
			while(i < m.length)
			{
				junk = m.getString(i);
				amount = m.getInt(i + 1);
				g.myCargo.addItem("Commodities",junk,amount);
				lootItem = new LootItem("Commodities",junk,amount);
				lootItem.y = j * 40;
				recycleBox.addItem(lootItem);
				i += 2;
				j++;
			}
			recycleBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(recycleBox,true);
				toggleRecycle();
			});
			markedForRecycle.splice(0,markedForRecycle.length);
		}
		
		private function onActiveRemoved(e:Event) : void
		{
			var _loc4_:ArtifactBox = e.target as ArtifactBox;
			var _loc2_:Artifact = _loc4_.a;
			if(!g.me.isLanded && !g.me.inSafeZone)
			{
				g.showErrorDialog(Localize.t("Artifacts can only be changed inside the safe zones."));
				return;
			}
			_loc4_.setEmpty();
			p.toggleArtifact(_loc2_);
			reloadStats();
			if(selectedUpgradeBox != null && selectedUpgradeBox.a == _loc4_.a)
			{
				return;
			}
			for each(var _loc3_ in cargoBoxes)
			{
				if(_loc3_.a == _loc2_)
				{
					_loc3_.stateNormal();
					break;
				}
			}
		}
		
		private function onCrewSelected(e:Event) : void
		{
			selectedCrewMember = e.target as CrewDisplayBoxNew;
			if(selectedUpgradeBox != null)
			{
				upgradeButton.enabled = true;
			}
		}
		
		private function onUpgradeArtifact(e:Event) : void
		{
			var _loc2_:Artifact = selectedUpgradeBox.a;
			var _loc4_:Number = _loc2_.level;
			var _loc5_:Number = _loc2_.level - 50;
			var _loc6_:Number = _loc2_.level - 75;
			if(_loc4_ > 50)
			{
				_loc4_ = 50;
			}
			if(_loc5_ > 25)
			{
				_loc5_ = 25;
			}
			if(_loc5_ < 0)
			{
				_loc5_ = 0;
			}
			if(_loc6_ < 0)
			{
				_loc6_ = 0;
			}
			var _loc3_:Number = 5 * Math.pow(1.075,_loc4_) * Math.pow(1.05,_loc5_) * (1 + 0.02 * _loc6_) * (60) * 1000;
			if(_loc3_ > 500 * 24 * 60 * 60)
			{
				_loc3_ = 43200000;
			}
			g.showConfirmDialog(Localize.t("The upgrade will be finished in") + ": \n\n<font color=\'#ffaa88\'>" + Util.getFormattedTime(_loc3_) + "</font>",confirmUpgrade);
			upgradeButton.enabled = true;
		}
		
		private function confirmUpgrade() : void
		{
			if(selectedUpgradeBox == null)
			{
				selectedCrewMember = null;
				upgradeButton.enabled = false;
				g.showErrorDialog("Something went wrong, please try again. No resources or flux were taken from your account",true);
				return;
			}
			g.showModalLoadingScreen("Starting upgrade...");
			selectedUpgradeBox.setNotSelected();
			selectedUpgradeBox.touchable = false;
			selectedCrewMember.touchable = false;
			var _loc1_:Message = g.createMessage("startUpgradeArtifact");
			_loc1_.add(selectedUpgradeBox.a.id,selectedCrewMember.key);
			g.rpcMessage(_loc1_,startedUpgrade);
			upgradeButton.enabled = false;
		}
		
		private function startedUpgrade(m:Message) : void
		{
			var _loc2_:CrewMember = null;
			if(m.getBoolean(0))
			{
				selectedUpgradeBox.a.upgrading = true;
				selectedUpgradeBox.update();
				_loc2_ = selectedCrewMember.crewMember;
				_loc2_.artifact = selectedUpgradeBox.a.id;
				_loc2_.artifactEnd = m.getNumber(1);
				selectedCrewMember.setSelected(false);
				Game.trackEvent("actions","started artifact upgrade",p.level.toString(),CreditManager.getCostArtifactUpgrade(g,_loc2_.artifactEnd));
			}
			else if(m.length > 1)
			{
				g.showErrorDialog(m.getString(1));
			}
			selectedUpgradeBox.touchable = true;
			selectedCrewMember.touchable = true;
			selectedCrewMember = null;
			selectedUpgradeBox = null;
			g.hideModalLoadingScreen();
		}
		
		private function onUpgradeArtifactComplete(e:Event = null) : void
		{
			var _loc2_:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
			sendArtifactComplete(_loc2_.crewMember);
		}
		
		private function onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade:Vector.<CrewMember>, i:int = 0) : void
		{
			if(i >= crewMembersThatCompletedUpgrade.length)
			{
				return;
			}
			sendArtifactComplete(crewMembersThatCompletedUpgrade[i],function():void
			{
				onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade,i + 1);
			});
		}
		
		private function sendArtifactComplete(crewMember:CrewMember, finishedCallback:Function = null) : void
		{
			var artifactKey:String = crewMember.artifact;
			var crewKey:String = crewMember.key;
			var m:Message = g.createMessage("completeUpgradeArtifact");
			m.add(artifactKey,crewKey);
			g.showModalLoadingScreen("Waiting for result...");
			g.rpcMessage(m,function(param1:Message):void
			{
				g.hideModalLoadingScreen();
				artifactUpgradeComplete(param1,finishedCallback);
			});
		}
		
		private function artifactUpgradeComplete(m:Message, finishedCallback:Function = null) : void
		{
			var soundManager:ISound;
			if(m.getBoolean(0))
			{
				soundManager = SoundLocator.getService();
				soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q",null,function():void
				{
					var isActive:Boolean;
					var newLevel:int;
					var diffLevel:int;
					var container:Sprite;
					var overlay:Quad;
					var artBox:ArtifactBox;
					var box:Box;
					var upgradeText:TextBitmap;
					var crewSkillText:TextBitmap;
					var levelText:TextBitmap;
					var hh:Number;
					var i:int;
					var statText:TextField;
					var stat:ArtifactStat;
					var newValue:Number;
					var diff:Number;
					var closeButton:Button;
					var acBox:ArtifactCargoBox;
					var aBox:ArtifactBox;
					var cm:CrewMember = p.getCrewMember(m.getString(1));
					var newSkillPoints:int = m.getInt(2);
					var a:Artifact = p.getArtifactById(m.getString(3));
					cm.skillPoints += newSkillPoints;
					isActive = p.isActiveArtifact(a);
					if(isActive)
					{
						p.toggleArtifact(a,false);
					}
					newLevel = m.getInt(4);
					diffLevel = newLevel - a.level;
					diffLevel = int(diffLevel <= 0 ? 1 : diffLevel);
					a.level = newLevel;
					a.upgraded += 1;
					a.upgrading = false;
					container = new Sprite();
					g.addChildToOverlay(container);
					overlay = new Quad(g.stage.stageWidth,g.stage.stageHeight,0);
					overlay.alpha = 0.4;
					container.addChild(overlay);
					artBox = new ArtifactBox(g,a);
					artBox.update();
					box = new Box(3 * 60,80 + a.stats.length * 25 + artBox.height + 60,"highlight");
					box.x = g.stage.stageWidth / 2 - box.width / 2;
					box.y = g.stage.stageHeight / 2 - box.height / 2;
					container.addChild(box);
					artBox.x = box.width / 2 - artBox.width / 2 - 20;
					box.addChild(artBox);
					upgradeText = new TextBitmap();
					upgradeText.format.color = 0xaaaaaa;
					upgradeText.y = artBox.height + 20;
					upgradeText.text = Localize.t("Upgrade Result");
					upgradeText.x = 90;
					upgradeText.center();
					box.addChild(upgradeText);
					crewSkillText = new TextBitmap();
					crewSkillText.format.color = 0xffffff;
					crewSkillText.text = Localize.t("Crew Skill") + " +" + newSkillPoints;
					crewSkillText.size = 14;
					crewSkillText.x = 90;
					crewSkillText.y = upgradeText.y + upgradeText.height + 10;
					crewSkillText.center();
					box.addChild(crewSkillText);
					levelText = new TextBitmap();
					levelText.format.color = 0xffffff;
					levelText.text = Localize.t("strength") + " +" + diffLevel;
					levelText.size = 18;
					levelText.x = 90;
					levelText.y = crewSkillText.y + crewSkillText.height + 10;
					levelText.center();
					levelText.visible = false;
					box.addChild(levelText);
					TweenMax.delayedCall(1,function():void
					{
						soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
						levelText.visible = true;
						TweenMax.from(levelText,1,{
							"scaleX":2,
							"scaleY":2,
							"alpha":0
						});
					});
					hh = levelText.y + levelText.height + 10;
					i = 0;
					while(i < a.stats.length)
					{
						statText = new TextField(box.width,16,"",new TextFormat("DAIDRR",13,a.getColor()));
						stat = a.stats[i];
						newValue = m.getNumber(5 + i);
						diff = newValue - stat.value;
						stat.value = newValue;
						statText.text = ArtifactStat.parseTextFromStatType(stat.type,diff,stat.isUnique);
						statText.isHtmlText = true;
						statText.x = -20;
						statText.y = i * 25 + hh;
						box.addChild(statText);
						TweenMax.from(statText,1,{
							"scaleX":0.5,
							"scaleY":0.5,
							"alpha":0
						});
						i++;
					}
					closeButton = new Button(function():void
					{
						g.removeChildFromOverlay(container,true);
						if(finishedCallback != null)
						{
							finishedCallback();
						}
					},Localize.t("close"));
					closeButton.x = 90 - closeButton.width / 2;
					closeButton.y = box.height - 60;
					box.addChild(closeButton);
					cm.artifact = "";
					cm.artifactEnd = 0;
					if(isActive)
					{
						p.toggleArtifact(a,false);
					}
					for each(acBox in cargoBoxes)
					{
						if(acBox.a == a)
						{
							acBox.showHint();
						}
						acBox.setNotSelected();
					}
					for each(aBox in activeSlots)
					{
						if(aBox.a == a)
						{
							aBox.update();
						}
					}
					reloadStats();
				});
			}
			else
			{
				if(m.length > 1)
				{
					g.showErrorDialog(m.getString(1));
				}
				if(finishedCallback != null)
				{
					finishedCallback();
				}
			}
			selectedUpgradeBox = null;
		}
	}
}

