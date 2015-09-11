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
object my3DvolumePECS
*/
/* #TODO: delete
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

// the object that will launch as a thread to see if the PECS is still useable
object statusThread 

interface I_statusCheck
{
	object init(object self);
	void stop(object self);
	void RunThread(object self);
}

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


void IPrep_Abort()
{
	print("abort called, aborting run stack...")
	IPrep_AbortRun()
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


void PECS_CAM_acquire( image &img )
// Used by acquire_PECS_image
{
	number camID = CameraGetActiveCameraID( )
	number processing = CameraGetUnprocessedEnum( )
	CameraPrepareForAcquire( camID )
	img := CameraAcquire( camID )
}


void acquire_PECS_image( image &img )
// JH version
// Use this routine to acquire a PECS image in any PECS stage position.
// PECS should not be milling - this is not tested for
// Uses default PECS camera acquire settings
// Image is not displayed
// Turns off illumination on exit
// TODO: migrate to pecscamera class
{
	object myWorkflow = returnWorkflow()
	object myStateMachine = returnStateMachine()

// Check if stage is up (needs to be up for imaging)
	string first_stagepos = myWorkflow.returnPecs().getStageState()
	if ( first_stagepos != "up" )
	{
// If not up then raise it
		result( datestamp()+": PECS stage in down position. Raising to up position.\n" )
		myWorkflow.returnPecs().moveStageUp()

		string current_stagepos = myWorkflow.returnPecs().getStageState()
		if ( current_stagepos != "up" )
			throw( "Problem moving stage to up position. Currently at:"+current_stagepos )

		result( datestamp()+": PECS stage in up position.\n" )
	}

// Force PECS shutter open (code from Steve Coyle 20150805)
	PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_07", "0")   //works set  SO valve
	PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_07", "1")   //works set  SO valve

// Light on, acquire, light off
	myWorkflow.returnPecs().ilumOn()
	PECS_CAM_acquire( img )
	myWorkflow.returnPecs().ilumOff()
	
// If stage was originally down, then return stage to down position
	if ( first_stagepos != "up" )
	{
		result( datestamp()+": PECS stage in up position. Returning to down position.\n" )
		myWorkflow.returnPecs().moveStageDown()
		string current_stagepos = myWorkflow.returnPecs().getStageState()
		if ( current_stagepos != "down" )
			throw( "Problem moving stage to down position. Currently at:"+current_stagepos )

		result( datestamp()+": PECS stage returned to down position.\n" )
	}
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

void IPrep_init()
{
	// starts when IPrep DM module starts
	// initializes workflow object, establishes connection with hardware and saves positions for transfers

	try
	{
		print("iprep init")

		// init iprep workflow and set the default positions in tags
		myWorkflow.init()
		
		// save calibrated positions for transfer
		myWorkflow.setDefaultPositions()

		// hand over workflow object to state machine, who handles allowed transfers and keeps track of them
		// get initial state from tag
		myStateMachine.init(myWorkflow)



		print("current slice: "+IPrep_sliceNumber())
		myPW.updateC("slice: "+IPrep_sliceNumber())
		myPW.updateB("idle")
		myPW.updateA("sample: "+myStateMachine.getCurrentWorkflowState())
		print("iprep init done")
	}
	catch
	{
		result("exception during init"+ GetExceptionString() + "\n" )
	}
}

number IPrep_continous_check()
{
	// check to see if PECS is still functioning well. lauch as separate thread. 
	// call IPrep_Abort() if triggered

	number a, t
	a = myWorkflow.returnPECS().argonCheck()
	t = myWorkflow.returnPECS().TMPCheck()

	if (a && t)
		return 1
	else
	{	
		print("argon check failed: "+a+", tmp check: "+t)
		return 0
	}

}

/*
void IPrep_Align()
{

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

void IPrep_StoreCurrentSEMPosition()
{
	// stores current position as StoredImaging
	myWorkflow.returnSEM().saveCurrentAsStoredImaging()
}

void IPrep_StoreSEMPositionAsStoredImaging(number x, number y, number z)
{
	// stores custom position as StoredImaging
	myWorkflow.returnSEM().saveCustomAsStoredImaging(x,y,z)
}

void IPrep_cleanup()

{
	print("cleanup called")
	/*
	if (XYZZY)
		{

		// delete the digiscan parameters created for 
		DSDeleteParameters( alignParamID )

		// turn off HV
		if(ContinueCancelDialog( "turn off HV?" ))
			myWorkflow.returnSEM().HVOff()

		// delete the digiscan parameter array
		DSDeleteParameters( alignParamID )
	}
	*/
	// unlock PECS UI
	myWorkflow.returnPECS().unlock()

	// stop thread that checks PECS
	try
		statusThread.stop()
	recover
		print("no statusthread running")


}
/*
Number IPrep_Setup_Imaging()
{
	print("IPrep_Setup_Imaging")
	try
	{
		// setup the imaging parameters and saves them 
		// run this after manually surveying
		// beam is assumed to be on at this point

		// TODO: this query structure needs to be neatened up
		if(ContinueCancelDialog( "is digiscan configured correctly?" ))
		{
			// save workingdistance used now during preview in SEM class so that when taking 
			// an actual image we can set it back to that value
			// this value is the same for each image taken

			if (XYZZY)
				{
				imagingWD = myWorkflow.returnSEM().measureWD()
				myWorkflow.returnSEM().setDesiredWD(imagingWD)
				print("working distance to do imaging at: "+imagingWD)

						// 3D volume stuff, number of slices in 3D block
						// make the displayed 3D stack of digiscan images the size of what the capture setting is
						number slices = 10
						my3DvolumeSEM = alloc(IPrep_3Dvolume)
						my3DvolumePECS = alloc(IPrep_3Dvolume)
						my3DvolumePECS.initPECS_3D(slices)
						my3DvolumeSEM.initSEM_3D(slices, DSGetWidth(2), DSGetHeight(2))
					
						// set the voltage to be used for every image
						// TODO: get this from dialog or from somewhere, now just set to 2
						// may want to measure this and set it to the value it is right now
						myWorkflow.returnSEM().setDesiredkV(IPrepVoltage)

						// TODO: register the coordinate to come back to
						// right now this is done manually

						// turn on beam
						// myWorkflow.returnSEM().HVOn()

						// blank the beam
						myWorkflow.returnSEM().blankOn()
				}
			imagingConfigured = 1

		} 
		else
		{
			imagingConfigured = 0

		}
	}
	catch
	{
		if(!ContinueCancelDialog( GetExceptionString()+". continue workflow?" ))
		{
			print("stopped after exception: "+GetExceptionString())
			IPrep_cleanup()
			IPrep_Abort()
		}
		else
		{
			print("continuing after exception like nothing happened")
			break
		}
	}
	return 1;
}
*/


