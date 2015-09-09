//$BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{
//myWorkflow.returnPecs().openGVandCheck()		
//myWorkflow.returnPecs().moveStageDown()
//myWorkflow.returnPecs().stageHome()
	//myWorkflow.pickupFromPecsAndMoveToGV()
	myWorkflow.insertSampleIntoPecsAndRetract()
		// test
		//result(myWorkflow.returnPecs().getStageState())
		//goToNominalImaging()
		//myWorkflow.returnTransfer().setManualState("outofway")
		//myStateMachine.changeWorkflowState("SEM")
		//myWorkflow.returnSEMDock().goDown()
		//myWorkflow.returnGripper().setManualState("open")
//myWorkflow.returnGripper().open()		
//myWorkflow.returnGripper().close()
//myWorkflow.returnGripper().sendCommand("gP20000R")
		//result("wf now state is: "+myWorkflow.returnSEM().getState()+"\n")
		//myWorkflow.returnSEM().goToNominalImaging()
		//myWorkflow.pickupFromPecsAndMoveToGV()
//myWorkflow.returnTransfer().home()		
		//myWorkflow.returnTransfer().move("beforeGV")
		//myWorkflow.returnTransfer().move("outofway")
		//iprep_init()	
		//myWorkflow.returnPecs().moveStageUp()
		//myWorkflow.returnPecs().stageHome()
		//myWorkflow.returnPecs().ilumOn()
		/*
		myWorkflow.returnSEM().setMag(2000)
		//EMSetMagnification(4000)
		//sleep(1)
		
		image temp_slice
		myWorkflow.returnDigiscan().config(3)
		myWorkflow.returnDigiscan().acquire(temp_slice)
		showimage(temp_slice)
		*/
		/*
		myWorkflow.returnSEM().setMag(4000)
		sleep(1)
	
		number alignParamID1 = DSCreateParameters( 2048, 2048, 0, 1, 0 )

		image temp_slice_im2
		myWorkflow.returnDigiscan().config(alignParamID1)
		myWorkflow.returnDigiscan().acquire(temp_slice_im2)
		showimage(temp_slice_im2)
		
		DSDeleteParameters( alignParamID1 )
		
	*/
		//myWorkflow.returnPecsCamera().acquire(temp_slice_im)
		//number camID = CameraGetActiveCameraID( )
		//temp_slice_im := CameraAcquire( camID , 0.00051)
		//myWorkflow.returnTransfer().move("outofway")
		
		
		//IPrep_Setup_Imaging()
		//showimage(temp_slice_im)
		//IPrep_StoreCurrentSEMPosition()
		//IPrep_StoreSEMPositionAsStoredImaging(5.39262,-18.7724,45.7419)
		//IPrep_image()
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")

