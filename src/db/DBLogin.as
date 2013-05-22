package db {
	
	import flash.display.Sprite;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.*;
	import mx.rpc.remoting.RemoteObject;
	
	import pd.Child;
	import pd.CustomEvent;
	
	public class DBLogin extends Sprite {
		
		private var RO:RemoteObject = new RemoteObject("ColdFusion");
//		private var RO:SQLiteLogin;
		public function DBLogin():void {
			RO.endpoint = R.roNewEndPoint;
			RO.addEventListener(FaultEvent.FAULT, FaultEventError);
			RO.source = "TherapyProject.Login";
		}
		
		public function masterLogin(username:String, password:String):void {			
			RO.addEventListener(CustomEvent.ON_LOADED, masterLoginHandler);
			RO.masterLogin(username, password);
		}
		
		private function masterLoginHandler(e:CustomEvent):void {
			RO.removeEventListener(CustomEvent.ON_LOADED, masterLoginHandler);
			
			/*
				Access Levels
				2 - Senior
				3 - Therapist
				4 - Family/Parent
			*/
			var infoObj:Object = e.data;
			var dataObj:Object = new Object();
			
			if(infoObj['result'] == 0) {
				dataObj.valid = false;
			} else {			
				//Assign validity 
				dataObj.valid = true;
				//Assign access
				dataObj.access = infoObj['accessID'];
				//Assign name
				dataObj.fname = infoObj['fname'];
				dataObj.mname = infoObj['mname'];
				dataObj.lname = infoObj['lname'];
				//Assign userID
				dataObj.userID = infoObj['userID'];
				
				//Temp Child Array
				var tempChildArray:ArrayCollection = new ArrayCollection();
				
				//Create Child Objects
				for(var i:int = 0; i < infoObj['children'].length; i++) {
					//infoObj['children'][i] = new Object();
					var child:Child = new Child(infoObj['children'][i][0], infoObj['children'][i][1], infoObj['children'][i][2], infoObj['children'][i][3]);
					tempChildArray.addItem(child);
				}
				
				//Assign children
				if(tempChildArray.length > 0) {
					dataObj.children = tempChildArray;
				}else {
					dataObj.children = null;
				}
			}
			
			//dispatchEvent to login component
			this.dispatchEvent(new CustomEvent("masterLoginEvent", dataObj));
		}
		
		protected function FaultEventError(e:FaultEvent):void {                  
			trace("Fault " +e.message.toString());
		}
	}
}