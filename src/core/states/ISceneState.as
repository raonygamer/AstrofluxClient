package core.states {
public interface ISceneState {
    function set stateMachine(sm:SceneStateMachine):void;

    function enter():void;

    function execute():void;

    function exit():void;
}
}

