

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()

result("pre")
result(returnWorkflow().returnTransfer().sendCommand("?BIT8467"))
result("post\n")

result(returnWorkflow().returnTransfer().sendCommand("?BIT8467")=="-1")

// KAMR bit check: ?BIT8467