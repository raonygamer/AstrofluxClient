package core.artifact {
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	
	public class ArtifactFactory {
		public function ArtifactFactory() {
			super();
		}
		
		public static function createArtifact(key:String, g:Game, p:Player, callback:Function) : void {
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeyFromBigDB("Artifacts",key,function(param1:DatabaseObject):void {
				if(param1 == null) {
					callback(null);
					return;
				}
				var _local2:Artifact = new Artifact(param1);
				callback(_local2);
			});
		}
		
		public static function createArtifacts(keys:Array, g:Game, p:Player, callback:Function) : void {
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeysFromBigDB("Artifacts",keys,function(param1:Array):void {
				var _local2:Artifact = null;
				try {
					for each(var _local3 in param1) {
						if(_local3 != null) {
							_local2 = new Artifact(_local3);
							p.artifacts.push(_local2);
						}
					}
				}
				catch(e:Error) {
					g.client.errorLog.writeError(e.toString(),"Something went wrong when loading artifacts, pid: " + p.id,e.getStackTrace(),{});
				}
				callback();
			});
		}
		
		public static function createArtifactFromSkin(skin:Object) : Artifact {
			var _local3:Artifact = new Artifact({});
			var _local2:Object = skin.specials;
			_local3.name = "skin artifact";
			_local3.stats.push(new ArtifactStat("corrosiveAdd",_local2["corrosiveAdd"]));
			_local3.stats.push(new ArtifactStat("corrosiveMulti",_local2["corrosiveMulti"]));
			_local3.stats.push(new ArtifactStat("energyAdd",_local2["energyAdd"]));
			_local3.stats.push(new ArtifactStat("energyMulti",_local2["energyMulti"]));
			_local3.stats.push(new ArtifactStat("kineticAdd",_local2["kineticAdd"]));
			_local3.stats.push(new ArtifactStat("kineticMulti",_local2["kineticMulti"]));
			_local3.stats.push(new ArtifactStat("speed",_local2["speed"] / 2));
			_local3.stats.push(new ArtifactStat("refire",_local2["refire"]));
			_local3.stats.push(new ArtifactStat("cooldown",_local2["cooldown"]));
			_local3.stats.push(new ArtifactStat("powerMax",_local2["powerMax"] / 1.5));
			_local3.stats.push(new ArtifactStat("powerReg",_local2["powerReg"] / 1.5));
			return _local3;
		}
	}
}

