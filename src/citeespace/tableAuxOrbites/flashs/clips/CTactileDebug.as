package citeespace.tableAuxOrbites.flashs.clips
{
	import citeespace.tableAuxOrbites.controllers.PhysicsController;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import com.greensock.TweenMax;
	import com.greensock.data.TweenLiteVars;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.TactileClip;
	
	import utils.MyTrace;
	import utils.params.ParamsHub;
	
	/**
	 * 
	 *
	 * @author sps
	 *
	 * citeespace.planisphere.flashs.clips.CTactileDebug
	 */
	public class CTactileDebug extends C_TactileUiClip
	{

		public var outputText:Boolean = false;
		
		protected var alpha_idle:Number = 0.4;
		protected var alpha_down:Number = 1;
		
		
		 
	
		public function CTactileDebug()
		{
			super();
			
			var w:Number = 400;
			var dbg_rect:Shape;

			dbg_rect = new Shape();
			dbg_rect.graphics.clear();
			dbg_rect.graphics.beginFill(0xFF00FF);
			dbg_rect.graphics.drawRect(-w/2, -w/2, w, w);
			alpha = alpha_idle;
			
			addChild(dbg_rect);
			
			dbg_rect = new Shape();
			dbg_rect.graphics.clear();
			dbg_rect.graphics.beginFill(0x00FF00);
			dbg_rect.graphics.drawRect(-w/2, -w/2, 10, 10);
			addChild(dbg_rect);
			
			x = 100+w;
			y = w/2;
			
			mouseEnabled  = true;
			dragEnabled	  = true;
			rotateEnabled = true; 
			zoomEnabled	  = true; 
			 
			
			addEventListener(TuioTouchEvent.TAP, handleTap);
			addEventListener(TuioTouchEvent.TOUCH_MOVE, onMove);
			addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
			
			
			if (stage) onAddedToStage_CTactileDebug(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_CTactileDebug, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_CTactileDebug, false,0,true);
		}
		
		
		
		
		
		protected function onRemovedFromStage_CTactileDebug(event:Event):void
		{
			
		}
		
		protected function onAddedToStage_CTactileDebug(event:Event):void
		{
			
		
			//stage.addEventListener(TransformGestureEvent.GESTURE_PAN, onPanStage);
			/*
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEnd);
			stage.addEventListener(TouchEvent.TOUCH_TAP, stage_touchTap);
			*/
			/*
			stage.addEventListener(TuioTouchEvent.TOUCH_DOWN, onStageTuioTouchDown);
			stage.addEventListener(TuioTouchEvent.TOUCH_UP, onStageTuioTouchUp);
			stage.addEventListener(TuioTouchEvent.TAP, onStageTuioTouchTap);
			stage.addEventListener(TuioTouchEvent.TOUCH_MOVE, onStageTuioTouchMove);
			stage.addEventListener(TransformGestureEvent.GESTURE_PAN, onStageTuioPan);
			*/
		}
		
		override protected function init_C_TactileUiClip():void
		{
			
			super.init_C_TactileUiClip();
			if (physics) {
				// physics.getUnrotatedRect = _getUnrotatedRect;
				physics.isRunning = true;
			}
		}
		
		protected function onStageTuioPan(event:TransformGestureEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg tuioTouchPan " +event.offsetX + ', '+event.offsetX);
			
		}
		
		protected function onStageTuioTouchMove(event:TuioTouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg tuioTouchMove " +event.localX + ', '+event.localY);
			
		}
		
		protected function onStageTuioTouchTap(event:TuioTouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg tuioTouchTap " +event.localX + ', '+event.localY);
			
		}
		
		protected function onStageTuioTouchUp(event:TuioTouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg tuioTouchUp " +event.localX + ', '+event.localY);
			
		}
		
		protected function onStageTuioTouchDown(event:TuioTouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg tuioTouchDown " +event.localX + ', '+event.localY);
			
		}
		
		protected function stage_touchTap(event:TouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg touchTap " +event.localX + ', '+event.localY);
			
		}
		
		protected function stage_touchEnd(event:TouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg touchEnd " +event.localX + ', '+event.localY);
			
		}
		
		protected function stage_touchMove(event:TouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("touchMove " +event.localX + ', '+event.localY);
			
		}
		
		protected function stage_touchBegin(event:TouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg touchBegin " +event.localX + ', '+event.localY);
		}
		
		protected function onPan(event:TransformGestureEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg pan " +event.offsetX + ', '+event.offsetY);
			
		}
		
		protected function onPanStage(event:TransformGestureEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg panstage " +event.offsetX + ', '+event.offsetY);
			
		}
		
		protected function onMove(event:TuioTouchEvent):void
		{
			if (outputText) C_DebugConsole.setText("dbg move " +event.localX + ', '+event.localY);
		}	
		
		protected function handleTap(event:TuioTouchEvent):void
		{
			alpha = alpha_down;
			//var tweenv:TweenMaxVars = new TweenMaxVars({alpha:0.2, scaleX:scaleX-0.1, scaleY:scaleY-0.1});
			var tweenv:TweenMaxVars = new TweenMaxVars({alpha:0.2});
			tweenv.yoyo = true;
			tweenv.repeat = 1;
			tweenv.ease = Bounce.easeInOut;
			TweenMax.to(this, 0.15, tweenv);
		}
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			super.handleTouchBegin(event);
			alpha = alpha_down;
			// MyTrace.put(">>>> begin");
			//	inertieWatcher.releaseControl();
		}
		 
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
		
			super.handleTouchEnd(event);
			alpha = alpha_idle;
			// MyTrace.put("<<<< end");
		//	inertieWatcher.takeControl();
		}
		
		override protected function handleDrag(event:TransformGestureEvent):void
		{
			// Gestion du drag
			super.handleDrag(event);
		}

		override protected function handleScale(event:TransformGestureEvent):void
		{
			super.handleScale(event);
			
		}
		
		
		
	}
}