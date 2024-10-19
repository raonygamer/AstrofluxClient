package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class Astroflux extends Sprite
	{
		public function Astroflux()
		{
			super();

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat("_sans", 12, 0x0000cc);
			textField.text = "Hello, Adobe AIR!";
			addChild(textField);
		}
	}
}
