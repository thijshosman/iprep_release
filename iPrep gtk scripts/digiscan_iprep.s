// $BACKGROUND$
class digiscan_iprep : object
{
		number dataType
		number width
		number height
		number signalIndex
		number rotation
		number pixelTime
		number lineSync

	number paramID

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
		// constructor, DEPRECATED, just sets default values
		dataType = 4   // 4 byte data
		width    = 1024 // pixel
		height   = 1024 // pixel
		signalIndex = 0
		rotation = 0   // degree
		pixelTime= 2   // microseconds
		lineSync = 1   // activated

	}

	void init(object self)
	{
		self.print("digiscan initialized")
	}

	void config(object self, number paramID1)
	{
		// paramID is the id of the configuration used to acquire. 
		
		
		self.print("parameter ID used: "+paramID1)

		width = DSGetWidth( paramID1 )
		height = DSGetHeight( paramID1 )
		pixelTime = DSGetPixelTime( paramID1 )
		lineSync = DSGetLineSynch( paramID1 )
		rotation = DSGetRotation( paramID1 )

		
		self.print("digiscan configured, height = "+height+", width = "+width+", dwell time = "+pixelTime)
	}

	void acquire(object self, image &img)
	{
		// *** public ***
		// acquires the image and shows it
		self.print("digiscan start acquiring, height = "+height+", width = "+width+", dwell time = "+pixelTime)

		img := IntegerImage( "Img", dataType, 0, width, height )        // Image has to be of type unsigned-integer

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
		
		// most flexible way
		number signalIndex, selected, imageID
		signalIndex = 0
		selected    = 1 // acquire this signal
		//imageID     = 0 // create new image
		imageID = ImageGetID( img )
		
		
		number continuous  = 0 // 0 = single frame, 1 = continuous
		number synchronous = 1 // 0 = return immediately, 1 = return when finished
		
		paramID = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 
		DSSetParametersSignal( paramID, signalIndex, dataType, selected, imageID )
		DSStartAcquisition( paramID, continuous, synchronous )
		
		// delete the parameter array we temporarily created
		DSDeleteParameters( paramID )

		// close the image that the digiscan image is contained in
		//ImageDocument imdoc = GetFrontImageDocument()
		ImageDocument imdoc = ImageGetOrCreateImageDocument(img)
		imdoc.ImageDocumentClose(0)
		
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
