package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import flash.events.Event;
	
	import org.tuio.TuioTouchEvent;

	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [12 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.boutons.C_BoutonGoChoixLangue
	 */
	public class C_BoutonGoChoixLangue extends CTactileBouton
	{
		public function C_BoutonGoChoixLangue()
		{
			super();
			tapEvent = NavigationEvent.BTN_CHOIX_LANGUE_CLICKED;
			hide();
			// Bouton home ne sera visite qu'une fois langue et animal sélectionnés
			NavigationEvent.channel.addEventListener(NavigationEvent.BTN_UPDATE_REQUEST, onUpdateRequest);
		}
		
		protected function onUpdateRequest(event:Event):void
		{
			if (GameController.instance.langChoiceEnabled) 
				show();
			else
				hide();
			
		}
		
		
		
	}
}