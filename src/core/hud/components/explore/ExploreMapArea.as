package core.hud.components.explore
{
	import com.greensock.TweenMax;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Area;
	import extensions.PixelHitArea;
	import extensions.PixelImageTouch;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ExploreMapArea extends starling.display.Sprite
	{
		private static const ALPHA_COMPLETE:Number = 0.6;
		
		private static const ALPHA_START:Number = 0.3;
		
		public var key:String;
		
		public var area:Object;
		
		private var shell:Vector.<Point>;
		
		public var size:int;
		
		private var a:Number;
		
		private var g:Game;
		
		private var color:uint;
		
		private var color_fill:uint;
		
		private var color_fill_done:uint;
		
		private var map:ExploreMap;
		
		private var selected:Boolean;
		
		private var mouseOver:Boolean;
		
		private var x_max:int;
		
		private var fractionText:TextBitmap;
		
		private var kx:Number;
		
		private var ky:Number;
		
		private var x_mid:Number;
		
		private var y_mid:Number;
		
		private var infoBox:starling.display.Sprite;
		
		private var infoBoxBgr:Quad;
		
		public var explore:Explore;
		
		public var fraction:int = 0;
		
		private var areaTexture:Texture;
		
		private var areaImage:PixelImageTouch;
		
		private var tween:TweenMax;
		
		private var needRedraw:Boolean = true;
		
		private var fader:Number = 0.02;
		
		public function ExploreMapArea(g:Game, map:ExploreMap, area:Object, shell:Vector.<Point>, kx:Number, ky:Number, x_max:int)
		{
			var _loc10_:int = 0;
			var _loc17_:int = 0;
			var _loc13_:ITextureManager = null;
			var _loc9_:Image = null;
			var _loc16_:starling.display.Sprite = null;
			var _loc11_:ToolTip = null;
			var _loc18_:TextBitmap = null;
			var _loc19_:TextBitmap = null;
			var _loc12_:int = 0;
			var _loc20_:Image = null;
			var _loc21_:starling.display.Sprite = null;
			var _loc15_:ToolTip = null;
			super();
			this.g = g;
			this.a = 1;
			this.kx = kx;
			this.ky = ky;
			this.map = map;
			this.area = area;
			this.x_max = x_max;
			this.shell = shell;
			key = area.key;
			size = area.size;
			explore = g.me.getExploreByKey(key);
			if(explore == null)
			{
				fraction = 0;
			}
			else if(explore.failTime < g.time && explore.failTime != 0)
			{
				fraction = 100 * (explore.successfulEvents + 1) / (size + 4 + 1);
			}
			else
			{
				fraction = 100 * (g.time - explore.startTime) / (explore.finishTime - explore.startTime);
			}
			var _loc8_:Array = area.types;
			if(area.majorType == -1)
			{
				color = 0x333333;
				color_fill = 0;
			}
			else
			{
				color = Area.COLORTYPE[area.majorType];
				color_fill = Area.COLORTYPEFILL[area.majorType];
			}
			drawArea();
			if(area.majorType != -1)
			{
				useHandCursor = true;
				_loc10_ = 49;
				_loc17_ = 45;
				if(area.skillLevel > 99 || _loc8_.length > 1)
				{
					_loc17_ = 58;
				}
				infoBox = new starling.display.Sprite();
				infoBoxBgr = new Quad(_loc17_,_loc10_,0);
				infoBoxBgr.alpha = 0.5;
				infoBox.addChild(infoBoxBgr);
				infoBox.x = x_mid - 0.5 * infoBox.width;
				infoBox.y = y_mid - 0.5 * infoBox.height;
				infoBox.touchable = false;
				addChild(infoBox);
				fractionText = new TextBitmap(2,2,fraction + "%");
				infoBox.addChild(fractionText);
				_loc13_ = TextureLocator.getService();
				_loc9_ = new Image(_loc13_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[area.majorType]));
				_loc9_.x = 4;
				_loc9_.y = 33;
				_loc16_ = new starling.display.Sprite();
				_loc16_.addChild(_loc9_);
				_loc11_ = new ToolTip(g,_loc16_,Area.SKILLTYPEHTML[area.majorType],null,"skill");
				infoBox.addChild(_loc16_);
				_loc18_ = new TextBitmap(2,18,"lvl ",11);
				infoBox.addChild(_loc18_);
				_loc19_ = new TextBitmap(0,18,area.skillLevel,11);
				_loc19_.x = _loc18_.x + _loc18_.width;
				infoBox.addChild(_loc19_);
				_loc12_ = 1;
				for each(var _loc14_ in _loc8_)
				{
					_loc12_++;
					_loc20_ = new Image(_loc13_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_loc14_]));
					_loc20_.x = -18 + 20 * _loc12_;
					_loc20_.y = 33;
					_loc21_ = new starling.display.Sprite();
					_loc21_.addChild(_loc20_);
					_loc15_ = new ToolTip(g,_loc21_,Area.SPECIALTYPEHTML[_loc14_],null,"skill");
					infoBox.addChild(_loc21_);
				}
				infoBox.addEventListener("touch",onTouch);
			}
		}
		
		private function drawArea() : void
		{
			var _loc7_:int = 0;
			var _loc8_:Number = 0;
			var _loc6_:Number = 0;
			x_mid = 0;
			y_mid = 0;
			var _loc3_:int = 1 + shell.length;
			var _loc2_:flash.display.Sprite = new flash.display.Sprite();
			_loc2_.graphics.lineStyle(2,color);
			_loc2_.graphics.beginFill(color_fill,a);
			_loc2_.graphics.moveTo(shell[0].x * kx,shell[0].y * ky);
			x_mid += shell[0].x * kx;
			y_mid += shell[0].y * ky;
			_loc8_ = shell[0].x * kx;
			_loc6_ = shell[0].y * ky;
			_loc7_ = 1;
			while(_loc7_ < shell.length)
			{
				x_mid += shell[_loc7_].x * kx;
				y_mid += shell[_loc7_].y * ky;
				_loc8_ = Math.min(_loc8_,shell[_loc7_].x * kx);
				_loc6_ = Math.min(_loc6_,shell[_loc7_].y * ky);
				_loc2_.graphics.lineTo(shell[_loc7_].x * kx,shell[_loc7_].y * ky);
				_loc7_++;
			}
			x_mid /= _loc3_;
			y_mid /= _loc3_;
			_loc2_.graphics.endFill();
			var _loc1_:Rectangle = _loc2_.getBounds(_loc2_);
			var _loc5_:BitmapData = new BitmapData(_loc1_.width,_loc1_.height,true,0);
			var _loc9_:Matrix = new Matrix();
			_loc9_.translate(-_loc1_.x,-_loc1_.y);
			_loc5_.draw(_loc2_,_loc9_);
			var _loc4_:Bitmap = new Bitmap(_loc5_);
			areaTexture = Texture.fromBitmap(_loc4_);
			areaImage = new PixelImageTouch(areaTexture,new PixelHitArea(_loc4_,1,key),50);
			_loc4_ = null;
			_loc5_.dispose();
			_loc5_ = null;
			_loc2_.graphics.clear();
			_loc2_ = null;
			if(area.majorType != -1)
			{
				areaImage.addEventListener("touch",onTouch);
			}
			areaImage.x = _loc8_;
			areaImage.y = _loc6_;
			addChildAt(areaImage,0);
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			var _loc2_:DisplayObject = e.currentTarget as DisplayObject;
			if(e.getTouch(_loc2_,"ended"))
			{
				onClick(e);
			}
			else if(e.interactsWith(_loc2_))
			{
				mOver(e);
			}
			else if(!e.interactsWith(_loc2_))
			{
				mOut(e);
			}
		}
		
		public function shouldBlink() : Boolean
		{
			if(explore != null && !explore.lootClaimed)
			{
				return true;
			}
			return false;
		}
		
		public function update() : void
		{
			if(!needRedraw)
			{
				return;
			}
			if(area.majorType == -1)
			{
				return;
			}
			if(explore == null)
			{
				fraction = 0;
			}
			else
			{
				if(explore.failTime < g.time && explore.successfulEvents < area.size + 4)
				{
					fractionText.text = "Failed!";
					fractionText.format.color = 0xff0000;
					infoBoxBgr.width = fractionText.width + 5;
					if(!explore.lootClaimed)
					{
						fractionText.text = "Reward!";
						infoBoxBgr.width = fractionText.width + 5;
						startTween();
					}
					return;
				}
				if(explore.failTime >= g.time)
				{
					fractionText.format.color = 0xffffff;
					fraction = 100 * (g.time - explore.startTime) / (explore.finishTime - explore.startTime);
					fractionText.text = fraction + "%";
				}
				else if(explore != null && explore.lootClaimed)
				{
					fractionText.text = "Claimed!";
					fractionText.format.color = 0xffffff;
					infoBoxBgr.width = fractionText.width + 5;
					needRedraw = false;
				}
				else
				{
					fractionText.text = "Reward!";
					fractionText.format.color = 0xffffff;
					infoBoxBgr.width = fractionText.width + 5;
					startTween();
				}
			}
		}
		
		public function select() : void
		{
			selected = true;
			if(areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			map.moveOnTop(this);
			startTween();
		}
		
		private function startTween() : void
		{
			if(tween != null)
			{
				return;
			}
			tween = TweenMax.fromTo(areaImage,0.8,{"alpha":1},{
				"alpha":0.5,
				"yoyo":true,
				"repeat":-1
			});
		}
		
		public function clearSelect() : void
		{
			selected = false;
			if(tween != null)
			{
				tween.kill();
				tween = null;
				areaImage.alpha = 1;
			}
		}
		
		public function onClick(e:TouchEvent) : void
		{
			if(!selected)
			{
				SoundLocator.getService().play("3hVYqbNNSUWoDGk_pK1BdQ");
				map.clearSelected(this);
				ExploreMap.selectedArea = area;
				select();
			}
		}
		
		public function mOver(e:TouchEvent) : void
		{
			if(selected)
			{
				return;
			}
			if(areaImage.filter)
			{
				return;
			}
			var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
			_loc2_.adjustBrightness(0.2);
			areaImage.filter = _loc2_;
		}
		
		public function mOut(e:TouchEvent) : void
		{
			if(areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
		}
		
		override public function dispose() : void
		{
			if(areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			if(tween != null)
			{
				tween.kill();
				tween = null;
			}
			if(areaTexture)
			{
				removeChild(areaImage,true);
				areaTexture.dispose();
			}
			super.dispose();
		}
	}
}

