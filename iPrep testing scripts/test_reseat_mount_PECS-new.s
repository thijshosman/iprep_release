// $BACKGROUND$
// Script to reseat sample mount in PECS
// 8/10/2015 SC

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
number count
number maxcount = 1
number fps = 15
string filename
filename = "C:\\Users\\gatan\\Desktop\\video\\test.mp4"

number i
string text
number annot
image img:=getfrontimage()
Video_Open( filename, fps )
sleep(1)

try
{

//myWorkflow.returnPecs().moveStageDown()

for (count=1; count<=maxcount; count++)
{  
	if (getkey() == 32 || ( controldown() && optiondown() ) )
		break
		
	text = "Loop "+count
	annot = CreateTextAnnotation( img, 5, 5, text )
	updateimage( img )
	
	
	//home pecs stage
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home

	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
	myWorkflow.returnGripper().open()	
	myWorkflow.returnTransfer().move("pickup_pecs") // location where open arms can be used to pickup sample
	myWorkflow.returnGripper().close()

	myWorkflow.returnTransfer().move("test")    // location where sample is free of PECS before GV

	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "7")  // works,  stage to right front
	//PIPS_SetPropertyDevice("subsystem_milling", "device_stage", "set_rotate_mode", "3")  // works,  stage to home
	
	// turn on chamber illuminator
	PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "1")   //turn on chamber illuminator
	// start video here
	Video_Start()
//sleep(2)
	
	myWorkflow.returnTransfer().move("dropoff_pecs") // location where sample gets dropped off in PECS
	myWorkflow.returnTransfer().move("dropoff_pecs_backoff") // location where sample gets dropped off in PECS
	
	// stop video here
	Video_Pause()
	//sleep(1)
	
	myWorkflow.returnGripper().open()
	
	// take image, convert to integer, check average intensity: stop if > 20% change?
	//do cross-correlation, if sample has moved > 1 mm stop
	PIPS_SetPropertyDevice("subsystem_milling", "device_cpld", "bit_24", "0")   //turn off chamber illuminator
	
	myWorkflow.returnTransfer().move("open_pecs")  // location where arms can open in PECS	
	myWorkflow.returnGripper().close()
	myWorkflow.returnTransfer().home()
	sleep(5)
	
	deleteannotation(img, annot)

}


}
catch
{
	result( GetExceptionString() + "\n" )
	deleteannotation(img, annot)

	Video_Stop()
}

Video_Stop()
deleteannotation(img, annot)

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
