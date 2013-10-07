package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import utils.events.EventChannel;
	
	/**
	 * Classe de controle de  
	 *
	 * @author SPS
	 * @version 1.0.0 [10 nov. 2011][Seb] creation
	 *
	 * citeespace.planisphere.flashs.F_Backgrounds
	 */
	public class F_Backgrounds extends F_Anim_super
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		public var anim:MovieClip;
		
		/* ----------------------------------------------------------------- */
		
		public function F_Backgrounds()
		{
			super();
			anim.stop();
			
			var chan:EventChannel = GameLogicEvent.channel;
			chan.addEventListener(GameLogicEvent.FUSEE_SHOW, onShowBackground);
			chan.addEventListener(GameLogicEvent.FUSEE_HIDE, onHideBackground);
			
		}
		
		protected function onShowBackground(event:Event):void
		{
			//anim.gotoAndStop(1);
			anim.fusee.show();
		}
		
		protected function onHideBackground(event:Event):void
		{
			anim.fusee.hide();
		}
		
			
		
	}
}