// *** methods directly called by UI elements ***

Number IPrep_foobar()
{
	// test function for error handling framework

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
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus
	}

	return returncode
}

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
		returnDeadFlag().setDeadUnSafe()

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
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus
	}
	return returncode
}


Number IPrep_StartRun()
{
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	try
	{

		if (!returnDeadFlag().checkAliveAndSafe())
			return returncode // to indicate error	

		print("IPrep_StartRun")
		if (myStateMachine.getCurrentWorkflowState() != "SEM")
		{
			print("cannot start workflow from "+myStateMachine.getCurrentWorkflowState()+", aborting")
			return returncode
		}

		if (!IPrep_continous_check())
		{
			print("PECS system not at vacuum or argon leak, aborting")
			return returncode
		}


		// lockout PECS UI
		myWorkflow.returnPECS().lockOut()

		// launch the thread that is going to check the argon pressure and TMP speed
		// TODO: make sure this does cause triggers when valve is just actuated
		//statusThread = alloc(statusCheck)
		//statusThread.init().StartThread()

		returncode = 1 // to indicate success

	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus

	}


	return returncode
}

Number IPrep_PauseRun()
{
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	returncode = 1 // to indicate success

	print("IPrep_PauseRun")
	return returncode
}

Number IPrep_ResumeRun()
{
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	returncode = 1 // to indicate success
	
	print("IPrep_ResumeRun")
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



		// Update GMS status bar - SEM imaging started
			myPW.updateB("SEM imaging...")	

		// Goto saved specimen ROI location using SEM stage
			object mySI = myWorkflow.returnSEM().returnStoredImaging()
			number xx,yy,zz
			xx=mySI.getX()
			yy=mySI.getY()
			zz=mySI.getZ()
			if (zz > 5)	// safety check, make sure tags are set -- should do proper in bounds checking
				myWorkflow.returnSEM().goToStoredImaging()

		// Set SEM focus to saved value
			number saved_focus = EMGetFocus()/1000	// initialize to current value (in case tag is empty)
			string tagname = "IPrep:SEM:WD:value"
			if ( GetPersistentNumberNote( tagname, saved_focus ) )
			{
				EMSetFocus( saved_focus*1000 )
				EMWaitUntilReady()
			}

		// Workaround for Quanta SEM magnification bug (changes mag at SEM after some unknown action, but mag query gives original (now incorrect) mag) #TODO:Fix
			WorkaroundQuantaMagBug()

		// Unblank SEM beam
			FEIQuanta_SetBeamBlankState(0)
			EMWaitUntilReady()
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
			FEIQuanta_SetBeamBlankState(1)

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
							IPrep_Abort()	// #Todo: Check this exits correctly
							IPrep_cleanup()
							str = datestamp()+": Acquisition terminated by user" 
							result( str +"\n" )
							Throw( str )
					}
				}
				else
					result( datestamp()+": Average image value ("+avg+") is greater than emission check threshold ("+threshold+"). SEM emission assumed OK.\n" )

		}

		// Save Digiscan image
			IPrep_saveSEMImage(temp_slice_im, "digiscan")

		// Close Digiscan image
			ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
			imdoc.ImageDocumentClose(0)
			
		// Update GMS status bar - SEM imaging done
			myPW.updateB("SEM imaging completed")
			result(datestamp()+": SEM mag 2 = "+EMGetMagnification()+"\n")

		returncode = 1

	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
		returnDeadFlag().setDeadUnSafe()

		break // so that flow contineus

	}



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
		myStateMachine.stop_image()  //###

		myPW.updateB("imaging done")
		print("imaging done")

		// make sure beam gets turned off and things like that
		myWorkflow.postImaging()


