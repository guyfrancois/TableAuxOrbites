package citeespace.tableAuxOrbites.flashs.clips
{
	import citeespace.tableAuxOrbites.controllers.DataCollection;
	import citeespace.tableAuxOrbites.controllers.PhysicsController;
	
	import flash.geom.Rectangle;
	
	import utils.params.ParamsHub;
	
	/**
	 * Clip qui sert à définir une zone de collision
	 *
	 * @author sps
	 * @version 1.0.0 [9 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.clips.CCollisionDefinitionClip
	 */
	public class CCollisionDefinitionClip extends C_TactileUiClip implements ICollisionDefinition
	{
		
		protected var _threshold:Number = 30;
		protected var _proxyshape:uint = PhysicsController.PROXY_SHAPE_CIRCLE;
		
		public function CCollisionDefinitionClip()
		{
			super();
			
			zoomEnabled = false;
			dragEnabled = false;
			rotateEnabled = false;
		
			var params:ParamsHub = DataCollection.params;
			_threshold = params.getNumber('collision_threshold', _threshold);
			
			
			
		}
		
		public function get threshold():Number
		{
			return _threshold;
		}
		
		public function get isActive():Boolean
		{
			return (alpha > 0.5);
		}
		
		public function get proxyShape():uint
		{
			return _proxyshape;
		}
		public function set proxyShape(shapeType:uint):void
		{
			_proxyshape = shapeType;
		}
		
		public function getUnrotatedRect():Rectangle
		{
			var t_rot:Number = rotation;
			rotation = 0;
			
			var clipRect:Rectangle = getRect(parent);// new Rectangle(x, y, width, height);
			rotation = t_rot;
			
			return clipRect;
		}
		
		
		
		
		
	}
}