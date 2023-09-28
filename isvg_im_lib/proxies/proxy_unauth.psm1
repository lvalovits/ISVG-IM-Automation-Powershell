using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"

using module "..\entities\endpoint.psm1"

#
#	usage:
#		$session_proxy	=	[IM_Unauth_Proxy]::new(<im_endpoint>) : [IM_Unauth_Proxy]
#		$session_proxy.login() : [IM_Session]
#		$session_proxy.login(<creds>) : [IM_Session]
#		$session_proxy.logout() : void
#

class IM_Unauth_Proxy{

	static $version 		=	0.2.0
	hidden static $subject 	=	"im_unauth_proxy"
	static $proxies			=	@()

	$proxy					=	$null
	$namespace				=	$null
	$proxy_wsdl				=	$null

	IM_Unauth_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.SESSION
			$this.proxy				=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_Unauth_Proxy]::proxies	+=	$this
			[utils_logs]::write_log("TRACE", "$([IM_Unauth_Proxy]::subject):	++	New unauth proxy created: $($this.proxy_wsdl)")
		}catch{
			Write-Warning "$([IM_Unauth_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Unauth_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Unauth_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Unauth_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_Unauth_Proxy] instance'
		}
	}

	# default constructor cannot be disable.
	hidden IM_Unauth_Proxy() { throw 'Default constructor disabled. To instance a new proxy use [IM_Unauth_Proxy]::new( [IM_Endpoint] $endpoint )' }

	[string] getItimVersionInfo (){

		try{
			[utils_logs]::write_log("INFO", "$([IM_Unauth_Proxy]::subject):	++	Getting IM version")

			$wsReturn								=	$this.proxy.getItimVersionInfo()

			[utils_logs]::write_log("INFO", "$([IM_Unauth_Proxy]::subject):	++	IM version: $($wsReturn.version)")
			
			return $($wsReturn.version)
		}catch{
			Write-Warning "$([IM_Unauth_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Unauth_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Unauth_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Unauth_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			
			return $null
		}
	}

}