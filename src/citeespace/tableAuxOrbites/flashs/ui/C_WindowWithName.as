package citeespace.tableAuxOrbites.flashs.ui
{
 
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	import com.senocular.display.e4d_internal;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	import org.tuio.TuioTouchEvent;
	
	import utils.MyTrace;
	import utils.clips.DisplayObjectUtil;
	import utils.events.EventChannel;

	/**
	 * 
	 *
	 * @author Sps
	 * @version 1.0.0 [6 janv. 2012][Sps] creation
	 *
	 * citeespace.planisphere.flashs.ui.C_WindowWithName
	 */
	public class C_WindowWithName extends MovieClip
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		
		/* ----------------------------------------------------------------- */
		
		// On stocke notre état initial
		protected var _initialScale:Number 		= 1.0;
		protected var _initialRotation:Number 	= 0;
		protected var _initialLocX:Number 		= 0;
		protected var _initialLocY:Number 		= 0;
		
		//protected var _initialTransform:Transform
		
		public function C_WindowWithName()
		{
			super();
			stop();
			
			initVisualState();
		}
		
		
		private function initVisualState():void
		{
			// On backup la position/rotation/scale
			_initialScale 		= this.scaleX;
			_initialRotation 	= this.rotation;
			_initialLocX		= this.x;
			_initialLocY		= this.y;
			
			 
			
			if (stage) onAddedToStage_C_WindowWithName(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_WindowWithName, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_WindowWithName, false,0,true);
			
		}
		
		protected function onAddedToStage_C_WindowWithName(event:Event):void
		{
			 
			var navig:EventChannel = NavigationEvent.channel;
			navig.addEventListener(NavigationEvent.WINDOW_WITH_NAME_CLOSE_REQUEST, onCloseWindowRequest);
			navig.addEventListener(NavigationEvent.WINDOW_WITH_NAME_OPEN_REQUEST, onOpenWindowRequest);
			
			var btnFermer:InteractiveObject = getChildByName('btnFermer') as InteractiveObject;
			if (btnFermer)
			{
				btnFermer.addEventListener(TuioTouchEvent.TAP, onClickFermer, false,0,true);
			}
			
			hide(true);
		}
		
		protected function onClickFermer(event:TuioTouchEvent):void
		{
			hide();
		}
		
		protected function onCloseWindowRequest(event:NavigationEvent):void
		{
			var targetWindowName:String = event.data as String;
			if (targetWindowName != this.name && targetWindowName != "*") return;

			hide();
		}
		
		protected function onOpenWindowRequest(event:NavigationEvent):void
		{
			var targetWindowName:String = event.data as String;
			if (targetWindowName != this.name && targetWindowName != "*") return;
			
			show();
		}
		
		protected function onRemovedFromStage_C_WindowWithName(event:Event):void
		{
			var navig:EventChannel = NavigationEvent.channel;
			// navig.removeEventListener(NavigationEvent.FOCUS_INDICE_LAYER, onFocusNotification);
			
		}
		
	 
		
		protected function showCompleteCallback():void
		{
		
		}
		
		protected function hideCompleteCallback():void
		{
		
		}
		
	 
		
		public function show(immediate:Boolean=false):void
		{
			TweenLite.killTweensOf(this);
			visible = true;
			alpha = 1;
		}
		
		
		public function hide(immediate:Boolean=false):void
		{
			if (immediate) {
				visible = false;
			} else {
				TweenLite.to(this, 0.3, {alpha:0, onComplete:hideComplete});
			}
		}
		
		protected function hideComplete():void
		{
			visible = false;
		}
		
		
	}
}