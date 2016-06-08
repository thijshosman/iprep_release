// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

try
{
	// *** workflow ***
	//myStateMachine.changeWorkflowState("SEM")
	//myStateMachine.changeWorkflowState("PECS")
	
	//IPrep_init()
	//IPrep_consistency_check()
	
	//IPrep_image()
	//IPrep_incrementSliceNumber()
	//IPrep_MoveToPECS()

	//IPrep_Pecs_Image_beforemilling()
	//IPrep_mill(1)
	//IPrep_Pecs_Image_aftermilling()
	
	//IPrep_MoveToSEM()
	
	//IPrep_scribemarkVectorCorrection(-0.1,0)
	
	
	

	//IPrep_cleanup()
	
	
	// *** EBSD ***
	//IPrep_acquire_ebsd()
	
	
	
	// *** shutter ***
	//myWorkflow.returnPecs().moveShutterIn()
	//myWorkflow.returnPecs().moveShutterOut()
	
	// check state
	//string value
	//PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_33", value)   //works set cpld bits individually
	//result("TSO = " + value + "\n")
	
	
	// *** gate valve ***
	//myWorkflow.returnPecs().openGVandCheck()
	//myWorkflow.returnPecs().closeGVandCheck()
	
	// *** gripper ***
	//myWorkflow.returnGripper().sendCommand("V300000L1400h0m20j128R")
	//myWorkflow.returnGripper().setManualState("open")
	//myWorkflow.returnGripper().setManualState("closed")
	//myWorkflow.returnGripper().open()		
	//myWorkflow.returnGripper().close()


/*
number i

for (i=0;i<50;i++)
{

	myWorkflow.returnGripper().open()		
	myWorkflow.returnGripper().close()
	result("i: "+i+"\n")
}
*/
	

	
//myWorkflow.returnGripper().lookupState(1)
	//sleep(5)
	//myWorkflow.returnGripper().sendCommand("D100000R")
	
	// *** manual workflow items ***
	//myWorkflow.insertSampleIntoPecsAndRetract()
	
	
	
	
	// *** dock ***
	//myWorkflow.returnSEMDock().setManualState("clamped")
	//myWorkflow.returnSEMDock().setManualState("unclamped")
	
	//myWorkflow.returnSEMDock().unclamp()	//disengaged
	//myWorkflow.returnSEMDock().clamp()   //engaged
	//sleep(3)
	//myWorkflow.returnSEMDock().lookupState(1)
	//result("sample present: "+myWorkflow.returnSEMDock().checkSamplePresent()+"\n")
	// test dock clamping/unclamping
	
	/*
	number i
	for (i=0;i<20;i++)
	{
		myWorkflow.returnSEMDock().unclamp()	//disengaged
		result("arrived at unclamped position, waiting..\n")
		sleep(3)
		myWorkflow.returnSEMDock().clamp()   //engaged
		result("i: "+i+"\n")
	}
	*/
	
	// *** pecs ***
	//myWorkflow.returnPecs().moveStageUp()
	//myWorkflow.returnPecs().moveStageDown()
	//myWorkflow.returnPecs().stageHome()
	//result(myWorkflow.returnPecs().argonCheck()+"\n")
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
	//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")   //turn on chamber illuminator
	//myWorkflow.returnPecs().shutoffArgonFlow()
	//myWorkflow.returnPecs().restoreArgonFlow()
	//PIPS_Execute("STRTPROC0000,process_movetocoat")
	//PIPS_Execute("STRTPROC0000,process_movetoetch")
	//PIPS_StartMilling()
	//PIPS_StopMilling()
	//result(myWorkflow.returnPecs().millingTimeRemaining()+"\n")
	
	// *** parker ***
	//myWorkflow.returnTransfer().init()
	//myWorkflow.returnTransfer().home()
	//myWorkflow.returnTransfer().move("outofway")   // home position, without going through homing sequence
   // myWorkflow.returnTransfer().move("prehome")    // location where we can move to close to home from where we home
    //myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
    //myWorkflow.returnTransfer().move("pickup_pecs") // location where open arms can be used to pickup sample	
	//myWorkflow.returnTransfer().move("beforeGV")    // location where open arms can be used to pickup sample
	//myWorkflow.returnTransfer().move("dropoff_sem") // location where sample gets dropped off (arms will open)
    //myWorkflow.returnTransfer().move("pickup_sem")  // location in where sample gets picked up
    //myWorkflow.returnTransfer().move("backoff_sem") // location where gripper arms can safely open/close in SEM chamber
   // myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
   // myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
    //myWorkflow.returnTransfer().turnOff()  // turn off Parker to stop noise
    //myWorkflow.returnTransfer().move("test")  // test location from tags  
	//result(MyWorkflow.returnTransfer().getCurrentPosition())
	//result(MyWorkflow.returnTransfer().returnParkerPositions().getCurrentPosition())
	//myWorkflow.returnTransfer().resetKillSwitch()


    //result(myWorkflow.returnTransfer().getCurrentPosition())
	//result(myWorkflow.returnTransfer().getCurrentState()+"\n")
	//myWorkflow.returnTransfer().init()
	//myWorkflow.returnTransfer().setMovingParameters()
	//myWorkflow.returnTransfer().sendCommand("ACC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("DEC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("JRK 20.000000")
	//myWorkflow.returnTransfer().sendCommand("VEL 80.000000")

		
	// *** SEM ***
	// homing to clear:
	//myWorkflow.returnSEM().homeToClear()

	// add a coord
	//object aCoord = alloc(SEMCoord)
	//aCoord.set("testcoord3",3.11,2.22,4.33,2.2)
	//result(returnSEMCoordManager().checkCoordExistence("StoredImaging")+"\n")
	//returnSEMCoordManager().addCoord(aCoord)

	//myWorkflow.returnSEM().printCoords()
	//result("wf now: "+myWorkflow.returnSEM().getState()+"\n")
	//myWorkflow.returnSEM().setManualState("clear")
	//myWorkflow.returnSEM().calibrateCoordsFromPickup()
	//myWorkflow.returnSEM().goToClear()
	//myWorkflow.returnSEM().goToPickup_Dropoff()
	//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().goToHighGridBack()
	//myWorkflow.returnSEM().goToHighGridFront()
	//myWorkflow.returnSEM().goToLowerGrid()
	//myWorkflow.returnSEM().goToScribeMark()
	
	// check consistency
	//result("wposition accuracy: "+myWorkflow.returnSEM().checkPositionConsistency("pickup_dropoff")+"\n")
	//result("state consistency: "+myWorkflow.returnSEM().checkStateConsistency()+"\n")
	
	
	// *** imaging ***
//	myStateMachine.start_image()
/*	object myROI 
		string name1 = "StoredImaging"
		if (!returnROIManager().getROIAsObject(name1, myROI))
		{
			print("IMAGE: tag does not exist!")
			
		}
*/
		// Update GMS status bar - SEM imaging started

	//myWorkflow.returnSEM().goToImagingPosition(myROI.getName())
	

//	image temp_slice_im2
//	myWorkflow.returnDigiscan().config()
//	myWorkflow.returnDigiscan().acquire(temp_slice_im2)
//	showimage(temp_slice_im2)
//	myStateMachine.stop_image()  
	
	
	// *** alignment of SEM dropoff/pickup point for parker and sem stage ***
	
	//myWorkflow.PecsToSemAlign()
	//myWorkflow.returnFromSEMAnywhereToPecs()
	
	
	
	// *** mediator ***
	//result("mediator gv: "+myMediator.getGVState()+"\n") // gate valve
	//result("mediator current parker position: "+myMediator.getCurrentPosition()+"\n") // parker
	//result("mediator SEM state: "+myMediator.getSEMState()+"\n") // SEM State
	//result("mediator PECS stage state: "+myMediator.getStageState()+"\n") // getStageState pecs
	//result("mediator FWD coupling: "+myMediator.checkFWDCoupling()+"\n") // 
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
