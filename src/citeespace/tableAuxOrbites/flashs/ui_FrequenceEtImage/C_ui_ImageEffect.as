package citeespace.tableAuxOrbites.flashs.ui_FrequenceEtImage
{

	
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	
	import effets.SignalEffectSprite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventPhase;
	
	import pensetete.clips.videos.LightVideoPlayer;
	
	import utils.MyTrace;
	import utils.strings.TokenUtil;
	
	public class C_ui_ImageEffect extends SignalEffectSprite
	{
		public var video:LightVideoPlayer;
		
		public function C_ui_ImageEffect()
		{
			super();
			
			_video=video;
			video.loop=true;
			updateFilter();
			addEventListener(Event.ADDED_TO_STAGE,evt_added,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE,evt_removed,false,0,true);
		}
		
		protected function evt_removed(event:Event):void
		{
			sinus_phase_autoIncrement=false;	
		}
		
		protected function evt_added(event:Event):void
		{
			sinus_phase_autoIncrement=true;
			
		}
		
		public function playVideo(fileName:String):void {
			var tokens:Object= {};
			tokens.satellite = fileName;
			var strVid:String = DataCollection.instance.getParamString('url_videosignal');
			strVid = TokenUtil.replaceTokens(strVid, tokens);
			MyTrace.put("lecture de la vidéo " + strVid);
			video.start(strVid);
			restoreNoise();
			
		}
		public function stopVideo():void {
			video.stopVideo();
		}
		
	}
}