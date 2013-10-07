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
	public class C_BoutonQuitter extends CTactileBouton implements I_UserResponse
	{
		
		override public function get mouseEnabled():Boolean
		{
			return super.mouseEnabled;
		}
		
		override public function set mouseEnabled(value:Boolean):void
		{
			if (value) gotoAndStop(1)
			else gotoAndStop(2);
			
			super.mouseEnabled = value;
		}

		
		public function C_BoutonQuitter()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			tapEvent = NavigationEvent.BTN_QUITTER_CLICKED;
			
			
		}
		protected function onAddedToStage(event:Event):void
		{
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			
		}
		
		
		
		public function setUser(user:Number):void
		{
			tapData = user;
		}
		
		
	}
}