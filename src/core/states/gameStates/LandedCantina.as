package core.states.gameStates {
import core.hud.components.CrewDetails;
import core.hud.components.CrewDisplayBoxNew;
import core.player.CrewMember;
import core.scene.Game;
import core.solarSystem.Body;

import feathers.controls.ScrollContainer;

import playerio.Message;

import starling.events.Event;

public class LandedCantina extends LandedState {
    public static var WIDTH:Number = 698;

    public function LandedCantina(g:Game, body:Body) {
        super(g, body, body.name);
    }
    private var mainBody:ScrollContainer;
    private var selectedCrewMember:CrewDetails;
    private var crewMembers:Vector.<CrewMember>;
    private var crew:Vector.<CrewDisplayBoxNew> = new Vector.<CrewDisplayBoxNew>();

    override public function enter():void {
        super.enter();
        g.rpc("getCantinaCrew", onGetCantinaCrew);
    }

    override public function execute():void {
        super.execute();
    }

    override public function exit(callback:Function):void {
        mainBody.removeEventListener("reloadDetails", onReloadDetails);
        mainBody.removeEventListener("crewSelected", setActive);
        super.exit(callback);
    }

    public function reloadDetails(forceRefresh:Boolean = false):void {
        if (!selectedCrewMember) {
            return;
        }
        var _loc2_:CrewDetails = new CrewDetails(g, selectedCrewMember.crewMember, reloadDetails, false, 1);
        _loc2_.requestRemovalCallback = removeActiveCrewMember;
        _loc2_.x = selectedCrewMember.x;
        _loc2_.y = selectedCrewMember.y;
        removeChild(selectedCrewMember);
        selectedCrewMember = _loc2_;
        addChild(selectedCrewMember);
    }

    private function onReloadDetails():void {
        reloadDetails();
    }

    private function removeActiveCrewMember(cd:CrewDetails):void {
        var _loc3_:int = 0;
        var _loc2_:CrewDisplayBoxNew = null;
        removeChild(cd);
        _loc3_ = 0;
        while (_loc3_ < mainBody.numChildren) {
            if (mainBody.getChildAt(_loc3_) is CrewDisplayBoxNew) {
                _loc2_ = mainBody.getChildAt(_loc3_) as CrewDisplayBoxNew;
                if (_loc2_.crewMember.seed == cd.crewMember.seed) {
                    mainBody.removeChild(_loc2_);
                }
            }
            _loc3_++;
        }
    }

    private function onGetCantinaCrew(m:Message):void {
        var _loc4_:CrewMember = null;
        var _loc2_:Array = null;
        var _loc3_:Array = null;
        crewMembers = new Vector.<CrewMember>();
        var _loc5_:int = 0;
        var _loc6_:int = m.getInt(_loc5_++);
        while (_loc5_ < m.length) {
            _loc4_ = new CrewMember(g);
            _loc4_.seed = m.getInt(_loc5_++);
            _loc4_.key = m.getString(_loc5_++);
            _loc4_.name = m.getString(_loc5_++);
            _loc4_.solarSystem = m.getString(_loc5_++);
            _loc4_.area = m.getString(_loc5_++);
            _loc4_.body = m.getString(_loc5_++);
            _loc4_.imageKey = m.getString(_loc5_++);
            _loc4_.injuryEnd = m.getNumber(_loc5_++);
            _loc4_.injuryStart = m.getNumber(_loc5_++);
            _loc4_.trainingEnd = m.getNumber(_loc5_++);
            _loc4_.trainingType = m.getInt(_loc5_++);
            _loc4_.artifactEnd = m.getNumber(_loc5_++);
            _loc4_.artifact = m.getString(_loc5_++);
            _loc4_.missions = m.getInt(_loc5_++);
            _loc4_.successMissions = m.getInt(_loc5_++);
            _loc4_.rank = m.getInt(_loc5_++);
            _loc4_.fullLocation = m.getString(_loc5_++);
            _loc4_.skillPoints = m.getInt(_loc5_++);
            _loc2_ = [];
            _loc2_.push(m.getNumber(_loc5_++));
            _loc2_.push(m.getNumber(_loc5_++));
            _loc2_.push(m.getNumber(_loc5_++));
            _loc4_.skills = _loc2_;
            _loc3_ = [];
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc3_.push(m.getNumber(_loc5_++));
            _loc4_.specials = _loc3_;
            crewMembers.push(_loc4_);
        }
        load();
    }

    private function load():void {
        var _loc1_:CrewDisplayBoxNew = null;
        mainBody = new ScrollContainer();
        mainBody.width = WIDTH;
        mainBody.height = 450;
        mainBody.x = 0;
        mainBody.y = 35;
        mainBody.addEventListener("reloadDetails", onReloadDetails);
        mainBody.addEventListener("crewSelected", setActive);
        var _loc5_:int = 0;
        var _loc3_:int = 60;
        var _loc2_:int = 330;
        var _loc6_:int = 25;
        for each(var _loc4_ in crewMembers) {
            _loc1_ = new CrewDisplayBoxNew(g, _loc4_, 1);
            _loc1_.x = _loc3_;
            _loc1_.y = _loc6_;
            _loc6_ += _loc1_.height + 10;
            _loc5_++;
            mainBody.addChild(_loc1_);
            crew.push(_loc1_);
        }
        addChild(mainBody);
        loadCompleted();
    }

    public function setActive(e:Event):void {
        var _loc2_:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
        if (selectedCrewMember != null) {
            removeChild(selectedCrewMember);
        }
        selectedCrewMember = new CrewDetails(g, _loc2_.crewMember, reloadDetails, false, 1);
        selectedCrewMember.requestRemovalCallback = removeActiveCrewMember;
        addChild(selectedCrewMember);
        selectedCrewMember.x = 350;
        selectedCrewMember.y = 53;
    }
}
}

