using module "..\entities\Session.psm1"
using module "..\entities\Role.psm1"

#
#	DO NOT:
#		[IM_Role_Proxy]::new()
#	usage:
#		$role_proxy	=	[IM_Role_Proxy]::getProxy()
#		$role_proxy.init() : void
#		$role_proxy.searchRoles( <raw_session> , <filter> ) : IM_Role[]
#		$role_proxy.createStaticRole ( <raw_session> , <raw_container> , <raw_role> ) : IM_Role
#		$role_proxy.getRawRole ( <IM_Role> ) : raw_role
#		$role_proxy.getStub() : raw_role
#

class IM_Role_Proxy{
	################# Singleton start #################
    hidden static [IM_Role_Proxy] $_instance	=	[IM_Role_Proxy]::new()
	hidden IM_Role_Proxy() {}
    static [IM_Role_Proxy] getProxy() { return [IM_Role_Proxy]::_instance }
	################# Singleton end #################

	[string]$proxy_wsdl		=	$PROPERTY_FILE.ENDPOINTS.ROLE
	$proxy					=	$null
	$namespace				=	$null

	[void]init(){
		
		$subject			=	"proxy init"

		try{
			if ( $null -eq [IM_Session]::GetSession().clientSession ){
				$exceptionMessage	=	"Session not found."
				Throw $exceptionMessage
			}

			$this.proxy	=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop # -Namespace "WebServiceProxy" -Class "Session"
			$this.namespace	=	$this.proxy.GetType().Namespace
		}
		catch {
			$exceptionMessage	=	"Could not create proxy."
			Write-Host -fore red "$($subject): $exceptionMessage"
			write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
			write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
			write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
			write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
		}
	}

	[psObject] getStub(){
		
		$subject			=	"getStub"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		try{
			
			if ( $null -eq [IM_Session]::GetSession().clientSession ){
				$exceptionMessage	=	"Session not found."
				Throw $exceptionMessage
			}

			$returnObject	=	New-Object $($this.namespace+".WSRole")

		}catch{
			if ( $null -eq $exceptionMessage) { $exceptionMessage	=	"Unhandled error" }
			Write-Host -fore red "$($subject): $exceptionMessage"
			write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
			write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
			write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
			write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
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
						$returnObject		=	[IM_Role]::new($_)
						$returnArray		+=	$returnObject
					}
				}
			}catch{
				$exceptionMessage	=	"Error retrieving roles."
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			try{
				$exceptionMessage	=	"Proxy not found."
				throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}
		return $returnArray
	}

	[IM_Role] createStaticRole ( $raw_session, $raw_container, $raw_role ){
		
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
					$returnObject		=	[IM_Role]::new($wsReturn)
				}
			}catch{
				$exceptionMessage	=	"Error creating role"
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			try{
				$exceptionMessage	=	"Proxy not found."
				throw $exceptionMessage
			}catch{
				Write-Host -fore red "$($subject): $exceptionMessage"
				write_log "error" "$($subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$($subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$($subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$($subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}
		return $returnObject
	}

}