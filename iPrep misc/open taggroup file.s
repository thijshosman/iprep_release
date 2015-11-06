void loadTagsFromFileAndBrowse(void)
{
	

	taggroup ipreploadtg = newtaggroup()

	ipreploadtg.TagGroupLoadFromFile("c:\\temp\\iprep_tags")

	ipreploadtg.TagGroupOpenBrowserWindow( 0 )


}

loadTagsFromFileAndBrowse()
