// no background
// $BACKGROUND$
// general IPrep (helper) functions used in various scripts

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

class deadFlagObject:object
{
	// sets two flags:
	// -dead/alive: is the system ready to be used or not. alive means everything is fine, dead means the system or subsystems need to be put in the right state(s) before continuing. 
	//	example: SEM gives an error while imaging. all state information of the IPrep is saved and the workflow can be recovered but we cannot continue until the SEM functions again
	// -safe/unsafe. if system is unsafe, it implies that the system failed in a way that is not recoverable without some complicated, manual set of operations and following these correctly
	//	will ensure the system does not destroy itself
	//	example: during transfer of sample to PECS, the parker system does not know where it is anymore. 

	// the setDead() method sets the flag and sets the errorcode and the device that set the error

	object deadFlag // flag that sets dead state
	object safetyFlag // flag that sets safety state
	object errorCode // errorcode 
	object deviceSet // the device that set the dead flag
	object exceptionMessage // if exception causes dead flag, log the exception thrown
	object unsafeReason // reason why unsafe flag set

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("deadFlag", level, text)
	}

	void print(object self, string str1)
	{
		result("deadFlag: "+str1+"\n")
		self.log(2,str1)

	}

	void deadFlagObject(object self)
	{
		// get deadflag
		deadFlag = alloc(statePersistance)
		safetyFlag = alloc(statePersistance)
		deviceSet = alloc(statePersistance)
		errorCode = alloc(statePersistanceNumeric)
		exceptionMessage = alloc(statePersistance)
		unsafeReason = alloc(statePersistance)
		deadFlag.init("flags:dead")
		safetyFlag.init("flags:safe")
		deviceSet.init("flags:device")
		errorCode.init("flags:errorcode")
		exceptionMessage.init("flags:exception")
		unsafeReason.init("flags:unsafeReason")

	}

	void setDead(object self, number code, string deviceName, string message)
	{
		// set whether system is dead or not, most informative version
		self.print("deadflag set to: dead from device: "+deviceName+" with errorcode: "+code)
		deadFlag.setState("1")
		deviceSet.setState(deviceName)
		errorCode.setNumber(code)
		exceptionMessage.setState(message)
	}

	void setDead(object self, number status)
	{
		// set whether system is dead or not, basic version
		self.print("deadflag set to " + status)
		deadFlag.setState(""+status)
	}

	void setSafety(object self, number status, string reason)
	{
		// set whether system is safe to operate
		self.print("safety flag set to " + status)
		safetyFlag.setState(""+status)
		unsafeReason.setState(reason)
	}	

	void setSafety(object self, number status)
	{
		// set whether system is safe to operate
		self.print("safety flag set to " + status)
		safetyFlag.setState(""+status)
	}

	number isDead(object self)
	{
		// is system dead (ie is flag set)?
		return val(deadFlag.getState())

	}

	number isSafe(object self)
	{
		// is system safe to operate (ie is flag set)?
		return val(safetyFlag.getState())
	}

	void setDeadSafe(object self)
	{
		self.setDead(1)
		self.setSafety(1)
	}

	void setDeadUnsafe(object self)
	{
		self.setDead(1)
		self.setSafety(0)
	}

	void setAliveSafe(object self)
	{
		self.setDead(0)
		self.setSafety(1)
	}

	number checkAliveAndSafe(object self)
	{
		if (!self.isDead() & self.isSafe())
			return 1
		else
		{
			self.print("system is: dead: "+self.isDead()+", safe: "+self.isSafe())
			return 0
		}
	}
	
	number checkDeadAndSafe(object self)
	{
		if (self.isDead() & self.isSafe())
			return 1
		else
			return 0
	}

	number lastErrorCode(object self)
	{
		return errorCode.getNumber()
	}

	string lastDevice(object self)
	{
		return deviceSet.getState()
	}

	string lastMessage(object self)
	{
		return exceptionMessage.getState()
	}

}

// *** functions for safety: check status of these critical components inside the classes by checking tags ***

class safetyMediator:object
{
	// predefine these objects

	object pecs
	object sem
	object transfer
	object gripper
	object dock

	// the mediator is the perfect place to change the progresswindow from
	object progresswindow
	
	void registerDock(object self, object obj)
	{
		dock = obj
		result("mediator: dock registered\n")
	}

	void registerPecs(object self, object obj)
	{
		pecs = obj
		result("mediator: pecs registered\n")
	}

	void registerSem(object self, object obj)
	{
		sem = obj
		result("mediator: sem registered\n")
	}

