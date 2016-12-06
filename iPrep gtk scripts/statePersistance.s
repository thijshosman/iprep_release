// $BACKGROUND$

// generic tag functions (JH)

number AddTag( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloat( index, tagValue ) 
	ApplicationSavePreferences()
	return index
}

number AddTagAsFloat( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloat( index, tagValue ) 
	ApplicationSavePreferences()
	return index
}

number AddTag( TagGroup tg, string tagName, string tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsString( index, tagValue ) 
	ApplicationSavePreferences()
	return index
}

number AddTag( TagGroup tg, string tagName, number tagValue1, number tagValue2 )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloatPoint( index, tagValue1, tagValue2 ) 
	ApplicationSavePreferences()
	return index
}

void AddTagGroup(taggroup tg, taggroup child, string path, string label)
{
	// creates taggroup with name label at path and copies child into it
	tg.TagGroupSetTagAsTagGroup(path+":"+label, child ) 
	ApplicationSavePreferences()
}

void AddTagGroup(taggroup tg, taggroup child, string path)
{
	// creates taggroup with name label at path and copies child into it
	tg.TagGroupSetTagAsTagGroup(path, child ) 
	ApplicationSavePreferences()
}

void overwriteTag(taggroup tg, string path, string name)
{
	TagGroupSetTagAsString(getpersistenttaggroup(), path, name)
	ApplicationSavePreferences()
}

void overwriteTag(taggroup tg, string path, number value)
{
	TagGroupSetTagAsFloat(getpersistenttaggroup(), path, value)
	ApplicationSavePreferences()
}

number GetTagValue(string tagpath)
{
	// check if tagpath exists, and if it does, retrieve the value and return it
	number returnvalue
	taggroup subtag = GetPersistentTagGroup()
	if (TagGroupDoesTagExist(subtag,tagpath)) 
		TagGroupGetTagAsNumber(subtag,tagpath,returnvalue)
	else
		throw(tagpath+" does not exist!")

	return returnvalue
}

string GetTagString(string tagpath)
{
	// check if tagpath exists, and if it does, retrieve the value and return it
	string returnstring
	taggroup subtag = GetPersistentTagGroup()
	if (TagGroupDoesTagExist(subtag,tagpath)) 
		TagGroupGetTagAsString(subtag,tagpath,returnstring)
	else
		throw("tag at"+tagpath+" does not exist!")

	return returnstring
}

taggroup GetTagGroup(string tagpath)
{

	TagGroup tg = GetPersistentTagGroup() 
	TagGroup subtag
	if (tg.TagGroupDoesTagExist(tagpath))
	{	
		tg.TagGroupGetTagAsTagGroup( tagpath, subtag )
		return subtag
	}
	else
	{
		throw("tag at"+tagpath+" does not exist!")
	}

}

string GetTagStringFromSubtag(string tagpath, taggroup subtag)
{
	// check if tagpath exists, and if it does, retrieve the value and return it
	string returnstring
	//taggroup subtag = GetPersistentTagGroup()
	if (TagGroupDoesTagExist(subtag,tagpath)) 
		TagGroupGetTagAsString(subtag,tagpath,returnstring)
	else
		throw("tag at"+tagpath+" does not exist!")

	return returnstring
}

number GetTagValueFromSubtag(string tagpath, taggroup subtag)
{
	// check if tagpath exists, and if it does, retrieve the value and return it
	number returnvalue
	//taggroup subtag = GetPersistentTagGroup()
	if (TagGroupDoesTagExist(subtag,tagpath)) 
		TagGroupGetTagAsNumber(subtag,tagpath,returnvalue)
	else
		throw("tag at"+tagpath+" does not exist!")

	return returnvalue
}

//subtag.taggroupopenbrowserwindow(0)

class persistentTag: object
{
	// class that can be used to save and load a eneral tag number or string

	string tagname

	persistentTag(object self)
	{
		// constructor
	}

