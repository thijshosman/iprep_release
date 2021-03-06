// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

number j

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
	//IPrep_mill(1)
	//IPrep_MoveToSEM()
	//IPrep_scribemarkVectorCorrection(-0.1,0)
	//myWorkflow.returnPECSCamera().liveView()
	//IPrep_cleanup()

	//if(!IPrep_check())
	//	{
	//		string popuperror = "check failed, check log. cannot start"
	//		okdialog(popuperror)
	//	}
	
////////////////////	
// *** TESTS *** ///
////////////////////
	
	// test dovetail insertion repeatability pecs
/*	
	for (j=0; j<20; j++)
	{

		if(IPrep_Pecs_Image_aftermilling()!=1)
		{	
			debug("pecs imaging failed failed, check log\n")
			break
		}
		
		IPrep_incrementSliceNumber()
	
		if (IPrep_reseat()!= 1)
		{	
			debug("reseating failed, check log\n")
			break
		}


		debug("iteration: "+j+"\n")
		sleep(2)
		if (optiondown() && shiftdown())
			break
	}
*/

	// test communication with PECS/BING
	
/*
	number j
	string value1, value2, value3
	for (j=0; j<1; j++)
	{
		number tick = GetOSTickCount()
		
		//GET check TSO
		PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_33", value1)   //works set cpld bits individually
		//GET GV
		PIPS_GetPropertyDevice("subsystem_milling", "device_cpld", "bit_38", value2)
		// GET argon
		PIPS_GetPropertyDevice("subsystem_pumping", "device_gasPressure", "read_pressure_status", value3)
		//SET move shutter in
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_23", "1")
		//SET move shutter out
		sleep(1)
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_23", "0")
		//SET ilum on
		PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")
		PIPS_SetPropertyDevice("subsystem_milling", "device_mfcLeft", "set_gas_flow", "0.01")
		number tock = GetOSTickCount()
		result(j+": values: = " + value1+", "+value2+", "+value3 + ", time = "+(tock-tick)+" ms \n")
		//sleep(1)
		
	}
	
*/

	// test gripper functionality
/*
	number i

	for (i=0;i<10;i++)
	{

		try
		{
			//myWorkflow.returnGripper().close_once()	
			myWorkflow.returnGripper().open()		
			myWorkflow.returnGripper().close()
			myWorkflow.returnGripper().lookupState(1)
			myWorkflow.returnGripper().lookupStateNTimes(5)
		}
		catch
		{
			result( GetExceptionString() + "\n" )
			break
		}
		result("i: "+i+"\n")
		sleep(1)
	}
*/



	
	// reseating test dovetail

/*
	number i

	for (i=0;i<10;i++)
	{
		if ((optiondown() && shiftdown()))
			break
			
		if (IPrep_reseat() != 1)
		{
			debug("problem happened, stopping\n")
			break
		}
		if (myWorkflow.returnTransfer().killSwitchEngaged())
		{
			debug("killswitch engaged\n")
			break
		}
		
		//sleep(5)
		debug("i: "+i+"\n")
	}
*/	

	// dock clamping/unclamping

/*
	number i
	for (i=0;i<20;i++)
	{
		myWorkflow.returnSEMDock().unclamp()	//disengaged
		result("arrived at unclamped position, waiting..\n")
		sleep(1)
		myWorkflow.returnSEMDock().clamp()   //engaged
		if (!myWorkflow.returnSEMdock().checkSamplePresent())
		{	
			okdialog("sample not detected!")
			break
		}
		result("i: "+i+"\n")
	}

*/
	// test how well focus is kept when moving z
	// setup
/*
	
	// NB: make sure to load the "image_test" imaging sequence and set the sem position to the right coordinates	
	// add sem position with name "testImagingRepeat"
	//IPrep_addSEMPosition()
	
	// save focus
	// autofocus

	myWorkflow.returnSEM().goToImagingPosition("testImagingRepeat")
	
	myWorkflow.returnSEM().blankOff()
	IPrep_autofocus()
	myWorkflow.returnSEM().blankOn()
	
	myWorkflow.returnSEM().setDesiredWDToCurrent()
*/	
/*
	// loop
	number i
	for (i=0;i<10;i++)
	{
		
	
		// restore focus
		//myWorkflow.returnSEM().setWDForImaging()
		
		// take image
		IPrep_image()
		
		// increment slice number 
		IPrep_incrementSliceNumber()
		
		// move z by going to clear
		myWorkflow.returnSEM().goToClear()
		
		// go to nominal imaging
		myWorkflow.returnSEM().goToNominalImaging()
		

		debug("i: "+i+"\n")
		sleep(2)
		if (optiondown() && shiftdown())
			break
	}

*/


	// test PECS etching/coating
/*
	// go to etch
	myWorkflow.returnPECS().goToEtchMode()
	okdialog("system should be in ETCH mode. continue?")

	// go to coat
	myWorkflow.returnPECS().goToCoatMode()
	okdialog("system should be in COAT mode. continue?")

	// go to etch
	myWorkflow.returnPECS().goToEtchMode()
	okdialog("system should be in ETCH mode. continue?")

*/

// *** recover from closing gripper on way to pecs 20161208 ***

/*	
	myWorkflow.returnSEM().goToClear()
	myWorkflow.returnTransfer().move("beforeGV")  
	myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
    myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
	myWorkflow.returnGripper().open()	
	myWorkflow.returnTransfer().move("open_pecs")
	myWorkflow.returnGripper().close()
	myWorkflow.returnTransfer().home()
	myWorkflow.returnSEMDock().clamp()
	myWorkflow.returnPecs().closeGVandCheck()
	myStateMachine.changeWorkflowState("PECS")
*/	

