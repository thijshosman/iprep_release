//$BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()


try
{

	image temp_slice_im0, temp_slice_im1
	
	// digiscan

	// or use digiscan parameters as setup in the normal 'capture' at this moment
	myWorkflow.returnDigiscan().config(temp_slice_im0,temp_slice_im1)

	myWorkflow.returnDigiscan().acquire()

// Save Digiscan image 1

	//temp_slice_im0.showimage()

		IPrep_saveSEMImage(temp_slice_im0, "digiscan BSE")

		// Save Digiscan image 2
		IPrep_saveSEMImage(temp_slice_im1, "digiscan SE")

		// Close Digiscan image
		ImageDocument imdoc0 = ImageGetOrCreateImageDocument(temp_slice_im0)
		imdoc0.ImageDocumentClose(0)
	
		// Close Digiscan image
		ImageDocument imdoc1 = ImageGetOrCreateImageDocument(temp_slice_im1)
		imdoc1.ImageDocumentClose(0)	

}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")

