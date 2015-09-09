string SEM_type = "Quanta"

void passive_check_fwd_coupling( void )
{
	number Quanta_z_limit = 10799
	number tol = 5
	number pos = EMGetStageZ( )
	if ( SEM_type == "Quanta" && pos > Quanta_z_limit-tol && pos < Quanta_z_limit+tol )
		throw("Error: FWD is not coupled. (Z reading="+pos+")" )
		
}


void active_check_fwd_coupling( void )
{
	number Quanta_z_limit = 10799
	number tol = 15
	number orig_pos = EMGetStageZ( )
	EMSetStageZ( 50000 )
	EMWaitUntilReady( )
	number pos = EMGetStageZ( )
	if ( SEM_type == "Quanta" && pos > Quanta_z_limit-tol && pos < Quanta_z_limit+tol )
		throw("Error: FWD is not coupled. (Z reading="+pos+")" )
		
}

active_check_fwd_coupling()