package core.hud.components
{
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextEditor;
	import flash.text.TextFormat;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class LoginInput extends Sprite
	{
		private static var textColor:uint = 16777215;
		private static var textFormat:starling.text.TextFormat = new starling.text.TextFormat("DAIDRR",12,textColor);
		private static var errorFormat:starling.text.TextFormat = new starling.text.TextFormat("DAIDRR",10,0xff0000,"center");
		private var placeholder:TextField;
		private var errorText:TextField;
		public var input:TextInput;
		
		public function LoginInput(placeholderText:String)
		{
			var w:int;
			var line:Quad;
			input = new TextInput();
			super();
			w = 250;
			placeholder = new TextField(w,30,placeholderText.toUpperCase(),textFormat);
			placeholder.y = 4;
			addChild(placeholder);
			line = new Quad(w,1,textColor);
			line.y = placeholder.height;
			addChild(line);
			input.textEditorFactory = getTextEditor;
			input.textEditorProperties.textFormat = new flash.text.TextFormat("Verdana",14,textColor,null,null,null,null,null,"center");
			input.textEditorProperties.wordWrap = true;
			input.paddingLeft = 5;
			input.width = w;
			input.height = 30;
			input.addEventListener("focusIn",function():void
			{
				placeholder.visible = false;
			});
			input.addEventListener("focusOut",function():void
			{
				placeholder.visible = input.text.length == 0;
			});
			addChild(input);
			errorText = new TextField(w,15,"",errorFormat);
			errorText.wordWrap = true;
			errorText.y = line.y + 5;
			errorText.visible = false;
			addChild(errorText);
			alpha = 0.7;
		}
		
		private function getTextEditor() : TextFieldTextEditor
		{
			return new TextFieldTextEditor();
		}
		
		public function get text() : String
		{
			return input.text;
		}
		
		public function set text(value:String) : void
		{
			input.text = value;
			placeholder.visible = input.text.length == 0;
		}
		
		public function get error() : String
		{
			return errorText.text;
		}
		
		public function set error(value:String) : void
		{
			errorText.text = value.toUpperCase();
			errorText.visible = errorText.text.length != 0;
		}
		
		public function setPrevious(component:LoginInput) : void
		{
			component.input.nextTabFocus = this.input;
			y = component.y + component.height + 10;
		}
	}
}