*/
	return returncode
}


		


Number IPrep_Mill()
// Assumes sample is in PECS
// Mills sample, saves image
{
	number returncode = 0

	if (!returnDeadFlag().checkAliveAndSafe())
		return returncode // to indicate error

	print("IPrep_Mill")
	try
	{
		// initiate workflow to start milling
		print("PECS milling started")
		myPW.updateB("PECS milling started")
		image temp_slice_im

// If on the first slice (which is slice 1), acquire an image before milling
		if ( IPrep_sliceNumber() == 1 )
		{
		// Acquire image, show it briefly, save it
			acquire_PECS_image( temp_slice_im )
			temp_slice_im.showimage()
			IPrep_savePECSImage(temp_slice_im, "pre_milling")
		// Close image
			ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
			imdoc.ImageDocumentClose(0)
		}

// Mill sample 
		number simulation = 0
		myStateMachine.start_mill(simulation, 4000)	// (timeout of 4000s)
	// Acquire image, show it briefly, save it
		acquire_PECS_image( temp_slice_im )
		temp_slice_im.showimage()
		IPrep_savePECSImage(temp_slice_im, "pecs_camera")
	// Close image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)

		myPW.updateB("PECS milling done")
		
		print("milling done. new slice number: "+IPrep_sliceNumber())
		
		returncode = 1
	}
	catch
	{
		// system caught unhandled exception and is now considered dead/unsafe
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
	// take one last image
	// then turn beam off etc
	print("IPrep_End_Imaging")
	IPrep_Image()
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
	return myStateMachine.getPercentage()
}

// *** actual workflow following ***

try
{
	// this get executed when this script starts / DM starts

	Iprep_init()

}
catch
{
	result("exception caught at highest level\n")
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("iPrep_main: done with execution, idle\n")


