package citeespace.tableAuxOrbites.flashs
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.GameController;
	import citeespace.tableAuxOrbites.controllers.PtTouchController;
	import citeespace.tableAuxOrbites.controllers.TimerController;
	import citeespace.tableAuxOrbites.events.DebugEvent;
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	import citeespace.tableAuxOrbites.tools.XClassImporter;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.fscommand;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import net.hires.debug.Stats;
	
	import org.casalib.util.ArrayUtil;
	import org.tuio.debug.TuioDebug;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.ScreenshotUtil;
	import utils.params.ParamsHub;
	
	/**
	 * 
	 * charger les elements de l'interface<br>
	 * configure le menu contextuel (clic droit) et touches de raccourcis de debug et interfaces de debug
	 * @author GUYF
	 */	
	public dynamic class F_TableAuxOrbites extends F_Anim_super
		{
			static public var SWF_PATH:String = '../swf/';
			static public const STAGE_WIDTH:Number  = 1366;
			static public const STAGE_HEIGHT:Number = 768;
			
			/* ------------- Éléments définis dans le Flash ----------- */
			public var handle_tuio:MovieClip;
			public var handle_animAccroche:MovieClip;
			public var handle_animTimeout:MovieClip;
			public var handle_uiJoueurs:MovieClip;
			
			public var handle_visuelsCas:MovieClip;
			public var handle_backgrounds:MovieClip;
			
			/* ------------------------------------------------- */
			
			
			protected var _loadQueueTokens:Array = [];
			protected var ptTouchController:PtTouchController;
			protected var dbgConsole:C_DebugConsole;
			
			
			//private var localTuioManager:TuioManagerCentral; 
			
			private var stats:Stats;
			public function F_TableAuxOrbites()
			{
				
				gotoAndStop(1);
				
				if (stage) 
					initSwf();
				else
					addEventListener(Event.ADDED_TO_STAGE, initSwf, false,0,true);
				
			}
			
			protected function initSwf(event:Event=null):void
			{
				_stageDisplayState = stage.displayState;
				updateStageDisplayMode();
				// stage.showDefaultContextMenu  = false;// Mask le menu fichier et cie
				
				// On charge les textes depuis le doc XML
				var textsColl:DataCollection = DataCollection.instance;
				if (textsColl.xmlLoaded) onXmlDatasReady(null);
				else textsColl.addEventListener(Event.COMPLETE, onXmlDatasReady, false, 0, true);
				
			}
			
			
			
			protected function onXmlDatasReady(event:Event):void
			{
				initContents();
			}
			
			
			/**
			 * Méthode principale d'initialisation du FLash une fois les XML chargés 
			 * @param event
			 * 
			 */
			protected function initContents():void
			{
				new XClassImporter();
				// Test de paramètres
				//var dbg_01:* = DataCollection.params.getJsonObj('dock_1_outil_3Dparams', {x:0,y:0,rotationY:33});
				
				// Les textes ont été chargés
				var texts:DataCollection = DataCollection.instance;
				var params:ParamsHub = DataCollection.params;
				
				// Ajout de l'élément Tuio de management, débug et tests
				//var dbgTuio:Boolean = params.getBoolean('showDebugTuio', false) ;
				/*var useTuio:Boolean = params.getBoolean('enableTuio', true);
				if (useTuio) {*/
				
				/*
				ptTouchController = new PtTouchController(params);
				handle_tuio.addChild(ptTouchController);
				*/
				
				//localTuioManager = new TuioManagerCentral(dbgTuio);
				//handle_tuio.addChild(localTuioManager);
				/*}*/
				
				GameController.instance.initGame(null, this.stage); // On s'assure que les éléments seront pret et initialisés
				
				_loadUiParts();
				
				
				var cm:ContextMenu = new ContextMenu();
				cm.hideBuiltInItems();
				var cmi:ContextMenuItem;
				
				stats = new Stats();
				stats.visible = params.getBoolean('showStats', false); 
				addChild(stats);
				
				dbgConsole =  getChildByName('debugConsole') as C_DebugConsole;//new C_DebugConsole();
				if (dbgConsole) {
					dbgConsole.visible = params.getBoolean('showDebugInfo', false);
				}
				
				
				cmi = new ContextMenuItem("Retour à l’accroche", false,true);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onRetourAccrocheSelected);
				cm.customItems.push(cmi);
				
				if (params.getBoolean('quitOnEsc', true)) 
				{
					stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDn_watchForEsc);
				}
				if (params.getBoolean('fastTestMode', true)) {
					stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp_skipSound);
				}
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp_genericShortCuts);
				
				if (params.getBoolean('quitOnRightClic', true)) 
				{
					//	stage.addEventListener(MouseEvent.MOUSE_DOWN, onRightMouseDown);
					//	stage.addEventListener(MouseEvent.CONTEXT_MENU, onRightMouseDown);
					
					cmi = new ContextMenuItem("Quitter", true);
					cm.customItems.push(cmi);
					cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onQuitSelected);
					
				}
				cmi = new ContextMenuItem("version "+params.getString('version') + " du "+params.getString('versionDate'), true,false);
				cm.customItems.push(cmi);
				
				cmi = new ContextMenuItem("Réalisation Pense-Tête", true,true);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onPenseTeteSelected);
				cm.customItems.push(cmi);
				
				this.contextMenu = cm;
				
				if (params.getBoolean('fullscreen', false)) 
				{
					try {
						stage.displayState = StageDisplayState.FULL_SCREEN;
					} catch (e:Error) {
						MyTrace.put(e.message);
					}
				}
				_stageDisplayState = stage.displayState;
				
				if (!params.getBoolean('showMouseCursor', true))
				{
					Mouse.hide();
				}
				
				
				
			}
			
			protected var _stageDisplayState:String;
			
			
			private function updateStageDisplayMode():void
			{
				
				stage.displayState = _stageDisplayState; 
				stage.scaleMode	   = StageScaleMode.SHOW_ALL;
				
			}
			
			private function initTuio():void
			{
				ptTouchController = new PtTouchController(DataCollection.params);
				handle_tuio.addChild(ptTouchController);
				
			}
			
			
			protected function onPenseTeteSelected(event:ContextMenuEvent):void
			{
				navigateToURL(new URLRequest('http://www.pense-tete.com/'));
			}	 	
			
			
			protected function _loadUiParts(event:Event=null):void
			{
				_loadQueueTokens = [];
				var loader:Loader;
				
				/*
				// On prépare l'ffichage des vidéos
				var stageVideoPlayer:CPlanisphereStageVideoPlayer = new CPlanisphereStageVideoPlayer();
				addChildAt(stageVideoPlayer, 0);
				*/
				
				// On charge l'élément qui s'occupera des anims des cas
				//handle_animCas.addChild(new AnimCasLoader());
				
				// On charge l'anim d'accroche
				
				var params:ParamsHub = DataCollection.params;
				
				var bgColor:uint = params.getNumber('opaqueBackgroundColor', 0x000000);
				var bg:Sprite = new Sprite();
				bg.graphics.beginFill(bgColor);
				bg.graphics.drawRect(0,0,STAGE_WIDTH, STAGE_HEIGHT);
				bg.graphics.endFill();
				stage.addChildAt(bg, 0);
				bg.visible = params.getBoolean('opaqueBackgroundColorVisible', false);
				
				
				
				_loadQueueTokens.push('swf_accroche');
				loader = new Loader();
				loader.load(new URLRequest(SWF_PATH+'accroche.swf'));
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false,0,true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAnimAccrocheLoaded, false, 0, true);
				handle_animAccroche.addChild(loader);
				
				
				// Chargement de l'anim de timeout
				_loadQueueTokens.push('swf_timeout');
				loader = new Loader();
				loader.load(new URLRequest(SWF_PATH+'timeout.swf'));
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false,0,true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAnimTimeoutLoaded, false, 0, true);
				handle_animTimeout.addChild(loader);
				
				
				// On charge les arrières plans
				_loadQueueTokens.push('swf_backgrounds');
				loader = new Loader();
				loader.load(new URLRequest(SWF_PATH+'backgrounds.swf'));
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false,0,true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAnimBackgroundsLoaded, false, 0, true);
				handle_backgrounds.addChild(loader);
				//handle_backgrounds.alpha = 0.3;
				
				
				// On charge l'UI 
				_loadQueueTokens.push('swf_ui');
				loader = new Loader();
				loader.load(new URLRequest(SWF_PATH+'user_interface.swf'));
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false,0,true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAnimUILoaded, false, 0, true);
				handle_uiJoueurs.addChild(loader);
				

				
				
			}
			
			
			
			protected function onLoadError(event:IOErrorEvent):void
			{
				MyTrace.put("Erreur de chargement :" + event.text);
			}
			
			protected function onUiPlayerLoaded(event:Event):void
			{
				// Chargement du swf de l'ui des joueurs
				var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
				/*
				var uiPlayer:FPlayerPanel = loaderInfo.content as FPlayerPanel;
				
				uiPlayer.joueur = new Joueur();
				// uiPlayer.showInvitation();
				_checkLoadQueue('playerPanel'+uiPlayer.joueur.playerId);
				*/
			}
			
			
			
			protected function onAnimAccrocheLoaded(event:Event):void
			{
				// Lors du chargement initial on la joue
				_checkLoadQueue('swf_accroche');
				
				new DelayedCall(updateStageDisplayMode, 3000);
				new DelayedCall(initTuio, 6000);
			}
			
			protected function onAnimTimeoutLoaded(event:Event):void
			{
				_checkLoadQueue('swf_timeout');
			}
			
			protected function onAnimBackgroundsLoaded(event:Event):void
			{
				_checkLoadQueue('swf_backgrounds');
			}
			
	
			protected function onAnimUILoaded(event:Event):void
			{
				_checkLoadQueue('swf_ui');
			}
			
			
			protected function _checkLoadQueue(loadedToken:String=''):void
			{
				ArrayUtil.removeItem(_loadQueueTokens, loadedToken);
				
				MyTrace.put(loadedToken +' chargé, restants: '+_loadQueueTokens);
				
				if (_loadQueueTokens.length > 0) return;
				
				// Tous les éléments attendus pour l'init ont été chargés
				// On lance le jeu, commencant par la boucle d'attente
				GameController.instance.startGame();
			}
			

			
			protected function onKeyDn_watchForEsc(event:KeyboardEvent):void
			{
				if (event.keyCode == Keyboard.ESCAPE)
				{
					doQuit();
				}
			}
			
			protected function onQuitSelected(event:ContextMenuEvent):void
			{
				doQuit();
			}
			
			
			protected function onRightMouseDown(event:MouseEvent):void
			{
				// trace(event);
				// doQuit();
			}
			
			
			private function doQuit():void
			{
				/*
				if (localTuioManager != null)
				{
				localTuioManager.shutDown();
				}
				*/
				fscommand("quit");
			}
			
			protected function onKeyUp_skipSound(event:KeyboardEvent):void
			{
				if (event.keyCode == Keyboard.SPACE)
				{
					var navEvt:NavigationEvent = new NavigationEvent(NavigationEvent.SKIP_CURRENT_VOICE);
					navEvt.dispatch();
				}
			}
			
			protected function onKeyUp_genericShortCuts(event:KeyboardEvent):void
			{
				/*
				
				0 pavé numérique : stats de performance on/off
				1 pavé numérique : débug physique on/off
				F1  : retour accroche
				F12 : screenshot (si activé dans les paramètres)
				
				*/
				if (event.keyCode == Keyboard.F1)
				{
					onRetourAccrocheSelected(null);
					
				} else if(event.keyCode == Keyboard.F12) {
					if (DataCollection.params.getBoolean('screenshotEnabled', false)) {
						// Sauvegarde en png
						if (stage)
							ScreenshotUtil.saveToPng(stage);
					}
					
				} else if (event.keyCode == Keyboard.NUMPAD_0) {
					stats.visible = !stats.visible;
					
				} else if (event.keyCode == Keyboard.NUMPAD_1) {
					if (DataCollection.params.getBoolean('showDebugTuio', false)) {
						try {
							TuioDebug.getInstance().showObjects=!TuioDebug.getInstance().showObjects;
							TuioDebug.getInstance().showCursors=!TuioDebug.getInstance().showCursors;
							TuioDebug.getInstance().showDebugText=!TuioDebug.getInstance().showDebugText;
						} catch(e:Error) {
							
						}
					}
					
				} else if (event.keyCode == Keyboard.NUMPAD_2) {
					if (dbgConsole) {
						dbgConsole.visible = !dbgConsole.visible;
					}
					
				} else if (event.keyCode == Keyboard.NUMPAD_3) {
					
					Mouse.hide()
					
				} else if (event.keyCode == Keyboard.NUMPAD_4) {
					Mouse.show()
					
				} else if (event.keyCode == Keyboard.NUMPAD_5) {
					DebugEvent.dispatch(DebugEvent.TOGGLE_DEBUG_PHYSICS);
				} else if (event.keyCode == Keyboard.NUMPAD_6) {
					
				} else if (event.keyCode == Keyboard.NUMPAD_7) {
					
				} else if (event.keyCode == Keyboard.NUMPAD_8) {
					
				} else if (event.keyCode == Keyboard.NUMPAD_9) {
					
				} 
			}
			
			
			protected function onRetourAccrocheSelected(event:ContextMenuEvent):void
			{
				TimerController.instance.showWaitLoop();
			}
			
			
		}
}