// $BACKGROUND$

// this file contains function definitions. needs to be installed with other hardware class 
// scripts as library

number XYZZY = 0	// set to 1 to enable TH workflow

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()


object myPW = alloc(progressWindow) //#todo migrate to mediator
// convention for progresswindow:
// A: sample status
// B: operation
// C: slice number

//object myLoop

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

object my3DvolumeSEM

/*
// 3d volumes
object my3DvolumeSEM
object my3DvolumePECSbefore
object my3DvolumePECSafter
*/
/* #TODO: re-enable
	// digiscan parameters alignment
	number alignWidth = 2048
	number alignHeight = 2048
	number alignDwell = 4
	number alignParamID = 3
	number alignMag = 1000


	// working distance for imaging grids on posts
	number gridWD = 7.5

	// imaging parameters
	number imageMag = 5000
	number imagingWD = 0

	// voltage used
	number IPrepVoltage = 2

	// configured status flag
	number imagingConfigured = 0
*/


void logE(number level, string str1)
{
	// log events in log files
	LogEvent("main", level, str1)
}

void print(string str1)
{
	result("main: "+datestamp()+": "+str1+"\n")
	logE(2, str1)
}

// *** methods available for UI to call ***

string IPrep_rootSaveDir()
{
	// get the root save path from the tag that the UI dialog saves it in

	string pointer
	GetPersistentTagGroup().TagGroupGetTagAsString("IPrep:Record Settings:Base Filename", pointer)

	print("root dir is: "+pointer+"\n")
	return pointer
}

number IPrep_sliceNumber()
{
	Number nSlices
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", nSlices)
	print("N Slices = "+nSlices)
	return nSlices
}

void IPrep_setSliceNumber(number setSlice)
{
	// save the slice number in the tag
	TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:Record Settings:Slice Number",setSlice)
	print("new #slices is: "+setSlice+"\n")
	myPW.updateC("slice: "+IPrep_sliceNumber())
}

number IPrep_maxSliceNumber()
{
	string tagname = "IPrep:Record Settings:Number of Cycles"
	number slices = 0
	GetPersistentNumberNote( tagname, slices )
	return slices
}


void IPrep_saveSEMImage(image &im, string subdir)
{
	// saves front image, used both for digiscan
	
	string DirPath = ""
	DirPath = PathExtractDirectory(IPrep_rootSaveDir(), 0)

	string FileNamePrefix = "IPREP_SEM"
	string FileNamePostfix = "_slice_"+right("000"+IPrep_sliceNumber(),4)
	
	// check if dir exsits, create if not
	if (!DoesDirectoryExist( dirPath + subdir))
		CreateDirectory(dirPath + subdir)
	
	DirPath = DirPath + subdir + "\\"
	string filename = DirPath+FileNamePrefix+FileNamePostfix
	
	SaveAsGatan(im,filename)

	print("saved "+filename)
}

void IPrep_savePECSImage(image &im, string subdir)
{
	// saves front image, used both for pecs camera
	
	string DirPath = ""
	DirPath = PathExtractDirectory(IPrep_rootSaveDir(), 0)

	string FileNamePrefix = "IPREP_PECS"
	string FileNamePostfix = "_slice_"+right("000"+IPrep_sliceNumber(),4)

	// check if dir exsits, create if not
	if (!DoesDirectoryExist( dirPath + subdir))
		CreateDirectory(dirPath + subdir)
	
	DirPath = DirPath + subdir + "\\"
	string filename = DirPath+FileNamePrefix+FileNamePostfix

	SaveAsGatan(im,filename)
	
	print("saved "+filename)
}


void WorkaroundQuantaMagBug( void )
// When there is a Z move on the Quanta and the FWD is different from the calibrated stage Z,
// there is a bug where the Quanta miscalculates the actual magnification.  This work around
// seems to be generic in fixing the issue.  You can see this bug by having the stageZ=30, fwd=7
// (focused on the sample) and then changing Z to 60 and back.  The mag will be off by > 2x.
{
	result( datestamp()+": WorkaroundQuantaMagBug" )
	number oldmag=emgetmagnification()

	emsetmagnification( 50 )
	emwaituntilready()

	emsetmagnification( 100000 )
	emwaituntilready()

	emsetmagnification( oldmag )
	result( ",done.\n")
}

