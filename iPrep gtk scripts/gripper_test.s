// $BACKGROUND$

object aGripper

aGripper = createGripper(1)
aGripper.init()

aGripper.setManualState("open")
result("Gripper state is: "+aGripper.getState()+"\n")
aGripper.close()
result("Gripper state is: "+aGripper.getState()+"\n")
aGripper.close()
result("Gripper state is: "+aGripper.getState()+"\n")
aGripper.open()
result("Gripper state is: "+aGripper.getState()+"\n")
aGripper.open()
result("Gripper state is: "+aGripper.getState()+"\n")
aGripper.close()

result("test done\n")