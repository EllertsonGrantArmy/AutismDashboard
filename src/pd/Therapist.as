package pd
{
	public class Therapist
	{
		
		private var _id:int;
		private var _fName:String;
		private var _lName:String;
		
		public function Therapist(id:int, fName:String, lName:String) {
			this._id = id;
			this._fName = fName;
			this._lName = lName;
		}

		public function get id():int
		{
			return _id;
		}

		private function set id(value:int):void
		{
			_id = value;
		}

		public function get fName():String
		{
			return _fName;
		}

		private function set fName(value:String):void
		{
			_fName = value;
		}

		public function get lName():String
		{
			return _lName;
		}

		private function set lName(value:String):void
		{
			_lName = value;
		}

		public function get initals():String
		{
			return (_fName.charAt(0)+_lName.charAt(0)).toUpperCase();
		}


	}
}