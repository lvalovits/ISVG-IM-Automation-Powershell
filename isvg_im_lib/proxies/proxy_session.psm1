using module "..\utils\utils_properties.psm1"
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

	static $proxies = @()

	$proxy			=	$null
	$namespace		=	$null
	$proxy_wsdl		=	$null

	hidden IM_Session_Proxy() {}

	IM_Session_Proxy([IM_Endpoint]$endpoint){
		$this.proxy_wsdl		=	$endpoint.endpoints_list.SESSION
		$this.proxy	=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
		$this.namespace	=	$this.proxy.GetType().Namespace

		[IM_Session_Proxy]::proxies += $this
	}

	# [void]init(){
		
	# 	$subject	=	"proxy init"

	# 	try{
	# 		[IM_Session]::GetSession().clean()
	# 		$this.proxy	=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop # -Namespace "WebServiceProxy" -Class "Session"
	# 		$this.namespace	=	$this.proxy.GetType().Namespace
	# 	}
	# 	catch {
	# 		$exceptionMessage	=	"Could not create proxy."
	# 		Write-Host -fore red "$($subject): $exceptionMessage"
	# 		write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
	# 		write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
	# 		write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
	# 		write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
	# 	}
	# }

	[void] login ( [PSCredential]$Credential ){

		$subject	=	"login"

		if ($null -ne $this.proxy){
			try{
			
				$isim_principal		=	$Credential.GetNetworkCredential().username
				$isim_seceret		=	$Credential.GetNetworkCredential().password
				
				$wsReturn	=	$this.proxy.login( $isim_principal, $isim_seceret )
		
				$Session								=	[IM_Session]::GetSession()
					$Session.raw						=	$wsReturn
					$Session.sessionID					=	$wsReturn.sessionID
					$Session.clientSession				=	$wsReturn.clientSession
					$Session.enforceChallengeResponse	=	$wsReturn.enforceChallengeResponse
					$wsReturn.locale | ForEach-Object{
						$Session.locale.$($_.name)	=	$_.values
					}
				
			}catch{
			
				$Session							=	[IM_Session]::GetSession()
				$Session.raw						=	$null
				$Session.sessionID					=	$null
				$Session.clientSession				=	$null
				$Session.locale.country				=	$null
				$Session.locale.variant				=	$null
				$Session.locale.language			=	$null
				$Session.enforceChallengeResponse	=	$null

				$exceptionMessage	=	"Authentication error."
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			$exceptionMessage	=	"Proxy not found."
			try{
				Throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}	
	}

	[void] logout ( $raw_session ){

		$subject	=	"logout"

		if ($null -ne $this.proxy){
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
				$exceptionMessage	=	"Error loging out."
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			$exceptionMessage	=	"Proxy not found."
			try{
				Throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}		
	}

}