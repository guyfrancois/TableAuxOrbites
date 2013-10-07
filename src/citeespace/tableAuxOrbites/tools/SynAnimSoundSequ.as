package citeespace.tableAuxOrbites.tools
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.LangageController;
	import citeespace.tableAuxOrbites.controllers.SoundController;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.SoundChannel;
	
	import utils.movieclip.MovieClipUtils;

	public class SynAnimSoundSequ
	{
		public static var COMMENTTYPEVOICE:String="VOICE"
		public static var COMMENTTYPEFX:String="FX"
	
		private var seq:Array;
		private var endCallBack:Function;
		private var anim:MovieClip;
		public function SynAnimSoundSequ(anim:MovieClip,endCallBack:Function)
		{
			seq=new Array();
			this.anim=anim;
			this.endCallBack=endCallBack;
		}
		
		
		/**
		 * 
		 * @param frame Number ou etiquette ou Function(callBack_complete:Function)
		 * @param comment		chaine id de son
		 * @param commentType	SynAnimSoundSequ.COMMENTTYPEVOICE ou SynAnimSoundSequ.COMMENTTYPEFX
		 * 
		 */
		public function add(frame:*,comment:String,commentType:String="VOICE"):void {
			var o:Object=new Object();
			var iframe:Number=0;
			if (frame is Function) {
				o.frame=frame;
			}
			if (frame is Number) {
				o.frame=Number(frame);
			}
			if (frame is String) {
				o.frame=hframeof(String(frame));
			}
			if (comment) {
				o.comment=comment;
				o.fx=(commentType==COMMENTTYPEFX)
			}
			seq.push(o);
		}
		
		private var running:Boolean=false;
		public function play():void {
			running=true;
			_play(0);
		}
		
		public function stop():void {
			if (!running) return;
			running=false,
			LangageController.instance.clear_uniq_txtid();
			SoundController.instance._stopAllVoices();
			if (fxChan) fxChan.stop();
		}
		
		private var currentSeq:Number=0;
		
		
		
		
		private function _play(seqid:Number=0):void {
			currentSeq=seqid;
			
			var oSyn:SyncVoiceAnim=new SyncVoiceAnim(playNext);
			
			if (seq[seqid].frame && seq[seqid].comment) {
				
			}
			if (seq[seqid].frame) {
				if (seq[seqid].frame is Function) {
					(seq[seqid].frame as Function).call(null,oSyn.cb_animTrue);
				} else {
					htweenToFrame(seq[seqid].frame,oSyn.cb_animTrue);
				}
			} else {
				oSyn.cb_animTrue();
			}
			if (seq[seqid].comment) {
				if (!seq[seqid].fx) {
					LangageController.instance.uniq_DisplaySsTitresAndVoice(seq[seqid].comment, oSyn.cb_voiceTrue);
				} else {
					hplayfx(seq[seqid].comment,oSyn.cb_voiceTrue);
				}
			} else {
				oSyn.cb_voiceTrue();
			}
		}
		
		private function playNext():void {
			if (!running) return;
			currentSeq++;
			if (currentSeq<seq.length) {
				_play(currentSeq);
			} else {
				onSeqComplete();
			}
		}
		
		private function onSeqComplete():void
		{
			running=false;
			if (endCallBack  != null) endCallBack.call();
		}
		
		
		// CONTROL D'IMAGE
		private function hframeof(frame:String):Number {
			return MovieClipUtils.getFrameForLabel(anim,frame);
		}
		private function htweenToFrame(frame:Number,callBack:Function=null):void {
			TweenLite.to(anim,Math.abs(frame-anim.currentFrame),{frame:frame,useFrames:true,onComplete:callBack});
		}
		
		// CONTROL DE BRUIT
		private var callBackFx:Function
		private var fxChan:SoundChannel
		private function hplayfx(name:String,callBack:Function=null):void {
			callBackFx=callBack;
			(fxChan=SoundController.instance.playSfx(name,0,  DataCollection.instance.getParamNumber('soundVolume_signal_sfx',1))).addEventListener(Event.SOUND_COMPLETE, _fxComplete, false, 0, true);
			SoundController.instance.updateAmbiantVolume(true);
		}
		
		protected function _fxComplete(event:Event):void
		{
			(event.currentTarget as SoundChannel).stop();
			SoundController.instance.updateAmbiantVolume(false);
			// TODO Auto-generated method stub
			if (callBackFx != null) {
				var cb:Function = callBackFx;
				callBackFx = null;
				cb.call();
			}
		}
	}
}



class SyncVoiceAnim
{
	private var _voice:Boolean=false;
	private var _Anim:Boolean=false;
	private var _callBack:Function
	public function SyncVoiceAnim(callBack:Function) 
	{
		this._callBack=callBack
	}
	
	public function get Anim():Boolean
	{
		return _Anim;
	}
	
	public function set Anim(value:Boolean):void
	{
		_Anim = value;
		tryTest()
	}
	
	public function get voice():Boolean
	{
		return _voice;
	}
	
	public function set voice(value:Boolean):void
	{
		_voice = value;
		tryTest()
	}
	
	public function cb_animTrue():void {
		Anim=true;
	}
	public function cb_voiceTrue():void {
		voice=true;
	}
	
	private function tryTest():void {
		if (_Anim && _voice && _callBack!=null) {
			_callBack.call();
			_callBack=null
		}
	}
}