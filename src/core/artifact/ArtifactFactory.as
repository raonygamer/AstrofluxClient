package core.artifact
{
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	
	public class ArtifactFactory
	{
		public function ArtifactFactory()
		{
			super();
		}
		
		public static function createArtifact(key:String, g:Game, p:Player, callback:Function) : void
		{
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeyFromBigDB("Artifacts",key,function(param1:DatabaseObject):void
			{
				if(param1 == null)
				{
					callback(null);
					return;
				}
				var _loc2_:Artifact = new Artifact(param1);
				callback(_loc2_);
			});
		}
		
		public static function createArtifacts(keys:Array, g:Game, p:Player, callback:Function) : void
		{
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeysFromBigDB("Artifacts",keys,function(param1:Array):void
			{
				var _loc2_:Artifact = null;
				try
				{
					for each(var _loc3_ in param1)
					{
						if(_loc3_ != null)
						{
							_loc2_ = new Artifact(_loc3_);
							p.artifacts.push(_loc2_);
						}
					}
				}
				catch(e:Error)
				{
					g.client.errorLog.writeError(e.toString(),"Something went wrong when loading artifacts, pid: " + p.id,e.getStackTrace(),{});
				}
				callback();
			});
		}
		
		public static function createArtifactFromSkin(skin:Object) : Artifact
		{
			var _loc2_:Artifact = new Artifact({});
			var _loc3_:Object = skin.specials;
			_loc2_.name = "skin artifact";
			_loc2_.stats.push(new ArtifactStat("corrosiveAdd",_loc3_["corrosiveAdd"]));
			_loc2_.stats.push(new ArtifactStat("corrosiveMulti",_loc3_["corrosiveMulti"]));
			_loc2_.stats.push(new ArtifactStat("energyAdd",_loc3_["energyAdd"]));
			_loc2_.stats.push(new ArtifactStat("energyMulti",_loc3_["energyMulti"]));
			_loc2_.stats.push(new ArtifactStat("kineticAdd",_loc3_["kineticAdd"]));
			_loc2_.stats.push(new ArtifactStat("kineticMulti",_loc3_["kineticMulti"]));
			_loc2_.stats.push(new ArtifactStat("speed",_loc3_["speed"] / 2));
			_loc2_.stats.push(new ArtifactStat("refire",_loc3_["refire"]));
			_loc2_.stats.push(new ArtifactStat("cooldown",_loc3_["cooldown"]));
			_loc2_.stats.push(new ArtifactStat("powerMax",_loc3_["powerMax"] / 1.5));
			_loc2_.stats.push(new ArtifactStat("powerReg",_loc3_["powerReg"] / 1.5));
			return _loc2_;
		}
	}
}

