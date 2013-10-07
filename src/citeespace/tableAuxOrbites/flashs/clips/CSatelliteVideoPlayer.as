package citeespace.tableAuxOrbites.flashs.clips
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	
	import pensetete.clips.videos.LightVideoPlayer;
	import pensetete.clips.videos.StageVideoPlayer;
	
	import utils.events.EventChannel;
	
	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [8 déc. 2011][sps] creation
	 *
	 * citeespace.tableAuxOrbites.flashs.clips.CSatelliteVideoPlayer
	 */
	public class CSatelliteVideoPlayer extends LightVideoPlayer implements I_UserResponse
	{
		
		public function CSatelliteVideoPlayer(args:Object=null)
		{
			super(args);
			
			// On passe le ParamsHub a notre ancetre pour qu'il puisse lire les préférences
			params 		= DataCollection.params;
			autoPlay	= false;
			loop 		= false;
			
			var chan:EventChannel = GameLogicEvent.channel;
			chan.addEventListener(GameLogicEvent.SHOW_VIDEO, onShowVideoRequest);
			chan.addEventListener(GameLogicEvent.HIDE_VIDEO, onHideVideoRequest);
			
			addEventListener(Event.COMPLETE, onVideoComplete, false,0,true);
			
			
		}
		
		protected function onHideVideoRequest(event:Event):void
		{
			stopVideo();
			hide();
		}
		
		protected function onVideoComplete(event:Event):void
		{
			// Vidéo terminée
			trace("vidéo terminée");
			GameLogicEvent.dispatch(GameLogicEvent.CONCLUSION_VIDEO_COMPLETE);
		}
		
		override protected function resize():void
		{
			// TODO Auto Generated method stub
	
				video.width=video.videoWidth;
				video.height=video.videoHeight;
				
		}
		
		
		
		protected function onShowVideoRequest(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			start(event.data as String);
			
		}
		
		override protected function onVideoStarted():void
		{
			show();
			super.onVideoStarted();
			GameLogicEvent.dispatch(GameLogicEvent.VIDEO_STARTED);
		}
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à hide
		 */
		public var hide_tween_duration:Number = 0.5;
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show
		 */
		public var show_tween_duration:Number = 0.5;
		
	
		/**
		 *  
		 * @param noTween
		 * @return 
		 * 
		 */
		public function hide(noTween:Boolean=false):void
		{
			TweenLite.killTweensOf(this);
			if (noTween) {
				visible = false;
				alpha = 0;
			} else {
				TweenLite.to(this, hide_tween_duration, {alpha:0, onComplete:_hideComplete});
			}
			
		} 
		
		protected function _hideComplete():void
		{
			visible = false;
		}
		
		public function show(noTween:Boolean=false):void
		{
			TweenLite.killTweensOf(this);
			visible = true;
			if (noTween) {
				alpha = 1;
			} else {
				TweenLite.to(this, show_tween_duration, {alpha:1,onComplete:_showComplete});
			}
		
		}
		protected function _showComplete():void
		{
			
		}
		
		
	}
}