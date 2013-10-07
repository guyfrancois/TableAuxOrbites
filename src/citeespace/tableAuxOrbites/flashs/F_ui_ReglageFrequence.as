package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.flashs.ui.boutons.C_Potar;
	
	import com.greensock.TweenLite;
	
	import effets.SignalEffectSprite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import flashx.textLayout.operations.PasteOperation;
	
	import utils.MyTrace;
	import utils.events.EventChannel;

	public class F_ui_ReglageFrequence extends F_Anim_super  implements I_UserResponse
	{
		public static var frequenceH_sat:Number=0.45;
		public static var frequenceW_sat:Number=0.5;
			
		public static var sensibility:Number=0.1;
		public static var minHeight:Number=10;
		public static var maxHeight:Number=450;
		public static var minWidth:Number=1800;
		public static var maxWidth:Number=100000;
		public static var effectFactor:Number=20;
		
		private var potar_h:C_Potar;
		private var potar_v:C_Potar;
		
		public var control:MovieClip;
		
		public var image:MovieClip;
		public var frequ_ref:MovieClip;
		public var frequ_mod:MovieClip;
		
		
		
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var state:String;
		
		private var _user:Number;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		public function F_ui_ReglageFrequence()
		{
			super();
			stop();
			potar_h=control.potar_h;
			potar_v=control.potar_v;
			potar_h.minRotation=0;
			potar_h.maxRotation=360;
			potar_v.minRotation=-90;
			potar_v.maxRotation=360;
			state=STATE_HIDE;
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.REGLER_FREQUENCE_HIDE, onHide);
			chan.addEventListener(GameLogicEvent.REGLER_FREQUENCE_SHOW, onShow);
			chan.addEventListener(GameLogicEvent.REGLER_FREQUENCE_START, onStartAct);
			chan.addEventListener(GameLogicEvent.REGLER_FREQUENCE_CONCLUSION, onConclusion);
		
			addEventListener(AskUserEvent.ITEM_ROTATE,evt_rotatePotar,true,0,true);
			
			
			
		}
		
		protected function onConclusion(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			// TODO Auto-generated method stub
			potar_h.rotation=scalToDeg(frequ_mod.scaleX=frequ_ref.scaleX);
			potar_v.rotation=scalToDeg(frequ_mod.scaleY=frequ_ref.scaleY);
			updateAffAmplitude();
			
		}		
		
		protected function onStartAct(event:Event):void {
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			gotoAndPlay(2);
			potar_h.rotationParDrag=true;
			potar_v.rotationParDrag=true;
		}
		
		protected function onShow(event:Event):void
		{
			if (state!=STATE_HIDE)	return;
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
				
				state=STATE_SHOW;
			gotoAndStop(1);
			initGame();
			show();
			
		}
		
		private function initGame():void
		{
			gotoAndStop(1);
			potar_h.rotation=scalToDeg(frequ_mod.scaleX=DataCollection.instance.getParamNumber("frequenceH_sat"+GameData.instance.selectedSatellite,frequenceH_sat));
			potar_v.rotation=scalToDeg(frequ_mod.scaleY=DataCollection.instance.getParamNumber("frequenceW_sat"+GameData.instance.selectedSatellite,frequenceW_sat ));
			
			
			updateAffAmplitude();
		}
		
		protected function onHide(event:Event):void
		{
			if (state!=STATE_SHOW)
				return
				state=STATE_HIDE;

			hide();
		}
		
		
		
		protected function updateAffAmplitude():void {
			dispatchEvent(new AskUserEvent(AskUserEvent.SIGNAL_AMP,
				{
					amplitudex:(frequ_mod.scaleX-frequ_ref.scaleX)*effectFactor,
					amplitudey:(frequ_mod.scaleY-frequ_ref.scaleY)*effectFactor
				}));
		}
		
		protected function evt_rotatePotar(event:AskUserEvent):void
		{
			// TODO Auto-generated method stub
			var scale:Number=degToScal(Number(event.data));
			MyTrace.put("evt_rotatePotar "+event.data+" "+event.target.name+" "+scale);
			if (	potar_h.rotationParDrag==false && 	potar_v.rotationParDrag==false) return;
			
			switch(event.target)
			{
				case potar_h:
				{
					frequ_mod.scaleX=degToScal(Number(event.data));
					break;
				}
				case potar_v:
				{
					frequ_mod.scaleY=degToScal(Number(event.data));
					break;
				}
					
				default:
				{
					break;
				}
			}
			updateAffAmplitude();
			
			if (nearEqual(frequ_mod.scaleX,frequ_ref.scaleX) && nearEqual(frequ_mod.scaleY,frequ_ref.scaleY)) {
				if (potar_h.rotationParDrag==false &&	potar_v.rotationParDrag==false)
					return;
				MyTrace.put("REGALGE SUCCESS");
				potar_h.rotationParDrag=false;
				potar_v.rotationParDrag=false;
				NavigationEvent.dispatch(NavigationEvent.SATELLITE_FREQUENCE_FOUND);
			}
			
		}		
	
		private function nearEqual(val1:Number,val2:Number,prec:Number=0.02):Boolean {
			MyTrace.put("nearEqual "+val1+" "+val2);
			return Math.abs(val1-val2)<=0.1;
		}
	
		
	
		override protected function _hideComplete():void
		{
			visible = false;
			potar_h.rotation=0;
			potar_v.rotation=0;
			gotoAndStop(1);
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
			gotoAndStop(1);
		}
		
		private function degToScal(val:Number):Number {
			return (val*2+180)/360
			
		}
		private function scalToDeg(val:Number):Number {
			return (val*360-180)/2
			
		}
		

		
	}
}