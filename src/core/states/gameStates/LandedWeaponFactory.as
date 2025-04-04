package core.states.gameStates
{
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
	
	public class LandedWeaponFactory extends LandedState
	{
		private var shopItemBars:Vector.<ShopItemBar> = new Vector.<ShopItemBar>();
		private var myCargo:Cargo;
		private var container:ScrollContainer;
		private var infoContainer:Sprite = new Sprite();
		private var hasBought:Boolean = false;
		private var fluxCost:int;
		
		public function LandedWeaponFactory(g:Game, body:Body, startMusic:Boolean = true)
		{
			super(g,body,body.name);
			fluxCost = CreditManager.getCostWeaponFactory(body.obj.payVaultItem);
			myCargo = g.myCargo;
		}
		
		override public function enter() : void
		{
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
			var _loc1_:Text = new Text();
			_loc1_.text = body.name;
			_loc1_.size = 26;
			_loc1_.x = 60;
			_loc1_.y = 50;
			addChild(_loc1_);
			var _loc2_:Text = new Text();
			_loc2_.text = Localize.t("Produce a weapon with minerals or Flux.");
			_loc2_.color = 0xaaaaaa;
			_loc2_.x = 60;
			_loc2_.y = _loc1_.y + _loc1_.height + 10;
			addChild(_loc2_);
			cargoRecieved();
		}
		
		override public function execute() : void
		{
			super.execute();
		}
		
		private function cargoRecieved() : void
		{
			var _loc4_:int = 0;
			var _loc2_:Object = null;
			var _loc1_:String = null;
			var _loc6_:String = null;
			var _loc3_:ShopItemBar = null;
			var _loc7_:Array = body.obj.shopItems;
			if(_loc7_ == null || _loc7_.length == 0)
			{
				g.showErrorDialog(Localize.t("This weapon factory is not operational."));
				return;
			}
			var _loc5_:int = 0;
			_loc4_ = 0;
			while(_loc4_ < _loc7_.length)
			{
				_loc2_ = _loc7_[_loc4_];
				_loc1_ = _loc2_.item;
				_loc6_ = _loc2_.table;
				if(_loc2_.available)
				{
					_loc3_ = new ShopItemBar(g,infoContainer,_loc2_,fluxCost);
					_loc3_.x = 0;
					_loc3_.y = 60 * _loc5_;
					_loc3_.addEventListener("select",onSelect);
					_loc3_.addEventListener("bought",bought);
					shopItemBars.push(_loc3_);
					container.addChild(_loc3_);
					_loc5_++;
				}
				_loc4_++;
			}
			loadCompleted();
			g.tutorial.showShopAdvice();
		}
		
		private function onSelect(e:TouchEvent) : void
		{
			var _loc2_:ShopItemBar = e.target as ShopItemBar;
			for each(var _loc3_ in shopItemBars)
			{
				if(_loc3_ != _loc2_)
				{
					_loc3_.deselect();
				}
			}
		}
		
		private function bought(e:Event) : void
		{
			for each(var _loc2_ in shopItemBars)
			{
				_loc2_.update();
			}
			hasBought = true;
		}
		
		override public function exit(callback:Function) : void
		{
			if(hasBought)
			{
				g.tutorial.showChangeWeapon();
			}
			for each(var _loc2_ in shopItemBars)
			{
				_loc2_.removeEventListener("bought",bought);
				_loc2_.removeEventListener("select",onSelect);
			}
			super.exit(callback);
		}
	}
}

