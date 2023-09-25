using module "..\entities\Session.psm1"
using module "..\entities\OrganizationalUnit.psm1"

#
#	DO NOT:
#		[IM_OrganizationalUnit_Proxy]::new()
#	usage:
#		$orgUnit_proxy	=	[IM_OrganizationalUnit_Proxy]::getProxy()
#		$orgUnit_proxy.init() : void
#		$orgUnit_proxy.getOrganization(<raw_session>) : IM_OrgUnit
#		$orgUnit_proxy.getOrganizationSubTree(<raw_session> , <raw_organization>) : IM_OrgUnit
#

class IM_OrganizationalUnit_Proxy{
	################# Singleton start #################
    hidden static [IM_OrganizationalUnit_Proxy] $_instance	=	[IM_OrganizationalUnit_Proxy]::new()
    hidden IM_OrganizationalUnit_Proxy() {}
    static [IM_OrganizationalUnit_Proxy] getProxy() { return [IM_OrganizationalUnit_Proxy]::_instance }
	################# Singleton end #################

	[string]$proxy_wsdl		=	$PROPERTY_FILE.ENDPOINTS.ORGANIZATIONALCONTAINER
	$proxy					=	$null
	$namespace				=	$null

	[void] init (){
		
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
		$exceptionMessage	=	$null
		$returnObject		=	$null

		try{
			
			if ( $null -eq [IM_Session]::GetSession().clientSession ){
				$exceptionMessage	=	"Session not found."
				Throw $exceptionMessage
			}

			$returnObject	=	New-Object $($this.namespace+".WSOrganizationalContainer")

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

	[IM_Container] getOrganization ( $raw_session, $org_name){

		$subject			=	"getOrganization"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		if ($null -ne $this.proxy){
			try{
			
				$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace

				$wsReturn	=	$this.proxy.getOrganizations($wsSession)

				if($wsReturn.count -gt 0) {
					$wsReturnFiltered	=	$wsReturn | Where-Object { $_.name -eq $org_name}
					$returnObject		=	[IM_Container]::new($wsReturnFiltered)
				}	
			}catch{
				$exceptionMessage	=	"Error retrieving organizations."
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

	[IM_Container] getOrganizationSubTree ( $raw_session , $raw_organization ){

		$subject			=	"getOrganizationSubTree"
		$returnObject		=	$null
		$returnArray		=	@()
		$exceptionMessage	=	$null

		if ($null -ne $this.proxy){
			try{
			
				$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
				write-host 1
				$wsReturn	=	$this.proxy.getOrganizationSubTree($wsSession, $raw_organization)
				write-host 2
				if($null -ne $wsReturn) {
					$returnObject		=	[IM_Container]::new($wsReturn)
				}
			}catch{
				$exceptionMessage	=	"Error retrieving organizaton"
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