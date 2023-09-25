using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"
using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"
#
#	DO NOT:
#		[IM_Session_Proxy]::new()
#	usage:
#		$session_proxy	=	[IM_Session_Proxy]::getProxy()
#		$session_proxy.init() : void
#		$session_proxy.login(<creds>) : void
#		$session_proxy.logout(<raw_session>) : void
#

class IM_Session_Proxy{
	################# Singleton start #################
    # hidden static [IM_Session_Proxy] $_instance	=	[IM_Session_Proxy]::new()
    # hidden IM_Session_Proxy() {}
    # static [IM_Session_Proxy] getProxy() { return [IM_Session_Proxy]::_instance }
	################# Singleton end #################

	static $version 						=	0.2.0
	hidden static $subject 					=	"im_session_proxy"
	static $proxies							=	@()

	$proxy			=	$null
	$namespace		=	$null
	$proxy_wsdl		=	$null

	IM_Session_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.SESSION
			$this.proxy				=	New-WebServiceProxy -Uri $endpoint.endpoints_list.SESSION -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_Session_Proxy]::proxies	+=	$this
		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_Session_Proxy] instance'
		}
	}

	# default constructor cannot be disable.
	hidden IM_Session_Proxy() { throw 'Default constructor disabled. To instance a new proxy use IM_Session_Proxy::new( [IM_Endpoint] $endpoint, [IM_Session] $session )' }

	[void] login (){
		# $im_cred	=	Get-Credential -Credential $null -Message "Enter your ISVG IM credential"
		$this.login($(Get-Credential -Credential $null -Message "Enter your ISVG IM credential"))
	}

	[void] login ( [PSCredential] $IM_Credential ){

		try{
			$wsReturn								=	$this.proxy.login( $IM_Credential.GetNetworkCredential().username, $IM_Credential.GetNetworkCredential().password )
			Clear-Variable -Name IM_Credential

			$Session								=	[IM_Session]::new()

			$Session.raw							=	$wsReturn
			$Session.sessionID						=	$wsReturn.sessionID
			$Session.clientSession					=	$wsReturn.clientSession
			$Session.enforceChallengeResponse		=	$wsReturn.enforceChallengeResponse
			$wsReturn.locale | ForEach-Object{
				$Session.locale.$($_.name)			=	$_.values
			}
		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
		}
	}

	[void] logout ( $raw_session ){
		try{
			$this.proxy.logout( $raw_session )
		
			$Session							=	[IM_Session]::GetSession()
			$Session.raw						=	$null
			$Session.sessionID					=	$null
			$Session.clientSession				=	$null
			$Session.locale.country				=	$null
			$Session.locale.variant				=	$null
			$Session.locale.language			=	$null
			$Session.enforceChallengeResponse	=	$null

			Write-Host
			Write-Host "Successfully logout" -ForegroundColor green
			Write-Host

		}catch{
			Write-Warning "$([IM_Session_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Session_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Session_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
		}	
	}

}