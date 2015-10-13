// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()


try
{
	// *** workflow ***
	//myStateMachine.changeWorkflowState("SEM")
	//myStateMachine.changeWorkflowState("PECS")
	
	// *** gate valve ***
	//myWorkflow.returnPecs().openGVandCheck()
	//myWorkflow.returnPecs().closeGVandCheck()
	
	// *** gripper ***
	//myWorkflow.returnGripper().setManualState("open")
	//myWorkflow.returnGripper().setManualState("closed")
	//myWorkflow.returnGripper().open()		
	//myWorkflow.returnGripper().close()
	
	// *** manual workflow items ***
	//myWorkflow.insertSampleIntoPecsAndRetract()
	
	
	// *** dock ***
	//myWorkflow.returnSEMDock().setManualState("open")
	//myWorkflow.returnSEMDock().setManualState("closed")
	
	//myWorkflow.returnSEMDock().unclamp()	//disengaged
	//myWorkflow.returnSEMDock().clamp()   //engaged
	//sleep(3)
	//myWorkflow.returnSEMDock().lookupState(1)
	
	// test dock clamping/unclamping
	
	
	number i
	for (i=0;i<20;i++)
	{
		myWorkflow.returnSEMDock().unclamp()	//disengaged
		result("arrived at unclamped position, waiting..\n")
		sleep(3)
		myWorkflow.returnSEMDock().clamp()   //engaged
		result("i: "+i+"\n")
	}
	
	
	// *** pecs ***
	//myWorkflow.returnPecs().moveStageUp()
	//myWorkflow.returnPecs().moveStageDown()
	//result(IPrep_continous_check()+"\n")
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
	//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")   //turn on chamber illuminator
	
	// *** parker ***
	//myWorkflow.returnTransfer().init()
	//myWorkflow.returnTransfer().home()
	//myWorkflow.returnTransfer().move("outofway")   // home position, without going through homing sequence
    //myWorkflow.returnTransfer().move("prehome")    // location where we can move to close to home from where we home
    //myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
    //myWorkflow.returnTransfer().move("pickup_pecs") // location where open arms can be used to pickup sample	
	//myWorkflow.returnTransfer().move("beforeGV")    // location where open arms can be used to pickup sample
	//myWorkflow.returnTransfer().move("dropoff_sem") // location where sample gets dropped off (arms will open)
    //myWorkflow.returnTransfer().move("pickup_sem")  // location in where sample gets picked up
    //myWorkflow.returnTransfer().move("backoff_sem") // location where gripper arms can safely open/close in SEM chamber
    //myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
    //myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
    //myWorkflow.returnTransfer().turnOff()  // turn off Parker to stop noise
    // myWorkflow.returnTransfer().move("test")  // test location from tags  


    //result(myWorkflow.returnTransfer().getCurrentPosition())
	//result(myWorkflow.returnTransfer().getCurrentState()+"\n")
	//myWorkflow.returnTransfer().init()
	//myWorkflow.returnTransfer().setMovingParameters()
	//myWorkflow.returnTransfer().sendCommand("ACC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("DEC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("JRK 20.000000")
	//myWorkflow.returnTransfer().sendCommand("VEL 80.000000")

		
	// *** SEM ***
	//myWorkflow.returnSEM().printCoords()
	//result("wf now: "+myWorkflow.returnSEM().getState()+"\n")
	//myWorkflow.returnSEM().setManualState("imaging")
	//myWorkflow.returnSEM().calibrateCoordsFromPickup()
	//myWorkflow.returnSEM().goToClear()
	//myWorkflow.returnSEM().goToPickup_Dropoff()
	//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().goToHighGridBack()
	//myWorkflow.returnSEM().goToHighGridFront()
	//myWorkflow.returnSEM().goToLowerGrid()
	//myWorkflow.returnSEM().goToScribeMark()
	//result(myWorkflow.returnSEM().checkPositionConsistency("pickup_dropoff")+"\n")
	//result(myWorkflow.returnSEM().checkStateConsistency()+"\n")
	
	
	// *** imaging ***
	//number alignParamID1 = DSCreateParameters( 512, 512, 0, 16, 0 )
	//image temp_slice_im2
	//myWorkflow.returnDigiscan().config(alignParamID1)
	//myWorkflow.returnDigiscan().acquire(temp_slice_im2)
	//showimage(temp_slice_im2)
	
	
	
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
