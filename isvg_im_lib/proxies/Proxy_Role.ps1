#
#	usage:
#		$role_proxy	=	[ISIM_Role_Proxy]::getProxy()
#		$role_proxy.init() : void
#		$role_proxy.searchRoles( <raw_session> , <filter> ) : ISIM_Role[]
#		$role_proxy.createStaticRole ( <raw_session> , <raw_container> , <raw_role> ) : ISIM_Role
#		$role_proxy.getRawRole ( <ISIM_Role> ) : raw_role
#		$role_proxy.getStub() : raw_role
#

class ISIM_Role_Proxy{
	################# Singleton start #################
    hidden static [ISIM_Role_Proxy] $_instance	=	[ISIM_Role_Proxy]::new()
    static [ISIM_Role_Proxy] $Instance			=	[ISIM_Role_Proxy]::getProxy()

    hidden ISIM_Role_Proxy() {
    }

    hidden static [ISIM_Role_Proxy] getProxy() {
        return [ISIM_Role_Proxy]::_instance
    }
	################# Singleton end #################

	[string]$proxy_wsdl		=	$GLOBAL:ISIM_WSDL_ROLE
	$proxy				=	$null
	$namespace			=	$null

	[void]init(){
		
		$subject			=	"proxy init"

		try{
			if ( $null -eq [ISIM_Session]::GetSession().clientSession ){
				$exceptionMessage	=	"Session not found."
				Throw $exceptionMessage
			}

			$this.proxy	=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop # -Namespace "WebServiceProxy" -Class "Session"
			$this.namespace	=	$this.proxy.GetType().Namespace
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

	[psObject] getStub(){
		
		$subject			=	"getStub"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		try{
			
			if ( $null -eq [ISIM_Session]::GetSession().clientSession ){
				$exceptionMessage	=	"Session not found."
				Throw $exceptionMessage
			}

			$returnObject	=	New-Object $($this.namespace+".WSRole")

		}catch{
			if ( $null -eq $exceptionMessage) { $exceptionMessage	=	"Unhandled error" }
			Write-Host -fore red "$($subject): $exceptionMessage"
			debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
			debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
			debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
			debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
		}
		return $returnObject
	}

	[array] searchRoles ( $raw_session, [string]$filter ){

		$subject			=	"searchRoles"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		if ($null -ne $this.proxy){
			try{
			
				$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
				
				$wsReturn	=	$this.proxy.searchRoles($wsSession, $filter)
		
				if($wsReturn.count -gt 0) {
					$wsReturn | ForEach-Object{
						$returnObject		=	[ISIM_Role]::new($_)
						$returnArray		+=	$returnObject
					}
				}
			}catch{
				$exceptionMessage	=	"Error retrieving roles."
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			try{
				$exceptionMessage	=	"Proxy not found."
				throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}
		return $returnArray
	}

	[ISIM_Role] createStaticRole ( $raw_session, $raw_container, $raw_role ){
		
		$subject			=	"createStaticRole"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		if ($null -ne $this.proxy){
			try{
				$wsSession		=	Copy-ISIMObjectNamespace $raw_session $this.namespace
				$wsContainer	=	Copy-ISIMObjectNamespace $raw_container $this.namespace
				
				$wsReturn	=	$this.proxy.createStaticRole($wsSession, $wsContainer, $raw_role)
		
				if($null -ne $wsReturn) {
					$returnObject		=	[ISIM_Role]::new($wsReturn)
				}
			}catch{
				$exceptionMessage	=	"Error creating role"
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			try{
				$exceptionMessage	=	"Proxy not found."
				throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				debugLog "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				debugLog "trace" "$($subject):	++	Exception:	$($PSItem)"
				debugLog "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				debugLog "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}
		return $returnObject
	}

}