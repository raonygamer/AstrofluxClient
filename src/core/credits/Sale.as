package core.credits {
import core.scene.Game;

public class Sale {
    public function Sale(g:Game) {
        super();
        this.g = g;
    }
    public var type:String;
    public var startTime:Number;
    public var endTime:Number;
    public var normalPrice:int;
    public var salePrice:int;
    public var saleBonus:int;
    public var key:String;
    public var vaultKey:String;
    public var description:String;
    private var g:Game;

    public function isNow():Boolean {
        if (g.time > startTime && g.time < endTime) {
            return true;
        }
        return false;
    }
}
}

