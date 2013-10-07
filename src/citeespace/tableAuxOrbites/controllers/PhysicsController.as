package citeespace.tableAuxOrbites.controllers
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	
	import citeespace.tableAuxOrbites.events.DebugEvent;
	import citeespace.tableAuxOrbites.flashs.clips.CCollisionDefinitionClip;
	import citeespace.tableAuxOrbites.flashs.clips.CDebugShape;
	import citeespace.tableAuxOrbites.flashs.clips.CTactileDebug;
	import citeespace.tableAuxOrbites.flashs.clips.C_TactileUiClip;
	import citeespace.tableAuxOrbites.flashs.clips.ICollisionDefinition;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.GeomUtil;
	import org.tuio.TuioTouchEvent;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.clips.DisplayObjectUtil;
	import utils.events.DataBringerEvent;
	import utils.geom.GeometryUtil;
	import utils.params.ParamsHub;
	
	/**
	 * Classe d'implémentation de Box2D pour déplacer les éléments avec frictionet inertie
	 *
	 * @author sps
	 * @version 1.0.0 [5 déc. 2011][sps] creation
	 * @version 1.1.0 [6 déc. 2011][sps] Ajout de la gestion des PhysicGroups pour distringuer des univers physiques parallèles
	 *
	 * citeespace.planisphere.controllers.PhysicsController
	 */
	public class PhysicsController extends EventDispatcher
	{
		// Propriétés de la simulation
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1/30;
		public var pixels_in_a_meter = 30;
		public var gravityX:Number = 0.0;
		public var gravityY:Number = 0.0;
		public var gravity:b2Vec2;
		
		public var proxyShapeType:uint = PROXY_SHAPE_SQUARE; 
		static public const PROXY_SHAPE_SQUARE:uint = 0;
		static public const PROXY_SHAPE_CIRCLE:uint = 1;
		
		//public var targetFrameRate:int = 60;
		
		public var m_world:b2World;
		public var mousePVec:b2Vec2 = new b2Vec2();
		
		public var worldAABB:b2AABB = new b2AABB();
		
		public var real_x:Number;
		public var real_y:Number;
		
		public var mouseJoint:b2MouseJoint;
		public var mouseJoints:Vector.<b2MouseJoint> = new Vector.<b2MouseJoint>();
		public var tuioSessions:Vector.<uint> = new Vector.<uint>();
		
		private var frameUpdateHandler:Function;
		protected var _stage:Stage;
		
		
		protected var marginOutbounds:Number = 10;
		protected var marginDocs:Number = 0;
		 
		private var stageMeterWidth:Number;

		private var stageMeterHeight:Number;
	 
		protected var bodiesToRefresh:Array = [];
		private var targetObject:DisplayObject;
		private var targetObjectParent:DisplayObjectContainer;
		
		private var oldSSID:Array = [];
		
		internal var _isDebug:Boolean = false;
		internal var _showDebug:Boolean = false;
		
		public function PhysicsController(targetObject:DisplayObject, targetObjectParent:DisplayObjectContainer=null, proxyShapeType:uint=0)
		{
			if (targetObject != null)
			{
				this.targetObject = targetObject;
				if (targetObjectParent == null) targetObjectParent = targetObject.parent;
				this.targetObjectParent = targetObjectParent;
				getUnrotatedRect = _getUnrotatedRect;
				
				this.proxyShapeType = proxyShapeType;
				
				DebugEvent.channel.addEventListener(DebugEvent.TOGGLE_DEBUG_PHYSICS, onToggleDebug);
			}
		}
		
		public function kill():void
		{
			if (_stage == null)
				return;
			DebugEvent.channel.removeEventListener(DebugEvent.TOGGLE_DEBUG_PHYSICS, onToggleDebug);
			getUnrotatedRect = null;
			if (_stage.contains(debugSprite)) _stage.removeChild(debugSprite);
			
			_stage.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
			_stage.removeEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp);
			_stage.removeEventListener(TuioTouchEvent.TOUCH_MOVE, onTouchMove);
			_stage.addEventListener(Event.ENTER_FRAME, onUpdate_frame);
			(Event.ENTER_FRAME, onUpdate_frame, false,0,true);
			
			_stage = null;
		}
		
		
		
		protected function onToggleDebug(event:DebugEvent):void
		{
			_isDebug = !_isDebug;
			debugSprite.visible = (_isDebug && _showDebug);
		}
		
		
		/**
		 * Permet de définir une fonction poru surcharger _getUnrotatedRect(s:DisplayObject):Rectangle poru connaitre les dimensions à utiliser pour le rigibBody (permet d'ignorer certains éléments, les filtres, ...)  
		 */
		public var getUnrotatedRect:Function;
		
		
		
		private var _isRunning:Boolean = false;

		private var debugSprite:Sprite;
		private var myGroup:PhysicsGroups;
		public function get isRunning():Boolean
		{
			return _isRunning;
		}

		public function set isRunning(value:Boolean):void
		{
			_isRunning = value;
			if (debugSprite) debugSprite.visible = (value && _isDebug && _showDebug);
			
		}
		
		public function showDebug():void
		{
			_showDebug = true;
		}
		
		public function hideDebug():void
		{
			_showDebug = false;
		}
		

		
		protected function onTargetAddedToStage(event:Event):void
		{
			initSimulation();
		}
		
		
		/**
		 * Initialisation de la simulation physique 
		 * Peut être appellé après avoir défini les paramètres de la simulation
		 */
		public function initSimulation(stage:Stage=null):void
		{
			if (stage) {
				_stage = stage;
			} else {
				if (targetObject.stage == null)
				{
					targetObject.addEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage, false,0,true);
					return;
				} else {
					_stage = targetObject.stage;
				}
			}
			
			var params:ParamsHub = ParamsHub.instance;
			
			marginDocs 		= params.getNumber('documents_physics_body_margin', 0);
			marginOutbounds = params.getNumber('documents_screen_margin', 0);
			
			gravity = new b2Vec2(gravityX, gravityY);
			
			// On se prépare à recevoir les ticks poru mettre à jour
			//	var updateTimer:Timer = new Timer(Math.round(1000/targetFrameRate), int.MAX_VALUE);
			//	updateTimer.addEventListener(TimerEvent.TIMER, onTimerUpdate_tick, false,0,true);
			//  updateTimer.start();
			_stage.addEventListener(Event.ENTER_FRAME, onUpdate_frame, false,0,true);
			
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);
			
			m_world = new b2World(worldAABB, gravity, true);
			
			
			/*
			if (params.getBoolean('enableMouse', false)) 
			{
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
				_stage.addEventListener(MouseEvent.MOUSE_UP, on_mouse_up);
				frameUpdateHandler = updateJoints;
			} 
			*/
			if (params.getBoolean('enableTuio', false)) {
				_stage.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown, false,0,true);
				_stage.addEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp, false,0,true);
				_stage.addEventListener(TuioTouchEvent.TOUCH_MOVE, onTouchMove, false,0,true);
			}
			myGroup = PhysicsGroups.get('defaultGroup');
			
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxDef:b2PolygonDef;
			
			// On calcule les caractéristiques de la scène en mètre pour faire la conversion avec la smiulation graphique
			stageMeterWidth  = _stage.stageWidth  / pixels_in_a_meter;
			stageMeterHeight = _stage.stageHeight / pixels_in_a_meter;
			
			
				
			// On prépare les côtés 
			var ground_width:Number  = 0.5*stageMeterWidth; 
			var ground_height:Number = 0.5;
			var side_width:Number 	 = 0.5;
			var side_height:Number 	 = 0.5*stageMeterHeight;
			var offsetInMeter:Number = 2* marginOutbounds / pixels_in_a_meter;
			
			// Coté sud
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0.3;
			boxDef.density = 0;
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(0.5*stageMeterWidth, stageMeterHeight - offsetInMeter);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			//bodyDef.userData = new CDebugShape();
			//bodyDef.userData.width 	= ground_width * 2 * pixels_in_a_meter;
			//bodyDef.userData.height = ground_height * 2 * pixels_in_a_meter;
			//stage.addChild(bodyDef.userData);
				
			// Coté nord
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0.3;
			boxDef.density = 0;
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(0.5*stageMeterWidth, offsetInMeter);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			
			// Coté ouest
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(side_width, side_height);
			boxDef.friction = 0.3;
			boxDef.density = 0;
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(offsetInMeter, 0.5*stageMeterHeight);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			
			// Coté est
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(side_width, side_height);
			boxDef.friction = 0.3;
			boxDef.density = 0;
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(stageMeterWidth-offsetInMeter, 0.5*stageMeterHeight);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			
			createRect(targetObject);
			for (var i:int = 1; i <=5; i++) {
				//createRect();
				/*
				bodyDef = new b2BodyDef();
				bodyDef.position.x = 0.5*stageMeterWidth  +Math.random() * 15 + 1;
				bodyDef.position.y = 0.5*stageMeterHeight +Math.random() * 10;
				bodyDef.linearDamping = params.getNumber('documents_physics_linear_damping', 1);
				bodyDef.angularDamping = params.getNumber('documents_physics_angular_damping', 1);
				var crate_width:Number = 1.5;
				var crate_height:Number = 1.5;
				boxDef = new b2PolygonDef();
				boxDef.SetAsBox(crate_width, crate_height);
				boxDef.density 		= params.getNumber('documents_physics_density', 8.0);
				boxDef.friction 	= params.getNumber('documents_physics_friction', 0.8);
				boxDef.restitution 	= params.getNumber('documents_physics_restitution',0.2);
				bodyDef.userData 	= new CDebugShape();
				bodyDef.userData.width 	= crate_width * 2 * pixels_in_a_meter;
				bodyDef.userData.height = crate_height * 2* pixels_in_a_meter;
				body = m_world.CreateBody(bodyDef);
				body.CreateShape(boxDef);
				body.SetMassFromShapes();
				stage.addChild(bodyDef.userData);
				*/
			}
			
			
			//debugSprite is some sprite that we want to draw our debug shapes into.
			
			debugSprite = new Sprite();
			_stage.addChild(debugSprite);
			debugSprite.mouseEnabled = false;
			// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			
			dbgDraw.m_sprite = debugSprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.3;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit | b2DebugDraw.e_coreShapeBit;
			m_world.SetDebugDraw(dbgDraw);
			debugSprite.visible = _isDebug = _showDebug = params.getBoolean('dbg_documents_physics', false); 
			
			
		}
		
		protected var _excludedInteractors:Array = [];

		public function get excludedInteractors():Array
		{
			return _excludedInteractors;
		}

		public function set excludedInteractors(value:Array):void
		{
			_excludedInteractors = value;
		}

		public function excludeDisplayObjectFromInteractions(obj:DisplayObject):void
		{
			_excludedInteractors.push(obj);
		}
		
		protected function onTouchDown(event:TuioTouchEvent):void
		{
			if (!isRunning) return;
			var ssID:uint = event.tuioContainer.sessionID;
			var triggerID:String = 'tuio_'+ssID;
			// MyTrace.put('  1 test tuio '+ssID +' '+myGroup.isTriggerInUse(triggerID));
			
			//if (myGroup.isTriggerInUse(triggerID)) return;
			
			
			var body:b2Body = GetBodyUnderLoc(event.stageX, event.stageY);
			if (body) 
			{
				var s:DisplayObject = body.GetUserData() as DisplayObject;
				if (!s.visible) {
					return;
				}

				// On vérifie que ce body ne recouvr epa sun objet exclus
				for each (var dispObj:DisplayObject in excludedInteractors) 
				{
					if (dispObj.hitTestPoint(event.stageX, event.stageY, true)) {
						return;
					}
				}
				
				
				var nfos:Object = myGroup.getTriggerData(triggerID);
				/*
				var depths:Array = nfos.depths as Array;
				depths.push((s as C_PlanisphereTactileUiClip).depth);
				nfos.depths = depths;
				*/
				var sprites:Array = nfos.sprites as Array;
				sprites.push(s);
				nfos.sprites = sprites;
				myGroup.setTriggerData(triggerID, nfos);
				//MyTrace.put('  2 test tuio '+ssID +' ' + (s as C_PlanisphereTactileUiClip).depth);
				
				new DelayedCall(_checkTouchDown, 2, {ssID:ssID, triggerID:triggerID, body:body, x:event.stageX, y:event.stageY});
			}
		}
		
		
		protected function _checkTouchDown(args:Object):void
		{
			if (!_stage) return;
			
			var ssID:uint 		 = args.ssID;
			if (oldSSID.indexOf(ssID) > -1) return; // double tap rapide, cette session tuio est déjà terminée
			var triggerID:String = args.triggerID;
			var body:b2Body 	 = args.body;
			var xx:Number 		 = args.x;
			var yy:Number 		 = args.y;
			
			var nfos:Object = myGroup.getTriggerData(triggerID);
			
			var s:C_TactileUiClip = body.GetUserData() as C_TactileUiClip;
			var sprites:Array = nfos.sprites as Array;
			if (sprites == null) return; // 
			var testSprite:C_TactileUiClip;
			for (var i:int = sprites.length-1; i >=0; i--) 
			{
				testSprite = sprites[i] as C_TactileUiClip;
				if (testSprite != s) {
					if (testSprite.depth > s.depth) {
						return;
					}
				}
				
			}
			// MyTrace.put('start tuio '+ssID +' ' + s.depth);
			
			//MyTrace.put('check depths '+ssID +' ' + depths +' ('+s.depth+')');
			//if (ArrayUtil.getHighestValue(depths) != s.depth) 
				//return;
			
				// Je ne suis pas au premier plan dans mon physicGroup, je laisse la main
			
			
			
			var mouse_joint:b2MouseJointDef = new b2MouseJointDef();
			mouse_joint.body1 = m_world.GetGroundBody();
			mouse_joint.body2 = body;
			
			mouse_joint.target.Set(xx/pixels_in_a_meter, yy/pixels_in_a_meter);
			mouse_joint.maxForce = 80000;
			mouse_joint.timeStep = m_timeStep;
			mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;
			
			mouseJoints.push(mouseJoint);
			tuioSessions.push(ssID);
			
			myGroup.beginTrigger('tuio_'+ssID);
			
		}
		
		
		protected function onTouchUp(event:TuioTouchEvent):void
		{
			if (!_stage) return;
			var ssID:uint = event.tuioContainer.sessionID;
			oldSSID.push(ssID);
			var ind:int = tuioSessions.indexOf(ssID);
			if (ind < 0) return;
			var t_mouseJoint:b2MouseJoint = mouseJoints[ind] as b2MouseJoint; 
			
			if (t_mouseJoint) 
			{
				mouseJoints.splice(ind, 1);
				tuioSessions.splice(ind, 1);
				m_world.DestroyJoint(t_mouseJoint);
				myGroup.endTrigger('tuio_'+ssID);
			} else {
				// Session en cours mais pas de lien trouvé?!
				MyTrace.put('touch up '+ ssID);
			}
		}
		
		
		protected function onTouchMove(event:TuioTouchEvent):void
		{
			if (!_stage) return;
			
			var ssID:uint = event.tuioContainer.sessionID;
			var ind:int = tuioSessions.indexOf(ssID);
			if (ind < 0) return;
			
			var t_mouseJoint:b2MouseJoint = mouseJoints[ind] as b2MouseJoint; 
			
			if (t_mouseJoint) 
			{
				var mouseXWorldPhys = event.stageX / pixels_in_a_meter;
				var mouseYWorldPhys = event.stageY / pixels_in_a_meter;
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				t_mouseJoint.SetTarget(p2);
			}
		}
		
		protected var _lastFocusBody:b2Body;
		protected function createRect(userData:DisplayObject=null):b2BodyDef
		{
			var posX:Number, posY:Number;
			var body_width:Number 	= 1.5;
			var body_height:Number 	= 1.5;
			
			if (userData == null) 
			{
				posX = 0.5*stageMeterWidth  +Math.random() * 15 + 1;
				posY = 0.5*stageMeterHeight +Math.random() * 10;
				userData = new CDebugShape();
				
				userData.width 	= body_width * 2 * pixels_in_a_meter;
				userData.height = body_height * 2* pixels_in_a_meter;
				body_width  = body_width  + marginDocs/pixels_in_a_meter;
				body_height = body_height + marginDocs/pixels_in_a_meter;
				
			} else {
				
				var ww:Number = DisplayObjectUtil.getVisibleWidth(userData);
				var hh:Number = DisplayObjectUtil.getVisibleHeight(userData);
				//var stageLoc:Point = userData.localToGlobal(new Point(userData.x, userData.y));
				body_width  = 0.5*(ww  + marginDocs) / pixels_in_a_meter; 
				body_height = 0.5*(hh + marginDocs) / pixels_in_a_meter; 
				posX = userData.x / pixels_in_a_meter; 
				posY = userData.y / pixels_in_a_meter; 
				
			}
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.x = posX;
			bodyDef.position.y = posY;
			bodyDef.angle = GeometryUtil.degreeToRadian(userData.rotation); // userData.rotation;
			bodyDef.linearDamping  	= params.getNumber('documents_physics_linear_damping',  1);
			bodyDef.angularDamping 	= params.getNumber('documents_physics_angular_damping', 1);
			
			var boxDef:b2ShapeDef = getShapeDef(userData);// new b2PolygonDef();
			 
			bodyDef.userData 		= userData;
			var body:b2Body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			_lastFocusBody = body;
			//_stage.addChild(bodyDef.userData);
			this.targetObjectParent.addChild(bodyDef.userData);
			return bodyDef;
		}
		
		protected function _getUnrotatedRect(s:DisplayObject):Rectangle
		{
			var t_rot:Number = s.rotation;
			s.rotation = 0;
			var out:Rectangle = new Rectangle(s.x, s.y, s.width, s.height);
			s.rotation = t_rot;
			return out;
		}
		
		protected function getShapeDef(userData:DisplayObject=null):b2ShapeDef
		{
			var body_width:Number 	= 1.5;
			var body_height:Number 	= 1.5;
			if (userData != null) 
			{
				var userDataRect:Rectangle = getUnrotatedRect(userData) as Rectangle;
				body_width  = 0.5*(userDataRect.width  + marginDocs) / pixels_in_a_meter; 
				body_height = 0.5*(userDataRect.height + marginDocs) / pixels_in_a_meter; 
			}
			var boxDef:b2ShapeDef;
			switch(proxyShapeType)
			{
				case PROXY_SHAPE_SQUARE:
					boxDef = new b2PolygonDef();
					(boxDef as b2PolygonDef).SetAsBox(body_width, body_height);
					break;
				
				case PROXY_SHAPE_CIRCLE:
					boxDef = new b2CircleDef();
					(boxDef as b2CircleDef).radius = 0.5 * (body_width + body_height);// On prend la moyenne de largueur/hauteur
					break;
				
			}
			 
			boxDef.density 			= params.getNumber('documents_physics_density', 8.0);
			boxDef.friction 		= params.getNumber('documents_physics_friction', 0.8);
			boxDef.restitution 		= params.getNumber('documents_physics_restitution',0.2);
			return boxDef;
		}
		
		protected function onUpdate_frame(event:Event):void
		{
			if (isRunning) updateSimulation();
		}
		
		protected function updateSimulation():void
		{
			if (bodiesToRefresh.length > 0) {
				for (var i:int = bodiesToRefresh.length; i > 0; i--) 
				{
					var body:b2Body = bodiesToRefresh.pop() as b2Body;
					var s:DisplayObject = body.GetUserData() as DisplayObject;
					var t:* = body.GetShapeList();
					body.DestroyShape(t as b2Shape);
					var tDef:b2ShapeDef = getShapeDef(s);
					body.CreateShape(tDef);
				}
			}
			
			m_world.Step(m_timeStep, m_iterations);
			
			if (frameUpdateHandler != null) frameUpdateHandler.call();
			
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
				if (bb.m_userData is DisplayObject) {
					bb.m_userData.x = bb.GetPosition().x * pixels_in_a_meter;
					bb.m_userData.y = bb.GetPosition().y * pixels_in_a_meter;
					bb.m_userData.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
		}
		
		
		protected function updateJoints():void
		{
			if (mouseJoints.length > 0)
			{
				for each (var mouseJoint:b2MouseJoint in mouseJoints) 
				{
					var mouseXWorldPhys = _stage.mouseX/pixels_in_a_meter;
					var mouseYWorldPhys = _stage.mouseY/pixels_in_a_meter;
					var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
					mouseJoint.SetTarget(p2);
				}
				
				if (mouseJoint) {
					
				}
			}
		}
		
		
		/**
		 * Demande au moteur physique de vérifier et réappliquer l'échelle du 
		 * DisplayObject passé en argument pour la répercuter sur le rigibBody
		 * auquel cet élément est associé
		 *  
		 * @param userData
		 * 
		 */
		public function refreshScale(userData:DisplayObject):void
		{
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
				if (bb.m_userData is DisplayObject && bb.m_userData == userData) 
				{
					bodiesToRefresh.push(bb);
				}
			}	
		}
		
		
		
		protected function on_mouse_down(evt:MouseEvent):void 
		{	
			if (!isRunning) return;
			
			if (myGroup.isTriggerInUse('mouse')) return;
			
			var body:b2Body = GetBodyUnderLoc(_stage.mouseX, _stage.mouseY);
			if (body) {
				
				// Si shift on agrandi l'élément
					var s:DisplayObject = body.GetUserData() as DisplayObject;
				if (evt.shiftKey) {
					//s.width  = s.width+10;
					//s.height = s.height+10;
					s.scaleX = s.scaleX+0.2;
					s.scaleY = s.scaleY+0.2;
					bodiesToRefresh.push(body);
					
					//body.SetMassFromShapes();
				} else if (evt.ctrlKey) {
					s.scaleX = s.scaleX-0.2;
					s.scaleY = s.scaleY-0.2;
					bodiesToRefresh.push(body);
				}
				
				
				var mouse_joint:b2MouseJointDef = new b2MouseJointDef();
				mouse_joint.body1 = m_world.GetGroundBody();
				mouse_joint.body2 = body;
				
				mouse_joint.target.Set(_stage.mouseX/pixels_in_a_meter, _stage.mouseY/pixels_in_a_meter);
				mouse_joint.maxForce = 80000;
				mouse_joint.timeStep = m_timeStep;
				mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;
			
				mouseJoints.push(mouseJoint);
				
				myGroup.beginTrigger('mouse');
			}
		}
		
		
		protected function on_mouse_up(evt:MouseEvent):void 
		{
			if (mouseJoint) {
				m_world.DestroyJoint(mouseJoint);
				mouseJoints.splice(mouseJoints.indexOf(mouseJoint), 1);
				mouseJoint = null;
				myGroup.endTrigger('mouse');
			}
		}
		
		public function GetBodyUnderLoc(locX:Number, locY:Number, includeStatic:Boolean=false):b2Body 
		{
			real_x = locX / pixels_in_a_meter;
			real_y = locY / pixels_in_a_meter;
			mousePVec.Set(real_x, real_y);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(real_x - 0.001, real_y - 0.001);
			aabb.upperBound.Set(real_x + 0.001, real_y + 0.001);
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i) {
				if (shapes[i].m_body.IsStatic() == false || includeStatic) {
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.m_body.GetXForm(), mousePVec);
					if (inside) {
						body = tShape.m_body;
						break;
					}
				}
			}
			return body;
		}
		
		
		protected function onTimerUpdate_tick(event:TimerEvent):void
		{
			updateSimulation();
		}
		
		
		protected function get params():ParamsHub
		{
			return ParamsHub.instance;
		}
		
		public function removeObstacle(obstacleBody:b2Body):void
		{
			m_world.DestroyBody(obstacleBody);
		}
		
		
		/**
		 * 
		 * @param movieClip Le clip à prendre en référence poru la zone de collision
		 * @param proxyShape Le type de forme à lui associer (PROXY_SHAPE_CIRCLE par défaut)
		 * 
		 */
		public function addObstacle(collDef:CCollisionDefinitionClip):b2Body
		{
			//proxyShape:uint=PROXY_SHAPE_CIRCLE
			
			var clipRect:Rectangle = collDef.getUnrotatedRect();// 	= getUnrotatedRect(movieClip) as Rectangle;
			
			
			/*
			var t_rot:Number = collDef.rotation;
			collDef.rotation = 0;
			
			clipRect = new Rectangle(collDef.x, collDef.y, collDef.width, collDef.height);
			collDef.rotation = t_rot;
			*/
			
			// MyTrace.put("rect voter :" + clipRect);
			var ww:Number 			= (0.5*(clipRect.width)  - collDef.threshold) / pixels_in_a_meter; 
			var hh:Number 			= (0.5*(clipRect.height) - collDef.threshold) / pixels_in_a_meter; 
			var xyCenter:Point 		= GeometryUtil.rectangleCenter(clipRect);
			
			var boxDef:b2ShapeDef;
			switch(collDef.proxyShape)
			{
				case PROXY_SHAPE_SQUARE:
					boxDef = new b2PolygonDef();
					(boxDef as b2PolygonDef).SetAsBox(ww, hh);
					break;
				
				case PROXY_SHAPE_CIRCLE:
					boxDef = new b2CircleDef();
					(boxDef as b2CircleDef).radius = 0.5 * (ww + hh); // On prend la moyenne de largueur/hauteur
					break;
			}
		 	
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(xyCenter.x / pixels_in_a_meter, xyCenter.y / pixels_in_a_meter);
			//bodyDef.userData = collDef;
			
			var body:b2Body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
 
			// On force les corps focuser à se mettre à jour
			var smallImpulse:b2Vec2 = new b2Vec2(0.5,0.5);
			_lastFocusBody.ApplyImpulse(smallImpulse, new b2Vec2());
			
			return body;
		}
		
		
		public function applyImpulseOnTargetObject(xStageApplyPos:Number=NaN, yStageApplyPos:Number=NaN):void
		{
			// xx/pixels_in_a_meter, yy/pixels_in_a_meter
			var applyVec:b2Vec2;
			var smallImpulse:b2Vec2;
			if (isNaN(yStageApplyPos)) {
				applyVec = _lastFocusBody.GetWorldCenter();
				var dX:Number = b2Math.b2RandomRange(-20, 20);
				var dY:Number = b2Math.b2RandomRange(-20, 20);
				smallImpulse = new b2Vec2(dX, dY);
			} else {
				applyVec = new b2Vec2(xStageApplyPos/pixels_in_a_meter , yStageApplyPos/pixels_in_a_meter  );
				smallImpulse = _lastFocusBody.GetWorldCenter().Copy();
			}
			
			// L'impulse se fait dans la direction point d'appui-> centre poru pousser l'objet
			smallImpulse.Subtract(applyVec);
			smallImpulse.Normalize();
			smallImpulse.Multiply(12);
			
			
			_lastFocusBody.WakeUp();
			_lastFocusBody.SetLinearVelocity(smallImpulse);
			
			
		}
	}
}