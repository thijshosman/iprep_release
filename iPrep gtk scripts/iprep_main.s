// $BACKGROUND$

// this file contains function definitions. needs to be installed with other hardware class 
// scripts as library

number XYZZY = 0	// set to 1 to enable TH workflow

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myPW = returnMediator().returnPW()


//object myPW = alloc(progressWindow) //#todo migrate to mediator
// convention for progresswindow:
// A: sample status
// B: operation
// C: slice number



// forward declare main loop
interface I_IPrep_mainloop
{
	object init(object self, number p1);
	void incrementi(object self);
	void seti(object self, number newi);
	number geti(object self);
	void runthread(object self);
}

// main loop
object myLoop = alloc(IPrep_mainloop)

// *** methods available for UI to call ***

void IPrep_setSliceNumber(number setSlice)
{
	// save the slice number in the tag and update progress window
	TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:Record Settings:Slice Number",setSlice)
	print("new #slices is: "+setSlice+"\n")
	myPW.updateC("slice: "+IPrep_sliceNumber())
}

number IPrep_consistency_check()
{
	// run after DM restarts to make sure that:
	// -all state machines are in a known position that we can resume from
	// -hardware classes have their states in tags synchronized with sensors
	// if we detect an unsafe flag, we need manual intervention


	print("iprep consistency check:")

	// workflow state machine
	print("current workflow state: "+myStateMachine.getCurrentWorkflowState())

	// determine where workflow is. used in case of DM crash or powerfailure of system. will tell user
	// where system was when it was still functioning
	if (myStateMachine.getCurrentWorkflowState() == "onTheWayToPECS"  || myStateMachine.getCurrentWorkflowState() == "onTheWayToSEM")
	{	
		// system crashed when doing transfer. nothing we can do. contact service and do a manual recovery
		print("DM terminated when system was "+myStateMachine.getCurrentWorkflowState()+", manual recovery needed")
		returnDeadFlag().setDeadUnSafe()

	}
	else if (myStateMachine.getCurrentWorkflowState() == "PECS") // sample was in PECS
	{
		// system was last in PECS, but did milling finish
		print("last finished step: "+myStateMachine.getLastCompletedStep())
		if (myStateMachine.getLastCompletedStep() == "MILL") // did milling finish? 
		{	

			print("milling was finished before DM terminated")
		}
		else if (myStateMachine.getLastCompletedStep() == "RESEAT")
		{

			print("reseating was finished before DM terminated")
		}
		else // milling did not finish
		{

			print("milling was not finished when workflow was aborted")
		}
	}
	else if (myStateMachine.getCurrentWorkflowState() == "SEM") // sample was in SEM
	{
		print("last finished step: "+myStateMachine.getLastCompletedStep())
		if (myStateMachine.getLastCompletedStep() == "IMAGE") // did imaging finish?
		{	

			print("imaging was finished before DM terminated")
		}
		else
		{
			
			print("imaging was not finished when workflow was aborted")
		}		
	}
	else
	{
		// workflow in unknown state, set dead unsafe. unlikely catch all state
		print("DM crashed when system was "+myStateMachine.getCurrentWorkflowState()+", manual recovery needed")
		returnDeadFlag().setDead(1, "state machine", "DM crashed when system was "+myStateMachine.getCurrentWorkflowState()+", manual recovery needed")
		returnDeadFlag().setSafety(0, "current workflow state not known: "+myStateMachine.getCurrentWorkflowState())

	}

	// sample is either in SEM Dock or on PECS stage, so we can most likely recover
	// figure out state of hardware one by one by running corresponding consistencychecks

	// pips
	// -check gate valve against sensor values
	// -check stage state 
	if (!myWorkflow.returnPecs().GVConsistencyCheck())
	{
		// GV is not nicely opened or closed
		// system is now dead
		print("GV:sensordata do not agree with previous save state. either caused by a malfunction or powerloss")
		returnDeadFlag().setDead(1, "GV", "GV state unknown: manual recovery needed")
		
	}
	else
	{
		print("GV state consistent")
	}


	// transfer, is saved position similar to where it thinks it is?
	if (myWorkflow.returnTransfer().consistencycheck() != 1)
	{
				
		print("transfer controller: stage is not where system thinks it is. manual recovery needed")
		returnDeadFlag().setDead(1, "TRANSFER", "transfer system not where system thinks it is. caused by faulted drive or powerloss while system was not at home")
		
		// set unsafe
		returnDeadFlag().setSafety(0, "transfer system not where system thinks it is. caused by faulted drive or powerloss while system was not at home")

	}
	else
	{
		print("Transfer stage state consistent")
	}

	// check if the FWD is coupled right
	//if (!returnMediator().checkFWDCoupling(0))
	//{
	//	print("FWD not correctly coupled")
	//	returnDeadFlag().setDead(1, "SEM", "FWD not set")
	//}

	// semstage, check that current coordinates are consistent with the state 
	if(!myWorkflow.returnSEM().checkStateConsistency())
	{

		if (okcanceldialog("SEM stage not where it should be. home to clear? "))
		{
			print("homing SEM stage to clear")
			myWorkflow.returnSEM().homeToClear()
			
		}
		else
		{
			print("sem stage: stage coordinates are not consistent with what the state of the stage is")
			returnDeadFlag().setDead(1, "SEM", "SEM stage in "+myWorkflow.returnSEM().getState()+", but not at state coordinates of that state")
		
			// set unsafe
			//returnDeadFlag().setSafety(0, "SEM stage in "+myWorkflow.returnSEM().getState()+", but not at state coordinates of that state")
		}
	} 
	else
	{
		print("SEM stage state consistent")
	}

	// dock mode
	// check that new mode is consistent with readout of dock
	if (getSystemMode() != returnMediator().detectMode())
	{
		print(getSystemMode()+" dock not detected. detected dock is "+returnMediator().detectMode())

		// give user option to ignore
		if (!okcanceldialog("dock mode not detected. detected "+returnMediator().detectMode()+", but mode is set to "+getSystemMode()+". continue?"))
		{
			
			returnDeadFlag().setDead(1, "DOCK", getSystemMode()+" dock not detected. detected dock is "+returnMediator().detectMode())
		}
		print("ignoring dock warning")
	}
	else
	{
		print("dock mode consistent: "+returnMediator().detectMode())
	}

	// dock state
	// #todo

	// gripper
	// #todo: what if stuck in open position? go to unsafe, since gripper problems cannot be easily fixed!



	// if dead, return 0
	//if (returnDeadFlag().isDead())
	//{
	//	print("system is in dead mode, devices need to be manually put in correct state")	
	//	okdialog("system is in dead mode, devices need to be manually put in correct state")	
	//	return 0
	//}


	// if unsafe, there is nothing we can do without manually figuring this out
	if (!returnDeadFlag().isSafe())
	{
		print("system is in unsafe mode, please contact Gatan service")	
		okdialog("system is in unsafe mode, please contact Gatan service")	
		return 0
	}

	// success,
	print("consistency check finished!")
	return 1
}

