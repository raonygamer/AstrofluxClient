package core.states {
public interface IDisplayState {
    function get type():String;

    function set stateMachine(sm:DisplayStateMachine):void;

    function enter():void;

    function execute():void;

    function exit():void;
}
}

