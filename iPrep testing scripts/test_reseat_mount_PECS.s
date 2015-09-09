// Script to reseat sample mount in PECS
// 8/10/2015 SC

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
number count

try
{

myWorkflow.returnPecs().moveStageDown()

for (count=1; count<=25; count++)
{ 
	//home pecs stage
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home

	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
	myWorkflow.returnGripper().open()	
	myWorkflow.returnTransfer().move("pickup_pecs") // location where open arms can be used to pickup sample
	myWorkflow.returnGripper().close()

	myWorkflow.returnTransfer().move("test")    // location where sample is free of PECS before GV
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
	
	myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
	myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
	myWorkflow.returnGripper().open()
	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
	myWorkflow.returnGripper().close()
	myWorkflow.returnTransfer().home()
	sleep(5)
}

//myWorkflow.returnTransfer().move("test")  // not part of this workflow, just for testing


}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
