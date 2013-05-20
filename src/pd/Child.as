package pd
{
	import mx.collections.ArrayList;

	public class Child
	{
		/**
		 * Number of items to be mastered to allow a
		 * <code>ProgramItem</code> enter random
		 * rotation.
		 */
		public static var ITEMS_NEEDED_FOR_RR:int = 2;
		
		private var _id:int;
		private var _fName:String;
		private var _lName:String;
		private var _mtGoal:int;
		private var _dtGoal:int;
		private var _rrGoal:int;
		private var _programs:Vector.<Program>;
		private var _sessions:Vector.<Session>;

		/**
		 * All properties of a child are read-only, 
		 * this object is for storing data of a 
		 * child, not editing it.
		 */
		public function Child(id:int, fName:String = "", lName:String = "", mtGoal:int = 3, 
							  dtGoal:int = 5, rrGoal:int = 10, programs:Vector.<Program> = null) 
		{
			this._id = id;
			this._fName = fName;
			this._lName = lName;
			this._mtGoal = mtGoal;
			this._dtGoal = dtGoal;
			this._rrGoal = rrGoal;
			this._programs = programs;
			this._sessions = new Vector.<Session>();
		}

		public function get id():int
		{
			return _id;
		}

		private function set id(value:int):void
		{
			_id = value;
		}

		[Bindable]
		public function get fName():String
		{
			return _fName;
		}

		private function set fName(value:String):void
		{
			_fName = value;
		}
	
		[Bindable]
		public function get lName():String
		{
			return _lName;
		}

		private function set lName(value:String):void
		{
			_lName = value;
		}
		
		[Bindable]
		public function get mtGoal():int
		{
			return _mtGoal;
		}

		private function set mtGoal(value:int):void
		{
			_mtGoal = value;
		}
		[Bindable]
		public function get dtGoal():int
		{
			return _dtGoal;
		}

		private function set dtGoal(value:int):void
		{
			_dtGoal = value;
		}
		[Bindable]
		public function get rrGoal():int
		{
			return _rrGoal;
		}

		private function set rrGoal(value:int):void
		{
			_rrGoal = value;
		}

		public function get programs():Vector.<Program>
		{
			return _programs;
		}

		private function set programs(value:Vector.<Program>):void
		{
			_programs = value;
		}
		
		public function get acquisitionPrograms():Vector.<Program>
		{
			var _value:Vector.<Program> = new Vector.<Program>();
			for each(var prog:Program in _programs)
			{
				if(prog.items.length != 0 && !prog.onHold && !prog.inReviewState())
					_value.push(prog);
			}
			return _value;
		}

		public function get sessions():Vector.<Session>
		{
			return _sessions;
		}

		public function set sessions(value:Vector.<Session>):void
		{
			_sessions = value;
		}
		
		public function getMasteredProgramItems():Vector.<ProgramItem>
		{
			var completeProgramItems:Vector.<ProgramItem> = new Vector.<ProgramItem>();
			for each (var p:Program in this._programs) {
				for each(var pi:ProgramItem in p.items) {
					if(pi.dateMastered != null)
						completeProgramItems.push(pi);
				}
			}
			return completeProgramItems;
		}
	}
}