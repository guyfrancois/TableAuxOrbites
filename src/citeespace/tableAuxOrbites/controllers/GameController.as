package citeespace.tableAuxOrbites.controllers
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.F_ui_userDock;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonSelfName;
	import citeespace.tableAuxOrbites.models.TextInfo;
	
	import com.greensock.OverwriteManager;
	import com.greensock.plugins.FrameLabelPlugin;
	import com.greensock.plugins.FramePlugin;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.casalib.util.ArrayUtil;
	import org.tuio.TuioTouchEvent;
	
	import pensetete.textes.TextPlayListItem;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.events.DataBringerEvent;
	import utils.events.EventChannel;
	import utils.params.ParamsHub;
	import utils.strings.TokenUtil;

	/*
	Affichage et lecture de textes :
	
	var txtId:String = 'resultatVote_8'
	// Une voix-off précède l'évolution du faceteur de risque
	var items:Array = TextPlayListItem.loadFromXmllist(txts.getTextXmlNodes(txtId, getLangMajoritaire()));
	_playItemsVoice(items, _onFinCas_EvolutionFacteurs)._playNextVoice();
	// Affichage sur les consoles
	var txtEvt:GameLogicEvent = new GameLogicEvent(GameLogicEvent.DISPLAY_PLAYER_TEXTS, txtId);
	txtEvt.dispatch();
	*/
	

	
	

	/**
	 * citeespace.planisphere.controllers.GameController
	 * @author SPS
	 * @version 1.0.0 2011 01 24 Creation
	 * @version 1.0.7 2011 03 10 Modif accroche -> son joué le plus longtemps possible
	 */
	public class GameController
	{
		private var _currentState:String = STATE_INIT;
		static public const STATE_INIT:String        				= 'init';
		/**
		 * Etat de veille, avec boucle d'accroche invitant le visiteur à toucher l'écran 
		 */
		static public const STATE_ACCROCHE:String    				= 'accroche';
		/**
		 * Enrolement des joueurs : construction de l'ui et choix de la langue 
		 */		
		static public const STATE_CHOIX_LANGUE:String  				= 'choix_langue';
	 
		
		/* Gestion des phases hors jeu */
		
		static public const STATE_CHOIX_SATELLITE:String 				= 'choix_satellite';
		
		static public const STATE_CHOIX_SATELLITE_ANIMCOMPLET:String 	= 'choix_satellite_animcomplet';
		
		static public const STATE_PLACEMENT_SATELLITE_INIT:String 	= 'placement_satellite_init';
		
		static public const STATE_PLACEMENT_SATELLITE_ANIMCOMPLET:String 	= 'state_placement_satellite_animcomplet';
		
		static public const STATE_PLACEMENT_SATELLITE_COMPLET:String 	= 'state_placement_satellite_complet';
		
		
		static public const STATE_IDENTIFIER_SATELLITE_INIT:String = 'state_identifier_satellite_init';
		static public const STATE_IDENTIFIER_SATELLITE_START:String = 'state_identifier_satellite_start';
		static public const STATE_IDENTIFIER_SATELLITE_TEST2:String = 'state_identifier_satellite_test2';
		static public const STATE_IDENTIFIER_SATELLITE_VALIDATION:String = 'state_identifier_satellite_validation';
		static public const STATE_IDENTIFIER_SATELLITE_VALIDATION2:String = 'state_identifier_satellite_validation2';
		static public const STATE_IDENTIFIER_SATELLITE_COMPLET:String = 'state_identifier_satellite_complet';
		
		static public const STATE_REGLER_FREQUENCE:String='state_regler_frequence';
		static public const STATE_REGLER_FREQUENCE_START:String='state_regler_frequence_start';
		static public const STATE_REGLER_FREQUENCE_COMPLET:String='state_regler_frequence_complet';
		
		static public const STATE_IDENTIFIER_SIGNAL_INIT:String='state_identifier_signal_init';
		static public const STATE_IDENTIFIER_SIGNAL_START:String='state_identifier_signal_start';
		static public const STATE_IDENTIFIER_SIGNAL_VALIDATION:String='state_identifier_signal_validation';
		static public const STATE_IDENTIFIER_SIGNAL_COMMENTAIRE:String='state_identifier_signal_commentaire';
		static public const STATE_IDENTIFIER_SIGNAL_TRANSITION:String='state_identifier_signal_transition';
		
		static public const STATE_VIDEO_CONCLUSION:String='state_video_conclusion';
		
		static public const  STATE_CHOIX_FIN:String='state_choix_fin';
		
		
		/* Gestion du jeu */
		
	
		
		static private var _tweenLiteInited:Boolean = false;
		 
		
		
		/* Gestion du singleton */
		static protected var _instance:GameController;

		private var mainStage:Stage;

		public function get currentState():String
		{
			
			return _currentState;
		}

		public function set currentState(value:String):void
		{
			MyTrace.put("currentState ---------->"+value);
			
			_currentState = value;
			SoundController.instance.updateSfxAmbiance();
		}

		static public function get instance():GameController
		{
			return (_instance != null) ? _instance : new GameController();
		}
		
		internal function get logicEventChan():EventChannel { return GameLogicEvent.channel; }
		internal function get txts():DataCollection {
			return DataCollection.instance;
		}
		
		
	
		
		
		
		
		
		
		
		public function GameController()
		{
			if (_instance != null) return;
			_instance = this;
			
			// Paramétrage par défaut de TweenLite
			if (!_tweenLiteInited) {
				TweenPlugin.activate([FrameLabelPlugin, FramePlugin, TransformMatrixPlugin]);
				OverwriteManager.init(OverwriteManager.AUTO);
				_tweenLiteInited = true;

			}
			
			TimerController.instance.initTimers();
			
			// On se prépare à écouter les événements importants
			var navigChan:EventChannel = NavigationEvent.channel;
			// Ecoute des événements généras suites aux actions de l'utilisateur
			navigChan.addEventListener(NavigationEvent.ANIM_ACCROCHE_CLICKED, onAnimAcrocheClicked_handler);

			navigChan.addEventListener(NavigationEvent.SKIP_CURRENT_VOICE, SoundController.instance.onSkipCurrentVoice, false,0,true);
			
			
			navigChan.addEventListener(NavigationEvent.PLAYER_SATELLITE_ANIMCOMPLET, onPlayerSatelliteAnimcomplet);
			
			navigChan.addEventListener(NavigationEvent.PLAYER_SATELLITE_SELECTED, onPlayerSatelliteSelected);
			
			navigChan.addEventListener(NavigationEvent.SATELLITE_PLACEMENT_ANIMCOMPLET, onSatellitePlacementAnimcomplet);
			
			navigChan.addEventListener(NavigationEvent.SATELLITE_PLACEMENT_COMPLET, onSatellitePlacementComplet);
			
			navigChan.addEventListener(NavigationEvent.SATELLITE_PLACEMENT_END, onSatellitePlacementEnd);
			
			navigChan.addEventListener(NavigationEvent.IDENTIFIER_SATELLITE_INTROCOMPLET, onIdentifier_satellite_introComplet);
			
			//navigChan.addEventListener(NavigationEvent.IDENTIFIER_SATELLITE_CONCLUSIONCOMPLET, onIdentifier_satellite_introComplet);
			
			navigChan.addEventListener(NavigationEvent.SATELLITE_FREQUENCE_FOUND, onSatellite_Frequence_Found);
			
			navigChan.addEventListener(NavigationEvent.IDENTIFIER_SIGNAL_INTROCOMPLET, onIdentifier_signal_introComplet);
			
			navigChan.addEventListener(NavigationEvent.IDENTIFIER_SIGNAL_CONCLUSIONCOMPLET, onIdentifier_signal_conclusionComplet);
			

			/*
			navigChan.addEventListener(NavigationEvent.PLAYER_START_VOTE_SELECTED, onPlayerStartVoteClicked);
			*/
			
			// Gestion des boutons de controle global
			navigChan.addEventListener(NavigationEvent.BTN_HOME_CLICKED, onBtnHomeClicked);
			navigChan.addEventListener(NavigationEvent.DISPLAY_CREDITS, onBtnCreditClicked);
			
			navigChan.addEventListener(NavigationEvent.BTN_CHOIX_LANGUE_CLICKED, onBtnChoixLangueClicked);
			navigChan.addEventListener(NavigationEvent.BTN_VALIDER_CLICKED, onBtnValiderClicked);
			
			navigChan.addEventListener(NavigationEvent.BTN_QUITTER_CLICKED, onBtnQuitterClicked);
			navigChan.addEventListener(NavigationEvent.BTN_AUTRE_MISSION_CLICKED, onBtnAutreClicked);
			
			
			
			
			
		
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("jouer1"),evt_click_1joueur);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("jouer2"),evt_click_2joueur);
			
			
			// Ecoute des événements logiques
			logicEventChan.addEventListener(GameLogicEvent.CONCLUSION_VIDEO_COMPLETE, onConclusionVideoComplete);
			
			/*
			logicEventChan.addEventListener(GameLogicEvent.INDICE_FOUND_NOTIFICATION, onIndiceFound);
			logicEventChan.addEventListener(GameLogicEvent.VOTE_USER_CLICKED, onVoteUserClicked);
			logicEventChan.addEventListener(GameLogicEvent.CREDITS_FIN_COMPLETE, onCreditsFinComplete);
			*/
		//	logicEventChan.addEventListener(GameLogicEvent.ENROLEMENT_TIMER_END, onEnrolementTimeEnd_handler);
		/*
			logicEventChan.addEventListener(GameLogicEvent.VOTE_END_CHRONO, onVoteEndChrono_handler); // on laise la fin du chrono être émise par sa vue, pour s'assurer sa synchro
			logicEventChan.addEventListener(GameLogicEvent.FIN_CAS_VOTE_ANIM_CONSEQ_COMPLETE, _onAnimConseqAnimComplete_handler);
			logicEventChan.addEventListener(GameLogicEvent.FIN_CAS_OUTRO_COMPLETE, onCasOutroComplete_handler);
			*/
		}
		
		protected function onBtnCreditClicked(event:Event):void
		{
			SoundController.instance._playSfxInteraction('sfx_clic');
		}
		
		protected function onBtnAutreClicked(event:NavigationEvent):void
		{
			SoundController.instance._playSfxInteraction('sfx_clic');
			GameData.instance.setIdentification(event.data as Number,1);
			evalDecisionFin();
		}
		
		
		protected function onBtnQuitterClicked(event:NavigationEvent):void
		{
			SoundController.instance._playSfxInteraction('sfx_clic');
			GameData.instance.setIdentification(event.data as Number,2);
			evalDecisionFin();
		}
		
		protected function evalDecisionFin():void {
			if (currentState != STATE_CHOIX_FIN) return;
			if (GameData.instance.playerNumber==1) {
				GameLogicEvent.dispatch(GameLogicEvent.FIN_HIDE);
				TimerController.instance.pauseTimer();
				if (GameData.instance.getIdentification(1)==1) {
					restartGame();
				} else {
					closeGame();
				}
				
			} else {
				if (GameData.instance.getIdentification(1)!=0 && GameData.instance.getIdentification(2)!=0) {
					GameLogicEvent.dispatch(GameLogicEvent.FIN_HIDE);
					TimerController.instance.pauseTimer();
					if (GameData.instance.getIdentification(1)==2 && GameData.instance.getIdentification(2)==2) {
						closeGame();
					} else  {
						restartGame();
					}
				}
				
			}
		}
		
		protected function onBtnValiderClicked(event:NavigationEvent):void
		{
			switch(currentState)
			{
				case STATE_IDENTIFIER_SATELLITE_INIT:
				case STATE_IDENTIFIER_SATELLITE_START:
				case STATE_IDENTIFIER_SATELLITE_TEST2:
					startPhase_IdentifierSatelliteValider(Number(event.data));
					break;
				case STATE_IDENTIFIER_SIGNAL_START:
					startPhase_IdentifierSignalValider(Number(event.data));
					break;
			}
		}		
			
		
		
		
		
		public function get langChoiceEnabled():Boolean
		{
			switch(currentState)
			{
				case STATE_ACCROCHE:
				case STATE_CHOIX_LANGUE:
					return false
					break;
			}
			return true;
		}
		
		public function get homeButtonEnabled():Boolean
		{
			switch(currentState)
			{
				case STATE_ACCROCHE:
				case STATE_CHOIX_LANGUE:
					return false
					break;
			}
			return true;
		}
		
		public function get btnValiderEnabled():Boolean
		{
			MyTrace.put("btnValiderEnabled "+currentState);
			switch(currentState)
			{
				case STATE_IDENTIFIER_SATELLITE_INIT:
				case STATE_IDENTIFIER_SATELLITE_START:
				case STATE_IDENTIFIER_SATELLITE_TEST2:
				case STATE_IDENTIFIER_SIGNAL_START:	
					return true
					break;
			}
			return false;
		}
		
		
		
		/**
		 * Méthode de reset du jeu, à appeler lors d'un retour à la boucle initiale 
		 * @param event
		 */
		public function initGame(event:Event=null, targetStage:Stage=null):void
		{
			// On remet tous les scores et préférences à 0
			/*
			for each (var joueur:Joueur in joueurs) {
				joueur.dispose()();
			}
			joueurs = [];
			*/
			
			// On charge les divers scenarios
			/*
			var scenariosXmll:XMLList = TextsCollection.instance.loadedXML.scenariis.scenario;
			GameCas.parseScenariis(scenariosXmll);
			*/
			if (targetStage != null)
			{
				mainStage = targetStage;
				mainStage.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown_handler, false,0,true);
				mainStage.addEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp_handler, false,0,true);
				mainStage.addEventListener(TuioTouchEvent.TOUCH_MOVE, onTouchMove_handler, false,0,true);
			}
			
		}
		
		internal function onTouchMove_handler(event:TuioTouchEvent):void
		{
			TimerController.instance._userActivityUpdate();
		}
		
		internal function onTouchUp_handler(event:TuioTouchEvent):void
		{
			TimerController.instance._userActivityUpdate();
		}
		
		internal function onTouchDown_handler(event:TuioTouchEvent):void
		{
			TimerController.instance._userActivityUpdate();
		}
		
		
			
		
		protected function onBtnChoixLangueClicked(event:Event):void
		{
			restartGame()
		}
		
	
	
		
		
		protected function onBtnHomeClicked(event:Event):void
		{
			SoundController.instance._playSfxInteraction('sfx_clic');
			restartGame();
		}
		public function restartGame():void
		{
			_stopGame()
			startPhaseAccroche(true);
			startPhase_ChoixLangue();
		}
		
		public function closeGame():void {
			
			TimerController.instance.timerInactiviteVeille.stop();
			TimerController.instance.timerInactiviteWarning.stop();
			
			// On s'assure qu'aucune voix n'est encore en cours, sans callbacks
			SoundController.instance._stopAllVoices();

	//		SoundController.instance._stopSfxAmbiance();
			GameController.instance.startGame();
		}
		
		public function startGame(event:Event=null):void
		{
			_stopGame()
			// On s'assure de commence une partie vierge
			startPhaseAccroche();
			//startPhase_ChoixLangue();
			/*
			GameData.instance.playerNumber=1;
			GameData.instance.selectedSatellite=1;
			LangageController.instance.userLanguage="FR";
			*/
			
			
		}
		
		
		internal function _stopGame():void
		{
			GameData.instance.playerNumber=0;
			SoundController.instance._stopAllVoices();
			LangageController.instance.displaySsTitres(null); // On vire les sous-titres
			initUiItems();
			
			TimerController.instance.timerInactiviteVeille.reset();
			TimerController.instance.timerInactiviteVeille.start();
			TimerController.instance.timerInactiviteWarning.reset();
			TimerController.instance.timerInactiviteWarning.start();
			
			// On coupe les timer en cours (vote, ...)
			
			TimerController.instance.timerChoixSatellite.stop();
			TimerController.instance.timerChoixLangue.stop();
			TimerController.instance.timerChoixFin.stop();
			TimerController.instance.timerIdentifierSatellite.stop();
			TimerController.instance.timerIdentifierSignal.stop();
			TimerController.instance.timerPlacementSatellite.stop();
			TimerController.instance.timerReglerFrequence.stop();
			
			
		}
		
		
	
		
		private function startPhaseAccroche(bNoDisplay:Boolean=false):void
		{
			currentState 	= STATE_ACCROCHE;
			
			SoundController.instance._stopAllVoices();
		//	SoundController.instance._stopSfxAmbiance();
			
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			
			if (!bNoDisplay) 
				logicEventChan.dispatchEvent(new GameLogicEvent(GameLogicEvent.START_ACCROCHE));
			
			
			initUiItems();
		}
		
		
		
		
		/**
		 * Dispatch les événements adhoc pour que les divers éléments visuels 
		 * s'initialisent pour un début de partie 
		 * 
		 */
		internal function initUiItems():void
		{
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_HIDE);
			// En l'état initial, pas de vue 3D, pas de panel de vote, pas de dock utilisateur
			GameLogicEvent.dispatch(GameLogicEvent.FUSEE_SHOW);
			GameLogicEvent.dispatch(GameLogicEvent.LANG_CHOICE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.USER_DOCK_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.SATELLITE_CHOICE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.FREQUENCEETIMAGE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.FREQUENCEETIMAGE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.HIDE_VIDEO);
			GameLogicEvent.dispatch(GameLogicEvent.FIN_HIDE);
			NavigationEvent.dispatch(NavigationEvent.WINDOW_WITH_NAME_CLOSE_REQUEST,"*");
			
			// Les docks n'affichent que les sous-titres
			/*
			GameLogicEvent.dispatch(GameLogicEvent.USER_DOCKS_SHOW, C_UiPanel.STATE_SS_TITRE);
			*/
			
			
		}
		
		
		
		
		
		
		
		
		
		protected function onAnimAcrocheClicked_handler(event:Event):void
		{
			if (currentState != STATE_ACCROCHE) return;
			
			
			startPhase_ChoixLangue();
			//start_phase_identifier_satellite();
		}
		
		
		private function startPhase_ChoixLangue():void
		{
			GameData.instance.playerNumber=0
			LangageController.instance.userLanguage=null
			LangageController.instance.userLanguage2=null
				
			LangageController.instance.displaySsTitres(null);
			
			// On masque l'accroche
			var evtHideAccroche:GameLogicEvent = new GameLogicEvent(GameLogicEvent.HIDE_ACCROCHE);
			evtHideAccroche.dispatch();
			
			
			// On démarre une 'partie', on fait donc attention aux périodes d'inactivité
			TimerController.instance.timerInactiviteVeille.reset();
			TimerController.instance.timerInactiviteVeille.start();
			TimerController.instance.timerInactiviteWarning.reset();
			TimerController.instance.timerInactiviteWarning.start();
			
			SoundController.instance._stopAllVoices();
			
			// On affiche le choix de langue 
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.LANG_CHOICE_SHOW);
			GameLogicEvent.dispatch(GameLogicEvent.FUSEE_SHOW);
			
			currentState = STATE_CHOIX_LANGUE;
			
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._startTimer(TimerController.instance.timerChoixLangue);
			
		}
		
		
		
		/**
		 * Écouteur sur les sélection de joueurs
		 * @param event
		 * 
		 */
		
		internal function _onPlayerLangSelected_handler(language:String):void {
			TimerController.instance.pauseTimer();
			if (currentState != STATE_CHOIX_LANGUE) return;
			
			SoundController.instance._playSfxInteraction('sfx_clic');
			
			LangageController.instance.userLanguage = language;
			MyTrace.put("user 1 : Sélection de la langue :"+ LangageController.instance.userLanguage);
			SoundController.instance.playItemsVoice("bienvenue_general",_invite2ndJoueur);
			
			
			
		}
		
		private function _invite2ndJoueur():void
		{
			var arr_invite:Array=new Array();
			arr_invite=arr_invite.concat(LangageController.instance.getTextNodesLang("second_joueur","FR"));
			arr_invite=arr_invite.concat(LangageController.instance.getTextNodesLang("second_joueur","GB"));
			arr_invite=arr_invite.concat(LangageController.instance.getTextNodesLang("second_joueur","ES"));
			SoundController.instance._stopAllVoices();
			SoundController.instance._playItemsVoice(arr_invite,_startTimerJ2)._playNextVoiceItemLang();
		
		}
		
		private function _startTimerJ2():void
		{
			TimerController.instance._startTimer(TimerController.instance.timer2ndJoueur);
		}
		
		internal function timer2ndJoueurComplet():void {
			SoundController.instance.playItemsVoice("pas_de_second_joueur",evt_click_1joueur);
		}
		
		internal function _onPlayerLangSelected_handler2(language:String):void {
			TimerController.instance.pauseTimer();
			if (currentState != STATE_CHOIX_LANGUE) return;
			
			SoundController.instance._playSfxInteraction('sfx_clic');
			
			LangageController.instance.userLanguage2 = language;
			SoundController.instance._stopAllVoices();
			SoundController.instance._playItemsVoice(LangageController.instance.getTextNodesLang("bienvenue_general",LangageController.instance.userLanguage2),_startTimerJ2)._playNextVoiceItemLang()
			MyTrace.put("user 2 : Sélection de la langue :"+ LangageController.instance.userLanguage2);
		}
		
		protected function evt_click_1joueur(event:Event=null):void
		{
			
			SoundController.instance._stopAllVoices();
			SoundController.instance._playSfxInteraction('sfx_clic');
			TimerController.instance.pauseTimer();
			LangageController.instance.userLanguage2=null
			GameData.instance.playerNumber=1
			startPhase_ChoixSatellite();
		}	
		protected function evt_click_2joueur(event:Event):void {
			SoundController.instance._stopAllVoices();
			SoundController.instance._playSfxInteraction('sfx_clic');
			TimerController.instance.pauseTimer();
			GameData.instance.playerNumber=2

			SoundController.instance.playItemsVoice("bienvenue_a_deux",startPhase_ChoixSatellite);
		}
		
	
		
		private function startPhase_ChoixSatellite(event:Event=null):void
		{
			currentState = STATE_CHOIX_SATELLITE;
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_HIDE);
		 
			// On masque les choix de langue
			GameLogicEvent.dispatch(GameLogicEvent.LANG_CHOICE_HIDE);
			
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			
			TimerController.instance._userActivityUpdate();
		
			
