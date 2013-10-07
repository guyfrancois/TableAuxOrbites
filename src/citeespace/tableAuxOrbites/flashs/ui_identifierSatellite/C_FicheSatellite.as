package citeespace.tableAuxOrbites.flashs.ui_identifierSatellite
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.flashs.ui.I_UserResponse;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getQualifiedClassName;
	
	import mx.effects.Tween;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	import utils.MyTrace;
	import utils.movieclip.MovieClipUtils;
	import utils.params.ParamsHub;
	
	public class C_FicheSatellite extends MovieClip implements I_UserResponse
	{
		public var masque:MovieClip;
		public var fond:MovieClip;
		public var img:MovieClip;// img.item.video
		
		public var commentairetf:TextField;
		private var _satellite:Number;
		
		public function set anim(val:Boolean):void {
			if (val) 	img.item.play();
			else img.item.stop();
		}

		public function get maxScaleY():Number
		{
			
			return _maxScaleY;
		}

		public function get satellite():Number
		{
			return _satellite;
		}
		public function set satellite(value:Number):void
		{
			_satellite=value;
			onLangChanged(null);
		}
		
		public function updateScaleX(val:Number):void {
			/*
			if (val>1) {
				scaleX=1/val;
			}
			*/
		}
		public function updateScaleY(val:Number):void {
			if (val>1) {
				scaleY=1/val;
				fond.scaleY=val;
				masque.scaleY=val;
			} else {
				scaleY=1
				fond.scaleY=1;
				masque.scaleY=1;
			}
		}
		
	
		
		public function C_FicheSatellite()
		{
			super();
			
			stop();
		
			
			if (stage) onAddedToStage_C_ClipTxtLocalizable(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_ClipTxtLocalizable, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_ClipTxtLocalizable, false,0,true);
			
			
			
		}
		
		
		
		
		
		
		
		
		
		
		//////////////////// gestion des textes ///////////////////////////////////////////////
		protected function onAddedToStage_C_ClipTxtLocalizable(event:Event):void
		{
			GameLogicEvent.channel.addEventListener(GameLogicEvent.LANGAGE_CHANGE, onLangChanged,false,0,true);
			
			
			dispatchEvent(new AskUserEvent(AskUserEvent.ASK_USER_INTERFACE,this));
			onLangChanged(null);
		}
		
	
		public function setUser(user:Number):void
		{
			MyTrace.put("C_FicheSatellite.setUser "+user);
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
			
			//var tf:TextField = getChildByName('tf') as TextField;
			var tf:TextField = commentairetf ;
			tf.autoSize=TextFieldAutoSize.LEFT;
			var txtId:String = "ui_label_identifier_satellite_sat"+_satellite+"_commentaire";
			
			var daCo:DataCollection = DataCollection.instance;
			var str:String = daCo.getText(txtId, _lang);
			var strIsHtml:Boolean = daCo.isHtml(txtId, _lang); 
			if (strIsHtml) 
			{
				tf.htmlText = str;
			} else {
				tf.text = str;
			}
			var maxHeight:Number=commentairetf.y+commentairetf.height+30;
			_maxScaleY=maxHeight/commentairetf.y;
			
		}
		
		private var _maxScaleY:Number=1;
		
		
	
	}
}