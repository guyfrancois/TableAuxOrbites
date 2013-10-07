package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	public class C_ui_NBJoueurs extends Sprite
	{
		private var _nbJoueurs
		public function C_ui_NBJoueurs()
		{
			super();
			_nbJoueurs=UI_utils.identify_ui_nb_player(getQualifiedClassName((this));
			addEventListener(AskUserEvent.ASK_NB_INTERFACE,evt_askNb,true,0,true);
		}
		
		protected function evt_askNb(event:Event):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
					return;
				(event.target as I_NbResponse).setNbUser(_nbJoueurs);
		}
	}
}