	void registerTransfer(object self, object obj)
	{
		transfer = obj
		result("mediator: transfer registered\n")
	}

	void registerGripper(object self, object obj)
	{
		gripper = obj
		result("mediator: gripper registered\n")
	}

	void registerProgressWindow(object self, object obj)
	{
		progresswindow = obj
		result("mediator: progresswindow registered\n")
	}	

	// *** test checks ***

	string checkGV(object self)
	{
		// make sure that method name is the same as method name called in body
		// in this case checkGV()
		// if you dont do that, you need to define the name of what to call in interface
		
		return pecs.checkGV()
	
	}

	number checkTransfer(object self)
	{
		return transfer.checkTransfer()
	}

	// *** real checks ***

	string getGVState(object self)
	{
		// returns gv state 
		
		string status
		//GetPersistentTagGroup().TagGroupGetTagAsString("IPrep:GVState:state", status)
		
		// check pecs for state
		status = pecs.getGVState()

		return status // open or closed or undefined
	}

	number getCurrentPosition(object self)
	{
		// returns the position of parker stage
		
		number pos
		// change to correct tag name
		//GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:parkerState:currentPosition", status)
		
		pos = transfer.getCurrentPosition()

		return pos // position of parker
	}

	string getSEMState(object self)
	{
		// returns the current state of the SEM stage
		string status
		
		// change to correct tag name 
		//GetPersistentTagGroup().TagGroupGetTagAsString("IPrep:SEMStage:state", status)
		
		status = sem.getSEMState()

		return status // sem state. "clear" or "pickup_dropoff" or "imaging"
	}

	string getStageState(object self)
	{
		// returns the current state of pecs stage
		string status
		
		status = pecs.getStageState()

		return status // "up", "down" or "undefined"

	}

	string getShutterState(object self)
	{
		// returns the current state of the coating shutter
		string status

		status = pecs.getShutterState()

		return status // "in", "out", "unknown"
	}

	number checkFWDCoupling(object self, number active)
	{
		// check if FWD is coupled correctly
		// active measn stage can move during check, passive that it does not
		// may not be used on nova if absolute stage coordinates work
		number status = sem.checkFWDCoupling(active)

		return status // 1 for correctly set, 0 for incorrectly set

	}

	string getGripperState(object self)
	{
		// check ithe state of the gripper
		return gripper.getGripperState() // open or closed

	}

	string detectMode(object self)
	{
		// check the type of dock installed
		string status
		status = dock.detectMode()

		return status // "ebsd", "planar", "disconnected" or "undefined"
	}

	string getDockState(object self)
	{
		// check if dock is clamped
		string status
		status = dock.getDockState()

		return status // "clamped", "unclamped", or "inbetween"
	}

	object returnPW(object self)
	{
		return progresswindow
	}

	// *** actions ***
	// experimental, not used in workflow yet

	void HVOff(object self)
	{
		// turn the high tension in the microscope off in case there is a problem
		sem.HVOff()
		result("mediator: turning high tension off\n")
	}

	// *** status ***
	// for later use by UI elements to show status of everything

	void printStatus(object self)
	{
		// list of outputs:
		// -HV status (on or off)
		// -dock status (clamped or unclamped)
		// -system mode (planar or ebsd)
		// -gripper pecs statestage state
		// -sem stage state
		// -parker position
		// -gv state

		// #todo

	}

	number bigCheck(object self)
	{
		// check intended to be run after start/resume is pressed
		// #todo
	}

	number littleCheck(object self)
	{
		// check intended to be run every workflow step
		// #todo
	}



}

class haltCheckObject:object
{
	// TODO: make sure tag is set correctly
	object haltFlag

	void haltCheckObject(object self)
	{
		// get haltflag
		haltFlag = alloc(statePersistance)
		haltFlag.init("flags:halt")
	}
	
	void resetHaltFlag(object self)
	{
		haltFlag.setState("0")
		result("haltFlag: reset to 0\n")
	}

	void setHaltFlag(object self)
	{
		haltFlag.setState("1")
		result("haltFlag: set\n")
	}

	void haltCheck(object self)
	{
		// check halt bit, if set, set back to 0 and throw exception
		if(haltFlag.getState()=="1")
		{	
			self.resetHaltFlag()
			result("haltFlag detected, halting..\n")
			throw("halt pressed")
			
		}
	}

}

