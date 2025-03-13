package core.hud.components.credits {
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class CreditDayItem extends CreditBaseItem {
		public static var PRICE_1_DAY:int = 75;
		public static var PRICE_3_DAY:int = 215;
		public static var PRICE_7_DAY:int = 425;
		protected var buyContainer:Sprite = new Sprite();
		protected var descriptionContainer:Sprite = new Sprite();
		protected var aquiredContainer:Sprite = new Sprite();
		protected var waitingContainer:Sprite = new Sprite();
		protected var description:String;
		protected var confirmText:String = "";
		protected var preview:String;
		protected var aquiredText:Text = new Text();
		protected var expiryTime:Number;
		protected var aquired:Boolean = false;
		protected var bundles:Array = [];
		
		public function CreditDayItem(g:Game, parent:Sprite) {
			super(g,parent);
		}
		
		override protected function load() : void {
			super.load();
			infoContainer.x = 40;
			addBuyOptions();
			addDescription();
			addAquired();
			addWaiting();
			updateAquiredText();
			updateContainers();
		}
		
		protected function addBuyOptions() : void {
			var _local4:int = 0;
			var _local2:Object = null;
			var _local1:CreditLabel = null;
			var _local5:int = 0;
			var _local3:int = 0;
			_local4 = 0;
			while(_local4 < bundles.length) {
				_local2 = bundles[_local4];
				_local3 = 40 * _local4;
				createButton(_local2,_local3);
				_local1 = new CreditLabel();
				_local1.x = 170;
				_local1.y = _local3;
				_local1.text = _local2.cost;
				_local1.alignRight();
				buyContainer.addChild(_local1);
				_local4++;
			}
			buyContainer.x = 30;
			infoContainer.addChild(buyContainer);
		}
		
		private function createButton(obj:Object, y:int) : void {
			var button:Button;
			var text:String = "Buy " + obj.days + " day";
			if(obj.days > 1) {
				text += "s";
			}
			button = new Button(function():void {
				var buyConfirm:CreditBuyBox = new CreditBuyBox(g,obj.cost,confirmText);
				buyConfirm.addEventListener("accept",function():void {
					onBuy(obj.days);
					buyConfirm.removeEventListeners();
					button.enabled = true;
				});
				buyConfirm.addEventListener("close",function():void {
					buyConfirm.removeEventListeners();
					button.enabled = true;
				});
				g.addChildToOverlay(buyConfirm);
			},text,"positive");
			button.x = 20;
			button.y = y;
			button.width = 100;
			button.alignWithText();
			buyContainer.addChild(button);
		}
		
		protected function addDescription() : void {
			var _local3:int = 0;
			var _local2:Image = null;
			var _local4:Quad = null;
			var _local1:Text = new Text();
			_local1.text = description;
			_local1.color = 0xaaaaaa;
			_local1.width = 5 * 60;
			_local1.height = 5 * 60;
			_local1.wordWrap = true;
			descriptionContainer.addChild(_local1);
			if(preview != null) {
				_local3 = 4;
				_local2 = new Image(textureManager.getTextureGUIByTextureName(preview));
				_local2.x = 4;
				_local2.y = _local1.height + 10;
				_local4 = new Quad(_local2.width + 6,_local2.height + 6,0xaaaaaa);
				_local4.x = _local2.x - 3;
				_local4.y = _local2.y - 3;
				descriptionContainer.addChild(_local4);
				descriptionContainer.addChild(_local2);
			}
			descriptionContainer.y = 130;
			infoContainer.addChild(descriptionContainer);
		}
		
		protected function addWaiting() : void {
			var _local1:Text = new Text();
			_local1.text = "waiting...";
			_local1.x = 60;
			_local1.y = 40;
			waitingContainer.addChild(_local1);
			waitingContainer.visible = false;
			infoContainer.addChild(waitingContainer);
		}
		
		protected function addAquired() : void {
			aquiredText.x = 0;
			aquiredText.y = 40;
			aquiredText.color = Style.COLOR_HIGHLIGHT;
			aquiredText.wordWrap = true;
			aquiredText.width = 5 * 60;
			aquiredContainer.addChild(aquiredText);
			aquiredContainer.visible = false;
			infoContainer.addChild(aquiredContainer);
		}
		
		protected function updateContainers() : void {
			buyContainer.visible = !aquired;
			aquiredContainer.visible = aquired;
			waitingContainer.visible = false;
		}
		
		protected function onBuy(days:int) : void {
			buyContainer.visible = false;
			waitingContainer.visible = true;
		}
		
		protected function updateAquiredText() : void {
			var _local2:Number = NaN;
			var _local1:Date = null;
			if(aquired) {
				_local2 = expiryTime - g.time;
				_local1 = new Date();
				_local1.milliseconds += _local2;
				aquiredText.text = "Aquired!\nActive until: " + _local1.toLocaleDateString();
			}
		}
		
		protected function showFailed(s:String) : void {
			g.showErrorDialog(s);
			buyContainer.visible = true;
			waitingContainer.visible = false;
		}
	}
}

