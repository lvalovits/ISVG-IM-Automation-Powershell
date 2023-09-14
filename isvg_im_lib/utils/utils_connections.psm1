function test_connections_secure(){
		[CmdletBinding()]
    param(
        [Parameter()]
        [string] $SCRIPT:ISIM_SESSION_WSDL
	)

	if (-not ($SCRIPT:ISIM_SESSION_WSDL)){
		$SCRIPT:ISIM_SESSION_WSDL = $GLOBAL:PROPERTY_FILE.WSDL.SESSION
	}

	Write-Output $SCRIPT:ISIM_SESSION_WSDL

	try{

		if ($PROPERTY_FILE.ISIM.SSL){
			
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

			$GLOBAL:PROPERTY_FILE.ISIM.VERSION = (New-WebServiceProxy -Uri ${SCRIPT:ISIM_SESSION_WSDL} -ErrorAction STOP).getItimVersionInfo().version
			# Write-Warning "`t`tSSL Connection: BYPASSED"
		}

	}catch [System.Management.Automation.MethodInvocationException]{
		Throw "``ttCould not establish trust relationship for the SSL/TLS secure channel"
		Write-Host -fore red "$($Error[0])"
	}
}

function test_connections{

	try{
		Write-Host -fore green "`t`tSSL Enabled =" $GLOBAL:ISIM_WS_PROPS['SSL']

		TestConnections_Host $GLOBAL:ISIM_WS_Props['ISIM_VA'] "ISIM VA"
		TestConnections_Host $GLOBAL:ISIM_WS_Props['ISIM_APP'] "ISIM APP"

		Write-Host -fore green "`t`tAll connections tested on ISIM v.$GLOBAL:ISIM_VERSION"

	}catch{
		Write-Host -fore red "$($Error[0])"
	}

}



function init_connections(){
	test_connections
	test_connections_secure
}