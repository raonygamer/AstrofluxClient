package core.particle {
import starling.display.MeshBatch;

public class CollectiveMeshBatch extends MeshBatch {
    private static var effectsBatch:CollectiveMeshBatch;
    private static var meshBatches:Vector.<CollectiveMeshBatch> = new Vector.<CollectiveMeshBatch>();

    public static function Create(e:Emitter):CollectiveMeshBatch {
        var _loc2_:CollectiveMeshBatch = null;
        if (e.canvasTarget != null) {
            _loc2_ = new CollectiveMeshBatch();
            meshBatches.push(_loc2_);
            _loc2_.emitters.push(e);
            return _loc2_;
        }
        if (!effectsBatch) {
            effectsBatch = new CollectiveMeshBatch();
        }
        effectsBatch.emitters.push(e);
        return effectsBatch;
    }

    public static function AllMeshesAreUpdated():void {
        var _loc2_:int = 0;
        var _loc1_:CollectiveMeshBatch = null;
        _loc2_ = meshBatches.length - 1;
        while (_loc2_ > -1) {
            _loc1_ = meshBatches[_loc2_];
            _loc1_.markUpdated();
            if (_loc1_.emitters.length == 0) {
                _loc1_.clear();
            }
            _loc2_--;
        }
        if (effectsBatch) {
            effectsBatch.markUpdated();
        }
    }

    public static function dispose():void {
        if (effectsBatch == null || meshBatches == null) {
            return;
        }
        effectsBatch.dispose();
        effectsBatch = null;
        for each(var _loc1_ in meshBatches) {
            if (_loc1_ != null) {
                _loc1_.emitters.length = 0;
                _loc1_.dispose();
            }
        }
        meshBatches.length = 0;
    }

    public function CollectiveMeshBatch() {
        super();
        batchable = false;
    }
    private var hasBeenUpdated:Boolean = false;
    private var emitters:Vector.<Emitter> = new Vector.<Emitter>();

    override public function clear():void {
        if (!hasBeenUpdated) {
            return;
        }
        super.clear();
        hasBeenUpdated = false;
    }

    public function markUpdated():void {
        hasBeenUpdated = true;
    }

    public function remove(e:Emitter):void {
        if (emitters.indexOf(e) == -1) {
            return;
        }
        emitters.removeAt(emitters.indexOf(e));
    }
}
}

