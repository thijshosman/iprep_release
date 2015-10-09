// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()


try
{

	// *** sem coordinate stuff ***
	
	// create the tags
	// myWorkflow.setDefaultSEMPositions() // run only once
	
	// calibrate the SEM for for dock (simulator)
	//myWorkflow.returnSEMdock().calibrateCoords()

	// *** workflow ***
	//myStateMachine.changeWorkflowState("SEM")
	//myStateMachine.changeWorkflowState("PECS")
	
	// *** dead safe flags ***
	//returnDeadFlag().setAliveSafe()
	//returnDeadFlag().checkAliveAndSafe()





// temp debugging

//myStateMachine.start_mill(0, 8000)
//image im
//acquire_PECS_image( im )
//im.showimage()
//myWorkflow.init()


// *** init when DM starts
	//Iprep_init()

	// *** main
	//IPrep_RunPercentCompleted()
	//IPrep_GetStatus()
	//IPrep_End_Imaging()
	//IPrep_IncrementSliceNumber()
	//IPrep_Mill()
	//IPrep_Image()
	//IPrep_StopRun()
	//IPrep_ResumeRun()
	//IPrep_PauseRun()
	//IPrep_StartRun()
	//IPrep_MoveToSEM()
	//IPrep_MoveToPECS()
	//IPrep_foobar()
	//IPrep_Setup_Imaging()
	//IPrep_cleanup()
	//IPrep_Align()
	//IPrep_Abort()
	

	//IPrep_setSliceNumber(3)
	//result("current slice: "+IPrep_sliceNumber()+"\n")

	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
