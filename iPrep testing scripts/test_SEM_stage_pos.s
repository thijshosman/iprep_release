// $BACKGROUND$

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
	myWorkflow.returnSEM().printCoords()
	result("wf now: "+myWorkflow.returnSEM().getState()+"\n")
	
	//myWorkflow.returnSEM().setManualState("imaging")

	//myWorkflow.returnSEM().goToClear()
	//myWorkflow.returnSEM().goToPickup_Dropoff()
	//myWorkflow.returnSEM().goToNominalImaging()
	//myWorkflow.returnSEM().goTofwdGrid()
	//myWorkflow.returnSEM().goToStoredImaging()
	//myWorkflow.returnSEM().goToHighGridBack()
	//myWorkflow.returnSEM().goToHighGridFront()
	//myWorkflow.returnSEM().goToLowerGrid()
	//myWorkflow.returnSEM().goToScribeMark()
	
