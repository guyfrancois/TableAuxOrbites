package citeespace.tableAuxOrbites.views
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import utils.MyTrace;
	import utils.movieclip.MovieClipUtils;
	
	/**
	 * 
	 *
	 * @author sps
	 *
	 * citeespace.planisphere.views.C_DebugConsole
	 */
	public class C_DebugConsole extends MovieClip
	{
		
		static private var _instance:C_DebugConsole;
		public static function get instance():C_DebugConsole
		{
			return _instance;
		}
		public static function set instance(value:C_DebugConsole):void
		{
			_instance = value;
		}
		
		static public function setText(str:String):void
		{
			if (_instance == null) return;
			instance.setText(str);
		}
		
		
		
		private var legend:TextField;
		public function C_DebugConsole()
		{
			super();
			
			instance = this;
			if (stage) onAddedToStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			
			
			
			var t_legend:TextField = getChildByName('legend') as TextField;
			if (t_legend == null) 
			{
				legend = new TextField();
				
				legend.autoSize = TextFieldAutoSize.LEFT;
				// Debug infos
				//legend.background 		 = true;
				//legend.backgroundColor 	 = 0xFFFFFFFF;
				//legend.defaultTextFormat = new TextFormat("_sans", 9, 0x000000);
				legend.multiline 		 = true;
				legend.width = 478;
				legend.x = 0;
				legend.y = 0;
				addChild(legend);
			} else {
				legend = t_legend;
			}
			legend.text = "";
			 
			
		}
		
		public function setText(str:String):void
		{
			legend.appendText("\n"+getTimer() +" " +str);
			legend.scrollV=legend.maxScrollV;
			MyTrace.put("¤ "+str);
		}
	}
}