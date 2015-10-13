// $BACKGROUND$
// general IPrep (helper) functions used in various scripts


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
		deviceSet = alloc(statePersistanceNumeric)
		errorCode = alloc(statePersistance)
		exceptionMessage = alloc(statePersistance)
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
		// *** private ***
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


}

// define mediator object
object aMediator = alloc(SafetyMediator)

// make sure we can return mediator after this script is installed
object returnMediator()
{
	return aMediator
}

// define SEMCoordManager object

object mySEMCoordManager = alloc(SEMCoordManager)

// allow classes to return this coordManager
object returnSEMCoordManager()
{
	return mySEMCoordManager
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



