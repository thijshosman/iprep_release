// $BACKGROUND$

// pecs abstract base class

// --- this class is intended to do the following:
// --- * open/close gate valve, check status
// --- * check status of gate valve through sensors
// --- * lower/raise PECS stage
// --- * check status (up/down) of PECS stage
// --- * home the rotation stage
// --- * some secondary stuff, check pressures, etc. 


class pecs_base: object
{
	
	void log(object self, number level, string text)
	{

	}

	void print(object self, string text)
	{

	}
	
	number argonCheck(object self)
	{
		// *** public ***
			return 0

	}

	number TMPCheck(object self)
	{
		// *** public ***
			return 0

	}

	number getLockOut(object self)
	{
		return 0
	}

	void lockOut(object self)
	{
		// lock UI

	}

	void unlock(object self)
	{
		// unlock UI
		
	} 


	void startMilling(object self)
	{
		// *** public ***

	}

	void stopMilling(object self)
	{
		// *** public ***

	}

	number millingTimeRemaining(object self)
	{
		// *** public ***
		return 0
	}

	void setMFCsToZero(object self)
	{

	}

	string getGVState(object self)
	{
		return ""
		
	}

	string getStageState(object self)
	{
		// *** public ***`
		return ""
	}

	string getSystemStatus(object self)
	{
		// *** public ***
		return ""
	}

	number getMillingStatus(object self)
	{
		// *** public ***
		return 0

	}

	string getStageAngle(object self)
	{
		// *** public ***
		return ""
	}

	void stageHome(object self)
	{
		// *** public ***

	}

	void ilumOn(object self)
	{
		// *** public ***
	}

	void ilumOff(object self)
	{
		// *** public ***
	}


	void PECS(object self)
	{
		//constructor

	}

	number consistencyCheck(object self)
	{
		// check states from sensors are consistent with tag in DM
		return 0
	}


	void moveStageUp(object self)
	{
		// *** public ***
		
	}

	void moveStageDown(object self)
	{
		// *** public ***
		
	}


	void init(object self)
	{
		// *** public ***
	}

	
	void openGV(object self)
	{
		// *** private ***

	}

	void closeGV(object self)
	{
		// *** private ***

	}
	
	void openGVandCheck(object self)
	{
		// *** public ***
	}

	void closeGVandCheck(object self)
	{
		// *** public ***
	}


}



