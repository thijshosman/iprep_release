// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

string tag ="IPrep:parkerpositions:test"
string val
getpersistentstringnote( tag, val )
if (!getstring("Test:", val, val ) )
	exit(0)
	
Setpersistentstringnote( tag, val )
myWorkflow.returnTransfer().move("test")  // test location from tags  
