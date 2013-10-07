package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.controllers.SoundController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonSelfName;
	import citeespace.tableAuxOrbites.tools.SynAnimSoundSequ;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.media.SoundChannel;
	
	import utils.MyTrace;
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_ChoixSatellite extends F_Anim_super
	{
		
		public var state:String;
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var FRAME_LANCE:Number;
		public var FRAME_PLACE:Number;
		public var FRAME_TRACE_ORB:Number;
		public var FRAME_TRACE_LIGHT:Number;
		public var FRAME_SAT_1:Number;
		public var FRAME_SAT_2:Number;
		public var FRAME_SAT_3:Number;
		public var FRAME_END:Number;
		

			
		private var selectedSatellite:Number=0;
		
		private var syncAnim:SynAnimSoundSequ;
		
		public function F_ui_ChoixSatellite()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.SATELLITE_CHOICE_SHOW, onShowChoice);
			chan.addEventListener(GameLogicEvent.SATELLITE_CHOICE_HIDE, onHideChoice);
			chan.addEventListener(GameLogicEvent.SATELLITE_CHOICE_HIDEQUICK, onHideChoiceQuick);
			
			
			
			
			
			FRAME_LANCE	=	hframeof("FRAME_LANCE");
			FRAME_PLACE	=	hframeof("FRAME_PLACE");
			FRAME_TRACE_ORB	=	hframeof("FRAME_TRACE_ORB");
			FRAME_TRACE_LIGHT	=	hframeof("FRAME_TRACE_LIGHT");
			FRAME_SAT_1	=	hframeof("FRAME_SAT_1");
			FRAME_SAT_2	=	hframeof("FRAME_SAT_2");
			FRAME_SAT_3	=	hframeof("FRAME_SAT_3");
			FRAME_END	=	hframeof("FRAME_END");
			
			syncAnim=new SynAnimSoundSequ(this,onSeqComplete);
			syncAnim.add(null,"choix_satellite_01");
			syncAnim.add(FRAME_LANCE,"choix_satellite_02");
			syncAnim.add(FRAME_TRACE_ORB,"choix_satellite_04");
			syncAnim.add(FRAME_TRACE_LIGHT,"choix_satellite_05");
			syncAnim.add(FRAME_SAT_1,"signal_0",SynAnimSoundSequ.COMMENTTYPEFX);
			syncAnim.add(FRAME_SAT_2,"signal_1",SynAnimSoundSequ.COMMENTTYPEFX);
			syncAnim.add(FRAME_SAT_3,"signal_2",SynAnimSoundSequ.COMMENTTYPEFX);
			syncAnim.add(null,"choix_satellite_06");
		
		}
		
		protected function onHideChoice(event:Event):void
		{
			// TODO Auto-generated method stub
			if (state!=STATE_SHOW)	return;
		
			state=STATE_HIDE
			syncAnim.stop();
			hide();
		}
		
		protected function onHideChoiceQuick(event:Event):void
		{
			// TODO Auto-generated method stub
			if (state!=STATE_SHOW)	return;
			state=STATE_HIDE;
			syncAnim.stop();
			hide(true);
		}
		
		protected function onShowChoice(event:Event):void
		{
			// TODO Auto-generated method stub
			if (state!=STATE_HIDE)
				return
			state=STATE_SHOW;
			gotoAndStop(1);
			syncAnim.stop();
			selectedSatellite=0
			show();
		}
		
		override protected function _showComplete():void
		{
			super._showComplete();
			//playSeq(0);
			syncAnim.play();
			var navigChan:EventChannel=NavigationEvent.channel;
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat1"),evt_click_sat1);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat2"),evt_click_sat2);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat3"),evt_click_sat3);
		}
		
	
		
		private function onSeqComplete():void
		{
			if (state!=STATE_SHOW)
				return
			// TODO Auto Generated method stub

			NavigationEvent.dispatch(NavigationEvent.PLAYER_SATELLITE_ANIMCOMPLET);
			var navigChan:EventChannel=NavigationEvent.channel;
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat1"),evt_click_sat1);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat2"),evt_click_sat2);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("select_sat3"),evt_click_sat3);
		}	
		
		private function removeSelectListener():void {
			var navigChan:EventChannel=NavigationEvent.channel;
			navigChan.removeEventListener(C_BoutonSelfName.getTapEvent("select_sat1"),evt_click_sat1);
			navigChan.removeEventListener(C_BoutonSelfName.getTapEvent("select_sat2"),evt_click_sat2);
			navigChan.removeEventListener(C_BoutonSelfName.getTapEvent("select_sat3"),evt_click_sat3);
		}
		
		protected function evt_click_sat3(event:Event):void
		{
			// TODO Auto-generated method stub
			removeSelectListener()
			selectedSatellite=3;
			SoundController.instance._playSfxInteraction('sfx_clic');
			htweenToFrame(FRAME_END,dispatchPlayerSatelliteSelected)
			
		}
		
		protected function evt_click_sat2(event:Event):void
		{
			// TODO Auto-generated method stub
			removeSelectListener()
			selectedSatellite=2;
			SoundController.instance._playSfxInteraction('sfx_clic');
			htweenToFrame(FRAME_END,dispatchPlayerSatelliteSelected)
		}
		
		protected function evt_click_sat1(event:Event):void
		{
			// TODO Auto-generated method stub
			removeSelectListener()
			selectedSatellite=1;
			SoundController.instance._playSfxInteraction('sfx_clic');
			htweenToFrame(FRAME_END,dispatchPlayerSatelliteSelected)
		}
		
		
		private function dispatchPlayerSatelliteSelected():void
		{
			NavigationEvent.dispatch(NavigationEvent.PLAYER_SATELLITE_SELECTED,selectedSatellite);
		}
		
		
		protected function onRemovedFromStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			visible=false;
			alpha=0;
			gotoAndStop(1);
			state=STATE_HIDE;
		}
			

		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}