// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

number i,n=5
result(datestamp()+"\n")
for (i=0; i<n; i++)
{
	result("  "+i+": ")
	myWorkflow.returnSEMDock().lookupState(1)

}

result("\n")
