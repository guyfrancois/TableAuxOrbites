package citeespace.tableAuxOrbites.events
{
	import utils.events.EventChannel;

	/**
	 * 
	 *
	 * @author SPS
	 * @version 1.0.0 [10 nov. 2011][Seb] creation
	 *
	 * citeespace.planisphere.events.NavigationEvent
	 */
	public class NavigationEvent extends TableAuxOrbitesEvent
	{
		// --------------------------------------------------------------------
		// ELEMENTS GENERIQUES ------------------------------------------------
		// --------------------------------------------------------------------
		
		// SKIP_CURRENT_VOICE
		static public const SKIP_CURRENT_VOICE:String = 'skip_current_voice';
		static public const ANIM_ACCROCHE_CLICKED:String 	= 'anim_accroche_clicked';
		static public const PLAYER_LANG_SELECTED:String 	= 'playerLangSelected';
		
		static public const BTN_HOME_CLICKED:String 			= 'btn_home_clicked';
		static public const BTN_CHOIX_LANGUE_CLICKED:String 	= 'btn_choix_langue_clicked';
		static public const BTN_QUITTER_CLICKED:String 			= 'btn_quitter_clicked';
		static public const BTN_AUTRE_MISSION_CLICKED:String 	= 'btn_autre_mission_clicked';
		
		public static var DISPLAY_CREDITS:String	= 'display_credits';
		
		static public const BTN_VALIDER_CLICKED:String 			= 'btn_valider_clicked';
		
		static public const BTN_UPDATE_REQUEST:String = 'btn_update_request';
		
		
		// --------------------------------------------------------------------
		// ELEMENTS SPECIFIQUES AU table au orbite DES ANIMAUX --------------------
		// --------------------------------------------------------------------
		
		/**
		 * Evenement de notification de nouveau focus d'un indice, passé en argument {depth:int_newTargetDepth, target:DisplayObject}
		 */
		
		static public const PLAYER_SATELLITE_ANIMCOMPLET:String 	= 'player_satellite_animcomplet';
		static public const PLAYER_SATELLITE_SELECTED:String 		= 'player_satellite_selected';
		static public const SATELLITE_PLACEMENT_ANIMCOMPLET:String 	= 'satellite_placement_animcomplet';
		static public const SATELLITE_PLACEMENT_COMPLET:String 		= 'satellite_placement_complet';
		static public const SATELLITE_PLACEMENT_END:String 		= 'satellite_placement_end';
		
		static public const IDENTIFIER_SATELLITE_INTROCOMPLET:String	= 'identifier_satellite_introcomplet';
		static public const IDENTIFIER_SATELLITE_CONCLUSIONCOMPLET:String 		= 'identifier_satellite_conclusioncomplet';
		
		static public const SATELLITE_FREQUENCE_FOUND:String 		= 'satellite_frequence_found';
		
		static public const IDENTIFIER_SIGNAL_CONCLUSIONCOMPLET:String 		= 'identifier_signal_conclusioncomplet';
		static public const IDENTIFIER_SIGNAL_INTROCOMPLET:String 		= 'identifier_signal_introcomplet';
		
		public static var WINDOW_WITH_NAME_CLOSE_REQUEST:String	= 'window_with_name_close_request';
		public static var WINDOW_WITH_NAME_OPEN_REQUEST:String	= 'window_with_name_open_request';
		
		
		/*
		 * Evenements de la phase recherche d'indices
		 */
		/**
		 * Notification de dépôt par l'utilisateur d'un objet symbole, pour 
		 * tests par le GameController afin de provoque la réaction adhoc
		 */
		static public const OBJET_SYMBOLE_DROPPED:String = 'OBJET_SYMBOLE_DROPPED';
		/**
		 * Notification de réaction au dépôt par l'utilisateur d'un objet symbole
		 */
		static public const OBJET_SYMBOLE_RESULT:String = 'OBJET_SYMBOLE_DROPPED';
		
		
		// --------------------------------------------------------------------
		// ELEMENTS SPECIFIQUES A PHOTO-INTERPRETE ----------------------------
		// --------------------------------------------------------------------
		
		
		
		static protected const EVENT_CHANNEL_NAME:String = 'planisphereNavigationChannel';
		
		public function NavigationEvent(type:String, initialData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, initialData, bubbles, cancelable);
		}
		
		override public function dispatch():void 
		{
			NavigationEvent.channel.dispatchEvent(this);
		}
		
		/**
		 * Alias pour un (new NavigationEvent(type, initialData)).dispatch() qui diffusera
		 * l'événement type dans l'EventChannel de ces événements
		 * 
		 * @param type
		 * @param initialData
		 * @return 
		 * 
		 */
		static public function dispatch(type:String, initialData:Object=null):NavigationEvent
		{
			var notif:NavigationEvent = new NavigationEvent(type, initialData);
			notif.dispatch();
			return notif;
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