package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [12 déc. 2011][sps] creation
	 * @version 1.1.0 [6 janv. 2012][Sps] Ajout de tapData
	 *
	 * citeespace.planisphere.flashs.ui.boutons.CTactileBouton
	 */
	public class CTactileBouton extends TactileUiClip
	{
		
		/**
		 * Le type d'évenement NavigationEvent qui sera dispatché on tap 
		 */
		protected var tapEvent:String;
		protected var tapData:Object;
		
		public function CTactileBouton()
		{
			super();
			stop();
			
			dragEnabled = false; 
		}
		
		
		override protected function onTap_tactileClip(event:TuioTouchEvent):void
		{
			if (!mouseEnabled) return;
			super.onTap_tactileClip(event);
			if (tapEvent != null) NavigationEvent.dispatch(tapEvent, tapData);
		}
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			super.handleTouchEnd(event);
			gotoAndStop(1);
		}
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			super.handleTouchBegin(event);
			gotoAndStop(2);
		}
		
		
		
		
		
		
	}
}