void IPrep_autofocus()
{
	// wrapper for autofocus function in DM
	// #todo: test, just copied from JH example

	string s1="Private:AFS Parameters"
	string s2="Focus accuracy"
	string s3="Focus limit (lower)"
	string s4="Focus limit (upper)"
	string s5="Focus search range"
	number n2,n3,n4,n5

	string str2 
	number focus_range_fraction = .2
	number focus = EMGetFocus()
	number focus_range = .1*focus
	number focus_res = .01*focus

	str2 = s1+":"+s2
	GetPersistentNumberNote( str2, n2 )
	n2 = focus_res
	if ( !GetNumber( str2, n2, n2 ) ) exit(0)
	SetPersistentNumberNote( str2, n2 )


	str2 = s1+":"+s3
	GetPersistentNumberNote( str2, n3 )
	n3 = focus - focus * focus_range_fraction
	if ( !GetNumber( str2, n3, n3 ) ) exit(0)
	SetPersistentNumberNote( str2, n3 )

	str2 = s1+":"+s4
	GetPersistentNumberNote( str2, n4 )
	n4 = focus + focus * focus_range_fraction
	if ( !GetNumber( str2, n4, n4 ) ) exit(0)
	SetPersistentNumberNote( str2, n4 )

	str2 = s1+":"+s5
	GetPersistentNumberNote( str2, n5 )
	n5=focus_range
	if ( !GetNumber( str2, n5, n5 ) ) exit(0)
	SetPersistentNumberNote( str2, n5 )

	//AF_Run()
	// /*
	number start_focus = EMGetFocus()
	result("\n"+datestamp()+": start WD = "+(start_focus/1000)+"\n")
	AFS_Run()

	while( AFS_IsBusy() )
	{
		sleep( 1 )
		result(".")
	}
	result("\n")
	number end_focus = EMGetFocus()
	result(datestamp()+": final WD = "+(end_focus/1000)+"\n")
	//*/
	/*
	{
		number mag=EMGetMagnification()
		number focus=EMGetFocus()
		number i=0,df
		image plot:=RealImage("AF test,mag="+mag+",prec="+n2,4,11,1)
		plot.showimage()
		plot.displayat(500,100)
		plot=focus/1000
		for (df=-2.5;df<=2.5;df+=.5)
		{
			EMSetFocus(focus+1000*df)
			sleep(1)
			if (shiftdown() &&optiondown() ) exit(0)
			number start_focus = EMGetFocus()
			result(i+":"+datestamp()+": start WD = "+(start_focus/1000)+"\n")
			AFS_Run()
			number end_focus = EMGetFocus()
			result(i+":"+datestamp()+": final WD = "+(end_focus/1000)+"\n\n")
			plot[i,0]=end_focus/1000
			plot.updateimage()
			i+=1
		}
	}
	*/
}

