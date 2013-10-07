package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * 
	 *
	 * @author Sps
	 * @version 1.0.0 [6 janv. 2012][Sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.C_WindowCredits
	 */
	public class C_WindowCredits extends C_WindowWithName implements I_UserResponse
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var credits:C_CreditsScrollContainer;
		public var noDragArea:MovieClip;
		/* ----------------------------------------------------------------- */
		
		public function C_WindowCredits()
		{
			super();
			//name="window_credits";
			credits.addEventListener("autoScrollComplete", onAutoScrollComplete, false,0,true);
			
			NavigationEvent.channel.addEventListener(NavigationEvent.DISPLAY_CREDITS, onDisplayCredits_request);
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
		}
		
		private function onAddedToStage(param0:Object):void
		{
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
		}
		
	private var _user:Number=0;	
	
	public function setUser(user:Number):void
	{
		_user = user;
	}
		
		protected function onDisplayCredits_request(event:NavigationEvent):void
		{
			if (_user != event.data as Number) return;
			show();
		}
		
		protected function onAutoScrollComplete(event:Event):void
		{
			// A la fin d'un scroll on ferme automatiquement les credits
			hide();
		}
		
	 
		
		override public function show(immediate:Boolean=false):void
		{
			super.show(immediate);
			// On lance le scroll de mes contenus
			
			credits.loadLang(LangageController.instance.userLanguageOf(_user));
			credits.startAutoScroll();
			
		}
		
		
	}
}