using module "..\utils\utils_properties.psm1"
using module "..\utils\utils_logs.psm1"
using module "..\utils\utils_proxy.psm1"

using module "..\entities\endpoint.psm1"
using module "..\entities\session.psm1"
using module "..\entities\person.psm1"

#
#	DO NOT:
#		[IM_Person_Proxy]::new()
#	usage:
#		$person_proxy	=	[IM_Person_Proxy]::getProxy()
#		$person_proxy.init() : void
#		$person_proxy.searchPersonFromRoot( <raw_session> , <filter> ) : IM_Person[]
#		$person_proxy.lookupPerson ( <raw_session> , <raw_container> , <raw_person> ) : IM_Person
#

class IM_Person_Proxy{

	static $version 		=	0.2.0
	hidden static $subject 	=	"im_person_proxy"
	static $proxies			=	@()

	$proxy					=	$null
	$namespace				=	$null
	$proxy_wsdl				=	$null

	hidden IM_Person_Proxy() { throw 'Default constructor disabled. To instance a new proxy use [IM_Person_Proxy]::new( [IM_Endpoint] $endpoint )' }

	IM_Person_Proxy([IM_Endpoint] $endpoint){
		try{
			$this.proxy_wsdl		=	$endpoint.endpoints_list.PERSON
			$this.proxy				=	New-WebServiceProxy -Uri $this.proxy_wsdl -ErrorAction stop
			$this.namespace			=	$this.proxy.GetType().Namespace

			[IM_Person_Proxy]::proxies	+=	$this
			[utils_logs]::write_log("TRACE", "$([IM_Person_Proxy]::subject):	++	New person proxy created: $($this.proxy_wsdl)")
		}catch{
			Write-Warning "$([IM_Person_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Person_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error initializing [IM_Person_Proxy] instance'
		}
	}

	[IM_Person[]] searchPersonsFromRoot ([IM_Session] $s){
		return $this.searchPersonsFromRoot($s, $null, $null)
	}
	[IM_Person[]] searchPersonsFromRoot ([IM_Session] $s, [string] $ldap_filter){
		return $this.searchPersonsFromRoot($s, $ldap_filter, $null)
	}
	[IM_Person[]] searchPersonsFromRoot ([IM_Session] $s, [string[]] $attributeList){
		return $this.searchPersonsFromRoot($s, $null, $attributeList)
	}

	[IM_Person[]] searchPersonsFromRoot ([IM_Session] $s, [string] $ldap_filter, [string[]] $attributeList){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_Person_Proxy]::subject):	++	Retrieving persons")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.searchPersonsFromRoot($wsSession, $ldap_filter, $attributeList)
			
			[utils_logs]::write_log("TRACE", "$([IM_Person_Proxy]::subject):	++	Retrieved $($wsReturn.count) persons")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_Person_Proxy]::subject):	++	Roles retrieved:")

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_Person_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Person]::new($_))
				}
			}
		}catch{
			Write-Warning "$([IM_Person_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Person_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving persons'
		}
		
		return $returnObject
	}

	[IM_Person[]] lookupPerson ([IM_Session] $s, [string] $dn){
		$raw_session		=	$s.raw
		$returnObject		=	@()

		try{		
			[utils_logs]::write_log("TRACE", "$([IM_Person_Proxy]::subject):	++	Retrieving person by DN")
			[utils_logs]::write_log("DEBUG", "$([IM_Person_Proxy]::subject):	++	Looking up DN: $($dn)")

			$wsSession	=	Copy-ISIMObjectNamespace $raw_session $this.namespace
			$wsReturn	=	$this.proxy.lookupPerson($wsSession, $dn)
			
			[utils_logs]::write_log("TRACE", "$([IM_Person_Proxy]::subject):	++	Retrieved $($wsReturn.count) persons")
			

			if($wsReturn.count -gt 0) {
				[utils_logs]::write_log("DEBUG", "$([IM_Person_Proxy]::subject):	++	Roles retrieved:")

				$wsReturn | ForEach-Object{
					[utils_logs]::write_log("DEBUG", "$([IM_Person_Proxy]::subject):	++		$($_.name)")
					$returnObject	+=	([IM_Person]::new($_))
				}
			}
		}catch{
			Write-Warning "$([IM_Person_Proxy]::subject): $($PSItem)"
			[utils_logs]::write_log("error", "$([IM_Person_Proxy]::subject):	++	Exception:	$($PSItem)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	Ex.Message:	$($PSItem.exception.Message)")
			[utils_logs]::write_log("debug", "$([IM_Person_Proxy]::subject):	++	$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber).")
			throw 'Error retrieving persons'
		}
		
		return $returnObject
	}
}