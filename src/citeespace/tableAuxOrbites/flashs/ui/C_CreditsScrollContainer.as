package citeespace.tableAuxOrbites.flashs.ui
{
	 
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import pensetete.managers.TactileScrollObserver;
	
	import utils.movieclip.MovieClipUtils;
	import utils.strings.TokenUtil;
	
	/**
	 * autoScrollComplete est dispatché automatiquement à la fin du scroll automatique 
	 */	
	[Event(name="autoScrollComplete", type="flash.events.Event")]
	
	/**
	 * 
	 *
	 * @author Sps
	 * @version 1.0.0 [6 janv. 2012][Sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.C_CreditsScrollContainer
	 */
	public class C_CreditsScrollContainer extends MovieClip
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var credits:MovieClip;
		public var mask_credits:DisplayObject;
		
		/* ----------------------------------------------------------------- */
		
		public function C_CreditsScrollContainer()
		{
			super();
			stop();
			
			_checkContainerScrollInit();
			
			mouseEnabled = true;
			
			if (stage) onAddedToStage_C_CreditsScrollContainer(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_CreditsScrollContainer, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_CreditsScrollContainer, false,0,true);
			
		}
		
		protected function onAddedToStage_C_CreditsScrollContainer(event:Event):void
		{
			
		}
		
		
		protected function onLoadingComplete(event:Event):void
		{
			_scrollObserver.resetScroll();
			if (_autoScrollInProgress)
			{
				startAutoScroll();
			}
		}
		
		protected var _lastLang:String;
		public function loadLang(lang:String = 'FR'):void
		{
			if (lang == null) lang = 'FR';
			
			if (lang == _lastLang) return;
			_lastLang = lang;
			
			// On supprime tous les childs de credits
			MovieClipUtils.removeAllChilds(credits);
			
			var url:String = DataCollection.params.getString('url_credits_popup');
			var tokens:Object = {lang:lang};
			url = TokenUtil.replaceTokens(url, tokens);
			var loader:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete, false,0,true);
			loader.load(urlReq);
			credits.addChild(loader);
		}
		
		
		protected var _autoScrollInProgress:Boolean;
		public function startAutoScroll():void
		{
			_autoScrollInProgress = true;
			_scrollObserver.resetScroll();
			var duration:Number = DataCollection.params.getNumber('timer_duree_affichage_credits_popup', 30);
			_scrollObserver.startAutoScroll(duration);
		}
		
		
		protected function onRemovedFromStage_C_CreditsScrollContainer(event:Event):void
		{
			 
		}
		
		protected var _scrollObserver:TactileScrollObserver;
		protected function _checkContainerScrollInit():void
		{
			if (!credits || !mask_credits) return;
			if (_scrollObserver != null) return;
			_scrollObserver = new TactileScrollObserver(credits, mask_credits, false, false);
			credits.tactileScrollObserver =_scrollObserver;
			
			_scrollObserver.addEventListener("autoScrollComplete", onAutoScrollComplete, false, 0, true);
				
			
		}
		
		protected function onAutoScrollComplete(event:Event):void
		{
			_autoScrollInProgress = false;
			dispatchEvent(event);
		}
		
	}
}