
// --- testing semcoordmanager ---


// create a manager
//object aMan = alloc(SEMCoordManager)
//aMan.addCoord(aCoord)

// return the manager
object aMan = returnSEMCoordManager()

// create coord
object aCoord1 = alloc(SEMCoord)
aCoord1.set("unittestcoord1",3.11,2.22,4.33,2.1)
result("unittestcoord1: \n")
aCoord1.print()

// save a coord
aMan.addCoord(aCoord1)

// copy coord 
object aCoord2 = aCoord1
aCoord2.setName("unittestcoord2")
aCoord2.set(2.1,2.3,2.4)
result("unittestcoord2: \n")
aCoord2.print()




// save another coord
aMan.addCoord(aCoord2)

// retrieve a coord
object retrCoord1 = aMan.getCoordAsCoord("unittestcoord1")
result("retrieved unittestcoord1: \n")
retrCoord1.print()

// retrieve another coord
object retrCoord2 = aMan.getCoordAsCoord("unittestcoord2")
result("retrieved unittestcoord2: \n")
retrCoord2.print()

// retrieve a coord that does not exist
object retrCoord3 = aMan.getCoordAsCoord("coorddoesnotexist")

// retrieve coord as tag
taggroup tg1
aMan.getCoordAsTag("unittestcoord1",tg1)
tg1.TagGroupOpenBrowserWindow( 0 )

// delete a coord
aMan.delCoord("unittestcoord1")

// cannot delete an empty coordname or one that does nto exist
aMan.delCoord("d")

// print all coords
aMan.printAll()

// retrieve all coords
taggroup tg
tg = aMan.getCoordList()
tg.TagGroupOpenBrowserWindow( 0 ) 


// --- end testing semcoordmanager ---


