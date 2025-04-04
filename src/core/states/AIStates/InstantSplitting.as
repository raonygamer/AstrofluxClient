package core.states.AIStates {
import core.hud.components.BeamLine;
import core.projectile.Projectile;
import core.scene.Game;
import core.states.IState;
import core.states.StateMachine;

public class InstantSplitting implements IState {
    public function InstantSplitting(g:Game, p:Projectile, color:uint, glowColor:uint, thickness:Number, alpha:Number, aiMaxNrOfLines:int, aiBranchingFactor:int, aiSplitChance:Number) {
        super();
        this.g = g;
        this.p = p;
        this.color = color;
        this.glowColor = glowColor;
        this.alpha = alpha;
        this.thickness = thickness;
        this.splitChance = aiSplitChance;
        this.branchingFactor = aiBranchingFactor;
        this.maxNrOfLines = aiMaxNrOfLines;
        if (p.isHeal || p.unit.factions.length > 0) {
            this.isEnemy = false;
        } else {
            this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
        }
    }
    protected var g:Game;
    protected var p:Projectile;
    private var sm:StateMachine;
    private var isEnemy:Boolean;
    private var color:uint;
    private var thickness:Number;
    private var alpha:Number;
    private var maxNrOfLines:int;
    private var glowColor:uint;
    private var branchingFactor:int;
    private var splitChance:Number;
    private var lines:Vector.<BeamLine> = new Vector.<BeamLine>();

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function get type():String {
        return "InstantSplitting";
    }

    public function enter():void {
        var _loc1_:BeamLine = null;
        _loc1_ = g.beamLinePool.getLine();
        _loc1_.init(thickness, 1, 0, color, alpha, 3, glowColor);
        lines.push(_loc1_);
        g.canvasEffects.addChild(_loc1_);
    }

    public function execute():void {
        if (p.alive) {
            for each(var _loc1_ in lines) {
                _loc1_.x = p.pos.x;
                _loc1_.y = p.pos.y;
                _loc1_.lineTo(p.pos.x + Math.cos(p.rotation) * 200, p.pos.y + Math.sin(p.rotation) * 200);
                _loc1_.alpha = alpha * p.ttl / p.ttlMax;
                _loc1_.visible = true;
            }
        } else {
            for each(_loc1_ in lines) {
                _loc1_.visible = false;
                _loc1_.clear();
                g.canvasEffects.removeChild(_loc1_);
            }
            lines = new Vector.<BeamLine>();
        }
    }

    public function exit():void {
    }
}
}

