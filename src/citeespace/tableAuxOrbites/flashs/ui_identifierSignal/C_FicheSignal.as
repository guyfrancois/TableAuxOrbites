package citeespace.tableAuxOrbites.flashs.ui_identifierSignal
{
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.tools.UI_utils;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import mx.effects.Tween;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	import utils.movieclip.MovieClipUtils;
	
	public class C_FicheSignal extends TactileUiClip
	{
		public var contenu:C_FicheSignalContenu
		
		private var pos_init:Point;
		private var scale_init:Number;
		private var rotation_init:Number;
		
		
		public function get id():Number
		{
			return contenu.id;
		}
		public function set id(val:Number):void {
			contenu.id=val;
			hide(true);
			
		}
		
		public function C_FicheSignal()
		{
			super();
			
			stop();
			mouseChildren=false;
			mouseEnabled = false;
			dragEnabled=false;
		
			pos_init=new Point(x,y);
			scale_init=scaleX;
			rotation_init=rotation;
		}
		
		private var _callBack:Function
		public function afficheTo(slotP:Point,callBack:Function=null):void {
			super.show(true)
			this._callBack=callBack;
			var dest:Point=parent.globalToLocal(slotP);
			TweenLite.to(this,1,{x:dest.x,y:dest.y-contenu.height/2,scaleX:scale_init,scaleY:scale_init,rotation:0,onComplete:onAfficheTo});
		}
		private function onAfficheTo():void {
			if (_callBack!=null)
				_callBack.call();
		}
		
		public function dropTo(slotP:Point,callBack:Function=null):void {
			this._callBack=callBack;
			
			var dest:Point=parent.globalToLocal(slotP);
			TweenLite.to(this,1,{x:dest.x,y:dest.y,scaleX:0.5,scaleY:0.5,rotation:0,onComplete:onDropTo});
		}
		
		
		private function onDropTo():void {
			visible=false;
			if (_callBack!=null)
				_callBack.call();
		}
		
		
		
		override public function show(immdediate:Boolean=false):void {
			super.show(immdediate)
			if (immdediate) {
				x=pos_init.x;
				y=pos_init.y;
				scaleX=scale_init;
				scaleY=scale_init;
				rotation=rotation_init;
			} else {
				restore();
			}

		}
		
		override public function hide(immdediate:Boolean=false):void {
			x=pos_init.x;
			y=pos_init.y;
			scaleX=scale_init;
			scaleY=scale_init;
			rotation=rotation_init;
			super.hide(immdediate)
		}
		

		public function restore():void {
			visible=true;
			super.show(true)
			TweenLite.to(this,1,{x:pos_init.x,y:pos_init.y,scaleX:scale_init,scaleY:scale_init,rotation:rotation_init,onComplete:onRestore});
		}
		
		
		private function onRestore():void {
			
		}
		

		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			if(!mouseEnabled)	return;
			parent.addChild(this);
			dragEnabled=true;
			rotateEnabled = true;
			zoomEnabled = false;
			super.handleTouchBegin(event);
			
		}
		
		override protected function handleDrag(event:TransformGestureEvent):void
		{
			var _localoffset : Point = parent.globalToLocal(new Point(event.offsetX,event.offsetY)).subtract(parent.globalToLocal(new Point(0,0)));
			
			
				if (_dragOffset == null) _dragOffset = new Point(0,0);
			_dragOffset.offset(_localoffset.x,_localoffset.y)
			
			
			if (dragEnabled) 
			{
				//if (hitTestPoint(event.stageX,event.stageY)) {
					
					var nextPos:Point=new Point(this.x,this.y).add(_localoffset);
					
					
					
					
					
					var zone:DisplayObject=parent["dragArea"];
				
					var gPos:Point=parent.localToGlobal(nextPos);
					if (!zone.hitTestPoint(gPos.x,gPos.y)) {
					
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
		
		override protected function handleScale(event:TransformGestureEvent):void 
		{
			if (!zoomEnabled) return;
			
		}
		

		
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			C_DebugConsole.setText("handleTouchEnd deplacable");
			if (!mouseEnabled) return;
				
			
			
			super.handleTouchEnd(event);
			dispatchEvent(new AskUserEvent(AskUserEvent.ITEM_DROPED,{item:this,pos:new Point(event.stageX,event.stageY)}));
			dragEnabled=false;
			rotateEnabled = false;
			zoomEnabled = false;
			
		}
		
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(this,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(this,Math.abs(frame-currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
	}
}