	void set(object self, string str1)
	{
		// save tag in path
		TagGroupSetTagAsString(GetPersistentTagGroup(),tagname,str1)
		ApplicationSavePreferences()
	}

	void set(object self, number val1)
	{
		// save tag in path
		TagGroupSetTagAsNumber(GetPersistentTagGroup(),tagname,val1)
		ApplicationSavePreferences()
	}

	string get(object self)
	{
		// return value as string
		
		TagGroup tg = GetPersistentTagGroup() 
		string current
		TagGroupGetTagAsString(tg,tagname, current )
		return current

	}

	void init(object self, string tagpath1)
	{
		// set the tagpath
		tagname = tagpath1
		taggroup tg = GetPersistentTagGroup()
		if ( !tg.TagGroupDoesTagExist(tagname) )
		{	
			self.set("default_initialized")
			ApplicationSavePreferences()
			
			
		}
		
		// check if tag has real value, not just "default_initialized"
		string current
		TagGroupGetTagAsString(tg,tagname, current )
		if (current == "default_initialized")
		{
			string er = "persistentTag: "+tagname+" exists but has default value, please set to correct state"
			result(er+"\n")
			throw(er)	
		}



	}


}

class statePersistance:object
{
	// general class to contain tag "state" in path following "IPrep" subtag
	string tagname
	void init(object self, string name) 
	{
		tagname = name
		
		taggroup tg = GetPersistentTagGroup()

		// check if tag already exists
		if ( !tg.TagGroupDoesTagExist("IPrep:"+tagname) )
		{	
			// tag does not yet exist, create but set to "default_initialized" 
			TagGroupSetTagAsString(tg,"IPrep:"+tagname+":state","default_initialized")
			result("tag "+tagname+" created and set to default value\n")
			ApplicationSavePreferences()

		}

		// check if tag has real value, not just "default_initialized"
		string current
		TagGroupGetTagAsString(tg,"IPrep:"+tagname+":state", current )
		if (current == "default_initialized")
		{
			string er = "statePersistance: IPrep:"+tagname+" exists but has default value, please set to correct state"
			result(er+"\n")
			throw(er)	
		}
	}

	// saves and retrieves state information from tags

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
	// stores numbers in IPrep:NameOfVale:value

	// name of tag group under which this is stored
	string tagname
	
	// name of the tag itself that the value is stored as
	string valueName

