package sound {
public class SoundLocator {
    private static var service:ISound;

    public static function register(s:ISound):void {
        service = s;
    }

    public static function getService():ISound {
        return service;
    }

    public function SoundLocator() {
        super();
    }
}
}

