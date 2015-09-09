// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{

	// *** automated test dovetail 
	
	
	IPrep_setSliceNumber(0)
	image temp_slice_im
	number i
	object my3DvolumePECS = alloc(IPrep_3Dvolume)
	my3DvolumePECS.initPECS_3D(20)	
	//myWorkflow.returnPecs().openGVandCheck()
	myWorkflow.returnTransfer().setPositionTag("beforeGV",100)
	
	for (i = 0; i<=50; i++)
	{
		myWorkflow.returnPecs().moveStageUp()
		myWorkflow.returnPecs().stageHome()
		myWorkflow.returnPecs().ilumOn()
		myWorkflow.returnPecsCamera().acquire(temp_slice_im)
		IPrep_savePECSImage(temp_slice_im, "pecs_camera")
		my3DvolumePECS.addSlice(temp_slice_im)
		my3DvolumePECS.show()	
		IPrep_incrementSliceNumber()
		IPrep_sliceNumber()
		myWorkflow.pickupFromPecsAndMoveToGV()
		myWorkflow.insertSampleIntoPecsAndRetract()
		sleep(20)
	}
	
	myWorkflow.returnPecs().moveStageUp()
	myWorkflow.returnPecs().stageHome()
	myWorkflow.returnPecs().ilumOn()
	myWorkflow.returnPecsCamera().acquire(temp_slice_im)
	IPrep_savePECSImage(temp_slice_im, "pecs_camera")
	my3DvolumePECS.addSlice(temp_slice_im)
	my3DvolumePECS.show()		
	
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
