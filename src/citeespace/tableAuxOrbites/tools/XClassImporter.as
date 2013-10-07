package citeespace.tableAuxOrbites.tools
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.GameData;
	
	import pensetete.textes.TextPlayList;

	/**
	 * Classe qui sert à forcer l'import de classes pour une compilation
	 *
	 * @author sps
	 * @version 1.0.0 [13 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.tools.XClassImporter
	 */
	public class XClassImporter
	{
		public function XClassImporter()
		{
			var t_controller:* = GameController.instance;
			
			var obj:Object = {};
			
			t_controller = GameData.instance;
		//	var t_Chrono:C_DockChrono = obj.dummy as C_DockChrono; 
		//	var t_3DJ:C_3DJeton = obj.dummy as C_3DJeton;
			/*
			new TextPlayList();
			new PhysicsController(null);
			
			new C_UiPanel();
			new C_DockChrono();
			*/
		}
	}
}