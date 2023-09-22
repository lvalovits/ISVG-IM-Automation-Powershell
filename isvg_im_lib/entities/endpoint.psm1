using module "..\utils\utils_properties.psm1"

Class IM_Endpoint{

	static $version = 0.2.2
	hidden static $subject = "endpoints"
	static $endpoints = @()

	[bool] $secure
	[string] $ip_or_hostname
	[string] $port
	[string] $protocol
	[string] $endpoints_url

	[psobject] $endpoints_list = @{
		ACCOUNT					=	""
		EXTENSION				=	""
		GROUP					=	""
		ORGANIZATIONALCONTAINER	=	""
		PASSWORD				=	""
		PERSON					=	""
		PROVISIONING			=	""
		REQUEST					=	""
		ROLE					=	""
		SEARCHDATA				=	""
		SERVICE					=	""
		SESSION					=	""
		SHAREDACCESS			=	""
		SYSTEMUSER				=	""
		TODO					=	""
		UNAUTH					=	""
	}

	static [string] get_protocol([IM_Endpoint]$endpoint){
		$ret = ""
		if ($endpoint.secure){
			$ret = "https"
		}else{
			$ret = "http"
		}
		return $ret
	}

	static [string] get_endpoints_url([IM_Endpoint]$endpoint){
		return $($endpoint.protocol + "://" + $endpoint.ip_or_hostname + ":" + $endpoint.port)
	}

	static [psobject] get_endpoints_list([IM_Endpoint]$endpoint){
		$ret = @{}
		[utils_properties]::PROPERTIES.WSDL_FILES.keys | ForEach-Object {
			if ($null -ne [utils_properties]::PROPERTIES.WSDL_FILES[$_]){
				$ret[""+$_]	=	"$($endpoint.endpoints_url)$([utils_properties]::PROPERTIES.WSDL_FILES[$_])"
			}else{
				Write-Warning "Endpoint not found: $($_)" 
			}
		}
		return $ret
	}

	IM_Endpoint(){

		$this.secure			=	[utils_properties]::PROPERTIES.ISIM.SSL
		$this.ip_or_hostname	=	[utils_properties]::PROPERTIES.ISIM.APP_HOST
		$this.port				=	[utils_properties]::PROPERTIES.ISIM.APP_PORT

		$this.protocol			=	[IM_Endpoint]::get_protocol($this)
		$this.endpoints_url		=	[IM_Endpoint]::get_endpoints_url($this)
		$this.endpoints_list	=	[IM_Endpoint]::get_endpoints_list($this)

		[IM_Endpoint]::endpoints += $this
	}

	IM_Endpoint([string]$IP_OR_HOSTNAME, [int]$PORT, [bool] $SSL){

		$this.secure			=	$SSL
		$this.ip_or_hostname	=	$IP_OR_HOSTNAME
		$this.port				=	$PORT

		$this.protocol			=	[IM_Endpoint]::get_protocol($this)
		$this.endpoints_url		=	[IM_Endpoint]::get_endpoints_url($this)
		$this.endpoints_list	=	[IM_Endpoint]::get_endpoints_list($this)

		[IM_Endpoint]::endpoints += $this
	}

	static [void] test_endpoints_ICMP($endpoint){
		$dest_ip = $endpoint.ip_or_hostname
		if (-not ([utils_properties]::PROPERTIES::LIB.DEPRECATED_TESTCONNECTION)){
			if (-not (Test-Connection -Quiet -Count 1 $($dest_ip))){
				Write-Warning "Connection error to $($dest_ip)"
			}
		}else{
			[IM_Endpoint]::test_endpoints_ICMP___deprecated($endpoint)
		}
	}

	static [void] test_endpoints_ICMP___deprecated([IM_Endpoint] $endpoint){
		try{
			$dest_ip = $endpoint.ip_or_hostname
			Write-Warning "Using deprecated test connection method to connect $dest_ip"
			
			$ping_return = ping -n 1 $dest_ip

			if (($ping_return | Where-Object {$_ -match "Request timed out"}) -gt 0){
				Write-Warning "$($dest_ip): Request timed out"
			}elseif (($ping_return | Where-Object {$_ -match "Destination host unreachable"}) -gt 0){
				Write-Warning "$($dest_ip): Destination host unreachable"
			}
		}catch{
			Write-Host -fore red "$($Error[0])"
		}
	}

	static [void] test_endpoints_HTTPS([IM_Endpoint] $endpoint){	
		$dest_ip	=	$endpoint.ip_or_hostname
		$dest_port	=	$endpoint.port
		$des_secure		=	$endpoint.secure

		if ($des_secure){
			if ([utils_properties]::PROPERTIES::LIB.SSL_SKIP_VALIDATION){
				[System.Net.ServicePointManager]::ServerCertificateValidationCallback	=	{$true}
				Write-Warning "SSL Connection to $($dest_ip):$($dest_port) BYPASSED"
			}else{
				[Net.ServicePointManager]::SecurityProtocol	=	[Net.SecurityProtocolType]::Tls12
				[IM_Endpoint]::CheckSSL($endpoint)
			}
		}else{
			Write-Warning "Endpoint not secure. SSL validation skiped"
		}
	}

	# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-monitor/log-analytics/ssl-connectivity-mma-windows-powershell
	static [void] CheckSSL([IM_Endpoint]$endpoint) {
		$dest_fqdn		=	$endpoint.ip_or_hostname
		$dest_port		=	$endpoint.port
		$tcpSocket	=	$null
		$tcpStream	=	$null
		$sslStream	=	$null
		$certinfo	=	$null
		$result		=	$True

		try {
			$tcpSocket	=	New-Object Net.Sockets.TcpClient($dest_fqdn, $dest_port)
		} catch {
			$result	=	$False
			Write-Warning "Error: $($_.Exception.InnerException.Message)"
		}

		if ($result){
			$tcpStream	=	$tcpSocket.GetStream()
			# ""; "-- Target: $dest_fqdn / " + $tcpSocket.Client.RemoteEndPoint.Address.IPAddressToString
			$sslStream	=	New-Object -TypeName Net.Security.SslStream($tcpStream, $false)
			
			try{
				$sslStream.AuthenticateAsClient($dest_fqdn) | Out-Null # If not valid, will display "remote certificate is invalid".
				$certinfo	=	New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

				$sslStream | Select-Object | Format-List -Property SslProtocol, CipherAlgorithm, HashAlgorithm, KeyExchangeAlgorithm, IsAuthenticated, IsEncrypted, IsSigned, CheckCertRevocationStatus
				$certinfo | Format-List -Property Subject, Issuer, FriendlyName, NotBefore, NotAfter, Thumbprint
				$certinfo.Extensions | Where-Object -FilterScript { $_.Oid.FriendlyName -Like 'subject alt*' } | ForEach-Object -Process { $_.Oid.FriendlyName; $_.Format($true) }
				$tcpSocket.Close()
			} catch {
				$result	=	$False
				$tcpSocket.Close()
				Write-Warning "$($dest_fqdn): $($_.Exception.InnerException.Message)"
			}
		}
	}
	
	static [bool] test_connections([IM_Endpoint]$endpoint){
		try{
			[IM_Endpoint]::test_endpoints_ICMP($endpoint)
			[IM_Endpoint]::test_endpoints_HTTPS($endpoint)
			return $True
		}catch{
			Write-Warning "Ex.Message:	$($PSItem.exception.Message)"
			Write-Warning "$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)"
			return $False
		}
	}

}