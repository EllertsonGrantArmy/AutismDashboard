package
{
	public class DateFunctions
	{
		/**@param date1 first date to compare
		 * @param date2 second date to compare
		 * 
		 * @return true if the dates have the same
		 * day, month, and year.
		 */
		public static function sameDay(date1:Date, date2:Date):Boolean
		{
			return (date1.fullYear == date2.fullYear && 
				date1.month == date2.month &&
				date1.date == date2.date);
		}
		
		/** Compares two Date objects based only on date
		 * 
		 * 	@return <ul>
		 * <li>0 if they have the same date</li>
		 * <li>1 if first Date is earlier</li>
		 * <li>-1 if first Date is later</li>
		 * </ul>
		 */
		public static function compareOnDay(a:Object, b:Object):int
		{
			var _a:Date = a as Date;
			var _b:Date = b as Date;
			
			if(sameDay(_a, _b))
				return 0;
			if(_a < _b)
				return -1;
			return 1;
		}
		
		/** Builds string in form 8/31/2011 from Date */
		public static function toAmericanString(date:Date):String
		{
			return (date.month + 1) + "/" + date.date + "/" + date.fullYear;
		}
		
		/** @return true if <code>date</code> has the same
		 * date as today.
		 */
		public static function isToday(date:Date):Boolean
		{
			return sameDay(date, new Date());
		}
	}
}