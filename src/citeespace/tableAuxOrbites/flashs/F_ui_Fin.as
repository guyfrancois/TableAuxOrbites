package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.tools.SynAnimSoundSequ;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import org.tuio.TuioTouchEvent;
	
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_Fin extends F_Anim_super implements I_UserResponse
	{
		public var state:String;
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var btn_quitter:MovieClip;
		public var btn_poursuivre:MovieClip;
		
		
		private var _user:Number;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		private var syncAnim:SynAnimSoundSequ;
		public function F_ui_Fin()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			// ecouter ,repondre et signaler d'utilisateur de cette interface
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.FIN_SHOW, onShow);
			chan.addEventListener(GameLogicEvent.FIN_HIDE, onHide);
			
			btn_quitter.addEventListener(TuioTouchEvent.TAP, onQuitter, false,-100,true);
			btn_poursuivre.addEventListener(TuioTouchEvent.TAP, onPoursuivre, false,-100,true);
		
			syncAnim=new SynAnimSoundSequ(this,null);
			syncAnim.add(null,"fin_question");
			syncAnim.add(null,"fin_proposition1");
			syncAnim.add(null,"fin_proposition2");
		
		}
		
		protected function onQuitter(event:Event):void {
			btn_quitter.mouseEnabled=false;
			btn_poursuivre.mouseEnabled=true;
		}
		protected function onPoursuivre(event:Event):void {
			btn_quitter.mouseEnabled=true;
			btn_poursuivre.mouseEnabled=false;
		}
		
		protected function onHide(event:GameLogicEvent):void
		{
			//if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			//if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			//if (state!=STATE_SHOW)	return;
			state=STATE_HIDE
			hide();
			syncAnim.stop();
		}
		
		protected function onShow(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state!=STATE_HIDE)	return;

			
				state=STATE_SHOW;
			gotoAndStop(1);
	
		//	selectedSatellite=0
			show(true);
			btn_quitter.mouseEnabled=true;
			btn_poursuivre.mouseEnabled=true;
			syncAnim.play()
			
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
		
	}
}