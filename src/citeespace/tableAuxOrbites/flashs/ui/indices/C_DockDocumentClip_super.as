package citeespace.tableAuxOrbites.flashs.ui.indices
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.PhysicsController;
	import citeespace.tableAuxOrbites.events.GameLogicEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.flashs.clips.CCollisionDefinitionClip;
	import citeespace.tableAuxOrbites.flashs.clips.C_TactileUiClip;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.Cubic;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.TransformGestureEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.clips.texts.TextFieldWithBackground;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.clips.DisplayObjectUtil;
	import utils.events.DataBringerEvent;
	import utils.events.EventChannel;
	import utils.params.ParamsHub;
	import utils.strings.TokenUtil;
	
	
	/**
	 * La gestion des boutons btnFermer et btnClose sera automatiquement prise 
	 * en compte dans l'ancêtre TactileUiClip
	 * 
	 * @author sps
	 * @version 1.0.0 [25 nov. 2011][sps] creation
	 * @version 1.0.1 [ 8 déc. 2011][sps] Ajout de la gestion dynamique du filtre d’ombre 
	 * @version 1.0.2 [12 déc. 2011][sps] Ajout de l'icone
	 *
	 *  TODO : gérer les états ouverts/fermés 
	 *
	 * citeespace.planisphere.flashs.ui.indices.C_IndiceClip_super
	 */
	
	public class C_DockDocumentClip_super extends C_TactileUiClip
	{
		
		
		
		
		// On stocke notre état initial
		protected var _initialScale:Number 		= 1.0;
		protected var _initialRotation:Number 	= 0;
		protected var _initialLocX:Number 		= 0;
		protected var _initialLocY:Number 		= 0;
		
		private var timerInit:Timer;
		
		public function C_DockDocumentClip_super() 
		{
			super();
			stop();
			timerInit=new Timer(100,1);
			timerInit.addEventListener(TimerEvent.TIMER_COMPLETE,evt_timer_init,false,0,true);
			_initialScale 		= this.scaleX;
			_initialRotation 	= this.rotation;
			_initialLocX		= this.x;
			_initialLocY		= this.y;
			
			proxyShapeType = PhysicsController.PROXY_SHAPE_CIRCLE;
			
			maxScale  	= params.getNumber('document_max_scale', 2);
			minScale 	= params.getNumber('document_min_scale', 0.5);
			openedScale = params.getNumber('document_opened_scale', 1.0);
			closedScale = params.getNumber('document_closed_scale', 0.5);
			
			maxScaleX = maxScaleY = maxScale;
			minScaleX = minScaleY = minScale;
			//onAddedToStage_planisphereTactileUiClip(null)
			/*
			if (stage) {
				onAddedToStage_planisphereTactileUiClip(null)
			}	 else {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_planisphereTactileUiClip);
			}
				*/	
			if (stage) evt_addedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, evt_addedToStage, false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE, evt_removedToStage, false,0,true);
		}
		
		protected function evt_timer_init(event:TimerEvent):void
		{
			MyTrace.put("evt_timer_init "+this.name)
			this_init_C_TactileUiClip()
		}
		
		protected function evt_removedToStage(event:Event):void
		{
			MyTrace.put("evt_removedToStage "+this.name);
		}
		
		private function evt_addedToStage(event:Event):void
		{
			MyTrace.put("evt_addedToStage "+this.name)
			//this_init_C_TactileUiClip()
			timerInit.start();
		}		
	
		
		protected function this_init_C_TactileUiClip():void
		{
			
			var usePhysics:Boolean = params.getBoolean('usePhysics', false);
			
			
			if (usePhysics) {
				if (_physicsProxy == null) _physicsProxy = this;
				physics = new PhysicsController(this, this.parent, proxyShapeType);
				physics.initSimulation();
				
				dragEnabled	  = false;
				
				rotateEnabled = false; 
				zoomEnabled	  = true; 
			} 
			
			if (physics) {
				physics.getUnrotatedRect = _getUnrotatedRect;
				visualDecorator.showCompleteCallback = showCompleteCallback;
				visualDecorator.hideCompleteCallback = hideCompleteCallback;
				physics.isRunning = true;
			}

			
			
			
			
		//	show(); 
		}
		
		protected function showCompleteCallback():void
		{
			
		}
		
		protected function hideCompleteCallback():void
		{
			
		}
		
		
		
		protected function _getUnrotatedRect(s:DisplayObject):Rectangle
		{
			var t_rot:Number;
			var out:Rectangle;
			
			if (_physicsProxy == null) 
			{
				// Version sans proxy
				t_rot = s.rotation;
				s.rotation = 0;
				
				out = getRect(parent); // new Rectangle(s.x, s.y, s.width, s.height);
				s.rotation = t_rot;
			} else {
				t_rot = s.rotation;
				s.rotation = 0;
				out = _physicsProxy.getRect(stage);
				
				// out = new Rectangle(s.x, s.y, s.width, s.height);
				s.rotation = t_rot;
			}
			
			return out;
		}
		
		
		
		public function repulse(xStageApplyPos:Number=NaN, yStageApplyPos:Number=NaN):void
		{
			physics.applyImpulseOnTargetObject(xStageApplyPos, yStageApplyPos);
		}
		
		
		/**
		 * // FIXE Méthode temporaire pour facilement tester l'état 'trouvé' de l'indice.  
		 * @param event
		 * 
		 */
		override protected function onTap_tactileClip(event:TuioTouchEvent):void
		{
			super.onTap_tactileClip(event);
		}
		
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			super.handleTouchBegin(event);
			this.depth = getTimer();
		}
		
		override protected function handleScale(event:TransformGestureEvent):void
		{
			super.handleScale(event);
			if (!zoomEnabled) return;
			_scaleUpdated();
		}
		
		
		
		override protected function handleRotate(event:TransformGestureEvent):void
		{
			super.handleRotate(event);
		}
		
		
		override protected function onDoubleTap_tactileClip(event:TuioTouchEvent):void
		{
			super.onDoubleTap_tactileClip(event);
			C_DebugConsole.setText("double tap");
			openDoc();
		}
		
		protected function openDoc():void
		{
			
			var mediumScale:Number = 0.5 * (openedScale + closedScale);
			var targetScale:Number = (scaleX > mediumScale)  ? closedScale : openedScale;
			openToScale(targetScale);
		}
		
		protected function openToScale(targetScale:Number):void
		{
			
			var tweenv:TweenMaxVars = new TweenMaxVars({scaleX:targetScale, scaleY:targetScale});
			tweenv.onComplete = onScaleTweeningComplete;
			tweenv.onUpdate = _scaleUpdated;
			TweenMax.to(this, 0.5, tweenv);
		}
		
		
		protected function _scaleUpdated(event:Event=null):void
		{
				onAskRefresh(null);
		}
		
		
		internal var _icoTransformMatrix:Matrix;
		/**
		 * On maintient la position de l'icone 
		 * 
		 */
	 
		
	
		
		protected function onScaleTweeningComplete():void
		{
			onAskRefresh(null);
		}
		
		
		
		
		
		
		
		

		
		override public function show(immediate:Boolean=false):void
		{
			// Avant d'afficher on met à joru les textes si besoin
				super.show(true);
			// On place cet item a sa position initiale
			x = _initialLocX;
			y = _initialLocY;
			scaleX = scaleY = _initialScale;
			rotation = _initialRotation;
			if (physics) {
				physics.kill();
				physics = new PhysicsController(this, this.parent, this.proxyShapeType);
				physics.initSimulation();
			}
			if (physics) {
				physics.showDebug();
				physics.isRunning = true;
			}
			
			onAskRefresh(null);
		}
		
		
		override public function hide(immediate:Boolean=false):void
		{
			if (physics) {
				physics.hideDebug();
				physics.isRunning = false;
				
			}
			
			super.hide(immediate);
		}
		
		
	}
}