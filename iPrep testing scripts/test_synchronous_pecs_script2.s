// $BACKGROUND$
number j
for (j=0;j<100;j++)
{
	string value2
	PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", value2)
	debug("should be 1500: "+value2+"\n")
	sleep(0.1)
}
debug("end\n")