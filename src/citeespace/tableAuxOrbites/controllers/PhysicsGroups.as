package citeespace.tableAuxOrbites.controllers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * Les groupes servent à distringuer les univers physiques parallèles. 
	 * Chaque gorup stockera les id des interface déjà en cour sde gestion
	 * Par exemple lorsqu'un containerID tuio sera géré, son id sera stocké pour
	 *  le renseigner aux autres univers parallèle exploitant le même groupe. 
	 *
	 * @author sps
	 * @version 1.0.0 [6 déc. 2011][sps] creation
	 *
	 * citeespace.planisphere.controllers.PhysicsGroups
	 */
	public class PhysicsGroups extends EventDispatcher
	{
		
		//
		
		
		
		static protected var groups:Dictionary = new Dictionary();
		
		static public function get(groupName:String):PhysicsGroups
		{
			var t_group:PhysicsGroups = groups[groupName] as PhysicsGroups;
			if (t_group == null) {
				t_group = new PhysicsGroups(groupName);
			}
			return t_group;
		}
		
		
		protected var usedTriggers:Object = {};
		
		public function beginTrigger(triggerID:String):void
		{
			usedTriggers[triggerID] = {};
		}
		public function endTrigger(triggerID:String):void
		{
			usedTriggers[triggerID] = null;
		}
		public function isTriggerInUse(triggerID:String):Boolean
		{
			return (usedTriggers[triggerID] != null);
		}
		public function getTriggerData(triggerID:String):Object
		{
			var obj:Object = usedTriggers[triggerID] as Object;
			if (obj == null) obj = {depths:[], sprites:[]};
			return obj;
		}
		public function setTriggerData(triggerID:String, datas:Object):void
		{
			 usedTriggers[triggerID] = datas;
		}
		
		private var _groupName:String;
		public function get groupName():String { return _groupName; }

		
		
		public function PhysicsGroups(name:String)
		{
			super();
			_groupName = name;
			if (groups[groupName] == null) {
				groups[groupName] = this;
			} else {
				throw "Création d'un group physique déjà existant";
			}
		}
	}
}