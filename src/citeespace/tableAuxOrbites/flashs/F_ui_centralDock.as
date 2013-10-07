package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.flashs.ui_centralDock.C_ThumbItem;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import utils.MyTrace;
	import utils.events.EventChannel;

	public class F_ui_centralDock extends F_Anim_super
	{
		
		public var _etape1:C_ThumbItem;
		public var _etape2:C_ThumbItem;
		public var _etape3:C_ThumbItem;
		public var _etape4:C_ThumbItem;
		public var _etape5:C_ThumbItem;
		
		
		public static var STATE_EXTEND:String="state_extend";
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var showx:Number=-25.8; // uniquement en mode 1j
		public var hidex:Number=-275.8; // uniquement en mode 1j
		
		public var state:String;
		
		
		private var _user:Number;
		
		public function F_ui_centralDock()
		{
			super();
			stop();
			state=STATE_HIDE;
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			_user=UI_utils.identify_ui_player(getQualifiedClassName(this));
			if (_user!=0) {
				showx=x;
				hidex=x;
			}
			
			chan.addEventListener(GameLogicEvent.COMMON_DOCK_HIDE, onHideDock);
			chan.addEventListener(GameLogicEvent.COMMON_DOCK_SHOW, onShowDock);

			chan.addEventListener(GameLogicEvent.COMMON_DOCK_EXTENDS, onShowExtends);
			chan.addEventListener(GameLogicEvent.COMMON_DOCK_THUMB_SHOW, onShowThumb);
			addEventListener(AskUserEvent.ASK_USER_INTERFACE,evt_ask_ui_Player,true,0,true);
		}
		
		protected function evt_ask_ui_Player(event:Event):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
				return;
			MyTrace.put("F_ui_centralDock.evt_ask_ui_Player "+getQualifiedClassName(event.target)+" "+_user);
			(event.target as I_UserResponse).setUser(_user);
		}
		
		protected function onShowThumb(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			// TODO Auto-generated method stub
			switch(event.data)
			{
				case 1:
				{
					_etape1.show();
					break;
				}
				case 2:
				{
					_etape2.show();
					break;
				}
			
				case 3:
				{
					_etape3.show();
					break;
				}
				case 4:
				{
					_etape4.show();
					break;
				}
				case 5:
				{
					_etape5.show();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		protected function onShowExtends(event:Event):void
		{
			// c'est ici que tout bascule en fonction des joueurs
			// TODO Auto-generated method stub
			if (_user > 0 && GameData.instance.playerNumber>1) {
				x=hidex
				show();
				state=STATE_EXTEND
				gotoAndPlay(2);
			} else if (_user == 0 && GameData.instance.playerNumber<=1) {
				if (state!=STATE_SHOW)
					return
					state=STATE_EXTEND
				gotoAndPlay(2);
			} else {
				onHideDock(null);
			}
		
		}		
		
		
	
		protected function onShowDock(event:GameLogicEvent):void
		{
			if (_user != 0) return;
			// TODO Auto-generated method stub
			if (state!=STATE_HIDE)
				return
			gotoAndStop(1);
			x=hidex
			show();
			
		}
		
	
		override protected function _hideComplete():void
		{
			visible = false;
		}
		
		protected function onHideDock(event:GameLogicEvent):void
		{
			if (state==STATE_HIDE)
				return
			state=STATE_HIDE
			hide();
		}
		protected function onRemovedFromStage(event:Event):void
		{
			var logicChannel:EventChannel = GameLogicEvent.channel;
			//logicChannel.removeEventListener(GameLogicEvent.DISPLAY_PLAYER_TEXTS, _displayPlayerTexts);
			
		}
		
		protected function onAddedToStage(event:Event):void
		{

			visible=false;
			alpha=0;
		}
		
		override public function show(noTween:Boolean=false):F_Anim_super
		{
			state=STATE_SHOW
			TweenLite.killTweensOf(this);
			visible = true;
			if (noTween) {
				alpha = 1;
				x=showx;
			} else {
				TweenLite.to(this, show_tween_duration, {alpha:1,x:showx});
			}
			return this;
		}
		
	}
}