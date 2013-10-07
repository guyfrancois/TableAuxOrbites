package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import com.greensock.TweenLite;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import org.tuio.TuioTouchEvent;
	
	import utils.MyTrace;

	
	/**
	 * Classe associée à l'animation timeout.fla 
	 *
	 * @author Sps
	 *
	 * citeespace.planisphere.flashs.F_Anim_Timeout
	 */
	public class F_Anim_Timeout extends F_Anim_super
	{
	 
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var contents:MovieClip;
		
		protected var _clip_chrono:MovieClip;
		protected var _text_chrono:TextField;
		protected var _intitule:TextField;
		
		/* ----------------------------------------------------------------- */
		
		
		protected var _isActive:Boolean = false;

		private var durationChrono:Number;

		private var startTime:Number;
	 	
		public function F_Anim_Timeout()
		{
			super();
			visible = false;
			if (stage) initSwf();
			else addEventListener(Event.ADDED_TO_STAGE, initSwf);
			
			_clip_chrono = contents.getChildByName('clip_chrono') as MovieClip;
			_clip_chrono.stop();
			_text_chrono = contents.getChildByName('text_chrono') as TextField;
			_intitule = contents.getChildByName('intitule') as TextField;
			_text_chrono.text = '';
			_intitule.text = '';
		}
		
		public function show_timeout(event:Event=null):void
		{
			if (!visible)
			{
				TweenLite.killTweensOf(this);
				TweenLite.to(this, 1, {alpha:1});
			}
			visible = true;
			
			// On met à jour nos textes
			_intitule.htmlText = DataCollection.instance.getText('ui_avertissement_inactivite', LangageController.instance.userLanguage);
			
			
		}
		
		
		public function hide_timeout(event:Event=null):void
		{
			visible = false;
			
		}
		
		public function playTimeout(event:Event=null):void
		{
			//gotoAndStop(1);
			_isActive = true;
			stage.addEventListener(TuioTouchEvent.TAP, onTap_handler, false, 0, true);
			addEventListener(TuioTouchEvent.TAP, onTap_handler, false, 0, true);
			addEventListener(Event.ENTER_FRAME, updateChrono);
			//stage.addEventListener(MouseEvent.CLICK, onClickStage_handler, false, 0, true);
			
			// On calcule la durée à afficher
			var durVeille:Number  = DataCollection.params.getNumber('timer_inactivite_veille', 0);
			var durWarning:Number = DataCollection.params.getNumber('timer_inactivite_warning', 0);
			
			durationChrono = durVeille - durWarning; // Durée en seconde entre le moment d'apparition du warning et de la veille
			
			startTime = getTimer();
			
		}
		
		
		public function stopTimeout(event:Event=null):void
		{
			//gotoAndStop(2);
			_isActive = false;
			visible = false;
			//stage.removeEventListener(MouseEvent.CLICK, onClickStage_handler);
			stage.removeEventListener(TuioTouchEvent.TAP, onTap_handler);
			removeEventListener(TuioTouchEvent.TAP, onTap_handler);
			removeEventListener(Event.ENTER_FRAME, updateChrono);
		}
		
		
		protected function initSwf(event:Event=null):void
		{
			GameLogicEvent.channel.addEventListener(GameLogicEvent.SHOW_TIMEOUT_WARNING, onStartTimeout_handler);
			GameLogicEvent.channel.addEventListener(GameLogicEvent.HIDE_TIMEOUT_WARNING, onHideTimeout_handler);
			
		}
		
		
		
		protected function onStartTimeout_handler(event:Event):void
		{
			playTimeout();
			show_timeout();
			
		}
		
		protected function onHideTimeout_handler(event:Event):void
		{
			if (visible)
			{
				TweenLite.killTweensOf(this);
				TweenLite.to(this, 1, {alpha:0, delay:1, onComplete:hide_timeout});
			}
		}
		
		protected function onTap_handler(event:TuioTouchEvent):void
		{
			if (!_isActive) return;
			MyTrace.put('# timeout tap');
			stopTimeout();
			//NavigationEvent.channel.dispatchEvent(new NavigationEvent(NavigationEvent.ANIM_ACCROCHE_CLICKED));
		}
		
		
		protected function onClickStage_handler(event:Event):void
		{
			if (!_isActive) return;
			MyTrace.put('# timeout click');
			stopTimeout();
			//NavigationEvent.channel.dispatchEvent(new NavigationEvent(NavigationEvent.ANIM_ACCROCHE_CLICKED));
		}
		
		protected function updateChrono(event:Event):void
		{
			var elapsed:Number = getTimer() - startTime;
			var remaining:Number = durationChrono*1000 - elapsed;
			
			remaining = Math.max(0, Math.round(remaining/1000) );
			var str:String = '' + remaining;
			if (_text_chrono.text != str) {
				_text_chrono.text = str;
			}
		}
		
	 
		
	}
}