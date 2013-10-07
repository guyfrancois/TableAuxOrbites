package citeespace.tableAuxOrbites.flashs.ui_placement
{
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.tools.SynAnimSoundSequ;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import utils.MyTrace;
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;
	
	public class C_anim_placement extends MovieClip implements I_UserResponse 
	{
		public var state:String;
		public static var STATE_SHOW:String="state_show";
		public static var STATE_INTERACTION:String="state_interaction";
		public static var STATE_CORRECTION:String="state_correction";
		public static var STATE_HIDE:String="state_hide";
		
		public var FRAME_INIT:Number;
		public var FRAME_PREACT:Number;
		
		public var FRAME_ACT:Number;
		public var FRAME_CORRECTION	:Number;
		public var FRAME_CONCLUSION:Number;
		
		private var _satellite:Number;
		
		private var syncAnim:SynAnimSoundSequ;
		
		private var _user:Number;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		
		public function C_anim_placement() 
		{
			super();
		
			_satellite=UI_utils.identify_ui_satellite(getQualifiedClassName(this));
			stop();

			FRAME_INIT	=	hframeof("FRAME_INIT");
			FRAME_PREACT	=	hframeof("FRAME_PREACT");
			
			FRAME_ACT	=	hframeof("FRAME_ACT");
			FRAME_CORRECTION	=	hframeof("FRAME_CORRECTION");
			FRAME_CONCLUSION	=	hframeof("FRAME_CONCLUSION");
			
			syncAnim=new SynAnimSoundSequ(this,onAnimComplete);
			syncAnim.add(FRAME_INIT,"placement_satellite_01");
			syncAnim.add('FRAME_PLACE',"placement_satellite"+_satellite);
			syncAnim.add(FRAME_PREACT,"placement_satellite_03");
			syncAnim.add(FRAME_ACT,"placement_satellite_04");
		
			
			
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
		
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.PLACEMENT_SHOW, onShowPlacement);
			chan.addEventListener(GameLogicEvent.PLACEMENT_HIDE, onHidePlacement);
			chan.addEventListener(GameLogicEvent.PLACEMENT_TIMEOUT, onShowCorrection);
			chan.addEventListener(GameLogicEvent.PLACEMENT_CONCLUSION, onShowConclusion);
		}
		
		protected function onHidePlacement(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state!=STATE_SHOW) return;
			removeEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true);
			//if (syncAnim) syncAnim.stop();
			state=STATE_HIDE;
		}
		
		protected function onShowPlacement(event:Event):void
		{
			if (stage==null) return;
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			removeEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true);
			var selected:Number=GameData.instance.selectedSatellite;
			if (_satellite!=selected) {
				state=STATE_HIDE;
				visible=false;
				return;
			}
			state=STATE_SHOW;
			gotoAndStop(1);
			syncAnim.stop();
			visible=true;
			
			
			syncAnim.play();
			addEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true,0,true);
		}		
	
		
		protected function onRemovedFromStage(event:Event):void
		{

			
		}

		protected function onAddedToStage(event:Event):void
		{
			
			
			
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			onShowPlacement(null);
			
		}	
		
	
		
		
		
		
		private function onAnimComplete():void
		{
			NavigationEvent.dispatch(NavigationEvent.SATELLITE_PLACEMENT_ANIMCOMPLET);
			
			state=STATE_INTERACTION;
		}
		
		
		
		
		protected function evt_itemDropped(event:AskUserEvent):void
		{
			if (stage==null) return;

			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state!=STATE_INTERACTION && state!=STATE_SHOW)	return;
			
				MyTrace.put(event.type);
			// TODO Auto-generated method stub
			var palet:C_deplacable_satellite=event.data as C_deplacable_satellite
			
			if (palet.hitTestObject(this["cible"])) {
				removeEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true);
				NavigationEvent.dispatch(NavigationEvent.SATELLITE_PLACEMENT_COMPLET);
			}
			
		}
		
		protected function onShowCorrection(event:Event):void
		{
			
			if (stage==null) return;
			
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state!=STATE_INTERACTION && state!=STATE_SHOW)	return;

			state =	STATE_CORRECTION;
			removeEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true);
			if (this["palet"]) 		removeChild(this["palet"]);
			htweenToFrame(FRAME_CORRECTION,dispatch_anim_end);
		}
		
		protected function dispatch_anim_end():void {
			NavigationEvent.dispatch(NavigationEvent.SATELLITE_PLACEMENT_END);
			
		}
		
		protected function onShowConclusion(event:Event):void
		{
			
			if (state!=STATE_CORRECTION)	return;

			htweenToFrame(FRAME_CONCLUSION);
		}
		
		
		
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}