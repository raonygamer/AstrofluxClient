package core.hud.components.pvp {
import core.hud.components.Text;
import core.scene.Game;
import core.states.gameStates.PvpScreenState;

import playerio.Message;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

import textures.TextureLocator;

public class DominationManager extends PvpManager {
    private const SCORE_LIMIT:Number = 1000;
    private const BAR_MAX_WIDTH:Number = 96;

    public function DominationManager(g:Game) {
        g.addMessageHandler("updateDominationStatus", m_updateDominationStatus);
        super(g, false);
        score.push(0);
        score.push(0);
        var _loc2_:Texture = TextureLocator.getService().getTextureGUIByTextureName("bullet_crew");
        blueZone1 = new Image(_loc2_);
        blueZone2 = new Image(_loc2_);
        blueZone3 = new Image(_loc2_);
        blueZone4 = new Image(_loc2_);
        blueZone5 = new Image(_loc2_);
        redZone1 = new Image(_loc2_);
        redZone2 = new Image(_loc2_);
        redZone3 = new Image(_loc2_);
        redZone4 = new Image(_loc2_);
        redZone5 = new Image(_loc2_);
        blueZone1.color = blueZone2.color = blueZone3.color = blueZone4.color = blueZone5.color = redZone1.color = redZone2.color = redZone3.color = redZone4.color = redZone5.color = 0x222222;
        blueZone1.y = blueZone2.y = blueZone3.y = blueZone4.y = blueZone5.y = redZone1.y = redZone2.y = redZone3.y = redZone4.y = redZone5.y = 26;
        blueZone1.x = -12;
        blueZone2.x = blueZone1.x - blueZone1.width - 4;
        blueZone3.x = blueZone2.x - blueZone2.width - 4;
        blueZone4.x = blueZone3.x - blueZone3.width - 4;
        blueZone5.x = blueZone4.x - blueZone4.width - 4;
        redZone1.x = 6;
        redZone2.x = redZone1.x + redZone1.width + 4;
        redZone3.x = redZone2.x + redZone2.width + 4;
        redZone4.x = redZone3.x + redZone3.width + 4;
        redZone5.x = redZone4.x + redZone4.width + 4;
        blueTeamBarBackground.x = blueTeamBarFill.x = -2;
        blueTeamBarFill.y = blueTeamBarBackground.y = 2;
        blueTeamBarBackground.pivotX = blueTeamBarBackground.width;
        blueTeamBar.pivotX = blueTeamBar.width;
        redTeamBarBackground.x = redTeamBarBackground.y = redTeamBarFill.x = redTeamBarFill.y = 2;
        scoreTextBlueTeam = new Text();
        scoreTextBlueTeam.color = 0xffffff;
        scoreTextBlueTeam.text = "0";
        scoreTextBlueTeam.alignRight();
        scoreTextBlueTeam.x = -2;
        scoreTextBlueTeam.y = 0;
        scoreTextBlueTeam.size = 16;
        scoreTextRedTeam = new Text();
        scoreTextRedTeam.color = 0xffffff;
        scoreTextRedTeam.htmlText = "0";
        scoreTextRedTeam.x = 2;
        scoreTextRedTeam.y = 0;
        scoreTextRedTeam.size = 16;
        timerText = new Text();
        timerText.color = 0xffffff;
        timerText.text = "x:xx";
        timerText.size = 16;
        timerText.color = 0x55ff55;
        container.addChild(timerText);
        container.addChild(blueTeamBar);
        container.addChild(blueTeamBarBackground);
        container.addChild(blueTeamBarFill);
        container.addChild(redTeamBar);
        container.addChild(redTeamBarBackground);
        container.addChild(redTeamBarFill);
        container.addChild(scoreTextRedTeam);
        container.addChild(scoreTextBlueTeam);
        container.addChild(blueZone1);
        container.addChild(blueZone2);
        container.addChild(blueZone3);
        container.addChild(blueZone4);
        container.addChild(blueZone5);
        container.addChild(redZone1);
        container.addChild(redZone2);
        container.addChild(redZone3);
        container.addChild(redZone4);
        container.addChild(redZone5);
        g.addChildToHud(container);
        resize();
    }
    public var zones:Vector.<DominationZone> = new Vector.<DominationZone>();
    public var safeZones:Vector.<TeamSafeZone> = new Vector.<TeamSafeZone>();
    private var score:Vector.<int> = new Vector.<int>();
    private var scoreTextBlueTeam:Text;
    private var scoreTextRedTeam:Text;
    private var blueTeamBar:Quad = new Quad(100, 24, 0x222222);
    private var blueTeamBarBackground:Quad = new Quad(96, 20, 0x222288);
    private var blueTeamBarFill:Quad = new Quad(1, 20, 0x4444ff);
    private var blueZone1:Image;
    private var blueZone2:Image;
    private var blueZone3:Image;
    private var blueZone4:Image;
    private var blueZone5:Image;
    private var redTeamBar:Quad = new Quad(100, 24, 0x222222);
    private var redTeamBarBackground:Quad = new Quad(96, 20, 0x880000);
    private var redTeamBarFill:Quad = new Quad(1, 20, 0xff4444);
    private var redZone1:Image;
    private var redZone2:Image;
    private var redZone3:Image;
    private var redZone4:Image;
    private var redZone5:Image;
    private var container:Sprite = new Sprite();
    private var id:int = 1;

    override public function update():void {
        var _loc2_:int = 0;
        var _loc4_:int = 0;
        if (!isLoaded) {
            loadMap();
        }
        if (requestTime < g.time && (roomStartTime == 0 || g.playerManager.players.length > scoreList.length)) {
            requestTime = g.time + 2000;
            g.send("requestInitPlayers");
        }
        map.update();
        switch (matchState) {
            case 0:
                if (timerText != null) {
                    timerText.htmlText = "Starting in: <FONT COLOR=\'#7777ff\'>" + formatTime((matchStartTime - g.time) / 1000) + "</FONT>";
                }
                if (matchStartTime != 0 && matchStartTime < g.time) {
                    matchState = 2;
                    g.textManager.createPvpText("The Match begins! Fight!", 0, 50);
                }
                for each(var _loc1_ in g.playerManager.players) {
                    _loc1_.inSafeZone = true;
                }
                break;
            case 2:
                if (timerText != null) {
                    timerText.text = formatTime((matchEndTime - g.time) / 1000).toString();
                }
                if (g.me != null) {
                    _loc2_ = 0;
                    _loc4_ = 0;
                    if (g.me.team == 0) {
                        _loc4_ = 0;
                        _loc2_ = 1;
                    } else {
                        _loc4_ = 1;
                        _loc2_ = 0;
                    }
                    if (scoreTextBlueTeam != null) {
                        blueTeamBarFill.width = score[_loc4_] / 1000 * 96;
                        blueTeamBarFill.x = -blueTeamBarFill.width - 2;
                        scoreTextBlueTeam.text = score[_loc4_].toString();
                    }
                    if (scoreTextRedTeam != null) {
                        redTeamBarFill.width = score[_loc2_] / 1000 * 96;
                        scoreTextRedTeam.text = score[_loc2_].toString();
                    }
                    for each(var _loc3_ in g.playerManager.players) {
                        _loc3_.inSafeZone = false;
                    }
                    for each(var _loc5_ in safeZones) {
                        _loc5_.updateZone();
                    }
                    if (zones.length > 4) {
                        if (zones[4].ownerTeam == _loc4_) {
                            blueZone5.color = 0x4444ff;
                            redZone5.color = 0x222222;
                        } else if (zones[4].ownerTeam == _loc2_) {
                            blueZone5.color = 0x222222;
                            redZone5.color = 0xff4444;
                        } else {
                            blueZone5.color = 0x222222;
                            redZone5.color = 0x222222;
                        }
                    }
                    if (zones.length > 3) {
                        if (zones[3].ownerTeam == _loc4_) {
                            blueZone4.color = 0x4444ff;
                            redZone4.color = 0x222222;
                        } else if (zones[3].ownerTeam == _loc2_) {
                            blueZone4.color = 0x222222;
                            redZone4.color = 0xff4444;
                        } else {
                            blueZone4.color = 0x222222;
                            redZone4.color = 0x222222;
                        }
                    }
                    if (zones[2].ownerTeam == _loc4_) {
                        blueZone1.color = 0x4444ff;
                        redZone1.color = 0x222222;
                    } else if (zones[2].ownerTeam == _loc2_) {
                        blueZone1.color = 0x222222;
                        redZone1.color = 0xff4444;
                    } else {
                        blueZone1.color = 0x222222;
                        redZone1.color = 0x222222;
                    }
                    if (zones[0].ownerTeam == _loc4_) {
                        blueZone2.color = 0x4444ff;
                        redZone2.color = 0x222222;
                    } else if (zones[0].ownerTeam == _loc2_) {
                        blueZone2.color = 0x222222;
                        redZone2.color = 0xff4444;
                    } else {
                        blueZone2.color = 0x222222;
                        redZone2.color = 0x222222;
                    }
                    if (zones[1].ownerTeam == _loc4_) {
                        blueZone3.color = 0x4444ff;
                        redZone3.color = 0x222222;
                    } else if (zones[1].ownerTeam == _loc2_) {
                        blueZone3.color = 0x222222;
                        redZone3.color = 0xff4444;
                    } else {
                        blueZone3.color = 0x222222;
                        redZone3.color = 0x222222;
                    }
                }
                break;
            case 3:
                if (timerText != null) {
                    timerText.htmlText = "Closing in: <FONT COLOR=\'#7777ff\'>" + formatTime((roomEndTime - g.time) / 1000) + "</FONT>";
                }
                if (endGameScreenTime != 0 && endGameScreenTime < g.time) {
                    g.enterState(new PvpScreenState(g));
                    endGameScreenTime = g.time + 60 * 1000;
                }
                break;
            case 4:
                if (timerText != null) {
                    timerText.htmlText = "Closing in: <FONT COLOR=\'#7777ff\'>" + formatTime((roomEndTime - g.time) / 1000) + "</FONT>";
                    break;
                }
        }
    }

    override public function addZones(items:Array):void {
        for each(var _loc2_ in items) {
            if (_loc2_.type == "dominationZone") {
                addZone(_loc2_);
            } else if (_loc2_.type == "safezoneT1") {
                addTeamZone(_loc2_, 0);
            } else if (_loc2_.type == "safezoneT2") {
                addTeamZone(_loc2_, 1);
            }
        }
        if (zones.length < 4) {
            blueZone4.visible = false;
            redZone4.visible = false;
        }
        if (zones.length < 5) {
            blueZone5.visible = false;
            redZone5.visible = false;
        }
    }

    override public function hideText():void {
    }

    override public function showText():void {
    }

    override protected function m_gameEnded(m:Message):void {
        var _loc6_:Number = NaN;
        var _loc5_:int = 0;
        var _loc3_:int = m.getInt(_loc5_++);
        matchEnded = true;
        matchEndTime = m.getNumber(_loc5_++);
        endGameScreenTime = matchEndTime + 5000;
        roomEndTime = m.getNumber(_loc5_++);
        saveScore(m, _loc5_);
        for each(var _loc2_ in g.playerManager.players) {
            if (_loc2_.ship != null) {
                _loc2_.ship.hp = _loc2_.ship.hpMax;
                _loc2_.ship.shieldHp = _loc2_.ship.shieldHpMax;
            }
        }
        if (_loc3_ == g.me.team) {
            g.textManager.createPvpText("The Match has Ended!", -50, 40, 0x5555ff);
            g.textManager.createPvpText("The blue team won!", 0, 40, 0x5555ff);
        } else {
            g.textManager.createPvpText("The Match has Ended!", -50, 40, 0xff5555);
            g.textManager.createPvpText("The blue team won!", 0, 40, 0xff5555);
        }
        Game.trackEvent("pvp", "pvp dom won", g.me.name, g.me.level);
        var _loc4_:PvpScoreHolder = getScoreHolder(g.me.id, g.me.name);
        if (_loc4_ == null) {
            return;
        }
        if (_loc4_.deaths == 0) {
            _loc6_ = _loc4_.kills * 2;
        } else {
            _loc6_ = _loc4_.kills / _loc4_.deaths;
        }
        g.enterState(new PvpScreenState(g));
        endGameScreenTime = g.time + 60 * 1000;
    }

    override protected function m_updateScore(m:Message):void {
        saveScore(m, 0);
    }

    public function getDZ(id:*):DominationZone {
        for each(var _loc2_ in zones) {
            if (_loc2_.id == id) {
                return _loc2_;
            }
        }
        return null;
    }

    protected function m_updateDominationStatus(m:Message):void {
        var _loc4_:int = 0;
        var _loc2_:DominationZone = null;
        var _loc3_:int = 0;
        matchState = m.getInt(_loc3_++);
        score[0] = m.getInt(_loc3_++);
        score[1] = m.getInt(_loc3_++);
        _loc3_;
        while (_loc3_ < m.length) {
            _loc4_ = m.getInt(_loc3_++);
            _loc2_ = getDZ(_loc4_);
            _loc2_.ownerTeam = m.getInt(_loc3_++);
            _loc2_.capCounter = m.getInt(_loc3_++);
            _loc2_.nrTeam[0] = m.getInt(_loc3_++);
            _loc2_.nrTeam[1] = m.getInt(_loc3_);
            _loc2_.updateZone();
            _loc3_++;
        }
    }

    private function addTeamZone(obj:Object, team:int):void {
        safeZones.push(new TeamSafeZone(g, obj, team));
    }

    private function addZone(obj:Object):void {
        zones.push(new DominationZone(g, obj, id));
        id += 1;
    }

    override public function resize(e:Event = null):void {
        container.y = 20;
        container.x = g.stage.stageWidth / 2;
        super.resize();
        if (timerText != null) {
            timerText.x = redTeamBarBackground.x + redTeamBarBackground.width + 5;
            timerText.y = 2;
        }
    }
}
}

