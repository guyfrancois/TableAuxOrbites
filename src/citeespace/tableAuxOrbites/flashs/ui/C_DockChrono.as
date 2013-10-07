package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.TimerController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import utils.date.TimeUtils;
	import utils.events.EventChannel;

	/**
	 * Chronomètre inclus dans les docks
	 *
	 * @author sps
	 * @version 1.0.0 [22 nov. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.C_DockChrono
	 */
	public class C_DockChrono extends MovieClip
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var tf:TextField;
		public var anim:MovieClip;
		/* ----------------------------------------------------------------- */
		
		
		internal var _duration:Number = 30;
		internal var chronoStartTime:int;
		
		private function set tf_text(val:String):void {
			tf.text=val;
			if (this["tf2"]) this["tf2"].text=val; 
		}
		
		public function C_DockChrono()
		{
			super();
			stop();
			
			clipIsPlaying = false;
			anim.gotoAndStop(1);
			tf_text = '';
			
			if (stage) onAddedToStage_C_DockChrono(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_DockChrono, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_DockChrono, false,0,true);
			
		}
		
		protected function onRemovedFromStage_C_DockChrono(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onUpdateTimer);
			var chan:EventChannel = GameLogicEvent.channel;
			chan.removeEventListener(GameLogicEvent.START_CHRONO, onEvt_start_chrono);
			chan.removeEventListener(GameLogicEvent.CHRONO_DISABLE, onDisableChrono);
			chan.removeEventListener(GameLogicEvent.CHRONO_ENABLE, onEnableChrono);
		}
		
		protected function onAddedToStage_C_DockChrono(event:Event):void
		{
			// startChrono(); // départ automatique du chrono pour tests
			var chan:EventChannel = GameLogicEvent.channel;
			chan.addEventListener(GameLogicEvent.START_CHRONO, onEvt_start_chrono);
			chan.addEventListener(GameLogicEvent.CHRONO_DISABLE, onDisableChrono);
			chan.addEventListener(GameLogicEvent.CHRONO_ENABLE, onEnableChrono);
			
			// On regarde si un chrono est déjà en route
			var gCtrl:TimerController = TimerController.instance;
			if (gCtrl.timerToShow!= null) {
				duration = gCtrl.timerToShow.delay / 1000;
				startChrono(gCtrl.timerToShowStartTime);
			}
		}
		
		protected var _enabled:Boolean = true;
		protected function onEnableChrono(event:GameLogicEvent):void
		{
			_enabled = true;
		}
		
		protected function onDisableChrono(event:GameLogicEvent):void
		{
			_enabled = false;
			
			clipIsPlaying = false;
			anim.gotoAndStop(1);
			tf_text = '';
		}
		
		protected function onEvt_start_chrono(event:GameLogicEvent):void
		{
			duration = event.data as Number;
			startChrono();
		}
		
		/**
		 * Durée du chrono en secondes 
		 * @return 
		 */
		public function get duration():Number { return _duration; }
		public function set duration(value:Number):void
		{
			if (_duration == value) return;
			_duration = value;
		}
		
		public function startChrono(startTime:Number = NaN):void
		{
			chronoStartTime = isNaN(startTime) ? getTimer() : startTime;
			addEventListener(Event.ENTER_FRAME, onUpdateTimer, false,0,true);
			clipIsPlaying = true;
		}
		
		private var _remaining:Number;
		protected function onUpdateTimer(event:Event):void
		{
			if (!_enabled) return;
			
			var now:int = getTimer();
			var elapsed:int = now - chronoStartTime;
			var remaining:int = _duration * TimeUtils.SECONDES_TO_MS - elapsed;
			remaining = Math.max(0, Math.min(remaining, int.MAX_VALUE));
			
			var gCtrl:TimerController = TimerController.instance;
			if (gCtrl.timerToShow!= null) 
			{
				clipIsPlaying = gCtrl.timerToShow.running;
				if (!gCtrl.timerToShow.running) {
					remaining = _duration * TimeUtils.SECONDES_TO_MS;
					chronoStartTime = getTimer();
				}
				
			}
			_remaining=remaining *TimeUtils.MS_TO_SECONDES;
			// Formattage
			var str:String = TimeUtils.millisecondsToTimeString(remaining, TimeUtils.FORMAT_MINUTES | TimeUtils.FORMAT_SECONDS, TimeUtils.FORMAT_MINUTES);
			tf_text = str;
			anim.gotoAndStop(1+Math.floor(_remaining*anim.totalFrames/_duration))
		}
		
		protected var _clipIsPlaying:Boolean = true;

		public function get clipIsPlaying():Boolean
		{
			return _clipIsPlaying;
		}

		public function set clipIsPlaying(value:Boolean):void
		{
			if (value == _clipIsPlaying) return;
			_clipIsPlaying = value;
			/*
			if (value) {
				anim.play();
			} else {
				anim.stop();
			}*/
		}

		
	}
}