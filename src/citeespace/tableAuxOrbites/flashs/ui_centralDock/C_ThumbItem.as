package citeespace.tableAuxOrbites.flashs.ui_centralDock
{
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.F_Anim_super;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	
	import utils.events.EventChannel;
	
	public class C_ThumbItem extends F_Anim_super implements I_UserResponse
	{
		private var _user:Number;
		
		
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		public function C_ThumbItem()
		{
			super();
			stop();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.COMMON_DOCK_HIDE, onHideDock);
			chan.addEventListener(GameLogicEvent.COMMON_DOCK_SHOW, onShowDock);
			visible = false;	
		}
		
		private function onAddedToStage(param0:Object):void
		{
			
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
			
		}
		
		
		protected function onShowDock(event:Event):void
		{
			hide(true);
		}
		
		protected function onHideDock(event:Event):void
		{
			hide(true);
			
		}
		
		override public function hide(noTween:Boolean=false):F_Anim_super
		{
			gotoAndStop(1);
			if (visible==false)
				return this
			// TODO Auto Generated method stub
			return super.hide(noTween);
		}
		
		
		
		override public function show(noTween:Boolean=false):F_Anim_super
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return this;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return this;
			
			gotoAndStop(1+GameData.instance.selectedSatellite);
			TweenLite.killTweensOf(this);
			scaleX=scaleY=0;
			visible = true;
			if (noTween) {
				alpha = 1;
			} else {
				TweenLite.to(this, show_tween_duration, {delay:0,alpha:1,scaleX:1,scaleY:1,onComplete:_showComplete});
			}
			return this;
		}
		
		
	}
}