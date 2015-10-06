// $BACKGROUND$

// generic tag functions (JH)

number AddTag( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloat( index, tagValue ) 
	return index
}

number AddTagAsFloat( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloat( index, tagValue ) 
	return index
}

number AddTag( TagGroup tg, string tagName, string tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsString( index, tagValue ) 
	return index
}

number AddTag( TagGroup tg, string tagName, number tagValue1, number tagValue2 )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloatPoint( index, tagValue1, tagValue2 ) 
	return index
}


class statePersistance:object
{
	string tagname
	void init(object self, string name) 
	{
		tagname = name
	}

	// saves and retrieves state information from tags
	// #TODO: create tag if it does not exist yet

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
	
	// name of the tag itself that the value beFloats to
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

	string name

	number X
	number Y
	number Z

	number isSet

	number df_valid // set to 1 if df is set to a valid #
	number df 		// change of focus from current object wrt scribe_pos, lower than scribe_pos is a positive number

	string getName(object self)
	{
		// return name
		return name
	}

	void SEMCoord(object self)
	{
		// constructor
		X=0
		Y=0
		Z=0
		isSet = 0
		df = 0
		df_valid = 0
		name="unnamed"
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

	void set(object self, string name1, number Xn, number Yn, number Zn, number dfn)
	{
		name = name1
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
			result("SEM coord: name:"+name+", X: "+X+", Y: "+Y+", Z: "+Z+", df:"+df+" \n")
		else
			result("SEM coord: name:"+name+", X: "+X+", Y: "+Y+", Z: "+Z+", df:"+"not valid"+" \n")

	}

	taggroup returnAsTag(object self)
	{
		// returns this coord as tag, to be saved in taggroup
		TagGroup tg = NewTagGroup()

		tg.addTag("name",name)
		tg.addTagAsFloat("X", X)
		tg.addTagAsFloat("Y", Y)
		tg.addTagAsFloat("Z", Z)
		tg.addTag("isSet", isSet)
		tg.addTagAsFloat("df", df)
		tg.addTagAsFloat("df_valid", df_valid)

		return tg
	}



}



class SEMCoordManager: object
{
	// manages a list of SEMCoord object saved in tags
	string location // location in persistent taggroup

	void SEMCoordManager(object self)
	{
		// constructor
		location = "IPrep:SEMPositions" // default location
	}

	void init(object self, string location1)
	{
		// inits
		// path to correct tag
		location = location1
	}

	TagGroup getCoordList(object self)
	{
		// get the list of coord tags in the persistent taggroup

		taggroup tg = GetPersistentTagGroup()
		return TagGroupGetOrCreateTagList( tg, location )
	}

	number getCoordAsTag(object self, string name, taggroup &subtag)
	{
		// eagerly finds coord with given name and return it
		taggroup tall = self.getCoordList()
		number count = tall.TagGroupCountTags( ) 
		number i
		
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			string name1
			subtag.TagGroupGetTagAsString("name", name1)

			if (name1 == name)
			{			
				result("found "+name1+"\n")
				//subtag.taggroupopenbrowserwindow(0)
				return 1
			}
		}
		return 0

	}

	void addCoord(object self, object aCoord)
	{
		// adds a coord to the list. create if name does not exist, overwrite if it does
		
		// #todo: check if coord exists
		
		// get the taglist we want to add the coord to
		taggroup t1 = self.getCoordList()
		
		
		taggroup subtag
		// search for the name
		if (self.getCoordAsTag(aCoord.getName(),subtag))
		{
			// coord with same name found, now replace it with the new one
			result("replacing existing "+aCoord.getName()+"\n")
			TagGroupReplaceTagsWithCopy(subtag,aCoord.returnAsTag())
			
			//subtag.TagGroupOpenBrowserWindow( 0 )
			//aCoord.returnAsTag().TagGroupOpenBrowserWindow( 0 )
		}
		else
		{
			result("inserting "+aCoord.getName()+"\n")
			t1.TagGroupAddTagGroupAtEnd( aCoord.returnAsTag() )
		}
		
		ApplicationSavePreferences()

	}

	object convertTagToCoord(object self, taggroup subtag)
	{
		// converts a tag to a sem object

		string name
		subtag.TagGroupGetTagAsString("name",name)

		number X
		subtag.TagGroupGetTagAsFloat("X",X)

		number Y
		subtag.TagGroupGetTagAsFloat("Y",Y)

		number Z
		subtag.TagGroupGetTagAsNumber("Z",Z)
		
		number df
		subtag.TagGroupGetTagAsNumber("df",df)

		object tempCoord = alloc(SEMCoord)
		tempCoord.set(name, X, Y, Z, df)
		return tempCoord
	}

	object getCoordAsCoord(object self, string name)
	{
		// returns tag with given name from persistent list and create coord
		taggroup subtag
		self.getCoordAsTag(name,subtag)
		return self.convertTagToCoord(subtag)

		//return self.convertTagToCoord(subtag)

	}

	void printAll(object self)
	{
		// prints all coords
		
		// get the list of stored coords
		taggroup tall = self.getCoordList()
		number count = tall.TagGroupCountTags( ) 
		number i
		taggroup subtag // temporary storage
		string name
		
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			
			TagGroupGetTagAsString(subtag,"name",name)
			//result(name+"\n")
			self.convertTagToCoord(subtag).print()

			//tg.TagGroupOpenBrowserWindow( 0 )
			//result(i)
		}

	}

}


class positionManager: object
{
	
	// manages list of allowed parker coordinates
	
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

// --- testing semcoordmanager ---

/*

object aCoord = alloc(SEMCoord)
aCoord.set("testcoord3",3.11,2.22,4.33,2.1)

object aMan = alloc(SEMCoordManager)

aMan.addCoord(aCoord)

//taggroup tg1
//aMan.getCoordAsTag("testcoord1",tg1)

//aMan.addCoord(aCoord)


aMan.printAll()

aMan.getCoordAsCoord("testcoord3").print()

//taggroup tg
//tg = Man.getCoordList()
//tg1.TagGroupOpenBrowserWindow( 0 ) 

*/

// --- end testing semcoordmanager ---

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


// --- testing persistance ---

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



// -- end testing persistance ---