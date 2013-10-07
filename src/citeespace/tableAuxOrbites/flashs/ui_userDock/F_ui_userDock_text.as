package citeespace.tableAuxOrbites.flashs.ui_userDock
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.F_Anim_super;
	import citeespace.tableAuxOrbites.models.TextInfo;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import org.casalib.util.ArrayUtil;
	
	import pensetete.textes.TextPlayListItem;
	import pensetete.textes.TextPlayListWrapper;
	
	import utils.events.EventChannel;

	public class F_ui_userDock_text extends F_Anim_super
	{
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var ss_titres_txt:TextPlayListWrapper;
		/* ----------------------------------------------------------------- */
	
		
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show / STATE_SUBTITLE
		 */
		public var hide_full_tween_duration:Number = 0.5;
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show / STATE_FULL
		 */
		public var show_full_tween_duration:Number = 0.5;
		
		private var _user:Number;
		
		
		
		public function getUserLanguage():String {
			switch(_user)
			{
				case 2:
				{
					return LangageController.instance.userLanguage2
					break;
				}
					
				default:
				{
					return LangageController.instance.userLanguage;
					break;
				}
			}
			
		}
		
		
		public function F_ui_userDock_text()
		{
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			_user=UI_utils.identify_ui_player(getQualifiedClassName(this));
			
			
			
		}
		
	
		
		protected function onRemovedFromStage(event:Event):void
		{
			var logicChannel:EventChannel = GameLogicEvent.channel;
			logicChannel.removeEventListener(GameLogicEvent.DISPLAY_PLAYER_TEXTS, _displayPlayerTexts);
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			visible=false;
			alpha=0;
			
			
			ss_titres_txt.removeItems();
			
			var logicChannel:EventChannel = GameLogicEvent.channel;
			
			logicChannel.addEventListener(GameLogicEvent.DISPLAY_PLAYER_TEXTS, _displayPlayerTexts);

		}
		
		protected function _displayPlayerTexts(event:GameLogicEvent):void
		{
			var targetField:TextPlayListWrapper = ss_titres_txt;
			switch(_user)
			{
				case 2:
				{
					if (LangageController.instance.userLanguage2==null) {
						hide();
						targetField.removeItems();
						return;
					} else {
						show();
					}
					break;
				}
					
				default:
				{
					if (LangageController.instance.userLanguage==null) {
						hide();
						targetField.removeItems();
						return;
					} else {
						show();
					}
					break;
				}
			}
			
			
			var nfo:TextInfo = event.data as TextInfo;
			// filtre de cible d'utilisateur a afficher
			// if (nfo.targetDock > 0 && nfo.targetDock != dockID) return;
			
		
			/*
			switch(nfo.targetField)
			{
				case 'animal':
					targetField = animal_txt;
					break;
				case 'question':
					targetField = question_txt;
					break;
				case 'indice':
					targetField = indices_txt;
					break;
				
			}*/
			
			
			_playTxtIDs(nfo.textIDs, targetField);
		}
		
		
		protected function _playTxtIDs(textIDs:*, targetField:TextPlayListWrapper):void
		{
			if (targetField == null) return;
			
			if (textIDs == null) {
				targetField.removeItems();
			}
			
			if (textIDs is String) {
				_playTxtId(textIDs as String, targetField);
			} else if (textIDs is Array) {
				var ids:Array = textIDs as Array;
				var txtColl:DataCollection = DataCollection.instance;
				var items:Array = [];
				var item:TextPlayListItem;
				
				for each (var textId:String in ids) 
				{
					//TODO : selection du langage pour utilisateur, en fonction du receveur
					// interroger le nom de classe du clip
					ArrayUtil.addItemsAt(items,  TextPlayListItem.loadFromXmllist(
					txtColl.getTextXmlNodes(textId, getUserLanguage())));
				}
				
				targetField.addItems(items).playItems();
			}
		}
		
		protected function _playTxtId(textId:String, targetField:TextPlayListWrapper):void
		{
			if (targetField == null) return;
			
			var txtColl:DataCollection = DataCollection.instance;
			var item:TextPlayListItem;
			//TODO : selection du langage pour utilisateur, en fonction du receveur
			// interroger le nom de classe du clip
			var items:Array = TextPlayListItem.loadFromXmllist(txtColl.getTextXmlNodes(textId, getUserLanguage()));
			targetField.addItems(items).playItems();
			
		}
	
	}
}