// $BACKGROUND$

// this file contains function definitions. needs to be installed with other hardware class 
// scripts as library

number XYZZY = 0	// set to 1 to enable TH workflow

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

object myPW = alloc(progressWindow)
// convention for progresswindow:
// A: sample status
// B: operation
// C: slice number

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
	result("main: "+str1+"\n")
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





void AcquireDigiscanImage( image &img )
// JH version
// #TODO: migrate to digiscan class
{
	Number paramID = 2	// capture ID
	number width, height,pixeltime,linesync,rotation
	width = DSGetWidth( paramID )
	height = DSGetHeight( paramID)
	pixelTime = DSGetPixelTime( paramID )
	lineSync = DSGetLineSynch( paramID )
	rotation = DSGetRotation( paramID )

	number signed = 0	// Image has to be of type unsigned-integer
	number datatype = 2	// Currently this is hard coded - no way to read from DS plugin - #TODO: fix
	number signalIndex, imageID
	signalIndex = 0		// Only 1 signal supported now - #TODO: fix
	string name = DSGetSignalName( signalIndex )

	img := IntegerImage( name, dataType, signed, width, height )        
	imageID = ImageGetID( img )

	// Create temp parameter array
	number paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 
	result("paramID="+paramID2+"\n")
	// if paramID is used (Capture) then an extra copy of the image is made by GMS3 after acquire. 
	// Doesnt happen if new parameter set is made

	// Assign <img> to DS signal
	number selected    = 1 // acquire this signal
	DSSetParametersSignal( paramID2, signalIndex, dataType, selected, imageID )

	number continuous  = 0 // 0 = single frame, 1 = continuous
	number synchronous = 1 // 0 = return immediately, 1 = return when finished
	DSStartAcquisition( paramID2, continuous, synchronous )

	// Delete the parameter array temporarily created
	DSDeleteParameters( paramID2 )
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
		print("PECS stage:sensordata do not agree with previous save state. either caused by a malfunction, powerloss or argon pressure loss")
		returnDeadFlag().setDead(1, "PECS", "pecs stage not in well defined position")
		
		// not unsafe yet
		//returnDeadFlag().setSafety(0, "pecs stage not in well defined position")
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

	// dock
	// does not seem like dock needs this. unlikely to be in unknown state

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
		result("exception during init"+ GetExceptionString() + "\n" )
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
			throw("sample not in PECS!")

		// vent
		if (!okcanceldialog("please vent and press ok when dock is replaced and connected. make sure dock motor axis is aligned along y axis"))
			throw("user aborted during vent")

		// confirm alignment in x
			// store rotation #todo

		// change mode tag
		setSystemMode(mode)

		// run iprep_init to initialize all hardware again
		IPrep_init()

		// clamp and unclamp and confirm

		if (okcanceldialog("testing dock in clamped and unclamped position, press ok when ready"))
		{
			myWorkflow.returnSEMDock().unclamp()
			myWorkflow.returnSEMDock().clamp()
		}
		else
			throw("user aborted check")
	}
	catch
	{
		print("mode change did not succeed: exception: "+GetExceptionString())
		
		// set dead
		returnDeadFlag().setDead(1, "mode", "mode change error: "+GetExceptionString())
		// set unsafe
		returnDeadFlag().setSafety(0, "mode change error: "+GetExceptionString())
		return returncode
	}

	returncode = 1

	return returncode

}






/* DEPRECATED
void IPrep_Align()
{
// may not be needed anymore, alignment is now done in iprep_imaging
	if (XYZZY)
	{
		// align image, called by IPrep_image()
		print("alignment started")
		
		// define a digiscan parameterset used for alignment
		alignParamID = DSCreateParameters( alignWidth, alignHeight, 0, alignDwell, 0 )
		// go to 2 grids (front and back) and take images there
		myWorkflow.returnSEM().setMag(150)
		myWorkflow.returnSEM().setDesiredWD(gridWD)
		myWorkflow.returnDigiscan().config(alignParamID)
		
		myWorkflow.returnSEM().goToHighGridBack()
		image alignBack
		myWorkflow.returnDigiscan().acquire(alignBack)
		IPrep_saveSEMImage(alignBack, "alignBack")

		myWorkflow.returnSEM().goToHighGridFront()
		image alignFront
		myWorkflow.returnDigiscan().acquire(alignFront)
		IPrep_saveSEMImage(alignFront, "alignFront")

		// got to stored imaging
		// TODO: make sure this point is stored in DM somewhere
		// TODO: can be different from actual high res image
		myWorkflow.returnSEM().setDesiredWD(imagingWD)
		myWorkflow.returnSEM().goToStoredImaging()
		
		image align_im
		myWorkflow.returnSEM().setMag(alignMag)
		myWorkflow.returnDigiscan().config(alignParamID)
		myWorkflow.returnDigiscan().acquire(align_im)
		IPrep_saveSEMImage(align_im, "alignment")

		// loop and servo off of feedback signal until repeatability criterion is met, then return
		print("alignment done")
	}
}
*/






