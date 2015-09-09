// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

String logFilePath = "C:\\Users\\gatan\\Documents\\IPrep\\testlog\\parkerlog.txt"
Number cycles = 20000
Number fileRef
String iteration

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
	// in search of the bridge fault
	
	
	
	IPrep_setSliceNumber(iteration.val())
	number i
	myWorkflow.returnSEMDock().goUp()	
	myWorkflow.returnPecs().openGVandCheck()
	myWorkflow.returnPecs().moveStageDown()
	
	for (i = iteration.val(); i<=cycles; i++)
	{
		// PECS -> SEM
		myWorkflow.returnTransfer().move("open_pecs")
		myWorkflow.returnTransfer().move("pickup_pecs")
		myWorkflow.returnTransfer().move("dropoff_sem")
		myWorkflow.returnTransfer().move("backoff_sem")
		myWorkflow.returnTransfer().move("prehome")
		myWorkflow.returnTransfer().home()
		sleep(15)
		myWorkflow.returnTransfer().turnOff()
		

		// SEM -> PECS
		myWorkflow.returnTransfer().move("backoff_sem")
		myWorkflow.returnTransfer().move("pickup_sem")
		myWorkflow.returnTransfer().move("dropoff_pecs")
		myWorkflow.returnTransfer().move("dropoff_pecs_backoff")
		myWorkflow.returnTransfer().move("open_pecs")
		myWorkflow.returnTransfer().move("prehome")
		myWorkflow.returnTransfer().home()
		sleep(15)
		myWorkflow.returnTransfer().turnOff()
		
		IPrep_IncrementSliceNumber()
		result("iteration: "+i+"\n")
		
		HoldAndCheckForManualInterrupt(0.1)
		
		fileRef = OpenFileForReadingAndWriting(logFilePath)
		WriteFile(fileRef, Decimal(i+1))
		CloseFile(fileRef)
		
	}
	
	
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
