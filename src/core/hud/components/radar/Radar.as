package core.hud.components.radar {
	import core.GameObject;
	import core.boss.Boss;
	import core.drops.Drop;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Radar extends Sprite {
		public static const outerDetectionRadius:Number = 5000;
		public static const innerDetectionRadius:Number = 2500;
		private var unitsDetected:Number = 0;
		//private var scale:Number = 10;
		public var radius:Number = 60;
		private var textureManager:ITextureManager;
		private var g:Game;
		private var blips:Vector.<Blip> = new Vector.<Blip>();
		private var loaded:Boolean = false;
		private var blipBatch:MeshBatch = new MeshBatch();
		private var firstHalf:Boolean = true;
		private var quadBatch:MeshBatch = new MeshBatch();
		private var updateCount:int = 0;
		
		public function Radar(g:Game) {
			super();
			this.g = g;
			textureManager = TextureLocator.getService();
			touchable = false;
		}
		
		public function load() : void {
			var _local6:* = null;
			drawBackground();
			for each(var _local2:* in g.shipManager.enemies) {
				createBlip(_local2,_local7);
			}
			for each(var _local7:* in g.shipManager.players) {
				if(!_local7.player.isMe) {
					createBlip(_local7);
				}
			}
			for each(var _local4:* in g.spawnManager.spawners) {
				if(_local4.alive) {
					createBlip(_local4);
				}
			}
			for each(var _local3:* in g.bodyManager.bodies) {
				if(_local3.type == "planet" || _local3.type == "junk yard" || _local3.type == "warpGate" || _local3.type == "shop" || _local3.type == "pirate" || _local3.type == "research" || _local3.type == "comet" || _local3.type == "sun") {
					createBlip(_local3);
				}
			}
			for each(var _local1:* in g.dropManager.drops) {
				createBlip(_local1);
			}
			for each(var _local5:* in g.bossManager.bosses) {
				if(_local5.alive) {
					createBlip(_local5);
				}
			}
			drawCenter();
			addChild(quadBatch);
			loaded = true;
		}
		
		private function drawBackground() : void {
			var _local1:Image = new Image(textureManager.getTextureGUIByTextureName("radar_bg"));
			addChild(_local1);
		}
		
		private function drawCenter() : void {
			var _local1:Image = new Image(textureManager.getTextureGUIByTextureName("radar_player"));
			_local1.pivotX = _local1.pivotY = _local1.width / 2;
			_local1.x = 60;
			_local1.y = 60;
			addChild(_local1);
		}
		
		private function createBlip(go:GameObject, ps:PlayerShip = null) : void {
			var _local3:Blip = null;
			_local3 = new Blip(go,ps,g);
			blips.push(_local3);
		}
		
		public function add(go:GameObject) : void {
			var _local2:PlayerShip = null;
			if(!loaded) {
				return;
			}
			if(go is PlayerShip) {
				_local2 = go as PlayerShip;
				if(_local2.player.isMe) {
					return;
				}
			}
			createBlip(go);
		}
		
		public function remove(go:GameObject) : void {
			var _local2:Blip = null;
			var _local3:int = 0;
			if(!loaded || blips == null) {
				return;
			}
			while(_local3 < blips.length) {
				_local2 = blips[_local3];
				if(_local2.isGameObject(go)) {
					blips.splice(_local3,1);
					removeChild(_local2);
					_local2.dispose();
					return;
				}
				_local3++;
			}
		}
		
		public function update() : void {
			var _local2:Blip = null;
			var _local3:int = 0;
			if(g.me.ship == null || g.me.isLanded) {
				return;
			}
			updateCount++;
			if(updateCount < 4) {
				return;
			}
			updateCount = 0;
			quadBatch.clear();
			var _local1:int = int(blips.length);
			_local3 = 0;
			while(_local3 < _local1) {
				_local2 = blips[_local3];
				if(_local2.go.distanceToCamera <= 5000) {
					if(_local2.updateVisibility()) {
						quadBatch.addMesh(_local2);
					}
				}
				_local3++;
			}
		}
		
		public function inHostileZone() : Boolean {
			if(unitsDetected > 0) {
				return true;
			}
			return false;
		}
		
		override public function dispose() : void {
			for each(var _local1:* in blips) {
				_local1.dispose();
			}
			blips = null;
		}
	}
}

import core.GameObject;
import core.boss.Boss;
import core.drops.Drop;
import core.hud.components.Style;
import core.player.Player;
import core.scene.Game;
import core.ship.EnemyShip;
import core.ship.PlayerShip;
import core.solarSystem.Body;
import core.spawner.Spawner;
import starling.display.Image;
import starling.textures.Texture;
import textures.ITextureManager;
import textures.TextureLocator;

class Blip extends Image {
	private static const scale:Number = 10;
	public static var radarRadius:Number = 60;
	public var go:GameObject;
	private var blipWidth:Number;
	private var blipHeight:Number;
	private var radius:Number;
	private var g:Game;
	
