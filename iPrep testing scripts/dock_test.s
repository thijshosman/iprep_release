// $BACKGROUND$

object aplanarSEMdock

aplanarSEMdock = createDock(1)
aplanarSEMdock.init()



aplanarSEMdock.setManualState("clamped")

result("test: current state: "+aplanarSEMdock.getState()+"\n")

aplanarSEMdock.lookupState(1)

aplanarSEMdock.clamp()


result("test: current state: "+aplanarSEMdock.getState()+"\n")

aplanarSEMdock.clamp()


result("current state: "+aplanarSEMdock.getState()+"\n")

aplanarSEMdock.unclamp()

result("current state: "+aplanarSEMdock.getState()+"\n")

aplanarSEMdock.unclamp()

result("current state: "+aplanarSEMdock.getState()+"\n")

//result("sensor input: "+aplanarSEMdock.sensorToBitStr()+"\n")
result("sample present: "+aplanarSEMdock.checkSamplePresent()+"\n")

result("test done\n")