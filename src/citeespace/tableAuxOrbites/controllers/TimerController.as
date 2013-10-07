package citeespace.tableAuxOrbites.controllers
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import utils.MyTrace;
	import utils.params.ParamsHub;

	public class TimerController
	{
		
		/* Gestion du singleton */
		static protected var _instance:TimerController;
		static public function get instance():TimerController
		{
			return (_instance != null) ? _instance : new TimerController();
		}
	
		
		public function TimerController()
		{
			if (_instance != null) return;
			_instance = this;
			
		}
		
		internal var timerInactiviteWarning:Timer;
		internal var timerInactiviteVeille:Timer;
		internal var timerChoixLangue:Timer;
		internal var timer2ndJoueur:Timer;
		internal var timerChoixSatellite:Timer;
		internal var timerPlacementSatellite:Timer;
		internal var timerIdentifierSatellite:Timer;
		internal var timerReglerFrequence:Timer;
		internal var timerIdentifierSignal:Timer;
		internal var timerChoixFin:Timer;
		
		
		internal function initTimers():void
		{
			var params:ParamsHub = DataCollection.params;
			timerInactiviteWarning 		= new Timer(1000* params.getNumber('timer_inactivite_warning', 200), 1);
			timerInactiviteVeille 		= new Timer(1000* params.getNumber('timer_inactivite_veille', 260), 1);
			timerChoixLangue 			= new Timer(1000* params.getNumber('timer_choix_langue', 30), 1);
			timer2ndJoueur				= new Timer(1000* params.getNumber('timer_2nd_Joueur', 30), 1);
			timerChoixSatellite 		= new Timer(1000* params.getNumber('timer_choix_satellite', 30), 1);
			timerPlacementSatellite 	= new Timer(1000* params.getNumber('timer_placement_satellite', 30), 1);
			timerIdentifierSatellite	= new Timer(1000* params.getNumber('timer_identifier_satellite', 30), 1);
			timerReglerFrequence        = new Timer(1000* params.getNumber('timer_regler_frequence', 30), 1);
			timerIdentifierSignal		= new Timer(1000* params.getNumber('timer_identifier_signal', 30), 1);
			timerChoixFin				= new Timer(1000* params.getNumber('timer_choix_fin', 30), 1);
			
			timerInactiviteWarning.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_InactiviteWarning);
			timerInactiviteVeille.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_InactiviteVeille);
			timerChoixLangue.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_ChoixLangue);
			timer2ndJoueur.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_Timer2ndJoueur);
			timerChoixSatellite.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_ChoixSatellite);
			timerPlacementSatellite.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_PlacementSatellite);
			timerIdentifierSatellite.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_IdentifierSatellite);
			timerReglerFrequence.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_ReglerFrequence);
			timerIdentifierSignal.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_IdentifierSignal);
			timerChoixFin.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete_ChoixFin);
			
			
			
		}
		
				
		
		
		internal var _warningDisplayed:Boolean = false;
		internal function onTimerComplete_InactiviteWarning(event:TimerEvent):void
		{
			timerInactiviteWarning.reset();
			timerInactiviteWarning.start();
			
			
			switch(GameController.instance.currentState)
			{
				// SITUATION OU L'inactivité de compte pas
				case GameController.STATE_ACCROCHE:
				case GameController.STATE_CHOIX_LANGUE:
				case GameController.STATE_CHOIX_SATELLITE:
				case GameController.STATE_PLACEMENT_SATELLITE_INIT:
				case GameController.STATE_VIDEO_CONCLUSION:
					_userActivityUpdate();
					return;
					break;
				case GameController.STATE_PLACEMENT_SATELLITE_ANIMCOMPLET:
				case GameController.STATE_CHOIX_SATELLITE_ANIMCOMPLET:
					// Ici on continue, le timer a sa pertinence
					break;
				
			}
			// Si une voix est en cours on attendra la fin de la voix
			if (SoundController.instance.lastSoundChannel != null) {
				_userActivityUpdate();
				return;
			}
			
			
			MyTrace.put("INACTIVITE DETECTÉE");
			warningTimeoutVisibility = true;
			
		}
		internal function _userActivityUpdate():void
		{
			if (timerInactiviteVeille) {
				timerInactiviteVeille.reset();
				timerInactiviteVeille.start();
			}
			if (timerInactiviteWarning) { 
				timerInactiviteWarning.reset();
				timerInactiviteWarning.start();
			}
			/*
			if (timerChoixLangue && timerChoixLangue.running) {
				timerChoixLangue.reset();
				timerChoixLangue.start();
			}
			*/
			warningTimeoutVisibility = false;
		}
		
		internal function set warningTimeoutVisibility(value:Boolean):void
		{
			if (value == _warningDisplayed) return;
			_warningDisplayed = value;
			if (_warningDisplayed) {
				GameLogicEvent.dispatch(GameLogicEvent.SHOW_TIMEOUT_WARNING);
			} else {
				GameLogicEvent.dispatch(GameLogicEvent.HIDE_TIMEOUT_WARNING);
			}
		}
		
		internal function onTimerComplete_InactiviteVeille(event:TimerEvent):void
		{
			
			timerInactiviteVeille.reset();
			timerInactiviteVeille.start();
			
			if (GameController.instance.currentState == GameController.STATE_ACCROCHE) return;
			if (!_warningDisplayed) return;
			showWaitLoop();
		}
		
		internal function onTimerComplete_ChoixLangue(event:TimerEvent):void
		{
			if (GameController.instance.currentState != GameController.STATE_CHOIX_LANGUE) return;
			showWaitLoop();
		}
		
		internal function onTimerComplete_Timer2ndJoueur(event:TimerEvent):void
		{
			if (GameController.instance.currentState != GameController.STATE_CHOIX_LANGUE) return;
			GameController.instance.timer2ndJoueurComplet();
		}
		
		internal function onTimerComplete_ChoixSatellite (event:TimerEvent):void
		{
			if (GameController.instance.currentState != GameController.STATE_CHOIX_SATELLITE_ANIMCOMPLET) return;
			showWaitLoop();
		}
		
		protected function onTimerComplete_PlacementSatellite(event:TimerEvent):void
		{
			if (GameController.instance.currentState != GameController.STATE_PLACEMENT_SATELLITE_ANIMCOMPLET) return;
			//TODO : continuer avec une proposition automatique
			GameController.instance.startPhase_placementSatelliteTimeOut()
			//GameLogicEvent.dispatch(GameLogicEvent.PLACEMENT_TIMEOUT);
			
		}
		protected function onTimerComplete_IdentifierSatellite(event:TimerEvent):void
		{
			if (GameController.instance.currentState == GameController.STATE_IDENTIFIER_SATELLITE_START ||  GameController.instance.currentState ==GameController.STATE_IDENTIFIER_SATELLITE_TEST2) {
				GameController.instance.startPhase_IdentifierSatelliteTimeOut()
			}
			return;

			
		}
		
		protected function onTimerComplete_ReglerFrequence(event:TimerEvent):void
		{
			if (GameController.instance.currentState == GameController.STATE_REGLER_FREQUENCE_START ) {
				GameController.instance.startPhase_ReglerFrequenceTimeOut()
			}
			return;
		}
		
		protected function onTimerComplete_IdentifierSignal(event:TimerEvent):void
		{
			if (GameController.instance.currentState == GameController.STATE_IDENTIFIER_SIGNAL_START ) {
				GameController.instance.startPhase_IdentifierSignalTimeOut()
			}
			return;
		}
		protected function onTimerComplete_ChoixFin(event:TimerEvent):void
		{
			if (GameController.instance.currentState == GameController.STATE_CHOIX_FIN ) {
				GameController.instance.startPhase_ChoixFinTimeOut()
			}
			return;
			
		}
		
		
		private var _timerToShowStartTime:int;
		private var _timerToShow:Timer;
		
	
		
		public function get timerToShow():Timer 
		{
			return _timerToShow;
		}
		public function get timerToShowStartTime():int 
		{
			return _timerToShowStartTime;
		}
		
		public function showWaitLoop(event:Event=null):void
		{
			
			MyTrace.put("GameController.showWaitLoop()");
			warningTimeoutVisibility=false;
			timerInactiviteVeille.stop();
			timerInactiviteWarning.stop();
			
			// On s'assure qu'aucune voix n'est encore en cours, sans callbacks
			SoundController.instance._stopAllVoices();
			SoundController.instance._stopSfxAmbiance();
			
			GameController.instance.startGame();
		}
		
		
		internal function _startTimer(aTimer:Timer):void
		{
			aTimer.reset();
			aTimer.start();
			_timerToShow = aTimer;
			_timerToShowStartTime = getTimer();
			GameLogicEvent.dispatch(GameLogicEvent.START_CHRONO, (aTimer.delay/1000));
		}
		
		internal function pauseTimer():void
		{
			_timerToShow.stop();
		}
		internal function resumeTimer():void
		{
			_timerToShow.start();
		}
	}
}