package citeespace.tableAuxOrbites.models
{
	/**
	 * 
	 *
	 * @author SPS
	 * @version 1.0.0 [14 nov. 2011][SPS] creation
	 *
	 * citeespace.planisphere.models.TextInfo
	 */
	public class TextInfo
	{
	
		/**
		 * targetDock indique le dock sur lequel doit s'afficher le texte. Si 0 alors tous les docks sont visés 
		 */
		public var targetDock:uint = 0; 
		
		/**
		 * Si non null, spécifie un field spécifique dans lequel afficher le texte: problematique, question, indice, ... 
		 */		
		public var targetField:String;
		
		/**
		 * String ou Array de String 
		 */
		public var textIDs:* = null;
		
		public function TextInfo(ids:*=null, dock:uint=0, field:String=null)
		{
			textIDs = ids;
			targetDock = dock;
			targetField = field;
		}
	}
}