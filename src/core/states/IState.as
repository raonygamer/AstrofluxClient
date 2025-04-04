package core.states {
public interface IState {
    function get type():String;

    function set stateMachine(sm:StateMachine):void;

    function enter():void;

    function execute():void;

    function exit():void;
}
}

