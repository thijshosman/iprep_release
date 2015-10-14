void AddTagGroup(taggroup tg, taggroup child, string path, string label)
{

	taggroup tg1 = tg.TagGroupCreateNewLabeledGroup(path)	
	tg1.TagGroupAddLabeledTagGroup(label, child )
	 
}
/*
taggroup PT = NewTagGroup()
PT.AddTag("test",2)

TagGroup tg = NewTagGroup()
tg.AddTag("test",1)

PT.AddTagGroup(tg,"IPrep:sub1","simulation11")
PT.TagGroupOpenBrowserWindow( 0 ) 
*/

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
PT.AddTagGroup(tg,"IPrep","simulation11")
