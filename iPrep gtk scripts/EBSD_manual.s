// $BACKGROUND$

class EBSD_manual: object
{
	// give control to the EBSD system and hand it back over to the workflow when done

	number EBSD_start(object self)
	{
		if (okdialog("start the EBSD acquisition. press OK when done"))
			return 1 // success, give control back to workflow
		else
			return 0 // indicates to the workflow that something went wrong with EBSD
	}


}







