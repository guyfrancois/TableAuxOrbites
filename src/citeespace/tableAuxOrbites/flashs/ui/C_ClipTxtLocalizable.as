package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getQualifiedClassName;

	/**
	 * Clases de controle d'un champs texte tf répartir sur 3 frames pour potionnement/stylage selon la langue
	 *
	 * @author Sps
	 * @version 1.0.0 [6 janv. 2012][Sps] creation
	 *
	 * citeespace.planisphere.flashs.clips.C_ClipTxtLocalizable
	 */
	public class C_ClipTxtLocalizable extends MovieClip
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		
		/* ----------------------------------------------------------------- */
		
		public function C_ClipTxtLocalizable()
		{
			super();
			stop();
			
			if (stage) onAddedToStage_C_ClipTxtLocalizable(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_ClipTxtLocalizable, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_ClipTxtLocalizable, false,0,true);
		}
		
		
		protected function onAddedToStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged,false,0,true);
			onLangChanged(null);
		}
		
		protected function onRemovedFromStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.removeEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged);
		}
		
		protected function onLangChanged(event:GameLogicEvent):void
		{
			lang = LangageController.instance.userLanguage;
		}
		
		
		private var _lang:String;
		protected function get lang():String { return _lang; }
		protected function set lang(value:String):void
		{
			if (value == _lang) return;
			_lang = value;
			// 
			
			// On va à une certaine frame selon la langue
			var objFrames:Object = {"FR":1, "GB":2, "ES":3};
			var targetFrame:Number = objFrames[_lang];
			if (targetFrame > 0 && targetFrame <= totalFrames) gotoAndStop(targetFrame);
			
			//var tf:TextField = getChildByName('tf') as TextField;
			var tf:TextField = getChildAt(0) as TextField;
			if (tf == null) return;
			/*
			if (tf.getTextFormat().align==TextFormatAlign.LEFT) {
				tf.autoSize=TextFieldAutoSize.LEFT;
			} else if (tf.getTextFormat().align==TextFormatAlign.RIGHT) {
				tf.autoSize=TextFieldAutoSize.RIGHT;
			} else {
				tf.autoSize=TextFieldAutoSize.CENTER;
			}*/
			var txtId:String = getQualifiedClassName(this);
			
			var daCo:DataCollection = DataCollection.instance;
			var str:String = daCo.getText(txtId, _lang);
			var strIsHtml:Boolean = daCo.isHtml(txtId, _lang); 
			if (strIsHtml) 
			{
				tf.htmlText = str;
			} else {
				tf.text = str;
			}
			
			
		}

	}
}