package core.states.menuStates {
import core.hud.components.CrewBuySlot;
import core.hud.components.CrewDetails;
import core.hud.components.CrewDisplayBoxNew;
import core.player.CrewMember;
import core.player.Player;
import core.scene.Game;
import core.states.DisplayState;

import feathers.controls.ScrollContainer;

import starling.events.Event;

public class CrewStateNew extends DisplayState {
    public static var WIDTH:Number = 698;

    public function CrewStateNew(g:Game) {
        super(g, HomeState);
        this.p = g.me;
    }
    private var p:Player;
    private var mainBody:ScrollContainer;
    private var selectedCrewMember:CrewDetails;
    private var crew:Vector.<CrewDisplayBoxNew> = new Vector.<CrewDisplayBoxNew>();

    override public function enter():void {
        super.enter();
        mainBody = new ScrollContainer();
        mainBody.width = WIDTH;
        mainBody.height = 450;
        mainBody.x = 0;
        mainBody.y = 35;
        addChild(mainBody);
        container.addEventListener("reloadDetails", onReloadDetails);
        container.addEventListener("crewSelected", setActive);
        load();
    }

    override public function execute():void {
    }

    override public function exit():void {
        container.removeEventListener("reloadDetails", onReloadDetails);
        container.removeEventListener("crewSelected", setActive);
        super.exit();
    }

    public function refresh():void {
        for each(var _loc1_ in crew) {
            if (mainBody.contains(_loc1_)) {
                mainBody.removeChild(_loc1_);
            }
        }
        crew = new Vector.<CrewDisplayBoxNew>();
        load();
    }

    public function reloadDetails(forceRefresh:Boolean = false):void {
        if (!selectedCrewMember) {
            return;
        }
        var _loc2_:CrewDetails = new CrewDetails(g, selectedCrewMember.crewMember, reloadDetails);
        _loc2_.x = selectedCrewMember.x;
        _loc2_.y = selectedCrewMember.y;
        removeChild(selectedCrewMember);
        selectedCrewMember = _loc2_;
        addChild(selectedCrewMember);
        if (!forceRefresh) {
            return;
        }
        if (selectedCrewMember != null) {
            removeChild(selectedCrewMember);
        }
        refresh();
    }

    private function load():void {
        var _loc2_:CrewDisplayBoxNew = null;
        var _loc3_:CrewBuySlot = null;
        var _loc1_:Vector.<CrewMember> = g.me.crewMembers;
        super.backButton.visible = false;
        var _loc7_:int = 0;
        var _loc5_:int = 60;
        var _loc4_:int = 330;
        var _loc8_:int = 25;
        for each(var _loc6_ in _loc1_) {
            _loc2_ = new CrewDisplayBoxNew(g, _loc6_, 0);
            _loc2_.x = _loc5_;
            _loc2_.y = _loc8_;
            _loc8_ += _loc2_.height + 10;
            _loc7_++;
            mainBody.addChild(_loc2_);
            crew.push(_loc2_);
        }
        if (_loc1_.length < 4) {
            _loc3_ = new CrewBuySlot(g);
            _loc3_.x = _loc5_;
            _loc3_.y = _loc8_;
            mainBody.addChild(_loc3_);
        }
    }

    public function setActive(e:Event):void {
        var _loc2_:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
        if (selectedCrewMember != null) {
            removeChild(selectedCrewMember);
        }
        if (_loc2_ == null) {
            selectedCrewMember = new CrewDetails(g, null);
            addChild(selectedCrewMember);
            selectedCrewMember.x = 350;
            selectedCrewMember.y = 53;
        } else {
            selectedCrewMember = new CrewDetails(g, _loc2_.crewMember, reloadDetails);
            addChild(selectedCrewMember);
            selectedCrewMember.x = 350;
            selectedCrewMember.y = 53;
        }
    }

    private function onReloadDetails(e:Event):void {
        reloadDetails();
    }
}
}

