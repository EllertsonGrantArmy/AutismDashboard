package
{
	import pd.*;

	/** a static class with sorting functions.
	 */
	public class SortingClass
	{
		/** 
		 * 
		 * @param sittings The vector filled with all of the sittings
		 * to be grouped
		 * 
		 * @return a 2D array where each inner array are the sittings 
		 * for a session. Where oldest is first in both dimentions
		 */
		public static function sortSittingsBySession(sittings:Vector.<Sitting>):Array
		{
			var sittingsGroupedBySession:Array = new Array();
			for each(var loopSitting:Sitting in sittings)
			{
				//trace("loopSitting: " + loopSitting);
				var added:Boolean = false;
				
				// for each array of sittings already grouped by session 
				var _length:uint = sittingsGroupedBySession.length;
				for (var i:uint = 0; i < _length; i++)
				{
					var array:Array = sittingsGroupedBySession[i] as Array;
					// comp is -1 if priviously added sitting is less than the sitting we 
					// are currently looping on.
					var comp:int = DateFunctions.compareOnDay(Sitting(array[0]).session.date,
						loopSitting.session.date);
					if(comp > 0)
					{
						// current index is of a later date
						//trace("current index is of a later date");
						var _tempArray:Array = sittingsGroupedBySession.slice(0,i);
						_tempArray.push([loopSitting]);
						//_tempArray.concat(sittingsGroupedBySession.slice(i));
						for(i; i<sittingsGroupedBySession.length; i++)
							_tempArray.push(sittingsGroupedBySession[i]);
						sittingsGroupedBySession = _tempArray;
						added = true;
						break;
					}
						// Date the same
					else if(comp == 0)
					{
						//trace("Date the same");
						if(Sitting(array[0]).session == loopSitting.session)
						{
							// Now put sitting in the correct spot in the array of sittings
							// for this session
							for(var j:uint = 0; j < array.length; j++)
							{
								var arraySitting:Sitting = array[j] as Sitting;
								if(arraySitting.time > loopSitting.time)
								{
									_tempArray = array.slice(0,j);
									_tempArray.push(loopSitting);
									_tempArray.concat(array.slice(j));
									array = _tempArray;
									added = true;
									break;
								}
							}
							if(!added)
							{
								array.push(loopSitting);
								added = true;
							}
						}
					}
				}
				if(!added)
					sittingsGroupedBySession.push([loopSitting]);
				
			}
			return sittingsGroupedBySession;
		}
	}
}