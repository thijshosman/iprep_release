// $BACKGROUND$

// creating docks, 1 = simulator, 2 = planar, 3 is ebsd


// *** planar case ***
object aplanarSEMdock
aplanarSEMdock = createDock(2)
aplanarSEMdock.init()


//aplanarSEMdock.setManualState("clamped")

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