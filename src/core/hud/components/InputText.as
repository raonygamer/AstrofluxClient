package core.hud.components
{
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.skins.IStyleProvider;
	import feathers.skins.ImageSkin;
	import flash.text.TextFormat;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class InputText extends TextInput
	{
		public static var globalStyleProvider:IStyleProvider;
		private static var textFormat:TextFormat = new TextFormat("Verdana",12,0xffffff);
		
		public function InputText(x:int, y:int, w:int, h:int)
		{
			super();
			this.x = x;
			this.y = y;
			width = w;
			height = h;
			if(!backgroundSkin)
			{
				backgroundSkin = new Image(Texture.fromEmbeddedAsset(EmbeddedAssets.TextInputBitmap,false));
			}
			this.textEditorFactory = getTextEditor;
			this.textEditorProperties.textFormat = InputText.textFormat;
			this.textEditorProperties.wordWrap = true;
			paddingLeft = 5;
			paddingTop = 2;
			paddingRight = 5;
		}
		
		private function getTextEditor() : TextFieldTextEditor
		{
			return new TextFieldTextEditor();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider
		{
			return InputText.globalStyleProvider;
		}
		
		public function setDesktopLogin() : void
		{
			var _loc1_:ImageSkin = new ImageSkin();
			_loc1_.defaultColor = 908765;
			_loc1_.selectedColor = 4212299;
			this.backgroundSkin = _loc1_;
			this.textEditorProperties.textFormat = new TextFormat("Verdana",18,0xffffff);
			this.textEditorProperties.wordWrap = true;
		}
	}
}

