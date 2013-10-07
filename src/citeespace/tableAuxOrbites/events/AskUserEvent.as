package citeespace.tableAuxOrbites.events
{
	import flash.events.Event;
	
	/**
	 * Evenement de propagation dans la displaylist<br>
	 * interroge les ancetres (...parents), pas sensé être en bubble<br>
	 * Mais ecouté en capture<br>
	 * addEventListener(AskUserEvent.ASK_CURRENT_USER,evt_askUser,true,0,true);<br>
	 * event.eventPhase==EventPhase.CAPTURING_PHASE<br>
	 * XXXXXXXla reponse devrait passer par BubbleUserEvent<br>
	 * ^^ ça marche pas !!
	 * recuperer le Target qui doit implementer I_qqlchose et utiliser la methode implementée
	 * @author GUYF
	 * 
	 */	
	public class AskUserEvent extends DataEvent
	{
		public static const ASK_NB_INTERFACE:String = "ASK_CURRENT_NBUSER";
		public static const ASK_USER_INTERFACE:String = "citeespace.tableAuxOrbites.events.ASK_USER_INTERFACE";
		
		public static const ITEM_DROPED:String = "ITEM_DROPED";
		public static const ITEM_ROTATE:String = "ITEM_ROTATION";
		public static const SIGNAL_AMP:String = "SEND_SIGNAL_AMP";
		
		
		public function AskUserEvent(type:String,initialData :Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,initialData, bubbles, cancelable);
		}
		
	
		
	}
}