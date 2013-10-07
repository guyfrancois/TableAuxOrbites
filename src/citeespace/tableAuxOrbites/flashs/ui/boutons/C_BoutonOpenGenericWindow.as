package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import org.casalib.util.StringUtil;
	import org.tuio.TuioTouchEvent;

	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [12 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.boutons.C_BoutonOpenGenericWindow
	 */
	public class C_BoutonOpenGenericWindow extends CTactileBouton
	{
		public function C_BoutonOpenGenericWindow()
		{
			super();
			tapEvent = NavigationEvent.WINDOW_WITH_NAME_OPEN_REQUEST;
			tapData  = StringUtil.replace(this.name, "btn_", "");
		}
		
		 
		
	}
}