package core.hud.components {
import starling.events.TouchEvent;
import starling.filters.ColorMatrixFilter;
import starling.textures.Texture;

public class ImageButton extends InteractiveImage {
    public function ImageButton(callback:Function, bd:Texture = null, hoverBd:Texture = null, disabledBd:Texture = null, toggleBd:Texture = null, caption:String = null, alwaysShowCaption:Boolean = false) {
        disabledSource = disabledBd;
        toggleSource = toggleBd;
        super(bd, hoverBd, caption, alwaysShowCaption);
        captionPosition = Position.INNER_RIGHT;
        this.callback = callback;
    }
    protected var disabledSource:Texture;
    protected var toggleSource:Texture;
    private var callback:Function;

    override public function set texture(bd:Texture):void {
        if (disabledSource == null) {
            disabledSource = bd;
        }
        if (toggleSource == null) {
            toggleSource = bd;
        }
        super.texture = bd;
    }

    override public function set enabled(value:Boolean):void {
        var _loc2_:ColorMatrixFilter = null;
        if (disabledSource == null) {
            disabledSource = source;
        }
        if (!_enabled && value) {
            useHandCursor = true;
            if (layer.filter) {
                layer.filter.dispose();
                layer.filter = null;
            }
            layer.texture = source;
        } else if (_enabled && !value) {
            useHandCursor = false;
            if (disabledSource == source) {
                _loc2_ = new ColorMatrixFilter();
                _loc2_.adjustSaturation(-1);
                layer.filter = _loc2_;
            }
            layer.texture = disabledSource;
        }
        super.enabled = value;
    }

    public function set disabledBitmapData(bd:Texture):void {
        disabledSource = bd;
    }

    override protected function onClick(e:TouchEvent):void {
        layer.texture = toggleSource;
        var _loc2_:Texture = source;
        source = toggleSource;
        toggleSource = _loc2_;
        callback(this);
    }
}
}

