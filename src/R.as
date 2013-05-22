package
{
	/** a static class for building global vars
	 */
	public final class R
	{
		public static const logoSrc:String = "resources/logobilinier.png";
		[Embed(source="resources/headerBack.gif")]
		public static const headerBack:Class;
		
		[Embed(source="resources/starIcon.png")]
		public static const starIcon:Class;
		[Embed(source="resources/unstarIcon.png")]
		public static const unstarIcon:Class;
		[Embed(source="resources/checkIcon.png")]
		public static const checkIcon:Class;
		[Embed(source="resources/uncheckIcon.png")]
		public static const uncheckIcon:Class;
		
		[Embed(source="resources/leftArrowInactive.png")]
		public static const leftArrowInactive:Class;
		[Embed(source="resources/leftArrowActive.png")]
		public static const leftArrowActive:Class;
		[Embed(source="resources/rightArrowInactive.png")]
		public static const rightArrowInactive:Class;
		[Embed(source="resources/rightArrowActive.png")]
		public static const rightArrowActive:Class;
		[Embed(source="resources/wrenchIcon.png")]
		public static const wrench:Class;
		
		[Embed(source="resources/leftSingleArrow.png")]
		public static const leftSingleArrow:Class;
		[Embed(source="resources/leftDoubleArrow.png")]
		public static const leftDoubleArrow:Class;
		[Embed(source="resources/rightSingleArrow.png")]
		public static const rightSingleArrow:Class;
		[Embed(source="resources/rightDoubleArrow.png")]
		public static const rightDoubleArrow:Class;

		[Embed(source="resources/plusIcon.png")]
		public static const plusIcon:Class;
		[Embed(source="resources/plusIconWShaddow.png")]
		public static const plusIconWShaddow:Class;
		[Embed(source="resources/minusIconWShaddow.png")]
		public static const minusIconWShaddow:Class;
		[Embed(source="resources/grayPlusIcon.png")]
		public static const grayPlusIcon:Class;
		[Embed(source="resources/grayMinusIcon.png")]
		public static const grayMinusIcon:Class;

		[Embed(source="resources/arrowExpanded.png")]
		public static const arrowExpanded:Class;

		public static const font_utsaahLoc:String = "resources/UTSAAH.TTF";
		public static const font_utsaahBoldLoc:String = "resources/UTSAAH.TTF";
		public static const font_utsaahItalicLoc:String = "resources/UTSAAH.TTF";
		public static const font_utsaahBoldItalicLoc:String = "resources/UTSAAH.TTF";
		
		
		// colors
		public static const selectedRowColor:uint = 0x787878;
		public static const backgroundColor:uint = 0xf0f0f0;
		public static const borderColor:uint = 0xb3b3b3;
		public static const darkBorderColor:uint = 0x7c7c7c;
		//globalColors
		public static const LIGHT_BLUE:uint = 0x73e3ff;
		public static const tile_color:uint = LIGHT_BLUE;
		public static var roEndPoint:String = "http://wdmdsrv1.uwsp.edu/flex2gateway/";
		public static var roNewEndPoint:String = "http://prenticetech-com.securec53.ezhostingserver.com/flex2gateway/";
		public static var cfcDir:String = "MobileAutism.AutismTwo.DataEntry.CFC.";
		
		// animated gif's
		[Embed(source="resources/loader.gif")]
		public static const loaderGif:Class;
	}
}