package pd
{
	import db.DBSitting;
	
	import flash.events.Event;
	
	import mx.rpc.events.FaultEvent;
	
	public class Sitting
	{
		
		private var _id:int;
		private var _programItem:ProgramItem;
		private var _session:Session;
		private var _time:Date;
		private var _trials:String;
		public static var TRIALS_CHANGE_UNDOREDO:String = "trials_change_undoredo";
		
		public function Sitting(id:int, programItem:ProgramItem, session:Session, time:Date, trials:String = "") {
			this._id = id;
			this._programItem = programItem;
			this._session = session;
			if(time.toString() == "Invalid Date")
				this._time = null;
			else
				this._time = time;
			this._trials = trials;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get programItem():ProgramItem
		{
			return _programItem;
		}

		private function set programItem(value:ProgramItem):void
		{
			_programItem = value;
		}

		public function get session():Session
		{
			return _session;
		}

		private function set session(value:Session):void
		{
			_session = value;
		}

		public function get time():Date
		{
			return _time;
		}

		private function set time(value:Date):void
		{
			_time = value;
		}
		
		
		public function get trials():String
		{
			return _trials;
		}

		public function set trials(value:String):void
		{
			this._trials = value;
			var dbSitting:DBSitting = new DBSitting();
			// if the sitting has not yet been added to the db
			if(_id == -1)
			{
				_programItem.program.sittingsUntilReview--;
				_programItem.program.invalidateSittingsToday();
				dbSitting.addSitting(this);
			}
			else
				dbSitting.updateSitting(this);
			dbSitting.addEventListener(FaultEvent.FAULT, updateSittingFaultResponse);
		}
		
		protected function updateSittingFaultResponse(event:FaultEvent):void
		{
			trace("Fault Updating Sitting: " + event.message);
		}
	}
}