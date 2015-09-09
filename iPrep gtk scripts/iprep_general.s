// $BACKGROUND$
// general IPrep functions used in various scripts





number getProtectedModeFlag()
{
	// check 

	TagGroup tg = GetPersistentTagGroup() 
	
	string current
	
	TagGroupGetTagAsString(tg,"IPrep:flags:protected", current )
	
	return val(current)
}


// testing

//result(getProtectedModeFlag()+"\n")
