// $BACKGROUND$

number i, progress, err



	for (i=0;i<10000;i++)
	{
		if ((optiondown() && shiftdown()))
			break		

		sleep(1)

		OINA_AcquisitionIsActive(progress, err)
		result("prog: "+progress+", err: "+err+"\n")

	}	

result("done\n")



	