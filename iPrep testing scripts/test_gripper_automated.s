// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

try
{
	// *** automated test for gripper ***
	

	// first move to a safe plase, from home (assumed)
	myWorkflow.returnTransfer().move("open_pecs")

	// now run test
	number i
	for (i=0;i<5;i++)
	{

		myWorkflow.returnGripper().open()
		sleep(10)		
		myWorkflow.returnGripper().close()
		debug("i: "+i+"\n")
		sleep(10)
		if (optiondown() & shiftdown())
			break
	}
	
	myWorkflow.returnTransfer().home()

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
