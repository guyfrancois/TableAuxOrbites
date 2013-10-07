package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import com.greensock.TweenLite;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import org.tuio.TuioTouchEvent;
	
	import utils.DelayedCall;
	import utils.MyTrace;

	/**
	 * citeespace.planisphere.flashs.F_Anim_Accroche
	 * 
	 * Classe associée à l'animation accroche.fla 
	 * 
	 * @author SPS
	 * @version 1.0.0 2011 01 25 Création
	 * @version 1.1.0 2011 02 03 Passage en mode touch
	 * @version 1.2.0 2011 11 10 Décinaison pour le planisphere de la Cité de l'Espace
	 */
	public class F_Anim_Accroche extends F_Anim_super
	{
	 
		protected var _isActive:Boolean = false;
		protected var swfContainer:MovieClip;
		
		public function F_Anim_Accroche()
		{
			super();
			visible = false;
			if (stage) initSwf();
			else addEventListener(Event.ADDED_TO_STAGE, initSwf);
			
		}
		
		public function show_accroche(event:Event=null):void
		{
			if (!visible)
			{
				TweenLite.killTweensOf(this);
				TweenLite.to(this, 1, {alpha:1});
			}
			visible = true;
			
		}
		
		public function hide_accroche(event:Event=null):void
		{
			visible = false;
		}
		
		public function playAccroche(event:Event=null):void
		{
			//gotoAndStop(1);
			_isActive = true;
			new DelayedCall(initTapHandler,250);
		}
		
		
		public function stopAccroche(event:Event=null):void
		{
			//gotoAndStop(2);
			_isActive = false;
			stage.removeEventListener(TuioTouchEvent.TAP, onTap_handler, false);
			
		}
		
		private function initTapHandler():void {
			if (_isActive)	{
				stage.addEventListener(TuioTouchEvent.TAP, onTap_handler, false, 0, true);
			}
		}
		
		
		protected function initSwf(event:Event=null):void
		{
			
			GameLogicEvent.channel.addEventListener(GameLogicEvent.START_ACCROCHE, onStartAccroche_handler);
			GameLogicEvent.channel.addEventListener(GameLogicEvent.SHOW_ACCROCHE, show_accroche);
			GameLogicEvent.channel.addEventListener(GameLogicEvent.HIDE_ACCROCHE, onHideAccroche_handler);
			
			swfContainer = new MovieClip();
			
			_loadSwf();
		}
		
		protected function _loadSwf():void
		{
			var url:String = DataCollection.instance.getParamString('url_swf_veille',"screensaver.swf");
			
			var loader:Loader = new Loader();
			swfContainer.addChild(loader);
			loader.load(new URLRequest(url));
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false,0,true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded, false, 0, true);
			
		}
		
		protected function onStartAccroche_handler(event:Event):void
		{
			playAccroche();
			show_accroche();
		}
		
		protected function onHideAccroche_handler(event:Event):void
		{
			if (visible)
			{
				/*
				TweenLite.killTweensOf(this);
				TweenLite.to(this, 1, {alpha:0, delay:1, onComplete:hide_accroche});
				*/
				hide_accroche();
			}
		}
		
		protected function onTap_handler(event:TuioTouchEvent):void
		{
			if (!_isActive) return;
			//MyTrace.put('# accroche tap');
			stopAccroche();
			NavigationEvent.channel.dispatchEvent(new NavigationEvent(NavigationEvent.ANIM_ACCROCHE_CLICKED));
		}
		
		
		protected function onClickStage_handler(event:Event):void
		{
			if (!_isActive) return;
			//MyTrace.put('# accroche click');
			stopAccroche();
			NavigationEvent.channel.dispatchEvent(new NavigationEvent(NavigationEvent.ANIM_ACCROCHE_CLICKED));
		}
		
		
		protected function onLoadError(event:IOErrorEvent):void
		{
			MyTrace.put("Erreur de chargement du swf de veille :" + event.text);
		}
		
		/*
		protected function onHideVeille_handler(event:Event):void
		{
			visible = false;
		}
		
		protected function onShowVeille_handler(event:Event):void
		{
			visible = true;
		}
		*/
		
		private function onAssetLoaded(event:Event):void
		{
			// Ok visuel chargé
			addChild(swfContainer);
			
			var scale:Number = DataCollection.params.getNumber('accroche_scale', 1);
			scaleX = scaleY = scale;
		}
		
	}
}