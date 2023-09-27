using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"
using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"
using module "..\entities\organizationalUnit.psm1"

#
#	usage:
#		$session_proxy	=	[IM_Session_Proxy]::new(<im_endpoint>) : [IM_Session_Proxy]
#
#		$orgUnit_proxy.getOrganizationRoot(<session>) : IM_Container
#		$orgUnit_proxy.getOrganizationSubTree(<session> , <organization>) : IM_Container[]
#

class IM_OrganizationalUnit_Proxy{

	static $version 		=	0.2.0
	hidden static $subject 	=	"im_container_proxy"
	static $proxies			=	@()

	$proxy					=	$null
	$namespace				=	$null
	$proxy_wsdl				=	$null

	hidden IM_OrganizationalUnit_Proxy() { throw 'Default constructor disabled. To instance a new proxy use [IM_OrganizationalUnit_Proxy]::new( [IM_Endpoint] $endpoint )' }

	IM_OrganizationalUnit_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.ORGANIZATIONALCONTAINER
			$this.proxy				=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_OrganizationalUnit_Proxy]::proxies	+=	$this
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	New organizational proxy created: $($this.proxy_wsdl)")
		}catch{
			Write-Warning "$([IM_OrganizationalUnit_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_OrganizationalUnit_Proxy] instance'
		}
	}

	[psObject] getStub(){
		$returnObject		=	$null
		try{
			$returnObject	=	New-Object $($this.namespace+".WSOrganizationalContainer")
		}catch{
			Write-Warning "$([IM_OrganizationalUnit_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving container stub'
		}
		return $returnObject
	}

	[IM_Container] getOrganizationRoot ([IM_Session] $s){
		return $this.getOrganizationRoot($s, $null)
	}


	[IM_Container[]] getOrganizationRoot ([IM_Session] $s, [string] $org_name){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieving root organizations")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.getOrganizations($wsSession)
			
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieved $($wsReturn.count) root organizations")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Root organizations retrieved:")

				if ($org_name){
					$wsReturn	=	$wsReturn | Where-Object { $_.name -like $org_name}
				}

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Root organization name: $($_.name)")
					$returnObject.add([IM_Container]::new($_))
				}
			}
		}catch{
			Write-Warning "$([IM_OrganizationalUnit_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_OrganizationalUnit_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving root organizations'
		}
		
		return $returnObject
	}

	[IM_Container] getOrganizationSubTree ($raw_session , $raw_organization){
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
				Write-Host -fore red "$([IM_OrganizationalUnit_Proxy]::subject): $exceptionMessage"
				write_log "error" "$([IM_OrganizationalUnit_Proxy]::subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}else{
			try{
				$exceptionMessage	=	"Proxy not found."
				throw $exceptionMessage
			}catch{
				Write-Host -fore red "$([IM_OrganizationalUnit_Proxy]::subject): $exceptionMessage"
				write_log "error" "$([IM_OrganizationalUnit_Proxy]::subject):	+ $($exceptionMessage) [ $($PSItem.exception.gettype()) ]"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	Exception:	$($PSItem)"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)"
				write_log "trace" "$([IM_OrganizationalUnit_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)."
			}
		}
		return $returnObject
	}
}