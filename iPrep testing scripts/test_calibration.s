// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{


	// *** SEM to PECS
	//myWorkflow.removeSampleFromSEM()
		// unfolded:
		//myWorkflow.returnPecs().moveStageDown()
		//myWorkflow.returnPecs().stagehome()
		//myWorkflow.returnTransfer().move("beforeGV")
		//myWorkflow.returnSEM().goToClear()
		//myWorkflow.returnSEMDock().goUp()
		//myWorkflow.returnSEM().goToPickup_Dropoff()
		//myWorkflow.returnPecs().openGVandCheck()
		//myWorkflow.returnTransfer().move("backoff_sem")
		//myWorkflow.returnGripper().open()
		//myWorkflow.returnTransfer().move("pickup_sem")
		//myWorkflow.returnGripper().close()
		//myWorkflow.returnSEM().goToClear()
		//myWorkflow.returnTransfer().move("beforeGV")
		//myWorkflow.returnPecs().closeGVandCheck()
		//myWorkflow.returnSEMDock().goDown()
	//myWorkflow.insertSampleIntoPecsAndRetract()
	

	// *** PECS to SEM
	//myWorkflow.pickupFromPecsAndMoveToGV()
	//myWorkflow.insertIntoSEM()
		// unfolded:
		//myWorkflow.returnPecs().openGVandCheck()
		//myWorkflow.returnSEM().goToClear()	
		//myWorkflow.returnSEMDock().goUp()
		//myWorkflow.returnTransfer().move("dropoff_sem")
		// safety wait
		//myWorkflow.returnSEM().goToPickup_Dropoff()	
		//myWorkflow.returnGripper().open()
		//myWorkflow.returnTransfer().move("backoff_sem")
		//myWorkflow.returnGripper().close()
		//myWorkflow.returnSEM().goToClear()	
		//myWorkflow.returnSEMDock().goDown()
		//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.retractArmAfterDropoff()
		// unfolded:
		//myWorkflow.returnTransfer().move("open_pecs")
		//myWorkflow.returnTransfer().home()
		//myWorkflow.returnPecs().closeGVandCheck()


	//myWorkflow.returnSEMDock().sendCommand("T")
	//myWorkflow.returnSEMDock().setManualState("up")
	
	//number i = 0
	//while (i<3) 
	//{
	//	myWorkflow.returnSEMDock().goDown()
	//	myWorkflow.returnSEMDock().goUp()
	//	i++
	//}
	//myWorkflow.returnSEMDock().goDown()
	//myWorkflow.returnSEMDock().goUp()
	// testing beam operations, works
	//myWorkflow.returnSEM().HVOff()
	//myWorkflow.returnSEM().blankOff()


	// check of argon pressure sensor check works
	//result(myWorkflow.returnPecs().argonCheck())




	// SEM positioning
	//myWorkflow.returnSEM().printCoords()
	//result("wf now state is: "+myWorkflow.returnSEM().getState()+"\n")
	//myWorkflow.returnSEM().setManualState("imaging")
	//myWorkflow.returnSEM().calibrateCoordsFromPickup()
	//myWorkflow.returnSEM().goToClear()
	//myWorkflow.returnSEM().goToPickup_Dropoff()
	//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().goToHighGridBack()
	//myWorkflow.returnSEM().goToHighGridFront()
	//myWorkflow.returnSEM().goToLowerGrid()
	
	// manual overrides
	//myWorkflow.returnGripper().setManualState("open")
	//myWorkflow.returnGripper().close()
	//myWorkflow.returnGripper().open()
	
	//myWorkflow.returnPecs().moveStageUp()
	//myWorkflow.returnPecs().stageHome()
	

	
	
	
	
	
	/*number i = 0
	
	while(i<10)
	{
		myWorkflow.pickupFromPecsAndMoveToGV()
		myWorkflow.insertSampleIntoPecsAndRetract()
		i++
		result("i: "+i+"\n")
	}
	*/
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
