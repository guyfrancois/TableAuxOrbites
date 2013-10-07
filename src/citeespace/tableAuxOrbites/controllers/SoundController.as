package citeespace.tableAuxOrbites.controllers
{
	import citeespace.tableAuxOrbites.events.NavigationEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import org.casalib.util.ArrayUtil;
	
	import pensetete.textes.TextPlayListItem;
	
	import utils.DelayedCall;
	import utils.MyTrace;
	import utils.strings.TokenUtil;

	public class SoundController
	{
		
		/* Gestion du singleton */
		static protected var _instance:SoundController;
	
		static public function get instance():SoundController
		{
			return (_instance != null) ? _instance : new SoundController();
		}
		
		public function SoundController()
		{
				if (_instance != null) return;
				_instance = this;
				
		}
		
		internal function get txts():DataCollection {
			return DataCollection.instance;
		}
		
		
	
		
		protected var _sfxSndTransform:SoundTransform;
		

		internal var _lastAmbientId:String;
		internal var _lastAmbientSndChan:SoundChannel;
		internal var _sfxInteractionSndChan:SoundChannel;
		
		public function _playSfxInteraction(soundName:String):void
		{
			if (_sfxInteractionSndChan != null) _stopSfxInteraction();
			//MyTrace.put("} _playSfx('snd_chrono', 999);");
			
			_sfxInteractionSndChan = _playSfx(soundName, 0);
		}
		internal function _stopSfxInteraction():void
		{
			if (_sfxInteractionSndChan != null) _sfxInteractionSndChan.stop();
			//MyTrace.put("{ _stopSfxChrono");
			
			_sfxInteractionSndChan = null;
		}
	
		
		/*
		14:44:19:52	currentState ---------->accroche
		14:44:51:143	currentState ---------->choix_langue
		-> commentaire au clic
		14:45:38:756	currentState ---------->choix_satellite (commentaire audio)
		14:46:18:663	currentState ---------->choix_satellite_animcomplet attente selection
		14:46:47:368	currentState ---------->placement_satellite_init commentaure audio
		14:47:11:813	currentState ---------->state_placement_satellite_animcomplet	chrono
		14:47:26:118	currentState ---------->state_placement_satellite_complet		placement fait : commentaire
		14:47:37:739	currentState ---------->state_identifier_satellite_init	commentaire
		14:47:54:998	currentState ---------->state_identifier_satellite_start		chrono
		14:48:34:751	currentState ---------->state_identifier_satellite_validation commentaire
		14:48:41:399	currentState ---------->state_identifier_satellite_test2		chrono
		14:49:23:884	currentState ---------->state_identifier_satellite_validation	commentaire
		14:49:29:615	currentState ---------->state_identifier_satellite_complet
		14:49:30:129	currentState ---------->state_regler_frequence					commentaire
		14:49:42:360	currentState ---------->state_regler_frequence_start			chrono
		14:50:26:570	currentState ---------->state_regler_frequence_complet			commentaire
		14:50:30:223	currentState ---------->state_identifier_signal_init
		14:50:50:19	currentState ---------->state_identifier_signal_start				chrono
		14:51:20:71	currentState ---------->state_identifier_signal_validation			commentaire
		14:51:22:747	currentState ---------->state_identifier_signal_commentaire
		14:51:34:601	currentState ---------->state_identifier_signal_transition
		14:52:05:345	currentState ---------->state_video_conclusion					pas de son
		14:53:15:121	currentState ---------->state_choix_fin							reprise son
		14:53:45:204	currentState ---------->accroche								
		
		
		
		*/
		
		
		
		internal function updateSfxAmbiance():void
		{
			
			var sfxId:String="";
			switch(GameController.instance.currentState)
			{
				case GameController.STATE_ACCROCHE:
					sfxId="ambiance_accroche";
					break;
				case GameController.STATE_VIDEO_CONCLUSION:
					sfxId="";
					
				break;
				case GameController.STATE_PLACEMENT_SATELLITE_ANIMCOMPLET:
				case GameController.STATE_IDENTIFIER_SATELLITE_START:
				case GameController.STATE_IDENTIFIER_SATELLITE_TEST2:
				case GameController.STATE_REGLER_FREQUENCE_START:
				case GameController.STATE_IDENTIFIER_SIGNAL_START:
					sfxId="ambiance_chrono";
				break;
					
				case GameController.STATE_CHOIX_LANGUE:
				case GameController.STATE_CHOIX_SATELLITE:
				case GameController.STATE_CHOIX_SATELLITE_ANIMCOMPLET:
				case GameController.STATE_PLACEMENT_SATELLITE_INIT:
				
				case GameController.STATE_PLACEMENT_SATELLITE_COMPLET:
				case GameController.STATE_IDENTIFIER_SATELLITE_INIT:
				
				
				case GameController.STATE_IDENTIFIER_SATELLITE_VALIDATION:
				case GameController.STATE_IDENTIFIER_SATELLITE_VALIDATION2:
				case GameController.STATE_IDENTIFIER_SATELLITE_COMPLET:
				case GameController.STATE_REGLER_FREQUENCE:
				
				case GameController.STATE_REGLER_FREQUENCE_COMPLET:
				case GameController.STATE_IDENTIFIER_SIGNAL_INIT:

				case GameController.STATE_IDENTIFIER_SIGNAL_VALIDATION:
				case GameController.STATE_IDENTIFIER_SIGNAL_COMMENTAIRE:
				case GameController.STATE_IDENTIFIER_SIGNAL_TRANSITION:
				
				case GameController.STATE_CHOIX_FIN:
					sfxId="ambiance_activite";
					break;
				/*
				case GameController.STATE_CHOIX_LANGUE:
					sfxId = 'ambiance_choixLangue';
					break;
				*/
				
				default:
					sfxId="";
					break;
				
			}
			
			if (_lastAmbientId!=sfxId) {
				if (_lastAmbientSndChan != null) _stopSfxAmbiance();
				if (sfxId!="") {
					_lastAmbientSndChan = _playSfx(sfxId, int.MAX_VALUE,txts.getParamNumber('soundVolume_ambiance'));
				}
			}
			// _lastAmbientSndChan = _playSfx('sfx_ambiance_loop', int.MAX_VALUE);
			_lastAmbientId=sfxId;
		}
		
		internal function _stopSfxAmbiance():void
		{
			if (_lastAmbientSndChan != null) _lastAmbientSndChan.stop();
			_lastAmbientId="";
			_lastAmbientSndChan = null;
		}
		

		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////
		//						GESTION DES VOIX
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		protected var _voiceSndTransform:SoundTransform;
		protected var _soundPlayed:Array = [];
		protected var _soundChannelsPlayed:Array = [];
		
		
		protected var _lastSoundChannel:SoundChannel;
		internal function get lastSoundChannel():SoundChannel
		{
			return _lastSoundChannel;
		}
		
		public function _stopAllVoices():void
		{
			
			_playItemVoiceCallback = null;
			_voicesCallback = null;
			onSkipCurrentVoice(null);
			_voicesQueue = [];
			SoundController.instance.updateAmbiantVolume(false);
			
		}
		
		internal var _voicesQueue:Array = [];
		internal var _voicesCallback:Function;
		
		public function playItemsVoice(voiceId:String, callback:Function=null):void {
			_stopAllVoices();// interuption volontaire d'une voix
			SoundController.instance._playItemsVoice(LangageController.instance.getTextNodes(voiceId), callback)._playNextVoice();
		}
		/**
		 * 
		 * @param items Array of TextPlayListItem
		 * @param callback
		 * 
		 */
		internal function _playItemsVoice(items:Array /*of TextPlayListItem*/, callback:Function=null):SoundController
		{
			if (_voicesCallback != null && callback != null)
			{
				throw "Ecrasement d'un callback de lecture des sons";
			}
			if (callback != null) _voicesCallback = callback;
			ArrayUtil.addItemsAt(_voicesQueue, items);
			return this;
		}
		
		internal var _currentItemVoiceToken:String;
		internal function _playNextVoice():void
		{
			_currentItemVoiceToken = null;
			if (_voicesQueue.length < 1) 
			{
				if (_voicesCallback != null) {
					var t_callback:Function = _voicesCallback;					
					_voicesCallback = null;
					t_callback.call();
				}
				return;
			}
			var item:TextPlayListItem = _voicesQueue.shift();
			var delay:Number = (item.hasDuration) ? item.duration : 1;
			if (item.isPause)
			{
				new DelayedCall(_playNextVoice, 1000*item.duration);
			} else {
				_currentItemVoiceToken = item.language+"_"+item.id;
				_playItemVoice(item, _playNextVoice);
			}
			// new DelayedCall(_playNextVoice, 1000*delay);
		}
		internal function _playNextVoiceItemLang():void
		{
			_currentItemVoiceToken = null;
			if (_voicesQueue.length < 1) 
			{
				if (_voicesCallback != null) {
					var t_callback:Function = _voicesCallback;					
					_voicesCallback = null;
					t_callback.call();
				}
				return;
			}
			var item:TextPlayListItem = _voicesQueue.shift();
			var delay:Number = (item.hasDuration) ? item.duration : 1;
			if (item.isPause)
			{
				new DelayedCall(_playNextVoiceItemLang, 1000*item.duration);
			} else {
				_currentItemVoiceToken = item.language+"_"+item.id;
				_playItemVoice(item, _playNextVoiceItemLang,true);
			}
			// new DelayedCall(_playNextVoice, 1000*delay);
		}
		
	
		
		internal function _stopSfx(soundChannel:SoundChannel):void
		{
			if (soundChannel != null)
				soundChannel.stop();
		}
		
		internal function _delayedPlaySfx(args:Object):void
		{
			var sfxId:String = args.sfxId as String;
			var loops:int = (args.loops == null) ? 0 : args.loops as int;
			var vol:Number = (args.volume == null) ? NaN :  args.volume as Number;
			
			_playSfx(sfxId, loops, vol);
		}
		
		public function playSfx(sfxId:String, loops:int=0, volume:Number=NaN, initialDelay:Number=0):SoundChannel
		{
			return _playSfx(sfxId, loops, volume, initialDelay);
		}
		/**
		 * Lance la lecture d'un son 
		 * @param sfxId  le fichier son chargé sera %sfxId%.mp3 dans le dossier indiqué dans les params
		 * @param loops  Nombre d'itérations du son
		 * @param volume Volume entre 0 et 1 (multiplié par le volume des sfx définis dans les params)
		 * @param initialDelay  en secondes, le délai initial avant de lancer le son
		 * @return Attention : return null si un délai est défini (pour simplifier le code) 
		 * 
		 */
		private function _playSfx(sfxId:String, loops:int=0, volume:Number=NaN, initialDelay:Number=0):SoundChannel
		{
			if (initialDelay > 0)
			{
				var args:Object = {sfxId:sfxId, loops:loops, volume:volume};
				new DelayedCall(_delayedPlaySfx, 1000*initialDelay, args);
				return null;
			}
			
			var url:String;
			// On compose l'url du son 
			var tokens:Object = {};
			url = txts.getParamString('url_sound');
			tokens.file = sfxId + ".mp3";
			url = TokenUtil.replaceTokens(url, tokens);
			
			if ( _sfxSndTransform == null)
			{
				var vol:Number = txts.getParamNumber('soundVolume_sfx');
				if (isNaN(vol)) vol = 1;
				vol = Math.max(0, Math.min(vol, 1));
				_sfxSndTransform = new SoundTransform(vol);
			}
			
			var sfxVol:Number = txts.getSfxNominalVolume(sfxId);
			
			var snd:Sound = new Sound(new URLRequest(url));
			snd.addEventListener(IOErrorEvent.IO_ERROR, onSoundIoError_handler, false,0,true);
			var soundChannel:SoundChannel = snd.play(0,loops);
			
			var trsf:SoundTransform = soundChannel.soundTransform;
			sfxVol =  isNaN(volume) ? _sfxSndTransform.volume*sfxVol : _sfxSndTransform.volume *volume*sfxVol;
			trsf.volume = sfxVol;
			soundChannel.soundTransform = trsf;
			MyTrace.put("playSfx id : "+sfxId+" sound : " + trsf.volume);
			// soundChannel.addEventListener(Event.SOUND_COMPLETE, _playItemVoiceComplete_handler, false, 0, true);
			return soundChannel;
		}
		
		public function updateAmbiantVolume(voice:Boolean=false):void {
			if (_lastAmbientSndChan==null) return;
			if (_lastAmbientId=="") return;
			
			var soundChannel:SoundChannel=_lastAmbientSndChan;
			var sfxVol:Number = txts.getSfxNominalVolume(_lastAmbientId);
			
			var volume:Number;
			if (voice) {
				volume =  txts.getParamNumber('soundVolume_ambiance_w_voices');
			} else {
				volume =  txts.getParamNumber('soundVolume_ambiance');
			}
			var trsf:SoundTransform = soundChannel.soundTransform;
			sfxVol =  isNaN(volume) ? _sfxSndTransform.volume*sfxVol : _sfxSndTransform.volume *volume*sfxVol;
			trsf.volume = sfxVol;
			soundChannel.soundTransform = trsf;
			MyTrace.put("updateAmbiantVolume id : "+_lastAmbientId+" sound : " + trsf.volume);
			
		}
		
		internal function _playItemVoiceDelayed(item:Object):void
		{
			var txtItem:TextPlayListItem = item as TextPlayListItem;
			txtItem.startDelay = 0; // Pour ne pas patienter a l'execution du timeout
			_playItemVoice(txtItem);
		}
		
		internal var _playItemVoiceCallback:Function;
		
		internal function _playItemVoice(item:TextPlayListItem, callback:Function=null, useItemlang:Boolean=false):void
		{
			if (item == null) {
				MyTrace.put("*** Tentative de lecture d'une voix non trouvée");
				if (callback != null) callback.call();
				return;
			}
			
			if (callback != null) _playItemVoiceCallback = callback;
			if (item.startDelay > 0)
			{
				new DelayedCall(_playItemVoiceDelayed, 1000*item.startDelay, item);
				return;
			}
			
			if (item.noSound)
			{
				if (item.isPause)
				{
					new DelayedCall(_soundCallback, 1000*item.duration);
				} else {
					_soundCallback();
				}
				return;
			}
			
			
			// On joue le son associé 
			var tokens:Object = {};
			var url:String;
			// On compose l'url du son 
			if (item.language != null)
			{
				url = txts.getParamString('url_localized_sound');
				if (useItemlang == true) {
					tokens.lang = item.language;
				} else {
					tokens.lang = LangageController.instance.userLanguage;
				}
			} else {
				url = txts.getParamString('url_sound');
			}
			
			tokens.file = item.sndFileRadical + ".mp3";
			url = TokenUtil.replaceTokens(url, tokens);
			
			if (_voiceSndTransform == null)
			{
				var vol:Number = txts.getParamNumber('soundVolume_voices');
				if (isNaN(vol)) vol = 1;
				vol = Math.max(0, Math.min(vol, 1));
				_voiceSndTransform = new SoundTransform(vol);
			}
			var snd:Sound = new Sound(new URLRequest(url));
			snd.addEventListener(IOErrorEvent.IO_ERROR, onSoundIoError_handler, false,0,true);
			var soundChannel:SoundChannel = snd.play(0,0,_voiceSndTransform);
			if (soundChannel==null)
				return;
			var trsf:SoundTransform = soundChannel.soundTransform;
			trsf.volume = _voiceSndTransform.volume;
			soundChannel.soundTransform = trsf;
			soundChannel.addEventListener(Event.SOUND_COMPLETE, _playItemVoiceComplete_handler, false, 0, true);
			_soundPlayed.push(snd);
			_soundChannelsPlayed.push(soundChannel);
			_lastSoundChannel = soundChannel;
			MyTrace.put("lecture du son " + item.id+ " ( chargé depuis "+url+") :"+ item.text);
			updateAmbiantVolume(true);
			
		}
		
		
		internal function onSkipCurrentVoice(event:NavigationEvent):void
		{
			if (_lastSoundChannel == null) return;
			_lastSoundChannel.removeEventListener(Event.SOUND_COMPLETE, _playItemVoiceComplete_handler);
			_lastSoundChannel.stop();
			_lastSoundChannel = null;
			_playItemVoiceComplete_handler(null);
		}
		
		/**
		 * Callback défini dans _playItemVoice, déclenché lorsqu'un son a été 
		 * joué jusqu'à sa fin 
		 * @param event
		 * 
		 */
		internal function _playItemVoiceComplete_handler(event:Event):void
		{
			if (_lastSoundChannel!=null) {
				_lastSoundChannel.stop();
			}
			_currentItemVoiceToken = null;
			_lastSoundChannel = null;
			_soundCallback();
		}
		
		internal function _soundCallback(event:Event=null):void
		{
			updateAmbiantVolume(false);
			if (_playItemVoiceCallback != null) 
			{
				var cb:Function = _playItemVoiceCallback;
				_playItemVoiceCallback = null;
				cb.call();
			}
		}
		
		/**
		 * Callback défini dans _playItemVoice, déclenché lorsqu'un son 
		 * n'a pas été correctemetn chargé
		 * @param event
		 * 
		 */
		internal function onSoundIoError_handler(event:IOErrorEvent):void
		{
			MyTrace.put("*** ERREUR de chargement du son :"+event.text, MyTrace.LEVEL_ERROR);
			// _soundCallback();
			// En cas d'erreur on lance le son suivant apres 1 sec
			new DelayedCall(_soundCallback);
		}
	}
}