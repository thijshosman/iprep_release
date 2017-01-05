
result("***start***\n")
object myPW = returnMediator().returnPW()
myPW.updateC("test applied")
result("***end***\n")
/*
object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myPW = returnMediator().returnPW()


number IPrep_init1()
{
	// starts when IPrep DM module starts
	// initializes workflow object, establishes connection with hardware and saves positions for transfers

	try
	{
		print("iprep init")


		// init iprep workflow subsystems/hardware
		myWorkflow.init()

		// init the state machine with current states 
		myStateMachine.init(myWorkflow)
		
		// #TODO: check dock against mode tag
		// use okcanceldialog wrapper to choose to ignore this as warning or throw error

		
		print("current slice: "+IPrep_sliceNumber())
		myPW.updateC("slice: "+IPrep_sliceNumber())
		myPW.updateB("idle")
		myPW.updateA("sample: "+myStateMachine.getCurrentWorkflowState())
		print("iprep init done")
		return 1
	}
	catch
	{
		print("exception during init: "+ GetExceptionString())
		okdialog("exception during init: "+ GetExceptionString())
		break
		
	}
	return 0
}

void iprep_test_single()
{
	//debug(IPrep_sliceNumber()+"")
	myPW.updateA("slice: "+IPrep_sliceNumber())
}


//tests()

//iprep_init1()

*/
