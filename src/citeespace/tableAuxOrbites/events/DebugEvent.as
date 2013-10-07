package citeespace.tableAuxOrbites.events
{
	import utils.events.DataBringerEvent;
	import utils.events.EventChannel;

	/**
	 * 
	 *
	 * @author SPS
	 * @version 1.0.0 [10 nov. 2011][Seb] creation
	 *
	 * citeespace.planisphere.events.CopiedeNavigationEvent
	 */
	public class DebugEvent extends DataBringerEvent
	{
		static protected const EVENT_CHANNEL_NAME:String = 'debugNavigationChannel';
		
		
		static public const TOGGLE_DEBUG_PHYSICS:String = 'toggle_debug_physics';
		static public const TOGGLE_DEBUG_STATS:String 	= 'toggle_debug_stats';
		
		
		
		public function DebugEvent(type:String, initialData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, initialData, bubbles, cancelable);
		}
		
		override public function dispatch():void 
		{
			DebugEvent.channel.dispatchEvent(this);
		}
		
		/**
		 * Alias pour un (new NavigationEvent(type, initialData)).dispatch() qui diffusera
		 * l'événement type dans l'EventChannel de ces événements
		 * 
		 * @param type
		 * @param initialData
		 * @return 
		 * 
		 */
		static public function dispatch(type:String, initialData:Object=null):DebugEvent
		{
			var notif:DebugEvent = new DebugEvent(type, initialData);
			notif.dispatch();
			return notif;
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