package citeespace.tableAuxOrbites.controllers
{
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.apache.xinclude4flex.events.MultiProgressEvent;
	import org.apache.xinclude4flex.loaders.XIncludeXMLLoader;
	import org.casalib.util.ArrayUtil;
	
	import utils.params.ParamsHub;
	import utils.strings.TokenUtil;

	/** COMPLETE est dispatché lorsque les textes ont été chargés et prêts à 
	 * être exploités */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * citeespace.planisphere.models.DataCollection
	 * Cette classe sert de collecteur des textes et de leur formats poru le jeu de l'adaptation 2011.
	 * 
	 * Cette classe charge automatiquement les données XML à son initialisation. Pour vérifier la disponibilité des données, utilisez un écouteur et le getter xmLoaded comme suit :
	 * <pre>
	var textsColl:TextsCollection = TextsCollection.instance;
	if (textsColl.xmlLoaded) onTextsReady(null);
	else textsColl.addEventListener(Event.COMPLETE, onTextsReady, false, 0, true);
		</pre> 
	 * 
	 * @author SPS
	 * @version 1.0.0 2011 01 24 Creation
	 * @version 1.0.1 2011 01 25 Ajout d'un fallback sur une autre langue si la langue demandée n'est pas définie
	 * @version 1.0.2 2011 11 10 Changement de package pour adapter à la Cité de l'Espace (planisphere des animaux)
	 * @version 1.1.3 [24 nov. 2011][sps] Sépération du chargement des paramètres dans un autre XML, utilisation de paramsHub pour plus de clareté
	 * @version 2.0.4 [ 8 déc. 2011][sps] Passage d'un URLLoader à XIncludeXMLLoader pour charger des XML imbriqués grace à XInclude 
	 * @version 2.0.5 [12 jan. 2012][sps] Ajout d'un isHtml() pour savoir comment injecter un texte 
	 */
	public class DataCollection extends EventDispatcher
	{
		/** Chemin du ficheir XML contenanty les textes à gérer */
		static public var XML_CONTENTS_PATH:String = '../contents/xml/contents.xml';
		static public var XML_PARAMS_PATH:String = '../contents/xml/params.xml';
		
		public var xmlLoaded:Boolean = false;
		private var _loadedXML:XML;
		/** Cette méthode d'accès aux données brutes est essentiellement dsponible à fins de tests et déboguage */
		public function get loadedXML():XML  { return _loadedXML; }
		
		/* Buffers contenant les infos chargées */
		private var _languages:Array /*of String*/= [];
		public function get languages():Array { return _languages.concat(); }
		public function set languages(value:Array):void { _languages = value; }

		protected var templates:Object = {};
		protected var textsXmlList:XMLList;
		
		public var soundVolumesXmlList:XMLList;
		
		
		static public function get params():ParamsHub
		{
			return ParamsHub.instance;
		}
		
		public function DataCollection()
		{
			if (_instance != null) return;
			
			_instance = this;
			// On charge les données XML poru parser les textes
			_loadXml();
		}
		
		/* ----- Gestion du singleton ----- */
		static private var _instance:DataCollection;
		static public function get instance():DataCollection
		{
			if (_instance == null) new DataCollection();
			return _instance;
		}
		
		
		
		/**
		 * Alias de params.getString(), conervsé ici poru raison historique et 
		 * préservation de l'API
		 *  
		 * @param paramId
		 * @param defaultValue
		 * @return 
		 * 
		 */
		public function getParamString(paramId:String, defaultValue:String=''):String
		{
			return params.getString(paramId, defaultValue);
		}
		
		/**
		 * Alias de params.getNumber(), conervsé ici poru raison historique et 
		 * préservation de l'API
		 * 
		 * @param paramId
		 * @param defaultValue
		 * @return 
		 * 
		 */
		public function getParamNumber(paramId:String, defaultValue:Number=NaN):Number
		{
			return params.getNumber(paramId, defaultValue);
		}
		
		/*
		public function getCreditsFinUrl():String
		{
			var langMaj:String =LangageController.instance.userLanguage;
			var url:String = getParamString('url_credits_fin');
			var tokens:Object = {lang:langMaj};
			url = TokenUtil.replaceTokens(url, tokens);
			return url;
		}
		*/
		
		/**
		 *  
		 * @param sfxId
		 * @return 1 si le volume de sfx n'est pas explicitement modifié dans les contenus XML, sinon la valeur numériquie entre 0 et 1 
		 * 
		 */
		public function getSfxNominalVolume(sfxId:String):Number
		{
			var out:Number = 1;
			var xmlNodes:XMLList = soundVolumesXmlList.(@id==sfxId);
			if (xmlNodes.length() < 1) return out;
			var xmlNode:XML   = xmlNodes[0];
			var strVal:String = xmlNode.@volume;
			out = Number(strVal);
			if (isNaN(out)) out = 1;
			out = Math.max(0, Math.min(out, 1))
			return out;
		}
		
		protected var _xmlLoadQueue:Array = [];
		protected function _loadXml():void
		{
			// Chargement du XML de paramètrage
			loadXmlFile('params', XML_PARAMS_PATH, onParamsLoad_complete, onParamsLoad_error);
			
			// Chargement du XML de contenus
			loadXmlFile('contents', XML_CONTENTS_PATH, onDataLoad_complete, onDataLoad_complete);
		}
		
		protected function loadXmlFile(loadQueueId:String, strUrl:String, completeCb:Function, errorCB:Function):void
		{
			_xmlLoadQueue.push(loadQueueId);
			var xiLoader:XIncludeXMLLoader = new XIncludeXMLLoader();
			xiLoader.addEventListener(Event.COMPLETE, completeCb);
			xiLoader.addEventListener(ErrorEvent.ERROR, errorCB);
			xiLoader.addEventListener(MultiProgressEvent.PROGRESS, onXmlProgress);
			xiLoader.load(strUrl);
			
			/*
			var loader:URLLoader = new URLLoader();
			var request:URLRequest	= new URLRequest(strUrl);
			loader.addEventListener(Event.COMPLETE, completeCb);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorCB);
			loader.load(request);
			*/
		}
		
		protected function onXmlProgress(event:MultiProgressEvent):void
		{
			trace('multiprogress :' + event.loadIndex +'/'+event.totalLoads); 
		}
		
		protected function checkXmlLoadQueue(loadQueueId:String):void
		{
			// On supprime l'id chargé de la liste d'attente
			ArrayUtil.removeItem(_xmlLoadQueue, loadQueueId);
			
			if (_xmlLoadQueue.length > 0) return;
			
			// On prévient qu'on a fini le chargement
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onParamsLoad_error(event:IOErrorEvent):void
		{
			throw "Erreur de chargement des paramètres : " + event.text;
		}
		protected function onDataLoad_error(event:IOErrorEvent):void
		{
			throw "Erreur de chargement des données : " + event.text;
		}
		
		public var _rawParamsXml:XML;
		
		protected function onParamsLoad_complete(event:Event):void
		{
			var paramsXML:XML = (event.currentTarget as XIncludeXMLLoader).xml; //new XML((event.currentTarget as URLLoader).data);
			_rawParamsXml = paramsXML;
			
			// Test de chargement du ParamsHub
			params.feed(paramsXML.params.param);
			/*
			var t:* = params.getNumber('showDebugInfo', 2);
			t = params.getString('version');
			*/
			checkXmlLoadQueue('params');
		}
		
		
		protected function onDataLoad_complete(event:Event):void
		{
			var i:int; var iMax:int;
			var xmlNode:XML;
			var xmlItems:XMLList;
			_loadedXML = (event.target as XIncludeXMLLoader).xml;// new XML(event.currentTarget.data);
			xmlLoaded = true;
			
			// On crée la table des références thématiques pour un traitement plus simple
			var xmlParams:XMLList = _loadedXML.contents;
			
			// Récupération des codes de langue
			var t_languages:Array = [];
			xmlItems = _loadedXML.LANGUAGES.Language;
			for (i=0, iMax = xmlItems.length(); i<iMax; i++)
			{
				xmlNode = xmlItems[i];
				if (xmlNode.hasOwnProperty("@code")) t_languages.push(xmlNode.@code.toString());
			}
			_languages = t_languages;
			
			// Récupération des templates
			xmlItems = _loadedXML.textTemplates.template;
			for (i=0, iMax = xmlItems.length(); i<iMax; i++)
			{
				xmlNode = xmlItems[i];
				if (xmlNode.hasOwnProperty("@id")) 
				{
					templates[xmlNode.@id] = xmlNode.toString();
				}
			}
			
			// Stockage des textes
			textsXmlList = _loadedXML.texts.text;
			
			//  Stockage brut des controles sonores
			soundVolumesXmlList = _loadedXML.soundVolume;
			
			// Tests
			/*
			xmlNode = getTextXmlNode('sampleText02', 'FR');
			var strHtml:String = getText('sampleText01', 'FR');
			strHtml = getText('sampleText02', 'FR', {mot:'kamoulox'});
			strHtml = getText('sampleText02dynamic', 'FR', {mot:'kamoulox', fontSize:33});
			*/
			
			checkXmlLoadQueue('contents');
		}
		
		public function getTextXmlNodes(textId:String, language:String=null):XMLList
		{
			var xmlList:XMLList
			if (language != null) {
				xmlList = textsXmlList.(@id==textId && @language==language);
				if (xmlList.length() == 0) xmlList = null; // résultat non trouvé
			} 
			if (xmlList == null) {
				// le cas language == null est possibel pour les textes d'invitation, affichés avant de connaitre la langue
				// Si la langue n'est pas dans le fichier XML on tombe également ici ce qui permet d'avoir un fallback
				xmlList = textsXmlList.(@id==textId);	
			}
			
			// On asservit la durée des textes à celle de la langue majoritaire
			if (language != null) {
				var langMaj:String = LangageController.instance.userLanguage; 
				if (language != langMaj)
				{
					var newXMLNodes:XMLList = new XMLList();
					var xmlsMajo:XMLList;
					var xmlMajo:XML;
					for each (var xml:XML in xmlList) {
						
						// On cherche l'équivalent dans la lang majoritaire
						if (xml.hasOwnProperty("@part")) {
							xmlsMajo = textsXmlList.(@id==textId && @language==langMaj && @part==xml.@part);
						} else {
							xmlsMajo = textsXmlList.(@id==textId && @language==langMaj);
						}
						if (xmlsMajo.length() > 0) {
							xmlMajo  = xmlsMajo[0];
							if (xmlMajo.hasOwnProperty("@duration"))
								xml.@duration = xmlMajo.@duration;

						} 
						newXMLNodes += xml;
						
					}
					xmlList = newXMLNodes;
				}
			}
			
			if (xmlList.length()) return xmlList;
			else return null;
		}
		
		
		
		public function getTextXmlNode(textId:String, language:String=null):XML
		{
			var xmlList:XMLList = getTextXmlNodes(textId, language);
			if (xmlList == null) return null;
			if (xmlList.length()) return xmlList[0] as XML;
			else return null;
		}
		
		/**
		 * 
		 * @param textId
		 * @param language
		 * @param tokens  Permet de passer des éléments de textes dynamique à 
		 * 				injecter dans le template. Ces éléments seront aussi 
		 * 				bien injectés dans le texte que dans le template 
		 * 				(pour permettre de dynamiquer texte et mise en forme). 
		 * 				Attention la propriété 'text' de tokens sera 
		 * 				systématiquement écrasée, réservée pour injectée le texte.
		 * @return 
		 * 
		 */
		public function getText(textId:String, language:String=null, tokens:Object=null):String
		{
			var out:String = '';
			var xml:XML = getTextXmlNode(textId, language);
			if (xml == null) return out;

			var isHtml:Boolean    = false;
			var templateId:String = null;
			var template:String   = null;
			if (xml.hasOwnProperty("@html"))
			{
				var htmlProp:String = xml.@html;
				htmlProp = htmlProp.toLowerCase();
				isHtml = (["true", "1",1].indexOf(htmlProp) > -1); 
			}
			
			if (xml.hasOwnProperty("@template"))
			{
				templateId = xml.@template;
				template = templates[templateId];
			}
			
			var text:String = xml.toString();
			
			if (tokens != null)
			{
				text = TokenUtil.replaceTokens(text, tokens);
			} else {
				tokens = {};
			}
			tokens.text = text;
			
			if (template != null)
			{
				out = TokenUtil.replaceTokens(template, tokens);
			} else {
				out = text;
			}
			
			return out;
		}
		
		public function isHtml(textId:String, language:String=null):Boolean
		{
			var out:Boolean = false;
			var xml:XML = getTextXmlNode(textId, language);
			if (xml == null) return out;
			
			if (xml.hasOwnProperty("@html"))
			{
				var htmlProp:String = xml.@html;
				htmlProp = htmlProp.toLowerCase();
				out = (["true", "1",1].indexOf(htmlProp) > -1); 
			}
			return out;
		}
		
		
		public function getTemplate(templateID:String):String
		{
			var out:String = templates[templateID] as String;
			return out;
		}
		
		public function applyTemplate(str:String, templateId:String, tokens:Object=null):String
		{
			var out:String;
			if (tokens == null) tokens = {};
			tokens.text = str;
			out = TokenUtil.replaceTokens(str, tokens);
			
			var template:String = templates[templateId];
			if (template != null) {
				out = TokenUtil.replaceTokens(template, tokens);
			}
			return out;
		}
		
		
	}
}