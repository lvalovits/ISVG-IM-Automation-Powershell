Write-Output "Importing properties module..."
Import-Module $PSScriptRoot\utils_properties.psm1 -force
Import-Module $PSScriptRoot\utils_logs.psm1 -force
Import-Module $PSScriptRoot\utils_connections.psm1 -force


function _init_{
	[CmdletBinding()]
        param (
		$sd,
		$s,	
		[switch]$SkipConnectionTest
		)
	try{		
		
		Write-Host
		Write-Host -fore green "--- Starting initialization ---"
		Write-Host

		if (-not $SkipTest_Properties.IsPresent){
			Write-Host -fore green "`tReading properties"
			init_properties
		}


		if (-not $SkipTest_Logging.IsPresent){
			init_logging
			write_log "info" "--- Starting initialization ---"
			Write-Host -fore green "`tLog file: $($PROPERTY_FILE.LIB.LOG_FILE)"
		}
		
		if (-not $SkipTest_Connections.IsPresent){
			Write-Host -fore green "`tTesting connections"
			init_connections
		}

		Write-Host
		Write-Host -fore green "--- Initialization completed ---"
		Write-Host
		
		write_log "info" "--- Initialization completed ---"
	}catch{
		Write-Host -fore red "$($Error[0])"
	}
}