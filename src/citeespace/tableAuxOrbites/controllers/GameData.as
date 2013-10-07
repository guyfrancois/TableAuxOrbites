package citeespace.tableAuxOrbites.controllers
{
	import org.casalib.util.ArrayUtil;
	
	import utils.MyTrace;

	
	public class GameData 
	{
		static protected var _instance:GameData;

		

		static public function get instance():GameData
		{
			return (_instance != null) ? _instance : new GameData();
		}
		
		internal var  _playerNumber:int;
		
		public function get playerNumber():int
		{
			return _playerNumber;
		}
		
		public function set playerNumber(value:int):void
		{
			_playerNumber = value;
		}
		
		// nombre de reponses obtenues :
		public var nb_reponses:int;
		
		/*
		0 : pas selectionné
		de 1 à 3
		*/
		private var _selectedSatellite:Number;
		public function get selectedSatellite():Number
		{
			return _selectedSatellite;
		}
		
		public function set selectedSatellite(value:Number):void
		{
			MyTrace.put("GameData.selectedSatellite "+value);
			_selectedSatellite = value;
		}
		
		private var identificationJ1:Number=0;
		private var identificationJ2:Number=0;
		
		public function getBestIdentification():Number {
			var ret:Number;
			if (identificationJ1!=0) {
				MyTrace.put("getBestIdentification identificationJ1 "+identificationJ1);
				return identificationJ1
			}
			if (identificationJ2!=0) {
				MyTrace.put("getBestIdentification identificationJ2 "+identificationJ2);
				return identificationJ2
			}
			var listId:Array=[1,2,3];
			ArrayUtil.removeItem(listId,_selectedSatellite);
			ret =  ArrayUtil.random(listId);
			MyTrace.put("getBestIdentification identificationJ1 "+ret);
			return ArrayUtil.random(listId);
		}
		
		
		
		public function getIdentification(idJoueur:Number):Number {
			if (idJoueur==2) {
				return identificationJ2;
			}
			return identificationJ1;
		}
		public function setIdentification(idJoueur:Number,value:Number):void {
			MyTrace.put("setIdentification idJoueur "+idJoueur+" value "+value);
			if (idJoueur==2) {
				
				identificationJ2=value;
			} else {
				identificationJ1=value;
			}
		}	
		/**
		 * 
		 * @return id du cas de test sur l'identification du signal
		 * 
		 */
		public function testJoueurIdentificationSignal(idJoueur:Number):Number {
			var ret:Number=0;
			var ident:Number=getIdentification(idJoueur);
			if (ident==0) {
				ret= 6 // incomplet
			} else	if (ident==1) {
				ret= 1 // trouvé
			} else	 {
				ret= 3 // mauvaise
			}
			return ret;
		}
		
		public function getWorstIdentificationSignal():Number {
			if (identificationJ1>1) {
				MyTrace.put("getWorstIdentificationSignal identificationJ1 "+identificationJ1);
				return identificationJ1
			}
			if (identificationJ2>1) {
				MyTrace.put("getWorstIdentificationSignal identificationJ2 "+identificationJ2);
				return identificationJ2
			}
			return ArrayUtil.random([2,3]);
		}
		
		public function testIdentificationSignal():Number {
			var tj1:Number=testJoueurIdentificationSignal(1);
			var ret:Number=tj1;
			
			if (playerNumber==2) {
				var tj2:Number=testJoueurIdentificationSignal(2);
				if (tj1==1 && tj2==1) {
					return 1
				} else if (tj1==1 || tj2==1) {
					return 2
				} else if (tj1==3 && tj2==3) {
					if (identificationJ1 == identificationJ2) {
						return 3
					} else {
						return 4
					}
				} else if (tj1==3 || tj2==3) {
					return 5
				} else {
					return 6
				}
			}
			return ret
		}
		
		/**
		 * 
		 * @return id du cas de test sur l'identification du satellite
		 * 
		 */
		public function testJoueurIdentification(idJoueur:Number):Number {
			var ret:Number=0;
			var ident:Number=getIdentification(idJoueur);
			if (ident==0) {
				ret= 6 // incomplet
			} else	if (ident==_selectedSatellite) {
				ret= 1 // trouvé
			} else	 {
				ret= 3 // mauvaise
			}
			return ret;
		}
		public function testIdentification():Number {
			var tj1:Number=testJoueurIdentification(1);
			var ret:Number=tj1;
			
				if (playerNumber==2) {
					var tj2:Number=testJoueurIdentification(2);
					if (tj1==1 && tj2==1) {
						return 1
					} else if (tj1==1 || tj2==1) {
						return 2
					} else if (tj1==3 && tj2==3) {
						if (identificationJ1 == identificationJ2) {
							return 3
						} else {
							return 4
						}
					} else if (tj1==3 || tj2==3) {
						return 5
					} else {
						return 6
					}
				}
			return ret
		}
		
		public function GameData()
		{
			super();
			if (_instance != null) return;
			_instance = this;
			
		}
	}
}