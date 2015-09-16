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
			throw("tag"+valueName+"does not exist")
		}


	}

	void setNumber(object self,number value1) 
	{
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),"IPrep:"+tagname+":"+valueName,value1)
		// save tags to disk
		ApplicationSavePreferences()
	}

}



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