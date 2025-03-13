package core.hud.components.pvp {
	import core.hud.components.Box;
	import core.hud.components.ButtonQueue;
	import core.hud.components.Text;
	import core.scene.Game;
	import generics.Localize;
	
	public class PvpQueueScreen extends PvpScreen {
		private var buttons:Vector.<ButtonQueue> = new Vector.<ButtonQueue>();
		
		public function PvpQueueScreen(g:Game) {
			super(g);
		}
		
		override public function load() : void {
			var _local3:Number = NaN;
			var _local2:ButtonQueue = null;
			super.load();
			var _local5:int = -70;
			var _local4:Box = new Box(620,80,"light",0.75,20);
			_local4.x = 65;
			_local4.y = 92;
			addChild(_local4);
			_local4 = new Box(620,148,"light",0.75,20);
			_local4.x = 65;
			_local4.y = _local5 + 305;
			addChild(_local4);
			_local4 = new Box(620,88,"light",0.75,20);
			_local4.x = 65;
			_local4.y = _local5 + 516;
			addChild(_local4);
			var _local1:Text = new Text();
			_local1.size = 22;
			_local1.color = 0x55ff55;
			_local1.x = 175;
			_local1.y = 35;
			_local1.htmlText = Localize.t("Player Vs Player Combat");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 16;
			_local1.color = 0x88ff88;
			_local1.x = 55;
			_local1.y = 82;
			_local1.htmlText = Localize.t("Your PvP statistics:");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0xaaaaaa;
			_local1.x = 60;
			_local1.y = 112;
			_local1.htmlText = Localize.t("Name: \nRank: \nPvP Troons:");
			_local1.height = 150;
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0xaaaaaa;
			_local1.x = 6 * 60;
			_local1.y = 112;
			_local1.htmlText = Localize.t("PvP kills: \nPvP deaths: \nK/D Ratio:");
			_local1.height = 150;
			addChild(_local1);
			if(g.me.playerDeaths == 0) {
				_local3 = 0;
			} else {
				_local3 = g.me.playerKills / g.me.playerDeaths;
			}
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0xffffff;
			_local1.x = 250;
			_local1.y = 112;
			_local1.htmlText = g.me.name + "\nxxx" + "\n" + g.me.troons + "\n";
			_local1.alignLeft();
			_local1.height = 150;
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0xffffff;
			_local1.x = 550;
			_local1.y = 112;
			_local1.htmlText = g.me.playerKills + "\n" + g.me.playerDeaths + "\n" + _local3.toPrecision(2);
			_local1.alignLeft();
			_local1.height = 150;
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 16;
			_local1.color = 0x88ff88;
			_local1.x = 55;
			_local1.y = _local5 + 295;
			_local1.htmlText = Localize.t("Normal PvP Matches:");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0x55ff55;
			_local1.x = 270;
			_local1.y = _local5 + 330;
			_local1.htmlText = Localize.t("Random PvP Match");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0x55ff55;
			_local1.x = 270;
			_local1.y = _local5 + 365;
			_local1.htmlText = Localize.t("Domination Team-PvP");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0x55ff55;
			_local1.x = 270;
			_local1.y = _local5 + 400;
			_local1.htmlText = Localize.t("Deathmatch");
			addChild(_local1);
			_local1 = new Text();
			_local1.size = 14;
			_local1.color = 0x55ff55;
			_local1.x = 270;
			_local1.y = _local5 + 435;
			_local1.htmlText = Localize.t("Arena");
			addChild(_local1);
			_local2 = new ButtonQueue(g,"pvp random",g.queueManager.getQueue("pvp random"),false);
			_local2.x = 60;
			_local2.y = _local5 + 328;
			addChild(_local2);
			buttons.push(_local2);
			_local2 = new ButtonQueue(g,"pvp dom",g.queueManager.getQueue("pvp dom"));
			_local2.x = 60;
			_local2.y = _local5 + 363;
			addChild(_local2);
			buttons.push(_local2);
			_local2 = new ButtonQueue(g,"pvp dm",g.queueManager.getQueue("pvp dm"));
			_local2.x = 60;
			_local2.y = _local5 + 398;
			addChild(_local2);
			buttons.push(_local2);
			_local2 = new ButtonQueue(g,"pvp arena",g.queueManager.getQueue("pvp arena"),false);
			_local2.x = 60;
			_local2.y = _local5 + 433;
			addChild(_local2);
			buttons.push(_local2);
		}
		
		override public function update() : void {
			for each(var _local1 in buttons) {
				_local1.update();
			}
		}
	}
}

