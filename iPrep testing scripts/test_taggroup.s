void AddTagGroup1(taggroup tg, taggroup child, string path, string label)
{

	if (label == "")
		return
	
	// get path to where this new child taggroup needs to be saved
	taggroup tg1
	// create right path if it does not exist yet and return it
	if (!TagGroupDoesTagExist(tg,path))
	{	
		result(path+" does not exist, adding path\n")
		tg1 = tg.TagGroupCreateNewLabeledGroup(path)	
	}
	else
	{
		result(path+" does exist\n")
		// now add label to path
		tg1 = tg
		//TagGroupSetTagAsTagGroup( TagGroup tagGroup, String tagPath, TagGroup subGroup ) 

	}
	
	//tg1.TagGroupOpenBrowserWindow( 0 ) 

	
	// if taggroup plus label already exists, delete it first, then add it
	if (TagGroupDoesTagExist(tg1,path+":"+label))
	{
		result(path+label+" already exists, need to delete\n")
		tg1.TagGroupDeleteTagWithLabel(label)
		tg1.TagGroupAddLabeledTagGroup(label, child )
	}
	else 
	{
		result(path+label+" does not exist, adding\n")
		tg1.TagGroupAddLabeledTagGroup(label, child )
	}
}

void AddTagGroup2(taggroup tg, taggroup child, string path, string label)
{
		tg.TagGroupSetTagAsTagGroup(path+":"+label, child ) 
}



result("\ndone\n")


/*
taggroup PT = NewTagGroup()
PT.AddTag("test",2)

TagGroup tg = NewTagGroup()
tg.AddTag("test",1)

PT.AddTagGroup1(tg,"IPrep:sub1","simulation11")
PT.TagGroupOpenBrowserWindow( 0 ) 
*/

TagGroup PT = TagGroupClone(GetPersistentTagGroup())
//PT.TagGroupOpenBrowserWindow( 0 ) 


// simulation
TagGroup tg = NewTagGroup()
tg.AddTag("digiscan",3)
tg.AddTag("dock",1)
tg.AddTag("gripper",1)
tg.AddTag("mode","ebsd")
tg.AddTag("pecs",1)
tg.AddTag("pecscamera",1)
tg.AddTag("sem",1)
tg.AddTag("transfer",1)
PT.AddTagGroup2(tg,"test22","simulation1")

TagGroup tg1 = NewTagGroup()
tg1.AddTag("state",0)

PT.AddTagGroup(tg1,"test22","dead")

PT.TagGroupOpenBrowserWindow( 0 ) 
