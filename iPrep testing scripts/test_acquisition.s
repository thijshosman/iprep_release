//$BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

try
{
PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_07", "0")   //works set  SO valve
PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_07", "1")   //works set  SO valve


	// *** pecs imaging ***
	image temp_slice_im
	myWorkflow.returnPecs().ilumOn()
	//PIPS_StartSnapshot()
	//sleep(2)
	//temp_slice_im := getfrontimage()
	//ImageDocument imdoc = GetFrontImageDocument()
	//imdoc.ImageDocumentClose(0)
	//PIPS_StartSnapshot()
	myWorkflow.returnPecsCamera().acquire(temp_slice_im)
	showimage(temp_slice_im)

	// *** digiscan imaging ***
/*	myWorkflow.returnSEM().setMag(1000)
	EMUpdateCalibrationState()

	image temp_slice
	myWorkflow.returnDigiscan().config(2)
	myWorkflow.returnDigiscan().acquire(temp_slice)
	showimage(temp_slice)
		
		
	myWorkflow.returnSEM().setMag(8000)
	EMUpdateCalibrationState()
	sleep(1)
	
	number alignParamID1 = DSCreateParameters( 2048, 2048, 0, 1, 0 )

	image temp_slice_im2
	myWorkflow.returnDigiscan().config(alignParamID1)
	myWorkflow.returnDigiscan().acquire(temp_slice_im2)
	showimage(temp_slice_im2)
		
	DSDeleteParameters( alignParamID1 )
*/	


}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")