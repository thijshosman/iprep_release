// $BACKGROUND$

class statePersistance:object
{
	string tagname
	void init(object self, string name) 
	{
		tagname = name
	}

	// saves and retrieves state information from tags
	// TODO: create tag if it does not exist yet

	string getState(object self) 
	{
		// TODO: no checking if tag actually exists
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,"IPrep:"+tagname+":state", current )
		return current
	}

	void setState(object self,string state) 
	{
		TagGroupSetTagAsString(GetPersistentTagGroup(),"IPrep:"+tagname+":state",state)

		// save tags to disk
		ApplicationSavePreferences()
	}

}

class statePersistanceNumeric:object
{
	// name of tag group under which this is stored
	string tagname
	
	// name of the tag itself that the value belongs to
	string valueName

	void init(object self, string name) 
	{
		tagname = name
		valuename = "value"
	}

	TagGroup getStoredNumber(object self)
	{
		// *** private ***
		// return taglist of stored numbers under the name
		
		TagGroup tg = GetPersistentTagGroup() 
		TagGroup subtag
		tg.TagGroupGetTagAsTagGroup( "IPrep:"+tagname, subtag )
		return subtag
	}
	
	number getNumber(object self) 
	{
		number value1
		
		taggroup subtag = self.getStoredNumber()
		if (TagGroupDoesTagExist(subtag,valueName)) {
			TagGroupGetTagAsNumber(subtag,valueName,value1)
			return value1
		} else {
			throw("tag: "+valueName+" does not exist")
		}


	}

	void setNumber(object self,number value1) 
	{
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:"+tagname+":"+valueName,value1)
		// save tags to disk
		ApplicationSavePreferences()
	}

}

class SEMCoord: object
{
	// simple container class for storing SEM coordinates (x, y and z)

	number X
	number Y
	number Z

	number isSet

	number df_valid // set to 1 if df is set to a valid #
	number df 		// change of focus from current object wrt scribe_pos, lower than scribe_pos is a positive number



	void SEMCoord(object self)
	{
		// constructor
		X=0
		Y=0
		Z=0
		isSet = 0
		df = 0
		df_valid = 0
	}

	void setdf(object self, number val)
	// df_valid - set to 1 if df is set to a valid #
	// df - change of focus from current object wrt scribe_pos, lower than scribe_pos is a positive number
	{
		df = val
		df_valid = 1
	}


	void cleardf(object self)
	{
		df = 0
		df_valid = 0
	}

	void set(object self, number Xn, number Yn, number Zn)
	{
		X = Xn
		Y = Yn
		Z = Zn
		isSet = 1
		df = 0
		df_valid = 0

	}

	void set(object self, number Xn, number Yn, number Zn, number dfn)
	{
		X = Xn
		Y = Yn
		Z = Zn
		isSet = 1
		df = dfn
		df_valid = 1

	}


	number getX(object self)
	{
		return X
	}

	number getY(object self)
	{
		return Y
	}

	number getZ(object self)
	{
		return Z
	}

	number getdf(object self)
	{
		return df
	}

	number getdfvalid(object self)
	{
		return df_valid
	}

	void print(object self)
	{
		if (df_valid)
			result("SEM coord: X: "+X+", Y: "+Y+", Z: "+Z+", df:"+df+" \n")
		else
			result("SEM coord: X: "+X+", Y: "+Y+", Z: "+Z+", df:"+"not valid"+" \n")

	}

}

/*
class SEMCoordManager: object
{
	// manages a list of SEMCoord object saved in tags

	void SEMCoordManager(object self)
	{
		// constructor
	}

	void initCoord(object self, string name)
	{
		// *** private ***
		// create empty record in taglist
		//TagGroup TagGroupAddTagGroupAtEnd( TagGroup tagList, TagGroup newGroup ) 
	}

	object getCoordFromTag(object self, string name)
	{
		// *** public ***
		// returns SEMCoord object from the taglist
		TagGroup tg = GetPersistentTagGroup() 
		TagGroup coordlist
		tg.TagGroupGetTagAsTagGroup( "Iprep", infoTG )



	}

	void saveCoordToTag(object self, object aSEMCoord)
	{
		// *** public ***
		// saves a coord to a tag

	}

	taglist listCoords(object self)
	{

	}

}
*/

class positionManager: object
{
	
	// TODO: detect kill switch in parker software and throw error if set
	
	number savePosition(object self, string positionName, number position)
	{
		//save (or overwrite) position with name
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:parkerpositions:"+positionName,position)
		ApplicationSavePreferences()
	}
	
	TagGroup getStoredPositions(object self)
	{
		//return taglist of all stored positions
		TagGroup tg = GetPersistentTagGroup() 
		TagGroup subtag
		tg.TagGroupGetTagAsTagGroup( "IPrep:parkerpositions", subtag )
		return subtag
	}
	


	number getPosition(object self, string positionName)
	{
		//return position based on name of tag and throws error if it does not exist
		number position
		taggroup subtag = self.getStoredPositions()
		if (TagGroupDoesTagExist(subtag,positionName)) {
			TagGroupGetTagAsNumber(subtag,positionname,position)
			return position
		} else {
			throw("tag"+positionName+"does not exist")
		}
	}

	void saveLastState(object self, string laststate)
	{
		TagGroupSetTagAsString(GetPersistentTagGroup(),"IPrep:parkerState:lastState",laststate)	
		ApplicationSavePreferences()
	}

	void saveCurrentState(object self, string currentstate)
	{
		TagGroupSetTagAsString(GetPersistentTagGroup(),"IPrep:parkerState:currentState",currentstate)
		ApplicationSavePreferences()
	}
	
	void saveCurrentPosition(object self, number current)
	{
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:parkerState:currentPosition",current)
		ApplicationSavePreferences()
	}
	
	number getCurrentPosition(object self)
	{
		// returns current position as saved in tags

		TagGroup tg = GetPersistentTagGroup() 
		number current
		TagGroupGetTagAsNumber(tg,"IPrep:parkerState:currentPosition", current )
		return current

	}

	string getCurrentState(object self)
	{
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,"IPrep:parkerState:currentState", current )
		return current
	}

	string getLastState(object self)
	{
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,"IPrep:parkerState:lastState", current )
		return current
	}

}


// --- testing positionmanager ---

//object apositionManager = alloc(positionManager)
//apositionManager.savePosition("testposition3",33)
//taggroup currentPositions
//currentPositions = apositionManager.getStoredPositions()
//currentPositions.TagGroupOpenBrowserWindow( 0 ) 

//number pos
//pos = apositionManager.getPosition("testposition3")
//result("\n"+pos+"\n")
//apositionManager.saveCurrentState("teststate")
//apositionManager.saveLastState("teststate")
//result(apositionManager.getCurrentState())

// --- end testing positionmanager ---







// --- testing ---

// text class
//object gripperPersistance1 = alloc(statePersistance)
//gripperPersistance1.init("test")
//gripperPersistance1.setState(1)
//result(gripperPersistance1.getState())


// numeric class
//object gripperPersistance2 = alloc(statePersistanceNumeric)
//gripperPersistance2.init("Test")
//gripperPersistance2.setNumber(44)
//gripperPersistance2.getStoredNumber().TagGroupOpenBrowserWindow( 0 )
//result(gripperPersistance2.getNumber())








// -- end testing ---