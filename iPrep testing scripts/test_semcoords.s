// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

try
{


	// adding a semcoord
	//object aCoord = alloc(SEMCoord)
	//aCoord.set(newROIname,x,y,z)
	//returnSEMCoordManager().addCoord(aCoord)
	//aCoord.print()
	//result("saved position "+newROIname+"\n\n")

//result(myWorkflow.returnSEM().getX())




}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")