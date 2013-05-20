package db
{
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.*;
	
	public class DBSession extends Sprite
	{	
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var acData:ArrayCollection = new ArrayCollection();
		
		private var sessionHolder:Session;
		private var childHolder:Child;
		private var date:Date;
		
		//private var dataObj:Object = new Object();
		
		//Hard coded until login built
		private var therapist:Therapist = new Therapist(1, "Mrs.", "Therapist");
		
		public function DBSession():void {
			
			RO.endpoint = R.roEndPoint;
			RO.source = R.cfcDir + ".Session";
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}
		
		public function addSession(session:Session):void {
			
			//trace("AddSession");
			
			//pass by reference
			sessionHolder = session;
			
			RO.addEventListener(ResultEvent.RESULT, addSessionResult_EventHandler);	
			RO.addSession(session.child.id, therapist.id, session.date.valueOf().toString(), session.index);
		}
		
		protected function addSessionResult_EventHandler(e:ResultEvent):void {
			
			sessionHolder.id = int(e.result);
			
			//no return of data needed
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sessionHolder));
		}
		
		public function requestSessions(child:Child):void {
			
			//trace("requestSessions");
			childHolder = child;
			
			RO.addEventListener(ResultEvent.RESULT, requestSessionsResult_EventHandler);	
			RO.getSessions(child.id);
		}
		
		protected function requestSessionsResult_EventHandler(e:ResultEvent):void {
			
			//data from CF
			acData = ArrayCollection(e.result);
			
			//Vector<Session>
			var sessions:Vector.<Session> = new Vector.<Session>();
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				date = new Date(parseInt(acData[i].DATE));
				sessions.push(new Session(childHolder, acData[i].ID_SESSION, therapist, date, acData[i].INDEX));
			}
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sessions));
		}
		
		public function requestSession(id:int):void {
			
			RO.addEventListener(ResultEvent.RESULT, requestSessionResult_EventHandler);	
			RO.getSessionById(id);
		}
		
		protected function requestSessionResult_EventHandler(e:ResultEvent):void {
			
			//data from CF
			acData = ArrayCollection(e.result);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				date = new Date(parseInt(acData[i].DATE));
				sessionHolder = new Session(childHolder, acData[i].ID_SESSION, therapist, date, acData[i].INDEX);
			}
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sessionHolder));
		}
		
		public function updateSession(session:Session):void {
			
			RO.addEventListener(ResultEvent.RESULT, updateSessionResult_EventHandler);	
			RO.updateSession(session.id, session.index);
		}
		
		protected function updateSessionResult_EventHandler(event:ResultEvent):void {
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, null));
		}
		
		public function getNextIndex():void {

		}
		
		protected function FaultEventError(e:FaultEvent):void {
			
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("Session Fault " +e.message.toString());
		}
	}
}