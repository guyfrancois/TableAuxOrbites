package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	/**
	 * 
	 *
	 * @author Sps
	 * @version 1.0.0 [12 janv. 2012][Sps] creation
	 *
	 * citeespace.planisphere.flashs.clips.C_ClipStaticTxtLocalizable
	 */
	public class C_ClipStaticTxtLocalizable extends C_ClipTxtLocalizable
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		
		/* ----------------------------------------------------------------- */
		
		public function C_ClipStaticTxtLocalizable()
		{
			super();
			
		}
		
		override protected function onLangChanged(event:GameLogicEvent):void
		{
			lang = "FR";
		}
		
		
	}
}