// $BACKGROUND$
class digiscan_simulator : object
{

	// general parameters for all images	
	number datatype
	number width
	number height
	number rotation
	number pixelTime
	number lineSync
	number paramID, paramID2 // paramID is ID of capture settings (2), paramID2 is the one we create using our own settings that we can delete
	number signed
	
	// parameters per image

	number imageID0
	number imageID1
	
	string name0
	string name1

	image img0
	image img1

	number configured0
	number configured1

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("DIGISCAN", level, text)
	}

	void print(object self, string text)
	{
		// print to console output. also log as info
		result("DIGISCAN: "+text+"\n")
		self.log(2,text)
	}


	void digiscan_simulator(object self)
	{
		// constructor
		configured0 = 0
		configured1 = 0
		name0 = "unnamed"
		name1 = "unnamed"

		// paramID is the id of the configuration used to acquire. 
		paramID = 2	// capture ID

		// check which signals are enabled and what their names are
		self.updateSignalSettings()
		width = 1024
		height = 1024
	}

	void updateSignalSettings(object self)
	{
		// look what signals names are/which are enabled

		// first re-init them to 0
		configured0 = 0
		configured1 = 0

		//if(DSGetSignalAcquired(paramID,0))
		{
			// 0 enabled
			configured0 = 1
			//name0 = DSGetSignalName( 0 )
		}
		
		//if(DSGetSignalAcquired(paramID,1))
		{
			// 1 enabled
			configured1 = 1
			//name1 = DSGetSignalName( 1 )
		}

	}
	
	void getControl(object self)
	{
		// give control of beam to digiscan
		//DSSetScanControl(1) // 1 is grab, 0 is release
		self.print("control: "+DSHasScanControl())
	}

	void releaseControl(object self)
	{
		// release control of beam back to SEM
		//DSSetScanControl(0) // 1 is grab, 0 is release
		self.print("control: "+DSHasScanControl())
	}

		number getConfigured0(object self)
	{
		// check if signal 0 is configured
	
		// check which signals are enabled and what their names are
		self.updateSignalSettings()
		return configured0
	}

	number getConfigured1(object self)
	{
		// check if signal 1 is configured

		// check which signals are enabled and what their names are
		self.updateSignalSettings()
		return configured1
	}

	number numberOfSignals(object self)
	{
		// check if signal 0 is configured

		// check which signals are enabled and what their names are
		self.updateSignalSettings()
		return configured0+configured1
	}

	string getName0(object self)
	{
		// return name of signal 0
		return name0
	}

	string getName1(object self)
	{
		// return name of signal 1
		return name1
	}

	void config(object self, image &img0, image &img1)
	{
		// use parameters from capture as setup in DM
		
		// see if signal names/enables have changed
		self.updateSignalSettings()

		width = 1024
		height = 1024
		//width = DSGetWidth( paramID )
		//height = DSGetHeight( paramID)
		//pixelTime = DSGetPixelTime( paramID )
		//lineSync = DSGetLineSynch( paramID )
		//rotation = DSGetRotation( paramID )

		signed = 0	// Image has to be of type unsigned-integer
		datatype = 2	// Currently this is hard coded - no way to read from DS plugin - #TODO: fix
		
		// use all these parameters to create a (temporary) parameter set
		//paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 

		// check if first signal is enabled
		if(configured0)
		{
			// enabled

			self.print("digiscan configured using signal 0 ("+name0+").")
			img0 := IntegerImage( name0, dataType, signed, width, height ) 
			number imageID0 = ImageGetID( img0 )
			//DSSetParametersSignal( paramID2, 0, dataType, 1, imageID0 )

			self.print("signal 0 succesfully configured from capture settings. height = "+height+", width = "+width+", dwell time = "+pixelTime)

		}
		else
			self.print("signal 0 not configured")

		if(configured1)
		{
			// enabled
		
			self.print("digiscan configured using signal 1 ("+name1+").")
			img1 := IntegerImage( name1, dataType, signed, width, height ) 
			number imageID1 = ImageGetID( img1 )
			//DSSetParametersSignal( paramID2, 1, dataType, 1, imageID1 )

			self.print("signal 1 succesfully configured from capture settings. height = "+height+", width = "+width+", dwell time = "+pixelTime)

		}	
		else
			self.print("signal 1 not configured")

		// #todo: if we try to get signal 2, DM crashes in an uncontrolled way. 2 signals supported for now
		
	}

	void config(object self, taggroup DSParam, image &img0, image &img1 )
	{
		// copy the parameters from DSParam taggroup

		// check which signals are enabled and what their names are
		self.updateSignalSettings()

		width = GetTagValueFromSubtag("Image Width",DSParam)
		height = GetTagValueFromSubtag("Image Height",DSParam)
		pixelTime = GetTagValueFromSubtag("Sample Time",DSParam)
		lineSync = GetTagValueFromSubtag("Synchronize Lines",DSParam)
		rotation = GetTagValueFromSubtag("Rotation",DSParam)

		signed = 0	// Image has to be of type unsigned-integer
		datatype = 2	// Currently this is hard coded - no way to read from DS plugin - #TODO: fix
		
		// use all these parameters to create a (temporary) parameter set
		//paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 

		// check if first signal is enabled
		if(configured0)
		{
			// enabled
			self.print("digiscan configured using signal 0 ("+name0+").")
			img0 := IntegerImage( name0, dataType, signed, width, height ) 
			number imageID0 = ImageGetID( img0 )
			//DSSetParametersSignal( paramID2, 0, dataType, 1, imageID0 )

			self.print("signal 0 succesfully configured from tag. height = "+height+", width = "+width+", dwell time = "+pixelTime)

		}
		else
			self.print("signal 0 not configured")

		if(configured1)
		{
			// enabled
			self.print("digiscan configured using signal 1 ("+name1+").")
			img1 := IntegerImage( name1, dataType, signed, width, height ) 
			number imageID1 = ImageGetID( img1 )
			//DSSetParametersSignal( paramID2, 1, dataType, 1, imageID1 )

			self.print("signal 1 succesfully configured from tag. height = "+height+", width = "+width+", dwell time = "+pixelTime)

		}	
		else
			self.print("signal 1 not configured")
		
		// #TODO: we want this config function to set the required signals that are selected and call DSSetParameterSignal methods based on which of these are selected

		self.print("digiscan configured using tag settings from ROI, height = "+height+", width = "+width+", dwell time = "+pixelTime)

	}

	number DSGetWidth(object self)
	{
		return width
	}

	number DSGetHeight(object self)
	{
		return height
	}

	void acquire(object self)
	{
		// *** public ***

		if (configured0 == 1 )
		{
			img0 = 501
		}

		if (configured1 == 1)
		{
			img1 = 502
		}

		self.print("digiscan done acquiring")

	}



