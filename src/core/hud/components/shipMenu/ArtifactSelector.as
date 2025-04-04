package core.hud.components.shipMenu
{
	import core.artifact.Artifact;
	import core.credits.CreditManager;
	import core.hud.components.PriceCommodities;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.player.Player;
	import core.scene.Game;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactSelector extends Sprite
	{
		private var g:Game;
		private var p:Player;
		private var icons:Vector.<MenuSelectIcon> = new Vector.<MenuSelectIcon>();
		private var textureManager:ITextureManager;
		
		public function ArtifactSelector(g:Game, p:Player)
		{
			this.g = g;
			this.p = p;
			super();
			textureManager = TextureLocator.getService();
			load();
		}
		
		private function load() : void
		{
			var _loc3_:int = 0;
			var _loc2_:String = "";
			for each(var _loc1_ in p.artifacts)
			{
				if(p.isActiveArtifact(_loc1_))
				{
					_loc2_ = "<FONT COLOR=\'#2233ff\'>" + _loc1_.name + "</FONT>: Click to change active artifacts";
					createArtifactIcon(_loc3_,textureManager.getTextureGUIByKey(_loc1_.bitmap),"slot_artifact.png",false,true,true,_loc2_);
					_loc3_++;
				}
			}
			_loc3_;
			while(_loc3_ < p.unlockedArtifactSlots)
			{
				_loc2_ = "Empty: Click to assign an artifact";
				createArtifactIcon(_loc3_,null,"slot_artifact.png",false,false,true,_loc2_);
				_loc3_++;
			}
			if(_loc3_ < 5)
			{
				_loc2_ = "Locked artifact slot, click to buy this slot";
				createArtifactIcon(_loc3_,null,"slot_artifact.png",true,false,true,_loc2_);
				_loc3_++;
			}
			_loc3_;
			while(_loc3_ < 5)
			{
				_loc2_ = "Locked artifact slot";
				createArtifactIcon(_loc3_,null,"slot_artifact.png",true,false,false,_loc2_);
				_loc3_++;
			}
		}
		
		private function createArtifactIcon(number:int, bd:Texture, type:String, locked:Boolean = true, inUse:Boolean = false, enabled:Boolean = false, tooltip:String = null) : void
		{
			var artifactIcon:MenuSelectIcon = new MenuSelectIcon(number + 1,bd,type,locked,inUse,enabled);
			artifactIcon.x = number * (60);
			if(tooltip != null)
			{
				new ToolTip(g,artifactIcon,tooltip,null,"HomeState");
			}
			if(!locked)
			{
				artifactIcon.addEventListener("touch",function(param1:TouchEvent):void
				{
					if(param1.getTouch(artifactIcon,"ended"))
					{
						dispatchEventWith("artifactSelected");
					}
				});
			}
			else if(locked && enabled)
			{
				artifactIcon.addEventListener("touch",function(param1:TouchEvent):void
				{
					if(param1.getTouch(artifactIcon,"ended"))
					{
						openUnlockSlot(artifactIcon.number);
					}
				});
			}
			addChild(artifactIcon);
			icons.push(artifactIcon);
		}
		
		private function openUnlockSlot(number:int) : void
		{
			var unlockCost:int = int(Player.SLOT_ARTIFACT_UNLOCK_COST[number - 1]);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			var fluxCost:int = CreditManager.getCostArtifactSlot(number);
			buyBox.text = "Artifact Slot";
			buyBox.addCost(new PriceCommodities(g,"flpbTKautkC1QzjWT28gkw",unlockCost));
			if(fluxCost > 0)
			{
				buyBox.addBuyForFluxButton(fluxCost,number,"buyArtifactSlotWithFlux","Are you sure you want to buy an artifact slot?");
				buyBox.addEventListener("fluxBuy",function(param1:Event):void
				{
					Game.trackEvent("used flux","bought artifact (ship menu)","number " + number);
					p.unlockedArtifactSlots = number;
					g.removeChildFromOverlay(buyBox,true);
					refresh();
				});
			}
			buyBox.addEventListener("accept",function(param1:Event):void
			{
				var e:Event = param1;
				g.me.tryUnlockSlot("slotArtifact",number,function():void
				{
					g.removeChildFromOverlay(buyBox,true);
					refresh();
				});
			});
			buyBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(buyBox,true);
			});
			g.addChildToOverlay(buyBox);
		}
		
		public function refresh() : void
		{
			for each(var _loc1_ in icons)
			{
				if(contains(_loc1_))
				{
					removeChild(_loc1_,true);
				}
			}
			icons = new Vector.<MenuSelectIcon>();
			load();
		}
		
		override public function dispose() : void
		{
			for each(var _loc1_ in icons)
			{
				if(contains(_loc1_))
				{
					removeChild(_loc1_,true);
				}
			}
			icons = null;
			super.dispose();
		}
	}
}