number IPrep_recover_deadflag()
{

	// the idea is that a succesful consistency check will recover from the 'dead' state, 
	// but not from the 'unsafe' state

	// attempts to recover from dead flag problem by asking user questions and doing tests where possible
	// if problem is fixed, dead flag set to 0 again and workflow can continue
	// -ask user if there was a power failure (check UPS)
	// -check unsafe flag, we cannot recover from that automatically

	// if set by GV:
	// try to force open
	// -make sure user verifies pecs and sem are under vacuum

	// if set by SEM stage:
	// try to home to clear, 
	// -make sure user gets dialog to verify parker is out of the way

	// if set by SEM:
	// -ask user to manually make picture and verify values are ok?

	// if set by pecs stage
	// lower
	// -make sure parker is at 0

	// if set by transfer:
	// check that position is 0, if not, we are unsafe

	// for now, a succesful IPrep_consistency_check() will remove the dead flag
	// #todo: we need to add some extra checks
	if (IPrep_consistency_check())
	{
		print("consistency check passed. system no longer dead")
		returnDeadFlag().setDead(0)
	}
}

number IPrep_align_applyvectors()
{
	// apply vectors based on current mode (ebsd or planar) to calibration points
}

number IPrep_align_restoredefaults()
{
}

number IPrep_align_planar_hack()
{
	// hardcoded values as planar coordinates

	// calibrate SEM points:
		// -set coords for "reference" and "scribe_pos" from "reference_ebsd" and "scripe_pos_ebsd"
		// -infers all the coordinates for SEM use from "reference" and "scribe_pos" for this particular dock
		//	and sets coord tags

		// first, set "reference" and "scribe_pos" to planar coord values
		object reference = returnSEMCoordManager().getCoordAsCoord("reference_planar")
		reference.setName("reference")
		returnSEMCoordManager().addCoord(reference)

		object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos_planar")
		scribe_pos.setName("scribe_pos")
		returnSEMCoordManager().addCoord(scribe_pos)

		// retrieve all coords we are going to set

		object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
		object clear = returnSEMCoordManager().getCoordAsCoord("clear")
		object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
		object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
		object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
		object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")
		object lowerGrid = returnSEMCoordManager().getCoordAsCoord("lowerGrid")


		
		print("calibration used is manual Quanta cal with planar dock 2016-06-27")

		// reference point is the point from which other coordinates are inferred
		// the reference point for all coordinates is the pickup/dropoff point now

		print("scribe position set: ")
		scribe_pos.print()

		print("reference set: ")
		reference.print()

		// pickup_dropoff is reference point, so simply set them there
		pickup_dropoff.set(reference.getX(), reference.getY(), reference.getZ())
		print("pickup_dropoff set: ")
		pickup_dropoff.print()

		// for clear only move in Z from reference point
		clear.set(reference.getX(), reference.getY(), reference.getZ()+3.5)
		print("clear set: ")
		clear.print()

		// nominal imaging is approximate middle of sample
		nominal_imaging.set( scribe_pos.getX()-22.8104, scribe_pos.getY()-38.6801, scribe_pos.getZ(), 0 )
		print("nominal_imaging set: ")
		nominal_imaging.print()

		// stored imaging starts at the same point as the nominal imaging point
		StoredImaging.set( nominal_imaging.getX(), nominal_imaging.getY(), nominal_imaging.getZ(), nominal_imaging.getdf() )
		print("StoredImaging set: ")
		StoredImaging.print()

		// grid on post at back position (serves as sanity check)
		highGridBack.set( 25.215, 14.161, 48, 0)
		print("highGridBack set: ")
		highGridBack.print()

		// grid on post in front position (serves as sanity check)
		highGridFront.set( -8.271, 14.533, 48, 0 )
		print("highGridFront set: ")
		highGridFront.print()



		// grid on base plate, formerly used for FWD Z-height cal, now not used // Save to remove all references to lowerGrid
		lowerGrid.set(31.887, 27.507, 48, 0)
		print("lowerGrid set: ")
		lowerGrid.print()

	
		// now update the coords in tags to their updated values
		returnSEMCoordManager().addCoord(pickup_dropoff)
		returnSEMCoordManager().addCoord(clear)
		returnSEMCoordManager().addCoord(nominal_imaging)
		returnSEMCoordManager().addCoord(StoredImaging)
		returnSEMCoordManager().addCoord(highGridFront)
		returnSEMCoordManager().addCoord(highGridBack)
		returnSEMCoordManager().addCoord(lowerGrid)
}

