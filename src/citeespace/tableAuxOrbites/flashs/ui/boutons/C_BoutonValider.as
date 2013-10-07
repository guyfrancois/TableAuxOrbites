package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	
	import flash.events.Event;
	
	import org.tuio.TuioTouchEvent;
	
	import utils.events.EventChannel;
	
	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [12 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.boutons.C_BoutonHome
	 */
	public class C_BoutonValider extends CTactileBouton implements I_UserResponse
	{
		
		
		public function C_BoutonValider()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			tapEvent = NavigationEvent.BTN_VALIDER_CLICKED;
			hide();
			// Bouton home ne sera visite qu'une fois langue et animal sélectionnés
			NavigationEvent.channel.addEventListener(NavigationEvent.BTN_UPDATE_REQUEST, onUpdateRequest);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.USER_VALIDER_SHOW, onShowUserBtn);
			chan.addEventListener(GameLogicEvent.USER_VALIDER_HIDE, onHideUserBtn);
		}
		private function onAddedToStage(param0:Object):void
		{
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
		}
		
		protected function onHideUserBtn(event:GameLogicEvent):void
		{
			if (event.data==tapData && GameController.instance.btnValiderEnabled) {
				hide();
			}
		}
		
		protected function onShowUserBtn(event:GameLogicEvent):void
		{
			if (event.data==tapData && GameController.instance.btnValiderEnabled) {
				show();
			}
		}
		
		protected function onUpdateRequest(event:Event):void
		{
			/*
			if (GameController.instance.btnValiderEnabled) 
				show();
			else
			*/
				hide();
			
		}
		
		public function setUser(user:Number):void
		{
			tapData = user;
		}
		
	}
}