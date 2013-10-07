package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.C_ClipTxtLocalizable;
	import citeespace.tableAuxOrbites.flashs.ui.C_ClipTxtLocalizable2;
	import citeespace.tableAuxOrbites.flashs.ui.C_ClipUserTxtLocalizable;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonPoursuivre;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonQuitter;
	import citeespace.tableAuxOrbites.flashs.ui_placement.C_deplacable_satellite;
	
	import flash.events.Event;
	
	import utils.events.EventChannel;

	public dynamic class F_UserInterface extends F_Anim_super
	{
		public function F_UserInterface()
		{
			super();
			stop();
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			/*
			chan.addEventListener(GameLogicEvent.USER_DOCKS_HIDE, onHideDocks);
			chan.addEventListener(GameLogicEvent.USER_DOCKS_SHOW, onShowDocks);
			*/
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			
		}
		private function keep():void {
			
			F_ui_choixLangue
			F_ui_centralDock
			F_ui_Placement
			F_ui_ChoixSatellite
			F_ui_IdentifierSatellite;
			C_ClipTxtLocalizable;
			C_ClipTxtLocalizable2;
			C_ClipUserTxtLocalizable
			C_deplacable_satellite;
			C_BoutonQuitter;
			C_BoutonPoursuivre;
			
			
		}
	}
}