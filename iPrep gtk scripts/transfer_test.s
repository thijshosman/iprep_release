// $BACKGROUND$

// for safetychecks

object aPecs
aPecs = createPecs(1)
aPecs.init()

object aSem
aSem = createSem(1)
aSem.init()

// make sure gv is open
aPecs.openGVandCheck()
result("test init: gv state: "+aPecs.getGVState()+"\n")

// make sure stage is lowered
aPecs.moveStageDown()
result("test init: stage state: "+aPecs.getStageState()+"\n")

// make sure SEM is in known state
aSem.setManualState("clear")
result("test init: sem state: "+aSem.getSEMState()+"\n")


object aTransfer
aTransfer = createTransfer(1)
aTransfer.init()




result("\ntest starts\n\n")


// home parker stage
aTransfer.home()

// safe move
aTransfer.move("open_pecs")
result("test: current position: "+aTransfer.getCurrentPosition()+"\n")

// see if we can raise stage, should fail
//aPecs.moveStageUp()

aTransfer.move("dropoff_sem")
result("test: current position: "+aTransfer.getCurrentPosition()+"\n")

// see if we can close the GV
aPecs.closeGVandCheck()


aTransfer.move("outofway")
result("test: current position: "+aTransfer.getCurrentPosition()+"\n")


// test what happens if we move the stage up, should fail
//aPecs.moveStageUp()

aTransfer.move("open_pecs")
result("test: current position: "+aTransfer.getCurrentPosition()+"\n")




result("\ntest done\n\n")