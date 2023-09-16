# Import-Module $PSScriptRoot\utils_properties.psm1 -force
# Import-Module $PSScriptRoot\utils_logs.psm1 -force
# Import-Module $PSScriptRoot\utils_connections.psm1 -force
# Import-Module $PSScriptRoot\utils_proxy_wrapper.psm1 -force
#Import-Module $PSScriptRoot\exceptions.psm1 -force

function _init_{
	[CmdletBinding()]
        param (
		[switch] $SkipTest_Properties,
		[switch] $SkipTest_Logging,	
		[switch] $SkipTest_Connections
		)
	try{
		if (-not $SkipTest_Properties.IsPresent){
			init_properties
		}
		if (-not $SkipTest_Logging.IsPresent){
			init_logging
			write_log "info" "--- Starting initialization ---"
			Write-Host -fore green "`tLog file: $($PROPERTY_FILE.LIB.LOG_FILE)"
		}
		if (-not $SkipTest_Connections.IsPresent){
			write_log "info" "Testing connections"
			init_connections
		}		
		write_log "info" "--- Initialization completed ---"
	}catch{
		# Write-Error "Initialization failed"
	}
}