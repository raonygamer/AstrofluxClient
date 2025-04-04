package core.states {
public interface IGameState {
    function set stateMachine(sm:GameStateMachine):void;

    function get loaded():Boolean;

    function get unloaded():Boolean;

    function enter():void;

    function execute():void;

    function exit(callback:Function):void;

    function tickUpdate():void;

    function loadCompleted():void;

    function unloadCompleted():void;
}
}

