package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_Placement extends F_Anim_super implements I_UserResponse
	{
		public var state:String;
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var FRAME_ACT:Number;
		
		private var _user:Number;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		
		
		public function F_ui_Placement()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			// ecouter ,repondre et signaler d'utilisateur de cette interface
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.PLACEMENT_SHOW, onShowPlacement);
			chan.addEventListener(GameLogicEvent.PLACEMENT_HIDE, onHidePlacement);
			
			FRAME_ACT	=	hframeof("FRAME_ACT");
			
			
		}
		
		protected function onHidePlacement(event:GameLogicEvent):void
		{
			if (state!=STATE_SHOW)
				return
			state=STATE_HIDE
			hide();
		}
		
		protected function onShowPlacement(event:GameLogicEvent):void
		{
			if (state!=STATE_HIDE)
				return
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
				state=STATE_SHOW;
			gotoAndStop(1);
	
		//	selectedSatellite=0
			show(true);
			htweenToFrame(FRAME_ACT);
		}		
		
		
			
		
		protected function onRemovedFromStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		private function onAddedToStage(param0:Object):void
		{
			visible=false;
			alpha=0;
			gotoAndStop(1);
			state=STATE_HIDE;
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
		}
		
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}