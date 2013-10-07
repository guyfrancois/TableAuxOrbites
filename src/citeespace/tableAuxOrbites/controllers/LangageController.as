package citeespace.tableAuxOrbites.controllers
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_BoutonSelfName;
	import citeespace.tableAuxOrbites.models.TextInfo;
	
	import fr.kapit.actionscript.lang.array.functions.array_clear;
	
	import pensetete.textes.TextPlayListItem;
	
	import utils.MyTrace;
	import utils.events.EventChannel;

	public class LangageController
	{
		
		
		/* Gestion du singleton */
		static protected var _instance:LangageController;
		static public function get instance():LangageController
		{
			return (_instance != null) ? _instance : new LangageController();
		}
		
		internal function get txts():DataCollection {
			return DataCollection.instance;
		}
		
		
		internal var _userLanguage:String;
		/**
		 * Langue actuellement sélectionnée par l'utilisateur 
		 * @return 
		 */
		public function get userLanguage():String { return _userLanguage; }
		public function set userLanguage(value:String):void
		{
			if (_userLanguage == value) return;
			_userLanguage = value;
			// On dispatch un événement
			GameLogicEvent.dispatch(GameLogicEvent.LANGAGE_CHANGE, _userLanguage);
		}
		
		internal var _userLanguage2:String;
		
		public function userLanguageOf(userId:Number):String {
			switch(userId)
			{
				case 2:
				{
					return userLanguage2;
					break;
				}
				case 1:
				{
					return userLanguage;
					break;
				}
					
				default:
				{
					return userLanguage;
					break;
				}
			}
		}
		/**
		 * Langue actuellement sélectionnée par l'utilisateur 
		 * @return 
		 */
		public function get userLanguage2():String { return _userLanguage2; }
		public function set userLanguage2(value:String):void
		{
			if (_userLanguage2 == value) return;
			_userLanguage2 = value;
			// On dispatch un événement
			GameLogicEvent.dispatch(GameLogicEvent.LANGAGE_CHANGE_2, _userLanguage2);
		}
		
		
		public function LangageController()
		{
			if (_instance != null) return;
			_instance = this;
			
			
			
			// On se prépare à écouter les événements importants
			var navigChan:EventChannel = NavigationEvent.channel;
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("GB"),evt_click_lang_GB);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("ES"),evt_click_lang_ES);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("FR"),evt_click_lang_FR);
			
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("GB2"),evt_click_lang_GB2);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("ES2"),evt_click_lang_ES2);
			navigChan.addEventListener(C_BoutonSelfName.getTapEvent("FR2"),evt_click_lang_FR2);
			
		}
		protected function evt_click_lang_GB(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler("GB");
		}
		protected function evt_click_lang_ES(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler("ES");
		}
		
		protected function evt_click_lang_FR(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler("FR");
		}
		protected function evt_click_lang_GB2(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler2("GB");
		}
		protected function evt_click_lang_ES2(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler2("ES");
		}
		
		protected function evt_click_lang_FR2(event:NavigationEvent):void
		{
			GameController.instance._onPlayerLangSelected_handler2("FR");
		}
		
		/**
		 *  
		 * @param txtId
		 * @return Un array de TextPlayListItem
		 * 
		 */
		internal function getTextNodes(txtId:String):Array
		{
			try {
			var items:Array = TextPlayListItem.loadFromXmllist(txts.getTextXmlNodes(txtId, userLanguage ));
			} catch (e:Error) {
				MyTrace.put("ERREUR getTextNodes "+txtId+" "+userLanguage,MyTrace.LEVEL_ERROR);
				return [];
			}
			return items;
		}
		internal function getTextNodesLang(txtId:String,userLanguage:String):Array
		{
			try {
				var items:Array = TextPlayListItem.loadFromXmllist(txts.getTextXmlNodes(txtId, userLanguage ));
			} catch (e:Error) {
				MyTrace.put("ERREUR getTextNodesLang "+txtId+" "+userLanguage,MyTrace.LEVEL_ERROR);
				return [];
			}
			return items;
		}
		
		
		public function displaySsTitres(txtId:String):void
		{
			var nfo:TextInfo = new TextInfo(txtId, 0);
			GameLogicEvent.dispatch(GameLogicEvent.DISPLAY_PLAYER_TEXTS, nfo);
		}
		
		public function displaySsTitresAndVoice(txtId:String,callBack:Function):void
		{
			var nfo:TextInfo = new TextInfo(txtId, 0);
			SoundController.instance.playItemsVoice(txtId, callBack);
			GameLogicEvent.dispatch(GameLogicEvent.DISPLAY_PLAYER_TEXTS, nfo);
		}
		
		public function clear_uniq_txtid():void {
			uniq_txtid="";
		}
		internal var uniq_txtid:String;
		private var uniq_callBacks:Array;
		public function uniq_DisplaySsTitresAndVoice(txtId:String,callBack:Function):void
		{
			
			if (uniq_txtid==txtId) {
				uniq_callBacks.push(callBack);
			} else {
				uniq_callBacks=new Array();
				uniq_txtid=txtId;
				uniq_callBacks.push(callBack);
				
				var nfo:TextInfo = new TextInfo(txtId, 0);
				SoundController.instance.playItemsVoice(txtId, uniq_callBack_call);
				GameLogicEvent.dispatch(GameLogicEvent.DISPLAY_PLAYER_TEXTS, nfo);
				
			}
		
		}
		private function uniq_callBack_call():void {
			var luniq_callBacks:Array=uniq_callBacks.concat();
			uniq_callBacks=new Array();
			uniq_txtid="";
			for (var i:int = 0; i < luniq_callBacks.length; i++) 
			{
				luniq_callBacks[i].call();
			}
			
			
		}
		
		
		
		
	}
}