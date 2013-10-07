package citeespace.tableAuxOrbites.flashs.ui_identifierSatellite
{
	import citeespace.tableAuxOrbites.controllers.SoundController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	import utils.MyTrace;

	public class C_FicheSatelliteScaler  extends TactileUiClip 
	{
		
		public var ref:MovieClip;
		public var fiche:C_FicheSatellite;
		public var btn_fermer:MovieClip;
		public var btn_ouvre:MovieClip;
		
		
		private var pos_init:Point;
		private var scale_init:Number;
		
		private var _satellite:Number;
		
		
		
		
		public function get satellite():Number
		{
			return _satellite;
		}
		
		
		public function C_FicheSatelliteScaler()
		{
		
			
			super();
			scale_init=1;
			pos_init=new Point(x,y);
			/**
			 * Echelle X minimum du clip lors de la mise à l'échelle par pincement à 2 doigts 
			 */
			minScaleX = 1;
			
			/**
			 * Echelle X maximum du clip lors de la mise à l'échelle par pincement à 2 doigts 
			 */
			maxScaleX = 1;
			
			/**
			 * Echelle Y minimum du clip lors de la mise à l'échelle par pincement à 2 doigts 
			 */
			minScaleY = 1;
			
			/**
			 * Echelle Y maximum du clip lors de la mise à l'échelle par pincement à 2 doigts 
			 */
			//fiche.maxScaleY;
			_satellite=UI_utils.identify_ui_satellite(getQualifiedClassName(this));
			fiche.satellite=_satellite;
			btn_ouvre.addEventListener(TuioTouchEvent.TAP,evt_btn_open,false,0,true);
			btn_fermer.addEventListener(TuioTouchEvent.TAP,evt_btn_close,false,0,true);
			scale=1;
		}
		
		protected function evt_btn_close(event:Event):void
		{
			if (!mouseEnabled) return;
			TweenLite.killTweensOf(this);
			fiche.anim=false;
			TweenLite.to(this,0.5,{scale:1,onComplete:function(){fiche.anim=true}});
			SoundController.instance.playSfx("sfx_carte_fermeture");
		}
		
		
		protected function evt_btn_open(event:Event):void
		{
			if (!mouseEnabled) return;
			TweenLite.killTweensOf(this);
			fiche.anim=false;
			TweenLite.to(this,0.5,{scale:fiche.maxScaleY,onComplete:function(){fiche.anim=true}});
			SoundController.instance.playSfx("sfx_carte_ouverture");
		}		
		
		
		override public function show(immdediate:Boolean=false):void {
			TweenLite.killTweensOf(this);
			super.show(immdediate)
			if (immdediate) {
				x=pos_init.x;
				y=pos_init.y;
				scale=scale_init;
			} else {
				restore();
			}
			
		}
		private function onRestore():void {
			fiche.anim=true
		}
		
		public function restore():void {
			_dragOffset == null
			visible=true;
			TweenLite.killTweensOf(this);
			super.show(true)
			TweenLite.to(this,1,{x:pos_init.x,y:pos_init.y,scale:scale_init,onComplete:onRestore});
		}
		
		private var _callBack:Function
		
		public function afficheTo(slotP:Point,callBack:Function=null):void {
			TweenLite.killTweensOf(this);
			super.show(true)
			this._callBack=callBack;
			var dest:Point=parent.globalToLocal(slotP);
			//mouseEnabled=false;
			TweenLite.to(this,1,{x:dest.x,y:dest.y,scale:fiche.maxScaleY,rotation:0,onComplete:onAfficheTo});
		}
		private function onAfficheTo():void {
			fiche.anim=true
			if (_callBack!=null)
				_callBack.call();
		}
		
		public function dropTo(slotP:Point,callBack:Function=null):void {
			TweenLite.killTweensOf(this);
			this._callBack=callBack;
//			_closeFile();
			var dest:Point=parent.globalToLocal(slotP);
			//mouseEnabled=false;
			TweenLite.to(this,0.5,{x:dest.x,y:dest.y,scale:0.3,rotation:0,onComplete:onDropTo});
		}
		
		
		private function onDropTo():void {
			fiche.anim=true
			visible=false;
			if (_callBack!=null)
				_callBack.call(null,this);
		}
		
		
		override public function hide(immdediate:Boolean=false):void {
			TweenLite.killTweensOf(this);
			fiche.anim=false;
			x=pos_init.x;
			y=pos_init.y;
			scale=scale_init;
			//mouseEnabled=false;
			super.hide(immdediate)
		}
		
		
		
		
		
		
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			if (!mouseEnabled) return;
			fiche.anim=false;
			parent.addChild(this);
			dragEnabled=true;
			rotateEnabled = true;
			zoomEnabled = true;
			super.handleTouchBegin(event);
			
		}
		
		override protected function handleDrag(event:TransformGestureEvent):void
		{
			if (!mouseEnabled) return;
			fiche.anim=false;
			var _localoffset : Point = parent.globalToLocal(new Point(event.offsetX,event.offsetY)).subtract(parent.globalToLocal(new Point(0,0)));
			
			
			if (_dragOffset == null) _dragOffset = new Point(0,0);
			_dragOffset.offset(_localoffset.x,_localoffset.y)
			
			
			if (dragEnabled) 
			{
				//if (hitTestPoint(event.stageX,event.stageY)) {
					
					var nextPos:Point=new Point(this.x,this.y).add(_localoffset);
					
					
					
					
					
					var zone:DisplayObject=parent["dragArea"];
					
					var gPos:Point=parent.localToGlobal(nextPos);
					if (zone && !zone.hitTestPoint(gPos.x,gPos.y)) {
						
					} else {
						this.x += _localoffset.x;
						this.y += _localoffset.y;
					}
				//}
			}  else {
				if (!rotateEnabled && rotationParDrag)
					// Si pas de rotation libre on regarde pour la rotation par drag'n drop
				{
					// On regarde la direction
					var dist:Number = Point.distance(_dragOffset, new Point(0,0));
					var dbgStr:String = 'dist :' +Math.round(dist);
					if (dist > dragRotateDistThreshold)
					{
						if (Math.abs(_dragOffset.x) > Math.abs(_dragOffset.y)) {
							// left/right
							if (_dragOffset.x > 0) {
								// right
								dbgStr += " right";
								rotation = dragRotateRight;
							} else {
								// left
								dbgStr += " left";
								rotation = dragRotateLeft;
							}
						} else {
							// top/bottom
							if (_dragOffset.y > 0) {
								// bottom
								dbgStr += " bottom";
								rotation = dragRotateBottom;
							} else {
								// top
								dbgStr += " top";
								rotation = dragRotateUp;
							}
						}
					}
				}
				// C_DebugConsole.setText(dbgStr );
			}
		}
		
		override public function get scaleY():Number
		{
			//		return super.scaleY;
			return super.scaleY;
		}
		
		override public function set scaleY(value:Number):void
		{
			//super.scaleY = value;
			MyTrace.put("C_FicheSatelliteScaler "+value);
			fiche.updateScaleY(value);
			super.scaleY=value;
			
			btn_fermer.scaleY=1/value;
			btn_ouvre.scaleY=1/value;
			if (value<minScaleY-0.1) {
				btn_ouvre.visible=false;
				btn_fermer.visible=false;
				
			}	else 	if (value<minScaleY+0.1) {
				btn_ouvre.visible=true;
				btn_fermer.visible=false;
			} else {
				btn_ouvre.visible=false;
				btn_fermer.visible=true;
			} 
			
			
		}

		override public function get scaleX():Number
		{
			//		return super.scaleY;
			return super.scaleX;
		}
		
		override public function set scaleX(value:Number):void
		{
			//super.scaleX = value;
			
			fiche.updateScaleX(value);
			if (value<minScaleX-0.1) {
				btn_ouvre.visible=false;
				btn_fermer.visible=false;
			}
			super.scaleX=value;
		}
		
		public function set scale(value:Number):void {
			scaleY=value;
			if (value>1) {
				scaleX=1;
			} else {
				scaleX=value;
			}
		}
		
		public function get scale():Number {
			return scaleY
		}
		
		
		
		override protected function handleScale(event:TransformGestureEvent):void 
		{
			if (!mouseEnabled) return;
			if (!zoomEnabled) return;
			//var newScaleX:Number = this.scaleX * event.scaleX;
			var newScaleY:Number = this.scaleY * event.scaleY;
			//newScaleX = Math.max(minScaleX, Math.min(newScaleX, maxScaleX));
			newScaleY = Math.max(minScaleY, Math.min(newScaleY, fiche.maxScaleY));
			//this.scaleX = newScaleX;
			this.scaleY = newScaleY;
			
			/*
			var testFactorScale:Number=event.scaleX*event.scaleY;
			trace(event.scaleX,event.scaleY,testFactorScale);
			
			if (testFactorScale>testFactorScale_openFiche) {
			_openFile();
			} else if (testFactorScale<testFactorScale_closeFiche) {
			_closeFile();
			}*/
		}
		
		
		
	
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			fiche.anim=true;
			C_DebugConsole.setText("handleTouchEnd "+satellite+" ")
			dragEnabled=false;
			rotateEnabled = false;
			zoomEnabled = false;
			
			super.handleTouchEnd(event);
			if (!mouseEnabled)	return;
			dispatchEvent(new AskUserEvent(AskUserEvent.ITEM_DROPED,{item:this,pos:new Point(event.stageX,event.stageY)}));
		}
		
	}
}