// $BACKGROUND$
// manages acquiring PECS images from the workflow and saving them in the correct directory

class pecsCamera_iprep : object
{

	number camID
	number processing

	image img1

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("PECSCAM", level, text)
	}

	void print(object self, string text)
	{
		// print to console output. also log as info
		result("PECSCAM: "+text+"\n")
		self.log(2,text)
	}


	void pecsCamera_iprep(object self)
	{
		camID = CameraGetActiveCameraID( )
		processing = CameraGetUnprocessedEnum( )
	}
 
	void init(object self)
	{
		// *** public ***
		// initializes

		CameraPrepareForAcquire( camID )
		self.print("initialized")
	}
	 
	void acquireDM(object self, image &im, number exposure)
	{
		// *** public ***
		// acquire image the DM way

		// use standard DM acquisition methods
		im := CameraAcquire( camID , exposure)
		//ShowImage( im )

		self.print("image acquired")
	}


	void acquire(object self, image &im)
	{
		// *** public ***
		// acquire image and show it the PECS way, including calibration tags


		
		// use PECS specific acquisition methods, close window afterwards
		PIPS_StartSnapshot()
		sleep(3)
		im := getfrontimage()
		//ImageDocument imdoc = GetFrontImageDocument()
		ImageDocument imdoc = ImageGetOrCreateImageDocument(im)
		imdoc.ImageDocumentClose(0)

		self.print("image acquired")

	}

	void liveView(object self)
	{
		// start live view acquisition
		PIPS_StartLiveview()

	}



	void save(object self)
	{
		// *** public ***
		// saves image to disk in directory for experiment
		self.print("image saved")

	}

	 




}


