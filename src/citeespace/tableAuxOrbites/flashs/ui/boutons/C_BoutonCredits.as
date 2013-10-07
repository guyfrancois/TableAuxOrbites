package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	
	import flash.events.Event;
	
	import org.tuio.TuioTouchEvent;

	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [12 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.boutons.C_BoutonCredits
	 */
	public class C_BoutonCredits extends CTactileBouton implements I_UserResponse
	{
		public function C_BoutonCredits()
		{
			super();
			tapEvent = NavigationEvent.DISPLAY_CREDITS;
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
		}
		
		private function onAddedToStage(param0:Object):void
		{
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
		}
		
		public function setUser(user:Number):void
		{
			tapData = user;
		}
		
		 
		
	}
}