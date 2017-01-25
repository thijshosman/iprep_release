	string sitename, dataname
	number type, progress, err
	sitename = "site_ebsd_20"
	dataname = "EDS_DM_14"
	type = 2 // (1 is electron, 2 is eds, 4 is ebsd (which may also have eds enabled))
	OINA_AcquisitionStart(sitename, dataname, type)
	//OINA_AcquisitionStop()
	//OINA_AcquisitionIsActive(progress, err)
	//result("prog: "+progress+", err: "+err+"\n")
	