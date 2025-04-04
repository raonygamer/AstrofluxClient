package core.states.AIStates {
import core.scene.Game;
import core.ship.EnemyShip;
import core.states.IState;
import core.states.StateMachine;

public class AIExit implements IState {
    public function AIExit(g:Game, s:EnemyShip) {
        super();
        this.g = g;
        this.s = s;
    }
    private var g:Game;
    private var s:EnemyShip;
    private var sm:StateMachine;
    private var endTime:Number;

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function get type():String {
        return "AIExit";
    }

    public function enter():void {
        endTime = g.time + 1000;
    }

    public function execute():void {
        s.engine.stop();
        s.alpha = (endTime - g.time) / 1000;
        if (endTime < g.time) {
            s.clearConvergeTarget();
            s.alive = false;
            s.explosionEffect = "";
            s.destroy(false);
            s.clearConvergeTarget();

        }
    }

    public function exit():void {
    }
}
}

