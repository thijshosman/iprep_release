// Gripper stuff
// 

object myWorkflow = returnWorkflow()
object myStateMachine = returnStateMachine()
object myGripper = myWorkflow.returnGripper()

	number x=myGripper.readSensor()
	string str = binary(x,4)
	result("sensor= "+str+"\n")
result(mygripper.getstate())
//self.sendCommand("T")

//myGripper.open()
//myGripper.close()

	x=myGripper.readSensor()
	str = binary(x,4)
	result("sensor= "+str+"\n")
result(mygripper.getstate())