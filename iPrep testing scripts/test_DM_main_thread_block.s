// $BACKGROUND$


void movestageuptest()
{
		

		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVent", "set_active", "1")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveWhisperlok", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveLoadLock", "set_active", "0")
		sleep(.25)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "1")
		sleep(7)
		PIPS_SetPropertyDevice("subsystem_pumping", "device_valveVacuum", "set_active", "0")
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_enable", "1")  
		PIPS_SetPropertyDevice("subsystem_imaging", "device_illuminatorTop", "set_active", "1")  


}

//movestageuptest()

returnWorkflow().returnPecs().moveStageUp() // blocks ui thread