number IPrep_init()
{
	// starts when IPrep DM module starts
	// initializes workflow object, establishes connection with hardware and saves positions for transfers

	try
	{
		print("iprep init")


		// init iprep workflow subsystems/hardware
		myWorkflow.init()

		// init the state machine with current states 
		myStateMachine.init(myWorkflow)
		
		// #TODO: check dock against mode tag
		// use okcanceldialog wrapper to choose to ignore this as warning or throw error

		
		print("current slice: "+IPrep_sliceNumber())
		myPW.updateC("slice: "+IPrep_sliceNumber())
		myPW.updateB("idle")
		myPW.updateA("sample: "+myStateMachine.getCurrentWorkflowState())
		print("iprep init done")
		return 1
	}
	catch
	{
		print("exception during init"+ GetExceptionString())
		okdialog("exception during init"+ GetExceptionString())
		break
		
	}
	return 0
}

number IPrep_toggle_planar_ebsd(string mode)
{
	// guides user through changing out docks
	// mode = 'ebsd' or 'planar'
	// called manually by user

	number returncode = 0

	try
	{
		// check dead/unsafe
		if (!returnDeadFlag().checkAliveAndSafe())
			return returncode // to indicate error

		// confirm sample in PECS
		if (myStateMachine.getCurrentWorkflowState() != "PECS")
		{
			print("sample not in PECS!")	
			return returncode
		}

		// vent
		if (!okcanceldialog("Has the dock been swapped, connected and has the dock motor axis been aligned along y axis?"))
		{
			print("user aborted")
			return returncode
		}

		// confirm alignment in x
			// store rotation #todo

		// change mode tag
		setSystemMode(mode)
		print("mode changed to: "+getSystemMode())

		// calibrate
		print("calibrating points for mode")
		// #todo: no longer in workflow class
		//myWorkflow.calibrateForMode()


		// check that new mode is consistent with readout of dock
		if (getSystemMode() != returnMediator().detectMode())
		{
			print(getSystemMode()+" dock not detected. detected dock is "+returnMediator().detectMode())
			return returncode
		}
		else
		{
			print(returnMediator().detectMode()+" dock detected")
		}

		//home sem stage to new clear
		print("homing to new clear position")
		myWorkflow.returnSEM().homeToClear()

		// clamp and unclamp and confirm

		if (okcanceldialog("testing dock in clamped and unclamped position, press ok when ready"))
		{
			myWorkflow.returnSEMDock().unclamp()
			myWorkflow.returnSEMDock().clamp()
		}
		else
			throw("user aborted check")

		okdialog("dock test has succeeded. please pump down the system and recalibrate scribe mark")
		print("done")
		returncode = 1

	}
	catch
	{
		print("mode change did not succeed: exception: "+GetExceptionString())
		okdialog("mode change did not succeed: exception: "+ GetExceptionString())
		// set dead
		returnDeadFlag().setDead(1, "mode", "mode change error: "+GetExceptionString())
		// set unsafe
		//returnDeadFlag().setSafety(0, "mode change error: "+GetExceptionString())
		break
	}


	return returncode
}

