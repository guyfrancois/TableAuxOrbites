package citeespace.tableAuxOrbites.flashs.ui
{
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import utils.MyTrace;
	
	public class C_ui_Interface_User extends Sprite
	{
		private var _user:Number;
		public function C_ui_Interface_User()
		{
			super();
			_user=UI_utils.identify_ui_player(getQualifiedClassName(this));
			addEventListener(AskUserEvent.ASK_USER_INTERFACE,evt_ask_ui_Player,true,0,true);
		}
		
		protected function evt_ask_ui_Player(event:Event):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
					return;
			MyTrace.put("C_ui_Interface_User.evt_ask_ui_Player "+getQualifiedClassName(event.target)+" "+_user);
				(event.target as I_UserResponse).setUser(_user);
		}
	}
}