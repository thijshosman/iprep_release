// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

	// test etching
	
	void etching_test_routine()
	{
		myWorkflow.returnPecs().goToEtchMode() // moves stage and angles
		myWorkflow.returnPecs().goToEtchMode() // again to fix bug in not going to repeated angle first time
		myWorkflow.returnPecs().startMilling() // start process
		result("etching time remaining: "+myWorkflow.returnPecs().millingTimeRemaining()+"\n")	
		sleep(1)
		result("milling status during etching: "+myWorkflow.returnPecs().getMillingStatus()+"\n")
		result("system status during etching: "+myWorkflow.returnPecs().getSystemStatus()+"\n")
		sleep(5)
		myWorkflow.returnPecs().stopMilling()
	}
	
	// test coating
	
	void coating_test_routine()
	{
		myWorkflow.returnPecs().goToCoatMode() // moves stage
		myWorkflow.returnPecs().startCoating() // start process
		result("coating time remaining: "+myWorkflow.returnPecs().millingTimeRemaining()+"\n")
		sleep(1)
		result("milling status during coating: "+myWorkflow.returnPecs().getMillingStatus()+"\n")
		result("system status during coating: "+myWorkflow.returnPecs().getSystemStatus()+"\n")
		sleep(5)
		myWorkflow.returnPecs().stopMilling()
	}

try
{
	//myWorkflow.returnPecs().shutoffArgonFlow()
	//myWorkflow.returnPecs().restoreArgonFlow()
	
	//myWorkflow.returnPecs().moveShutterIn()
	//myWorkflow.returnPecs().moveShutterOut()
	
	// move to coating
	//PIPS_Execute("STRTPROC0000,process_movetocoat")
	//PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,1")    //coating mode
		
	// move to etch
	//PIPS_Execute("STRTPROC0000,process_movetoetch")	
	//PIPS_Execute("SETP_SUB0000,subsystem_milling,set_milling_variation,0")     //etching mode
	
	
	// *** coating/etching switch ***
	// assume sample comes in from SEM, which means PECS is in a custom state (because of transfer position)
	// 1. go to etch
	// 2. etch
	// 3. go to coat mode
	// 4. insert shutter with coating target
	// 5. coat
	// 6. take shutter out

	
	//coating_test_routine()
	//etching_test_routine()
	
	//myWorkflow.returnPecs().stopMilling()
	//myWorkflow.returnPecs().goToEtchMode()
	//myWorkflow.returnPecs().goToCoatMode()
	
	result("milling status during coating: "+myWorkflow.returnPecs().getMillingStatus()+"\n") // 0 when idle
	result("system status during coating: "+myWorkflow.returnPecs().getSystemStatus()+"\n") // 0 when idle
	
	
	
	
	
	
	
	
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
