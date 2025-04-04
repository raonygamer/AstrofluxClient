package core.hud.components {
import core.queue.QueueInfoHolder;
import core.scene.Game;

import starling.display.Sprite;
import starling.events.TouchEvent;

public class ButtonPvPQuickMatch extends Sprite {
    public function ButtonPvPQuickMatch(g:Game, type:String, qi:QueueInfoHolder, avilable:Boolean = true) {
        this.g = g;
        this.type = type;
        queueInfo = qi;
        super();
        joinQueue = new ButtonPvP(join, "button_join_pvp.png");
        leaveQueue = new ButtonPvP(leave, "button_play_pvp.png");
        acceptQueue = new ButtonPvP(accept, "button_play_pvp.png");
        tmpButton = new ButtonPvP(wait, "button_play_pvp.png");
        tmpButton.touchable = false;
        updateStatus();
    }
    private var joinQueue:ButtonPvP;
    private var leaveQueue:ButtonPvP;
    private var acceptQueue:ButtonPvP;
    private var tmpButton:ButtonPvP;
    private var type:String;
    private var queueInfo:QueueInfoHolder;
    private var g:Game;

    public function update():void {
        updateStatus();
    }

    public function onPress():void {
        if (!queueInfo.isWaiting) {
            if (!queueInfo.isInQueue && !queueInfo.isReady) {
                join();
            } else if (queueInfo.isInQueue && !queueInfo.isReady) {
                leave();
            } else {
                accept();
            }
        }
    }

    private function updateStatus():void {
        if (queueInfo == null) {
            return;
        }
        if (queueInfo.isWaiting) {
            tmpButton.setText1("");
            tmpButton.setText2("Waiting", 14);
            if (contains(joinQueue)) {
                removeChild(joinQueue);
            }
            if (contains(leaveQueue)) {
                removeChild(leaveQueue);
            }
            if (contains(acceptQueue)) {
                removeChild(acceptQueue);
            }
            if (!contains(tmpButton)) {
                addChild(tmpButton);
            }
        } else if (!queueInfo.isInQueue && !queueInfo.isReady) {
            if (!contains(joinQueue)) {
                addChild(joinQueue);
            }
            if (contains(leaveQueue)) {
                removeChild(leaveQueue);
            }
            if (contains(acceptQueue)) {
                removeChild(acceptQueue);
            }
            if (contains(tmpButton)) {
                removeChild(tmpButton);
            }
            joinQueue.enabled = true;
        } else if (queueInfo.isInQueue && !queueInfo.isReady) {
            leaveQueue.setText1(queueInfo.getTime(), 18);
            leaveQueue.setText2("In Queue", 14);
            if (contains(joinQueue)) {
                removeChild(joinQueue);
            }
            if (!contains(leaveQueue)) {
                addChild(leaveQueue);
            }
            if (contains(acceptQueue)) {
                removeChild(acceptQueue);
            }
            if (contains(tmpButton)) {
                removeChild(tmpButton);
            }
            leaveQueue.enabled = true;
        } else {
            acceptQueue.setText1(queueInfo.getTimeout(), 18);
            acceptQueue.setText2("Match Ready", 10);
            if (contains(joinQueue)) {
                removeChild(joinQueue);
            }
            if (contains(leaveQueue)) {
                removeChild(leaveQueue);
            }
            if (!contains(acceptQueue)) {
                addChild(acceptQueue);
            }
            if (contains(tmpButton)) {
                removeChild(tmpButton);
            }
            acceptQueue.enabled = true;
        }
    }

    private function join(e:TouchEvent = null):void {
        g.queueManager.removedFromAllQueues();
        queueInfo.isWaiting = true;
        updateStatus();
        g.sendToServiceRoom("tryJoinQueue", type);
        Game.trackEvent("pvp", "queue", "joined", g.me.level);
    }

    private function leave(e:TouchEvent = null):void {
        queueInfo.isWaiting = true;
        updateStatus();
        g.sendToServiceRoom("tryLeaveQueue", type);
    }

    private function accept(e:TouchEvent = null):void {
        queueInfo.isWaiting = true;
        queueInfo.accepted = true;
        updateStatus();
        g.sendToServiceRoom("acceptMatch", type);
    }

    private function wait(e:TouchEvent):void {
    }
}
}

