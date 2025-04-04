package core.clan {
import core.hud.components.ToolTip;
import core.player.Player;
import core.scene.Game;
import core.states.gameStates.ClanState;

import data.DataLocator;
import data.IDataManager;

import flash.geom.ColorTransform;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class PlayerClanLogo extends Sprite {
    public function PlayerClanLogo(g:Game, player:Player, callback:Function = null) {
        this.g = g;
        this.player = player;
        this.callback = callback;
        super();
        if (stage != null) {
            init();
        } else {
            addEventListener("addedToStage", init);
        }
    }
    private var g:Game;
    private var player:Player;
    private var callback:Function;

    override public function dispose():void {
        removeChildren(0, -1, true);
        removeEventListeners();
        ToolTip.disposeType("clan");
    }

    private function init(e:Event = null):void {
        var that:Sprite;
        var dataManager:IDataManager;
        removeEventListener("addedToStage", init);
        if (player.clanId == "") {
            if (callback != null) {
                callback(false);
            }
            return;
        }
        that = this;
        if (player.clanLogo != null) {
            addChild(player.clanLogo);
            if (callback != null) {
                callback();
            }
            return;
        }
        dataManager = DataLocator.getService();
        dataManager.loadKeyFromBigDB("Clans", player.clanId, function (param1:Object):void {
            if (stage == null) {
                return;
            }
            var _loc4_:ITextureManager = TextureLocator.getService();
            var _loc2_:Texture = _loc4_.getTextureGUIByTextureName(param1.logo);
            var _loc3_:ColorTransform = new ColorTransform();
            player.clanRankName = ClanState.getMemberRankName(param1, player.id);
            player.clanName = param1.name;
            player.clanLogo = new Image(_loc2_);
            new ToolTip(g, that, param1.name, null, "clan");
            player.clanLogo.scaleX = player.clanLogo.scaleY = 0.25;
            player.clanLogo.color = param1.color;
            player.clanLogoColor = param1.color;
            addChild(player.clanLogo);
            if (callback != null) {
                callback();
            }
        });
    }
}
}

