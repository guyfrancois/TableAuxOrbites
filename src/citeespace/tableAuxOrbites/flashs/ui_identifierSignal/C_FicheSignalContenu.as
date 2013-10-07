package citeespace.tableAuxOrbites.flashs.ui_identifierSignal
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameData;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import utils.MyTrace;
	
	public class C_FicheSignalContenu extends MovieClip implements I_UserResponse
	{
		public var texte:TextField;
		public var fond:MovieClip;
		private var _id:Number;
		
		public var fiche:C_FicheSignal;// fiche associé pour le slot de poubelle
		public function get id():Number
		{
			return _id;
		}
		public function set id(val:Number):void {
			_id=val;
			_update();
		}
		
		public function C_FicheSignalContenu()
		{
			super();
			if (stage) onAddedToStage_C_ClipTxtLocalizable(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_ClipTxtLocalizable, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_ClipTxtLocalizable, false,0,true);
			
		}
		
		
		
		
		private function _update():void {
			if (id==0  ) {
				visible=false;
				return;
			} 
			visible=true;
			//var tf:TextField = getChildByName('tf') as TextField;
			
			var txtId:String = getQualifiedClassName(this)+"_sat"+GameData.instance.selectedSatellite+'_'+id;
			
			var daCo:DataCollection = DataCollection.instance;
			var str:String = daCo.getText(txtId, _lang);
			var strIsHtml:Boolean = daCo.isHtml(txtId, _lang); 
			this.texte.autoSize=TextFieldAutoSize.CENTER;
			
		
			if (strIsHtml) 
			{
				this.texte.htmlText = str;
			} else {
				this.texte.text = str;
			}
			var rect:Rectangle=this.texte.getBounds(this);
			rect.inflate(15,15);
			
			fond.width=rect.width
			fond.height=rect.height
			fond.x=rect.x+5
			fond.y=rect.y+5
			
		}
		
		
		
		
	
		
		
		
		protected function onAddedToStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged,false,0,true);
			onLangChanged(null);
			
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
		}
		
		public function setUser(user:Number):void
		{
			MyTrace.put("C_ClipUserTxtLocalizable.setUser "+user);
			_user=user;
			switch(_user)
			{
				case 2:
				{
					GameLogicEvent.channel.removeEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged);
					GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onLangChanged,false,0,true);
					break;
				}
					
				default:
				{
					GameLogicEvent.channel.removeEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onLangChanged);
					GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged,false,0,true);
					break;
				}
			}
			
			onLangChanged(null)
			
		}
		
		
		
		
		
		protected function onRemovedFromStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.removeEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged);
			GameLogicEvent.channel.removeEventListener(GameLogicEvent.LANGAGE_CHANGE_2, onLangChanged);
		}
		
		protected function onLangChanged(event:GameLogicEvent):void
		{
			
			lang = LangageController.instance.userLanguageOf(_user);
		}
		
		private var _user:Number;
		
		private var _lang:String;
		protected function get lang():String { return _lang; }
		protected function set lang(value:String):void
		{
			if (value == _lang) return;
			_lang = value;
			// 
			_update()
			
			
		}
		
	}
	
}