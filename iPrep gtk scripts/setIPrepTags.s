
void setSimulationTags()
{
	TagGroup PT = GetPersistentTagGroup()

	// simulation
	TagGroup tg = NewTagGroup()
	tg.AddTag("digiscan",1)
	tg.AddTag("dock",1)
	tg.AddTag("gripper",1)
	tg.AddTag("mode","ebsd")
	tg.AddTag("pecs",1)
	tg.AddTag("pecscamera",1)
	tg.AddTag("sem",1)
	tg.AddTag("transfer",1)
	PT.AddTagGroup(tg,"IPrep","simulation")

}

taggroup setFlagTags()
{

	TagGroup PT = NewTagGroup()

	// dead
	TagGroup tg1 = NewTagGroup()
	tg1.AddTag("state",0)
	PT.AddTagGroup(tg1,"flags","dead")

	// device
	TagGroup tg2 = NewTagGroup()
	tg2.AddTag("state","SEM")
	PT.AddTagGroup(tg2,"flags","device")	

	// errorcode
	TagGroup tg3 = NewTagGroup()
	tg3.AddTag("value",0)
	PT.AddTagGroup(tg3,"flags","errorcode")

	// safety
	TagGroup tg4 = NewTagGroup()
	tg4.AddTag("state",1)
	PT.AddTagGroup(tg4,"flags","safe")

	// unsafeReason
	TagGroup tg5 = NewTagGroup()
	tg5.AddTag("state","")
	PT.AddTagGroup(tg5,"flags","unsafeReason")

	// exception
	TagGroup tg6 = NewTagGroup()
	tg6.AddTag("state","")
	PT.AddTagGroup(tg6,"flags","exception")	

	PT.AddTag("protected",0)

	TagGroup persist = GetPersistentTagGroup()

	persist.AddTagGroup(PT,"IPrep",)


}






void createSEMPositionTags(object self)
	{
		// set the default SEM coord tags and populate them with default values
		// will later be overwritten by calibration routines in sem_iprep class
		// this method is not intended to be used other than during setup
		// and the only reason it exists is because it is a lot of work to manually
		// type all these tags

		object tempCoord = alloc(SEMCoord)
		
		//tempCoord.set(object self, string name1, number Xn, number Yn, number Zn, number dfn)

		// each dock has two calibrated points
		//	-reference, which is the manually calibrated pickup_dropoff point
		//	-scribe_pos, which is the position of the scribe mark on the dock

		// for each dock, all the imaging positions have a known vector from the scribe_pos
		// similarly, the clear positions has a known vector from the reference point

		// transfer between clear and nominal imaging is considered safe as long as it is known
		// in which direction we move first

		// EBSD dock points

		tempCoord.set("reference_ebsd", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("scribe_pos_ebsd", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		// planar dock points

		tempCoord.set("reference_planar", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("scribe_pos_planar", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)		

		// inferred points + used points

		// manually calibrated "pickup_dropoff" point. used to infer "clear"
		tempCoord.set("reference", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		// scribe, used to infer all imaging positions
		tempCoord.set("scribe_pos", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		// positions defined on dock inferred from 

		tempCoord.set("highGridFront", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("highGridBack", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("lowergrid", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)	

		tempCoord.set("fwdGrid", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)
		
		// positions defined on dock

		tempCoord.set("pickup_dropoff", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("clear", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("nominal_imaging", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

		tempCoord.set("stored_imaging", 0, 0, 0, 0)
		returnSEMCoordManager().addCoord(tempCoord)

	}

taggroup createSimulationTags

TagGroup tg = NewTagGroup()



tg = getpersistanttaggroup()




