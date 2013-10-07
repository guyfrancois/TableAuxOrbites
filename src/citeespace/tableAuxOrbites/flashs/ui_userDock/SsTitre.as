package citeespace.tableAuxOrbites.flashs.ui_userDock
{
	import flash.text.TextField;
	
	import pensetete.textes.TextPlayList;
	
	public class SsTitre extends TextPlayList
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var _templateTF:TextField;
		/* ----------------------------------------------------------------- */
		
		public function SsTitre()
		{
			//super();
			stop();
			template = _templateTF;
			initTextPlayList();
		}
	}
}