number IPrep_scribemarkVectorCorrection(number x_corr, number y_corr)
{
	// adjust nominal_imaging, stored_imaging, highGridFront, highGridBack, pickup_dropoff and clear by vector
	// called by UI


	object scribe_pos = returnSEMCoordManager().getCoordAsCoord("scribe_pos")
	object pickup_dropoff = returnSEMCoordManager().getCoordAsCoord("pickup_dropoff")
	object clear = returnSEMCoordManager().getCoordAsCoord("clear")
	object nominal_imaging = returnSEMCoordManager().getCoordAsCoord("nominal_imaging")
	object StoredImaging = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
	object highGridFront = returnSEMCoordManager().getCoordAsCoord("highGridFront")
	object highGridBack = returnSEMCoordManager().getCoordAsCoord("highGridBack")

	
	// do corrections on these points

	scribe_pos.corrX(x_corr)
	scribe_pos.corrY(y_corr)
	print("new corrected scribe_pos: ")
	scribe_pos.print()

	pickup_dropoff.corrX(x_corr)
	pickup_dropoff.corrY(y_corr)
	print("new corrected pickup_dropoff: ")
	pickup_dropoff.print()

	clear.corrX(x_corr)
	clear.corrY(y_corr)
	print("new corrected clear: ")
	clear.print()

	nominal_imaging.corrX(x_corr)
	nominal_imaging.corrY(y_corr)
	print("new corrected nominal_imaging: ")
	nominal_imaging.print()

	StoredImaging.corrX(x_corr)
	StoredImaging.corrY(y_corr)
	print("new corrected StoredImaging: ")
	StoredImaging.print()

	highGridFront.corrX(x_corr)
	highGridFront.corrY(y_corr)
	print("new corrected highGridFront: ")
	highGridFront.print()

	highGridBack.corrX(x_corr)
	highGridBack.corrY(y_corr)	
	print("new corrected highGridBack: ")
	highGridBack.print()

	// save the points with corrections added
	returnSEMCoordManager().addCoord(pickup_dropoff)
	returnSEMCoordManager().addCoord(clear)
	returnSEMCoordManager().addCoord(nominal_imaging)
	returnSEMCoordManager().addCoord(StoredImaging)
	returnSEMCoordManager().addCoord(highGridFront)
	returnSEMCoordManager().addCoord(highGridBack)
	returnSEMCoordManager().addCoord(scribe_pos)

	return 1
}

void IPrep_cleanup()
{
	// runs when there is a problem detected to return to manageable settings, ie:
	// unlock the pecs, turn off high voltage etc
	
	print("cleanup called")
	
	// delete the digiscan parameters created for 
	//DSDeleteParameters( alignParamID )

	// tell UI to not be in 'running' state anymore
	IPrep_abortrun()
	
	// turn off HV
	print("turning off HV")
	myWorkflow.returnSEM().HVOff()

	// unlock PECS UI
	print("unlocking PECS")
	myWorkflow.returnPECS().unlock()
}

Number IPrep_setup_imaging()
{
	print("IPrep_Setup_Imaging")
	// not used right now
}

Number IPrep_foobar()
{
	// test function for general error handling framework

	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("IPrep_foobar")
	try
	{
		print("foobar start")
		
		myStateMachine.SMtestroutine()
		
		print("foobar end")
		returncode = 1 // to indicate success
	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString())
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus
	}

	return returncode
}

// *** methods directly called by workflow ***

Number IPrep_MoveToPECS_workflow()
{
	number returncode = 0

	print("IPrep_MoveToPECS")
	myPW.updateA("sample: -> PECS")
	number success = myStateMachine.SEM_to_PECS()
	
	if (success == 1)
	{
		returncode = 1 // to indicate success
		myPW.updateA("sample: in PECS")
		print("iprep move to pecs done")
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
		returnDeadFlag().setDead(1, "movetopecs", " ")
		returnDeadFlag().setSafety(0, "IPrep_MoveToPECS failed")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
	}

	return returncode
}

