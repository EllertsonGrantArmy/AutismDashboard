package db
{
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.*;
	
	public class DBProgramItem extends EventDispatcher
	{
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
		
		[Bindable] private var acData:ArrayCollection = new ArrayCollection();
		
		private var dbSitting:DBSitting = new DBSitting();
		
		
		private var programHolder:Program;
		private var programItemsHolder:Vector.<ProgramItem>;
		private var childHolder:Child;
		private var date:Date;
		
		//private var dataObj:Object = new Object();
		
		//Hard coded until login built
		private var therapist:Therapist = new Therapist(1, "Mrs.", "Therapist");
		private var sessions:Vector.<Session>;
		private var count:int = 0;
		
		public function DBProgramItem():void {
			
			programItemsHolder = new Vector.<ProgramItem>();
			
			RO.endpoint = R.roEndPoint;
			RO.source = R.cfcDir + ".ProgramItem";
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
		}
		
		public function requestProgramItems(program:Program, sessions:Vector.<Session>):void {
			
			//trace("requestProgramItems");
			this.programHolder = program;
			this.sessions = sessions;
			
			/** required programid **/
			
			RO.addEventListener(ResultEvent.RESULT, requestProgramItemsResult_EventHandler);	
			RO.getProgramItems(program.id);
		}
		
		protected function requestProgramItemsResult_EventHandler(e:ResultEvent):void {
			
			//data from CF
			acData = ArrayCollection(e.result);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				date = new Date(parseInt(acData[i].DATE));
				acData[i].DATEINTRODUCED = (acData[i].DATEINTRODUCED == "empty") ? null : acData[i].DATEINTRODUCED;
				acData[i].DATEMASTERED = (acData[i].DATEMASTERED == "empty") ? null : acData[i].DATEMASTERED;
				acData[i].DATEGENERALIZED = (acData[i].DATEGENERALIZED == "empty") ? null : acData[i].DATEGENERALIZED;
				acData[i].DATELASTREVIEWED = (acData[i].DATELASTREVIEWED == "empty") ? null : acData[i].DATELASTREVIEWED;
				var pi:ProgramItem = new ProgramItem(acData[i].ID_PROGRAMITEM, programHolder, acData[i].PROMPT, acData[i].RESPONSE, acData[i].COMMENT,
									acData[i].TOREVIEW, acData[i].STAGE, new Date(parseInt(acData[i].DATEINTRODUCED)), new Date(parseInt(acData[i].DATEMASTERED)), new Date(parseInt(acData[i].DATEGENERALIZED)),
									new Date(parseInt(acData[i].DATELASTREVIEWED)), acData[i].CURRENTSTAGEPROGRESS, acData[i].FORCEREVIEW, acData[i].CONSECUTIVEFAILEDREVIEW, 
									null, acData[i].HASTIMER, acData[i].ONHOLD, acData[i].DISABLEDT, acData[i].DISABLERR);
				programItemsHolder.push(pi);
			}
			
			//Need sittings to update programitem objects within programItemsHolder (fill null)
			//trace("requestSittingsLoop");
			for each(pi in programItemsHolder){
				//trace(programItemsHolder.indexOf(pi));
				count++;
				var _dbSitting:DBSitting = new DBSitting();
				_dbSitting.requestSittings(pi, sessions);
				_dbSitting.addEventListener(CustomEvent.ON_LOADED, SittingsDataResult_EventHandler);
			}
			count--;
			//dbSitting.addEventListener(CustomEvent.ON_LOADED, SittingsDataResult_EventHandler);
		}
		
		protected function SittingsDataResult_EventHandler(e:CustomEvent):void {
			
			count--;
			if(e.data.length != 0) {
				
				var sittings:Vector.<Sitting> = e.data;
				var itemId:int = sittings[0].programItem.id;
				
				for each(var pi:ProgramItem in programItemsHolder){	
					
					if(pi.id == itemId) {
						pi.sittings = sittings;
					}
				}
			}
			
			if(count == -1) {
				//dbSitting.removeEventListener(CustomEvent.ON_LOADED, SittingsDataResult_EventHandler);
				//send programItems back to childProgram
				this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, programItemsHolder));
			}
		}
		
		public function updateProgramItem(item:ProgramItem):void 
		{
			/*trace("updateProgramItem()");
			trace(item.id);
			trace(item.stage);
			trace((item.dateIntroduced) ? item.dateIntroduced.valueOf().toString() : "poop");
			trace((item.dateMastered) ? item.dateMastered.valueOf().toString() : "empty");
			trace((item.dateLastReviewed) ? item.dateLastReviewed.valueOf().toString() : "empty");
			trace(item.currentStageProgress);
			trace(item.forceReview);
			trace(item.consecutiveFailedReview);
			trace((item.dateGeneralized) ? item.dateGeneralized.valueOf().toString() : "poop");*/
			RO.addEventListener(ResultEvent.RESULT, updateProgramItemResult_EventHandler);	
			RO.updateProgramItem(item.id, item.stage, 
				(item.dateIntroduced) ? item.dateIntroduced.valueOf().toString() : "empty", 
				(item.dateMastered) ? item.dateMastered.valueOf().toString() : "empty",
				(item.dateLastReviewed) ? item.dateLastReviewed.valueOf().toString() : "empty",
				item.currentStageProgress, 
				(item.forceReview) ? 1 : 0 , item.consecutiveFailedReview, 
				(item.dateGeneralized) ? item.dateGeneralized.valueOf().toString() : "empty");
		}
		
		protected function updateProgramItemResult_EventHandler(e:ResultEvent):void {
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, null));
		}
		
		public function requestProgramItemsById(id:int):void{
			
			RO.addEventListener(ResultEvent.RESULT, requestProgramItemResult_EventHandler);	
			RO.getProgramItemById(id);
		}
		
		protected function requestProgramItemResult_EventHandler(e:ResultEvent):void {
			
			//data from CF
			acData = ArrayCollection(e.result);
			
			//parses through data
			for (var i:int = 0; i < acData.length; i++) {
				
				date = new Date(parseInt(acData[i].DATE));
				programItemsHolder.push(new ProgramItem(acData[i].ID_PROGRAMITEM, programHolder, acData[i].PROMPT, acData[i].RESPONSE, acData[i].COMMENT,
					acData[i].TOREVIEW, acData[i].STAGE, new Date(parseInt(acData[i].DATEINTRODUCED)), new Date(parseInt(acData[i].DATEMASTERED)), new Date(parseInt(acData[i].DATEGENERALIZED)),
					new Date(parseInt(acData[i].DATELASTREVIEWED)), acData[i].CURRENTSTAGEPROGRESS, acData[i].FORCEREVIEW, acData[i].CONSECUTIVEFAILEDREVIEW, 
					null, acData[i].HASTIMER, acData[i].ONHOLD, acData[i].DISABLEDT, acData[i].DISABLERR));
			}
			
			//Need sittings to update programitem objects within programItemsHolder (fill null)
			for each(var pi:ProgramItem in programItemsHolder){
				dbSitting.requestSittings(pi, sessions);
			}
			
			this.dispatchEvent(new CustomEvent(CustomEvent.ON_LOADED, programItemsHolder));
		}
		
		protected function FaultEventError(e:FaultEvent):void {
			
			this.dispatchEvent(new FaultEvent(e.type, true, e.cancelable, e.fault, null, e.message));
			trace("PI Fault " +e.message.toString());
		}
	}
}