package startSetup {
public class StartSetupLocator {
    private static var service:IStartSetup;

    public static function initialize():void {
    }

    public static function register(s:IStartSetup):void {
        service = s;
    }

    public static function getService():IStartSetup {
        return service;
    }

    public function StartSetupLocator() {
        super();
    }
}
}

