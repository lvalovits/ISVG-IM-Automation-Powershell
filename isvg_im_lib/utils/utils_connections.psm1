function test_isim_connections_secure(){
		[CmdletBinding()]
    param(
        [Parameter()]
        [string] $SCRIPT:ISIM_SESSION_ENDPOINT
	)

	if (-not ($ISIM_SESSION_ENDPOINT)){
		$ISIM_SESSION_ENDPOINT = $PROPERTY_FILE.ENDPOINTS.SESSION
	}

	try{
		if ($PROPERTY_FILE.ISIM.SSL){
			
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

			Write-Warning "`t`tSSL Connection: BYPASSED"
		}

	}catch [System.Management.Automation.MethodInvocationException]{
		Throw "``ttCould not establish trust relationship for the SSL/TLS secure channel"
		Write-Host -fore red "$($Error[0])"
	}
}

function test_isim_connections{
	if ($(Test-Connection -Quiet -Count 1 -ComputerName $($PROPERTY_FILE.ISIM.ISIM_VA), $($PROPERTY_FILE.ISIM.ISIM_APP))){
		Write-Warning "`t`tSSL Enabled = $($PROPERTY_FILE.ISIM.SSL)"
		if ($PROPERTY_FILE.ISIM.SSL){
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			
			if ($PROPERTY_FILE.ISIM.SKIP_SSL_VALIDATION){
				[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
				Write-Warning "`t`tSSL Connection: BYPASSED"
			}
		}
	}
	$PROPERTY_FILE.ISIM.VERSION = (New-WebServiceProxy -Uri ${ISIM_SESSION_ENDPOINT} -ErrorAction STOP).getItimVersionInfo().version
	New-WebServiceProxy::ServerCertificateValidationCallback.
}

# Usage: CheckSSL <fully-qualified-domain-name>
# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-monitor/log-analytics/ssl-connectivity-mma-windows-powershell
function CheckSSL($fqdn, $port=443) 
{
    try {
        $tcpSocket = New-Object Net.Sockets.TcpClient($fqdn, $port)
    } catch {
        Write-Warning "$($_.Exception.Message) / $fqdn"
        break
    }
    $tcpStream = $tcpSocket.GetStream()
    ""; "-- Target: $fqdn / " + $tcpSocket.Client.RemoteEndPoint.Address.IPAddressToString
    $sslStream = New-Object -TypeName Net.Security.SslStream($tcpStream, $false)
    $sslStream.AuthenticateAsClient($fqdn)  # If not valid, will display "remote certificate is invalid".
    $certinfo = New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2(
        $sslStream.RemoteCertificate)

    $sslStream |
        Select-Object |
        Format-List -Property SslProtocol, CipherAlgorithm, HashAlgorithm, KeyExchangeAlgorithm,
            IsAuthenticated, IsEncrypted, IsSigned, CheckCertRevocationStatus
    $certinfo |
        Format-List -Property Subject, Issuer, FriendlyName, NotBefore, NotAfter, Thumbprint
    $certinfo.Extensions |
        Where-Object -FilterScript { $_.Oid.FriendlyName -Like 'subject alt*' } |
        ForEach-Object -Process { $_.Oid.FriendlyName; $_.Format($true) }

    $tcpSocket.Close() 
}



function init_connections(){
	# test_isim_connections
	# test_isim_connections_secure
	# CheckSSL $PROPERTY_FILE.ENDPOINTS.SESSION
	CheckSSL $PROPERTY_FILE.ISIM.ISIM_VA
}