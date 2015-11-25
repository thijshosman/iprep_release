// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

try
{
	
	
	
	// *** dock ***
	//myWorkflow.returnSEMDock().setManualState("clamped")
	//myWorkflow.returnSEMDock().setManualState("unclamped")
	
	//myWorkflow.returnSEMDock().unclamp()	//disengaged
	//myWorkflow.returnSEMDock().clamp()   //engaged
	//sleep(3)
	//myWorkflow.returnSEMDock().lookupState(1)
	//result("sample present: "+myWorkflow.returnSEMDock().checkSamplePresent()+"\n")
	// test dock clamping/unclamping
	//result(myWorkflow.returnSEMDock().detectMode()+"\n")

	
}
catch
{
	result( GetExceptionString() + "\n" )
}


result("done with execution, idle\n\n")
