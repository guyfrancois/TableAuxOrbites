package citeespace.tableAuxOrbites.flashs.ui.boutons
{
	import citeespace.tableAuxOrbites.controllers.SoundController;
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import flash.events.TransformGestureEvent;
	import flash.media.SoundChannel;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.TactileClip;
	
	public class C_Potar extends TactileClip
	{
		
		private var soundChannel:SoundChannel;
		override public function set rotationParDrag(value:Boolean):void
		{
			if (soundChannel && !value) soundChannel.stop();
			_rotationParDrag = value;
		}
		public function C_Potar()
		{
			
			super();
			dragEnabled=false;
			rotateEnabled=false;
			rotationParDrag=false;
			
		}
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			if(!mouseEnabled)	return;
			// TODO Auto Generated method stub
			super.handleTouchBegin(event);
			//soundChannel=SoundController.instance.playSfx("sfx_potar");
		}
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			C_DebugConsole.setText("handleTouchEnd C_Potar");
			// TODO Auto Generated method stub
			if (soundChannel) soundChannel.stop();
			soundChannel=null;
			super.handleTouchEnd(event);
		}
		
		
		override protected function handleDrag(event:TransformGestureEvent):void
		{
			// TODO Auto Generated method stub
			if(!mouseEnabled || !_rotationParDrag)	return;
			super.handleDrag(event);
			if (!soundChannel ) soundChannel=SoundController.instance.playSfx("sfx_potar");
			dispatchEvent(new AskUserEvent(AskUserEvent.ITEM_ROTATE,rotation));
		}
		
		override protected function handleRotate(event:TransformGestureEvent):void
		{
			if(!mouseEnabled || !_rotationParDrag)	return;
			if (!rotateEnabled) return;
			if (!soundChannel) soundChannel=SoundController.instance.playSfx("sfx_potar");
			// TODO Auto Generated method stub
			super.handleRotate(event);
			dispatchEvent(new AskUserEvent(AskUserEvent.ITEM_ROTATE,rotation));
		}
		
		
		
	}
}