package core.hud.components {
	import generics.Util;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class TopPvPPlayersList extends Sprite {
		private static var topPvpPlayersList:Array;
		private var textureManager:ITextureManager;
		
		public function TopPvPPlayersList() {
			super();
			textureManager = TextureLocator.getService();
		}
		
		public function showHighscore(m:Message) : void {
			var _local3:int = 0;
			var _local2:Object = null;
			topPvpPlayersList = [];
			_local3 = 0;
			while(_local3 < m.length) {
				_local2 = {};
				_local2.rank = m.getInt(_local3);
				_local2.name = m.getString(_local3 + 1);
				_local2.key = m.getString(_local3 + 2);
				_local2.level = m.getInt(_local3 + 3);
				_local2.clan = m.getString(_local3 + 4);
				_local2.value = m.getNumber(_local3 + 5);
				topPvpPlayersList.push(_local2);
				_local3 += 6;
			}
			drawTopPvpPlayers();
		}
		
		private function drawTopPvpPlayers() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			_local2 = 0;
			while(_local2 < topPvpPlayersList.length) {
				drawPlayerObject(topPvpPlayersList[_local2],_local2,this);
				_local1 = int(topPvpPlayersList[_local2].rank);
				_local2++;
			}
		}
		
		private function drawPlayerObject(player:Object, i:int, canvas:Sprite) : void {
			var _local6:Quad = null;
			var _local8:Image = null;
			var _local10:int = i * 45;
			if(Login.client.connectUserId == player.key) {
				_local6 = new Quad(670,40,0x424242);
			} else {
				_local6 = new Quad(670,40,0x212121);
			}
			_local6.y = _local10;
			_local10 += 10;
			var _local4:TextBitmap = new TextBitmap();
			_local4.text = topPvpPlayersList[i].rank;
			_local4.size = 14;
			_local4.y = _local10;
			_local4.x = 10;
			var _local7:TextBitmap = new TextBitmap();
			_local7.text = player.name;
			_local7.y = _local10;
			_local7.size = 14;
			_local7.format.color = 0xff4444;
			_local7.x = _local4.x + _local4.width + 10;
			var _local5:TextBitmap = new TextBitmap();
			_local5.text = "(Lv. " + player.level + ")";
			_local5.y = _local10;
			_local5.size = 14;
			_local5.format.color = 0xff4444;
			_local5.x = _local7.x + _local7.width + 10;
			var _local9:TextBitmap = new TextBitmap();
			_local9.text = Util.formatAmount(Math.floor(player.value));
			_local9.y = _local10;
			_local9.size = 14;
			_local9.format.color = Style.COLOR_YELLOW;
			_local9.x = 610 - _local9.width - 10;
			_local8 = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
			_local8.y = _local10 + 20;
			_local8.color = 0xff0000;
			_local8.x = _local9.x + _local9.width + 10;
			_local8.scaleX = _local8.scaleY = 0.25;
			_local8.rotation = -0.5 * 3.141592653589793;
			canvas.addChild(_local6);
			canvas.addChild(_local4);
			canvas.addChild(_local7);
			canvas.addChild(_local5);
			canvas.addChild(_local9);
			canvas.addChild(_local8);
		}
	}
}

