#
#	usage:
#		$session_proxy = [ISIM_Session_Proxy]::getProxy()
#		$session_proxy.init() : void
#		$session_proxy.login(<creds>) : void
#		$session_proxy.logout(<raw_session>) : void
#

class ISIM_Session_Proxy{
	################# Singleton start #################
    hidden static [ISIM_Session_Proxy] $_instance	=	[ISIM_Session_Proxy]::new()

    hidden ISIM_Session_Proxy() {}

    hidden static [ISIM_Session_Proxy] getProxy() {
        return [ISIM_Session_Proxy]::_instance
    }
	################# Singleton end #################

	[string]$proxy_wsdl		=	$GLOBAL:ISIM_WSDL_SESSION
	$proxy_session			=	$null
	$namespace_session		=	$null

	[void]init(){
		
		$subject	=	"proxy init"

		try{
			[ISIM_Session]::GetSession().clean()
			$this.proxy_session = New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop # -Namespace "WebServiceProxy" -Class "Session"
			$this.namespace_session = $this.proxy_session.GetType().Namespace
		}
		catch {
			$exceptionMessage	=	"Could not create proxy."
			Write-Host -fore red "$($subject): $exceptionMessage"
			debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
			debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
			debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
			debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
		}
	}

	[void] login ( [PSCredential]$Credential ){

		$subject	=	"login"

		if ($null -ne $this.proxy_session){
			try{
			
				$isim_principal		=	$Credential.GetNetworkCredential().username
				$isim_seceret		=	$Credential.GetNetworkCredential().password
				
				$wsReturn = $this.proxy_session.login( $isim_principal, $isim_seceret )
		
				$Session								=	[ISIM_Session]::GetSession()
					$Session.raw						=	$wsReturn
					$Session.sessionID					=	$wsReturn.sessionID
					$Session.clientSession				=	$wsReturn.clientSession
					$Session.enforceChallengeResponse	=	$wsReturn.enforceChallengeResponse
					$wsReturn.locale | ForEach-Object{
						$Session.locale.$($_.name)	=	$_.values
					}
				
			}catch{
			
				$Session							=	[ISIM_Session]::GetSession()
				$Session.raw						=	$null
				$Session.sessionID					=	$null
				$Session.clientSession				=	$null
				$Session.locale.country				=	$null
				$Session.locale.variant				=	$null
				$Session.locale.language			=	$null
				$Session.enforceChallengeResponse	=	$null

				$exceptionMessage	=	"Authentication error."
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			$exceptionMessage	=	"Proxy not found."
			try{
				# Write-Error "" -ErrorAction Stop
				Throw $exceptionMessage
			}catch{
				# Write-Host -fore red "$($subject): $exceptionMessage"
				# debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				# debugLog "error" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
				
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}	
	}

	[void] logout ( $raw_session ){

		$subject	=	"logout"

		if ($null -ne $this.proxy_session){
			try{
				$this.proxy_session.logout( $raw_session )
			
				$Session							=	[ISIM_Session]::GetSession()
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
				$exceptionMessage = "Error loging out."
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			$exceptionMessage = "Proxy not found."
			try{
				Throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}		
	}

}