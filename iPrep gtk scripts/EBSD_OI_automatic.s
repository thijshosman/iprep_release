// $BACKGROUND$

class EBSD_OI_automatic: object
{

	string sitename
	string data_prefix
	number type // (1 is electron, 2 is eds, 4 is ebsd (which may also have eds enabled))

	number err

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("EBSD", level, text)
	}

	void print(object self, string str1)
	{
		result("EBSD: "+str1+"\n")
		self.log(2,str1)
	}



	// give control to the EBSD system and hand it back over to the workflow when done
	number timeout
	
	void init(object self)
	{
		self.print("Oxford Instruments EBSD Handshake initialized")
		// set sitename


	}

	void init(object self, string sitename1, string prefix1, number type1)
	{
		sitename = sitename1
		data_prefix = prefix1
		type = type1
		self.print("site name: "+sitename+", filename prefix: "+data_prefix+", type: "+type)
		self.init()
	}

	// new interface to aztec

	//string sitename, dataname
	//number type, progress, err
	//OINA_AcquisitionStart(sitename, dataname, type)
	//OINA_AcquisitionStop()
	//OINA_AcquisitionIsActive(progress, err)

	void EBSD_start(object self)
	{
		// start EBSD acquisition
		OINA_AcquisitionStart(sitename, data_prefix+IPrep_sliceNumber(), type)
		self.print("EBSD Acquisition started")
	}

	void EBSD_stop(object self)
	{
		OINA_AcquisitionStop()
	}

	number checkProgress(object self)
	{
		number progress
		OINA_AcquisitionIsActive(progress, err)
		return progress
	}

	number isBusy(object self)
	{
		number progress
		return OINA_AcquisitionIsActive(progress, err)
	}


/*
	// old, unsupported interface to aztec

	void EBSD_start(object self)
	{
		// start EBSD acquisition
		EBSD_StartAcquisition()
		self.print("EBSD Acquisition started")
	}

	number isBusy(object self)
	{
		return EBSD_IsAcquisitionBusy()

*/	}



}







