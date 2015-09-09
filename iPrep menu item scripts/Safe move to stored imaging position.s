// $BACKGROUND$
// Use this script to get to stored imaging position if stuck in clear or pickup/dropoff
object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

string state = myWorkflow.returnSEM().getState()
if (!OKCancelDialog( "Currently SEM is in state \""+state+"\", goto stored imaging position?" ) )
	exit(0)
	
// if parker stage in SEM chamber, then do nothing
number pos = myWorkflow.returnTransfer().getCurrentPosition()
if (pos > 431)
	throw("Can't move SEM stage to imaging position when transfer arm is in SEM chamber")


if ( myWorkflow.returnSEM().getState() == "pickup_dropoff" )
	myWorkflow.returnSEM().goToClear()		

if ( myWorkflow.returnSEM().getState() == "clear" )
	myWorkflow.returnSEM().goToNominalImaging()		

	myWorkflow.returnSEM().goToStoredImaging()		
