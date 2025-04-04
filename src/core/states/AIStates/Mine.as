package core.states.AIStates {
import core.projectile.Projectile;
import core.scene.Game;
import core.states.IState;
import core.states.StateMachine;

public class Mine implements IState {
    public function Mine(g:Game, p:Projectile, delay:int) {
        super();
        this.g = g;
        this.p = p;
        this.delay = delay;
    }
    private var g:Game;
    private var p:Projectile;
    private var sm:StateMachine;
    private var activateTime:Number;
    private var delay:int;
    private var activated:Boolean = false;

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function get type():String {
        return "Mine";
    }

    public function enter():void {
        activateTime = g.time + delay;
        if (activateTime > g.time) {
            p.disable();
            activated = false;
        }
    }

    public function execute():void {
        p.updateHeading(p.course);
        if (!activated && activateTime < g.time) {
            p.activate();
            activated = true;
        }
    }

    public function exit():void {
    }
}
}

