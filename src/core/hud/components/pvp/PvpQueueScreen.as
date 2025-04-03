package core.hud.components.pvp
{
	import core.hud.components.Box;
	import core.hud.components.ButtonQueue;
	import core.hud.components.Text;
	import core.scene.Game;
	import generics.Localize;
	
	public class PvpQueueScreen extends PvpScreen
	{
		private var buttons:Vector.<ButtonQueue> = new Vector.<ButtonQueue>();
		
		public function PvpQueueScreen(g:Game)
		{
			super(g);
		}
		
		override public function load() : void
		{
			var _loc3_:Number = NaN;
			var _loc1_:ButtonQueue = null;
			super.load();
			var _loc2_:int = -70;
			var _loc4_:Box = new Box(620,80,"light",0.75,20);
			_loc4_.x = 65;
			_loc4_.y = 92;
			addChild(_loc4_);
			_loc4_ = new Box(620,148,"light",0.75,20);
			_loc4_.x = 65;
			_loc4_.y = _loc2_ + 305;
			addChild(_loc4_);
			_loc4_ = new Box(620,88,"light",0.75,20);
			_loc4_.x = 65;
			_loc4_.y = _loc2_ + 516;
			addChild(_loc4_);
			var _loc5_:Text = new Text();
			_loc5_.size = 22;
			_loc5_.color = 0x55ff55;
			_loc5_.x = 175;
			_loc5_.y = 35;
			_loc5_.htmlText = Localize.t("Player Vs Player Combat");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 16;
			_loc5_.color = 0x88ff88;
			_loc5_.x = 55;
			_loc5_.y = 82;
			_loc5_.htmlText = Localize.t("Your PvP statistics:");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0xaaaaaa;
			_loc5_.x = 60;
			_loc5_.y = 112;
			_loc5_.htmlText = Localize.t("Name: \nRank: \nPvP Troons:");
			_loc5_.height = 150;
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0xaaaaaa;
			_loc5_.x = 6 * 60;
			_loc5_.y = 112;
			_loc5_.htmlText = Localize.t("PvP kills: \nPvP deaths: \nK/D Ratio:");
			_loc5_.height = 150;
			addChild(_loc5_);
			if(g.me.playerDeaths == 0)
			{
				_loc3_ = 0;
			}
			else
			{
				_loc3_ = g.me.playerKills / g.me.playerDeaths;
			}
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0xffffff;
			_loc5_.x = 250;
			_loc5_.y = 112;
			_loc5_.htmlText = g.me.name + "\nxxx" + "\n" + g.me.troons + "\n";
			_loc5_.alignLeft();
			_loc5_.height = 150;
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0xffffff;
			_loc5_.x = 550;
			_loc5_.y = 112;
			_loc5_.htmlText = g.me.playerKills + "\n" + g.me.playerDeaths + "\n" + _loc3_.toPrecision(2);
			_loc5_.alignLeft();
			_loc5_.height = 150;
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 16;
			_loc5_.color = 0x88ff88;
			_loc5_.x = 55;
			_loc5_.y = _loc2_ + 295;
			_loc5_.htmlText = Localize.t("Normal PvP Matches:");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0x55ff55;
			_loc5_.x = 270;
			_loc5_.y = _loc2_ + 330;
			_loc5_.htmlText = Localize.t("Random PvP Match");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0x55ff55;
			_loc5_.x = 270;
			_loc5_.y = _loc2_ + 365;
			_loc5_.htmlText = Localize.t("Domination Team-PvP");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0x55ff55;
			_loc5_.x = 270;
			_loc5_.y = _loc2_ + 400;
			_loc5_.htmlText = Localize.t("Deathmatch");
			addChild(_loc5_);
			_loc5_ = new Text();
			_loc5_.size = 14;
			_loc5_.color = 0x55ff55;
			_loc5_.x = 270;
			_loc5_.y = _loc2_ + 435;
			_loc5_.htmlText = Localize.t("Arena");
			addChild(_loc5_);
			_loc1_ = new ButtonQueue(g,"pvp random",g.queueManager.getQueue("pvp random"),false);
			_loc1_.x = 60;
			_loc1_.y = _loc2_ + 328;
			addChild(_loc1_);
			buttons.push(_loc1_);
			_loc1_ = new ButtonQueue(g,"pvp dom",g.queueManager.getQueue("pvp dom"));
			_loc1_.x = 60;
			_loc1_.y = _loc2_ + 363;
			addChild(_loc1_);
			buttons.push(_loc1_);
			_loc1_ = new ButtonQueue(g,"pvp dm",g.queueManager.getQueue("pvp dm"));
			_loc1_.x = 60;
			_loc1_.y = _loc2_ + 398;
			addChild(_loc1_);
			buttons.push(_loc1_);
			_loc1_ = new ButtonQueue(g,"pvp arena",g.queueManager.getQueue("pvp arena"),false);
			_loc1_.x = 60;
			_loc1_.y = _loc2_ + 433;
			addChild(_loc1_);
			buttons.push(_loc1_);
		}
		
		override public function update() : void
		{
			for each(var _loc1_ in buttons)
			{
				_loc1_.update();
			}
		}
	}
}

