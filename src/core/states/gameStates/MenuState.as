package core.states.gameStates {
import core.hud.MenuHud;
import core.scene.Game;
import core.states.menuStates.ArtifactState2;
import core.states.menuStates.CargoState;
import core.states.menuStates.EncounterState;
import core.states.menuStates.HomeState;

public class MenuState extends PlayState {
    public function MenuState(g:Game, menuState:Class) {
        this.menuState = menuState;
        super(g);
    }
    private var menuHud:MenuHud;
    private var menuState:Class;

    override public function enter():void {
        super.enter();
        drawBlackBackground();
        menuHud = new MenuHud(g, sm.revertState);
        menuHud.load(menuState, function ():void {
            addChild(menuHud);
            loadCompleted();
            g.hud.show = false;
        });
    }

    override public function execute():void {
        updateInput();
        menuHud.update();
        super.execute();
    }

    private function updateInput():void {
        if (!loaded) {
            return;
        }
        checkAccelerate(true);
        if (menuHud.stateMachine.inState(CargoState) && keybinds.isInputPressed(7) || !g.blockHotkeys && menuHud.stateMachine.inState(HomeState) && keybinds.isInputPressed(2) || !g.blockHotkeys && menuHud.stateMachine.inState(ArtifactState2) && keybinds.isInputPressed(3) || !g.blockHotkeys && menuHud.stateMachine.inState(EncounterState) && keybinds.isInputPressed(4) || !g.blockHotkeys && keybinds.isEscPressed) {
            sm.revertState();
            menuHud.unload();
        }
    }
}
}

