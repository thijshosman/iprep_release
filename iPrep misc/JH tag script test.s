TagGroup SetValueGroup( string Name, string units, number value, number enable, number autotune, number track )
{
	number index

	TagGroup tg = NewTagGroup()
	
	index = tg.TagGroupCreateNewLabeledTag( "Units" ) 
	tg.TagGroupSetIndexedTagAsString( index, units )
		
	index = tg.TagGroupCreateNewLabeledTag( "Value" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, value )
	
	index = tg.TagGroupCreateNewLabeledTag( "Enable" )
	tg.TagGroupSetIndexedTagAsLong( index, enable )
	
	index = tg.TagGroupCreateNewLabeledTag( "Autotune" )
	tg.TagGroupSetIndexedTagAsLong( index, autotune )
	
	index = tg.TagGroupCreateNewLabeledTag( "Track" )
	tg.TagGroupSetIndexedTagAsLong( index, track )
	
	return tg
}


TagGroup CreateROIGroup( string name )
{
	number index
	TagGroup tg = NewTagGroup()

	index = tg.TagGroupCreateNewLabeledTag( "Region Name" ) 
	tg.TagGroupSetIndexedTagAsString( index, name )
	
	index = tg.TagGroupCreateNewLabeledTag( "Stage X (mm)" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 1 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Stage Y (mm)" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Stage Z (mm)" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Magnification" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Brightness" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Contrast" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Focus (mm)" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Stigmator X" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Stigmator Y" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Beam energy" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Spot size" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

return tg
}


TagGroup CreateROIGroup1( string regionName )
{
	number index
	TagGroup tg = NewTagGroup()
	string Name, units
	number value, enable, auto, track
	TagGroup NewTG
	
	index = tg.TagGroupCreateNewLabeledTag( "Region Name" ) 
	tg.TagGroupSetIndexedTagAsString( index, regionName )
	

	
	Name = "Focus"
	units = "mm"
	value = 123.45
	enable = 1
	auto = 0
	track = 0
	NewTG = SetValueGroup(  Name,  units,  value,  enable,  auto,  track )
	index = tg.TagGroupCreateNewLabeledTag( Name ) 
	tg.TagGroupSetIndexedTagAsTagGroup( index, NewTG )

	Name = "Stage X"
	units = "mm"
	value = 23.45
	enable = 1
	auto = 0
	track = 0
	NewTG = SetValueGroup(  Name,  units,  value,  enable,  auto,  track )
	index = tg.TagGroupCreateNewLabeledTag( Name ) 
	tg.TagGroupSetIndexedTagAsTagGroup( index, NewTG )

	Name = "Stage Y"
	units = "mm"
	value = 2.45
	enable = 1
	auto = 0
	track = 0
	NewTG = SetValueGroup(  Name,  units,  value,  enable,  auto,  track )
	index = tg.TagGroupCreateNewLabeledTag( Name ) 
	tg.TagGroupSetIndexedTagAsTagGroup( index, NewTG )

	return tg
}


TagGroup CreateROITagList1( void )
{
	number index
	TagGroup tg = NewTagGroup()

	index = tg.TagGroupCreateNewLabeledTag( "X" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 1 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Y" ) 
	tg.TagGroupSetIndexedTagAsFloat( index, 2 ) 

	index = tg.TagGroupCreateNewLabeledTag( "Region Name" ) 
	tg.TagGroupSetIndexedTagAsString( index, "First" )
	
	return tg
}


TagGroup tl = NewTagList()
TagGroup tg = CreateROIGroup( "#1" )
tl.TagGroupAddTagGroupAtEnd( tg )

tg = CreateROIGroup1( "First" )
tl.TagGroupAddTagGroupAtEnd( tg )

tg = CreateROIGroup1( "Second" )
tl.TagGroupAddTagGroupAtEnd( tg )

tl.TagGroupOpenBrowserWindow( 0 ) 

 