void acquire_PECS_image( image &img )
// Use this routine to acquire a PECS image in any PECS stage position.
// PECS should not be milling - this is not tested for
// Uses default PECS camera acquire settings
// Image is not displayed
// Turns off illumination on exit
{

// Check if stage is up (needs to be up for imaging)
	string first_stagepos = myWorkflow.returnPecs().getStageState()
	if ( first_stagepos != "up" )
	{
		// If not up then raise it
		print(": PECS stage in down position. Raising to up position" )
		myWorkflow.returnPecs().moveStageUp()

		string current_stagepos = myWorkflow.returnPecs().getStageState()
		if ( current_stagepos != "up" )
			throw( "Problem moving stage to up position. Currently at:"+current_stagepos )

	}
		//datestamp()
		print("PECS stage in up position" )

	// Light on, acquire, light off
	myWorkflow.returnPecs().ilumOn()
	myWorkflow.returnPECSCamera().acquire(img) // use correct method
	myWorkflow.returnPecs().ilumOff()
	
	// If stage was originally down, then return stage to down position
	if ( first_stagepos != "up" )
	{
		print("PECS stage in up position. Returning to down position")
		myWorkflow.returnPecs().moveStageDown()
		string current_stagepos = myWorkflow.returnPecs().getStageState()
		if ( current_stagepos != "down" )
			throw( "Problem moving stage back to down position. Currently at:"+current_stagepos )

		print("PECS stage returned to down position" )
	}
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
		
		// not unsafe yet
		//returnDeadFlag().setSafety(0, "GV state unknown: manual recovery needed")

	}
	else
	{
		print("GV state consistent")
	}


	if (!myWorkflow.returnPecs().StageConsistencyCheck())
	{
		if(!okcanceldialog("is the PECS stage in a known position?"))
		{	
			print("PECS stage:sensordata do not agree with previous save state. either caused by a malfunction, powerloss or argon pressure loss")
			returnDeadFlag().setDead(1, "PECS", "pecs stage not in well defined position")
		
			// not unsafe yet
			//returnDeadFlag().setSafety(0, "pecs stage not in well defined position")
		}
	}
	else
	{
		print("PECS stage state consistent")
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


	// semstage, check that current coordinates are consistent with the state 
	if(!myWorkflow.returnSEM().checkStateConsistency())
	{

		print("sem stage: stage coordinates are not consistent with what the state of the stage is")
		returnDeadFlag().setDead(1, "SEM", "SEM stage in "+myWorkflow.returnSEM().getState()+", but not at state coordinates of that state")
		
		// set unsafe
		returnDeadFlag().setSafety(0, "SEM stage in "+myWorkflow.returnSEM().getState()+", but not at state coordinates of that state")

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
		returnDeadFlag().setDead(1, "DOCK", getSystemMode()+" dock not detected. detected dock is "+returnMediator().detectMode())
		
	}
	else
	{
		print("dock mode consistent: "+returnMediator)
	}

	// dock state

	// gripper
	// #todo: what if stuck in open position? go to unsafe, since gripper problems cannot be easily fixed!



	// if dead, return 0
	if (returnDeadFlag().isDead())
	{
		print("system is in dead mode, devices need to be manually put in correct state")	
		okdialog("system is in dead mode, devices need to be manually put in correct state")	
		return 0
	}


	// if unsafe, there is nothing we can do without manually figuring this out
	if (!returnDeadFlag().isSafe())
	{
		print("system is in unsafe mode, please contact Gatan service")	
		okdialog("system is in unsafe mode, please contact Gatan service")	
		return 0
	}

	// success
	print("consistency check passed!")
	return 1

}

number IPrep_recover_deadflag()
{
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


}


number IPrep_init()
{
	// starts when IPrep DM module starts
	// initializes workflow object, establishes connection with hardware and saves positions for transfers

	try
	{
		print("iprep init")


		// init iprep workflow and set the default positions for transfer in tags
		myWorkflow.init()
		myWorkflow.setDefaultPositions()

		// hand over workflow object to state machine, who handles allowed transfers and keeps track of them
		// get initial state from tag
		myStateMachine.init(myWorkflow)


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
		return 0
	}
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
		myWorkflow.calibrateForMode()

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
	}
	catch
	{
		print("mode change did not succeed: exception: "+GetExceptionString())
		okdialog("mode change did not succeed: exception: "+ GetExceptionString())
		// set dead
		returnDeadFlag().setDead(1, "mode", "mode change error: "+GetExceptionString())
		// set unsafe
		//returnDeadFlag().setSafety(0, "mode change error: "+GetExceptionString())
		return returncode
	}

	returncode = 1

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

