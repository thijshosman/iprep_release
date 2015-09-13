// $BACKGROUND$
// general IPrep functions used in various scripts


class deadFlagObject:object
{
	object deadFlag
	object safetyFlag

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
		deadFlag.init("flags:dead")
		safetyFlag.init("flags:safe")
	}

	void setDead(object self, number status)
	{
		// set whether system is dead or not
		self.print("deadflag set to " + status)
		deadFlag.setState(""+status)
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
			self.print("system is not (alive and safe)")
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

}

number checkGatevalve()
{
	Number status
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", status)
	return status
}

numbr checkParker()
{
	Number status
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", status)
	return status
}

number checkSEM()
{
	Number status
	GetPersistentTagGroup().TagGroupGetTagAsLong("IPrep:Record Settings:Slice Number", status)
	return status
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



