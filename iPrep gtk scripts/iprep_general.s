// $BACKGROUND$
// general IPrep functions used in various scripts


class deadFlagObject:object
{
	object deadFlag
	object safetyFlag

	void deadFlagObject(object self)
	{
		// get deadflag
		deadFlag = alloc(statePersistance)
		safetyFlag = alloc(statePersistance)
	{

	void setDead(object self, number status)
	{
		// set whether system is dead or not
		deadFlag

	}

	void setSafety(object self, number status)
	{
		// set whether system is safe to operate

	}

	void setDeadSafe

	void setDeadUnsafe

	void checkDeadSafe



}


class haltCheckObject:object
{
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

//result(getProtectedModeFlag()+"\n")



