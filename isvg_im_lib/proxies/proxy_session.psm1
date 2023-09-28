using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"

using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"

#
#	usage:
#		$session_proxy	=	[IM_Session_Proxy]::new(<im_endpoint>) : [IM_Session_Proxy]
#		$session_proxy.login() : [IM_Session]
#		$session_proxy.login(<creds>) : [IM_Session]
#		$session_proxy.logout() : void
#

class IM_Session_Proxy{

	static $version 		=	0.2.1
	hidden static $subject 	=	"im_session_proxy"
	static $proxies			=	@()

	$proxy					=	$null
	$namespace				=	$null
	$proxy_wsdl				=	$null

	[IM_Session] $session	=	$null

	IM_Session_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.SESSION
			$this.proxy				=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_Session_Proxy]::proxies	+=	$this
			[utils_logs]::write_log("TRACE", "$([IM_Session_Proxy]::subject):	++	New session proxy created: $($this.proxy_wsdl)")
		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_Session_Proxy] instance'
		}
	}

	# default constructor cannot be disable.
	hidden IM_Session_Proxy() { throw 'Default constructor disabled. To instance a new proxy use [IM_Session_Proxy]::new( [IM_Endpoint] $endpoint )' }

	[IM_Session] login (){
		return $($this.login($(Get-Credential -Message "Enter your ISVG IM credential")))
	}

	[IM_Session] login ( [PSCredential] $IM_Credential ){

		try{
			[utils_logs]::write_log("INFO", "$([IM_Session_Proxy]::subject):	++	Loggin in as: $($IM_Credential.GetNetworkCredential().username)")

			$wsReturn								=	$this.proxy.login( $IM_Credential.GetNetworkCredential().username, $IM_Credential.GetNetworkCredential().password )
			
			$this.session							=	[IM_Session]::new()

			$this.session.raw						=	$wsReturn
			$this.session.sessionID					=	$wsReturn.sessionID
			$this.session.clientSession				=	$wsReturn.clientSession
			$this.session.enforceChallengeResponse	=	$wsReturn.enforceChallengeResponse
			
			$wsReturn.locale | ForEach-Object{
				$this.session.locale.$($_.name)		=	$_.values
			}

			[utils_logs]::write_log("INFO", "$([IM_Session_Proxy]::subject):	++	Login success")
			
			return $($this.session)
		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			
			return $null
		}
	}

	[void] logout (){
		try{
			$this.proxy.logout( $this.session.raw )
			$this.session	=	$null

			[utils_logs]::write_log("INFO", "$([IM_Session_Proxy]::subject):	++	Logout success")

		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
		}	
	}

}