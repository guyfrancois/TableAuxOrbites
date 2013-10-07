package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.controllers.SoundController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.flashs.ui_identifierSignal.C_ErreurSignalContenu;
	import citeespace.tableAuxOrbites.flashs.ui_identifierSignal.C_FicheSignal;
	import citeespace.tableAuxOrbites.flashs.ui_identifierSignal.C_FicheSignalContenu;
	import citeespace.tableAuxOrbites.tools.SynAnimSoundSequ;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import org.casalib.util.ArrayUtil;
	import org.tuio.TuioTouchEvent;
	
	import utils.MyTrace;
	import utils.events.EventChannel;
	import utils.movieclip.MovieClipUtils;

	public class F_ui_IdentifierSignal extends F_Anim_super implements I_UserResponse
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
		private var zoneErreur:C_ErreurSignalContenu;
		
		public function setUser(user:Number):void
		{
			_user=user;
		}
		
		private var synSequ:SynAnimSoundSequ;
		
		public function F_ui_IdentifierSignal()
		{
		
			super();
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false,0,true);
			
			
			// ecouter ,repondre et signaler d'utilisateur de cette interface
			var chan:EventChannel = GameLogicEvent.channel;
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_SHOW, onShow);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_HIDE, onHide);
			
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_ERREUR, onErreur);
			chan.addEventListener(GameLogicEvent.IDENTIFIER_SIGNAL_AFFICHE_REPONSE, onAfficheReponse);
			
			chan.addEventListener(GameLogicEvent.USER_VALIDE, onUserValide);
			
			FRAME_ACT	=	hframeof("FRAME_ACT");
			zoneErreur=fiche_animation.erreur;
			
			
		}
		
		
		
		protected function onShow(event:GameLogicEvent):void
		{
			if (state!=STATE_HIDE)		return;
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			state=STATE_SHOW;
			gotoAndStop(1);
			var listId:Array=event.data as Array;// listId =  ArrayUtil.randomize([1,2,3]);
				
			
			initGame(listId);
			show();
			//LangageController.instance.clear_uniq_txtid();
			
			synSequ=new SynAnimSoundSequ(this,dispatchintroOk);
			synSequ.add(FRAME_ACT,"identifier_signal");
			synSequ.add(showNextItem,_helperIdFicheSignal(0));
			synSequ.add(showNextItem,_helperIdFicheSignal(1));
			synSequ.add(showNextItem,_helperIdFicheSignal(2));
			synSequ.add(null,"identifier_signal_invitation");
			
			itemCounter=0;
			synSequ.play();
			
		}		
		
		private function _helperIdFicheSignal(index:Number):String {
			return "q_identifier_signal_sat"+GameData.instance.selectedSatellite+'_'+( arrFiche[index] as C_FicheSignal).id;
		}
		
		private function dispatchintroOk():void {
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				(arrFiche[i] as C_FicheSignal).mouseEnabled=true;
			}
			NavigationEvent.dispatch(NavigationEvent.IDENTIFIER_SIGNAL_INTROCOMPLET);
			
		}
		
		
		private function initGame( listId:Array):void {
			arrFiche=[fiche_animation.info1,fiche_animation.info2,fiche_animation.info3];
			
			resetSlot();
			zoneErreur.id=0;
			maxSlot=2;
			updateIdentification();
			
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				arrFiche[i].id=listId[i];
				arrFiche[i]..mouseEnabled=false;
				
			}
		}
		
		
		private var itemCounter:Number=0;
		private function showNextItem(cbAnim:Function) {
			arrFiche[itemCounter].show();
			itemCounter++;
			cbAnim.call();
		}
		
		protected function onUserValide(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			if (state != STATE_SHOW) return;
			
			if (event.data==_user) {
				for (var i:int = 0; i < arrFiche.length; i++) 
				{
					(arrFiche[i] as C_FicheSignal).mouseEnabled=false;
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
		protected function onErreur(event:GameLogicEvent):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			resetSlot();
			cible["info"].visible=false;
			// une erreur à commenter
			var erreurId:Number=event.data as Number;
 			if (erreurId!=0) {
				for (var j:int = 0; j < arrFiche.length; j++) 
				{
					if (arrFiche[j].id==erreurId) {
						zoneErreur.id=arrFiche[j].id;
						arrFiche[j].dropTo(fiche_animation.localToGlobal(new Point(zoneErreur.x,zoneErreur.y)));
						break;
					}
				}
			}
			
			
			arrFiche=[fiche_animation.info1,fiche_animation.info2,fiche_animation.info3];
			var tar:Array=arrFiche.concat();
			for (var i:int = 0; i < tar.length; i++) 
			{
				
				if (tar[i].id!=1 && tar[i].id!=zoneErreur.id) {
					tar[i].hide();
					ArrayUtil.removeItem(arrFiche,tar[i]);
				}
				if (tar[i].id==zoneErreur.id) {
					ArrayUtil.removeItem(arrFiche,tar[i]);
				}
				
			}
			
			maxSlot=0

			
		}
		
		protected function onAfficheReponse(event:Event):void
		{
			if (_user==0 && GameData.instance.playerNumber == 2) 	return;
			if (_user>0 && GameData.instance.playerNumber < 2) 	return;
			
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				
				if (arrFiche[i].id==1) {
					if (GameData.instance.playerNumber == 2) {
						arrFiche[i].afficheTo(localToGlobal(new Point(475,610)));
					} else {
						arrFiche[i].afficheTo(localToGlobal(new Point(600,600)));
					}
				}
			}
		}
		
	
		
		
		protected function onHide(event:GameLogicEvent):void
		{
			if (state!=STATE_SHOW)	return;
			if (synSequ) synSequ.stop();
			state=STATE_HIDE
			hide();
		}
		
		
	
		
		
		private function updateIdentification():void {
			if (arrFiche.length>1) {
				GameData.instance.setIdentification(_user,0);
				GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_HIDE,_user);
			} else {
				GameData.instance.setIdentification(_user,arrFiche[0].id);
				GameLogicEvent.dispatch(GameLogicEvent.USER_VALIDER_SHOW,_user);
			}
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
			
			var fiche:C_FicheSignal=event.data.item as C_FicheSignal
			var gp:Point=event.data.pos;
			if (cible.hitTestPoint(gp.x,gp.y,true) && (arrFiche.length>1)) {
				//NavigationEvent.dispatch(NavigationEvent.SUP);
				doStockCorbeille(fiche);
			}
			
		}
		
		
		
		private function doStockCorbeille(fiche:C_FicheSignal):void
		{
			
				
			var activSlot:C_FicheSignalContenu;
			if (slotArr.indexOf(fiche)==-1 ) {
				slotArr.push(fiche);
				ArrayUtil.removeItem(arrFiche,fiche);
			}
			updateIdentification();
			for (var i:int = 1; i <= maxSlot; i++) 
			{
				activSlot=cible["slot_"+i];
				if (activSlot.fiche==fiche) return;
				if (!activSlot.fiche) {
					activSlot.fiche=fiche;
					SoundController.instance.playSfx("sfx_selection");
					fiche.dropTo(cible.localToGlobal(new Point(activSlot.x,activSlot.y)),cb_dropComplet);
					return;
				} 
			}
			
		}
		
		private function resetSlot():void {
			
			slotArr=new Array();
			var activSlot:C_FicheSignalContenu;
			cible["info"].visible=true;
			for (var i:int = 1; i <= 2; i++) 
			{
				activSlot=cible["slot_"+i];
				activSlot.id=0
				activSlot.visible=false;
				activSlot.fiche=null
				activSlot.removeEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false);
			}
		}
		
		private function showAllActiveCartes():void {
			for (var i:int = 0; i < arrFiche.length; i++) 
			{
				arrFiche[i].show();
			}
			
		}
		
		
		private function cb_dropComplet():void
		{
			var activSlot:C_FicheSignalContenu;
		
			cible["info"].visible=false;
			for (var i:int = 1; i <= maxSlot; i++) 
			{
				activSlot=cible["slot_"+i];
				if (activSlot.fiche && activSlot.visible==false) {
					activSlot.visible=true;
					activSlot.id=activSlot.fiche.id;
					cible["supp"].x=activSlot.x
					cible["supp"].y=activSlot.y
					cible["supp"].gotoAndPlay(2);
					activSlot.addEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false,0,true);
				}
			}
		}
		
		protected function evt_reprise(event:TuioTouchEvent):void
		{
			// TODO Auto-generated method stub
			var activSlot:C_FicheSignalContenu=(event.currentTarget as C_FicheSignalContenu);
			if (activSlot.fiche==null) 
				return;
			
			
			ArrayUtil.removeItem(slotArr,activSlot.fiche);
			arrFiche.push(activSlot.fiche);
			
			activSlot.fiche.restore();
			activSlot.fiche=null;
			activSlot.visible=false;
			activSlot.id=0
			activSlot.removeEventListener(TuioTouchEvent.TOUCH_DOWN,evt_reprise,false);
			SoundController.instance.playSfx("sfx_deselection");
			if (slotArr.length==0) {
				cible["info"].visible=true;
			}
			updateIdentification()
			
		}
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}