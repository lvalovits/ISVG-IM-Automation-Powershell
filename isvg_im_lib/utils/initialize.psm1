Write-Output "Importing properties module..."
Import-Module $PSScriptRoot\utils_properties.psm1 -force
Import-Module $PSScriptRoot\utils_logs.psm1 -force
Import-Module $PSScriptRoot\utils_connections.psm1 -force

exit

function libs_init{
	[CmdletBinding()]
        param (
			[switch]$SkipConnectionTest
		)
	try{		
		
		Write-Host
		Write-Host -fore green "--- Starting initialization ---"
		Write-Host

		Write-Host -fore green "`tReading properties"
		init_properties

		Write-Host -fore green "`tRuning on debug: $($Global:PROPERTY_FILE.LIB.DEBUG)"

		init_logging
		debugLog "info" "--- Starting initialization ---"
		
		Write-Host -fore green "`tDebug log: $($GLOBAL:LOGFILE_DEBUG)"
				
		Write-Host -fore green "`tBuilding WSDL URLs"
		build_WSDL
		
		if (! $SkipTest.IsPresent){
			Write-Host -fore green "`tTesting connections"
			Test_Connections
		}

		Write-Host
		Write-Host -fore green "--- Initialization completed ---"
		Write-Host
		
		debugLog "info" "--- Initialization completed ---"
	}catch{
		Write-Host -fore red "$($Error[0])"
	}
}


function testConnections_Host(){
	param (
        $propValue,
		$propName
    )
	try{
		if ($null -ne $propValue){
			ping -n 1 $propValue > $null
			if ($LASTEXITCODE -eq 0){
				Write-Host -fore green "`t`t${propName}: OK"
			}else{
				Throw "`t`t$($propName): Could not find host $($propValue)"
			}
		}else{
			Write-Host -fore red "`t`t${propName}: Property missing"
			Throw "Property missing"
		}
	}catch{
		Write-Host -fore red "$($Error[0])"
	}

}