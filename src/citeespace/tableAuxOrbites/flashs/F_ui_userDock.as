package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.models.TextInfo;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.utils.getQualifiedClassName;
	
	import org.casalib.util.ArrayUtil;
	
	import pensetete.textes.TextPlayListItem;
	import pensetete.textes.TextPlayListWrapper;
	
	import utils.MyTrace;
	import utils.events.EventChannel;

	public class F_ui_userDock extends F_Anim_super
	{
		
		
		//public static var STATE_SUBTITLE:String="state_subtitle";
		public static var STATE_FULL:String="state_full";
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show / STATE_SUBTITLE
		 */
		public var hide_full_tween_duration:Number = 0.5;
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show / STATE_FULL
		 */
		public var show_full_tween_duration:Number = 0.5;
		
		
		private var _user:Number;
		private var _y0:Number;
		
		private var hideDec:Number=90;
		
		public function F_ui_userDock()
		{
			super();
			this._y0=y;
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			_user=UI_utils.identify_ui_player(getQualifiedClassName(this));
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.USER_DOCK_HIDE, onHideDock);
			chan.addEventListener(GameLogicEvent.USER_DOCK_SHOW, onShowDock);
			chan.addEventListener(GameLogicEvent.USER_DOCK_SHOW2, onShowDock2);
			
			//TODO : changement d'etat du dock une fois le satellite selectionné si 2 joueur
			// en fonction du nom de classe du clip
			
			addEventListener(AskUserEvent.ASK_USER_INTERFACE,evt_ask_ui_Player,true,0,true);
		}
		
		protected function evt_ask_ui_Player(event:Event):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
				return;
			MyTrace.put("F_ui_userDock.evt_ask_ui_Player "+getQualifiedClassName(event.target)+" "+_user);
			(event.target as I_UserResponse).setUser(_user);
		}
		
		protected function onShowDock(event:GameLogicEvent):void
		{
			if (_user== 0) {
				show();
				TweenLite.to(this, show_full_tween_duration, {y:_y0-hideDec});
			} else {
				onHideDock(null);
			}
		}
		
		protected function onShowDock2(event:GameLogicEvent):void
		{
			if (GameData.instance.playerNumber <2) return;
			switch (_user) {
				case 0 :
					onHideDock(null);
				break;
				case 1 :
				case 2 :
					show();
					TweenLite.to(this, show_full_tween_duration, {y:_y0-hideDec});
					break;
			}
		
		}
		
		protected function onHideDock(event:GameLogicEvent):void
		{
			hide();
			TweenLite.to(this, hide_full_tween_duration, {y:_y0});
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			
		}
		
		protected function onAddedToStage(event:Event):void
		{
			// TODO Auto-generated method stub
			visible=false;
			alpha=0;
		}
	
	}
}