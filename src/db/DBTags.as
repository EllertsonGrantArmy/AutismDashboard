package db
{	
	import flash.display.Sprite;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.RpcClassAliasInitializer;
	
	import pd.*;
	
	public class DBTags extends Sprite
	{
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var tagList:Array;
		
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
		
		public function DBTags():void {
			RpcClassAliasInitializer.registerClassAliases();
			RO.endpoint = R.roNewEndPoint;
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}				
		
		public function requestTags():void {
			//Make call to CF for child information
			RO.source = "TherapyProject.Video";
			RO.addEventListener(ResultEvent.RESULT, RequestTags_Handler);
			RO.getAllTags();
		}
		
		protected function RequestTags_Handler(e:Object):void {
			//data from CF
			tagList = [];
			//trace(acData.length);
			
			//parses through data
			for (var i:int = 0; i < e.result.length; i++) {				
				tagList[e.result[i][0]] = e.result[i][1];
			}
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, tagList));
			
			//Call to CF for sessions of the child
//			dbSession.requestSessions(new Child(id));
//			dbSession.addEventListener(CustomEvent.ON_LOADED, RequestSessionDataLoaded_EventHandler);
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
		
		protected function FaultEventError(e:Object):void {
			trace(e);
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("Child Fault " +e.message.toString());
		}
	}
}