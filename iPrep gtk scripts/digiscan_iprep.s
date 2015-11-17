// $BACKGROUND$
class digiscan_iprep : object
{
		number datatype
		number width
		number height
		number signalIndex
		number rotation
		number pixelTime
		number lineSync
		number paramID
		number signed
		number imageID
		string name

	number configured

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


	void digiscan_iprep(object self)
	{
		// constructor
		configured = 0

	}

	void config(object self, taggroup DSParam)
	{
		// paramID is the id of the configuration used to acquire. 
		
		
		// Copy all tags in the TagGroup 'sTG' into the TagGroup 'gTG' 
		taggroup subtag
		GetPersistentTagGroup().TagGroupGetTagAsTagGroup("Private:DigiScan:Faux:Setup:Record", subtag )
		subtag.TagGroupReplaceTagsWithCopy( DSParam )

		
		paramID = 2	// capture ID
		width = DSGetWidth( paramID )
		height = DSGetHeight( paramID)
		pixelTime = DSGetPixelTime( paramID )
		lineSync = DSGetLineSynch( paramID )
		rotation = DSGetRotation( paramID )

		signed = 0	// Image has to be of type unsigned-integer
		datatype = 2	// Currently this is hard coded - no way to read from DS plugin - #TODO: fix
		
		signalIndex = 0		// Only 1 signal supported now - #TODO: fix
		name = DSGetSignalName( signalIndex )

	
		
		self.print("digiscan configured, height = "+height+", width = "+width+", dwell time = "+pixelTime)
		configured = 1
	}

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
		
		number paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 
		// if paramID is used (Capture) then an extra copy of the image is made by GMS3 after acquire. 
		// Doesnt happen if new parameter set is made

		DSSetParametersSignal( paramID2, signalIndex, dataType, selected, imageID )
		DSStartAcquisition( paramID2, continuous, synchronous )
		
		// delete the parameter array we temporarily created
		DSDeleteParameters( paramID2 )

		// close the image that the digiscan image is contained in
		// depreciated: done one level up
		//ImageDocument imdoc = GetFrontImageDocument()
		//ImageDocument imdoc = ImageGetOrCreateImageDocument(img)
		//imdoc.ImageDocumentClose(0)
		
		//ShowImage( img )
		
		self.print("digiscan done acquiring")

		//return img
	}

	~digiscan_iprep(object self)
	{
		
	}


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
