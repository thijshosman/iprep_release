// measures chamber pressure after opening gate valve

// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myMediator = returnMediator()


// open gv
myWorkflow.returnPecs().openGVandCheck()

result("gas flow = 1 (2x) \n")

number tick = GetOSTickCount()
number i
for (i = 0; i<50; i++)
{
	
	result("time: "+(GetOSTickCount()-tick)/1000+", pressure: "+FEIQuanta_GetVacuumPressure()*0.01+"\n")
	sleep(0.100)
}

