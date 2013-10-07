package citeespace.tableAuxOrbites.flashs.clips
{
	import flash.geom.Rectangle;
	
	/**
	 * 
	 *
	 * @author sps
	 * @version 1.0.0 [9 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.flashs.clips.ICollisionDefinition
	 */
	public interface ICollisionDefinition 
	{
		
		function get threshold():Number;
		
		function get isActive():Boolean;
		
		/**
		 * Type de forme de proxy de collision à associer, cf PhysicsController.PROXY_SHAPE_CIRCLE 
		 * @return 
		 * 
		 */
		function get proxyShape():uint;
		
		function getUnrotatedRect():Rectangle;
	}
}