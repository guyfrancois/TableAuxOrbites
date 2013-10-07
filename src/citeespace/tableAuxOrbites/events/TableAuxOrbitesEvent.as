package citeespace.tableAuxOrbites.events
{
	import flash.events.Event;
	
	import utils.events.DataBringerEvent;
	import utils.events.EventChannel;
	
	/**
	 * citeespace.planisphere.events.PlanisphereEvent
	 * 
	 * Cette classe est à surcharger pour ajouter les meta de type d'evenements
	 * et la gestion des types de données, ainsi que sucharger 
	 * EVENT_CHANNEL_NAME et donc paralléliser les eventChannels
	 * 
	 * @author SPS
	 * @creation 2011 11 10 Creation
	 */
	public class TableAuxOrbitesEvent extends DataBringerEvent
	{
		static protected const EVENT_CHANNEL_NAME:String = 'tableAuxOrbitesChannel';
		
		
		public function TableAuxOrbitesEvent(type:String, initialData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, initialData, bubbles, cancelable);
			 
		}
		
		
		override public function dispatch():void 
		{
			TableAuxOrbitesEvent.channel.dispatchEvent(this);
		}
		
		
		static private var _channel:EventChannel; 
		static public function get channel():EventChannel
		{
			if (_channel == null) {
				_channel = EventChannel.get(EVENT_CHANNEL_NAME);
			}
			return _channel;
		}
	}
}