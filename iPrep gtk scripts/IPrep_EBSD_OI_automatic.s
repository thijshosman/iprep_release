// $BACKGROUND$

class EBSD_OI_automatic: object
{

	string sitename
	string data_prefix
	number type // (1 is electron, 2 is eds, 4 is ebsd (which may also have eds enabled))

	number err // 0 = no error, 1 = error, 2 = unknown event, 3 = completed
	number progress // goes from 50 to 97/98/99 (ebsd) or 50 to 97/98/99 (eds)

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


	number returnProgress(object self)
	{
		return progress
	}

	number returnError(object self)
	{
		return err
	}

	// give control to the EBSD system and hand it back over to the workflow when done
	
	void init(object self)
	{
		self.print("Oxford Instruments EBSD Handshake (Aztec 3.2) initialized")
		progress = 0
		err = 0
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

	void EBSD_stop(object self)
	{
		OINA_AcquisitionStop()
		self.print("Acquisition stopped")
	}

	void EBSD_start(object self)
	{
		// start EBSD acquisition

		// first stop acquisition to prevent bug on OI side that messes up our listener deamon
		self.EBSD_stop()
		OINA_AcquisitionStart(sitename, data_prefix+"_"+IPrep_sliceNumber(), type)
		self.print("Acquisition started")
	}

	number isBusy(object self)
	{
		OINA_AcquisitionIsActive(progress, err)
		if (err == 1)
		{
			self.print("error in acquisition")
			return 0
		}
		else if (err == 2)
		{
			self.print("unkonwn event in acquisition")
			return 0
		}
		else if (err == 3)
		{
			self.print("completed")
			return 0
		}
		else
		{
			self.print("acquisition busy")
			return 1
		}
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

	}
*/


}







