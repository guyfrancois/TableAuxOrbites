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
	import flash.events.TransformGestureEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
	
	public class C_IndiceClip_super extends C_TactileUiClip
	{
		
		
		/* ---- Paramétrage de l'affichage de l’indice ----  */
		
		/**
		 * Référence du scénario utilisant cet indice 
		 */
		protected var _animalNb:uint;
		/**
		 * Référence du dock associé à cet indice 
		 */
		protected var _indiceNb:uint;
		
		
		private var _isFound:Boolean = false;

		/** Le fond neutre, blanc, lorsque l'indice n'a pas encore été identifié */
		protected var _fond_0:MovieClip;
		/** Le fond colorisé, lorsque l'indice a été trouvé */
		protected var _fond_1:MovieClip;

		/** Le botuon fermé colorisé, une fois l'indice trouvé */
		protected var _btn_Close:MovieClip;
		/** Le botuon fermé neutre */
		protected var _btn_Fermer:MovieClip;
		
		/** icone de l'indice trouvé */
		protected var _ico:MovieClip;
		protected var icoAlphaFound:Number = 1.0;
		protected var icoAlphaNotFound:Number = 1.0;
		
		protected var openOnFound:Boolean = false;
		protected var foundScale:Number;
		
		/** Référence vers le bouton Voter au même niveau que this, qui servira poru les collisions s'il est détecté et visible */
		protected var _btn_Voter:CCollisionDefinitionClip;
		
		protected var _txt_indice:TextFieldWithBackground;
		
		protected var shadows:DropShadowFilter;
		protected var innerGlow:GlowFilter;

		private var _btn_Voter_Physicsbody:b2Body;
		
		
		// On stocke notre état initial
		protected var _initialScale:Number 		= 1.0;
		protected var _initialRotation:Number 	= 0;
		protected var _initialLocX:Number 		= 0;
		protected var _initialLocY:Number 		= 0;
		
		
		public function C_IndiceClip_super() 
		{
			super();
			stop();
			
			_initialScale 		= this.scaleX;
			_initialRotation 	= this.rotation;
			_initialLocX		= this.x;
			_initialLocY		= this.y;
			
			proxyShapeType = PhysicsController.PROXY_SHAPE_CIRCLE;
			
			maxScale  	= params.getNumber('document_max_scale', 2);
			minScale 	= params.getNumber('document_min_scale', 0.5);
			openedScale = params.getNumber('document_opened_scale', 1.0);
			closedScale = params.getNumber('document_closed_scale', 0.5);
			foundScale  = params.getNumber('document_found_scale', 0.5);
			
			maxScaleX = maxScaleY = maxScale;
			minScaleX = minScaleY = minScale;
			
			if (stage) onAddedToStage_C_IndiceClip_super(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage_C_IndiceClip_super, false,10,true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_C_IndiceClip_super, false,0,true);
			
			 
		}
		
		
		override protected function init_C_TactileUiClip():void
		{
			
			super.init_C_TactileUiClip()
			if (physics) {
				physics.getUnrotatedRect = _getUnrotatedRect;
				_updateBtnVoterPhysics();
				
				visualDecorator.showCompleteCallback = showCompleteCallback;
				visualDecorator.hideCompleteCallback = hideCompleteCallback;
					
				
			}
		}
		
		protected function showCompleteCallback():void
		{
			_updateBtnVoterPhysics();
		}
		
		protected function hideCompleteCallback():void
		{
			_updateBtnVoterPhysics();
		}
		
		
		protected function onVoteBtnUpdated(event:GameLogicEvent):void
		{
			new DelayedCall(_updateBtnVoterPhysics, 500);
			//_updateBtnVoterPhysics();
		}
		
		
		
		protected function _updateBtnVoterPhysics(e:Event=null):void
		{
			if (_btn_Voter != null ) 
			{
				if (_btn_Voter.isActive)
				{
					if (_btn_Voter_Physicsbody == null)
					{
						_btn_Voter_Physicsbody = physics.addObstacle(_btn_Voter);
					}
				} else {
					if (_btn_Voter_Physicsbody != null)
					{
						physics.removeObstacle(_btn_Voter_Physicsbody);
						_btn_Voter_Physicsbody = null;
					}
				}
				
			}
			
			// on force la mise à jour
			physics.isRunning = true;
			
			
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
			// isFound = !isFound;
		}
		
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			super.handleTouchBegin(event);
			
			this.depth = getTimer();
			// On notifie les autres éléments de mon panel que j'acquiert le focus
			//MyTrace.put(" > sort update request " + getQualifiedClassName(this) + ' '+ this.depth);
			
			/*
			NavigationEvent.dispatch(NavigationEvent.FOCUS_INDICE_LAYER, 
				{
					depth : this.depth,
					target: this
				});
			*/
			
			//MyTrace.put('update depth ');
			
			
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
			if (_ico) _keepIcoTransformAbsolute();
			
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
			// On met à jour notre ombre en fonction de l'échelle
			
			var strengthA:Number 	= params.getNumber('document_shadow_strength_facA', 1);
			var strengthB:Number 	= params.getNumber('document_shadow_strength_facB', 1);
			var blurA:Number 		= params.getNumber('document_shadow_blur_facA', 1);
			var blurB:Number 		= params.getNumber('document_shadow_blur_facB', 1);
			shadows.strength		= strengthB	 * (strengthA + scaleX);
			shadows.blurX   		= blurB		 * (blurA 	  + scaleX);
			shadows.blurY  			= shadows.blurX;
			
			this.filters = (isFound) ? [shadows] : [innerGlow, shadows];
			
			if (_ico) _keepIcoTransformAbsolute();
			
			onAskRefresh(null);
		}
		
		
		internal var _icoTransformMatrix:Matrix;
		/**
		 * On maintient la position de l'icone 
		 * 
		 */
		protected function _keepIcoTransformAbsolute():void
		{
			/*
			if (_icoTransformMatrix == null) {
				var mat:Matrix = DisplayObjectUtil.getConcatenatedMatrix(_ico);//_ico.transform.concatenatedMatrix;
				_icoTransformMatrix = mat;
				return;
			}
			var t_x:Number = _ico.x;
			var t_y:Number = _ico.y;
			var t_rotation:Number = _ico.rotation;
			DisplayObjectUtil.setConcatenatedMatrix(_ico, _icoTransformMatrix.clone());
			_ico.rotation = t_rotation;
			_ico.x = t_x;
			_ico.y = t_y;
			*/
		}
	 
		
	
		
		protected function onScaleTweeningComplete():void
		{
			onAskRefresh(null);
		}
		
		
		protected function onRemovedFromStage_C_IndiceClip_super(event:Event):void
		{
			var logic:EventChannel = GameLogicEvent.channel;
			
			/*
			logic.removeEventListener(GameLogicEvent.INDICES_HIDE, onHideRequest);
			logic.removeEventListener(GameLogicEvent.INDICES_SHOW, onShowRequest);
			logic.removeEventListener(GameLogicEvent.COLLECT_INDICES_UNDER_LOC, onCollectNotification);
			logic.removeEventListener(GameLogicEvent.VOTE_HIDE_BUTTON_START, onVoteBtnUpdated);
			logic.removeEventListener(GameLogicEvent.VOTE_SHOW_BUTTON_START, onVoteBtnUpdated);
			
			var navig:EventChannel = NavigationEvent.channel;
			navig.removeEventListener(NavigationEvent.FOCUS_INDICE_LAYER, onFocusNotification);
			*/
			
		}
		
		protected function onAddedToStage_C_IndiceClip_super(event:Event):void
		{
			 init_C_IndiceClip_super();
			 
			 /*
			 var logic:EventChannel = GameLogicEvent.channel;
			 logic.addEventListener(GameLogicEvent.INDICES_HIDE, onHideRequest);
			 logic.addEventListener(GameLogicEvent.INDICES_SHOW, onShowRequest);
			 logic.addEventListener(GameLogicEvent.COLLECT_INDICES_UNDER_LOC, onCollectNotification);
			 
			 
			 logic.addEventListener(GameLogicEvent.VOTE_HIDE_BUTTON_START, onVoteBtnUpdated);
			 logic.addEventListener(GameLogicEvent.VOTE_SHOW_BUTTON_START, onVoteBtnUpdated);
			
			 
			 var navig:EventChannel = NavigationEvent.channel;
			 navig.addEventListener(NavigationEvent.FOCUS_INDICE_LAYER, onFocusNotification);
			 */
			 
			 // Ajout de l'ombre portée pour donner de la profondeur. On la gère directement en AS pour plus facilement la faire évoluer ensuite
			 shadows   = new DropShadowFilter(0, 0, 0x000000, 1, 49,49, 1, 1);
			 innerGlow = new GlowFilter(0xffffff, 1, 69, 69, 0.8, 1, true);
			 
			 this.filters = [innerGlow, shadows];
			 
			// hide(true);
			 show(); 
		}
		
		protected function onCollectNotification(event:GameLogicEvent):void
		{
			//	{arCollector:arTest, testX:testX, testY:testY}
			var nfo:Object = event.data;
			if (!visible) return;
			if (alpha < 0.2) return;
			var testX:Number = nfo.testX;
			var testY:Number = nfo.testY;
			if (hitTestPoint(testX, testY, true)) 
			{
				var ar:Array = nfo.arCollector as Array;
				ar.push(this);
			}
		}
		
		
		protected function onFocusNotification(event:NavigationEvent):void
		{
			var nfo:Object = event.data;
			
		}
		
		protected function onShowRequest(event:DataBringerEvent):void
		{
			if (event.data != _animalNb) return;
			isFound = false;
			// On s'ajoute une mini temporisation pour ne pas apparaitre trop brutalement
			
			show(); 
		}
		
		protected function onHideRequest(event:DataBringerEvent):void
		{
			hide();
		}
		
		protected function init_C_IndiceClip_super():void
		{
			
			if (physics == true)
			{
				rotateEnabled = false;
			} else {
				rotateEnabled = true;
			}
			zoomEnabled   = true;
			// On prépare les éléments 
			_fond_0 = getChildByName('fond_0') as MovieClip;
			_fond_1 = getChildByName('fond_1') as MovieClip;
			_btn_Close  = getChildByName('btnClose') as MovieClip;
			_btn_Fermer = getChildByName('btnFermer') as MovieClip;
			_txt_indice = getChildByName('txt_indice') as TextFieldWithBackground;
			_ico = getChildByName('ico') as MovieClip;
			
			if ((_indiceNb / 4) > 1) 
			{
				// On est un indice générique
				icoAlphaFound 	 = params.getNumber('document_icon_indice_alpha_found', icoAlphaFound);
				icoAlphaNotFound = params.getNumber('document_icon_indice_alpha_notfound', icoAlphaNotFound);
			} else {
				// On est un média
				icoAlphaFound 	 = params.getNumber('document_icon_media_alpha_found', icoAlphaFound);
				icoAlphaNotFound = params.getNumber('document_icon_media_alpha_notfound', icoAlphaNotFound);
			}
			
			openOnFound = params.getBoolean('document_open_on_found', openOnFound);
			
			_btn_Voter  = parent.getChildByName('btn_voter') as CCollisionDefinitionClip;
			
			isFound = false;
			
			_txt_indice.mouseEnabled  = false;
			_txt_indice.mouseChildren = false;
			_txt_indice.setMarginsCss(params.getString('document_text_panel_margins', "10 10 20 10"));
			
		}
		
		public function get indiceNb():int { return _indiceNb; }
		
		public function get relativeDockNb():int
		{
			//var dockNb:int = Math.floor((_indiceNb-1)/4) +1 + _indiceNb % 4;
			var dockNb:int = _indiceNb % 4;
			if (dockNb < 1) dockNb = 4;
			
			return dockNb;
		}
		
			
		public function get isFound():Boolean { return _isFound; }
		public function set isFound(value:Boolean):void
		{
			_isFound = value;
			
			var alpha0:Number = _isFound ? 0: 1;
			var alpha1:Number = _isFound ? 1: 0;
			var alphaIco:Number = _isFound ? icoAlphaFound : icoAlphaNotFound;
			var duration:Number = 0.7;
			if (_fond_1) 
			{
				TweenLite.to(_fond_1, duration, {alpha:alpha1, ease:Cubic.easeInOut});
				if (_fond_0 != null) 
				{
					TweenLite.to(_fond_0, duration, {alpha:alpha0, ease:Cubic.easeInOut});
				}
			}
			if (_btn_Close) 
			{
				TweenLite.to(_btn_Fermer, duration, {alpha:alpha0, ease:Cubic.easeInOut});
				TweenLite.to(_btn_Close, duration, {alpha:alpha1, ease:Cubic.easeInOut});
			}
			
			if (_txt_indice != null) {
				_txt_indice.visible = (_txt_indice.alpha > 0 || alpha1 > 0);
				TweenLite.to(_txt_indice, duration, {alpha:alpha1, ease:Cubic.easeInOut, onComplete:_isFoundIndiceUpdateComplete});
			}
			if (_ico != null) {
				_ico.visible = (_ico.alpha > 0 || alphaIco > 0);
				TweenLite.to(_ico, duration, {alpha:alphaIco, ease:Cubic.easeInOut});
				var icoFrame:int = _isFound ? 2 : 1;
			 	icoFrame = Math.min(icoFrame, _ico.totalFrames);
				_ico.gotoAndStop(icoFrame);
			}
			
			if (shadows != null) 
			{
				// Lorsque les filitres ont été initialisés, on peut les assigner pour refléter le changement d'indice trouvé/non trouvé
				this.filters = (isFound) ? [shadows] : [innerGlow, shadows];
			}
			
			if (value && openOnFound) {
				openToScale(foundScale);
				
				// Si on s'ouvre alors on passe au premier plan
				this.depth = getTimer();
				// On notifie les autres éléments de mon panel que j'acquiert le focus
				//MyTrace.put(" > sort update request " + getQualifiedClassName(this) + ' '+ this.depth);
				
				/*
				NavigationEvent.dispatch(NavigationEvent.FOCUS_INDICE_LAYER, 
					{
						depth : this.depth,
						target: this
					});
				*/
			}
			
			/*
			// Notification
			if (_isFound)
				GameLogicEvent.dispatch(GameLogicEvent.INDICE_FOUND_NOTIFICATION, {indiceClip:this});
			*/
		}
		
		
		protected function _isFoundIndiceUpdateComplete():void
		{
			_txt_indice.visible = (_txt_indice.alpha > 0);
		}
		
		
		override public function show(immediate:Boolean=false):void
		{
			// Avant d'afficher on met à joru les textes si besoin
			// L'id du texte sera
			// <text id="${animalName}_media_indice_${dockNb}" language="FR"><![CDATA[Le texte d'indice qui apparait uen fois l'association objet/media réussie]]></text>
			/*
			var ctrl:GameController = GameController.instance;
			if (!ctrl.indiceEnabled(_animalNb)) return;
			
			var txtId:String  	= "${animalName}_media_indice_${dockNb}";
			var tokens:Object 	= {animalName:GameController.currentCasName, dockNb:_indiceNb};
			txtId = TokenUtil.replaceTokens(txtId, tokens);
			var str:String 		= DataCollection.instance.getText(txtId, GameController.instance.userLanguage);
			_txt_indice.text 	= str;
			
			if (immediate == true)
			{
				super.show(immediate);
			} else {
				var delay:Number = 100 + Math.floor(1500*Math.random());
				new DelayedCall(super.show, delay);
			}
			*/
			super.show(true);
			// On place cet item a sa position initiale
			x = _initialLocX;
			y = _initialLocY;
			scaleX = scaleY = _initialScale;
			rotation = _initialRotation;
			if (physics) {
				physics.kill();
				_btn_Voter_Physicsbody = null;
				
				physics = new PhysicsController(this, this.parent, this.proxyShapeType);
				physics.initSimulation();
				
			
				
			}
			if (physics) {
				physics.showDebug();
				physics.isRunning = true;
			}
			
			// Apres avoir reset les positions/rotations/scale, on s'assure que l'icone également est dans on état initial
			_keepIcoTransformAbsolute();
			
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