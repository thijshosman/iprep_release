// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try 
{
	// manual stuff
	//myStateMachine.changeWorkflowState("PECS")
	//myWorkflow.returnPecs().moveStageDown()
	
	// set SEM state to imaging manually
	//result(myWorkflow.returnSEM().getState())
	//myWorkflow.returnSEM().setManualState("imaging")

	//myWorkflow.preImaging()
	//image temp_slice_im	
	//myWorkflow.returnDigiscan().acquire(temp_slice_im)	
	
	//image temp_slice_im
	//myWorkflow.returnPecs().ilumOn()
	//myWorkflow.returnPecsCamera().acquire(temp_slice_im)
	//showimage(temp_slice_im)
	//myWorkflow.returnPecs().moveStageUp()
	
	//manual imaging
	//myWorkflow.returnSEM().blankOff()
	//myWorkflow.returnSEM().setkVForImaging()
	//myWorkflow.returnSEM().setWDForImaging()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().setMag(4000)
	//myWorkflow.returnDigiscan().config(1024,1024,2)



	
	
	
	// running actual sample
	
	// init
	//Iprep_init()
	// setting up things manually before
	// setup imaging parameters after zooming and viewing ROI
	//IPrep_setup_imaging()
	//IPrep_StoreCurrentSEMPosition()
	// OR
	//IPrep_StoreSEMPositionAsStoredImaging(7.33,-19.342,45.7419)
	//myWorkflow.returnSEM().setWDForImaging()
	
	// loop:	
	
	//turn on beam
	//IPrep_image()
	//turn off beam
	
	//IPrep_incrementSliceNumber()
	//IPrep_MoveToPECS_protected()
	//IPrep_mill(1)
	//IPrep_MoveToSEM_protected()
	//myWorkflow.returnSEM().setManualState("imaging")
	
	// end loop
	
	// run check
	//result(IPrep_continous_check())

	/*
	// test: beam on/ off causes misalignement
	IPrep_setSliceNumber(0)
	number i
	for (i=0; i<6; i++)
	{myWorkflow.returnSEM().HVOn()
		myWorkflow.returnSEM().goToClear()
		myWorkflow.returnSEMDock().goUp()
		myWorkflow.returnSEMDock().goDown()
		myWorkflow.returnSEM().goToNominalImaging()
		IPrep_image()
		IPrep_incrementSliceNumber()
		//myWorkflow.returnSEM().HVOff()
		//sleep(20)
		

		//	}
	*/



	// *** workflow items high level
	// actual main iprep functions
	
	//myPecsCamera.init()
	//myPecsCamera.acquire()
	//IPrep_image()
	//IPrep_mill(0)
	//IPrep_MoveToSEM_protected()
	//IPrep_MoveToPECS_protected()
	
	
	// *** testing digiscan imaging on front grid as stored imaging point
	//myWorkflow.returnSEM().goToHighGridFront()
	//IPrep_StoreCurrentSEMPosition()
	//IPrep_setup_imaging()
	//IPrep_image()
	//IPrep_incrementSliceNumber()
	
	//image im2
	//myWorkflow.executeImagingStep(im2)
	//showimage(im2)
	
	//myWorkflow.returnDigiscan().acquire(im2)
	//showimage(im2)
	
	// *** positioning SEM
	//
	//IPrep_StoreSEMPositionAsStoredImaging(5.39262,-18.7724,45.7419)
	//
	//IPrep_StoreCurrentSEMPosition()	
	//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().goToHighGridBack()
	//myWorkflow.returnSEM().goToHighGridFront()
	//myWorkflow.returnSEM().goToLowerGrid()
	
	
	
	
	// *** misc
	//Iprep_saveImage("digiscan")
	//myWorkflow.returnSEMDock().init()
	//myWorkflow.returnSEMDock().setManualState("Up")
	//myWorkflow.returnSEMDock().goUp()
	//result(myWorkflow.returnSEMDock().sendCommand("?4")+"\n")
	//myWorkflow.returnSEMDock().goDown()
	//myWorkflow.returnSEMDock().lookupState(1)
	//myWorkflow.returnSEMDock().sendCommand("P3000R")
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")