using module ".\isvg_im_lib\entities\endpoint.psm1"
using module ".\isvg_im_lib\entities\session.psm1"
using module ".\isvg_im_lib\entities\role.psm1"
using module ".\isvg_im_lib\entities\organizationalUnit.psm1"

using module ".\isvg_im_lib\proxies\proxy_unauth.psm1"
using module ".\isvg_im_lib\proxies\proxy_session.psm1"
using module ".\isvg_im_lib\proxies\proxy_role.psm1"
using module ".\isvg_im_lib\proxies\proxy_organizationalUnit.psm1"

using module ".\isvg_im_lib\utils\utils_properties.psm1"
using module ".\isvg_im_lib\utils\utils_logs.psm1"

using module ".\isvg_im_lib\enums\log_category.psm1"

Import-Module ".\isvg_im_lib\utils\utils_proxy_wrapper.ps1"

# $Global:PWD var is use to get the execution path to be send to static methods
# unable to get $PSScriptRoot inside a static method
$Global:PWD = $($PSScriptRoot)

function Test-Init(){

	# Initialize utils
	#	- property files
	#	- log file

	if (
		$([utils_properties]::_init_()) -and
		$([utils_logs]::_init_())
	){ Write-Output "initialization completed" }
	else{ throw "initialization error" }
}

function Test-EndpointConnection(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)
	
	# Test endpoint connection
	[IM_Endpoint]::test_endpoints_ICMP($im_endpoint)
	[IM_Endpoint]::test_endpoints_HTTPS($im_endpoint)

	# New unauth proxy
	$im_unauth_proxy	=	[IM_Unauth_Proxy]::new($im_endpoint)

	# IM Login (returns a IM_Session object)
	$im_version			=	$im_unauth_proxy.getItimVersionInfo()

	Write-Host -fore green "Endpoint version $($im_version)"
	Write-Host
}

function Test-Login(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[PSCredential] $credential
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)
	
	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# IM Login (returns a IM_Session object)
	if ($credential){
		$im_session			=	$im_session_proxy.login($credential)
	}else{
		$im_session			=	$im_session_proxy.login()
	}

	Write-Host -fore green "Login success"
	Write-Host
	$im_session
}

function Test-GetOrganization(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[string] $pattern
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New organizational proxy
	$org_proxy	=	[IM_OrganizationalUnit_Proxy]::new($im_endpoint)

	# Search root organizations
	$root_orgs = $org_proxy.getOrganizationRoot($im_session, $pattern)

	# Search root organizations including subtrees
	$tree_orgs = $org_proxy.getOrganizationTree($im_session, $pattern)

	Write-Host "Root organizations count:	$($root_orgs.count)"
	Write-Host "Organization tree count:	$($tree_orgs.count)"
	Write-Host
	$root_orgs
	$tree_orgs
}

function Test-LookupContainer(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[Parameter(Mandatory)]
		[string] $distinguishedName
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New organizational proxy
	$org_proxy	=	[IM_OrganizationalUnit_Proxy]::new($im_endpoint)

	# Lookup container based on input DN
	$containers = $org_proxy.lookupContainer($im_session, $distinguishedName)

	Write-Host "Container count:	$($containers.count)"
	Write-Host
	$containers
}

function Test-GetRoles(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[string] $pattern
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New role proxy
	$role_proxy	=	[IM_Role_Proxy]::new($im_endpoint)

	# Search roles
	$roles = $role_proxy.searchRoles($im_session, $pattern)

	Write-Host "Roles count:	$($roles.count)"
	Write-Host
	$roles
}

function Test-LookupRoles(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[Parameter(Mandatory)]
		[string] $distinguishedName
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New role proxy
	$role_proxy	=	[IM_Role_Proxy]::new($im_endpoint)

	# Lookup role based on input DN
	$roles = $role_proxy.lookupRole($im_session, $distinguishedName)

	Write-Host "Roles count:	$($roles.count)"
	Write-Host
	$roles
}

Test-Init
Test-EndpointConnection -ip_or_hostname "google.com" -port 443 -secure $TRUE
# Test-Login -ip_or_hostname "google.com" -port 443 -secure $TRUE
# Test-GetOrganization -ip_or_hostname "google.com" -port 443 -secure $TRUE
# Test-GetOrganization -ip_or_hostname "google.com" -port 443 -secure $TRUE -pattern "foo*"
# Test-LookupContainer -ip_or_hostname "google.com" -port 443 -secure $TRUE -distinguishedName "erglobalid=6329215222743470485,ou=Acme,dc=isim"
# Test-GetRoles -ip_or_hostname "google.com" -port 443 -secure $TRUE
# Test-GetRoles -ip_or_hostname "google.com" -port 443 -secure $TRUE -pattern "foo*"
# Test-LookupRoles -ip_or_hostname "google.com" -port 443 -secure $TRUE -distinguishedName "erglobalid=1695361430646039633,ou=roles,erglobalid=00000000000000000000,ou=Acme,dc=isim"
exit

#TODO:	Test-SearchPerson
#TODO:	Test-SearchAccount
#TODO:	Test-SearchServices
#TODO:	Test-SearchRoles
#TODO:	Test-CreateDynamicRoles
#TODO:	Test-CreateStaticRoles
#TODO:	Test-CreateProvisioningPolicy
#TOOD:	Test-SearchACI
#TOOD:	Test-SearchWorkflows

exit