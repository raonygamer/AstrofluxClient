package core.hud.components.radar {
import core.GameObject;
import core.scene.Game;
import core.ship.PlayerShip;

import starling.display.Image;
import starling.display.MeshBatch;
import starling.display.Sprite;

import textures.ITextureManager;
import textures.TextureLocator;

public class Radar extends Sprite {
    public static const outerDetectionRadius:Number = 5000;
    public static const innerDetectionRadius:Number = 2500;

    public function Radar(g:Game) {
        super();
        this.g = g;
        textureManager = TextureLocator.getService();
        touchable = false;
    }
    public var radius:Number = 60;
    private var scale:Number = 10;
    private var textureManager:ITextureManager;
    private var g:Game;
    private var blips:Vector.<Blip> = new Vector.<Blip>();
    private var loaded:Boolean = false;
    private var blipBatch:MeshBatch = new MeshBatch();
    private var firstHalf:Boolean = true;
    private var quadBatch:MeshBatch = new MeshBatch();
    private var updateCount:int = 0;

    override public function dispose():void {
        for each(var _loc1_ in blips) {
            _loc1_.dispose();
        }
        blips = null;
    }

    public function load():void {
        var _loc7_:* = null;
        drawBackground();
        for each(var _loc6_ in g.shipManager.enemies) {
            createBlip(_loc6_, _loc2_);
        }
        for each(var _loc2_ in g.shipManager.players) {
            if (!_loc2_.player.isMe) {
                createBlip(_loc2_);
            }
        }
        for each(var _loc3_ in g.spawnManager.spawners) {
            if (_loc3_.alive) {
                createBlip(_loc3_);
            }
        }
        for each(var _loc1_ in g.bodyManager.bodies) {
            if (_loc1_.type == "planet" || _loc1_.type == "junk yard" || _loc1_.type == "warpGate" || _loc1_.type == "shop" || _loc1_.type == "pirate" || _loc1_.type == "research" || _loc1_.type == "comet" || _loc1_.type == "sun") {
                createBlip(_loc1_);
            }
        }
        for each(var _loc5_ in g.dropManager.drops) {
            createBlip(_loc5_);
        }
        for each(var _loc4_ in g.bossManager.bosses) {
            if (_loc4_.alive) {
                createBlip(_loc4_);
            }
        }
        drawCenter();
        addChild(quadBatch);
        loaded = true;
    }

    public function add(go:GameObject):void {
        var _loc2_:PlayerShip = null;
        if (!loaded) {
            return;
        }
        if (go is PlayerShip) {
            _loc2_ = go as PlayerShip;
            if (_loc2_.player.isMe) {
                return;
            }
        }
        createBlip(go);
    }

    public function remove(go:GameObject):void {
        var _loc3_:Blip = null;
        var _loc2_:int = 0;
        if (!loaded || blips == null) {
            return;
        }
        while (_loc2_ < blips.length) {
            _loc3_ = blips[_loc2_];
            if (_loc3_.isGameObject(go)) {
                blips.splice(_loc2_, 1);
                removeChild(_loc3_);
                _loc3_.dispose();
                return;
            }
            _loc2_++;
        }
    }

    public function update():void {
        var _loc3_:Blip = null;
        var _loc1_:int = 0;
        if (g.me.ship == null || g.me.isLanded) {
            return;
        }
        updateCount++;
        if (updateCount < 4) {
            return;
        }
        updateCount = 0;
        quadBatch.clear();
        var _loc2_:int = int(blips.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            _loc3_ = blips[_loc1_];
            if (_loc3_.go.distanceToCamera <= 5000) {
                if (_loc3_.updateVisibility()) {
                    quadBatch.addMesh(_loc3_);
                }
            }
            _loc1_++;
        }
    }

    public function inHostileZone():Boolean {
        var unitsDetected:Number = 0;
        if (unitsDetected > 0) {
            return true;
        }
        return false;
    }

    private function drawBackground():void {
        var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("radar_bg"));
        addChild(_loc1_);
    }

    private function drawCenter():void {
        var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("radar_player"));
        _loc1_.pivotX = _loc1_.pivotY = _loc1_.width / 2;
        _loc1_.x = 60;
        _loc1_.y = 60;
        addChild(_loc1_);
    }

    private function createBlip(go:GameObject, ps:PlayerShip = null):void {
        var _loc3_:Blip = null;
        _loc3_ = new Blip(go, ps, g);
        blips.push(_loc3_);
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

    public function Blip(go:GameObject, ps:PlayerShip, g:Game) {
        var _loc4_:Texture = null;
        var _loc7_:* = 0;
        var _loc9_:EnemyShip = null;
        var _loc6_:Spawner = null;
        var _loc5_:Body = null;
        this.go = go;
        this.g = g;
        touchable = false;
        var _loc8_:ITextureManager = TextureLocator.getService();
        if (go is EnemyShip) {
            _loc9_ = go as EnemyShip;
            if (_loc9_.hasFaction("AF")) {
                _loc7_ = Style.COLOR_FRIENDLY;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_player");
            } else {
                _loc7_ = 0xff4444;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_enemy");
            }
        } else if (go is PlayerShip) {
            _loc7_ = Style.COLOR_FRIENDLY;
            _loc4_ = _loc8_.getTextureGUIByTextureName("radar_player");
        } else if (go is Spawner) {
            _loc6_ = go as Spawner;
            if (_loc6_.hasFaction("AF")) {
                _loc7_ = Style.COLOR_FRIENDLY;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_comet");
            } else {
                _loc7_ = 0xff4444;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_spawner");
            }
        } else if (go is Body) {
            _loc5_ = go as Body;
            if (_loc5_.type == "planet") {
                _loc7_ = 0x228822;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_planet");
            } else if (_loc5_.type == "junk yard" || _loc5_.type == "warpGate" || _loc5_.type == "shop" || _loc5_.type == "pirate" || _loc5_.type == "research") {
                _loc7_ = 0xaaaaaa;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_station");
            } else if (_loc5_.type == "comet") {
                _loc7_ = 0xaaaaff;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_comet");
            } else if (_loc5_.type == "sun") {
                _loc7_ = 0xffdd88;
                _loc4_ = _loc8_.getTextureGUIByTextureName("radar_sun");
            }
        } else if (go is Drop) {
            _loc4_ = _loc8_.getTextureGUIByTextureName("radar_drop");
            _loc7_ = 0xeeeeee;
        } else if (go is Boss) {
            _loc4_ = _loc8_.getTextureGUIByTextureName("radar_boss");
            _loc7_ = 0xff4444;
        }
        super(_loc4_);
        color = _loc7_;
        blipWidth = width;
        blipHeight = height;
        radius = Math.sqrt(0.25 * blipWidth * blipWidth + 0.25 * blipHeight * blipHeight) - 1;
    }
    public var go:GameObject;
    private var blipWidth:Number;
    private var blipHeight:Number;
    private var radius:Number;
    private var g:Game;

    override public function dispose():void {
        go = null;
        texture.dispose();
        super.dispose();
    }

    public function isGameObject(go:GameObject):Boolean {
        if (this.go == go) {
            return true;
        }
        return false;
    }

    public function getGameObject():GameObject {
        return go;
    }

    public function updateVisibility():Boolean {
        var _loc2_:Spawner = null;
        var _loc1_:Boss = null;
        var _loc3_:PlayerShip = null;
        var _loc6_:Player = null;
        var _loc5_:EnemyShip = null;
        var _loc4_:Boolean = Boolean(setRadarPos());
        if (_loc4_) {
            visible = true;
            alpha = getRadarAlphaIndex();
            if (go is Spawner) {
                _loc2_ = go as Spawner;
                if (!_loc2_.alive) {
                    visible = false;
                }
            } else if (go is Boss) {
                _loc1_ = go as Boss;
                if (!_loc1_.alive) {
                    visible = false;
                }
            } else if (go is PlayerShip) {
                _loc3_ = go as PlayerShip;
                _loc6_ = _loc3_.player;
                if (_loc3_.player == g.me) {
                    color = Style.COLOR_LIGHT_GREEN;
                } else if (g.isSystemTypeDeathMatch()) {
                    color = Style.COLOR_HOSTILE;
                } else if (g.isSystemTypeDomination()) {
                    color = _loc6_.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
                } else if (g.isSystemPvPEnabled()) {
                    color = _loc6_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
                } else {
                    color = _loc6_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
                }
            } else if (go is EnemyShip) {
                _loc5_ = go as EnemyShip;
                _loc3_ = _loc5_.owner;
                if (_loc3_ != null) {
                    if (_loc3_ == g.me.ship) {
                        color = Style.COLOR_LIGHT_GREEN;
                    } else if (g.isSystemTypeDeathMatch()) {
                        color = Style.COLOR_HOSTILE;
                    } else if (g.isSystemTypeDomination()) {
                        color = _loc3_.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
                    } else if (g.isSystemPvPEnabled()) {
                        color = _loc3_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
                    } else {
                        color = _loc3_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
                    }
                }
            }
        } else {
            visible = false;
        }
        return visible;
    }

    private function setRadarPos(showOnEdge:Boolean = true):Boolean {
        var _loc4_:Number = Number(go.distanceToCamera);
        var _loc2_:Number = Number(go.distanceToCameraX);
        var _loc3_:Number = Number(go.distanceToCameraY);
        if (_loc4_ >= 5000) {
            return false;
        }
        if (_loc4_ < 2500 - radius * scale) {
            _loc2_ /= 2500;
            _loc3_ /= 2500;
            x = _loc2_ * radarRadius + radarRadius - blipWidth / 2;
            y = _loc3_ * radarRadius + radarRadius - blipHeight / 2;
            return true;
        }
        if (showOnEdge) {
            _loc2_ /= _loc4_;
            _loc3_ /= _loc4_;
            _loc2_ *= radarRadius * scale - radius * scale;
            _loc3_ *= radarRadius * scale - radius * scale;
            x = _loc2_ / scale + radarRadius - blipWidth / 2;
            y = _loc3_ / scale + radarRadius - blipHeight / 2;
            return true;
        }
        return false;
    }

    private function getRadarAlphaIndex():Number {
        var _loc3_:Number = 5000;
        var _loc1_:Number = 2500;
        var _loc2_:Number = Number(go.distanceToCamera);
        if (_loc2_ < _loc3_ && _loc2_ >= _loc1_) {
            return 1 - (_loc2_ - _loc1_) / (_loc3_ - _loc1_);
        }
        return 1;
    }
}
