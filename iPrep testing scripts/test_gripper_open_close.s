// $BACKGROUND$

// Derived from: Script to reseat sample mount in PECS, 8/10/2015 SC
// 20150813 mod to run only gripper - in air

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myGripper = myWorkflow.returnGripper()

void rs( void )
{
	number x=myGripper.readSensor()
	string str = binary(x,4)
	result("\t1: "+datestamp()+": sensor="+str+"\n")
	
		x=myGripper.readSensor()
	 str = binary(x,4)
	result("\t2: "+datestamp()+": sensor="+str+"\n")

		x=myGripper.readSensor()
	 str = binary(x,4)
	result("\t3: "+datestamp()+": sensor="+str+"\n")

}

number x=myGripper.readSensor()
string str = binary(x,4)


number i,N = 10 // # cycles
if ( !continuecanceldialog("Sample must be in PECS to start, with stage lowered"))
	exit(0)
	
if ( !continuecanceldialog("Coupled FWD?"))
	exit(0)
	
if (!getinteger("Enter number of cycles",n,n) )
	exit(0)

//break
image plot := RealImage( "Plot", 4, n, 2 )
plot.setdisplaytype(4)
Showimage(plot)
	number start_time, end_time, duration_seconds

for ( i=0; i<N; i++)
{
//	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
	start_time = GetOSTickCount()
	myWorkflow.returnGripper().open()	
	end_time = GetOSTickCount()
	duration_seconds = CalcOSSecondsBetween( start_time, end_time )
	plot[i,0] = duration_seconds
	
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "0111") result("**************************************************** NOT OPEN")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "0111") result("**************************************************** NOT OPEN")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "0111") result("**************************************************** NOT OPEN")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "0111") result("**************************************************** NOT OPEN")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "0111") result("**************************************************** NOT OPEN")
	


//	myWorkflow.returnTransfer().move("pickup_pecs") // location where open arms can be used to pickup sample
	start_time = GetOSTickCount()
	myWorkflow.returnGripper().close()
	end_time = GetOSTickCount()
	duration_seconds = CalcOSSecondsBetween( start_time, end_time )
	plot[i,1] = duration_seconds
	
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "1011") result("**************************************************** NOT CLOSED")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "1011") result("**************************************************** NOT CLOSED")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "1011") result("**************************************************** NOT CLOSED")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "1011") result("**************************************************** NOT CLOSED")
	x=myGripper.readSensor()
	str = binary(x,4)
	If(str != "1011") result("**************************************************** NOT CLOSED")



//	myWorkflow.returnTransfer().move("beforeGV")    // location where open arms can be used to pickup sample
//	myWorkflow.returnPECS().stageHome()
//	myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
//	myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
//	myWorkflow.returnGripper().open()
//	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
//	myWorkflow.returnGripper().close()
//	myWorkflow.returnTransfer().home()

	if ( shiftdown() && optiondown() ) break

	// myWorkflow.returnTransfer().move("test")  // not part of this workflow, just for testing


}
