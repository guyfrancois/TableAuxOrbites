package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	import flash.events.Event;

	public class C_ClipTxtLocalizable2 extends C_ClipTxtLocalizable
	{
		public function C_ClipTxtLocalizable2()
		{
			super();
		}
		
		override protected function onAddedToStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onLangChanged,false,0,true);
			onLangChanged(null);
		}
		
		override protected function onLangChanged(event:GameLogicEvent):void
		{
			// TODO Auto Generated method stub
			lang = LangageController.instance.userLanguage2;
		}
		
		
		
	}
}