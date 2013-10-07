package citeespace.tableAuxOrbites.flashs.ui_choixLangues
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.F_Anim_super;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.CTactileBouton;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonSelfName;
	
	import flash.events.Event;
	
	import utils.events.EventChannel;
	
	public class C_ui_choixLangues_2 extends F_Anim_super
	{
		
		public function C_ui_choixLangues_2()
		{
			super();
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onLangageChange);
			chan.addEventListener(GameLogicEvent.LANG_CHOICE_SHOW, onShowLang);
			
		}
		
		
		protected function onShowLang(event:Event):void
		{
			// TODO Auto-generated method stub
			gotoAndStop(1);
		}
		
		protected function onLangageChange(event:GameLogicEvent):void
		{
			var userLangage :String=event.data as String;
			if (userLangage) {
				gotoAndStop(userLangage);
				this["btn_GB2"].mouseEnabled=(userLangage!="GB");
				this["btn_FR2"].mouseEnabled=(userLangage!="FR");
				this["btn_ES2"].mouseEnabled=(userLangage!="ES");
				
			} else {
				gotoAndStop(1);
				this["btn_GB2"].mouseEnabled=true;
				this["btn_FR2"].mouseEnabled=true;
				this["btn_ES2"].mouseEnabled=true;
			}
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
	}
}