/*
	void acquire(object self, image &img)
	{
		// *** public ***
		// acquires the image and shows it
		if (configured == 0)
		{
			self.print("digiscan not configured!")
			return
		}


		self.print("digiscan start acquiring, height = "+height+", width = "+width+", dwell time = "+pixelTime)

		img := IntegerImage( name, dataType, signed, width, height )        

		// there are different ways of acquiring digiscan image
		//invoke button
		//DSInvokeButton(3);
		//DSWaitUntilFinished( )
		//image img1 := DSGetLastAcquiredImage( 0 )

		// more advanced way: 
		//DSAcquireData( img, signalIndex, pixelTime, rotation, lineSync )
		// make sure you sleep until full image is acquired. TODO: neater way of doing this
		//sleep(width*height*pixeltime/1000000)
		//DSWaitUntilFinished()
		
		// Assign <img> to DS signal
		number selected    = 1 // acquire this signal
		//imageID     = 0 // create new image
		number imageID = ImageGetID( img )
		
		
		number continuous  = 0 // 0 = single frame, 1 = continuous
		number synchronous = 1 // 0 = return immediately, 1 = return when finished
		
		//number paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 
		// if paramID is used (Capture) then an extra copy of the image is made by GMS3 after acquire. 
		// Doesnt happen if new parameter set is made

		//DSSetParametersSignal( paramID2, signalIndex, dataType, selected, imageID )
		//DSStartAcquisition( paramID2, continuous, synchronous )

		img = 501
		
		// delete the parameter array we temporarily created
		//DSDeleteParameters( paramID2 )

		// close the image that the digiscan image is contained in
		// depreciated: done one level up
		//ImageDocument imdoc = GetFrontImageDocument()
		//ImageDocument imdoc = ImageGetOrCreateImageDocument(img)
		//imdoc.ImageDocumentClose(0)
		
		//ShowImage( img )
		
		self.print("digiscan done acquiring")

		//return img
	}
*/



}


// *** testing ***

//object mydigiscan = alloc(digiscan_iprep)
//mydigiscan.init()
//mydigiscan.config(2)

//image im1
//ImageDocument imageDoc = CreateImageDocument( "New ImageDocument" ) 

 

// add the new image to the imageDocument
//mydigiscan.acquire(im1)
//imageDoc.ImageDocumentAddImage( im1 )
//imageDoc.ImageDocumentShow()
//imageDoc.ImageDocumentClose(1)

//closeimage()
//showimage(im1)