Number IPrep_MoveToSEM_workflow()
{
	number returncode = 0

	print("IPrep_MoveToSEM")
	myPW.updateA("sample: -> SEM")
	number success = myStateMachine.PECS_to_SEM()
	
	if (success == 1)
	{

		myPW.updateA("sample: SEM")
		print("iprep move to sem done")
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
		returnDeadFlag().setDead(1, "movetosem", " ")
		returnDeadFlag().setSafety(0, "IPrep_MoveToSEM failed")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
	}	

	return returncode
}

Number IPrep_reseat()
{
	// used to pick up the sample from the PECS and put it back 
	// use after sample vacuum transfer to make sure images taken in the PECS have the carrier 
	// at the right location in the dovetail

	// called manually from menu before workflow starts

	number returncode = 0

	print("IPrep_reseat")
	myPW.updateA("sample: -> reseating")
	number success = myStateMachine.reseat1()
	
	if (success == 1)	
	{
		myPW.updateA("sample: done reseating")
		print("reseating done")
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
		returnDeadFlag().setDead(1, "reseating", " ")
		returnDeadFlag().setSafety(0, "reseating failed")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
	}	

	return returncode	
}

Number IPrep_check()
{
	// call this at the end of imaging step to check:
	// -SEM status (ie emission current)
	// -UPS status
	// -consistency check 
	// -pecs vacuum and argon pressure
	// -end condition met (number of slices)



	if(!myWorkflow.returnPECS().argonCheck())
	{
		print("PECS system argon pressure below threshold")
		return 0
	}

	if(!myWorkflow.returnPECS().TMPCheck())
	{
		print("PECS system not at vacuum or TMP problem")
		return 0
	}

	if(IPrep_sliceNumber() > IPrep_maxSliceNumber())
	{
		print("Maximum number of slices ("+IPrep_maxSliceNumber()+") reached")
		return 0
	}


	// SEM status:
	// - working distance active check

	// UPS status

	return 1
}

Number IPrep_Init3DStacks()
{
	// look at enabled ROIs and create (and show) 3D stacks of these
	// -gets called by startrun(create and show), but not resumerun (resumerun only shows them)
	// #todo: make startrun/resumerun compatible with this paradime


}


Number IPrep_StartResumeGeneric()
{
	// start the main loop for both start and resume
	print("UI: IPrep_StartResumeGeneric")

	number returncode = 0

	// now that we have concluded the system is in a good state to start, infer where we are
	try
	{

		// #TODO: this routine needs to know where to start in case of DM crash. 
		// # slice number is remembered, but also needs to know last succesfully completed step. 
		// # can query this with: myStateMachine.getLastCompletedStep() ("IMAGE", "MILL", "SEM", "PECS", "RESEAT")
		// # this is all working in a rather rudimentary way now

		// set stop and pause back to 0
		returnstopVar().set1(0)
		returnPauseVar().set1(0)
		
		if (myStateMachine.getCurrentWorkflowState() == "SEM")
		{
			if (myStateMachine.getLastCompletedStep() == "IMAGE")
			{
				myloop.seti(1) // start at EBSD step, comes after imaging
				print("starting from i=1, EBSD")
			}
			else if (myStateMachine.getLastCompletedStep() == "EBSD")
			{
				myloop.seti(2) // start at increment slice number step, comes after EBSD
				print("starting from i=2, incrementing slice number")
			}
			else
			{
				myloop.seti(0) // start at imaging step
				print("starting from i=0, imaging")				
			}
		}
		else if (myStateMachine.getCurrentWorkflowState() == "PECS")
		{
			if (myStateMachine.getLastCompletedStep() == "MILL")
			{
				myloop.seti(6) // start at image after mill
				print("starting from i=5, pecs camera image after milling")
			} 
			else
			{
				myloop.seti(4) // start at image before mill
				print("starting from i=4, pecs camera image before milling")
			}
		}
		else
		{
			print("cannot start run, current state is "+myStateMachine.getCurrentWorkflowState())
			IPrep_abortrun()
			return returncode
		}

	// start loop
	myloop.init(9).StartThread() // start thread with 9 steps 

	returncode = 1 // to indicate success

	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString())
		returnDeadFlag().setDeadUnSafe()
		okdialog("something went wrong in starting run: "+GetExceptionString()+"\n"+"system now dead/unsafe")
		break // so that flow continues

	}

	return returncode

}

