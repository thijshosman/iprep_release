// $BACKGROUND$

class EBSD_OI_automatic: object
{
	// give control to the EBSD system and hand it back over to the workflow when done
	number timeout
	
	void init(object self)
	{
		//

	}

	number EBSD_start(object self, number val1)
	{
		// start EBSD acquisition, then poll to see if it is done
		EBSD_StartAcquisition()

		while(1)
		{

		// quit if DM gets stop event message
		if(!EBSD_IsAcquisitionBusy())
		{
			return 1
			sleep(1)
		}




		}

	}



}







