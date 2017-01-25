// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

number j

try
{

	for (j=0;j<5;j++)
	{
		// test repeatability of SEM stage in z by moving back and forth between grid and clear. 
		// we need to figure out what the repeatability of the z stage is. compare AF to no AF
		// take image using default DS settings every time
		myWorkflow.returnSEM().goToClear()
		myWorkflow.returnSEM().goToNominalImaging()
		myWorkflow.returnSEM().goToHighGridBack()
		
		// position on area of highgridback that is in the center of one of the grids
		myWorkflow.returnSEM().goToImagingPosition("test_z_focus_grid")
		

		// exp1: no autofocus

		// take image
		//IPrep_image()

		// exp2: autofocus
		IPrep_autofocus_complete()
		IPrep_image()

		IPrep_IncrementSliceNumber()
		// print current settings: 
		debug("image number: "+IPrep_sliceNumber()+", current z: "+myWorkflow.returnSEM().getZ()+", current focus: "+myWorkflow.returnSEM().measureWD()+"\n")
		result("step: "+j+"\n")

		
		if(optiondown())
			break
		
	}

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")







