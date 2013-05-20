package db
{	
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.*;
	
	public class DBChild extends Sprite
	{
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var acData:ArrayCollection = new ArrayCollection();
		
		private var dbChildProgram:DBChildProgram = new DBChildProgram();
		private var dbSession:DBSession = new DBSession();
		
		//Child Parameter Variables - Need as placeholders to create child
		private var id:int;
		private var fName:String;
		private var lName:String;
		private var mtGoal:int;
		private var dtGoal:int;
		private var rrGoal:int;
		private var programs:Vector.<Program>;
		
		//Child Holder Object
		public var childHolder:Child;
		
		//Programs Holder Object
		private var programsHolder:Vector.<Program>;
		private var sessionsHolder:Vector.<Session>;
		
		private var dataBool:Boolean = false;
		
		public function DBChild():void {
			RO.endpoint = R.roEndPoint;
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}				
		
		public function requestChild(id:int):void {
			
			//trace("DBChild.requestChild(" + id + ");");
			//Make call to CF for child information
			RO.source = R.cfcDir + ".Children";
			RO.addEventListener(ResultEvent.RESULT, RequestChildInfoResult_EventHandler);
			RO.getChildByID(id);
		}
		
		protected function RequestChildInfoResult_EventHandler(e:ResultEvent):void {
			//data from CF
			acData = ArrayCollection(e.result);
			//trace(acData.length);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {				
				
				//data returned
				id = acData[i].ID_CHILD;
				fName = acData[i].FNAME;
				lName = acData[i].LNAME;
				mtGoal = acData[i].MTGOAL;
				dtGoal = acData[i].DTGOAL;
				rrGoal = acData[i].RRGOAL;
			}
			//trace("child!!!: " +acData);
			
			//Call to CF for sessions of the child
			dbSession.requestSessions(new Child(id));
			dbSession.addEventListener(CustomEvent.ON_LOADED, RequestSessionDataLoaded_EventHandler);
		}
		
		protected function RequestSessionDataLoaded_EventHandler(e:CustomEvent):void {
			
			//set sessions holder to the sessions retrieved from CF for the child selected
			sessionsHolder = e.data;			
			
			//Call to ChildProgram for programs of the child who is picked by the therapist 
			dbChildProgram.requestPrograms(new Child(id), sessionsHolder);
			dbChildProgram.addEventListener(CustomEvent.ON_LOADED, RequestProgramDataLoaded_EventHandler);
		}
		
		protected function RequestProgramDataLoaded_EventHandler(e:CustomEvent):void {
						
			//trace("DBChild.RequestProgramDataLoaded_EventHandler()");
			
			//set programs holder to the programs retrieved from CF for the child selected
			programsHolder = e.data;
			
			childHolder = new Child(id, fName, lName, mtGoal, dtGoal, rrGoal, programsHolder);
			childHolder.sessions = sessionsHolder;
			//trace("sessions.length: " + childHolder.sessions.length);
			
			//send child to app
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, childHolder));
		}
		
		protected function FaultEventError(e:FaultEvent):void {
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("Child Fault " +e.message.toString());
		}
	}
}