//			// _stopSfxChrono();
			SoundController.instance._stopAllVoices();

//			
			// La langue a été choisie, on affiche le choix des satellites et les docks 
			
			GameLogicEvent.dispatch(GameLogicEvent.FUSEE_HIDE);
			
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_SHOW);
			
			// On commence à afficher les sous-titres
			GameLogicEvent.dispatch(GameLogicEvent.USER_DOCK_SHOW,F_ui_userDock.STATE_FULL);

			GameLogicEvent.dispatch(GameLogicEvent.SATELLITE_CHOICE_SHOW);
		}
		
		protected function onPlayerSatelliteAnimcomplet(event:Event):void
		{
			currentState= STATE_CHOIX_SATELLITE_ANIMCOMPLET;
			TimerController.instance._userActivityUpdate();
			TimerController.instance._startTimer(TimerController.instance.timerChoixSatellite);
			SoundController.instance._stopAllVoices();

		}	
		
		protected function onPlayerSatelliteSelected(event:NavigationEvent):void
		{
			TimerController.instance.pauseTimer();
			
			LangageController.instance.displaySsTitres(null);
			GameData.instance.selectedSatellite=event.data as Number;
			GameLogicEvent.dispatch(GameLogicEvent.SATELLITE_CHOICE_HIDEQUICK);
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_EXTENDS);
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_THUMB_SHOW,1);
			NavigationEvent.dispatch(NavigationEvent.WINDOW_WITH_NAME_CLOSE_REQUEST,"*");
			startPhase_placementSatellite()
			
			
		}
		
		
	
		
		protected function startPhase_placementSatellite():void {
			LangageController.instance.displaySsTitres(null);
			TimerController.instance._userActivityUpdate();
			currentState= STATE_PLACEMENT_SATELLITE_INIT;
			
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_SHOW);
			GameLogicEvent.dispatch(GameLogicEvent.USER_DOCK_SHOW2);
			
			
		}
		

		protected function onSatellitePlacementAnimcomplet(event:NavigationEvent):void
		{
			start_PlacementAnimcomplet();
		}
		// "placer le satellite " avec timeout
		protected function start_PlacementAnimcomplet():void
		{
			currentState= STATE_PLACEMENT_SATELLITE_ANIMCOMPLET;
			TimerController.instance._userActivityUpdate();
			TimerController.instance._startTimer(TimerController.instance.timerPlacementSatellite);
		}
		
		private var sync_startPhase_placementSatelliteConclusion:SyncVoiceAnim
		protected function onSatellitePlacementComplet(event:NavigationEvent):void
		{
			TimerController.instance.pauseTimer();
			sync_startPhase_placementSatelliteConclusion=new SyncVoiceAnim(startPhase_placementSatelliteConclusion);
			currentState= STATE_PLACEMENT_SATELLITE_COMPLET;
			SoundController.instance._playSfxInteraction('sfx_indice_trouve');
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_TIMEOUT);
			LangageController.instance.displaySsTitresAndVoice("placement_satellite_ok_01_"+GameData.instance.playerNumber+"j",sync_startPhase_placementSatelliteConclusion.cb_voiceTrue);
		}

		internal function startPhase_placementSatelliteTimeOut():void {
			TimerController.instance.pauseTimer();
			sync_startPhase_placementSatelliteConclusion=new SyncVoiceAnim(startPhase_placementSatelliteConclusion);
			currentState= STATE_PLACEMENT_SATELLITE_COMPLET;
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_TIMEOUT);
			LangageController.instance.displaySsTitresAndVoice("placement_satellite_err_01",sync_startPhase_placementSatelliteConclusion.cb_voiceTrue);
			
		}
		
		protected function onSatellitePlacementEnd(event:NavigationEvent):void {
			sync_startPhase_placementSatelliteConclusion.cb_animTrue();
		}
		
		public function startPhase_placementSatelliteConclusion():void {
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_CONCLUSION);
			LangageController.instance.displaySsTitresAndVoice("placement_satellite"+GameData.instance.selectedSatellite+"_conclusion",startPhase_placementSatellite_end);
		}
		
		private function startPhase_placementSatellite_end():void {
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_THUMB_SHOW,2);
			//LangageController.instance.displaySsTitresAndVoice("placement_satellite_transition",start_phase_identifier_satellite);
			new DelayedCall(start_phase_identifier_satellite,txts.getParamNumber("STATE_PLACEMENT_SATELLITE_COMPLET",500));
			//start_phase_identifier_satellite();
			
		}
		
		private var sync_start_phase_identifier_satellite:SyncVoiceAnim
		public  function start_phase_identifier_satellite():void {
			if (currentState != STATE_PLACEMENT_SATELLITE_COMPLET) return;
			LangageController.instance.displaySsTitres(null);
			GameLogicEvent.dispatch(GameLogicEvent.LANG_CHOICE_HIDE);
			
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._userActivityUpdate();
			currentState=STATE_IDENTIFIER_SATELLITE_INIT;
			
			sync_start_phase_identifier_satellite = new SyncVoiceAnim(start_phase_identifier_satellite_introComplet);
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SHOW);
			GameData.instance.nb_reponses=0;
			LangageController.instance.displaySsTitresAndVoice("identifier_satellite_01",sync_start_phase_identifier_satellite.cb_voiceTrue);
		}
		protected function onIdentifier_satellite_introComplet(event:NavigationEvent):void
		{
			sync_start_phase_identifier_satellite.Anim=true;
		}
		
		private function start_phase_identifier_satellite_introComplet():void
		{
			currentState=STATE_IDENTIFIER_SATELLITE_START
			// uniquement par rapport au action de l'user conserné NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._userActivityUpdate();
			TimerController.instance._startTimer(TimerController.instance.timerIdentifierSatellite);
			
		}
		
		
		internal function startPhase_IdentifierSatelliteValider(idUser:Number):void
		{
			// qui valide ? les 2 on validé ??
			GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_HIDE,idUser);
			GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDE,idUser);
			if (idUser==0) {
			_startPhase_IdentifierSatelliteValider();
			} else {
				
				GameData.instance.nb_reponses++;
				if (GameData.instance.nb_reponses>=GameData.instance.playerNumber) {
					_startPhase_IdentifierSatelliteValider();
				} else {
					SoundController.instance._playSfxInteraction('sfx_clic');
				}
			}
		}
		internal function startPhase_IdentifierSatelliteTimeOut():void
		{
			_startPhase_IdentifierSatelliteValider();
		}
		private function _startPhase_IdentifierSatelliteValider():void {
			if (currentState==STATE_IDENTIFIER_SATELLITE_START || currentState == STATE_IDENTIFIER_SATELLITE_INIT) {
				currentState=STATE_IDENTIFIER_SATELLITE_VALIDATION;
				
				TimerController.instance.pauseTimer();
				TimerController.instance._userActivityUpdate();
				SoundController.instance._stopAllVoices();
				NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
				
				switch (GameData.instance.testIdentification()) {
					case 1 : // SUCCESS
						SoundController.instance._playSfxInteraction('sfx_indice_trouve');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS1_sat"+GameData.instance.selectedSatellite,_startPhase_IdentifierSatelliteConclusion);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE);

						break;
					case 2 :
						SoundController.instance._playSfxInteraction('sfx_indice_trouve');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS2_sat"+GameData.instance.selectedSatellite,_startPhase_IdentifierSatelliteConclusion);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE);
					
					break;
					case 3 :
						
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS3_sat"+GameData.instance.getBestIdentification(),_startPhase_IdentifierSatelliteTest2);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SUPPRIMER,GameData.instance.getBestIdentification());
						currentState=STATE_IDENTIFIER_SATELLITE_TEST2;
						NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
					
					break;
					case 4 :
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS4",_startPhase_IdentifierSatelliteTest2);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_ERREUR);
						currentState=STATE_IDENTIFIER_SATELLITE_TEST2;
						NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
								
					break;
					case 5 :
						/*
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS5",_startPhase_IdentifierSatelliteTest2);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SUPPRIMER,GameData.instance.getBestIdentification());
						*/
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS3_sat"+GameData.instance.getBestIdentification(),_startPhase_IdentifierSatelliteTest2);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SUPPRIMER,GameData.instance.getBestIdentification());
						currentState=STATE_IDENTIFIER_SATELLITE_TEST2;
						NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
						

					break;
					case 6 :
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS6",_startPhase_IdentifierSatelliteTest2);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SUPPRIMER,GameData.instance.getBestIdentification());
						currentState=STATE_IDENTIFIER_SATELLITE_TEST2;
						NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);

					break;
					default :
						MyTrace.put("ERREUR "+STATE_IDENTIFIER_SATELLITE_VALIDATION+" "+GameData.instance.testIdentification(),MyTrace.LEVEL_ERROR);
						break;
				} 
			} else if (currentState==STATE_IDENTIFIER_SATELLITE_TEST2 ) {
				currentState=STATE_IDENTIFIER_SATELLITE_VALIDATION2;
				NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
				TimerController.instance.pauseTimer();
				TimerController.instance._userActivityUpdate();
				SoundController.instance._stopAllVoices();
				switch (GameData.instance.testIdentification()) {
					case 1 : // SUCCESS
						SoundController.instance._playSfxInteraction('sfx_indice_trouve');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS1_sat"+GameData.instance.selectedSatellite,_startPhase_IdentifierSatelliteConclusion);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE);

						break;
					case 2 :
						SoundController.instance._playSfxInteraction('sfx_indice_trouve');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS2_sat"+GameData.instance.selectedSatellite,_startPhase_IdentifierSatelliteConclusion);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE);
						
						break;
					default :
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_satellite_CAS7_sat"+GameData.instance.selectedSatellite,_startPhase_IdentifierSatelliteConclusion);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE);

						break;
				}
			
				
			}
			GameData.instance.nb_reponses=0;
		}
		
		
		
		private function _startPhase_IdentifierSatelliteTest2() :void {
		
			currentState=STATE_IDENTIFIER_SATELLITE_TEST2
			//NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			//GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_AFFICHE_REPONSE);
			TimerController.instance._userActivityUpdate();
			
			TimerController.instance._startTimer(TimerController.instance.timerIdentifierSatellite);
		}
		
		private function _startPhase_IdentifierSatelliteConclusion() :void {
			currentState=STATE_IDENTIFIER_SATELLITE_COMPLET
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._userActivityUpdate();
			TimerController.instance.pauseTimer();
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_THUMB_SHOW,3);
			
			SoundController.instance._stopAllVoices();
			//LangageController.instance.displaySsTitresAndVoice("commentaire_orbite"+GameData.instance.selectedSatellite,startPhase_regler_frequence);
			
			new DelayedCall(startPhase_regler_frequence,txts.getParamNumber("STATE_IDENTIFIER_SATELLITE_COMPLET",500));
			
			//LangageController.instance.displaySsTitresAndVoice("identifier_satellite_transition",startPhase_regler_frequence);
			
		}
		
		// public pour test
		public function startPhase_regler_frequence():void {
			if (currentState!=STATE_IDENTIFIER_SATELLITE_COMPLET) return;
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_HIDE);
			LangageController.instance.displaySsTitres(null);
			currentState=STATE_REGLER_FREQUENCE;
			
			GameLogicEvent.dispatch(GameLogicEvent.FREQUENCEETIMAGE_SHOW);
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_SHOW);
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_START);
			LangageController.instance.displaySsTitresAndVoice("regler_satellite_01",startPhase_regler_frequence_act);
		}
		
		private function startPhase_regler_frequence_act():void {
			currentState=STATE_REGLER_FREQUENCE_START;
			TimerController.instance._userActivityUpdate();
			TimerController.instance._startTimer(TimerController.instance.timerReglerFrequence);
			LangageController.instance.displaySsTitresAndVoice("regler_satellite_aide",null);
		}
		
		internal function startPhase_ReglerFrequenceTimeOut():void {
			currentState=STATE_REGLER_FREQUENCE_COMPLET;
			SoundController.instance._playSfxInteraction('sfx_indice_erreur');
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_CONCLUSION);
			LangageController.instance.displaySsTitresAndVoice("regler_satellite_timeout",startPhase_transition_identifier_signal);
		}
		
		
		private function onSatellite_Frequence_Found(event:NavigationEvent):void
		{
			currentState=STATE_REGLER_FREQUENCE_COMPLET;
			SoundController.instance._playSfxInteraction('sfx_indice_trouve');
			TimerController.instance.pauseTimer();
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_CONCLUSION);
			LangageController.instance.displaySsTitresAndVoice("regler_satellite_"+GameData.instance.playerNumber+"j_01",startPhase_transition_identifier_signal);
		}
		
		private function startPhase_transition_identifier_signal():void {
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_THUMB_SHOW,4);
			GameLogicEvent.dispatch(GameLogicEvent.REGLER_FREQUENCE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.FREQUENCEETIMAGE_VIDEO);
			startPhase_identifier_signal()
			//LangageController.instance.displaySsTitresAndVoice("identifier_signal_transition",startPhase_identifier_signal);
			
		}
		
		
		private function startPhase_identifier_signal():void {
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._userActivityUpdate();
			currentState=STATE_IDENTIFIER_SIGNAL_INIT;
			
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_SHOW, ArrayUtil.randomize([1,2,3]));
			
		}

		protected function onIdentifier_signal_introComplet(event:NavigationEvent):void
		{
			start_phase_identifier_signal_introComplet()
		}
		
		private function start_phase_identifier_signal_introComplet():void
		{
			currentState=STATE_IDENTIFIER_SIGNAL_START
			//NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			TimerController.instance._userActivityUpdate();
			GameData.instance.nb_reponses=0;
			TimerController.instance._startTimer(TimerController.instance.timerIdentifierSignal);
		}
		
		internal function startPhase_IdentifierSignalValider(idUser:Number):void
		{
			// qui valide ? les 2 on validé ??
			GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_HIDE,idUser);
			GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDE,idUser);
			if (idUser==0) {
				_startPhase_IdentifierSignalValider();
			} else {
				
				GameData.instance.nb_reponses++;
				if (GameData.instance.nb_reponses>=GameData.instance.playerNumber) {
					_startPhase_IdentifierSignalValider();
				} else {
					SoundController.instance._playSfxInteraction('sfx_clic');
				}
			}
			
		}
		internal function startPhase_IdentifierSignalTimeOut():void
		{
			_startPhase_IdentifierSignalValider();
		}
		
		private function _startPhase_IdentifierSignalValider():void {
				currentState=STATE_IDENTIFIER_SIGNAL_VALIDATION;
				TimerController.instance.pauseTimer();
				NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
				
				TimerController.instance._userActivityUpdate();
				switch (GameData.instance.testIdentificationSignal()) {
					case 1 : // SUCCESS
						SoundController.instance._playSfxInteraction('sfx_indice_trouve');
						LangageController.instance.displaySsTitresAndVoice("identifier_signal_CAS1",_startPhase_IdentifierSignalCommentaire);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_ERREUR,0);
						break;
					case 2 :// 1 seul de correct
						LangageController.instance.displaySsTitresAndVoice("identifier_signal_CAS2",_startPhase_IdentifierSignalCommentaire);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_ERREUR,GameData.instance.getWorstIdentificationSignal());
						
						break;
					case 3 :// même erreur
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_signal_CAS7",_startPhase_IdentifierSignalCommentaire);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_ERREUR,GameData.instance.getWorstIdentificationSignal());
						break;
					default :// 2 : erreur differents , incorrect, ou incomplet
						SoundController.instance._playSfxInteraction('sfx_indice_erreur');
						LangageController.instance.displaySsTitresAndVoice("identifier_signal_err_gen",_startPhase_IdentifierSignalCommentaire);
						GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_ERREUR,0);
						break;
				}
			
		}
		
		
		
		private function _startPhase_IdentifierSignalCommentaire() :void {
			if (currentState!=STATE_IDENTIFIER_SIGNAL_VALIDATION) return;
			currentState=STATE_IDENTIFIER_SIGNAL_COMMENTAIRE;
			NavigationEvent.dispatch(NavigationEvent.BTN_UPDATE_REQUEST);
			
			TimerController.instance._userActivityUpdate();
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_AFFICHE_REPONSE);
			LangageController.instance.displaySsTitresAndVoice("identifier_signal_sat"+GameData.instance.selectedSatellite+"_1",_startPhase_IdentifierSignalCommentaire_detail);
			
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_THUMB_SHOW,5);
		}
		
		private function _startPhase_IdentifierSignalCommentaire_detail() :void {
			if (currentState!=STATE_IDENTIFIER_SIGNAL_COMMENTAIRE) return;
			currentState=STATE_IDENTIFIER_SIGNAL_COMMENTAIRE;
			TimerController.instance._userActivityUpdate();
			
			LangageController.instance.displaySsTitresAndVoice("commentaire_signal_sat"+GameData.instance.selectedSatellite+"_1",_startPhase_transition_SignalConclusion_delay);
			
		}
		
		private function _startPhase_transition_SignalConclusion_delay():void {
			if (currentState!=STATE_IDENTIFIER_SIGNAL_COMMENTAIRE) return;
			new DelayedCall(_startPhase_transition_SignalConclusion,txts.getParamNumber("STATE_IDENTIFIER_SIGNAL_TRANSITION",500));
		}
		
		private var sync_startPhase_transition_SignalConclusion:SyncVoiceAnim
		
		private function _startPhase_transition_SignalConclusion() :void {
			if (currentState!=STATE_IDENTIFIER_SIGNAL_COMMENTAIRE) return;
			MyTrace.put("onIdentifier_signal_conclusionComplet");
			currentState=STATE_IDENTIFIER_SIGNAL_TRANSITION;
			sync_startPhase_transition_SignalConclusion = new SyncVoiceAnim(_startPhase_bilan);
			
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_CONCLUSION);
			GameLogicEvent.dispatch(GameLogicEvent.IDENTIFIER_SIGNAL_HIDE);
			
		
			TimerController.instance._userActivityUpdate();
			LangageController.instance.displaySsTitresAndVoice("bilan_0",sync_startPhase_transition_SignalConclusion.cb_voiceTrue);
			
				
		}
		protected function onIdentifier_signal_conclusionComplet(event:NavigationEvent):void
		{
			sync_startPhase_transition_SignalConclusion.Anim=true;
		}
		
		private function _startPhase_bilan() :void {
			LangageController.instance.displaySsTitresAndVoice("bilan_sat"+GameData.instance.selectedSatellite,_startPhase_bilan_fin);

		}
		private function _startPhase_bilan_fin() :void {
			LangageController.instance.displaySsTitresAndVoice("bilan_",_startPhase_video_Conclusion);

		}
		
		
	
		
		private function _startPhase_video_Conclusion():void  {
			currentState=STATE_VIDEO_CONCLUSION;
			GameLogicEvent.dispatch(GameLogicEvent.FREQUENCEETIMAGE_HIDE);
			
			var tokens:Object= {};
			tokens.satId = GameData.instance.selectedSatellite;
			tokens.lang = LangageController.instance.userLanguage;
			
			_ssTitreVideoStarted = false;
			GameLogicEvent.channel.removeEventListener(GameLogicEvent.VIDEO_STARTED, _conclusionVideoStarted);
			GameLogicEvent.channel.addEventListener(GameLogicEvent.VIDEO_STARTED, _conclusionVideoStarted);
			
			
			var strVid:String = txts.getParamString('url_videosconclusion');
			strVid = TokenUtil.replaceTokens(strVid, tokens);
			LangageController.instance.displaySsTitres(null);
			MyTrace.put("lecture de la vidéo " + strVid);
			GameLogicEvent.dispatch(GameLogicEvent.COMMON_DOCK_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.SHOW_VIDEO, strVid);
		}
		
		internal var _ssTitreVideoStarted:Boolean;
		
		internal function _conclusionVideoStarted(event:GameLogicEvent=null):void
		{
			GameLogicEvent.channel.removeEventListener(GameLogicEvent.VIDEO_STARTED, _conclusionVideoStarted);
			if (_ssTitreVideoStarted) return;
			_ssTitreVideoStarted = true;
			// On lance les sous-titres
			var txtId:String 	= "video_conclusion_sat"+ GameData.instance.selectedSatellite;
			LangageController.instance.displaySsTitres(txtId);
			
			new DelayedCall(_phaseConclusionUpdateUi, 2000);
			
		}
		
		internal function _phaseConclusionUpdateUi():void
		{
			if (currentState != STATE_VIDEO_CONCLUSION) return;
			
			// On ne masque les éléments de fond qu'une fois qu'on a laissé le temps à la vidéo de démarrer
			
			//GameLogicEvent.dispatch(GameLogicEvent.ANIMAL_BACKGROUND_HIDE);
		}
		
		protected function onConclusionVideoComplete(event:GameLogicEvent):void
		{
			// Fin de la vidéo, on la masque et on retourne au chxoi des animaux
			LangageController.instance.displaySsTitres(null);
			//	startPhaseCreditsFin();
			
			startPhase_fin();
		}
		
		protected function startPhase_fin():void {
			currentState = STATE_CHOIX_FIN
			GameData.instance.setIdentification(1,0);
			GameData.instance.setIdentification(2,0);
			TimerController.instance._startTimer(TimerController.instance.timerChoixFin);
			GameLogicEvent.dispatch(GameLogicEvent.FIN_SHOW);
		}
		
		public function startPhase_ChoixFinTimeOut():void
		{
			if (GameData.instance.getIdentification(1)==0) GameData.instance.setIdentification(1,2);
			if (GameData.instance.getIdentification(2)==0) GameData.instance.setIdentification(2,2);
			evalDecisionFin();
			
		}
		
		

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
	
	
	
	
	
	

	

		
		
		

		
		
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	
		private function startPhaseCreditsFin():void
		{
			// On coupe la vidéo si elle jouait
			GameLogicEvent.dispatch(GameLogicEvent.HIDE_VIDEO);
			GameLogicEvent.dispatch(GameLogicEvent.LANG_CHOICE_HIDE);
			GameLogicEvent.dispatch(GameLogicEvent.DISPLAY_CREDITS_FIN);
		}
		
		internal function onCreditsFinComplete(event:GameLogicEvent):void
		{
			GameLogicEvent.dispatch(GameLogicEvent.HIDE_CREDITS_FIN);
			
			var t_lang:String = LangageController.instance.userLanguage;
			restartGame();
			LangageController.instance.userLanguage = t_lang;
			
			//startPhase_ChoixAnimal();
		}		
		
		
		
		
		
		
		internal var _introStep:int;
		
		
		
		
		
			
		
	
	}
	
	
	
}

/**
 * @author GUYF
 * Helper class
 */
class SyncVoiceAnim
{
	private var _voice:Boolean=false;
	private var _Anim:Boolean=false;
	private var _callBack:Function
	public function SyncVoiceAnim(callBack:Function) 
	{
		this._callBack=callBack
	}
	
	public function get Anim():Boolean
	{
		return _Anim;
	}
	
	public function set Anim(value:Boolean):void
	{
		_Anim = value;
		tryTest()
	}
	
	public function get voice():Boolean
	{
		return _voice;
	}
	
	public function set voice(value:Boolean):void
	{
		_voice = value;
		tryTest()
	}
	
	public function cb_animTrue():void {
		Anim=true;
	}
	public function cb_voiceTrue():void {
		voice=true;
	}
	
	private function tryTest():void {
		if (_Anim && _voice && _callBack!=null) {
			_callBack.call();
			_callBack=null
		}
	}
}
	