package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonSelfName;
	
	import flash.events.Event;
	
	import utils.events.EventChannel;

	public class F_ui_choixLangue extends F_Anim_super
	{
		public static var STATE_JOUEUR_1:String="etat_choix_joueur_1";
		public static var STATE_JOUEUR_2:String="etat_choix_joueur_2";
		public static var STATE_PLAY_2:String="etat_choix_jouer_2";
		private var _currentState:String;
		public function F_ui_choixLangue()
		{
			super();
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.LANG_CHOICE_SHOW, onShowLang);
			chan.addEventListener(GameLogicEvent.LANG_CHOICE_HIDE, onHideLang);
			chan.addEventListener(GameLogicEvent.LANGAGE_CHANGE, onPropose2);
			chan.addEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onPropose_play2);
			var navigChan:EventChannel = NavigationEvent.channel;
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("jouer1"),evt_click_1joueur);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("jouer2"),evt_click_2joueur);
		}
		
		protected function evt_click_2joueur(event:Event):void
		{
			
			if ( this["btn_jouer2"]) this["btn_jouer2"].mouseEnabled=false;;
			if ( this["btn_jouer1"]) this["btn_jouer1"].mouseEnabled=true;
			
		}
		
		protected function evt_click_1joueur(event:Event):void
		{
			if ( this["btn_jouer2"]) this["btn_jouer2"].mouseEnabled=true;
			if ( this["btn_jouer1"]) this["btn_jouer1"].mouseEnabled=false;
			
		}
		
		protected function onPropose_play2(event:Event):void
		{
			if ( this["btn_jouer2"]) this["btn_jouer2"].mouseEnabled=true;
			if ( this["btn_jouer1"]) this["btn_jouer1"].mouseEnabled=true;
			
			if (_currentState!=STATE_JOUEUR_2)
				return;
			_currentState=STATE_PLAY_2
			gotoAndPlay("JOUER_2");
			
		}
		
		protected function onPropose2(event:Event):void
		{
			if ( this["btn_jouer2"]) this["btn_jouer2"].mouseEnabled=true;
			if ( this["btn_jouer1"]) this["btn_jouer1"].mouseEnabled=true;
			
			if (_currentState!=STATE_JOUEUR_1)
				return;
			_currentState=STATE_JOUEUR_2
			gotoAndPlay("PROPOSE_2");
			
		}
		
		protected function onHideLang(event:Event):void
		{
			hide();
		}
		
		protected function onShowLang(event:Event):void
		{
			_currentState=STATE_JOUEUR_1;
			gotoAndStop(1);
			show();
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
	}
}