Number IPrep_Setup_Imaging()
{
	print("IPrep_Setup_Imaging")
	// setup the imaging parameters and saves them 
	// run this after manually surveying
	// beam is assumed to be on at this point	

	// save workingdistance used now during preview in SEM class so that when taking 
	// an actual image we can set it back to that value
	// this value is the same for each image taken

	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	try
	{
		// for single ROI imaging (legacy mode)
		// create the default ROI, linked to coord StoredImaging
		object myDefaultROI = ROIFactory(0,"StoredImaging")
		
		// set focus
		number imagingWD = myWorkflow.returnSEM().measureWD()
		myDefaultROI.setFocus(imagingWD)
		print("Setup Imaging: Working Distance="+imagingWD)

		// update StoredImaging position with current position
		myWorkflow.returnSEM().saveCurrentAsStoredImaging()
		print("Setup Imaging: StoredImaging Coord set")

		// blank the beam
		//myWorkflow.returnSEM().blankOn()

		// save the ROI to the manager
		returnROIManager().addROI(myDefaultROI)

		print("Setup Imaging: Done setting up imaging conditions")

		// 3D volume stuff, number of slices in 3D block
		// make the displayed 3D stack of digiscan images the size of what the "capture" setting is
		// quietly ignore exceptions
		try
		{
			number slices = 10
			my3DvolumeSEM = alloc(IPrep_3Dvolume)
			my3DvolumeSEM.initSEM_3D(slices, DSGetWidth(2), DSGetHeight(2))
			my3DvolumeSEM.show()
		}
		catch
		{
			print("ignoring 3D volume stack")
			break
		}

		/* // legacy

		// set WD in class to current value
		number imagingWD = myWorkflow.returnSEM().measureWD()
		myWorkflow.returnSEM().setDesiredWD(imagingWD)
		print("working distance to do imaging at: "+imagingWD)
		
		// set kv in class to current value (if needed, was needed for Quanta)
		//myWorkflow.returnSEM().setDesiredkV(IPrepVoltage)

		// register current coordinate to come back to
		//myWorkflow.returnSEM().saveCurrentAsStoredImaging()

		// blank the beam
		myWorkflow.returnSEM().blankOn()

		if(!ContinueCancelDialog( "is digiscan configured correctly?" ))
			return returncode

		// 3D volume stuff, number of slices in 3D block
		// make the displayed 3D stack of digiscan images the size of what the capture setting is
		//number slices = 10
		//my3DvolumeSEM = alloc(IPrep_3Dvolume)
		//my3DvolumePECSbefore = alloc(IPrep_3Dvolume)
		//my3DvolumePECSafter = alloc(IPrep_3Dvolume)
		//my3DvolumePECSbefore.initPECS_3D(slices)
		//my3DvolumePECSafter.initPECS_3D(slices)
		//my3DvolumeSEM.initSEM_3D(slices, DSGetWidth(4), DSGetHeight(4))

		*/

		returncode = 1
	}
	catch
	{
		okdialog("something went wrong in setting up imaging: "+GetExceptionString())
		break
	}
	return returncode


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

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("IPrep_MoveToPECS")
	try
	{
		print("iprep move to pecs")
		myPW.updateA("sample: -> PECS")
		myStateMachine.SEM_to_PECS()
		myPW.updateA("sample: in PECS")
		print("iprep move to pecs done")
		returncode = 1 // to indicate success
	}
	catch
	{

		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString()+", system now dead/unsafe")
		returnDeadFlag().setDead(1, "movetopecs", GetExceptionString())
		returnDeadFlag().setSafety(0, "IPrep_MoveToPECS failed")
		returncode = 0 // irrecoverable error
		//okdialog("not allowed. "+ GetExceptionString())
		break // so that flow continues
		
	}

	return returncode
}

Number IPrep_MoveToSEM_workflow()
{
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("IPrep_MoveToSEM")
	try
	{
		print("iprep move to sem")
		myPW.updateA("sample: -> SEM")
		myStateMachine.PECS_to_SEM()
		myPW.updateA("sample: SEM")
		print("iprep move to sem done")
		returncode = 1 // to indicate success
	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString()+", system now dead/unsafe")
		returnDeadFlag().setDead(1, "movetosem", GetExceptionString())
		returnDeadFlag().setSafety(0, "IPrep_MoveToSEM failed")
		returncode = 0 // irrecoverable error
		//okdialog("not allowed. "+ GetExceptionString())
		break // so that flow continues
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

	// consistency of states (optional)

	return 1



}

