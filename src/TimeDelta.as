package {
public class TimeDelta {
    public function TimeDelta(latency:Number, timeSyncDelta:Number) {
        super();
        this.latency = latency;
        this.timeSyncDelta = timeSyncDelta;
    }
    public var latency:Number;
    public var timeSyncDelta:Number;
}
}

