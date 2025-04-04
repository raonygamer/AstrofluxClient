package core.states.ship {
import core.ship.PlayerShip;
import core.solarSystem.Body;
import core.states.IState;
import core.states.StateMachine;

public class LandedShip implements IState {
    public function LandedShip(ship:PlayerShip, body:Body) {
        super();
        this.ship = ship;
        this.body = body;
    }
    private var sm:StateMachine;
    private var ship:PlayerShip;
    private var body:Body;

    public function get type():String {
        return "Landed";
    }

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function enter():void {
        ship.land();
    }

    public function execute():void {
    }

    public function exit():void {
    }
}
}