Number IPrep_StartRun()
{
	// executes when Start button is pressed
	print("UI: IPrep_StartRun")

	number returncode = 0
	string popuperror

	if (!returnDeadFlag().checkAliveAndSafe())
		{
			popuperror = "system dead and/or unsafe. cannot start"
			okdialog(popuperror)
			return returncode // to indicate error
		}

	if(!IPrep_consistency_check())
		{
			popuperror = "consistency check failed, check log. cannot start"
			okdialog(popuperror)
			return returncode // to indicate error
		}

	if(!IPrep_check())
		{
			popuperror = "check failed, check log. cannot start"
			okdialog(popuperror)
			return returncode // to indicate error
		}

	// reload sequences to pick up on changes
	// init state machine sequences with already initialized subsystems. also reinits 3d volumes used
	myStateMachine.init(myWorkflow)

	// show 3D stacks based on just enabled sequences/ROIs
	//returnVolumeManager().showAll()

	IPrep_StartResumeGeneric()

	
}

Number IPrep_PauseRun()
{
	number returncode = 0

	// set pausevar
	returnPauseVar().set1(1)

	returncode = 1 // to indicate success

	print("UI: IPrep_PauseRun")
	return returncode
}

Number IPrep_ResumeRun()
{
	print("UI: Prep_ResumeRun")

	number returncode = 0
	string popuperror

	if (!returnDeadFlag().checkAliveAndSafe())
	{
		popuperror = "system dead and/or unsafe. cannot start"
		okdialog(popuperror)
		return returncode // to indicate error
	}

	if(!IPrep_consistency_check())
	{
		popuperror = "consistency check failed, check log. cannot start"
		okdialog(popuperror)
		return returncode // to indicate error
	}

	if(!IPrep_check())
	{
		popuperror = "check failed, check log. cannot start"
		okdialog(popuperror)
		return returncode // to indicate error
	}

	// no reinit of 3d volumes or stacks

	IPrep_StartResumeGeneric()

	returncode = 1 // to indicate success
	
	return returncode
}

Number IPrep_StopRun()
{
	print("IPrep_StopRun")

	returnStopVar().set1(1)

	return 1
}