	void init(object self, string name) 
	{
		tagname = name
		valueName = "value"
		taggroup tg = GetPersistentTagGroup()

/*		// create tag if it does not exist yet
		
		if ( !tg.TagGroupDoesTagExist("IPrep:"+tagname) )
		{	
			//self.set("default_initialized")
			//ApplicationSavePreferences()
			result("trying to create IPrep:"+tagname+", problem\n")
			throw("tag at IPrep:"+tagname+" does not exist. please create")
		}	
*/
		// check if tag already exists
		if ( !tg.TagGroupDoesTagExist("IPrep:"+tagname) )
		{	
			// tag does not yet exist, create but set to "default_initialized" 
			TagGroupSetTagAsString(tg,"IPrep:"+tagname+":"+valueName,"default_initialized")
			result("tag "+tagname+" created and set to default value\n")
			ApplicationSavePreferences()

		}

		// check if tag has real value, not just "default_initialized"
		string current
		TagGroupGetTagAsString(tg,"IPrep:"+tagname+":"+valueName, current )
		if (current == "default_initialized")
		{
			string er = "statePersistanceNumeric: IPrep:"+tagname+" exists but has default value, please set to correct state"
			result(er+"\n")
			throw(er)	
		}

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

	void setName(object self, string name1)
	{
		// set name
		name = name1
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

	void set(object self, string name1, number Xn, number Yn, number Zn)
	{
		name = name1
		X = Xn
		Y = Yn
		Z = Zn
		isSet = 1
		df_valid = 0
	}

	void setX(object self, number X1)
	{
		X=X1
	}

	void setY(object self, number Y1)
	{
		Y=Y1
	}

	void setZ(object self, number Z1)
	{
		Z=Z1
	}

	void corrX(object self, number corr)
	{
		X=X+corr
	}

	void corrY(object self, number corr)
	{
		Y=Y+corr
	}

	void corrZ(object self, number corr)
	{
		Z=Z+corr
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

	void adjust(object self, object vector)
	{
		// adjust the current coord with the vector contained as argument
		self.print("adjusting current coord (x,y,z) by ("+vector.getX()+","+vector.getY()+", "+vector.getZ()+")")
		self.corrX(vector.getX())
		self.corrY(vector.getY())
		self.corrZ(vector.getZ())
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

object SEMCoordFactory(string name)
{
	object aCoord = alloc(SEMCoord)
	aCoord.set(name,0,0,0)
	return aCoord
}

object SEMCoordFactory(string name,x,y,z)
{
	object aCoord = alloc(SEMCoord)
	aCoord.set(name,x,y,z)
	return aCoord
}

class SEMCoordManager: object
{
	// manages a list of SEMCoord object saved in tags
	string location // location in persistent taggroup

	void log(object self, number level, string text)
	{
		// log events in log files
		LogEvent("SEMCoordManager", level, text)
	}

	void print(object self, string printstr)
	{
		result("SEMCoordManager: "+printstr+"\n")
		self.log(2,printstr)
	}

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

	number checkCoordExistence(object self, string name)
	{
		// returns 1 if coord found

		taggroup subtag // not used
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
				//result("found "+name1+"\n")
				//subtag.taggroupopenbrowserwindow(0)
				return 1
			}
		}
		return 0
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
				self.print("found "+name1)
				//subtag.taggroupopenbrowserwindow(0)
				return 1
			}
		}
		return 0

	}

	void addCoord(object self, object aCoord)
	{
		// adds a coord to the list. create if name does not exist, overwrite if it does
		
		// get the taglist we want to add the coord to
		taggroup t1 = self.getCoordList()
		
		taggroup subtag
		// search for the name
		if (self.getCoordAsTag(aCoord.getName(),subtag))
		{
			// coord with same name found, now replace it with the new one
			self.print("replacing existing "+aCoord.getName())
			TagGroupReplaceTagsWithCopy(subtag,aCoord.returnAsTag())
			
			//subtag.TagGroupOpenBrowserWindow( 0 )
			//aCoord.returnAsTag().TagGroupOpenBrowserWindow( 0 )
		}
		else
		{
			// coord with that name does not exist yet. add it. 
			self.print("inserting "+aCoord.getName())
			t1.TagGroupAddTagGroupAtEnd( aCoord.returnAsTag() )
		}
		
		ApplicationSavePreferences()

	}

	number delCoord(object self, string namestring)
	{
		// delete a coord with name "namestring"
		taggroup tall =self.getCoordList()
		number count = tall.TagGroupCountTags( ) 
		number i
		
		if(namestring == "")
			return 0 // no empty namestring allowed

		taggroup subtag
		for (i=0; i<count; i++)
		{
			// index the list and get single tag
			tall.TagGroupGetIndexedTagAsTagGroup(i,subtag)
			string name1
			subtag.TagGroupGetTagAsString("name", name1)

			if (name1 == namestring)
			{			
				// found, delete the tag with this index
				//subtag.taggroupopenbrowserwindow(0)
				tall.TagGroupDeleteTagWithIndex(i)
				self.print("deleted coord: "+name1)
				return 1
			}
		}
		return 0 // not found
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
		if (self.getCoordAsTag(name,subtag))
			return self.convertTagToCoord(subtag)
		else
			return NULL
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

// general class
//object rightsccmPersistance = alloc(persistentTag)
//rightsccmPersistance.init("testtag:rightsccm")
//rightsccmPersistance.set("7")
//result(rightsccmPersistance.get())



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