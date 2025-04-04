package startSetup {
import core.hud.components.Text;

import starling.display.Sprite;
import starling.display.Stage;

public interface IStartSetup {
    function get timer():Date;

    function get timeStart():int;

    function set timeStart(value:int):void;

    function get progressText():Text;

    function get sprite():Sprite;

    function get getStage():Stage;

    function get split():String;

    function set joinName(value:String):void;

    function get skin():String;

    function get pvp():Boolean;
}
}

