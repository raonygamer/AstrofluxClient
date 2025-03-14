package core.states.gameStates {
	import core.credits.CreditManager;
	import core.hud.components.ShopItemBar;
	import core.hud.components.Text;
	import core.hud.components.cargo.Cargo;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class LandedWeaponFactory extends LandedState {
		private var shopItemBars:Vector.<ShopItemBar> = new Vector.<ShopItemBar>();
		private var myCargo:Cargo;
		private var container:ScrollContainer;
		private var infoContainer:Sprite = new Sprite();
		private var hasBought:Boolean = false;
		private var fluxCost:int;
		
		public function LandedWeaponFactory(g:Game, body:Body, startMusic:Boolean = true) {
			super(g,body,body.name);
			fluxCost = CreditManager.getCostWeaponFactory(body.obj.payVaultItem);
			myCargo = g.myCargo;
		}
		
		override public function enter() : void {
			super.enter();
			container = new ScrollContainer();
			container.width = 640;
			container.height = 400;
			container.x = 60;
			container.y = 140;
			addChild(container);
			infoContainer.x = 380;
			infoContainer.y = 140;
			addChild(infoContainer);
			var _local2:Text = new Text();
			_local2.text = body.name;
			_local2.size = 26;
			_local2.x = 60;
			_local2.y = 50;
			addChild(_local2);
			var _local1:Text = new Text();
			_local1.text = Localize.t("Produce a weapon with minerals or Flux.");
			_local1.color = 0xaaaaaa;
			_local1.x = 60;
			_local1.y = _local2.y + _local2.height + 10;
			addChild(_local1);
			cargoRecieved();
		}
		
		override public function execute() : void {
			super.execute();
		}
		
		private function cargoRecieved() : void {
			var _local7:int = 0;
			var _local4:Object = null;
			var _local3:String = null;
			var _local5:String = null;
			var _local1:ShopItemBar = null;
			var _local2:Array = body.obj.shopItems;
			if(_local2 == null || _local2.length == 0) {
				g.showErrorDialog(Localize.t("This weapon factory is not operational."));
				return;
			}
			var _local6:int = 0;
			_local7 = 0;
			while(_local7 < _local2.length) {
				_local4 = _local2[_local7];
				_local3 = _local4.item;
				_local5 = _local4.table;
				if(_local4.available) {
					_local1 = new ShopItemBar(g,infoContainer,_local4,fluxCost);
					_local1.x = 0;
					_local1.y = 60 * _local6;
					_local1.addEventListener("select",onSelect);
					_local1.addEventListener("bought",bought);
					shopItemBars.push(_local1);
					container.addChild(_local1);
					_local6++;
				}
				_local7++;
			}
			loadCompleted();
			g.tutorial.showShopAdvice();
		}
		
		private function onSelect(e:TouchEvent) : void {
			var _local2:ShopItemBar = e.target as ShopItemBar;
			for each(var _local3:* in shopItemBars) {
				if(_local3 != _local2) {
					_local3.deselect();
				}
			}
		}
		
		private function bought(e:Event) : void {
			for each(var _local2:* in shopItemBars) {
				_local2.update();
			}
			hasBought = true;
		}
		
		override public function exit(callback:Function) : void {
			if(hasBought) {
				g.tutorial.showChangeWeapon();
			}
			for each(var _local2:* in shopItemBars) {
				_local2.removeEventListener("bought",bought);
				_local2.removeEventListener("select",onSelect);
			}
			super.exit(callback);
		}
	}
}

