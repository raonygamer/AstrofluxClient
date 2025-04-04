package core.hud.components.chat {
import core.hud.components.ToolTip;
import core.scene.Game;

import feathers.controls.ScrollContainer;
import feathers.layout.HorizontalLayout;

import starling.display.Image;
import starling.events.TouchEvent;

import textures.ITextureManager;
import textures.TextureLocator;

public class PlayerChatOptions extends ScrollContainer {
    public function PlayerChatOptions(g:Game, obj:Object) {
        super();
        this.g = g;
        this.obj = obj;
        var _loc3_:HorizontalLayout = new HorizontalLayout();
        _loc3_.paddingLeft = 10;
        _loc3_.paddingTop = 5;
        _loc3_.paddingBottom = 10;
        _loc3_.gap = 15;
        this.layout = _loc3_;
        var _loc4_:ITextureManager = TextureLocator.getService();
        muteImage = new Image(_loc4_.getTextureGUIByTextureName("mute"));
        muteImage.addEventListener("touch", onMute);
        muteImage.useHandCursor = true;
        addChild(muteImage);
        new ToolTip(g, muteImage, "mute player", null, "PlayerChatOptions");
        messageImage = new Image(_loc4_.getTextureGUIByTextureName("chat_pm"));
        messageImage.addEventListener("touch", onPrivateMessage);
        messageImage.useHandCursor = true;
        addChild(messageImage);
        new ToolTip(g, messageImage, "send private message", null, "PlayerChatOptions");
        if (g.me.isModerator || g.me.isDeveloper) {
            banImage = new Image(_loc4_.getTextureGUIByTextureName("chat_ban"));
            banImage.addEventListener("touch", onSilence);
            banImage.useHandCursor = true;
            addChild(banImage);
            new ToolTip(g, banImage, "silence player", null, "PlayerChatOptions");
        }
    }
    private var g:Game;
    private var obj:Object;
    private var muteImage:Image;
    private var messageImage:Image;
    private var banImage:Image;

    override public function dispose():void {
        muteImage.removeEventListeners();
        messageImage.removeEventListeners();
        if (banImage) {
            banImage.removeEventListeners();
        }
        ToolTip.disposeType("PlayerChatOptions");
        super.dispose();
    }

    private function onMute(e:TouchEvent):void {
        if (e.getTouch(muteImage, "ended")) {
            g.sendToServiceRoom("chatMsg", "ignore", obj.playerName);
            g.messageLog.removePlayerMessages(obj.playerKey);
        }
    }

    private function onPrivateMessage(e:TouchEvent):void {
        if (e.getTouch(messageImage, "ended")) {
            g.chatInput.setText("/w " + obj.playerName + " ");
        }
    }

    private function onSilence(e:TouchEvent):void {
        if (e.getTouch(banImage, "ended")) {
            g.chatInput.setText("/silence " + obj.playerKey + " ");
        }
    }
}
}

