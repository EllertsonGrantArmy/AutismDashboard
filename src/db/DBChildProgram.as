package db
{
	import flash.display.*;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.*;
	
	public class DBChildProgram extends Sprite
	{
		
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var acData:ArrayCollection = new ArrayCollection();
		
		private var dbProgramItem:DBProgramItem = new DBProgramItem();
		
		//Holders
		private var childHolder:Child;
		private var sessionsHolder:Vector.<Session>;
		private var programsHolder:Vector.<Program> = new Vector.<Program>();
		
		private var count:int = 0;
		
		public function DBChildProgram():void {
			
			RO.source = R.cfcDir + ".ChildProgram";
			RO.endpoint = R.roEndPoint;
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}
		
		public function requestPrograms(child:Child, sessions:Vector.<Session>):void {
			
			//trace("requestPrograms(" + child.id);
			this.childHolder = child;
			this.sessionsHolder = sessions;
			
			//Make call to get program information
			RO.addEventListener(ResultEvent.RESULT, requestProgramsResult_EventHandler);	
			//trace("getChildPrograms");
			RO.getChildPrograms(child.id);
			
		}
		
		protected function requestProgramsResult_EventHandler(e:ResultEvent):void {
						
			//trace("getChildPrograms");
			//data from CF
			acData = ArrayCollection(e.result);
			//trace("requestProgramsResult_EventHandler " + acData.length);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				var programHolder:Program = new Program(acData[i].ID_CHILDPROGRAM, childHolder, acData[i].TITLE, acData[i].DESCRIPTION, 
												acData[i].COMPLETED, acData[i].TOREVIEW, new Date(parseInt(acData[i].DATEADDED)), 
												new Date(parseInt(acData[i].DATEINTRODUCED)), acData[i].REVIEWINDEX, 
												acData[i].SITTINGSUNTILREVIEW, acData[i].STAGE, 
												null, acData[i].ONHOLD);
				programsHolder.push(programHolder);
			}
			
			//Need programItems to update program objects within programsHolder (fill null)
			/*for each(var p:Program in programsHolder){
				dbProgramItem.requestProgramItems(p, sessionsHolder);
			}
			
			dbProgramItem.addEventListener(CustomEvent.ON_LOADED, RequestProgramItemsLoaded_EventHandler);
			*/
			for each(var p:Program in programsHolder){
				count++;
				var _dbProgramItem:DBProgramItem = new DBProgramItem();
				_dbProgramItem.requestProgramItems(p, sessionsHolder);
				_dbProgramItem.addEventListener(CustomEvent.ON_LOADED, RequestProgramItemsLoaded_EventHandler);
			}
			count--;
		}
		
		protected function RequestProgramItemsLoaded_EventHandler(e:CustomEvent):void {
			
			//trace("RequestProgramItemsLoaded_EventHandler" + count);
			count--;
			if(e.data.length != 0) {
				
				var programItems:Vector.<ProgramItem> = e.data;
				var itemId:int = programItems[0].program.id;
				
				for each(var p:Program in programsHolder){					
					if(p.id == itemId) {
						//trace("here");
						p.items = programItems;
					}
				}
			}
			
			if(count == -1) {
				dbProgramItem.removeEventListener(CustomEvent.ON_LOADED, RequestProgramItemsLoaded_EventHandler);
				//Send programs back to Child
				this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, programsHolder));
			}
			//else
			//	trace("count != -1");
		}
		
		public function requestProgram(id:int):void {
			
			RO.addEventListener(ResultEvent.RESULT, requestProgramResult_EventHandler);	
			RO.getChildProgram(id);
		}
		
		protected function requestProgramResult_EventHandler(e:ResultEvent):void {
			
			//data from CF
			acData = ArrayCollection(e.result);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				if(acData[i].DATEINTRODUCED != "") {
					
					programsHolder.push(new Program(acData[i].ID_CHILDPROGRAM, childHolder, acData[i].TITLE, acData[i].DESCRIPTION, 
						acData[i].COMPLETED, acData[i].TOREVIEW, new Date(parseInt(acData[i].DATEADDED)), 
						new Date(parseInt(acData[i].DATEINTRODUCED)), acData[i].REVIEWINDEX, 
						acData[i].SITTINGSUNTILREVIEW, acData[i].STAGE, 
						null, acData[i].ONHOLD));
				} else {
					programsHolder.push(new Program(acData[i].ID_CHILDPROGRAM, childHolder, acData[i].TITLE, acData[i].DESCRIPTION, 
						acData[i].COMPLETED, acData[i].TOREVIEW, new Date(parseInt(acData[i].DATEADDED)), 
						null, acData[i].REVIEWINDEX, 
						acData[i].SITTINGSUNTILREVIEW, acData[i].STAGE, 
						null, acData[i].ONHOLD));
				}
			}
			
			//Need programItems to update program objects within programsHolder (fill null)
			for each(var p:Program in programsHolder){
				dbProgramItem.requestProgramItems(p, sessionsHolder);
			}
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, programsHolder));
		}
		
		public function updateProgram(program:Program):void {
			
			RO.addEventListener(ResultEvent.RESULT, updateProgramResult_EventHandler);	
			RO.updateChildProgram(
				program.id, 
				program.sittingsUntilReview, 
				program.reviewIndex, 
				(program.dateIntroduced) ? program.dateIntroduced.valueOf().toString() : "empty", 
				program.completed);
		}
		
		protected function updateProgramResult_EventHandler(e:ResultEvent):void {
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, e.result));
		}
		
		protected function FaultEventError(e:FaultEvent):void {
			
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("CP Fault " +e.message.toString());
		}
	}
}