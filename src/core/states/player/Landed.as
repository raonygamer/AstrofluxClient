package core.states.player {
import core.player.Player;
import core.scene.Game;
import core.solarSystem.Body;
import core.states.IState;
import core.states.StateMachine;
import core.states.ship.LandedShip;

import debug.Console;

public class Landed implements IState {
    public function Landed(player:Player, body:Body, g:Game) {
        super();
        Console.write("Player state: Landed");
        this.g = g;
        this.player = player;
        this.body = body;
    }
    private var player:Player;
    private var body:Body;
    private var sm:StateMachine;
    private var g:Game;

    public function get type():String {
        return "Landed";
    }

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function enter():void {
        player.currentBody = body;
        if (player.ship == null || player.ship.stateMachine == null) {
            return;
        }
        player.ship.stateMachine.changeState(new LandedShip(player.ship, body));
    }

    public function execute():void {
    }

    public function exit():void {
        player.lastBody = player.currentBody;
        player.currentBody = null;
    }

    private function updateInput():void {
    }
}
}

