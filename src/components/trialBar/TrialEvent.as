package components.trialBar
{
	import flash.events.Event;
	
	public class TrialEvent extends Event
	{
		public static var TRIAL_PLUS:String = "trialPlus";
		public static var TRIAL_MINUS:String = "trialMinus";
		
		public function TrialEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}