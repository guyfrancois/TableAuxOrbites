package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import flash.events.Event;

	public class C_BoutonSelfName extends CTactileBouton
	{
		
		/**
		 * selfname = name.substr(name.indexOf("_")+1) CAD :self_name si name=  XXXXX_self_name<br>
		 * tapEvent = EVENT_BOUTON_SELF_NAME+"_"+selfname <br>
		 * tapData = this (C_BoutonSelfName)<br>
		 */
		public static const EVENT_BOUTON_SELF_NAME:String="event_selfname";
		public var selfname:String;
		public function C_BoutonSelfName()
		{
			super();
			
			selfname=name.substr(name.indexOf("_")+1);
			tapEvent=getTapEvent(selfname);
			tapData=this;
		}
		
		
		override public function get mouseEnabled():Boolean
		{
			return super.mouseEnabled;
		}

		override public function set mouseEnabled(value:Boolean):void
		{
			if (value) gotoAndStop(1)
			else gotoAndStop(2);
				
			super.mouseEnabled = value;
		}

		/**
		 * tapData = this (C_BoutonSelfName)<br>
		 * @param selfname (name=  XXXXX_self_name)<br>
		 * @return event_string   EVENT_BOUTON_SELF_NAME+"_"+selfname <br>
		 * 
		 */
		public static function getTapEvent(selfname:String):String {
		
			return EVENT_BOUTON_SELF_NAME+"_"+selfname;
			
		}
	}
}