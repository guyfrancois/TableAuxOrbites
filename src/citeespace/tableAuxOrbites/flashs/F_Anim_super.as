package citeespace.tableAuxOrbites.flashs
{
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	
	/**
	 * Classe générique de chargement d'anim 
	 * @author SPS
	 * 
	 */
	public class F_Anim_super extends MovieClip
	{
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à hide
		 */
		public var hide_tween_duration:Number = 0.5;
		
		/**
		 * Durée (en secondes) du tween lors de l'appel à show
		 */
		public var show_tween_duration:Number = 0.5;
		
		public function F_Anim_super()
		{
			super();
		}
		
		/**
		 *  
		 * @param noTween
		 * @return 
		 * 
		 */
		public function hide(noTween:Boolean=false):F_Anim_super
		{
			TweenLite.killTweensOf(this);
			if (noTween) {
				visible = false;
				alpha = 0;
			} else {
				TweenLite.to(this, hide_tween_duration, {alpha:0, onComplete:_hideComplete});
			}
			return this;
		} 
		
		protected function _hideComplete():void
		{
			visible = false;
		}
		
		public function show(noTween:Boolean=false):F_Anim_super
		{
			TweenLite.killTweensOf(this);
			visible = true;
			if (noTween) {
				alpha = 1;
			} else {
				TweenLite.to(this, show_tween_duration, {alpha:1,onComplete:_showComplete});
			}
			return this;
		}
		protected function _showComplete():void
		{
			
		}
		
	}
}