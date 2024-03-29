using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"
using module "..\utils\utils_proxy.psm1"

using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"
using module "..\entities\role.psm1"
using module "..\entities\organizationalUnit.psm1"

#
#	usage:
#		$role_proxy	=	[IM_Role_Proxy]::new(<im_endpoint>) : [IM_Role_Proxy]
#		$role_proxy.searchRoles( <raw_session> ) : IM_Role[]
#		$role_proxy.searchRoles( <raw_session> , <filter> ) : IM_Role[]
#		$role_proxy.lookupRole( <raw_session> , <role_dn> ) : IM_Role[]
#

class IM_Role_Proxy{

	static $version 		=	0.2.0
	hidden static $subject 	=	"im_role_proxy"
	static $proxies			=	@()

	$proxy					=	$null
	$namespace				=	$null
	$proxy_wsdl				=	$null

	hidden IM_Role_Proxy() { throw 'Default constructor disabled. To instance a new proxy use [IM_Role_Proxy]::new( [IM_Endpoint] $endpoint )' }

	IM_Role_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.ROLE
			$this.proxy				=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_Role_Proxy]::proxies	+=	$this
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	New role proxy created: $($this.proxy_wsdl)")
		}catch{
			Write-Warning "$([IM_Role_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Role_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_Role_Proxy] instance'
		}
	}

	[IM_Role[]] searchRoles ([IM_Session] $s){
		return $this.searchRoles($s, $null)
	}

	[IM_Role[]] searchRoles ([IM_Session] $s, [string] $filter){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Retrieving roles")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.searchRoles($wsSession, $filter)
			
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Retrieved $($wsReturn.count) roles")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_Role_Proxy]::subject):	++	Roles retrieved:")

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_Role_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Role]::new($_))
				}
			}
		}catch{
			Write-Warning "$([IM_Role_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Role_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving roles'
		}
		
		return $returnObject
	}

	[IM_Role[]] lookupRole ([IM_Session] $s, [string] $dn){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Retrieving role by DN")
			[utils_logs]::write_log("DEBUG", "$([IM_Role_Proxy]::subject):	++	Looking up DN: $($dn)")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.lookupRole($wsSession, $dn)
			
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Retrieved $($wsReturn.count) roles")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_Role_Proxy]::subject):	++	Roles retrieved:")

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_Role_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Role]::new($_))
				}
			}
		}catch{
			Write-Warning "$([IM_Role_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Role_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving roles'
		}
		
		return $returnObject
	}

	[IM_Role[]] createStaticRole ([IM_Session] $s, [IM_Container] $c, [IM_Role] $r){
		$raw_session		=	$s.raw
		$raw_container		=	$c.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Creating static role")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsContainer =	Copy-ISIMObjectNamespace $raw_container $this.namespace

			$global:wsRole = Convert-2WSObject $r (New-Object $($this.namespace + ".WSRole"))

			$wsReturn	=	$this.proxy.createStaticRole($wsSession, $wsContainer, $global:wsRole)
			
			[utils_logs]::write_log("TRACE", "$([IM_Role_Proxy]::subject):	++	Static role creation return: $($wsReturn)")
			

		}catch{
			Write-Warning "$([IM_Role_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Role_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Role_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error creating static role'
		}
		
		return $returnObject
	}
}