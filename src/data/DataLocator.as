package data {
public class DataLocator {
    private static var service:IDataManager;

    public static function register(s:IDataManager):void {
        service = s;
    }

    public static function getService():IDataManager {
        return service;
    }

    public function DataLocator() {
        super();
    }
}
}

