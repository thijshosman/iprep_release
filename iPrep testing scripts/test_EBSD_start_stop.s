// $BACKGROUND$

EBSD_StartAcquisition()

while(1)
{
	sleep(2)
	number busy = EBSD_IsAcquisitionBusy()
	result("EBSD state = " + busy +"\n")
}