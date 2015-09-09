// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

String logFilePath = "C:\\Users\\gatan\\Documents\\IPrep\\testlog\\parkerlog.txt"
Number cycles = 20
Number fileRef
String iteration = "0"

void HoldAndCheckForManualInterrupt(Number seconds)
{
	Number startTicks = GetOSTickCount()
	while ((GetOSTickCount() - startTicks)/1000 < seconds)
	{
		if (OptionDown() && ShiftDown())
		{
			if (OKCancelDialog("Abort?"))
			{
				Result("*** stopped\n")
				exit(0)
			}
		}
		sleep(0.1)
	}
}

fileRef = OpenFileForReading(logFilePath)
ReadFileLine(FileRef, 0, iteration)
CloseFile(fileRef)



try
{

	// *** automated test parker workflow ***
	
	iteration = "0"
	
	IPrep_setSliceNumber(iteration.val())
	number i

	
	IPrep_Setup_Imaging()


	for (i = iteration.val(); i<=cycles; i++)
	{
		// PECS -> SEM

		// SEM -> PECS

		// move stage
		myWorkflow.returnSEM().goToClear()
		sleep(1)
		myWorkflow.returnSEM().goToNominalImaging()
		
		// image
		IPrep_image()
		
		IPrep_IncrementSliceNumber()

		result("iteration: "+i+"\n")
		
		HoldAndCheckForManualInterrupt(0.1)
		
		//fileRef = OpenFileForReadingAndWriting(logFilePath)
		//WriteFile(fileRef, Decimal(i+1))
		//CloseFile(fileRef)
		
	}
	
	
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
