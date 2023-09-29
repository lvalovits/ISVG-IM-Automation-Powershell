using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"

using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"
using module "..\entities\organizationalUnit.psm1"

#
#	usage:
#		$orgUnit_proxy	=	[IM_Session_Proxy]::new(<im_endpoint>) : [IM_Session_Proxy]
#		$orgUnit_proxy.getOrganizationRoot(<session>) : IM_Container[]
#		$orgUnit_proxy.getOrganizationRoot(<session>, <root_org_name_pattern>) : IM_Container[]
#		$orgUnit_proxy.getOrganizationTree(<session>) : IM_Container[]
#		$orgUnit_proxy.getOrganizationTree(<session>, <root_org_name_pattern>) : IM_Container[]
#		$orgUnit_proxy.lookupContainer(<session>, <container_dn>) : IM_Container[]
#

class IM_OrganizationalUnit_Proxy{

	static $version 		=	0.2.1
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

	[IM_Container[]] getOrganizationRoot ([IM_Session] $s){
		return $this.getOrganizationRoot($s, $null)
	}

	[IM_Container[]] getOrganizationRoot ([IM_Session] $s, [string] $pattern){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieving root organizations")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.getOrganizations($wsSession)
			
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieved $($wsReturn.count) root organizations")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Root organizations retrieved:")

				if ($pattern){
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++		Filtering results based on pattern: '$($pattern)'")
					$wsReturn	=	$wsReturn | Where-Object { $_.name -like $pattern}
				}

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Container]::new($_))
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

	[IM_Container[]] getOrganizationTree ([IM_Session] $s){
		return $this.getOrganizationTree($s, $null)
	}

	[IM_Container[]] getOrganizationTree ([IM_Session] $s, [string] $pattern){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieving organization tree")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.getOrganizationTree($wsSession)
			
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieved $($wsReturn.count) root organizations")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Root organizations retrieved:")

				if ($pattern){
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++		Filtering results based on pattern: '$($pattern)'")
					$wsReturn	=	$wsReturn | Where-Object { $_.name -like $pattern}
				}

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Container]::new($_))
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

	[IM_Container[]] lookupContainer ([IM_Session] $s, [string] $dn){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieving container by DN")
			[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Looking up DN: $($dn)")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.lookupContainer($wsSession, $dn)
			
			[utils_logs]::write_log("TRACE", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Retrieved $($wsReturn.count) containers")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++	Containers retrieved:")

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_OrganizationalUnit_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Container]::new($_))
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

	

}