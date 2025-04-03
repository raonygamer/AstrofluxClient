package core.states.gameStates.missions
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import generics.Util;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.TouchEvent;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class Statusbar extends Sprite
	{
		private var label:TextField;
		
		private var g:Game;
		
		private var daily:Daily;
		
		private var bg:Image;
		
		private var front:Image;
		
		public function Statusbar(g:Game, daily:Daily)
		{
			var _loc3_:ISound = null;
			super();
			this.g = g;
			this.daily = daily;
			var _loc4_:String = "";
			if(daily.level > g.me.level)
			{
				bg = new Image(g.textureManager.getTextureGUIByTextureName("daily_ongoing_bg"));
				_loc4_ = "Unlocks at level " + daily.level;
			}
			else if(daily.status == 0)
			{
				bg = new Image(g.textureManager.getTextureGUIByTextureName("daily_ongoing_bg"));
				front = new Image(g.textureManager.getTextureGUIByTextureName("daily_ongoing_front"));
			}
			else if(daily.status == 1)
			{
				bg = new Image(g.textureManager.getTextureGUIByTextureName("daily_completed"));
				_loc4_ = "Complete - Click to collect reward!";
				bg.addEventListener("touch",onClaim);
				bg.useHandCursor = true;
				_loc3_ = SoundLocator.getService();
				_loc3_.preCacheSound("daily_claim");
				_loc3_.preCacheSound("daily_reward");
			}
			else
			{
				bg = new Image(g.textureManager.getTextureGUIByTextureName("daily_waiting"));
				addEventListener("enterFrame",update);
			}
			addChild(bg);
			if(front)
			{
				addChild(front);
			}
			label = new TextField(this.width,this.height,_loc4_,new TextFormat("Verdana",11,0xffffff));
			label.touchable = false;
			addChild(label);
			setRatio();
		}
		
		private function setRatio() : void
		{
			if(!front)
			{
				return;
			}
			var _loc1_:Number = daily.progress / daily.missionGoal;
			var _loc2_:Number = Math.max(0,Math.min(1,_loc1_));
			front.scaleX = _loc2_;
			front.setTexCoords(1,_loc2_,0);
			front.setTexCoords(3,_loc2_,1);
			label.text = Math.floor(_loc2_ * 100).toFixed().toString() + "% complete";
		}
		
		private function onClaim(e:TouchEvent) : void
		{
			if(e.getTouch(this,"ended"))
			{
				label.text = "waiting ...";
				bg.removeEventListener("touch",onClaim);
				daily.status = 2;
				g.rpc("dailyMissionClaim",onClaimResponse,daily.key);
			}
		}
		
		private function onClaimResponse(m:Message) : void
		{
			var soundManager:ISound;
			g.dailyManager.addReward(m);
			Game.trackEvent("missions","daily",daily.name,g.me.level);
			dispatchEventWith("dailyMissionClaiming");
			bg.filter = new GlowFilter();
			soundManager = SoundLocator.getService();
			soundManager.play("daily_claim");
			TweenMax.to(bg.filter,0.3,{
				"repeat":5,
				"yoyo":true,
				"blur":15,
				"onCompleteListener":function():void
				{
					var reward:DailyReward;
					var xpos:int;
					removeChild(label);
					bg.filter.dispose();
					bg.filter = null;
					TweenMax.to(bg,0.8,{
						"width":0,
						"onCompleteListener":function():void
						{
							removeChild(bg);
							dispatchEventWith("dailyMissionClaimed");
							soundManager.stop("daily_claim");
							soundManager.play("daily_reward");
						}
					});
					reward = new DailyReward(g,daily);
					addChild(reward);
					reward.x = width;
					xpos = width / 2 - reward.width;
					TweenMax.to(reward,0.8,{"x":xpos});
				}
			});
		}
		
		public function update(e:EnterFrameEvent) : void
		{
			if(daily.status != 2)
			{
				return;
			}
			var _loc2_:Number = g.dailyManager.resetTime - g.time;
			if(_loc2_ <= 0)
			{
				daily.status = 0;
				daily.progress = 0;
				removeEventListener("enterFrame",update);
				dispatchEventWith("dailyMissionReset");
			}
			else
			{
				label.text = "Available again in " + Util.getFormattedTime(_loc2_);
			}
		}
		
		override public function dispose() : void
		{
			bg.removeEventListeners();
			removeEventListener("enterFrame",update);
			super.dispose();
		}
	}
}

