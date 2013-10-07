package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.controllers.SoundController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.flashs.ui_identifierSatellite.C_FicheSatelliteScaler;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import org.casalib.util.ArrayUtil;
	import org.tuio.TuioTouchEvent;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_IdentifierSatellite extends F_Anim_super implements I_UserResponse
	{
		public var cible:MovieClip;
		public var fiche_animation:MovieClip;
		
		public var state:String;
		public static var STATE_SHOW:String="state_show";
		public static var STATE_HIDE:String="state_hide";
		
		public var FRAME_ACT:Number;
		
		private var _user:Number;
		
		private var arrFiche:Array;
		private var slotArr:Array;
		private var maxSlot:Number;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		public function F_ui_IdentifierSatellite()
		{
		
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			// ecouter ,repondre et signaler d'utilisateur de cette interface
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SHOW, onShow);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_HIDE, onHide);
			
			chan.addEventListener(GameLogicEvent.USER_VALIDE, onUserValide);
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_ERREUR, onErreur);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SUPPRIMER, onSupprimer);
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_CLEAR_REPONSE,onClearReponse);
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_AFFICHE_REPONSE,onAfficheReponse);
			
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_CONCLUSION, onConclusion);
			
			
			
			
			
			
			FRAME_ACT	=	hframeof("FRAME_ACT");
			
			
		}
		
		
		
		protected function onUserValide(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state != STATE_SHOW) return;
			if (event.data==_user) {
				for (var i:int = 0; i < arrFiche.length; i++) 
				{
					(arrFiche[i] as C_FicheSatelliteScaler).mouseEnabled=false;
				}
				
				var activSlot:MovieClip;
				for (var j:int = 1; j <= maxSlot; j++) 
				{
					activSlot=cible["slot_"+j];
					activSlot.mouseEnabled=false;
					activSlot.removeEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false);

				}
			
				
			}
		}
		// supprimmer le satellite selectionner
		protected function onErreur(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			arrFiche[0].hide();
			arrFiche=slotArr.concat();
		
			maxSlot=1
			updateIdentification();
			new DelayedCall(onAfficheReponse,1000);
		}
		// supprimer le satellite en parametre (data)
		protected function onSupprimer(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			
			arrFiche=[fiche_animation.sat1,fiche_animation.sat2,fiche_animation.sat3];

			var tar:Array=arrFiche.concat();
			for (var i:int = 0; i < tar.length; i++) 
			{
				if (tar[i].satellite==event.data) {
					tar[i].hide();
					ArrayUtil.removeItem(arrFiche,tar[i]);
				}
			}
			
			maxSlot=1
			updateIdentification();
			new DelayedCall(onAfficheReponse,1000);
		}

		// afficher au centre le bon satellite, s'assurer que les autre sont bien supprimer, etape avant conclusion
		protected function onClearReponse(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			
			arrFiche=[fiche_animation.sat1,fiche_animation.sat2,fiche_animation.sat3];
			var tar:Array=arrFiche.concat();
			for (var i:int = 0; i < tar.length; i++) 
			{
				if (tar[i].satellite!=GameData.instance.selectedSatellite) {
					tar[i].hide();
					ArrayUtil.removeItem(arrFiche,tar[i]);
				} 
			}
			
			maxSlot=0
			new DelayedCall(onConclusion,1000);
		}
		
		// on affiche les bon elements
		protected function onAfficheReponse(event:Event=null):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			resetSlot();
			showAllActiveCartes();
			
		}
		
		//deplacer le satellite vers le dock (signaler quand c'est terminé pour passer à hide
		protected function onConclusion(event:GameLogicEvent=null):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			var fiche:C_FicheSatelliteScaler=arrFiche[0] as C_FicheSatelliteScaler
			
			fiche.afficheTo(localToGlobal(new Point(650,300)),cb_ConclusionComplet);
		}
		
		private function cb_ConclusionComplet():void
		{
			NavigationEvent.dispatch(NavigationEvent.IDENTIFIER_SATELLITE_CONCLUSIONCOMPLET);
		}		
		
		
		
		
		
		
		protected function onHide(event:GameLogicEvent):void
		{
			if (state!=STATE_SHOW)
				return
				state=STATE_HIDE
			hide();
		}
		
		protected function onShow(event:GameLogicEvent):void
		{
			if (state!=STATE_HIDE)	return;
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
				state=STATE_SHOW;
			gotoAndStop(1);
			initGame();
			show();
			htweenToFrame(FRAME_ACT,dispatchintroOk);
		}		
		
		private function dispatchintroOk():void {
			NavigationEvent.dispatch(NavigationEvent.IDENTIFIER_SATELLITE_INTROCOMPLET);
			
		}
		
		
		private function initGame():void {
			arrFiche=[fiche_animation.sat1,fiche_animation.sat2,fiche_animation.sat3]
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				(arrFiche[i] as C_FicheSatelliteScaler).show(true);
				(arrFiche[i] as C_FicheSatelliteScaler).mouseEnabled=true
			}
			resetSlot();
			maxSlot=2;
			updateIdentification();
			
		}
		
		
		private function updateIdentification():void {
			if (arrFiche.length>1) {
				GameData.instance.setIdentification(_user,0);
				GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_HIDE,_user);
			} else {
				GameData.instance.setIdentification(_user,(arrFiche[0] as C_FicheSatelliteScaler).satellite);
				GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_SHOW,_user);
			}
		}
		
		
		
		
		
		protected function evt_askUser(event:AskUserEvent):void
		{
			if (event.eventPhase!=EventPhase.CAPTURING_PHASE)
				return;
			(event.target as I_UserResponse).setUser(_user);
			
		}
		
		
		
		protected function onRemovedFromStage(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		private function onAddedToStage(param0:Object):void
		{
			visible=false;
			alpha=0;
			gotoAndStop(1);
			state=STATE_HIDE;
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			addEventListener(AskUserEvent.ITEM_DROPED,evt_itemDropped,true,0,true);
			
		}
		
		protected function evt_itemDropped(event:AskUserEvent):void
		{
			//if (state!=STATE_INTERACTION)
			//	return
				MyTrace.put(event.type);

			var fiche:C_FicheSatelliteScaler=event.data.item as C_FicheSatelliteScaler
			var gp:Point=event.data.pos;
			if (cible.hitTestPoint(gp.x,gp.y,true) && (arrFiche.length>1) ) {
				//NavigationEvent.dispatch(NavigationEvent.SUP);
				doStockCorbeille(fiche);
			}
			
		}
		
		
		
		private function doStockCorbeille(fiche:C_FicheSatelliteScaler):void
		{
			var activSlot:MovieClip;
			if (slotArr.indexOf(fiche)==-1 ) {
				slotArr.push(fiche);
				ArrayUtil.removeItem(arrFiche,fiche);
			}
			updateIdentification();
			for (var i:int = 1; i <= maxSlot; i++) 
			{
				activSlot=cible["slot_"+i];
				if (!activSlot.fiche) {
					activSlot.fiche=fiche;
					fiche.mouseEnabled=false;
					fiche.dropTo(cible.localToGlobal(new Point(activSlot.x,activSlot.y)),cb_dropComplet);
					SoundController.instance.playSfx("sfx_selection");
					return;
				}
			}
			
		}
		private function cb_dropComplet(fiche:C_FicheSatelliteScaler):void
		{
			var activSlot:MovieClip;
			
			cible["info"].visible=false;
			for (var i:int = 1; i <= maxSlot; i++) 
			{
				activSlot=cible["slot_"+i];
				if (activSlot.fiche && activSlot.fiche==fiche && activSlot.visible==false) {
					activSlot.visible=true;
					activSlot.gotoAndStop(activSlot.fiche.satellite);
					cible["supp"].x=activSlot.x
					cible["supp"].y=activSlot.y
					cible["supp"].gotoAndPlay(2);
					activSlot.mouseEnabled=true;
					activSlot.addEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false,0,true);
				}
			}
		}
		
		
		private function resetSlot():void {
			
			slotArr=new Array();
			var activSlot:MovieClip;
			cible["info"].visible=true;
			for (var i:int = 1; i <= 2; i++) 
			{
				activSlot=cible["slot_"+i];
				activSlot.fiche=null
				activSlot.visible=false;
				activSlot.removeEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false);
			}
		}
		
		private function showAllActiveCartes():void {
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				(arrFiche[i] as C_FicheSatelliteScaler).show();
				(arrFiche[i] as C_FicheSatelliteScaler).mouseEnabled=true;
			}
			
		}
		
		
	
		protected function evt_reprise(event:TuioTouchEvent):void
		{
			
			// TODO Auto-generated method stub
			var activSlot:MovieClip=(event.currentTarget as MovieClip);
			if (!activSlot.mouseEnabled) return;
			if (activSlot.fiche==null) 
				return;
			
			
			ArrayUtil.removeItem(slotArr,activSlot.fiche);
			arrFiche.push(activSlot.fiche);
			activSlot.fiche.mouseEnabled=true;
			activSlot.fiche.restore();
			activSlot.fiche=null;
			activSlot.visible=false;
			activSlot.removeEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false);
			if (slotArr.length==0) {
				cible["info"].visible=true;
			}
			updateIdentification();
			SoundController.instance.playSfx("sfx_deselection");
			
		}
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}