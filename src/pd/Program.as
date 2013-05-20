package pd
{
	import db.DBChildProgram;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;

	public class Program extends EventDispatcher {
		
		/**
		 *  Number of items to be mastered to allow 
		 * <code>sittingsUntilReview</code> drop to 
		 * 0, starting an aquisition review.
		 */
		public const ITEMS_NEEDED_FOR_REVIEW:int = 3;
		/**
		 * Value that <code>sittingsUntilReview</code> 
		 * will be reset to.
		 */
		private const SITTINGS_BETWEEN_REVIEWS:int = 5;
		
		
		private var _id:int;
		private var _child:Child;
		private var _title:String;
		private var _description:String;
		private var _stage:int;
		private var _completed:Boolean;
		private var _toReview:Boolean;
		private var _dateAdded:Date;
		private var _dateIntroduced:Date;
		private var _reviewIndex:int;
		private var _sittingsUntilReview:int;
		private var _items:Vector.<ProgramItem>;
		private var _onHold:Boolean;
		private var _sittingsToday:int = -1;
		private var invalidData_sittingToday:Boolean = true;
		
		public function Program(id:int, child:Child, title:String, description:String, 
								completed:Boolean, toReview:Boolean, dateAdded:Date, 
								dateIntroduced:Date, reviewIndex:int, 
								sittingsUntilReview:int, stage:int, 
								items:Vector.<ProgramItem>, onHold:Boolean = false) 
		{
			this._id = id;
			this._child = child;	
			this._title = title;
			this._description = description;
			this._stage = stage;
			this._completed = completed;
			this._toReview = toReview;
			this._dateAdded = dateAdded;
			this._dateIntroduced = dateIntroduced;
			this._reviewIndex = reviewIndex;
			this._sittingsUntilReview = sittingsUntilReview;
			this.items = items;
			this._onHold = onHold;
			
			//trace("sittings until review: " + sittingsUntilReview);
		}

		public function get child():Child
		{
			return _child;
		}

		private function set child(value:Child):void
		{
			_child = value;
		}

		public function get title():String
		{
			return _title;
		}

		private function set title(value:String):void
		{
			_title = value;
		}

		public function get description():String
		{
			return _description;
		}

		private function set description(value:String):void
		{
			_description = value;
		}

		public function get stage():int
		{
			return _stage;
		}

		private function set stage(value:int):void
		{
			_stage = value;
		}

		public function get completed():Boolean
		{
			return _completed;
		}

		public function set completed(value:Boolean):void
		{
			_completed = value;
		}

		public function get toReview():Boolean
		{
			return _toReview;
		}

		private function set toReview(value:Boolean):void
		{
			_toReview = value;
		}

		public function get dateAdded():Date
		{
			return _dateAdded;
		}

		private function set dateAdded(value:Date):void
		{
			_dateAdded = value;
		}

		public function get dateIntroduced():Date
		{
			return _dateIntroduced;
		}

		public function set dateIntroduced(value:Date):void
		{
			_dateIntroduced = value;
		}

		public function get reviewIndex():int
		{
			return _reviewIndex;
		}

		public function set reviewIndex(value:int):void
		{
			_reviewIndex = value;
		}
		
		[Bindable]
		/**
		 * Number of sittings until Program review.
		 * Will reset to <code>SITTINGS_BETWEEN_REVIEW</code>
		 * if there are not enough mastered items in the
		 * program.<br/><br/>
		 * 
		 * Typically will only be decremented.
		 */
		public function get sittingsUntilReview():int
		{
			return _sittingsUntilReview;
		}

		public function set sittingsUntilReview(value:int):void
		{
			//trace("new sittingsUntilReview: " + value);
			if(_sittingsUntilReview != value)
			{
				if(value <= 0 && getReviewItemsArrayCollection().length < ITEMS_NEEDED_FOR_REVIEW)
				{
					value = SITTINGS_BETWEEN_REVIEWS;
				}
				_sittingsUntilReview = value;
				var dbCP:DBChildProgram  = new DBChildProgram();
				dbCP.updateProgram(this);
			}
		}

		public function get items():Vector.<ProgramItem>
		{
			return _items;
		}

		public function set items(value:Vector.<ProgramItem>):void
		{
			this._items = new Vector.<ProgramItem>();
			for each(var i:ProgramItem in value)
			{
				if(i != null)
					_items.push(i);
				//trace(_title + " | " + i.prompt);
			}
		}

		public function get onHold():Boolean
		{
			return _onHold;
		}

		public function set onHold(value:Boolean):void
		{
			_onHold = value;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}
		/**
		 * Mark <code>sittingsToday</code> to be
		 * recalculated. Dispatches databind event.
		 */
		public function invalidateSittingsToday():void
		{
			invalidData_sittingToday = true;
			var _nothing:int = this.sittingsToday;
			dispatchEvent(new Event("sittingsTodayChange"));
		}
		
		[Bindable(event="sittingsTodayChange")]
		public function get sittingsToday():int
		{
			if(invalidData_sittingToday)
			{
				var time:Number = getTimer();
				var count:int = 0;
				for each(var sitting:Sitting in currentItem.sittings)
				{
					if(sitting.trials.length != 0 && DateFunctions.isToday(sitting.session.date))
						count++;
				}
				sittingsToday = count;
				invalidData_sittingToday = false;
				//trace ("time to calculate sittings today: " + (getTimer()-time));
			}
			return _sittingsToday;
		}
		
		public function set sittingsToday(value:int):void
		{
			_sittingsToday = value;
		}
		
		public function get currentItem():ProgramItem
		{
			//TODO FIX ME
			if(_items.length == 0)
				return null;
			//return _items[0];
			//trace("currentItem " + items.length);
			var i:uint = 0;
			while(i < items.length - 1 && items[i] != null && items[i].dateIntroduced != null)
			{
				//trace(items[i].dateIntroduced);
				i++;
			}
			if(i != 0 && items[i-1].dateMastered == null)
				i--;
			//trace("i: " + i);
			return items[i];
		}
		
		[Bindable]
		/**
		 * <code>currentItemTitle</code> could return
		 * one of two things, either the <code>title</code> 
		 * of <code>currentItem</code> or string
		 * "Next sitting will be a review."
		 */
		public function get currentItemTitle():String
		{
			if(sittingsUntilReview > 0)
			{
				var curItem:ProgramItem = currentItem;
				if(curItem == null)
					return "No current items.";
				else
					return currentItem.prompt;
				
			}
			else
				return "Next sitting will be a review.";
		}
		
		protected function set currentItemTitle(value:String):void
		{
			
		}
		
		public function inReviewState():Boolean
		{
			for each (var item:ProgramItem in _items)
			{
				if(item.dateMastered == null)
					return false;
			}
			return true;
		}
		
		override public function toString():String
		{
			return id + " |title " + _title;
		}
		
		/**
		 * Creates an <code>ArrayCollection</code> of <code>pd:Item</code>s
		 * to be reviewed.
		 */
		public function getReviewItemsArrayCollection():ArrayCollection
		{
			var reviewItemsArrayCollection:ArrayCollection = new ArrayCollection();
			for each(var item:ProgramItem in items)
			{
				if(item.dateMastered != null)
					reviewItemsArrayCollection.addItem(item);
			}
			return reviewItemsArrayCollection;
		}
	}
}