package io {
import core.scene.Game;

public class InputLocator {
    private static var input:IInput;

    public static function register(i:IInput):void {
        input = i;
    }

    public static function getService():IInput {
        return input;
    }

    public function InputLocator(g:Game) {
        super();
    }
}
}

