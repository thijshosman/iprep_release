// $BACKGROUND$

// for safetychecks
object aTransfer
aTransfer = createTransfer(1)
aTransfer.init()

// home parker stage so that we can close the gv
aTransfer.home()

// manually set the parker position tag to >150 to test gv not opening

object myMediator = returnMediator()
result("mediator parkerpos: "+myMediator.getCurrentPosition()+"\n")

object aPecs

aPecs = createPecs(1)
aPecs.init()

result("\ntest starts\n\n")


// GV
result("test init: gv state: "+aPecs.getGVState()+"\n")
aPecs.openGVandCheck()
result("test after open: gv state: "+aPecs.getGVState()+"\n")
aPecs.closeGVandCheck()
result("test after close: gv state: "+aPecs.getGVState()+"\n")
aPecs.closeGVandCheck()
result("test after close: gv state: "+aPecs.getGVState()+"\n")

// stage
result("test init: stage state: "+aPecs.getGVState()+"\n")
aPecs.moveStageUp()
result("test after up: stage state: "+aPecs.getStageState()+"\n")
aPecs.moveStageDown()
result("test after down: stage state: "+aPecs.getStageState()+"\n")
aPecs.moveStageDown()
result("test after down: stage state: "+aPecs.getStageState()+"\n")

// misc
result("systemstatus: "+aPecs.getSystemStatus()+"\n")
result("millingstatus: "+aPecs.getMillingStatus()+"\n")
result("argoncheck: "+aPecs.argonCheck()+"\n")
result("tmpcheck: "+aPecs.TMPCheck()+"\n")


result("\ntest done\n\n")