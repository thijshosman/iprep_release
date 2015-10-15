//taggroup tg = getpersistenttaggroup()

TagGroup PT = TagGroupClone(GetPersistentTagGroup())

taggroup ipreptg 
PT.TagGroupGetTagAsTagGroup("IPrep",ipreptg)

//ipreptg.TagGroupOpenBrowserWindow( 0 )

ipreptg.TagGroupSaveToFile("c:\\temp\\iprep")

taggroup ipreploadtg = newtaggroup()

ipreploadtg.TagGroupLoadFromFile("c:\\temp\\iprep")

ipreploadtg.TagGroupOpenBrowserWindow( 0 )

PT.addtaggroup(ipreploadtg,"IPrep")

PT.TagGroupOpenBrowserWindow( 0 )
