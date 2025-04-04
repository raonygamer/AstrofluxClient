package core.hud.components.shipMenu {
import core.credits.CreditManager;
import core.hud.components.PriceCommodities;
import core.hud.components.ToolTip;
import core.hud.components.dialogs.PopupBuyMessage;
import core.player.Player;
import core.scene.Game;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class CrewSelector extends Sprite {
    public function CrewSelector(g:Game, p:Player) {
        this.g = g;
        this.p = p;
        super();
        var textureManager:textures.ITextureManager = TextureLocator.getService();
        load();
    }
    private var g:Game;
    private var p:Player;
    private var icons:Vector.<MenuSelectIcon> = new Vector.<MenuSelectIcon>();

    override public function dispose():void {
        for each(var _loc1_ in icons) {
            if (contains(_loc1_)) {
                removeChild(_loc1_, true);
            }
        }
        icons = null;
        super.dispose();
    }

    public function refresh():void {
        for each(var _loc1_ in icons) {
            if (contains(_loc1_)) {
                removeChild(_loc1_, true);
            }
        }
        icons = new Vector.<MenuSelectIcon>();
        dispatchEventWith("refresh");
        load();
    }

    private function load():void {
        var _loc1_:String = null;
        var _loc3_:int = 0;
        var _loc4_:ITextureManager = TextureLocator.getService();
        for each(var _loc2_ in p.crewMembers) {
            _loc1_ = "Crew member: " + _loc2_.name;
            createCrewIcon(_loc3_, _loc4_.getTextureGUIByKey(_loc2_.imageKey), "slot_crew.png", false, true, true, _loc1_);
            _loc3_++;
        }
        _loc3_;
        while (_loc3_ < p.unlockedCrewSlots) {
            _loc1_ = "Unlocked crew slot";
            createCrewIcon(_loc3_, null, "slot_crew.png", false, false, true, _loc1_);
            _loc3_++;
        }
        if (_loc3_ < 5) {
            _loc1_ = "Locked crew slow, click to buy this slot";
            createCrewIcon(_loc3_, null, "slot_crew.png", true, false, true, _loc1_);
            _loc3_++;
        }
        _loc3_;
        while (_loc3_ < 5) {
            _loc1_ = "Locked crew slot";
            createCrewIcon(_loc3_, null, "slot_crew.png", true, false, false, _loc1_);
            _loc3_++;
        }
    }

    private function createCrewIcon(number:int, txt:Texture, type:String, locked:Boolean = true, inUse:Boolean = false, enabled:Boolean = false, tooltip:String = null):void {
        var crewIcon:MenuSelectIcon = new MenuSelectIcon(number + 1, txt, type, locked, inUse, enabled);
        crewIcon.x = number * (60);
        if (tooltip != null) {
            new ToolTip(g, crewIcon, tooltip, null, "HomeState");
        }
        if (!locked) {
            crewIcon.addEventListener("touch", function (param1:TouchEvent):void {
                if (param1.getTouch(crewIcon, "ended")) {
                    dispatchEventWith("crewSelected");
                }
            });
        } else if (locked && enabled) {
            crewIcon.addEventListener("touch", function (param1:TouchEvent):void {
                if (param1.getTouch(crewIcon, "ended")) {
                    openUnlockSlot(crewIcon.number);
                }
            });
        }
        addChild(crewIcon);
        icons.push(crewIcon);
    }

    private function openUnlockSlot(number:int):void {
        var fluxCost:int;
        var unlockCost:int = int(Player.SLOT_CREW_UNLOCK_COST[number - 1]);
        var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
        buyBox.text = "Crew Slot";
        if (number < 4) {
            buyBox.addCost(new PriceCommodities(g, "flpbTKautkC1QzjWT28gkw", unlockCost));
        }
        fluxCost = CreditManager.getCostCrewSlot(number);
        if (fluxCost > 0) {
            buyBox.addBuyForFluxButton(fluxCost, number, "buyCrewSlotWithFlux", "Are you sure you want to buy a crew slot?");
            buyBox.addEventListener("fluxBuy", function (param1:Event):void {
                Game.trackEvent("used flux", "bought crew slot", "number " + number, fluxCost);
                p.unlockedCrewSlots = number;
                g.removeChildFromOverlay(buyBox, true);
                refresh();
            });
        }
        buyBox.addEventListener("accept", function (param1:Event):void {
            var e:Event = param1;
            g.me.tryUnlockSlot("slotCrew", number, function ():void {
                g.removeChildFromOverlay(buyBox, true);
                refresh();
            });
        });
        buyBox.addEventListener("close", function (param1:Event):void {
            g.removeChildFromOverlay(buyBox, true);
        });
        g.addChildToOverlay(buyBox);
    }
}
}

