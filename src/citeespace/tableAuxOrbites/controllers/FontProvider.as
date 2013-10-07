package citeespace.tableAuxOrbites.controllers {
	import flash.text.Font;

	public class FontProvider {
	
		[Embed(source='../font/fonts.swf', symbol="UniversLTStd57BoldCondensed")]
		public var UniversLTStd57BoldCondensed:Class;
		[Embed(source='../font/fonts.swf', symbol="UniversCondensedMediumItalic")]
		public var UniversCondensedMediumItalic:Class;
		[Embed(source='../font/fonts.swf', symbol="UniversCondensedMedium")]
		public var UniversCondensedMedium:Class;
		[Embed(source='../font/fonts.swf', symbol="UniversCondensedBoldItalic")]
		public var UniversCondensedBoldItalic:Class;
		[Embed(source='../font/fonts.swf', symbol="UniversCondensedBold")]
		public var UniversCondensedBold:Class;
		[Embed(source='../font/fonts.swf', symbol="UniversLTStd67BoldCondensedOblique")]
		public var UniversLTStd67BoldCondensedOblique:Class;
		
		public function FontProvider() 
		{
			new UniversLTStd57BoldCondensed();
			new UniversCondensedMediumItalic();
			new UniversCondensedMedium();
			new UniversCondensedBoldItalic();
			new UniversCondensedBold();
			new UniversLTStd67BoldCondensedOblique();
			
		}
	}
}