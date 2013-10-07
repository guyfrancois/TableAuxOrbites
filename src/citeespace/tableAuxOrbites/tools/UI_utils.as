package citeespace.tableAuxOrbites.tools
{
	/**
	 * 
	 * @author GUYF
	 * 
	 */
	public class UI_utils
	{
		/**
		 * 
		 * 
		 */
		
		
			/**
			 *interface destinée au joueur 1 
			 */
			public static var KEYJ1:String="j1";
			/**
			 *interface destinée au joueur 2 
			 */
			public static var KEYJ2:String="j2";
			
			/**
			 *interface destinée pour 2 joueurs
			 */
			public static var KEY1J:String="1j";
			
			/**
			 *interface destinée pour 1 seul joueur
			 */
			public static var KEY2J:String="2j";
			
			/**
			 * identifier le joueur lié à l'interface par nom (de liaison du composant)
			 * @param class_name : string comprenant KEYJ1 ou KEYJ2
			 * @return 0 (indefini) 1 : joueur 1, 2 : joueur 2
			 * 
			 */
			public static function identify_ui_player(class_name:String):Number {
				if (class_name.indexOf(KEYJ1)>-1) return 1
				if (class_name.indexOf(KEYJ2)>-1) return 2
				return 0
			}
			
			/**
			 * identifier le nombre de joueurs actif pour afficher l'interface par nom (de liaison du composant)
			 * @param class_name : string comprenant KEY1J ou KEY2J
			 * @return 0 (indefini) 1 : 1 seul joueur, 2 : 2 joueurs
			 * 
			 */
			public static function identify_ui_nb_player(class_name:String):Number {
				if (class_name.indexOf(KEY1J)>-1) return 1
				if (class_name.indexOf(KEY2J)>-1) return 2
				return 0
			}
			
			
			public static var KEYSTA1:String="sat1"; // orbite basse
			public static var KEYSTA2:String="sat2"; // orbite géo
			public static var KEYSTA3:String="sat3"; // orbite de transfet
			
			/**
			 * 
			 * identifier l'item satellite
			 * 
			 * 
			 */
			public static function identify_ui_satellite(class_name:String):Number {
				if (class_name.indexOf(KEYSTA1)>-1) return 1
				if (class_name.indexOf(KEYSTA2)>-1) return 2
				if (class_name.indexOf(KEYSTA3)>-1) return 3
				return 0
			}
			
			
			
			
		
	}
}