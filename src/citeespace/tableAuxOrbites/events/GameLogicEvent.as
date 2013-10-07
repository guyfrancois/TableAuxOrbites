package citeespace.tableAuxOrbites.events
{
	import utils.events.EventChannel;

	/**
	 * citeespace.planisphere.events.GameLogicEvent
	 * @author SPS
	 * @version 1.0.0 2011 11 10 Création
	 */
	public class GameLogicEvent extends TableAuxOrbitesEvent
	{
		
		/* ----  ---- */
		/*
		static public const SHOW_VEILLE:String = 'show_veille';
		static public const HIDE_VEILLE:String = 'hide_veille';
		*/
		
		/* --------------- Elements des phases de jeu */
		/* Phase d'accroche publique */
		static public const START_ACCROCHE:String 		  = 'startAccroche';
		/* Affiche l'accroche sans relancer l'anim */
		static public const SHOW_ACCROCHE:String 		  = 'showAccroche';
		static public const HIDE_ACCROCHE:String 		  = 'hideAccroche';
		static public const SHOW_TIMEOUT_WARNING:String   = 'show_timeout_warning';
		static public const HIDE_TIMEOUT_WARNING:String   = 'hide_timeout_warning';
		/* Phase d'enrolement */
		static public const LANG_CHOICE_SHOW:String 	= 'lang_choice_show';
		static public const LANG_CHOICE_HIDE:String 	= 'lang_choice_hide';
		/*
		static public const SHOW_ENROLEMENT:String 		  = 'show_enrolement';
		static public const SHOW_ENROLEMENT_CHRONO:String = 'show_enrolement_chrono';
		static public const HIDE_ENROLEMENT_CHRONO:String = 'hide_enrolement_chrono';
	
		static public const ENROLEMENT_TIMER_END:String   = 'enrolementTimerEnd';
		static public const ENROLEMENT_LANG_CHANGE:String = 'enrolement_lang_change';
		*/
		
		static public const SATELLITE_CHOICE_SHOW:String 	= 'satellite_choice_show';
		static public const SATELLITE_CHOICE_HIDE:String 	= 'satellite_choice_hide';
		static public const SATELLITE_CHOICE_HIDEQUICK:String 	= 'satellite_choice_hideQuick';
		
		
		static public const PLACEMENT_SHOW:String 	= 'placement_show';
		static public const PLACEMENT_TIMEOUT:String   = 'PLACEMENT_TIMEOUT';
		static public const PLACEMENT_CONCLUSION:String   = 'PLACEMENT_CONCLUSION';
		static public const PLACEMENT_HIDE:String 	= 'placement_hide';
		
		static public const IDENTIFIER_SHOW:String 	= 'IDENTIFIER_SHOW';
		static public const IDENTIFIER_ERREUR:String 	= 'IDENTIFIER_ERREUR';
		static public const IDENTIFIER_SUPPRIMER:String 	= 'IDENTIFIER_SUPPRIMER';
		static public const IDENTIFIER_CLEAR_REPONSE:String 	= 'IDENTIFIER_CLEAR_REPONSE';
		public static const IDENTIFIER_AFFICHE_REPONSE:String	= 'IDENTIFIER_AFFICHE_REPONSE';
		static public const IDENTIFIER_CONCLUSION:String 	= 'IDENTIFIER_CONCLUSION';
		static public const IDENTIFIER_HIDE:String 	= 'IDENTIFIER_HIDE';
		
		static public const REGLER_FREQUENCE_SHOW:String="REGLER_FREQUENCE_SHOW";
		static public const REGLER_FREQUENCE_HIDE:String="REGLER_FREQUENCE_HIDE";
		
		static public const FREQUENCEETIMAGE_SHOW:String="FREQUENCEETIMAGE_SHOW";
		static public const FREQUENCEETIMAGE_HIDE:String="FREQUENCEETIMAGE_HIDE";
		
		static public const REGLER_FREQUENCE_START:String="REGLER_FREQUENCE_START";
		
		static public const REGLER_FREQUENCE_CONCLUSION:String="REGLER_FREQUENCE_CONCLUSION";
		
		static public const FREQUENCEETIMAGE_VIDEO:String="FREQUENCEETIMAGE_VIDEO";
		
		static public const IDENTIFIER_SIGNAL_SHOW:String="IDENTIFIER_SIGNAL_SHOW";
		static public const IDENTIFIER_SIGNAL_HIDE:String="IDENTIFIER_SIGNAL_HIDE";
		static public const IDENTIFIER_SIGNAL_ERREUR:String="IDENTIFIER_SIGNAL_ERREUR";
		static public const IDENTIFIER_SIGNAL_AFFICHE_REPONSE:String="IDENTIFIER_SIGNAL_AFFICHE_REPONSE";
		static public const IDENTIFIER_SIGNAL_CONCLUSION:String="IDENTIFIER_SIGNAL_CONCLUSION";
		
		
		public static const CONCLUSION_VIDEO_COMPLETE:String="CONCLUSION_VIDEO_COMPLETE";
		
		
	
		
		static public const FUSEE_SHOW:String 	= 'fusee_show';
		static public const FUSEE_HIDE:String 	= 'fusee_hide';
		
		
		
		
		static public const COMMON_DOCK_SHOW:String 	= 'common_dock_show';
		static public const COMMON_DOCK_HIDE:String 	= 'common_dock_hide';
		static public const COMMON_DOCK_EXTENDS:String 	= 'common_dock_extends';
		static public const COMMON_DOCK_THUMB_SHOW:String	= 'common_dock_thumb_show';
		
		static public const USER_DOCK_SHOW:String 	= 'user_dock_show';
		static public const USER_DOCK_SHOW2:String 	= 'user_dock_show2';
		static public const USER_DOCK_HIDE:String 	= 'user_dock_hide';
		
		public static const USER_VALIDER_SHOW:String = 'user_valider_show';
		public static const USER_VALIDER_HIDE:String = 'user_valider_hide';
		public static const USER_VALIDE:String = 'user_valide';
		
		
		
		
		static public const LANGAGE_CHANGE:String 		= 'langage_change';
		static public const LANGAGE_CHANGE_2:String 		= 'langage_change_2';
		
		
		
		static public const START_INTRO:String 			= 'startIntro';
		
		 
		static public const HIDE_VIDEO:String = 'hide_video';
		static public const SHOW_VIDEO:String = 'show_video';
		static public const VIDEO_STARTED:String = 'video_started';
		static public const START_CHRONO:String 		  = 'start_chrono';
		static public const CHRONO_ENABLE:String 		  = 'chrono_enable';
		static public const CHRONO_DISABLE:String 		  = 'chrono_disable';
		
		
		
		static public const DISPLAY_PLAYER_TEXTS:String = 'display_player_texts';
		static public const DISPLAY_CREDITS:String 		= 'display_credits';
		static public const DISPLAY_CREDITS_FIN:String 	= 'display_credits_fin';
		static public const HIDE_CREDITS_FIN:String 	= 'hide_credits_fin';
		static public const CREDITS_FIN_COMPLETE:String 	= 'credits_fin_complete';
		static public const  FIN_SHOW:String = 'fin_show';
		static public const  FIN_HIDE:String  = 'fin_hide';
		
		
		static protected const EVENT_CHANNEL_NAME:String = 'tableAuxOrbitesLogicChannel';
		
		public function GameLogicEvent(type:String, initialData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, initialData, bubbles, cancelable);
		}
		
		/**
		 * Alias pour un (new GameLogicEvent(type, initialData)).dispatch() qui diffusera
		 * l'événement type dans l'EventChannel de ces événements
		 * 
		 * @param type
		 * @param initialData
		 * @return 
		 * 
		 */
		static public function dispatch(type:String, initialData:Object=null):GameLogicEvent
		{
			var notif:GameLogicEvent = new GameLogicEvent(type, initialData);
			notif.dispatch();
			return notif;
		}
		
		override public function dispatch():void 
		{
			GameLogicEvent.channel.dispatchEvent(this);
		}
		
		
		
		
		
		
		static private var _channel:EventChannel; 
		
		
		
		
	
		
		static public function get channel():EventChannel
		{
			if (_channel == null) {
				_channel = EventChannel.get(EVENT_CHANNEL_NAME);
			}
			return _channel;
		}
	}
}