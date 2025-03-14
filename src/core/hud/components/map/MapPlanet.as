package core.hud.components.map {
	import core.controlZones.ControlZone;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.Style;
	import core.hud.components.ToolTip;
	import core.player.CrewMember;
	import core.player.LandedBody;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class MapPlanet extends MapBodyBase {
		public function MapPlanet(g:Game, container:Sprite, body:Body) {
			super(g,container,body);
			container.addChild(crew);
			container.addChild(text);
			container.addChild(percentage);
			layer.useHandCursor = true;
			addImage();
			addCrew();
			addTooltip();
			addOrbits();
			addText();
			init();
		}
		
		private function addImage() : void {
			if(body.texture == null) {
				return;
			}
			var _local2:Number = Map.SCALE * 1.5;
			radius = body.texture.width / 2 * _local2;
			if(radius < 4) {
				_local2 = 4 / (body.texture.width / 2);
			}
			radius = body.texture.width / 2 * _local2;
			var _local1:Image = new Image(body.texture);
			_local1.scaleX = _local2;
			_local1.scaleY = _local2;
			layer.addChild(_local1);
			imgHover = new Image(body.texture);
			imgHover.scaleX = _local2;
			imgHover.scaleY = _local2;
			imgHover.blendMode = "add";
			imgSelected = imgHover;
		}
		
		private function addCrew() : void {
			var _local1:Image = null;
			var _local3:int = 0;
			for each(var _local2:* in g.me.crewMembers) {
				if(_local2.body == body.key) {
					_local1 = new Image(_local2.texture);
					_local1.height *= 0.2;
					_local1.width *= 0.2;
					_local1.x = _local3 * (_local1.width + 4);
					crew.addChild(_local1);
					_local3++;
				}
			}
		}
		
		private function addTooltip() : void {
			var _local7:int = 0;
			var _local13:IDataManager = null;
			var _local3:Object = null;
			var _local12:ControlZone = null;
			var _local9:Number = NaN;
			var _local11:Boolean = false;
			for each(var _local10:* in g.me.landedBodies) {
				if(_local10.key == body.key) {
					_local11 = true;
					break;
				}
			}
			var _local2:String = "";
			if(!_local11) {
				_local2 = "Name: " + body.name + "\nAreas: Unknown";
				new ToolTip(g,layer,_local2,null,"Map",400);
				return;
			}
			var _local1:Array = [];
			var _local5:int = 0;
			var _local6:int = 0;
			_local2 += "Name: " + body.name + "\nAreas: ";
			for each(var _local8:* in body.obj.exploreAreas) {
				_local13 = DataLocator.getService();
				_local3 = _local13.loadKey("BodyAreas",_local8);
				if(_local3.skillLevel > 99) {
					_local7 = 34;
				} else {
					_local7 = 26;
				}
				_local2 += "\n<FONT COLOR=\'" + Area.COLORTYPESTR[_local3.majorType] + "\'> " + _local3.skillLevel + "      </FONT>";
				_local1.push({
					"img":CrewDisplayBox.IMAGES_SKILLS[_local3.majorType],
					"x":_local7,
					"y":38 + 19 * _local5
				});
				_local6 = 0;
				for each(var _local4:* in _local3.types) {
					_local6++;
					_local2 += "    ";
					_local1.push({
						"img":CrewDisplayBox.IMAGES_SPECIALS[_local4],
						"x":_local7 + _local6 * 18,
						"y":38 + 19 * _local5
					});
				}
				if(g.me.hasExploredArea(_local8)) {
					_local2 += "  Complete";
				} else {
					_local2 += "  Unexplored";
				}
				_local5++;
			}
			if(body.explorable && g.me.clanId != "" && g.isSystemTypeHostile()) {
				_local12 = g.controlZoneManager.getZoneByKey(body.key);
				if(_local12) {
					_local2 += "\n\n";
					_local2 += "Controlled by\n";
					_local2 += _local12.clanName + "\n";
					if(_local12.releaseTime > g.time) {
						_local9 = _local12.releaseTime - g.time;
						_local2 += "<FONT COLOR=\"#ff0000\">locked for " + Util.getFormattedTime(_local9) + "</FONT>\n";
					}
				}
			}
			new ToolTip(g,layer,_local2,_local1,"Map",400);
		}
		
		private function addText() : void {
			var _local4:ControlZone = null;
			if(!body.landable) {
				return;
			}
			text.size = 11;
			text.format.color = Style.COLOR_MAP_PLANET;
			text.text = body.name;
			if(body.explorable && g.me.clanId != "" && g.isSystemTypeHostile()) {
				_local4 = g.controlZoneManager.getZoneByKey(body.key);
				if(!_local4 || _local4.releaseTime < g.time) {
					text.format.color = Style.COLOR_LIGHT_GREEN;
				}
			}
			var _local2:int = 0;
			var _local3:int = 0;
			for each(var _local1:* in body.obj.exploreAreas) {
				if(g.me.hasExploredArea(_local1)) {
					_local3++;
				}
				_local2++;
			}
			if(_local2 > 0) {
				percentage.size = 11;
				percentage.format.color = Style.COLOR_BYLINE;
				percentage.text = Math.floor(_local3 / _local2 * 100).toString() + "%";
			}
		}
	}
}

