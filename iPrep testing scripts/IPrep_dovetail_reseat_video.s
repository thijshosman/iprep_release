// $BACKGROUND$
// Script to reseat sample mount in PECS and record
// 2016-06-17 TH

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
number count
number maxcount = 1
number fps = 15
string filename
filename = "C:\\Users\\gatan\\Desktop\\video\\test.mp4"

myWorkflow.returnPECSCamera().liveView()
sleep(3)

number i
string text
number annot
image img:=getfrontimage()
Video_Open( filename, fps )
sleep(1)

try
{



for (count=1; count<=maxcount; count++)
{  
	if (getkey() == 32 || ( controldown() && optiondown() ) )
		break
		
	text = "Loop "+count
	annot = CreateTextAnnotation( img, 5, 5, text )
	updateimage( img )
	
	
	// start video here
	//Video_Start()
	sleep(2)
	

	// perform action
	//myStateMachine.reseat()
	
	sleep(5)

	// stop video here
	//Video_Pause()
	//sleep(1)
	
	deleteannotation(img, annot)
	result("Loop " + count + " complete\n\n")
}


}
catch
{
	result( GetExceptionString() + "\n" )
	deleteannotation(img, annot)

	//Video_Stop()
	break
}

//Video_Stop()
//deleteannotation(img, annot)

// save global tags to disk
ApplicationSavePreferences()

result("done with execution, idle\n\n")
