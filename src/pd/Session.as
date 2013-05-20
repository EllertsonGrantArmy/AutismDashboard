package pd
{
	import mx.binding.utils.ChangeWatcher;

	public class Session
	{
		private var _child:Child;
		private var _id:int;
		private var _therapist:Therapist;
		private var _date:Date;
		private var _index:int;
		
		public function Session(child:Child, id:int, therapist:Therapist, date:Date, index:int) {
			this._child = child;
			this._id = id;
			this._therapist = therapist;
			this._date = date;
			this._index = index;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get therapist():Therapist
		{
			return _therapist;
		}

		private function set therapist(value:Therapist):void
		{
			_therapist = value;
		}

		public function get date():Date
		{
			return _date;
		}

		private function set date(value:Date):void
		{
			_date = value;
		}

		public function get index():int
		{
			return _index;
		}

		public function set index(value:int):void
		{
			_index = value;
		}
		
		[Bindable]
		public function get child():Child
		{
			return _child;
		}

		public function set child(value:Child):void
		{
			_child = value;
		}



	}
}