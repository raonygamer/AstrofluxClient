package core.states
{
	public interface IDisplayState
	{
		function enter() : void;
		
		function execute() : void;
		
		function exit() : void;
		
		function get type() : String;
		
		function set stateMachine(sm:DisplayStateMachine) : void;
	}
}

