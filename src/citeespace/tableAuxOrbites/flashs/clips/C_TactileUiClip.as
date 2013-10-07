package citeespace.tableAuxOrbites.flashs.clips
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.PhysicsController;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	import utils.MyTrace;
	import utils.params.ParamsHub;
	
	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [2 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.clips.C_PlanisphereTactileUiClip
	 */
	public class C_TactileUiClip extends TactileUiClip
	{
		
		/* -------- Éléments définis dans le Flash ------------------------- */
		
		/* ----------------------------------------------------------------- */
		public var minScale:Number = 0.5;
		public var maxScale:Number = 2;
		
		public var openedScale:Number = 1.5;
		public var closedScale:Number = 0.7;
		
		public var depth:int = 0;
		
		protected var physics:PhysicsController;
		/**
		 * physicsProxy permet de définir un displayObject servant de zone interactive pour les actions physiques, sans forcement tenir compte de l'ensemble du Clip.
		 * physicsProxy devrait idéalement être un des children de ce clip, pour en subir les modification de position/rotation/échelle
		 * Si null, alors le clip complet est utilisé comme zone physique. 
		 */
		protected var _physicsProxy:DisplayObject;
		
		/**
		 * proxyShapeType pourra prendre comme valeur  
		 * PhysicsController.PROXY_SHAPE_CIRCLE ou 
		 * PhysicsController.PROXY_SHAPE_SQUARE
		 */
		public var proxyShapeType:uint;
		
		public function C_TactileUiClip()
		{
			super();
			stop()
			proxyShapeType = PhysicsController.PROXY_SHAPE_CIRCLE;
			mouseEnabled  = true;
			dragEnabled   = true;
			
			
			var t_PhyProx:DisplayObject = getChildByName('physicsProxy');
			if (t_PhyProx != null) {
				_physicsProxy = t_PhyProx;
				_physicsProxy.alpha = 0;
			}
			
		
			
			
		}
		
		protected function onAddedToStage_planisphereTactileUiClip(event:Event):void
		{
			
			//removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage_planisphereTactileUiClip);
			init_C_TactileUiClip();
		}
		/*
		protected function onEnterFrame_handler(event:Event):void
		{
			
			if (stage) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame_handler);
				init_C_TactileUiClip();
				
			} else {
				// addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_planisphereTactileUiClip);
			}
		}*/
		
		
		protected function get params():ParamsHub
		{
			return ParamsHub.instance;
		}
		
		protected function init_C_TactileUiClip():void
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
		}
		
		
		override protected function handleScale(event:TransformGestureEvent):void
		{
			if (!zoomEnabled) return;
			super.handleScale(event);
			
			if (physics == null) return;
			
			// On met à jour 'échelle de notre body physics 
			physics.refreshScale(this);
			
			addEventListener(Event.ENTER_FRAME, onAskRefresh);
		}
		
		
		protected function onAskRefresh(event:Event):void
		{
			physics.refreshScale(this);
		}		
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			
			super.handleTouchEnd(event);
			
			// Si on sort de la scène, on y retourne !
			var loc:Point = parent.localToGlobal(new Point(x, y));
			
			var margin:Number = DataCollection.params.getNumber('documents_screen_margin', 0);
			
			var visibleRect:Rectangle = new Rectangle(0,0, stage.stageWidth, stage.stageHeight);
			visibleRect.inflate(-margin, -margin);
			if (visibleRect.containsPoint(loc)) return;
			
			// On seuil la position pour la replacer dans la scène
			loc.x = Math.max(visibleRect.left, Math.min(loc.x, visibleRect.right));
			loc.y = Math.max(visibleRect.top, Math.min(loc.y, visibleRect.bottom));
			
			// Et on y va
			loc = parent.globalToLocal(loc);
			TweenLite.to(this, 0.5, {x:loc.x, y:loc.y, ease:Cubic.easeOut});
			
			
			
			
		}
		
	}
	
	
	
}