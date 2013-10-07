package citeespace.tableAuxOrbites.flashs.ui_userDock
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	
	import flash.display.DisplayObject;
	
	import pensetete.textes.TextPlayList;
	import pensetete.textes.TextPlayListWrapper;
	
	public class SsTitreW extends TextPlayListWrapper
	{
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var _texts:TextPlayList;
		public var _mask_txt:DisplayObject;
		/* ----------------------------------------------------------------- */
		
		public function SsTitreW()
		{
			super();
			_texts.overrideTemplate = DataCollection.instance.getTemplate("ssTitre");
			_texts.textHeight1l = DataCollection.instance.getParamNumber("ssTitre1l",20);
		}
		
		
		
	}
}