number IPrep_acquire_ebsd()
{
	number returncode = 0

	print("IPrep_acquire_ebsd")
	myPW.updateA("imaging")
	number success = myStateMachine.ebsd()
	
	if (success == 1)	
	{
		myPW.updateA("sample: done imaging")
		print("imaging done")
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode



	// old 
	// #may be removed
	/*
	
	number returncode = 0
	try
	{
		if(getSystemMode() == "ebsd")
		{
			// tell state machine we want to start EBSD acquisition
			myStateMachine.start_ebsd(8000) // timeout of 8000

			// tell state machine we want to stop EBSD acquisition
			myStateMachine.stop_ebsd()

			returncode = 1
		}
		else
		{
			print("not in EBSD mode, skipping step..")
			returncode = 1
		}
		
	}
	catch
	{
		// system caught unhandled exception
		print("EBSD system generated exception: "+GetExceptionString())

		// an exception in ebsd acquisition is most likely safe
		returnDeadFlag().setDead(1, "DOCK", "EBSD system generated exception: "+GetExceptionString())
		//returnDeadFlag().setDeadUnSafe()

		break // so that flow continues
	}

	return returncode
	*/
}

number IPrep_image() 
{
	number returncode = 0

	print("IPrep_image")
	myPW.updateA("imaging")
	number success = myStateMachine.image()
	
	if (success == 1)	
	{
		myPW.updateA("sample: done imaging")
		print("imaging done")
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode
}

Number IPrep_Pecs_Image_beforemilling()
// take image of sample in PECS before milling
{
	number returncode = 0

	print("IPrep_image_beforemilling")
	number success = myStateMachine.PECSImageBefore()
	
	if (success == 1)	
	{
		print("PECS image before milling taken of slice: "+IPrep_sliceNumber())
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode
}

Number IPrep_Pecs_Image_aftermilling()
// take image of sample in PECS before milling
{
	number returncode = 0

	print("IPrep_image_aftermilling")
	number success = myStateMachine.PECSImageAfter()
	
	if (success == 1)	
	{
		print("PECS image after milling taken of slice: "+IPrep_sliceNumber())
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode
}



Number IPrep_mill_workflow()
// Assumes sample is in PECS
// Mills sample
{
	number returncode = 0

	print("IPrep_mill")
	myPW.updateA("milling")
	number success = myStateMachine.mill()
	
	if (success == 1)	
	{
		myPW.updateA("sample: done milling")
		print("milling done on slice number: "+IPrep_sliceNumber())
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode


	// old style
	/*
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("UI: IPrep_Mill")
	try
	{
		
		// If on the first slice (which is slice 1), acquire an image before milling
		if ( IPrep_sliceNumber() == 1 )



		// initiate workflow to start milling
		print("PECS milling started")
		myPW.updateB("PECS milling started")

		// Mill sample 
		myStateMachine.start_mill(0, 8000)	// (timeout of 8000s)
		myStateMachine.stop_mill() // milling done

		myPW.updateB("PECS milling done")
		
		print("milling done on slice number: "+IPrep_sliceNumber())
	
		returncode = 1



	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString())
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus

	}
	return returncode
	*/
}

Number IPrep_Coat_workflow()
// Assumes sample is in PECS
// coats sample
{
	number returncode = 0

	print("IPrep_coat")
	myPW.updateA("coating")
	number success = myStateMachine.coat()
	
	if (success == 1)	
	{
		myPW.updateA("sample: done coating")
		print("coating done on slice number: "+IPrep_sliceNumber())
		returncode = 1 // to indicate success
	}
	else if (success == -1)
	{
		returncode = 0 // irrecoverable error
		print("iprep encountered an irrecoverable error")
	}
	else if (success == 0)
	{
		returncode = 0 // irrecoverable error (for now)
		print("iprep encountered an error. cannot recover")
		// #TODO: should pause system for user to fix whatever is wrong and continue
	}	

	return returncode
}

Number IPrep_IncrementSliceNumber()
{
	// increment the slicenumber in the tag as experiment is going
	number nSlices
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", nSlices)
	nSlices++
	IPrep_setSliceNumber(nSlices)
	return 1;
}

string IPrep_GetStatus()
{
	// called by ui dialog to display status
	return("workflowstate: "+ myStateMachine.getCurrentWorkflowState())
}

Number IPrep_RunPercentCompleted()
{
	// deprecated
	return myStateMachine.getPercentage()
}

// *** methods manually called by UI/user ***
// #TODO: these are called by buttons in the UI what look for these names. not ideal but ok for now. 

Number IPrep_MoveToPECS()
{
		
	if(IPrep_MoveToPECS_workflow() != 1)
	{
		okdialog("Did not finish transfer to PECS. check log")
	}

	return 1
}

Number IPrep_MoveToSEM()
{
	if(IPrep_MoveToSEM_workflow() != 1)
	{
		okdialog("Did not finish transfer to SEM. check log")
	}

	return 1
}

Number IPrep_mill()
{
	if(IPrep_mill_workflow() != 1)
	{
		okdialog("did not finish milling. check log")
	}

	return 1
}

Number IPrep_coat()
{
	if(IPrep_coat_workflow() != 1)
	{
		okdialog("did not finish coating. check log")
	}

	return 1
}

class IPrep_mainloop:thread
{
	// main iprep loop

	number loop_running
	object aStepTimer
	object aGlobalTimer
	
	number p // number of steps per cycle

	object iPersist

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("mainloop", level, text)
	}

	void print(object self, string text)
	{
		result("mainloop: "+text+"\n")
		self.log(2,text)
	}

	void IPrep_mainloop(object self)
	{
		// constructor
		loop_running = 0
		iPersist = alloc(statePersistanceNumeric)
		iPersist.init("step")
		aStepTimer = alloc(timer)
		aGlobalTimer = alloc(timer)
	}

	object init(object self, number p1)
	{
		p = p1 // set number of steps per cycle
		self.print("initialized, number of steps per cycle = "+p1+", current step = "+iPersist.getNumber())

		// init timers to display
		aStepTimer.init(1)
		aGlobalTimer.init(1)

		return self
	}

	void incrementi(object self)
	{
		// increment i by 1 modulo p
		number newi = (iPersist.getNumber()+1)%p
		iPersist.setNumber(newi)
		//self.print("debug breakpoint")
	}

	void seti(object self, number newi)
	{
		// update i
		iPersist.setNumber(newi)
	}

	number geti(object self)
	{
		return iPersist.getNumber()
	}

	number process_response(object self, number returnval, number repeat)
	{
		// look at the response value and determine what the i value needs to do
		// check for pause and stop flags
		// 1: step succeeded, continue to next step
		// 0: irrecoverable error or stop/pause pressed, stop loop
		// -1: repeat previous step

		//self.print("DEBUG: processing returnval "+returnval)

		if (returnval==1)
		{	
			// success
			self.incrementi() // increment i if function succeeds
		}
		else if (returnval == -1)
		{
			// failure, repeat step next iteration, i remains the same
			//#todo: count number of repeats for a step and throw something if it is more than 2
			if (repeat == 0) 
			{
				// treat returning -1 as error
				returnval = 0
			}
			// else leave i as is

		} 

		// if irrecoverable error occured, stop loop
		if (returnval == 0)
		{
			
			IPrep_abortrun() // send UI stop command, tells ui elements to exit loop running state

			returnPauseVar().set1(0) // set pausevar back to 0, in case it was pressed
			returnstopVar().set1(0) // set stopvar back to 0, in case it was pressed

			return 0 
		}

		// if pause/stop button is pressed, stop loop and wait for resume
		if (returnPauseVar().get1() || returnStopVar().get1())
		{
			returnPauseVar().set1(0) // set pausevar back to 0
			returnstopVar().set1(0) // set stopvar back to 0

			return 0 
		}
	
		return 1
	}

	void stop(object self)
	{
		// stop the mainloop thread
		self.print("stop signal sent")
		loop_running = 0
	}

	void stop(object self, number cleanup)
	{
		// stop the mainloop thread and run cleanup() if requested
		loop_running = 0
		if (cleanup == 1)
		{	
			self.print("stop signal sent, running cleanup")
			IPrep_cleanup()
		}
		else 
			self.print("stop signal sent")
		
		
	}

	void runthread(object self)
	{

		loop_running = 1
		while (loop_running)
		{
			// get i and start loop at this step
			number i = self.geti()
			self.print("current step: "+i)

			if (i==0) // imaging, repeat if function returns 0
			{
				aGlobalTimer.tick("slice: "+IPrep_sliceNumber())

				aStepTimer.tick("imaging")

				self.print("loop: i = 0, imaging")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:imaging"))
				{
					returnval = IPrep_image()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping imaging step")
					returnval = 1
				}

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			} 
			else if (i==1) // ebsd imaging, repeat if function returns 0
			{
				
				aStepTimer.tick("EBSD")

				self.print("loop: i = 1, ebsd imaging")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:ebsd"))
				{
					returnval = IPrep_acquire_ebsd()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping EBSD/EDS step")
					returnval = 1
				}

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}		
			else if (i==2) // increment the slice number
			{
				aStepTimer.tick("slice number incrementation")

				self.print("loop: i = 2, incrementing slice number")
				number returnval = IPrep_IncrementSliceNumber()

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==3) // move to pecs, do not repeat
			{
				aStepTimer.tick("move to pecs")

				self.print("loop: i = 3, move to pecs")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:MoveToPECS"))
				{
					returnval = IPrep_MoveToPECS_workflow()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping MoveToPECS step")
					returnval = 1
				}

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==4) // image in pecs before milling, repeat if function returns 0
			{
				aStepTimer.tick("image in PECS before milling")

				self.print("loop: i = 4, imaging before milling")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:pecsImageBefore"))
				{
					returnval = IPrep_Pecs_Image_beforemilling()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping PECS imaging before milling step")
					returnval = 1
				}
				
				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==5) // mill, do not repeat
			{
				aStepTimer.tick("mill")

				self.print("loop: i = 5, milling")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:milling"))
				{
					returnval = IPrep_mill_workflow()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping milling step")
					returnval = 1
				}

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==6) // image in pecs after milling, repeat if function returns 0
			{
				aStepTimer.tick("image in PECS after milling")

				self.print("loop: i = 6, imaging after milling")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:pecsImageAfter"))
				{
					returnval = IPrep_Pecs_Image_aftermilling()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping PECS imaging after milling step")
					returnval = 1
				}				

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==7) // move to sem
			{
				aStepTimer.tick("move to sem")

				self.print("loop: i = 7, move to sem")
				number returnval = 0

				if(GetTagValue("IPrep:WorkflowElements:MoveToSEM"))
				{
					returnval = IPrep_MoveToSEM_workflow()
				}
				else // if step not enabled, succeed and go to next step
				{
					self.print("loop: skipping MoveToSEM step")
					returnval = 1
				}

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	
			}
			else if (i==8) // do a check of pressure/tmp speed/end conditions
			{
				aStepTimer.tick("safety and end condition checking")

				aGlobalTimer.tock()
				self.print("loop: check")
				number returnval = IPrep_check()
				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop(GetTagValue("IPrep:endConditions:run_cleanup_at_end"))					
			}

			sleep(1)
			aStepTimer.tock()

		}

		if (!returnDeadFlag().isSafe())
		{
			self.print("system unsafe when exiting mainloop: running cleanup routine")
			self.stop(1)
		}

		loop_running = 0
		self.print("done")

	}




}




// *** actual workflow following ***

try
{
	// this get executed when this script starts / DM starts

	Iprep_init() // initialize hardware


}
catch
{
	result("exception caught at highest level\n")
	print(GetExceptionString())
}

// save global tags to disk
ApplicationSavePreferences()

result("iPrep_main: done with execution, idle\n")


