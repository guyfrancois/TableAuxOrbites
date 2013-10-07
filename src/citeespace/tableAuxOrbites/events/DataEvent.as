package citeespace.tableAuxOrbites.events
{
	import flash.events.Event;
	
	public class DataEvent extends Event
	{
		public var data:Object;
		
		public function DataEvent(type:String, initialData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data = initialData;
		}
		
		override public function clone():Event
		{
			// TODO Auto Generated method stub
			return new DataEvent(type,data,bubbles,cancelable);
		}
		
		
	}
}