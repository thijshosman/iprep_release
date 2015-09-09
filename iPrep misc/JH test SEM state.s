number AddTag( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsFloat( index, tagValue ) 
	return index
}

number AddTagAsLong( TagGroup tg, string tagName, number tagValue )
{
	number index = tg.TagGroupCreateNewLabeledTag( tagName ) 
	tg.TagGroupSetIndexedTagAsLong( index, tagValue ) 
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


//// Tag definitions ////
// SEM imaging
string tgn_SEM_imaging = "SEM imaging"
string tn_EHT_volts = "Beam energy"
string tn_spotsize = "Spot size"
string tn_focus_mm = "Focus (mm)"
string tn_focus_delta_mm = "Focus delta (mm)"
string tn_stigmator = "Stigmator"
string tn_mag = "Magnification"
string tn_contrast = "Contrast"
string tn_brightness = "Brightness"

// SEM stage
string tgn_SEM_stage = "SEM stage"
string tn_stageX_mm = "Stage X (mm)"
string tn_stageY_mm = "Stage Y (mm)"
string tn_stageZ_mm = "Stage Z (mm)"

// SEM beam shift

// SEM autotuning
string tgn_Autotuning = "Autotuning"
string tn_AF_enable = "Autofocus enable"
string tn_AS_enable = "Autostigmation enable"

// Digiscan
string tgn_DS = "Digiscan"
string tn_DS_width = "DS_width"
string tn_DS_height = "DS_Height"
string tn_DS_pixelTime = "DS_PixelTime (us)"
string tn_DS_lineSync = "DS_LineSynch"
string tn_DS_rotation = "DS_Rotation"

// Gatan BSED


TagGroup GetSEMImagingState( void )
{
	number EHT_volts
	number spotsize
	number focus_mm, focus_delta_mm
	number stigX, stigY
	number mag
	number bright, contrast, channel=0

// Get state info from Microscope
	EHT_volts = EMGetHighTension()
	spotsize = EMGetSpotSize() / 1000
	focus_mm = EMGetFocus() / 1000
	focus_delta_mm = 0
	EMGetObjectiveStigmation( stigX, stigY )
	mag = EMGetMagnification()
	contrast = FEIQuanta_GetVideoContrastAtChannel( channel )
	bright = FEIQuanta_GetVideoBrightnessAtChannel( channel )

// Make and return taggroup
	TagGroup tg = NewTagGroup()

	tg.AddTag( tn_EHT_volts, EHT_volts ) 
	tg.AddTag( tn_spotsize, spotsize ) 
	tg.AddTag( tn_focus_mm, focus_mm ) 
	tg.AddTag( tn_focus_delta_mm, focus_delta_mm ) 
	tg.AddTag( tn_stigmator, stigX, stigY) 
	tg.AddTag( tn_mag, mag ) 
	tg.AddTag( tn_contrast, contrast ) 
	tg.AddTag( tn_brightness, bright ) 

	string suffix = " state"
	tg.AddTag( tn_EHT_volts+suffix, "set" ) // "set", "ignore", "auto", "track"
	tg.AddTag( tn_spotsize+suffix, "set" ) 
	tg.AddTag( tn_focus_mm+suffix, "set" ) 
	tg.AddTag( tn_focus_delta_mm+suffix, "ignore" ) 
	tg.AddTag( tn_stigmator+suffix, "set" ) 
	tg.AddTag( tn_mag+suffix, "set" ) 
	tg.AddTag( tn_contrast+suffix, "set" ) 
	tg.AddTag( tn_brightness+suffix, "set" ) 

	return tg
}

TagGroup GetSEMStageState( void )
{
	number X, Y, Z
	
// Get state info from Microscope
	EMGetStageXY( X, Y )	// in microns
	x /= 1000				// in mm
	y /= 1000
	z = EMGetStageZ( ) / 1000
	
// Make and return taggroup
	TagGroup tg = NewTagGroup()

	tg.AddTag( tn_stageX_mm, X ) 
	tg.AddTag( tn_stageY_mm, Y ) 
	tg.AddTag( tn_stageZ_mm, Z ) 

	return tg
}

TagGroup GetAutotuneState( void )
{
	number AF_enable = 0, AS_enable = 0, tv
	string tagname = "IPrep:SEM:AF:Enable"
// Get state info
	GetPersistentNumberNote( tagname, tv )
	AF_enable = tv > 0
	AS_enable = tv > 1
	
	
// Make and return taggroup
	TagGroup tg = NewTagGroup()

	tg.AddTagAsLong( tn_AF_enable, AF_enable ) 
	tg.AddTagAsLong( tn_AS_enable, AS_enable ) 

	return tg
}

TagGroup GetDigiscanCaptureState( void )
{
	Number paramID = 2	// capture ID
	number width, height,pixeltime,linesync,rotation
	
// Get state info from DigiScan Capture defaults
	width = DSGetWidth( paramID )
	height = DSGetHeight( paramID)
	pixelTime = DSGetPixelTime( paramID )
	lineSync = DSGetLineSynch( paramID )
	rotation = DSGetRotation( paramID )
		// #TODO: add support for more than signal 0
	
// Make and return taggroup
	TagGroup tg = NewTagGroup()

	tg.AddTagAsLong( tn_DS_width, width ) 
	tg.AddTagAsLong( tn_DS_height, height ) 
	tg.AddTag( tn_DS_pixelTime, pixelTime ) 
	tg.AddTagAsLong( tn_DS_lineSync, lineSync ) 
	tg.AddTag( tn_DS_rotation, rotation ) 

	return tg
}

/*
FEIQuanta_SetHighTensionOnOff(1)
val = FEIQuanta_GetVideoContrastAtChannel( channel )
FEIQuanta_SetVideoContrastAtChannel( channel, val )
val = FEIQuanta_GetVideoBrightnessAtChannel( channel )
FEIQuanta_SetVideoBrightnessAtChannel( channel, val )
*/
TagGroup tl = NewTagList()
TagGroup tgRegion

TagGroup tgImaging = GetSEMImagingState()
TagGroup tgStage = GetSEMStageState()
TagGroup tgDS = GetDigiscanCaptureState()
TagGroup tgAT = GetAutotuneState()

tgRegion = tl.TagGroupCreateGroupTagAtEnd()
tgRegion.TagGroupAddLabeledTagGroup( tgn_SEM_imaging, tgImaging )
tgRegion.TagGroupAddLabeledTagGroup( tgn_SEM_stage, tgStage )
tgRegion.TagGroupAddLabeledTagGroup( tgn_DS, tgDS )
tgRegion.TagGroupAddLabeledTagGroup( tgn_Autotuning, tgAT )


// TagGroupReplaceTagsWithCopy( TagGroup tagGroup, TagGroup srcGroup ) 
//Boolean TagGroupIsValid( TagGroup tagGroup ) 
//TagGroup TagGroupGetOrCreateTagList( TagGroup tagGroup, String tagPath ) 
//void TagGroupDeleteTagWithLabel( TagGroup tagGroup, String tagPath ) 
//Boolean TagGroupDoesTagExist( TagGroup tagGroup, String tagPath ) 
//void TagGroupDeleteAllTags( TagGroup tagGroup ) 
//TagGroup TagGroupClone( TagGroup tagGroup ) 






tl.TagGroupOpenBrowserWindow( 0 ) 