Number IPrep_StartRun()
{
	print("UI: IPrep_StartRun")
	
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	if(!IPrep_consistency_check())
		return returncode // to indicate error

	if(!IPrep_check())
		return returncode // to indicate error


	// #TODO: this routine needs to know where to start in case of DM crash. 
	// # slice number is remembered, but also needs to know last succesfully completed step. 
	// # can query this with: myStateMachine.getLastCompletedStep() ("IMAGE", "MILL", "SEM", "PECS", "RESEAT")
	// we should wrap this and call this function IPrep_infer()

	try
	{
		
		// set stop and pause back to 0
		returnstopVar().set(0)
		returnPauseVar().set(0)
		
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
				myloop.seti(5) // start at image after mill
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
	myloop.init(9).StartThread()

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

Number IPrep_PauseRun()
{
	number returncode = 0

	// set pausevar
	returnPauseVar().set(1)

	returncode = 1 // to indicate success

	print("UI: IPrep_PauseRun")
	return returncode
}

Number IPrep_ResumeRun()
{
	number returncode = 0
	print("UI: Prep_ResumeRun")

	IPrep_StartRun()

	returncode = 1 // to indicate success
	
	return returncode
}

Number IPrep_StopRun()
{
	print("IPrep_StopRun")

	returnStopVar().set(1)

	return 1
}

Number IPrep_Image_single()
{
	// #DEPRECIATED, replaced by IPrep_image()
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	try
	{
		// tell the state machine it is time to take an image
		myStateMachine.start_image()

		// Update GMS status bar - SEM imaging started
			myPW.updateB("SEM imaging...")	

		// Goto saved specimen ROI location using SEM stage
			//object mySI = myWorkflow.returnSEM().returnStoredImaging()
			object mySI = returnSEMCoordManager().getCoordAsCoord("StoredImaging")
			number xx,yy,zz
			xx=mySI.getX()
			yy=mySI.getY()
			zz=mySI.getZ()
			//if (zz > 5)	// safety check, make sure tags are set -- should do proper in bounds checking
			myWorkflow.returnSEM().goToStoredImaging()

		// Set SEM focus to saved value
			number saved_focus = EMGetFocus()/1000	// initialize to current value (in case tag is empty)
			string tagname = "IPrep:SEM:WD:value"
			if ( GetPersistentNumberNote( tagname, saved_focus ) )
			{
				EMSetFocus( saved_focus*1000 )
//				EMWaitUntilReady()
			}

		// Workaround for Quanta SEM magnification bug (changes mag at SEM after some unknown action, but mag query gives original (now incorrect) mag) #TODO:Fix
//			WorkaroundQuantaMagBug()

		// Unblank SEM beam
//			FEIQuanta_SetBeamBlankState(0)
//			EMWaitUntilReady()
//			sleep(1)	// Beam on stabilization delay, #TODO: Move to tag

		// Autofocus, if enabled in tag
		tagname = "IPrep:SEM:AF:Enable"
		number afs_enable = 0
		if ( GetPersistentNumberNote( tagname, afs_enable ) )
			if ( afs_enable )
			{
				afs_run()		// Autofocus command - #TODO: configure properly, turn off stig checking
				number afs_sleep = 1	// seconds of delay
				sleep( afs_sleep )

				number current_focus = myWorkflow.returnSEM().measureWD()
				number change = current_focus - saved_focus
				result("Autofocus changed focus value by "+change+" mm\n")

			// Set "default/desired" focus to autofocus value - subsequent images will use this
				myWorkflow.returnSEM().setDesiredWD(current_focus)
			}

			// If afs_enable tag is set to a negative value, do autofocus one time and then turn off
			if ( afs_enable < 0 )
			{
				afs_enable = 0
				SetPersistentNumberNote( tagname, afs_enable )
			}

		// Acquire Digiscan image, use "Capture" settings
			image temp_slice_im
			AcquireDigiscanImage( temp_slice_im )


		
		// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
		// if tag exists
		number pixel_threshold = 500
		tagname = "IPrep:SEM:Emission check threshold"
		if(GetPersistentNumberNote( tagname, pixel_threshold ))
		{
			number avg = average( temp_slice_im )

			if ( avg < pixel_threshold )
			{
				// average image value is less than threshold, assume SEM emission problem, pause acq
				string str = datestamp()+": Average image value ("+avg+") is less than emission check threshold ("+pixel_threshold+")\n"
				print(""+ str )
				string str2 = "\nAcquisition has been paused.\n\nCheck SEM is working properly and press <Continue> to resume acquisition, or <Cancel> to stop."
				string str3 = "\n\nNote: Threshold can be set at global tag: IPrep:SEM:Emission check threshold"
				if ( !ContinueCancelDialog( str + str2 +str3 ) )
				{
						str = datestamp()+": Acquisition terminated by user" 
						print(str)		
				}
			}
			else
			{
				result( datestamp()+": Average image value ("+avg+") is greater than emission check threshold ("+pixel_threshold+"). SEM emission assumed OK.\n" )	
			}

		}
		

		// Save Digiscan image
			IPrep_saveSEMImage(temp_slice_im, "digiscan")

		// Close Digiscan image
			ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
			imdoc.ImageDocumentClose(0)
			
		// Update GMS status bar - SEM imaging done
			myPW.updateB("SEM imaging completed")
			print(datestamp()+": SEM mag 2 = "+EMGetMagnification())

		// tell the state machine taking images is done
		myStateMachine.stop_image()

		returncode = 1

	}
	catch
	{
		
		// system caught unhandled exception and is now considered dead/unsafe
		print("exception caught in iprep_image(): "+GetExceptionString())

		// #TODO: an exception in iprep_imaging is most likely safe
		returnDeadFlag().setDeadUnSafe()

		break // so that flow continues

	}

	return returncode

/* // old code thijs

	print("IPrep_Image")

		// initiate workflow to align, image, save data
		print("imaging started")
		myPW.updateB("imaging started")
if (XYZZY)		
{
		// do pre-imaging, unblanking, ensuring WD and kV are correct etc
		myStateMachine.start_image()
		
		// perform alignment step
		IPrep_Align()

		// *** repeat for each definition *** 
		// one definition for now

		// set parameters
		// can configure (on per image basis): mag, height, width, dwelltime

		myWorkflow.returnSEM().setDesiredWD(imagingWD)

if (XYZZY)
	{

		myWorkflow.returnSEM().setMag(imageMag)
	}
		// set the digiscan configuration. 2 = capture as defined by UI
		myWorkflow.returnDigiscan().config(2)

		// take image with digiscan
		// TODO: do not hardcode exposure, but use pecs specific acquisition instead
		image temp_slice_im
		myWorkflow.returnDigiscan().acquire(temp_slice_im)
if (XYZZY)
	{
		
		// add image to 3D volume and update 
		my3DvolumeSEM.addSlice(temp_slice_im)
		my3DvolumeSEM.show()
	}
		// save image to disk in defined subdir
		IPrep_saveSEMImage(temp_slice_im, "digiscan")
			
		// *** end repeat *** 

		// do post-imaging
		myStateMachine.stop_image()  

		myPW.updateB("imaging done")
		print("imaging done")

		// make sure beam gets turned off and things like that
		myWorkflow.postImaging()


*/

}

number IPrep_image()
{
	// supports multi ROI

	number returncode = 0

	try
	{

		// tell the state machine it is time to image
		myStateMachine.start_image()

		// get the ROI (default/StoredImaging in this case)
		object myROI 
		string name1 = "StoredImaging"
		if (!returnROIManager().getROIAsObject(name1, myROI))
		{
			print("IMAGE: tag does not exist!")
			return returncode
		}

		// Update GMS status bar - SEM imaging started
		myPW.updateB("SEM imaging...")	

		// go to ROI
		print("IMAGE: going to location: "+myROI.getName())
		myWorkflow.returnSEM().goToImagingPosition(myROI.getName())
		
		// focus
		if (myROI.getAFMode() == 1) //autofocus on every slice
		{
			print("IMAGE: autofocusing")
			//IPrep_autofocus()
			number afs_sleep = 1	// seconds of delay
			sleep( afs_sleep )

			number current_focus = myWorkflow.returnSEM().measureWD()	
			number saved_focus = returnROIManager().getFocus()
			number change = current_focus - saved_focus
			print("IMAGE: Autofocus changed focus value by "+change+" mm")
		}
		else if (myROI.getAFMode() == 2) // no autofocus, use stored value
		{
			print("IMAGE: focus is: "+myROI.getFocus())
			myWorkflow.returnSEM().setDesiredWD(myROI.getFocus()) // automatically sets it after storing it in object
		}

		// brightness
		if(returnROIEnables().brightness())
		{
			print("IMAGE: brightness is: "+myROI.getBrightness())
			myROI.getBrightness()
		}

		// contrast
		if(returnROIEnables().contrast())
		{
			print("IMAGE: contrast is: "+myROI.getContrast())
			myROI.getContrast()
		}

		// mag
		if(returnROIEnables().mag())
		{
			print("IMAGE: magnification is: "+myROI.getMag())
			myROI.getMag()
		}

		// voltage
		if(returnROIEnables().voltage())
		{
			print("IMAGE: voltage is: "+myROI.getVoltage())
			myROI.getVoltage()
		}

		// ss
		if(returnROIEnables().ss())
		{
			print("IMAGE: spot size is: "+myROI.getss())
			myROI.getss()
		}	

		// stigx
		if(returnROIEnables().stigx())
		{
			print("IMAGE: stigmation in X is: "+myROI.getStigx())
			myROI.getStigx()
		}

		// stigy
		if(returnROIEnables().stigy())
		{
			print("IMAGE: stigmation in Y is: "+myROI.getStigy())
			myROI.getStigy()
		}

		// Acquire Digiscan image, use digiscan parameters saved in ROI
		
		taggroup dsp = myROI.getDigiscanParam()

		image temp_slice_im
		
		// digiscan
		// can set digiscan parameter taggroup from this ROI to overwrite 'capture' settings
		//myWorkflow.returnDigiscan().config(dsp)
		// or use digiscan parameters as setup in the normal 'capture' at this moment
		myWorkflow.returnDigiscan().config()

		myWorkflow.returnDigiscan().acquire(temp_slice_im)


		//AcquireDigiscanImage(temp_slice_im )
		
		// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
		// if tag exists
		number pixel_threshold = 500
		string tagname = "IPrep:SEM:Emission check threshold"
		if(GetPersistentNumberNote( tagname, pixel_threshold ))
		{
			number avg = average( temp_slice_im )

			if ( avg < pixel_threshold )
			{
				// average image value is less than threshold, assume SEM emission problem, pause acq
				string str = datestamp()+": Average image value ("+avg+") is less than emission check threshold ("+pixel_threshold+")\n"
				print(""+ str )
				string str2 = "\nAcquisition has been paused.\n\nCheck SEM is working properly and press <Continue> to resume acquisition, or <Cancel> to stop."
				string str3 = "\n\nNote: Threshold can be set at global tag: IPrep:SEM:Emission check threshold"
				if ( !ContinueCancelDialog( str + str2 +str3 ) )
				{
						str = ": Acquisition terminated by user" 
						print("IMAGE: "+str)	
						return returncode	
				}
			}
			else
			{
				print("IMAGE: Average image value ("+avg+") is greater than emission check threshold ("+pixel_threshold+"). SEM emission assumed OK." )	
			}

		}
		

		// Save Digiscan image
		IPrep_saveSEMImage(temp_slice_im, "digiscan")

		// Close Digiscan image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)
			
		// add image to 3D volume and update 
		// quietly ignore if stack is not initialized
		try
		{
			my3DvolumeSEM.addSlice(temp_slice_im)
			my3DvolumeSEM.show()
		}
		catch
		{
			print("ignoring 3D volume stack")
			break
		}

		// Update GMS status bar - SEM imaging done
		myPW.updateB("SEM imaging completed")
		print("IMAGE: SEM mag 2 = "+EMGetMagnification())

		// do post-imaging
		myStateMachine.stop_image()  

		myPW.updateB("imaging done")
		print("imaging done")

		returncode = 1

	}
	catch
	{
		
		// system caught unhandled exception and is now considered dead/unsafe
		print("exception caught in iprep_image(): "+GetExceptionString())

		// an exception in iprep_imaging is most likely safe
		returnDeadFlag().setDead(1, "SEM", "exception in iprep_image: "+GetExceptionString)

		//returnDeadFlag().setDeadUnSafe()

		break // so that flow continues

	}

	return returncode

}


number IPrep_acquire_ebsd()
{
	print("IPrep_acquire_ebsd")
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

}


Number IPrep_Pecs_Image_beforemilling()
{
	// take image in PECS system before milling

	number returncode = 0
	try
	{
		image temp_slice_im

		// Acquire image, show it briefly, save it
		acquire_PECS_image( temp_slice_im )
		temp_slice_im.showimage() // only show if image is not a null image
		IPrep_savePECSImage(temp_slice_im, "pecs_camera_beforemilling")
		
		// Close image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)
		returncode = 1
	}
	catch 
	{
	
		// system caught unhandled exception
		print("pecs camera exception during acquisition before milling: "+GetExceptionString())
		break // so that flow continues

	}

	return returncode	

}



Number IPrep_Pecs_Image_aftermilling()
{
	// take image in PECS system after milling

	number returncode = 0
	try
	{
		image temp_slice_im

		// Acquire image, show it briefly, save it
		acquire_PECS_image( temp_slice_im )
		temp_slice_im.showimage() // only show if image is not a null image
		IPrep_savePECSImage(temp_slice_im, "pecs_camera_aftermilling")
		
		// Close image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)
		returncode = 1
	}
	catch 
	{
	
		// system caught unhandled exception
		print("pecs camera exception during acquisition after milling: "+GetExceptionString())
		break // so that flow contineus

	}

	return returncode
}



Number IPrep_Mill()
// Assumes sample is in PECS
// Mills sample
{
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
		
		print("milling done. new slice number: "+IPrep_sliceNumber())
	
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

Number IPrep_MoveToPECS()
{
		
	if(!IPrep_MoveToPECS_workflow())
	{
		okdialog("Did not finish transfer to PECS. check log")
	
	}

	return 1
}

Number IPrep_MoveToSEM()
{
	if(!IPrep_MoveToSEM_workflow())
	{
		okdialog("Did not finish transfer to SEM. check log")
	
	}

	return 1
}

Number IPrep_reseat()
{
	// used to pick up the sample from the PECS and put it back 
	// use after sample vacuum transfer to make sure images taken in the PECS have the carrier 
	// at the right location in the dovetail

	// called manually from menu before workflow starts

	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("IPrep_reseat")
	try
	{
		print("reseating sample")
		myPW.updateA("sample: -> reseating")
		myStateMachine.reseat()
		myPW.updateA("sample: done reseating")
		print("reseating done")
		returncode = 1 // to indicate success
	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		print(GetExceptionString()+", system now dead/unsafe")
		returnDeadFlag().setDead(1, "", GetExceptionString())
		returnDeadFlag().setSafety(0, "reseating failed")
		returncode = 0 // irrecoverable error
		okdialog("not allowed. "+ GetExceptionString())
		break // so that flow contineus
	}
	return returncode

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

		// if stop button is pressed or irrecoverable error ocuured, stop loop
		if (returnStopVar().get() || returnval == 0)
		{
			returnstopVar().set(0) // set stopvar back to 0
			IPrep_abortrun() // send UI stop command, tells ui elements to exit loop running state
			returnPauseVar().set(0) // set pausevar back to 0, just in case in was pressed
			return 0 
		}

		// if pause button is pressed, stop loop and wait for resume or stop
		if (returnPauseVar().get())
		{
			returnPauseVar().set(0) // set pausevar back to 0
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
					self.print("loop: skipping this step")
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
					self.print("loop: skipping this step")
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
				number returnval = IPrep_MoveToPECS_workflow()
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
					self.print("loop: skipping this step")
					returnval = 1
				}
				
				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==5) // mill, do not repeat
			{
				aStepTimer.tick("mill")

				self.print("loop: i = 5, milling")
				number returnval = IPrep_mill()
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
					self.print("loop: skipping this step")
					returnval = 1
				}				

				if (!self.process_response(returnval, 0)) // dont repeat for now
					self.stop()	

			}
			else if (i==7) // move to sem
			{
				aStepTimer.tick("move to sem")

				self.print("loop: i = 7, move to sem")
				number returnval = IPrep_MoveToSEM_workflow()
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
			IPrep_cleanup()
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

	//IPrep_consistency_check() // check consistency of workflowstates and hardware

}
catch
{
	result("exception caught at highest level\n")
	print(GetExceptionString())
}

// save global tags to disk
ApplicationSavePreferences()

result("iPrep_main: done with execution, idle\n")


