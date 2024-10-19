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
		public function Astroflux(info:Object = null)
		{
			super();
			addChild(new RymdenRunt(info));
		}
	}
}
