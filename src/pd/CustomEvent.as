package pd
{
	import flash.events.Event;
	
	public class CustomEvent extends Event
	{			
		public static const ON_LOADED:String = "OnLoaded"; //———– Define your custom Event string constant
		public var data:*; //————- Define a data variable of * type to hold any kind of data object
		
		public function CustomEvent(type:String, data:*) {
			
			this.data = data;
			super(type);
		}
	}
}