package citeespace.tableAuxOrbites.events
{
	import flash.events.Event;
	import flash.events.EventPhase;
	
	/**
	 * Evenement de propagation dans la displaylist<br>
	 * envoie un signal au descendant (...children), doit être en bubble<br>
	 * 	addEventListener(BubbleUserEvent.SEND_CURRENT_USER,evtReceiveCurrentUser,false,0,true);<br>
	 *  if (event.eventPhase==EventPhase.BUBBLING_PHASE) do...<br>
	 * @author GUYF
	 * 
	 */	
	public class _BubbleUserEvent  extends  DataEvent 
	{
		
		public static const SEND_CURRENT_USER:String = "SEND_CURRENT_USER";
		
		public static const SIGNAL_AMP:String = "RELAY_SIGNAL_AMP";
		
		public function _BubbleUserEvent(type:String,initialData :Object=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type,initialData, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new BubbleUserEvent(type,data, bubbles,  cancelable);
		}
		
		
	}
}