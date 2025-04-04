package joinRoom {
public class JoinRoomLocator {
    private static var service:IJoinRoomManager;

    public static function register(s:IJoinRoomManager):void {
        service = s;
    }

    public static function getService():IJoinRoomManager {
        return service;
    }

    public function JoinRoomLocator() {
        super();
    }
}
}