// *** recover from closing gripper on way to sem 20161209 ***

/*	
	myWorkflow.returnGripper().open()	
	myWorkflow.returnTransfer().move("backoff_sem")  
	myWorkflow.returnSEM().goToClear()
	myWorkflow.returnGripper().close()
	myWorkflow.returnTransfer().move("beforeGV") 
	myWorkflow.returnTransfer().home()
	myWorkflow.returnSEMDock().clamp()
	myWorkflow.returnPecs().closeGVandCheck()
	myWorkflow.returnSEM().goToNominalImaging()
	myStateMachine.changeWorkflowState("SEM")
	
*/	


/////////////////////////////	
// *** Workflow Items *** ///
/////////////////////////////

	
	// *** gate valve ***
	//myWorkflow.returnPecs().openGVandCheck()
	//myWorkflow.returnPecs().closeGVandCheck()

	// *** EBSD ***
	//IPrep_acquire_ebsd()
	
	// *** shutter ***
	//myWorkflow.returnPecs().moveShutterIn()
	//myWorkflow.returnPecs().moveShutterOut()
		
	// *** gripper ***
	//myWorkflow.returnGripper().init()
	//myWorkflow.returnGripper().sendCommand("V300000L1400h0m25j64R")
	//myWorkflow.returnGripper().setManualState("open")
	//myWorkflow.returnGripper().setManualState("closed")
	//sleep(3)
	//myWorkflow.returnGripper().lookupState(1)
	//myWorkflow.returnGripper().open()		
	//myWorkflow.returnGripper().close()
	//myWorkflow.returnGripper().lookupState(1)
	//myWorkflow.returnGripper().lookupStateNTimes(5)
	
	//myWorkflow.returnGripper().sendCommand("P10000R") // close a bit (P)
	//myWorkflow.returnGripper().sendCommand("D10000R")
	
	//result("sensor number: "+myWorkflow.returnGripper().readSensor()+"\n")
	//myWorkflow.returnGripper().lookupState(1)


	
	// *** dock ***
	//myWorkflow.returnSEMDock().setManualState("clamped")
	//myWorkflow.returnSEMDock().setManualState("unclamped")
	
	//myWorkflow.returnSEMDock().unclamp()	//disengaged
	//myWorkflow.returnSEMDock().clamp()   //engaged
	//sleep(3)
	//myWorkflow.returnSEMDock().lookupState(1)
	//result("sample present: "+myWorkflow.returnSEMDock().checkSamplePresent()+"\n")
	// test dock clamping/unclamping
	//myWorkflow.returnSEMDock().camOn()
	//myWorkflow.returnSEMDock().camOff()
	//myWorkflow.returnSEMDock().unhold()
	
	
	// *** pecs ***
	//myWorkflow.returnPecs().moveStageUp()
	//myWorkflow.returnPecs().moveStageDown()
	//myWorkflow.returnPecs().stageHome()
	//myWorkflow.returnPecs().ilumOn()
	//result(myWorkflow.returnPecs().argonCheck()+"\n")
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
	//PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")   //turn on chamber illuminator
	//myWorkflow.returnPecs().shutoffArgonFlow()
	//myWorkflow.returnPecs().restoreArgonFlow()
	
	// move to coating
	//PIPS_Execute("STRTPROC0000,process_movetocoat")
	//PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,1")    //coating mode
		
	// move to etch
	//PIPS_Execute("STRTPROC0000,process_movetoetch")	
	//PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,0")     //etching mode
	
	//sleep(2)
	//PIPS_StartMilling()
	//PIPS_StopMilling()
	//result(myWorkflow.returnPecs().millingTimeRemaining()+"\n")
	
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
    //myWorkflow.returnTransfer().move("test")  // test location from tags  
	//result(MyWorkflow.returnTransfer().getCurrentPosition())
	//result(MyWorkflow.returnTransfer().returnParkerPositions().getCurrentPosition())
	//myWorkflow.returnTransfer().resetKillSwitch()
	//print("killswittch state: "+myWorkflow.returnTransfer().killSwitchEngaged()) // killswitch engaged
		

    //result(myWorkflow.returnTransfer().getCurrentPosition())
	//result(myWorkflow.returnTransfer().getCurrentState()+"\n")
	//myWorkflow.returnTransfer().init()
	//myWorkflow.returnTransfer().setMovingParameters()
	//myWorkflow.returnTransfer().sendCommand("ACC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("DEC 50.000000")
	//myWorkflow.returnTransfer().sendCommand("JRK 20.000000")
	//myWorkflow.returnTransfer().sendCommand("VEL 80.000000")

		
	// *** SEM ***
	// align all positions in SEM the hack way to planar dock
	//IPrep_align_planar_hack()
	//object reference = returnSEMCoordManager().getCoordAsCoord("reference_planar")
	//reference.print()
	
	//WorkaroundQuantaMagBug()
	
	// homing to clear (no pop ups):
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
	
	//myWorkflow.returnSEM().HVOn()
	
	//myWorkflow.returnSEM().uncoupleFWD() // doesn't work on quanta, works on nova
	//myWorkflow.returnSEM().coupleFWD()

	//print("current mag: "+myWorkflow.returnSEM().measureMag())
	


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
