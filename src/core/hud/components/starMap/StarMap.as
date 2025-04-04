package core.hud.components.starMap
{
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.friend.Friend;
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.credits.FBInviteUnlock;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import generics.Localize;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class StarMap extends Sprite
	{
		public static var selectedSolarSystem:SolarSystem;
		private static const PADDING:Number = 30;
		public static var friendsInSelectedSystem:Array = [];
		private var g:Game;
		private var p:Player;
		private var dataManager:IDataManager;
		private var discoveredSolarSystemsKeys:Array;
		private var allSolarSystems:Object;
		private var solarSystemIcons:Array;
		private var _height:Number;
		private var _width:Number;
		private var animationTween:TweenMax;
		private var textureManager:ITextureManager;
		private var container:Sprite;
		private var warpPathContainer:Sprite;
		private var galaxyText:Text;
		private var crewText:Text;
		private var crewBullet:Image;
		private var friendsInSystem:Sprite;
		private var friendsBullet:Image;
		private var crewAndFriendContainer:Sprite;
		private var _selectedWarpPath:WarpPath;
		private var allowBuy:Boolean;
		private var _currentSolarSystemKey:String;
		private var _currentSolarSystem:SolarSystem;
		private var focusSolarSystemKey:String;
		private var neighbours:Array;
		private var _warpPathLicenses:Array;
		private var _warpPaths:Array;
		private var confirmBuyWithFlux:CreditBuyBox;
		private var aquiredContainer:Sprite;
		private var aquiredText:Text;
		private var buyContainer:Sprite;
		private var buyButton:Button;
		private var buyWithFluxButton:Button;
		private var buyWithInviteButton:FBInviteUnlock = null;
		private var shipImage:MovieClip;
		private var orText:Text;
		
		public function StarMap(g:Game, width:Number = 540, height:Number = 240, allowBuy:Boolean = false, focusSolarSystemKey:String = "")
		{
			var bgr2:Image;
			var obj:Object;
			var obj2:Object;
			container = new Sprite();
			warpPathContainer = new Sprite();
			galaxyText = new Text();
			crewText = new Text();
			friendsInSystem = new Sprite();
			crewAndFriendContainer = new Sprite();
			neighbours = [];
			_warpPathLicenses = [];
			_warpPaths = [];
			aquiredContainer = new Sprite();
			aquiredText = new Text();
			buyContainer = new Sprite();
			super();
			this.g = g;
			this.p = g.me;
			this.allowBuy = allowBuy;
			this.focusSolarSystemKey = focusSolarSystemKey;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			_height = height;
			_width = width;
			solarSystemIcons = [];
			bgr2 = new Image(textureManager.getTextureGUIByTextureName("star_map.jpg"));
			container.addChild(bgr2);
			container.addChild(warpPathContainer);
			container.mask = new Quad(width,height);
			galaxyText.size = 14;
			galaxyText.x = 20;
			galaxyText.y = 15;
			addChild(container);
			addChild(galaxyText);
			buyContainer.x = 500;
			buyContainer.y = 15;
			buyContainer.visible = false;
			crewAndFriendContainer.x = 500;
			crewAndFriendContainer.y = 40;
			crewAndFriendContainer.touchable = false;
			crewText.x = 530;
			crewText.y = 80;
			crewText.size = 10;
			crewText.color = Style.COLOR_CREW;
			crewText.touchable = false;
			addChild(crewText);
			friendsBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_friend"));
			crewBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_crew"));
			crewBullet.x = 520;
			friendsBullet.x = 520;
			crewBullet.visible = false;
			friendsBullet.visible = false;
			crewBullet.pivotX = crewBullet.width / 2;
			crewBullet.pivotY = crewBullet.height / 2;
			crewBullet.color = Style.COLOR_CREW;
			friendsBullet.pivotX = friendsBullet.width / 2;
			friendsBullet.pivotY = friendsBullet.height / 2;
			friendsBullet.color = Style.COLOR_FRIENDS;
			addChild(crewBullet);
			addChild(friendsBullet);
			friendsInSystem.x = 530;
			friendsInSystem.y = 80;
			addChild(friendsInSystem);
			orText = new Text();
			orText.size = 25;
			orText.text = "or";
			orText.visible = false;
			aquiredText.size = 10;
			aquiredText.width = 150;
			aquiredText.height = 80;
			aquiredText.wordWrap = true;
			aquiredText.y = 15;
			aquiredText.x = 10;
			aquiredContainer.visible = true;
			aquiredText.color = Style.COLOR_VALID;
			aquiredText.text = Localize.t("You are here.");
			aquiredContainer.x = 500;
			aquiredContainer.y = 15;
			if(allowBuy)
			{
				buyButton = new Button(function(param1:TouchEvent):void
				{
					if(selectedWarpPath != null)
					{
						if(selectedSolarSystem.dev && !g.me.isDeveloper)
						{
							g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
							return;
						}
						g.rpc("buyWarpPath",boughtWarpPath,selectedWarpPath.key);
					}
				},Localize.t("Buy"),"positive");
				buyButton.name = "buyButton";
				buyContainer.addChild(orText);
				buyContainer.addChild(buyButton);
				buyWithFluxButton = new Button(function():void
				{
					var warpPathObj:Object;
					var fluxCost:int;
					if(selectedWarpPath == null)
					{
						return;
					}
					if(selectedSolarSystem.dev && (!g.me.isTester && !g.me.isDeveloper))
					{
						g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
						return;
					}
					warpPathObj = dataManager.loadKey("WarpPaths",selectedWarpPath.key);
					fluxCost = CreditManager.getCostWarpPathLicense(warpPathObj.payVaultItem);
					g.creditManager.refresh(function():void
					{
						confirmBuyWithFlux = new CreditBuyBox(g,fluxCost,Localize.t("Are you sure you want to buy the warp path license?"));
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept",onAccept);
						confirmBuyWithFlux.addEventListener("close",onClose);
					});
				},Localize.t("Buy with Flux"),"highlight");
				buyContainer.addChild(buyWithFluxButton);
				if(Login.currentState == "facebook")
				{
					buyWithInviteButton = new FBInviteUnlock(g,Math.ceil(1),function():void
					{
						if(selectedWarpPath != null)
						{
							if(selectedSolarSystem.dev && (!g.me.isTester && !g.me.isDeveloper))
							{
								g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
								return;
							}
							g.rpc("buyWarpPathWithInvites",boughtWarpPath,selectedWarpPath.key);
						}
					},function():void
					{
						g.showErrorDialog(Localize.t("Insufficient number of invites."));
					});
					buyWithInviteButton.visible = false;
					buyWithInviteButton.enabled = false;
					buyContainer.addChild(buyWithInviteButton);
				}
			}
			obj = dataManager.loadKey("Skins",p.activeSkin);
			obj2 = dataManager.loadKey("Ships",obj.ship);
			shipImage = new MovieClip(textureManager.getTexturesMainByKey(obj2.bitmap));
			shipImage.readjustSize();
			shipImage.scaleX = 0.5;
			shipImage.scaleY = 0.5;
			container.addChild(shipImage);
			aquiredContainer.addChild(aquiredText);
			addChild(aquiredContainer);
			addEventListener("removedFromStage",clean);
		}
		
		public function load(callback:Function = null) : void
		{
			var systemKey:String;
			var system:Object;
			var dataManager:IDataManager = DataLocator.getService();
			_currentSolarSystemKey = g.solarSystem.key;
			_warpPathLicenses = p.warpPathLicenses;
			discoveredSolarSystemsKeys = [];
			for each(systemKey in p.solarSystemLicenses)
			{
				system = dataManager.loadKey("SolarSystems",systemKey);
				if(system != null)
				{
					discoveredSolarSystemsKeys.push(systemKey);
				}
			}
			allSolarSystems = dataManager.loadTable("SolarSystems");
			createMap();
			loadFriends(function():void
			{
				loadCrew();
				if(focusSolarSystemKey == "")
				{
					focusSolarSystemKey = currentSolarSystem.key;
				}
				var _loc1_:SolarSystem = findSolarSystemIcon(focusSolarSystemKey);
				if(_loc1_ != null)
				{
					selectedSolarSystem.selected = false;
					selectIcon(_loc1_);
				}
				if(callback != null)
				{
					callback();
				}
			});
		}
		
		private function loadFriends(callback:Function) : void
		{
			g.friendManager.updateOnlineFriends(function():void
			{
				if(Player.onlineFriends.length == 0)
				{
					callback();
					return;
				}
				for each(var _loc2_ in solarSystemIcons)
				{
					for each(var _loc1_ in Player.onlineFriends)
					{
						if(_loc1_.currentSolarSystem == _loc2_.key)
						{
							_loc2_.hasFriends = true;
						}
					}
				}
				callback();
			});
		}
		
		private function loadCrew() : void
		{
			var _loc1_:Vector.<CrewMember> = g.me.crewMembers;
			for each(var _loc3_ in solarSystemIcons)
			{
				for each(var _loc2_ in _loc1_)
				{
					if(_loc2_.solarSystem == _loc3_.key)
					{
						_loc3_.hasCrew = true;
					}
				}
			}
		}
		
		private function createMap() : void
		{
			var _loc1_:Object = null;
			var _loc4_:SolarSystem = null;
			var _loc5_:Object = null;
			var _loc10_:SolarSystem = null;
			var _loc11_:SolarSystem = null;
			var _loc3_:Boolean = false;
			var _loc8_:WarpPath = null;
			for(var _loc9_ in allSolarSystems)
			{
				_loc1_ = allSolarSystems[_loc9_];
				_loc4_ = new SolarSystem(g,_loc1_,_loc9_,isDiscovered(_loc9_),_currentSolarSystemKey);
				if(!(_loc1_ == null || !_loc1_.hasOwnProperty("type") || _loc1_.type != "regular" && _loc1_.type != "pvp"))
				{
					container.addChild(_loc4_);
					solarSystemIcons.push(_loc4_);
					if(_loc4_.isCurrentSolarSystem)
					{
						updateRect(_loc4_.x,_loc4_.y);
						shipImage.x = _loc4_.x + _loc4_.size + 5;
						shipImage.y = _loc4_.y - _loc4_.size - 20;
						galaxyText.text = _loc4_.galaxy;
						galaxyText.color = _loc4_.color;
						_loc4_.selected = true;
						_currentSolarSystem = _loc4_;
						selectedSolarSystem = _loc4_;
					}
					if(!_loc4_.isDestroyed)
					{
						_loc4_.addEventListener("touch",onTouch);
					}
				}
			}
			var _loc2_:Object = dataManager.loadTable("WarpPaths");
			for(var _loc6_ in _loc2_)
			{
				_loc5_ = _loc2_[_loc6_];
				_loc10_ = findSolarSystemIcon(_loc5_.solarSystem1);
				_loc11_ = findSolarSystemIcon(_loc5_.solarSystem2);
				if(_loc10_ == null || _loc11_ == null)
				{
					Console.write("Something went wrong, could not find solarSystemIcon in Star Map.");
				}
				else
				{
					if(_loc10_.key == currentSolarSystem.key)
					{
						neighbours.push(_loc11_.key);
					}
					else if(_loc11_.key == currentSolarSystem.key)
					{
						neighbours.push(_loc10_.key);
					}
					_loc3_ = false;
					for each(var _loc7_ in _warpPathLicenses)
					{
						if(_loc7_ == _loc5_.key)
						{
							_loc3_ = true;
						}
					}
					_loc8_ = new WarpPath(g,_loc5_,_loc10_,_loc11_,_loc3_);
					_loc8_.x = _loc10_.x;
					_loc8_.y = _loc10_.y;
					if(_loc8_.transit)
					{
						_loc8_.addEventListener("transitClick",transitClick);
					}
					_warpPaths.push(_loc8_);
					warpPathContainer.addChild(_loc8_);
				}
			}
		}
		
		private function transitClick(e:Event) : void
		{
			var _loc2_:* = null;
			var _loc3_:String = e.data.solarSystemKey;
			for each(_loc2_ in solarSystemIcons)
			{
				_loc2_.selected = false;
				if(_loc2_.key == _loc3_)
				{
					selectIcon(_loc2_);
				}
			}
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			var _loc3_:SolarSystem = e.currentTarget as SolarSystem;
			if(e.getTouch(_loc3_,"ended"))
			{
				for each(var _loc2_ in solarSystemIcons)
				{
					_loc2_.selected = false;
				}
				selectIcon(_loc3_);
			}
		}
		
		private function selectIcon(icon:SolarSystem) : void
		{
			var _loc8_:WarpToFriendRow = null;
			icon.selected = true;
			galaxyText.text = icon.galaxy;
			galaxyText.color = icon.color;
			selectedSolarSystem = icon;
			var _loc3_:String = "<FONT COLOR=\'#666666\'>" + Localize.t("Crew") + "</FONT>\n";
			var _loc2_:Vector.<CrewMember> = g.me.getCrewMembersBySolarSystem(icon.key);
			if(_loc2_.length > 0)
			{
				crewText.visible = true;
				crewBullet.visible = true;
			}
			else
			{
				crewText.visible = false;
				crewBullet.visible = false;
			}
			for each(var _loc5_ in _loc2_)
			{
				_loc3_ += _loc5_.name + "\n";
			}
			_loc3_ += "\n\n";
			crewText.htmlText = _loc3_;
			crewBullet.y = crewText.y + 8;
			var _loc6_:int = 0;
			friendsInSystem.removeChildren(0,-1,true);
			var _loc4_:Text = new Text();
			_loc4_.text = Localize.t("Friends") + ":";
			_loc4_.color = 0x666666;
			friendsInSystem.addChild(_loc4_);
			friendsInSelectedSystem = [];
			for each(var _loc7_ in Player.onlineFriends)
			{
				if(_loc7_.currentSolarSystem == icon.key)
				{
					_loc6_++;
					_loc8_ = new WarpToFriendRow(_loc7_);
					_loc8_.y = _loc6_ * 25;
					friendsInSystem.addChild(_loc8_);
					friendsInSelectedSystem.push(_loc7_);
				}
			}
			if(_loc6_ > 0)
			{
				friendsInSystem.visible = true;
				friendsBullet.visible = true;
			}
			else
			{
				friendsInSystem.visible = false;
				friendsBullet.visible = false;
			}
			friendsInSystem.y = crewText.y + crewText.height;
			friendsBullet.y = friendsInSystem.y + 8;
			updateRect(icon.x,icon.y);
			for each(var _loc9_ in _warpPaths)
			{
				_loc9_.selected = false;
			}
			handleWarpJumpAllowance();
		}
		
		private function handleWarpJumpAllowance() : void
		{
			var _loc5_:* = null;
			var _loc3_:* = undefined;
			var _loc4_:DisplayObject = null;
			var _loc7_:Sprite = null;
			var _loc2_:Object = null;
			var _loc8_:int = 0;
			buyContainer.visible = false;
			aquiredContainer.visible = false;
			_selectedWarpPath = null;
			for each(_loc5_ in _warpPaths)
			{
				_loc5_.selected = false;
			}
			if(selectedSolarSystem == _currentSolarSystem)
			{
				aquiredContainer.visible = true;
				aquiredText.text = Localize.t("You are here.");
				aquiredText.color = Style.COLOR_VALID;
				aquiredContainer.y = 15;
				dispatchEvent(new Event("disallowWarpJump"));
				return;
			}
			if(allowBuy)
			{
				_loc3_ = findClosestPath(selectedSolarSystem.key);
				for each(var _loc1_ in _loc3_)
				{
					for each(_loc5_ in _warpPaths)
					{
						if(_loc1_.parent != null)
						{
							if(_loc5_.isConnectedTo(_loc1_.key,_loc1_.parent.key))
							{
								_loc5_.selected = true;
							}
						}
					}
				}
				if(_loc3_ != null && _loc3_.length > 1)
				{
					for each(_loc5_ in _warpPaths)
					{
						if(_loc5_.isConnectedTo(_loc3_[0].key,_loc3_[1].key))
						{
							Console.write("Warp path key: " + _loc5_.key);
							_selectedWarpPath = _loc5_;
							_loc5_.selected = true;
							for each(var _loc6_ in p.solarSystemLicenses)
							{
								if(_loc6_ == selectedSolarSystem.key)
								{
									_selectedWarpPath.bought = true;
								}
							}
							if(!_selectedWarpPath.bought)
							{
								aquiredContainer.visible = false;
								buyButton.x = 0;
								buyButton.y = 0;
								_loc4_ = buyContainer.getChildByName("costContainer");
								if(_loc4_ != null)
								{
									buyContainer.removeChild(_loc4_);
								}
								_loc7_ = _selectedWarpPath.costContainer;
								_loc7_.x = 0;
								_loc7_.y = buyButton.y + buyButton.height + 8;
								_loc7_.visible = true;
								_loc7_.name = "costContainer";
								_loc7_.touchable = false;
								buyContainer.addChild(_loc7_);
								_loc2_ = dataManager.loadKey("WarpPaths",_loc5_.key);
								_loc8_ = CreditManager.getCostWarpPathLicense(_loc2_.payVaultItem);
								if(_loc8_ > 0)
								{
									orText.visible = true;
									orText.color = 0xaaaaaa;
									orText.x = 5;
									orText.y = _loc7_.y + _loc7_.height + 5;
									buyWithFluxButton.text = Localize.t("Buy for [flux] Flux").replace("[flux]",_loc8_);
									buyWithFluxButton.x = buyButton.x;
									buyWithFluxButton.y = _loc7_.y + _loc7_.height + 45;
									buyWithFluxButton.visible = true;
									if(buyWithInviteButton != null)
									{
										buyWithInviteButton.setNrRequired(Math.max(2,Math.ceil(0.04 * _loc8_)));
										buyWithInviteButton.visible = true;
										buyWithInviteButton.enabled = true;
										buyWithInviteButton.x = buyWithFluxButton.x;
										buyWithInviteButton.y = buyWithFluxButton.y + buyWithFluxButton.height + 15;
									}
								}
								else
								{
									buyWithFluxButton.visible = false;
									if(buyWithInviteButton != null)
									{
										buyWithInviteButton.visible = false;
										buyWithInviteButton.enabled = false;
									}
								}
								buyContainer.x = 15;
								buyContainer.y = 45;
								addChild(buyContainer);
								buyContainer.visible = true;
								dispatchEvent(new Event("disallowWarpJump"));
								return;
							}
							dispatchEvent(new Event("allowWarpJump"));
							return;
						}
					}
				}
			}
			aquiredContainer.visible = true;
			aquiredText.text = Localize.t("You can\'t warp jump to here.");
			aquiredText.color = Style.COLOR_INVALID;
			aquiredContainer.y = 15;
			dispatchEvent(new Event("disallowWarpJump"));
		}
		
		private function findClosestPath(destinationKey:String) : Vector.<Node>
		{
			var _loc3_:Node = new Node(currentSolarSystem.key);
			var _loc2_:Node = fbs(_loc3_,destinationKey);
			if(_loc2_ == null)
			{
				return null;
			}
			return _loc2_.getNodePath();
		}
		
		private function fbs(currentNode:Node, destinationKey:String) : Node
		{
			var _loc4_:Vector.<Node> = new Vector.<Node>();
			var _loc3_:Vector.<WarpPath> = new Vector.<WarpPath>();
			_loc4_.push(currentNode);
			while(currentNode.key != destinationKey)
			{
				if(_loc4_.length == 0)
				{
					return null;
				}
				currentNode = _loc4_.shift();
				findChildren(currentNode,_loc3_);
				for each(var _loc5_ in currentNode.children)
				{
					_loc4_.push(_loc5_);
				}
			}
			return currentNode;
		}
		
		private function findChildren(node:Node, paths:Vector.<WarpPath>) : void
		{
			var _loc4_:Node = null;
			for each(var _loc3_ in _warpPaths)
			{
				if(paths.indexOf(_loc3_) == -1)
				{
					_loc4_ = null;
					if(node.key == _loc3_.solarSystem1)
					{
						_loc4_ = new Node(_loc3_.solarSystem2);
					}
					else if(node.key == _loc3_.solarSystem2)
					{
						_loc4_ = new Node(_loc3_.solarSystem1);
					}
					if(_loc4_ != null)
					{
						node.addChild(_loc4_);
						paths.push(_loc3_);
					}
				}
			}
		}
		
		private function isDiscovered(key:String) : Boolean
		{
			for each(var _loc2_ in discoveredSolarSystemsKeys)
			{
				if(_loc2_ == key)
				{
					return true;
				}
			}
			return false;
		}
		
		private function findSolarSystemIcon(key:String) : SolarSystem
		{
			for each(var _loc2_ in solarSystemIcons)
			{
				if(_loc2_.key == key)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		private function updateRect(x:Number, y:Number) : void
		{
			var rect:DisplayObject = container.mask;
			if(animationTween != null)
			{
				animationTween.kill();
			}
			animationTween = TweenMax.to(rect,1,{
				"x":x - _width / 2,
				"y":y - _height / 2,
				"onUpdate":function():void
				{
					container.x = -rect.x;
					container.y = -rect.y;
				}
			});
		}
		
		public function get selectedWarpPath() : WarpPath
		{
			return _selectedWarpPath;
		}
		
		public function get currentSolarSystem() : SolarSystem
		{
			return _currentSolarSystem;
		}
		
		private function onAccept(e:Event) : void
		{
			g.rpc("buyWarpPathWithFlux",boughtWarpPathWithFlux,selectedWarpPath.key);
			confirmBuyWithFlux.removeEventListener("accept",onAccept);
			confirmBuyWithFlux.removeEventListener("close",onClose);
		}
		
		private function boughtWarpPathWithFlux(m:Message) : void
		{
			var _loc2_:Object = null;
			var _loc3_:int = 0;
			if(m.getBoolean(0))
			{
				selectedSolarSystem.discovered = true;
				selectedWarpPath.bought = true;
				p.solarSystemLicenses.push(selectedSolarSystem.key);
				p.warpPathLicenses.push(selectedWarpPath.key);
				_loc2_ = dataManager.loadKey("WarpPaths",selectedWarpPath.key);
				_loc3_ = CreditManager.getCostWarpPathLicense(_loc2_.payVaultItem);
				selectIcon(selectedSolarSystem);
				Game.trackEvent("used flux","warp path",selectedWarpPath.name,_loc3_);
				Action.unlockSystem(selectedSolarSystem.key);
				g.creditManager.refresh();
				animateBuy();
			}
			else
			{
				buyWithFluxButton.enabled = true;
				if(m.length > 1)
				{
					g.showErrorDialog(m.getString(1));
				}
			}
		}
		
		private function onClose(e:Event) : void
		{
			confirmBuyWithFlux.removeEventListener("accept",onAccept);
			confirmBuyWithFlux.removeEventListener("close",onClose);
			buyWithFluxButton.enabled = true;
		}
		
		private function boughtWarpPath(m:Message) : void
		{
			if(m.getBoolean(0) && selectedWarpPath != null && selectedSolarSystem != null)
			{
				selectedSolarSystem.discovered = true;
				selectedWarpPath.bought = true;
				p.solarSystemLicenses.push(selectedSolarSystem.key);
				p.warpPathLicenses.push(selectedWarpPath.key);
				for each(var _loc2_ in selectedWarpPath.priceItems)
				{
					g.myCargo.removeMinerals(_loc2_.item,_loc2_.amount);
				}
				selectIcon(selectedSolarSystem);
				Action.unlockSystem(selectedSolarSystem.key);
				Console.write("Warp path bought!");
				animateBuy();
			}
			else
			{
				buyButton.enabled = true;
				if(m.length > 1)
				{
					g.showErrorDialog(m.getString(1));
				}
			}
		}
		
		private function animateBuy() : void
		{
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q",function():void
			{
				TweenMax.from(selectedSolarSystem,1,{
					"scaleX":8,
					"scaleY":8,
					"alpha":0
				});
				soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q");
			});
		}
		
		public function clean(e:Event = null) : void
		{
			Console.write("Clean up warp gate");
			for each(var _loc2_ in _warpPaths)
			{
				_loc2_.removeEventListener("transitClick",transitClick);
			}
			removeEventListener("removedFromStage",clean);
			dispose();
		}
	}
}

import core.friend.Friend;
import core.hud.components.Style;
import core.hud.components.Text;
import starling.display.Sprite;

class Node
{
	private var _children:Vector.<Node> = new Vector.<Node>();
	public var parent:Node = null;
	private var _key:String;
	
	public function Node(key:String)
	{
		super();
		_key = key;
	}
	
	public function addChild(node:Node) : void
	{
		node.parent = this;
		_children.push(node);
	}
	
	public function get children() : Vector.<Node>
	{
		return _children;
	}
	
	public function get key() : String
	{
		return _key;
	}
	
	public function getNodePath(nodes:Vector.<Node> = null) : Vector.<Node>
	{
		if(nodes == null)
		{
			nodes = new Vector.<Node>();
		}
		nodes.push(this);
		if(parent != null)
		{
			return parent.getNodePath(nodes);
		}
		return nodes;
	}
}

class WarpToFriendRow extends Sprite
{
	public function WarpToFriendRow(f:Friend)
	{
		super();
		var _loc2_:Text = new Text();
		_loc2_.color = Style.COLOR_H2;
		_loc2_.text = f.name;
		addChild(_loc2_);
	}
}
