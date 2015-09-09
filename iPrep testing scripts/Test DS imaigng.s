// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

object myPW = alloc(progressWindow)
// convention for progresswindow:
// A: sample status
// B: operation
// C: slice number

void AcquireDigiscanImage( image &img )
{

	Number paramID = 2	// capture ID
	number width, height,pixeltime,linesync,rotation
	width = DSGetWidth( paramID )
	height = DSGetHeight( paramID)
	pixelTime = DSGetPixelTime( paramID )
	lineSync = DSGetLineSynch( paramID )
	rotation = DSGetRotation( paramID )

	number signed = 0	// Image has to be of type unsigned-integer
	number datatype = 2	// Currently this is hard coded - no way to read from DS plugin - #TODO: fix
	number signalIndex, imageID
	signalIndex = 0		// Only 1 signal supported now - #TODO: fix
	string name = DSGetSignalName( signalIndex )

	 img := IntegerImage( name, dataType, signed, width, height )        
	imageID = ImageGetID( img )

	// Create temp parameter array
	number paramID2 = DSCreateParameters( width, height, rotation, pixelTime, lineSync) 
	result("paramID="+paramID2+"\n")
	// if paramID is used (Capture) then an extra copy of the image is made by GMS3 after acquire. Doesnt appen if new parameter set is made

	// Assign <img> to DS signal
	number selected    = 1 // acquire this signal
	DSSetParametersSignal( paramID2, signalIndex, dataType, selected, imageID )

	number continuous  = 0 // 0 = single frame, 1 = continuous
	number synchronous = 1 // 0 = return immediately, 1 = return when finished
	DSStartAcquisition( paramID2, continuous, synchronous )

	// Delete the parameter array temporarily created
	DSDeleteParameters( paramID2 )

//	return img
}


Number IPrep_Imagetest()
{
	// Update GMS status bar - SEM imaging started
		myPW.updateB("SEM imaging...")	
		result(datestamp()+": SEM mag 1 = "+EMGetMagnification()+"\n")

	// Unblank SEM beam
		FEIQuanta_SetBeamBlankState(0)

	// Goto saved specimen ROI location using SEM stage
		object mySI = myWorkflow.returnSEM().returnStoredImaging()
		number xx,yy,zz
		xx=mySI.getX()
		yy=mySI.getY()
		zz=mySI.getZ()
		if (zz > 5)	// safety check, make sure tags are set -- should do proper in bounds checking
			myWorkflow.returnSEM().goToStoredImaging()

		sleep( 5 )	// let stage settle, #TODO: move value to tag

	// Set SEM focus to saved value
		number saved_focus = EMGetFocus()/1000	// initialize to current value (in case tag is empty)
		string tagname = "IPrep:SEM:WD:value"
		if ( GetPersistentNumberNote( tagname, saved_focus ) )
			EMSetFocus(saved_focus*1000)

	// Autofocus, if enabled in tag
	/*
		afs_run()		// Autofocus command - #TODO: configure properly, turn off stig checking
		
		number current_focus = myWorkflow.returnSEM().measureWD()
		number change = current_focus - saved_focus
		result("Autofocus changed focus value by "+change+" mm\n")
	*/

	// Acquire Digiscan image, use "Capture" settings
		image temp_slice_im
		AcquireDigiscanImage( temp_slice_im )

	// Blank SEM beam
		FEIQuanta_SetBeamBlankState(1)

	// Save Digiscan image
		IPrep_saveSEMImage(temp_slice_im, "digiscan")

	// Close Digiscan image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)
		
	// Update GMS status bar - SEM imaging done
		myPW.updateB("SEM imaging completed")
		result(datestamp()+": SEM mag 2 = "+EMGetMagnification()+"\n")
}



number i,n=300
for (i=0; i<n; i++)
{
	IPrep_setSliceNumber( i )
		myWorkflow.returnSEM().goToLowerGrid()
		FEIQuanta_SetBeamBlankState(0)

		sleep( 3 ) // stabilize
			// Acquire Digiscan image, use "Capture" settings
		image temp_slice_im
		AcquireDigiscanImage( temp_slice_im )
		FEIQuanta_SetBeamBlankState(1)

	// Save Digiscan image
		IPrep_saveSEMImage(temp_slice_im, "grid")

	// Close Digiscan image
		ImageDocument imdoc = ImageGetOrCreateImageDocument(temp_slice_im)
		imdoc.ImageDocumentClose(0)

		iprep_imagetest()
}
