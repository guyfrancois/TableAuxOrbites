package citeespace.tableAuxOrbites.controllers
{
	import away3d.containers.Bone;
	
	import citeespace.tableAuxOrbites.flashs.clips.CTactileDebug;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	
	import org.tuio.TuioClient;
	import org.tuio.TuioEvent;
	import org.tuio.TuioManager;
	import org.tuio.adapters.MouseTuioAdapter;
	import org.tuio.adapters.NativeTuioAdapter;
	import org.tuio.connectors.TCPConnector;
	import org.tuio.connectors.UDPConnector;
	import org.tuio.debug.TuioDebug;
	import org.tuio.gestures.DragGesture;
	import org.tuio.gestures.GestureManager;
	import org.tuio.gestures.RotateGesture;
	import org.tuio.gestures.TwoFingerMoveGesture;
	import org.tuio.gestures.ZoomGesture;
	
	import pensetete.tuio.TactileClip;
	
	import utils.params.ParamsHub;
	
	/**
	 * Défini en tant qu'héritier de movieClip pour etre ajouté à la displayList 
	 * @author SPS
	 * @version 1.2.0 [25 nov. 2011][sps] adaptation pour le planisphere des animaux (Cite Espace) 
	 */
	public class PtTouchController extends Sprite
	{
		
		protected var paramsHub:ParamsHub;
		public function PtTouchController(paramsHub:ParamsHub=null)
		{
			super();
			
			this.paramsHub = paramsHub;
			
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		
		}
		
		protected var mcTactileTest:TactileClip;
		protected function onAddedToStage(event:Event):void
		{
			// affichage d'un panel de débug
			
		
			if (paramsHub && paramsHub.getBoolean('dbg_tuio_test', false))
			{
				mcTactileTest = new CTactileDebug();
				addChild(mcTactileTest);
				
			}
			initTuioTouch();
			
			/*
			var item:DragRotateScaleSprite;
			for (var c:int = 0; c < 2; c++ ) {
				item = new DragRotateScaleSprite(
					100 + Math.random() * (stage.stageWidth - 200), 
					100 + Math.random() * (stage.stageHeight - 200), 
					100, 
					150);
				stage.addChild(item);
			}
			*/
		}
		
		private function initTuioTouch():void
		{
			var virtualStage:Stage = this.stage;
			var tDbg:TuioDebug;
			var winMouseTouch:MouseTuioAdapter;
			var win7Touch:NativeTuioAdapter;
			
			var udpMode:Boolean=false;
			if (paramsHub) udpMode = paramsHub.getBoolean('udpMode', udpMode);
			var udpPort:Number = 3333;
			if (paramsHub) udpPort = paramsHub.getNumber('tuio_udp_port', udpPort);
			var udpIP:String = "127.0.0.1";
			if (paramsHub) udpIP = paramsHub.getString('tuio_udp_address', udpIP);
			
			
			var tcpPort:Number = 3001;
			if (paramsHub) tcpPort = paramsHub.getNumber('tuio_tcp_port', tcpPort);
			var tcpIP:String = "127.0.0.1";
			if (paramsHub) tcpIP = paramsHub.getString('tuio_tcp_address', tcpIP);
			
			var listenNativeTouch:Boolean = (paramsHub && paramsHub.getBoolean('enableW7Touch', false));
			var emulateNativeTouch:Boolean = !listenNativeTouch;
			var tc:TuioClient;
			if (paramsHub && paramsHub.getBoolean('enableTuio', true)) {
				if (udpMode) {
					tc = new TuioClient(new UDPConnector(udpIP, udpPort));
				} else {
					tc = new TuioClient(new TCPConnector(tcpIP, tcpPort));
				}
				C_DebugConsole.setText('Connecting TUIO src:'+tc.currentSource+' FREQ:'+tc.currentFseq);
			}
			
		
			var tuioManager:TuioManager = TuioManager.init(virtualStage);
			if (tc) tc.addListener(tuioManager);
			tuioManager.dispatchMouseEvents 		= false;
			tuioManager.dispatchNativeTouchEvents 	= false;;//false;//emulateNativeTouch; // 
			
			tuioManager.touchTargetDiscoveryMode = TuioManager.TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			
			
			
			if (paramsHub && paramsHub.getBoolean('showDebugTuio', false))
			{
				tDbg = TuioDebug.init(virtualStage);
				if (tc) tc.addListener(tDbg);
			}
			
			if (listenNativeTouch)
			{
				if (!Multitouch.supportsTouchEvents) 
				{
					throw "Demande d'écoute d'événements touch sur un système non compatible. Vérifiez vos paramètres";
				}
				
				
				win7Touch= new NativeTuioAdapter(virtualStage);
				C_DebugConsole.setText('NativeTuioAdapter ON');
				if (tDbg) {
					win7Touch.addListener(tDbg);
				}
			}
			
			
			
			//if (emulateNativeTouch && paramsHub && paramsHub.getBoolean('enableMouse', true))
			if (paramsHub && paramsHub.getBoolean('enableMouse', true))
			{
				C_DebugConsole.setText('MouseTuioAdapter ON');
				winMouseTouch = new MouseTuioAdapter(virtualStage);
				if (tDbg) {
					winMouseTouch.addListener(tDbg);
				}
			}
			
		
			
			/*
			var tuioManager:TuioManager = TuioManager.init(stage);
			tuioManager.dispatchMouseEvents 		= false;
			tuioManager.dispatchNativeTouchEvents 	= true;
			tuioManager.touchTargetDiscoveryMode = TuioManager.TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			tc.addListener(tuioManager);
			*/
			if (winMouseTouch) 	winMouseTouch.addListener(tuioManager);
			if (win7Touch) 		win7Touch.addListener(tuioManager);
			
			tuioManager.doubleTapTimeout = 20;
			
			/*
			// Ecouteurs de débug pour vérifier qu'on recoit (ou pas) les évenements TUIO
			tuioManager.addEventListener(TuioEvent.ADD, onTuioAdd);
			tuioManager.addEventListener(TuioEvent.UPDATE, onTuioUpdate);
			tuioManager.addEventListener(TuioEvent.REMOVE, onTuioRemove);
			
			tuioManager.addEventListener(TuioEvent.ADD_CURSOR, onTuioAddCursor);
			tuioManager.addEventListener(TuioEvent.UPDATE_CURSOR, onTuioUpdateCursor);
			tuioManager.addEventListener(TuioEvent.REMOVE_CURSOR, onTuioRemoveCursor);
			*/
			
			var gm:GestureManager = GestureManager.init(virtualStage);
			GestureManager.addGesture(new DragGesture());
			GestureManager.addGesture(new RotateGesture(TwoFingerMoveGesture.TRIGGER_MODE_TOUCH));
			GestureManager.addGesture(new ZoomGesture(TwoFingerMoveGesture.TRIGGER_MODE_TOUCH));
			
			gm.touchTargetDiscoveryMode = GestureManager.TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			
			tuioManager.touchTargetDiscoveryMode = TuioManager.TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			
			
			if (mcTactileTest != null) {
				mcTactileTest.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
				mcTactileTest.addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
				// addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
			}
			
		}
		
		
		protected function onPan(event:TransformGestureEvent):void
		{
			//C_DebugConsole.setText(" onPan " + event.rotation);
			
		}
		
		protected function onRotate(event:TransformGestureEvent):void
		{
			//DebugConsole.setText(" onRotate " + event.rotation);
			
			//	var pivot:Vector3D = new Vector3D(event.localX, event.localY, 0);
			//	var rotateV:Vector3D = new Vector3D(0, 0, this.rotationZ + event.rotation);
			// this.transformAround(pivot, null, rotateV);
			
		}
		
		protected function onTuioAddCursor(event:TuioEvent):void
		{
			C_DebugConsole.setText(" AddCursor " + event.tuioContainer.sessionID);
			
		}
		
		protected function onTuioUpdateCursor(event:TuioEvent):void
		{
			C_DebugConsole.setText(" updateCursor " + event.tuioContainer.sessionID);
			
		}
		
		protected function onTuioRemoveCursor(event:TuioEvent):void
		{
			C_DebugConsole.setText(" RemoveCursor " + event.tuioContainer.sessionID);
			
		}
		
		protected function onTuioRemove(event:TuioEvent):void
		{
			C_DebugConsole.setText(" Remove " + event.tuioContainer.sessionID);
		}
		
		protected function onTuioUpdate(event:TuioEvent):void
		{
			C_DebugConsole.setText(" Update " + event.tuioContainer.sessionID);
		}
		
		protected function onTuioAdd(event:TuioEvent):void
		{
			
			C_DebugConsole.setText(" Add " + event.tuioContainer.sessionID);
		}
	}
}