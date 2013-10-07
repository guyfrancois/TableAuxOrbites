package citeespace.tableAuxOrbites.flashs.ui_placement
{
	
	import citeespace.tableAuxOrbites.events.AskUserEvent;
	import citeespace.tableAuxOrbites.flashs.clips.C_TactileUiClip;
	import citeespace.tableAuxOrbites.views.C_DebugConsole;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tuio.TuioTouchEvent;
	
	import pensetete.tuio.clips.TactileUiClip;
	
	public class C_deplacable_satellite extends TactileUiClip
	{
		
		public function C_deplacable_satellite()
		{
			super();
			mouseEnabled  = true;
			dragEnabled   = false;
			
			rotateEnabled=false;
			zoomEnabled=false;
			
		}
		
		override protected function handleTouchBegin(event:TuioTouchEvent):void
		{
			dragEnabled=true;
			super.handleTouchBegin(event);
			
		}
		
		override protected function handleDrag(event:TransformGestureEvent):void
		{
			if (!mouseEnabled) return;
			var _localoffset : Point = parent.globalToLocal(new Point(event.offsetX,event.offsetY)).subtract(parent.globalToLocal(new Point(0,0)));
			
			
			if (_dragOffset == null) _dragOffset = new Point(0,0);
			_dragOffset.offset(_localoffset.x,_localoffset.y)
			
			
			if (dragEnabled) 
			{
				//if (hitTestPoint(event.stageX,event.stageY)) {
				
				var nextPos:Point=new Point(this.x,this.y).add(_localoffset);
				
				var zone:DisplayObject=parent["dragArea"];
				
				var gPos:Point=parent.localToGlobal(nextPos);
				if (zone && !zone.hitTestPoint(gPos.x,gPos.y)) {
					
				} else {
					this.x += _localoffset.x;
					this.y += _localoffset.y;
				}
				//}
			}  
				
		}
		
		
		
		
		
		override protected function handleTouchEnd(event:TuioTouchEvent):void
		{
			C_DebugConsole.setText("handleTouchEnd deplacable");
			dispatchEvent(new AskUserEvent(AskUserEvent.ITEM_DROPED,this));
			dragEnabled=false;
			
			super.handleTouchEnd(event);
			
		}
		
	}
}