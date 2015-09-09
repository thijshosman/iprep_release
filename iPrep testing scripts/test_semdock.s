// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{
	number i

	for (i=0; i<200; i++)
	{
		result(i+"\n")
		myWorkflow.returnSEMDock().goUp()	
		sleep(60)
		myWorkflow.returnSEMDock().goDown()
		sleep(60)
	}

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")

