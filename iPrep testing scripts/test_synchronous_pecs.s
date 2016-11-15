// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()

number j
sleep(2)
try
{
	result("start\n")

	string value1
	string value2

	for (j=0;j<100;j++)
	{
		// get WL value, 1 if lowered
		PIPS_GetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", value1) 
		debug("wl state: "+value1+"\n")
		
		// get TMP speed, 1500 
		//PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", value2)
		//result("tmp state: "+value2+"\n")
	}
	result("stop\n")
}
catch
{
	result( GetExceptionString() + "\n" )
}

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
