// Acquire 2 signals simultaneously, e.g. HAADF and BF detector

 

number paramID

number width    = 512 // pixel

number height   = 512 // pixel

number rotation = 0   // degree

number pixelTime= 2   // microseconds

number lSynch   = 1   // activated

paramID = DSCreateParameters( width, height, rotation, pixelTime, lSynch )

number signalIndex, dataType, selected, imageID


// define signal 0

signalIndex = 0

dataType    = 2 // 2 byte data

selected    = 1 // acquire this signal

imageID     = 0 // create new image

image img0 := IntegerImage( "img0", dataType, 0, width, height ) 
number id0 = ImageGetID( img0 )

DSSetParametersSignal( paramID, signalIndex, dataType, selected, id0 )



// define signal 1 

signalIndex = 1

dataType    = 2 // 2 byte data

selected    = 1 // acquire this signal

imageID     = 0 // create new image

image img1 := IntegerImage( "img1", dataType, 0, width, height ) 
number id1 = ImageGetID( img1 )

DSSetParametersSignal( paramID, signalIndex, dataType, selected, id1 )


 

number continuous  = 0 // 0 = single frame, 1 = continuous

number synchronous = 1 // 0 = return immediately, 1 = return when finished

// start

DSStartAcquisition( paramID, continuous, synchronous )

SaveAsGatan(img1,"C:\\Users\\gatan\\Documents\\tempfolder\\test.dm3")

DSDeleteParameters( paramID ) // remove parameters from memory
 
