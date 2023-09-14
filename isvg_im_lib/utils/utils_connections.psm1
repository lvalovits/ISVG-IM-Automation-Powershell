function test_isim_connections_secure(){

	Write-Warning "`t`tSSL Enabled	=	$($PROPERTY_FILE.ISIM.SSL)"
	
	if ($PROPERTY_FILE.ISIM.SSL){
		if ($PROPERTY_FILE.ISIM.SSL_SKIP_VALIDATION){
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback	=	{$true}
			Write-Warning "`t`tSSL Connection: BYPASSED"
		}else{
			[Net.ServicePointManager]::SecurityProtocol	=	[Net.SecurityProtocolType]::Tls12
			CheckSSL -FQDN $PROPERTY_FILE.ISIM.HOST_VA -Port $PROPERTY_FILE.ISIM.PORT_VA
			CheckSSL -FQDN $PROPERTY_FILE.ISIM.HOST_APP -Port $PROPERTY_FILE.ISIM.PORT_APP
		}
	}
}

function test_isim_connections{
	if (-not (Test-Connection -Quiet -Count 1 $($PROPERTY_FILE.ISIM.HOST_VA))){
		Write-Error "`t`tConnection error to $($PROPERTY_FILE.ISIM.HOST_VA)"
	}
	if (-not (Test-Connection -Quiet -Count 1 $($PROPERTY_FILE.ISIM.HOST_APP))){
		Write-Error "`t`tConnection error to $($PROPERTY_FILE.ISIM.HOST_APP)"
	}
	
}

# Usage: CheckSSL -FQDN <fully-qualified-domain-name> -Port <port number>
# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-monitor/log-analytics/ssl-connectivity-mma-windows-powershell
function CheckSSL() {
		[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position=0)]
		[String] $FQDN,
		[Parameter(Mandatory, Position=1)]
		[int] $Port
	)
	$SCRIPT:tcpSocket
	$SCRIPT:tcpStream
	$SCRIPT:sslStream
	$SCRIPT:certinfo
	$SCRIPT:result = $True

    try {
        $tcpSocket	=	New-Object Net.Sockets.TcpClient($FQDN, $Port)
    } catch {
		$SCRIPT:result	=	$False
		Write-Warning "Error: $($_.Exception.InnerException.Message)"
    }

	if ($result){
		$tcpStream	=	$tcpSocket.GetStream()
		""; "-- Target: $FQDN / " + $tcpSocket.Client.RemoteEndPoint.Address.IPAddressToString
		$sslStream	=	New-Object -TypeName Net.Security.SslStream($tcpStream, $false)
		
		try{
			$sslStream.AuthenticateAsClient($FQDN)   | Out-Null # If not valid, will display "remote certificate is invalid".
			$certinfo	=	New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

			$sslStream | Select-Object | Format-List -Property SslProtocol, CipherAlgorithm, HashAlgorithm, KeyExchangeAlgorithm, IsAuthenticated, IsEncrypted, IsSigned, CheckCertRevocationStatus
			$certinfo | Format-List -Property Subject, Issuer, FriendlyName, NotBefore, NotAfter, Thumbprint
			$certinfo.Extensions | Where-Object -FilterScript { $_.Oid.FriendlyName -Like 'subject alt*' } | ForEach-Object -Process { $_.Oid.FriendlyName; $_.Format($true) }
			$tcpSocket.Close()
		} catch {
			$SCRIPT:result	=	$False
			$tcpSocket.Close()
			Write-Warning "Error: $($_.Exception.InnerException.Message)"
		}
	}
}



function init_connections(){
	test_isim_connections
	test_isim_connections_secure
}