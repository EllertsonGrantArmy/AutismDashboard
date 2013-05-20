package db
{
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.*;

	public class DBSitting extends Sprite
	{
		
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var acData:ArrayCollection = new ArrayCollection();
		
		private var sittingHolder:Sitting;
		private var programItemHolder:ProgramItem;
		private var sessionsHolder:Vector.<Session>;
		private var sittingsHolder:Vector.<Sitting>;
		private var date:Date;
		
		public function DBSitting():void {
			
			sessionsHolder = new Vector.<Session>();
			sittingsHolder = new Vector.<Sitting>();
			
			RO.endpoint = R.roEndPoint;
			RO.source = R.cfcDir + ".Sitting";
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}
		
		public function addSitting(sitting:Sitting):void {
			
			sittingHolder = sitting;
			
			RO.addEventListener(ResultEvent.RESULT, addSittingResult_EventHandler);	
			RO.addSitting(sitting.programItem.id, sitting.session.id, sitting.trials, sitting.time.valueOf().toString());
		}
		
		protected function addSittingResult_EventHandler(e:ResultEvent):void {
			
			sittingHolder.id = int(e.result);
			
			//no return of data needed
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sittingHolder));
		}
		
		public function requestSitting(id:int):void {
			
			RO.addEventListener(ResultEvent.RESULT, requestSittingResult_EventHandler);	
			RO.getSitting(id);
		}
		
		protected function requestSittingResult_EventHandler(e:ResultEvent):void {

			//data from CF
			acData = ArrayCollection(e.result);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				date = new Date(parseInt(acData[i].DATE));
				//sittingHolder = new Sitting(acData[i].ID_SITTING, new Program(), new Session(), date, acData[i].TRIALS));
			}
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sittingHolder));
		}
		
		public function requestSittings(programItem:ProgramItem, sessions:Vector.<Session>):void {
			
			this.programItemHolder = programItem;
			this.sessionsHolder = sessions;
			
			RO.addEventListener(ResultEvent.RESULT, requestSittingsResult_EventHandler);	
			RO.getSittings(programItem.id);
		}
		
		protected function requestSittingsResult_EventHandler(e:ResultEvent):void {
			
			//data from CF - all sittings for program
			acData = ArrayCollection(e.result);			
			
			for each(var s:Session in sessionsHolder) {
				for (var i:int = 0; i < acData.length; i++) {
					if(s.id == acData[i].ID_SESSION){
						date = new Date(parseInt(acData[i].DATE));
						sittingsHolder.push(new Sitting(acData[i].ID_SITTING, programItemHolder, s, 
													date, acData[i].TRIALS));
					}
				}
			}
			
			//send sittings back to programItem
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, sittingsHolder));
		}
		
		public function updateSitting(sitting:Sitting):void {
			
			RO.addEventListener(ResultEvent.RESULT, updateSittingResult_EventHandler);	
			RO.updateSitting(sitting.id, sitting.trials);
		}
		
		protected function updateSittingResult_EventHandler(e:ResultEvent):void {
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, e.result));
		}
		
		protected function FaultEventError(e:FaultEvent):void {
			
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("Sitting Fault " +e.message.toString());
		}
	}
}