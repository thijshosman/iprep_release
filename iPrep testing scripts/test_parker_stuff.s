// Parker stuff

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myGripper = myWorkflow.returnGripper()

//myWorkflow.returnTransfer().home()
//result(myWorkflow.returnTransfer().getCurrentPosition())
//myWorkflow.returnTransfer().move("prehome") 
//myWorkflow.returnTransfer().home()
//myWorkflow.returnTransfer().move("test")
//myWorkflow.returnTransfer().turnOff()  // turn off Parker to stop noise