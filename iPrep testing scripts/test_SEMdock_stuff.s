// SEMdock stuff
// 

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object mySEMdock = myWorkflow.returnSEMdock()

	number x=mySEMdock.readSensor()
	string str = binary(x,4)
	result("sensor= "+str+"\n")
result(mySEMdock.getstate())
//self.sendCommand("T")

//mySEMdock.goUp()
mySEMdock.goDown()

	x=mySEMdock.readSensor()
	str = binary(x,4)
	result("sensor= "+str+"\n")
result(mySEMdock.getstate())