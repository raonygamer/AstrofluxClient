package core.hud.components.dialogs
{
	import core.hud.components.Button;
	import core.hud.components.PriceCommodities;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.Event;
	
	public class PopupBuyMessage extends PopupConfirmMessage
	{
		public static const BOUGHT_WITH_FLUX:String = "fluxBuy";
		
		private var priceMinerals:Vector.<PriceCommodities> = new Vector.<PriceCommodities>();
		
		private var fluxButton:Button;
		
		private var g:Game;
		
		public function PopupBuyMessage(g:Game)
		{
			super("Buy");
			this.g = g;
			this.confirmButton.visible = false;
		}
		
		public function addCost(pm:PriceCommodities) : void
		{
			priceMinerals.push(pm);
			if(!g.myCargo.hasCommodities(pm.item,pm.amount))
			{
				confirmButton.enabled = false;
			}
			box.addChild(pm);
			this.confirmButton.visible = true;
			redraw();
		}
		
		public function addBuyForFluxButton(fluxCost:int, slot:int, rpcName:String, buyMessage:String) : void
		{
			fluxButton = new Button(function():void
			{
				g.creditManager.refresh(function():void
				{
					onBuyForFlux(fluxCost,slot,rpcName,buyMessage);
				});
			},"Buy for " + fluxCost + " Flux","buy");
			fluxButton.autoEnableAfterClick = true;
			box.addChild(fluxButton);
			redraw();
		}
		
		private function onBuyForFlux(fluxCost:int, slot:int, rpcName:String, buyMessage:String) : void
		{
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,fluxCost,buyMessage);
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void
			{
				var e:Event = param1;
				g.rpc(rpcName,function(param1:Message):void
				{
					if(param1.getBoolean(0))
					{
						g.creditManager.refresh();
						dispatchEventWith("fluxBuy");
					}
					else
					{
						g.showErrorDialog(param1.getString(1),true);
						g.removeChildFromOverlay(creditBuyBox,true);
					}
				},slot);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox,true);
			});
		}
		
		override protected function redraw(e:Event = null) : void
		{
			var _loc7_:int = 0;
			var _loc8_:PriceCommodities = null;
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc6_:int = 0;
			var _loc4_:Object = null;
			var _loc5_:int = 0;
			try
			{
				if(g == null || g.stage == null || box == null)
				{
					return;
				}
				_loc5_++;
				_loc7_ = 0;
				while(_loc7_ < priceMinerals.length)
				{
					_loc8_ = priceMinerals[_loc7_];
					_loc8_.y = _loc7_ * 30 + textField.height + 15;
					_loc7_++;
				}
				_loc5_++;
				_loc2_ = textField.height + _loc7_ * 30 + 15;
				_loc5_++;
				_loc3_ = 0;
				_loc5_++;
				if(confirmButton.visible)
				{
					confirmButton.y = _loc2_;
					_loc5_++;
					confirmButton.x = _loc3_;
					_loc5_++;
					_loc3_ += confirmButton.width + 5;
					_loc5_++;
				}
				if(fluxButton != null)
				{
					_loc5_++;
					fluxButton.y = _loc2_;
					_loc5_++;
					fluxButton.x = _loc3_;
					_loc5_++;
					_loc3_ += fluxButton.width + 5;
					_loc5_++;
				}
				closeButton.y = _loc2_;
				_loc5_++;
				closeButton.x = _loc3_;
				_loc5_++;
				_loc6_ = closeButton.y + closeButton.height - 3;
				_loc5_++;
				box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
				_loc5_++;
				box.height = _loc6_;
				_loc5_++;
				box.x = g.stage.stageWidth / 2 - box.width / 2;
				_loc5_++;
				box.y = g.stage.stageHeight / 2 - box.height / 2;
				_loc5_++;
				bgr.width = g.stage.stageWidth;
				_loc5_++;
				bgr.height = g.stage.stageHeight;
				_loc5_++;
				bgr.alpha = 0.8;
			}
			catch(e:Error)
			{
				_loc4_ = {};
				_loc4_.box = box == null ? "null" : "exist";
				_loc4_.closeButton = closeButton == null ? "null" : "exist";
				_loc4_.fluxButton = fluxButton == null ? "null" : "exist";
				_loc4_.confirmButton = confirmButton == null ? "null" : "exist";
				_loc4_.priceMinerals = priceMinerals == null ? "null" : "exist";
				_loc4_.textField = textField == null ? "null" : "exist";
				_loc4_.line = _loc5_;
				g.client.errorLog.writeError("PopupbuyMessageNullError2","",e.getStackTrace(),_loc4_);
			}
		}
	}
}

