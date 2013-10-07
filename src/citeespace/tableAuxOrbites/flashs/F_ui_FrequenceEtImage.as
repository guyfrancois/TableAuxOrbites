package citeespace.tableAuxOrbites.flashs
{
	import avmplus.getQualifiedClassName;
	
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.flashs.ui_FrequenceEtImage.C_ui_ImageEffect;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventPhase;
	
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_FrequenceEtImage extends F_Anim_super implements I_UserResponse
	{
		public var cartouche_image:MovieClip;
		
		public var fiche_conclusion:F_Anim_super;
		
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var FRAME_VIDEO	:Number;
		
		public var state:String;
		
		private var _videoEffect:C_ui_ImageEffect;
		
		protected var _user:Number;
		
		public function setUser(user:Number):void
		{
				_user=user;
		}
		
		public function F_ui_FrequenceEtImage()
		{
			super();
			stop();
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			FRAME_VIDEO	=	hframeof("FRAME_VIDEO");
			relayAmplitude();
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.FREQUENCEETIMAGE_SHOW, onShow);
			chan.addEventListener(GameLogicEvent.FREQUENCEETIMAGE_HIDE, onHide);
			chan.addEventListener(GameLogicEvent.FREQUENCEETIMAGE_VIDEO, onVideo);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_AFFICHE_REPONSE, onVideoDecrypte);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_CONCLUSION, onConclusion);
		}
		
		protected function onConclusion(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			fiche_conclusion.gotoAndStop(GameData.instance.selectedSatellite);
			fiche_conclusion.show();
			NavigationEvent.dispatch(NavigationEvent.IDENTIFIER_SIGNAL_CONCLUSIONCOMPLET);
			
		}
		
		protected function onVideoDecrypte(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			// TODO Auto-generated method stub

			TweenLite.to(_videoEffect,1,{noisex:0,noisey:0,sinus_amplitudex:0,sinus_amplitudey:0,blurAmout:0});
		}
		
		protected function onVideo(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			htweenToFrame(FRAME_VIDEO);
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			
			
			
		}
		
		private function onAddedToStage(param0:Object):void
		{
			visible=false;
			alpha=0;
			gotoAndStop(1);
			fiche_conclusion.hide(true);
			state=STATE_HIDE;
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
		}
		
		
		
		protected function onHide(event:Event):void
		{
			
			if (state!=STATE_SHOW)
				return
				state=STATE_HIDE
			hide();
			
		}
		
		override protected function _hideComplete():void
		{
			// TODO Auto Generated method stub
			_videoEffect.stopVideo();
			
			fiche_conclusion.hide(true);
			super._hideComplete();
			//cartouche_image.gotoAndStop(1);
		}
		
		
		protected function onShow(event:Event):void
		{
			
			if (state!=STATE_HIDE)	return;
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			state=STATE_SHOW;
			gotoAndStop(1);
			initGame();
			show();
			
		}		
		
		private function initGame():void
		{
			_videoEffect=cartouche_image.videoEffect;
			_videoEffect.playVideo("sat"+GameData.instance.selectedSatellite);
		}		
		
		
		
		// relay update amplitudes
		public function relayAmplitude():void {
			addEventListener(AskUserEvent.SIGNAL_AMP,evt_update_amp,true,0,true);
		}
		
		protected function evt_update_amp(event:AskUserEvent):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
				return;
			if (_videoEffect) {
				_videoEffect.sinus_amplitudex=event.data.amplitudex;
				_videoEffect.sinus_amplitudey=event.data.amplitudey;
			}
			
			
		}
		
		
		
		
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}