number getProtectedModeFlag()
{
	// check protected mode flag

	TagGroup tg = GetPersistentTagGroup() 
	
	string current
	
	TagGroupGetTagAsString(tg,"IPrep:flags:protected", current )
	
	return val(current)
}

void continueCheck()
{
	// allow user to cancel out of current workflow set

	if(getProtectedModeFlag())
	{
		if(!ContinueCancelDialog( " continue?" ))
		{
			result("user manually aborted\n")
			throw("user opted not to continue")
		}
	}

}

void continueCheck(string message)
{
	// allow user to cancel out of current workflow set

	if(getProtectedModeFlag())
	{
		if(!ContinueCancelDialog( message + " continue?" ))
		{
			result("user manually aborted after "+message+"\n")
			throw(message + " user opted not to continue")
		}
	}

}

void manualHaltOptionShift()
{
	if (optiondown() & shiftdown())
	{
		result("user manually aborted with shift+option\n")
		throw("user aborted with shift+option")
	}
}

string getSystemMode()
{
	// return the current mode of the system, "ebsd" or "planar"
	string mode
	taggroup tg = GetPersistentTagGroup()
	TagGroupGetTagAsString(tg,"IPrep:simulation:mode", mode )
	return mode
}

void setSystemMode(string mode)
{
	// set the current mode of the system, "ebsd" or "planar"
	taggroup tg = GetPersistentTagGroup()
	TagGroupSetTagAsString(tg,"IPrep:simulation:mode", mode )

}

number getDockCalibrationStatus()
{
	// return state of dock calibration
	return GetTagValue("IPrep:flags:dockCalibrationStatus")
}

void setDockCalibrationStatus(number st)
{
	// set the state of dock calibration
	taggroup tg = GetPersistentTagGroup()
	TagGroupSetTagAsNumber(tg,"IPrep:flags:dockCalibrationStatus", st )
}


object deadFlag = alloc(deadFlagObject)

object returnDeadFlag()
{
	// returns the deadflag object
	return deadFlag
}

object haltFlag = alloc(haltCheckObject)

object returnHaltFlag()
{
	// returns the haltflag object
	return haltFlag
}

class stopVar:object
{
	// used to catch/set stop event
	number i

	void stopVar(object self)
	{
		i = 0
	}

	void set1(object self, number ii)
	{
		i = ii
	}

	number get1(object self)
	{	
		return i
	}

}

class pauseVar:object
{
	// used to catch/set pause event
	number i

	void pauseVar(object self)
	{
		i = 0
	}

	void set1(object self, number ii)
	{
		i = ii
	}

	number get1(object self)
	{	
		return i
	}

}

object myPauseVar = alloc(pauseVar)

object returnPauseVar()
{
	return myPauseVar
}

object myStopVar = alloc(stopVar)

object returnStopVar()
{
	return myStopVar
}

class timer: object
{
	// simple timer to measure overhead

	number tick_val
	number outp
	string namestring

	void init(object self, number disp)
	{
		// determine if this needs to print out on tock
		outp = disp
	}

	void tick(object self, string name1)
	{
		// start timer
		namestring = name1
		tick_val = GetOSTickCount()
	}

	void tock(object self)
	{
		// stop timer and print
		if (outp)
			debug("TIMER: elapsed time in "+namestring+": "+(GetOSTickCount()-tick_val)/1000+" s\n")	
	}

}



string IPrep_rootSaveDir()
{
	// get the root save path from the tag that the UI dialog saves it in

	string pointer
	GetPersistentTagGroup().TagGroupGetTagAsString("IPrep:Record Settings:Base Filename", pointer)

	//print("root dir is: "+pointer+"\n")
	return pointer
}