	public function Blip(go:GameObject, ps:PlayerShip, g:Game) {
		var _local9:Texture = null;
		var _local4:* = 0;
		var _local8:EnemyShip = null;
		var _local7:Spawner = null;
		var _local6:Body = null;
		this.go = go;
		this.g = g;
		touchable = false;
		var _local5:ITextureManager = TextureLocator.getService();
		if(go is EnemyShip) {
			_local8 = go as EnemyShip;
			if(_local8.hasFaction("AF")) {
				_local4 = Style.COLOR_FRIENDLY;
				_local9 = _local5.getTextureGUIByTextureName("radar_player");
			} else {
				_local4 = 0xff4444;
				_local9 = _local5.getTextureGUIByTextureName("radar_enemy");
			}
		} else if(go is PlayerShip) {
			_local4 = Style.COLOR_FRIENDLY;
			_local9 = _local5.getTextureGUIByTextureName("radar_player");
		} else if(go is Spawner) {
			_local7 = go as Spawner;
			if(_local7.hasFaction("AF")) {
				_local4 = Style.COLOR_FRIENDLY;
				_local9 = _local5.getTextureGUIByTextureName("radar_comet");
			} else {
				_local4 = 0xff4444;
				_local9 = _local5.getTextureGUIByTextureName("radar_spawner");
			}
		} else if(go is Body) {
			_local6 = go as Body;
			if(_local6.type == "planet") {
				_local4 = 0x228822;
				_local9 = _local5.getTextureGUIByTextureName("radar_planet");
			} else if(_local6.type == "junk yard" || _local6.type == "warpGate" || _local6.type == "shop" || _local6.type == "pirate" || _local6.type == "research") {
				_local4 = 0xaaaaaa;
				_local9 = _local5.getTextureGUIByTextureName("radar_station");
			} else if(_local6.type == "comet") {
				_local4 = 0xaaaaff;
				_local9 = _local5.getTextureGUIByTextureName("radar_comet");
			} else if(_local6.type == "sun") {
				_local4 = 0xffdd88;
				_local9 = _local5.getTextureGUIByTextureName("radar_sun");
			}
		} else if(go is Drop) {
			_local9 = _local5.getTextureGUIByTextureName("radar_drop");
			_local4 = 0xeeeeee;
		} else if(go is Boss) {
			_local9 = _local5.getTextureGUIByTextureName("radar_boss");
			_local4 = 0xff4444;
		}
		super(_local9);
		color = _local4;
		blipWidth = width;
		blipHeight = height;
		radius = Math.sqrt(0.25 * blipWidth * blipWidth + 0.25 * blipHeight * blipHeight) - 1;
	}
	
	public function isGameObject(go:GameObject) : Boolean {
		if(this.go == go) {
			return true;
		}
		return false;
	}
	
	public function getGameObject() : GameObject {
		return go;
	}
	
	public function updateVisibility() : Boolean {
		var _local3:Spawner = null;
		var _local2:Boss = null;
		var _local6:PlayerShip = null;
		var _local1:Player = null;
		var _local5:EnemyShip = null;
		var _local4:Boolean = Boolean(setRadarPos());
		if(_local4) {
			visible = true;
			alpha = getRadarAlphaIndex();
			if(go is Spawner) {
				_local3 = go as Spawner;
				if(!_local3.alive) {
					visible = false;
				}
			} else if(go is Boss) {
				_local2 = go as Boss;
				if(!_local2.alive) {
					visible = false;
				}
			} else if(go is PlayerShip) {
				_local6 = go as PlayerShip;
				_local1 = _local6.player;
				if(_local6.player == g.me) {
					color = Style.COLOR_LIGHT_GREEN;
				} else if(g.isSystemTypeDeathMatch()) {
					color = Style.COLOR_HOSTILE;
				} else if(g.isSystemTypeDomination()) {
					color = _local1.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				} else if(g.isSystemPvPEnabled()) {
					color = _local1.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				} else {
					color = _local1.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
				}
			} else if(go is EnemyShip) {
				_local5 = go as EnemyShip;
				_local6 = _local5.owner;
				if(_local6 != null) {
					if(_local6 == g.me.ship) {
						color = Style.COLOR_LIGHT_GREEN;
					} else if(g.isSystemTypeDeathMatch()) {
						color = Style.COLOR_HOSTILE;
					} else if(g.isSystemTypeDomination()) {
						color = _local6.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
					} else if(g.isSystemPvPEnabled()) {
						color = _local6.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
					} else {
						color = _local6.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
					}
				}
			}
		} else {
			visible = false;
		}
		return visible;
	}
	
	private function setRadarPos(showOnEdge:Boolean = true) : Boolean {
		var _local4:Number = Number(go.distanceToCamera);
		var _local2:Number = Number(go.distanceToCameraX);
		var _local3:Number = Number(go.distanceToCameraY);
		if(_local4 >= 5000) {
			return false;
		}
		if(_local4 < 2500 - radius * scale) {
			_local2 /= 2500;
			_local3 /= 2500;
			x = _local2 * radarRadius + radarRadius - blipWidth / 2;
			y = _local3 * radarRadius + radarRadius - blipHeight / 2;
			return true;
		}
		if(showOnEdge) {
			_local2 /= _local4;
			_local3 /= _local4;
			_local2 *= radarRadius * scale - radius * scale;
			_local3 *= radarRadius * scale - radius * scale;
			x = _local2 / scale + radarRadius - blipWidth / 2;
			y = _local3 / scale + radarRadius - blipHeight / 2;
			return true;
		}
		return false;
	}
	
	private function getRadarAlphaIndex() : Number {
		var _local3:Number = 5000;
		var _local2:Number = 2500;
		var _local1:Number = Number(go.distanceToCamera);
		if(_local1 < _local3 && _local1 >= _local2) {
			return 1 - (_local1 - _local2) / (_local3 - _local2);
		}
		return 1;
	}
	
	override public function dispose() : void {
		go = null;
		texture.dispose();
		super.dispose();
	}
}
