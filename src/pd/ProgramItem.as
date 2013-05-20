package pd
{
	import db.DBProgramItem;
	
	import flash.events.Event;

	public class ProgramItem
	{
		/** Defines the value of <code>type</code>
		 * of the event thrown when <code>stage</code>
		 * var changes.
		 * <br><br>
		 * Value is "stageValChanged".
		 */
		public static var STAGE_CHANGE:String = "stageValChanged";
		public static var CUR_STAGE_PROGRESS_CHANGE:String = "curStageProgChanged";
		
		private var _id:int;
		private var _program:Program;
		private var _prompt:String;
		private var _response:String;
		private var _comment:String;
		private var _toReview:Boolean;
		private var _stage:String;
		private var _dateIntroduced:Date = new Date();
		private var _dateMastered:Date;
		private var _dateGeneralized:Date;
		private var _dateLastReviewed:Date;
		private var _currentStageProgress:int;
		private var _forceReview:Boolean;
		private var _consecutiveFailedReview:int;
		private var _sittings:Vector.<Sitting>;
		private var _hasTimer:Boolean;
		private var _onHold:Boolean;
		private var _disableDT:Boolean;
		private var _disableRR:Boolean;
		public var successesBeforeLastFailure:uint = 0;

		public static function get testItem():ProgramItem
		{
			var testDate:Date= new Date();
			var testSittings:Vector.<Sitting> = new Vector.<Sitting>();
			testDate.setDate(20);
			testSittings.push(new Sitting(-1, null, 
				new Session(null, 1, null, 
					new Date(), 0), 
				new Date(), "00101101"));
			testSittings.push(new Sitting(-1, null, 
				new Session(null, 1, null, 
					testDate, 0), 
				testDate, "00101101"));
			var _testItem:ProgramItem = new ProgramItem(
				-1, null, "Example Prompt", "Example Response", "", true, "dt", new Date(), null, null, null,
				1, false, 0, testSittings);
			return _testItem;
		}

		
		public function ProgramItem(id:int, program:Program, prompt:String, response:String, comment:String = "", 
									toReview:Boolean = true, stage:String = "mt", dateIntroduced:Date = null, 
									dateMastered:Date = null, dateGeneralized:Date = null, 
									dateLastReviewed:Date = null, currentStageProgress:int = 0, 
									forceReview:Boolean = false, consecutiveFailedReview:int = 0, 
									sittings:Vector.<Sitting> = null, hasTimer:Boolean = false, onHold:Boolean = false,
									disableDT:Boolean = false, disableRR:Boolean = false) {
			
			this._id = id;
			this._program = program;
			this._prompt = prompt;
			this._response = response;
			this._comment = comment;
			this._toReview = toReview;
			this._stage = stage;
			this.dateIntroduced = dateIntroduced;
			this.dateMastered = dateMastered;
			this.dateGeneralized = dateGeneralized;
			this.dateLastReviewed = dateLastReviewed;
			this._currentStageProgress = currentStageProgress;
			this._forceReview = forceReview;
			this._consecutiveFailedReview = consecutiveFailedReview;
			this._sittings = (sittings != null) ? sittings : new Vector.<Sitting>();
			this._hasTimer = hasTimer;
			this._onHold = onHold;
			this._disableDT = disableDT;
			this._disableRR = disableRR;
		}

		public function get id():int
		{
			return _id;
		}

		private function set id(value:int):void
		{
			_id = value;
		}

		public function get program():Program
		{
			return _program;
		}

		protected function set program(value:Program):void
		{
			_program = value;
		}
		[Bindable]
		public function get prompt():String
		{
			return _prompt;
		}

		private function set prompt(value:String):void
		{
			_prompt = value;
		}

		public function get description():String
		{
			return _comment;
		}

		private function set description(value:String):void
		{
			_comment = value;
		}

		public function get toReview():Boolean
		{
			return _toReview;
		}

		private function set toReview(value:Boolean):void
		{
			_toReview = value;
		}
		
		[Bindable]
		public function get stage():String
		{
			return _stage;
		}

		public function set stage(value:String):void
		{
			if(_stage != value)
			{
				if(value == "rr" &&
					_program.getReviewItemsArrayCollection().length < Child.ITEMS_NEEDED_FOR_RR)
				{
					dateMastered = new Date();
				}
				_stage = value;
//				dispatchEvent(new Event(ProgramItem.STAGE_CHANGE));
				var dbProgItem:DBProgramItem = new DBProgramItem();
				dbProgItem.updateProgramItem(this);
			}
		}
		
		[Bindable]
		public function get dateIntroduced():Date
		{
			return _dateIntroduced;
		}

		public function set dateIntroduced(value:Date):void
		{
			if(value && value.toString() == "Invalid Date")
				_dateIntroduced = null;
			else
				_dateIntroduced = value;
		}

		[Bindable]
		public function get dateMastered():Date
		{
			return _dateMastered;
		}

		public function set dateMastered(value:Date):void
		{
			if(value.toString() == "Invalid Date")
				_dateMastered = null;
			else
				_dateMastered = value;
			//trace(_dateMastered);
		}

		[Bindable]
		public function get dateLastReviewed():Date
		{
			return _dateLastReviewed;
		}

		public function set dateLastReviewed(value:Date):void
		{
			if(value.toString() == "Invalid Date")
				_dateLastReviewed = null;
			else
				_dateLastReviewed = value;
		}
		
		[Bindable(event="currentStageChange")]
		public function get currentStageProgress():int
		{
			return _currentStageProgress;
		}

		public function set currentStageProgress(value:int):void
		{
			if(stage == "rr" && value == 0)
				successesBeforeLastFailure = currentStageProgress;
			_currentStageProgress = value;
			var goal:uint = _program.child[stage+"Goal"];
			if(_currentStageProgress + successesBeforeLastFailure == goal)
			{
				if(stage == "mt")
				{
					if(!disableDT)
					{
						stage = "dt";
						currentStageProgress = 0;
					}
					else if(!disableRR)
					{
						stage = "rr";
						currentStageProgress = 0;
					}
					else
						dateMastered = new Date();
				}
				else if(stage == "dt")
				{
					if(disableRR)
					{
						dateMastered = new Date();
					}
					else
					{
						stage = "rr";
						currentStageProgress = 0;
					}
				}
				else if(stage == "rr")
				{
					dateMastered = new Date();
				}
			}
			//trace("updateProgramItem call");
			var dbProgItem:DBProgramItem = new DBProgramItem();
			dbProgItem.updateProgramItem(this);
		}

		public function get forceReview():Boolean
		{
			return _forceReview;
		}

		public function set forceReview(value:Boolean):void
		{
			_forceReview = value;
		}

		public function get consecutiveFailedReview():int
		{
			return _consecutiveFailedReview;
		}

		public function set consecutiveFailedReview(value:int):void
		{
			_consecutiveFailedReview = value;
		}

		public function get sittings():Vector.<Sitting>
		{
			return _sittings;
		}

		public function set sittings(value:Vector.<Sitting>):void
		{
			_sittings = value;
		}

		public function get dateGeneralized():Date
		{
			return _dateGeneralized;
		}

		public function set dateGeneralized(value:Date):void
		{
			if(value && value.toString() == "Invalid Date")
				_dateGeneralized = null;
			else
				_dateGeneralized = value;
		}
		
		[Bindable]
		public function get response():String
		{
			return _response;
		}

		public function set response(value:String):void
		{
			_response = value;
		}

		public function get hasTimer():Boolean
		{
			return _hasTimer;
		}

		public function set hasTimer(value:Boolean):void
		{
			_hasTimer = value;
		}

		public function get onHold():Boolean
		{
			return _onHold;
		}

		public function set onHold(value:Boolean):void
		{
			_onHold = value;
		}
		
		[Bindable]
		public function get disableDT():Boolean
		{
			return _disableDT;
		}

		public function set disableDT(value:Boolean):void
		{
			_disableDT = value;
		}
		
		[Bindable]
		public function get disableRR():Boolean
		{
			return _disableRR;
		}

		public function set disableRR(value:Boolean):void
		{
			_disableRR = value;
		}

//		public override function toString():String
//		{
//			return "id " + _id + " |prompt " + _prompt + " |program.id " + _program.id;
//		}
	}
}