number IPrep_sliceNumber()
{
	Number nSlices
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", nSlices)
	print("N Slices = "+nSlices)
	return nSlices
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
	// saves front image, used for digiscan
	
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

void IPrep_saveSEMImage(image &im, string subdir, string name)
{
	// saves front image and saves as custom name, used for digiscan
	
	string DirPath = ""
	DirPath = PathExtractDirectory(IPrep_rootSaveDir(), 0)

	string FileNamePrefix = "IPREP_SEM"
	string FileNamePostfix = "_"+name+"_slice_"+right("000"+IPrep_sliceNumber(),4)
	
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
	// #todo: test, just copied from JH example; modified 20160701
	
	// NB: numbers are in Microns

	// Dear Thijs...you are going to hate this default focus mod. 

	string s1="Private:AFS Parameters"
	string s2="Focus accuracy"
	string s3="Focus limit (lower)"
	string s4="Focus limit (upper)"
	string s5="Focus search range"
	string s6="Stigmation enabled"
	
	string s7="Default focus"
	number n2,n3,n4,n5,n6,n7

	string str2 
	number focus_range_fraction = .1
	number focus = EMGetFocus()
	result(datestamp()+": current focus value before autofocus: "+focus+"\n")
	

	// Default focus
	str2 = s1+":"+s7
	n7=9001
	if (!GetPersistentNumberNote( str2, n7 ))
		{
			if ( !GetNumber( str2, n7, n7 ) ) 
			{
				n7 = 9000
				result("  USING DEFAULT FOCUS OF 9000 microns\n")
			}
			
			SetPersistentNumberNote( str2, n7 )
		}
		
	number default_focus=n7


	// number start_focus = EMGetFocus()
	number start_focus = default_focus
	EMSetFocus( start_focus )
	focus=start_focus
	result(datestamp()+": setting focus to (before AFS): "+start_focus+"\n")
	result("\n"+datestamp()+": start WD = "+(start_focus/1000)+"\n")

	number useDialog = 0 
	
	// old number JH
	//number focus_range = focus_range_fraction*focus
	//number focus_res = .0025*focus
	
	
	// new numbers thijs troubleshooting 20161128
	//number focus_range = 500
	//number focus_res = 20


	number AF_do_stig = 1
/*	
	// Focus accuracy
	str2 = s1+":"+s2
	GetPersistentNumberNote( str2, n2 )
	n2 = focus_res
	if ( useDialog) 
		if (!GetNumber( str2, n2, n2 ) ) exit(0)
		
	SetPersistentNumberNote( str2, n2 )

	// Focus limit (lower)
	str2 = s1+":"+s3
	GetPersistentNumberNote( str2, n3 )
	n3 = focus - focus * focus_range_fraction
		if ( useDialog) 
			if ( !GetNumber( str2, n3, n3 ) ) exit(0)
	SetPersistentNumberNote( str2, n3 )

	// Focus limit (upper)
	str2 = s1+":"+s4
	GetPersistentNumberNote( str2, n4 )
	n4 = focus + focus * focus_range_fraction
	if ( useDialog) 
		if ( !GetNumber( str2, n4, n4 ) ) exit(0)
	SetPersistentNumberNote( str2, n4 )

	// Focus search range
	str2 = s1+":"+s5
	GetPersistentNumberNote( str2, n5 )
	n5=focus_range
	if ( useDialog) 
		if ( !GetNumber( str2, n5, n5 ) ) exit(0)
	SetPersistentNumberNote( str2, n5 )
*/
	// Stigmation enabled
	str2 = s1+":"+s6
	n6=AF_do_stig
	GetPersistentNumberNote( str2, n6 )
	if ( useDialog) 
		if ( !GetNumber( str2, n6, n6 ) ) exit(0)
	SetPersistentNumberNote( str2, n6 )
	AF_do_stig=n6
	
	if ( AF_do_stig )
	{
		result("  Autofocus enabled with stigmation\n")
		AFS_Run()
	}
	 else
	{
		result("  Autofocus enabled without stigmation\n")
		AF_Run()
	}

	while( AFS_IsBusy() )
	{
		sleep( 1 )
		result(".")
	}

	number end_focus = EMGetFocus()
	if ( abs(end_focus-default_focus) > 5000 )
	{
		okdialog( "WARNING: focus is not within 5mm of the default focus" )
	}	
	
	result(datestamp()+": final WD = "+(end_focus/1000)+"\n")
		result("  Change in focus = "+((start_focus-end_focus)/1000)+"\n")

	// now set new AF default focus value to new value
	str2 = s1+":"+s7
	SetPersistentNumberNote( str2, end_focus )

}



// testing
/*
returnDeadFlag().setAliveSafe()
result("alivesafe: "+returnDeadFlag().checkAliveAndSafe()+"\n")
result("deadsafe: "+returnDeadFlag().checkDeadAndSafe()+"\n")
returnDeadFlag().setDeadSafe()
result("alivesafe: "+returnDeadFlag().checkAliveAndSafe()+"\n")
result("deadsafe: "+returnDeadFlag().checkDeadAndSafe()+"\n")
returnDeadFlag().setDeadUnSafe()
result("alivesafe: "+returnDeadFlag().checkAliveAndSafe()+"\n")
result("deadsafe: "+returnDeadFlag().checkDeadAndSafe()+"\n")
*/

// testing

//result(getProtectedModeFlag()+"\n")