void IPrep_cleanup()
{
	// runs when there is a problem detected to return to manageable settings, ie:
	// unlock the pecs, turn off high voltage etc
	print("cleanup called")
	

	// delete the digiscan parameters created for 
	//DSDeleteParameters( alignParamID )

	
	// turn off HV
	if(ContinueCancelDialog( "turn off HV?" ))
		myWorkflow.returnSEM().HVOff()

	// unlock PECS UI
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
		// set WD in class to current value
		number imagingWD = myWorkflow.returnSEM().measureWD()
		myWorkflow.returnSEM().setDesiredWD(imagingWD)
		print("working distance to do imaging at: "+imagingWD)
		
		// set kv in class to current value (if needed, was needed for Quanta)
		//myWorkflow.returnSEM().setDesiredkV(IPrepVoltage)

		// register current coordinate to come back to
		myWorkflow.returnSEM().saveCurrentAsStoredImaging()

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

		returncode = 1
	}
	catch
	{
		okdialog("something went wrong: "+GetExceptionString())
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


// *** methods directly called by UI elements ***

Number IPrep_MoveToPECS()
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
		//print(GetExceptionString()+", system now dead/unsafe")
		//returnDeadFlag().setDead(1, "movetopecs", GetExceptionString())
		//returnDeadFlag().setSafety(0, "IPrep_MoveToPECS failed")
		returncode = 0 // irrecoverable error
		//okdialog("not allowed. "+ GetExceptionString())
		break // so that flow contineus
		
	}

	return returncode
}

Number IPrep_MoveToSEM()
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
		break // so that flow contineus
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
		//print(GetExceptionString()+", system now dead/unsafe")
		//returnDeadFlag().setDead(1, "", GetExceptionString())
		//returnDeadFlag().setSafety(0, "reseating failed")
		returncode = 0 // irrecoverable error
		okdialog("not allowed. "+ GetExceptionString())
		break // so that flow contineus
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
	// #todo



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

		if (myStateMachine.getCurrentWorkflowState() != "SEM")
		{
			print("cannot start workflow from "+myStateMachine.getCurrentWorkflowState()+", aborting")
			return returncode
		}


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

Number IPrep_PauseRun()
{
	number returncode = 0

	returncode = 1 // to indicate success

	print("UI: IPrep_PauseRun")
	return returncode
}

Number IPrep_ResumeRun()
{
	number returncode = 0
	print("UI: Prep_ResumeRun")

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	if(!IPrep_consistency_check())
		return returncode // to indicate error

	if(!IPrep_check())
		return returncode // to indicate error

	// send resume command

	returncode = 1 // to indicate success
	
	return returncode
}

Number IPrep_StopRun()
{
	print("IPrep_StopRun")
	return 1
}

Number IPrep_Image()
{
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
			//	myWorkflow.returnSEM().goToStoredImaging()

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
			sleep(1)	// Beam on stabilization delay, #TODO: Move to tag

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

		// Blank SEM beam
//			FEIQuanta_SetBeamBlankState(1)
		/*
		// Verify SEM is functioning properly - pause acquisition otherwise (might be better to do before AFS with a test scan, easier here)
		{
				number avg = average( temp_slice_im )
				number threshold = 500
				string tagname = "IPrep:SEM:Emission check threshold"
				GetPersistentNumberNote( tagname, threshold )

				if ( avg < threshold )
				{
					// average image value is less than threshold, assume SEM emission problem, pause acq
					string str = datestamp()+": Average image value ("+avg+") is less than emission check threshold ("+threshold+")\n"
					result( str )
					string str2 = "\nAcquisition has been paused.\n\nCheck SEM is working properly and press <Continue> to resume acquisition, or <Cancel> to stop."
					string str3 = "\n\nNote: Threshold can be set at global tag: IPrep:SEM:Emission check threshold"
					if ( !ContinueCancelDialog( str + str2 +str3 ) )
					{

							str = datestamp()+": Acquisition terminated by user" 
							print(str)
							
							iprep_abort()
					}
				}
				else
				{
					result( datestamp()+": Average image value ("+avg+") is greater than emission check threshold ("+threshold+"). SEM emission assumed OK.\n" )	
				}

		}
		*/
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
		print(GetExceptionString())

		// #TODO: an exception in iprep_imaging is most likely safe
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus

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

number IPrep_acquire_ebsd()
{
	print("IPrep_acquire_ebsd")
	// #todo: implement
	if (getSystemMode() == 'ebsd')
	{
		myStateMachine.
	}


}


Number IPrep_Pecs_Image_beforemilling()
{
	// take image in PECS system before milling

	image temp_slice_im

	// Acquire image, show it briefly, save it
	acquire_PECS_image( temp_slice_im )
	temp_slice_im.showimage() // only show if image is not a null image
	IPrep_savePECSImage(temp_slice_im, "pecs_camera_beforemilling")
	
	// Close image
	ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
	imdoc.ImageDocumentClose(0)


}



Number IPrep_Pecs_Image_aftermilling()
{
	// take image in PECS system after milling

	image temp_slice_im

	// Acquire image, show it briefly, save it
	acquire_PECS_image( temp_slice_im )
	temp_slice_im.showimage() // only show if image is not a null image
	IPrep_savePECSImage(temp_slice_im, "pecs_camera_aftermilling")
	
	// Close image
	ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
	imdoc.ImageDocumentClose(0)
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

Number IPrep_End_Imaging()
{
	// executed after final transfer

	// then turn beam off etc
	print("UI: IPrep_End_Imaging")
	//IPrep_Image()
	IPrep_cleanup()

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


