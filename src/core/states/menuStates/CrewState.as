package core.states.menuStates
{
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import feathers.controls.ScrollContainer;
	
	public class CrewState extends DisplayState
	{
		public static var WIDTH:Number = 698;
		
		public static var PADDING:Number = 31;
		
		private var p:Player;
		
		private var mainBody:ScrollContainer;
		
		private var crew:Vector.<CrewDisplayBox> = new Vector.<CrewDisplayBox>();
		
		public function CrewState(g:Game)
		{
			super(g,HomeState);
			this.p = g.me;
		}
		
		override public function enter() : void
		{
			super.enter();
			var _loc1_:TextBitmap = new TextBitmap();
			_loc1_.size = 24;
			_loc1_.format.color = 0xffffff;
			_loc1_.text = "Crew";
			_loc1_.x = 60;
			_loc1_.y = 50;
			addChild(_loc1_);
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 4;
			mainBody.y = 95;
			addChild(mainBody);
			load();
		}
		
		override public function execute() : void
		{
			for each(var _loc1_ in crew)
			{
				_loc1_.update();
			}
		}
		
		public function refresh() : void
		{
			for each(var _loc1_ in crew)
			{
				if(mainBody.contains(_loc1_))
				{
					mainBody.removeChild(_loc1_);
				}
			}
			crew = new Vector.<CrewDisplayBox>();
			load();
		}
		
		private function load() : void
		{
			var _loc2_:CrewDisplayBox = null;
			var _loc1_:Vector.<CrewMember> = g.me.crewMembers;
			super.backButton.visible = false;
			var _loc6_:int = 0;
			var _loc4_:int = 70;
			var _loc3_:int = 330;
			var _loc7_:int = 28;
			for each(var _loc5_ in _loc1_)
			{
				_loc2_ = new CrewDisplayBox(g,_loc5_,null,p,false,this);
				_loc2_.x = _loc4_;
				_loc2_.y = _loc7_;
				if(_loc6_ % 2 == 0)
				{
					_loc4_ += _loc3_;
				}
				else
				{
					_loc4_ -= _loc3_;
					_loc7_ += _loc2_.height + 40;
				}
				_loc6_++;
				mainBody.addChild(_loc2_);
				crew.push(_loc2_);
			}
		}
	}
}

