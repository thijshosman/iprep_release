number j
for (j=0;j<10;j++)
{
	string value2
	PIPS_GetPropertyDevice("subsystem_pumping", "device_turboPump", "read_speed_Hz", value2)
	debug("interrupt number: "+value2+"\n")
}
debug("end\n")