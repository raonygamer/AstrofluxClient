package core.player {
	public class TechSkill {
		public var tech:String;
		public var table:String;
		public var level:int;
		public var name:String;
		public var activeEliteTech:String;
		public var activeEliteTechLevel:int;
		public var eliteTechs:Vector.<EliteTechSkill> = new Vector.<EliteTechSkill>();
		
		public function TechSkill(name:String = "", tech:String = "", table:String = "", level:int = 0, activeEliteTech:String = "", activeEliteTechLevel:int = 0) {
			super();
			this.name = name;
			this.tech = tech;
			this.table = table;
			this.level = level;
			this.activeEliteTech = activeEliteTech;
			this.activeEliteTechLevel = activeEliteTechLevel;
		}
		
		public function setData(d:Object) : void {
			name = d.name;
			tech = d.tech;
			table = d.table;
			level = d.level;
		}
		
		public function addEliteTechData(eliteTech:String, eliteTechLevel:int) : void {
			var _local4:Boolean = false;
			for each(var _local3 in eliteTechs) {
				if(_local3.eliteTech == eliteTech) {
					_local3.eliteTechLevel = eliteTechLevel;
					_local4 = true;
				}
			}
			if(!_local4) {
				eliteTechs.push(new EliteTechSkill(eliteTech,eliteTechLevel));
			}
		}
	}
}

