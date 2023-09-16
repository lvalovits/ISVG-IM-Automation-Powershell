using module ".\isvg_im_lib\entities\Session.psm1"
using module ".\isvg_im_lib\entities\Role.psm1"
using module ".\isvg_im_lib\entities\OrganizationalUnit.psm1"

using module ".\isvg_im_lib\proxies\Proxy_Session.psm1"
using module ".\isvg_im_lib\proxies\Proxy_Role.psm1"
using module ".\isvg_im_lib\proxies\Proxy_OrganizationalUnit.psm1"

using module ".\isvg_im_lib\utils\isvg_im_lib_init.psm1"

using module ".\isvg_im_lib\utils\utils_properties.psm1"
using module ".\isvg_im_lib\utils\utils_logs.psm1"

using module ".\isvg_im_lib\enums\log_category.psm1"
# Import-Module $PSScriptRoot\isvg_im_lib\enums\log_category.ps1 -force
# exit

# $Global:PWD var is use to get the execution path to be send to static methods
# unable to get $PSScriptRoot running in a static method
$Global:PWD = $($PSScriptRoot)

[utils_properties]::_init_()
[utils_logs]::_init_()

# _init_ -SkipTest_Connections -SkipTest_Properties
exit
function Test-Connection(){
	$session_proxy	=	[ISIM_Session_Proxy]::getProxy()
	$session_proxy.init()
	
	$creds			=	$null

	try{
		$creds		=	Get-Credential -Credential $null
	}catch{
		Write-Host -fore red "$($Error[0])"
	}

	if ( $null -ne $creds){
		$session_proxy.login($creds)
	
		if ( -not ( [IM_Session]::GetSession().isEmpty() ) ){
			Write-Host "Login success for user" $creds.UserName
			Write-Host -ForegroundColor green 'Session object is a singleton. You can access it through [IM_Session]::GetSession()'
		}
	}

	Write-Host
}

function Test-SearchRoles(){
	$isim_session 		=	[IM_Session]::GetSession()

	$role_proxy			=	[IM_Role_Proxy]::getProxy()
	$role_proxy.init()
	$isim_roles 		= $role_proxy.searchRoles($isim_session.raw , "(errolename=*)")

	Write-Host "Roles count:		" $isim_roles.count
	Write-Host "	Static roles:	" $($isim_roles | Where-Object {$_.membership_type() -eq 1}).count
	Write-Host "	Dynamic roles:	" $($isim_roles | Where-Object {$_.membership_type() -eq 2}).count
	
	# Global variable to export organizational structure search result for demo purposes
	$Global:isim_roles 	= $isim_roles
	Write-Host -ForegroundColor green 'Roles stored on $Global:isim_roles variable.'
	Write-Host
}

function Test-SearchOrganizationalStructure(){
	$isim_session 				=	[IM_Session]::GetSession()
	$ou_proxy					=	[IM_OrganizationalUnit_Proxy]::getProxy()
	$ou_proxy.init()

	$isim_organization			=	$ou_proxy.getOrganization( $isim_session.raw, $GLOBAL:ISIM_WS_Props['ORGANIZATION_NAME'] )
	
	$isim_organization_acmeInc	=	$isim_organization | Where-Object { $_.name -eq "Acme Inc."}

	$isim_subtree				=	$ou_proxy.getOrganizationSubTree( $isim_session.raw , $isim_organization_acmeInc.raw)

	Write-Host "Organizations count:	" $isim_organization.count	"'#TODO: remove filter by org name?'"
	Write-Host "Subtree count:		" $isim_subtree.count			"'#TODO: count child items'"

	# Global variable to export organizational structure search result for demo purposes
	$Global:isim_organization	=	$isim_organization
	$Global:isim_subtree 		=	$isim_subtree
	Write-Host -ForegroundColor green 'Organizations have been stored on $Global:isim_organization variable.'
	Write-Host -ForegroundColor green 'Organizational Structure have been stored on $Global:isim_subtree variable.'
}

function Test-CreateStaticRoles(){
	$isim_session 						=	[IM_Session]::GetSession()
	
	$role_proxy							=	[IM_Role_Proxy]::getProxy()
	$ou_proxy							=	[IM_OrganizationalUnit_Proxy]::getProxy()

	$isim_organization					=	$ou_proxy.getOrganization( $isim_session.raw )
	$isim_subtree						=	$ou_proxy.getOrganizationSubTree( $isim_session.raw , $isim_organization.raw)

	$new_role_name						=	"WS v2 Static Test - " + $(timeStamp)
	$new_role_desc						=	"Description for WS v2 Static Test - Next role in 5 seconds"
	$isim_new_staticRole				=	[IM_Role]::New($new_role_name, $new_role_desc)
	
	$ws_new_staticRole					=	$role_proxy.getStub()
	Convert-2WSObject $isim_new_staticRole $ws_new_staticRole

	$isim_role	=	$role_proxy.createStaticRole($isim_session.raw, $isim_subtree.children[0].raw, $new_staticRole_ws)
	Write-Host "Static role created:	" $isim_role.name

	Start-Sleep -Seconds 5

	$isim_role.name						=	"WS v2 Static Test - " + $(timeStamp)
	$isim_role.attributes.description	=	"Description for WS v2 Static Test"
	
	$isim_role.attributes.erglobalid	= $null
	$isim_role.attributes.erparent		= $null
	$isim_role.attributes.objectclass	= $null
	
	$ws_new_staticRole_2				=	$role_proxy.getStub()
	Convert-2WSObject $isim_role $ws_new_staticRole_2

	$isim_role	=	$role_proxy.createStaticRole($isim_session.raw, $isim_subtree.children[0].raw, $ws_new_staticRole_2)
	Write-Host "Static role created:	" $isim_role.name
}

Test-Connection
Test-SearchRoles
Test-SearchOrganizationalStructure

#TODO:	Test-SearchServices
#TODO:	Test-SearchPerson
#TOOD:	Test-SearchACI
#TOOD:	Test-SearchWorkflows
#TODO:	Test-CreateDynamicRoles
#TODO:	Test-CreateStaticRoles
#TODO:	Test-CreateProvisioningPolicy

exit


# $session_wsdl	=	"https://172.25.230.154:9082/itim/services/WSSessionService?wsdl"
# $role_wsdl	=	"https://172.25.230.154:9082/itim/services/WSRoleServiceService?wsdl"
$ou_wsdl	=	"https://172.25.230.154:9082/itim/services/WSOrganizationalContainerServiceService?wsdl"

# $session_proxy	=	New-WebServiceProxy -Uri $session_wsdl -ErrorAction stop
# $role_proxy	=	New-WebServiceProxy -Uri $role_wsdl -ErrorAction stop
$ou_ws_proxy	=	New-WebServiceProxy -Uri $ou_wsdl -ErrorAction stop

# $role_namespace	=	$role_proxy.GetType().Namespace
$ou_namespace	=	$ou_ws_proxy.GetType().Namespace

$raw_session	=	[IM_Session]::GetSession().raw
# $raw_ou			=	$subtree.children[0].raw

# $wsSession_roles	=	Copy-ISIMObjectNamespace $raw_session $role_namespace
# $wsContainer_roles	=	Copy-ISIMObjectNamespace $raw_ou $role_namespace -ErrorAction SilentlyContinue
$wsSession_ou	=	Copy-ISIMObjectNamespace $raw_session $ou_namespace

# $roles	=	$role_proxy.searchRoles($wsSession_roles, "(errolename=*)")
$organizations	=	$ou_ws_proxy.getOrganizations($wsSession_ou)
$ous	=	$ou_ws_proxy.getOrganizationSubTree($wsSession_ou, $organizations[0])

# $raw_static_role				=	New-Object $($role_namespace+".WSRole")
# $raw_static_role.name			=	"WS v2 Static Test 10"
# # $raw_static_role.description	=	"Description for WS v2 Static Test 4"

# $Attributes	=	@{"errolenamse"=$raw_static_role.name}
# $wsattr	=	Convert-2WSAttr -hash $Attributes -namespace $role_namespace
# $raw_static_role.attributes	=	$wsattr;

# $new_role_isim	=	$roles[5]

# $new_role_isim.attributes.Remove("erjavascript")
# $new_role_isim.attributes.Remove("erroleclassification")
# $new_role_isim.attributes.Remove("eraccessoption")
# $new_role_isim.attributes.Remove("erscope")
# $new_role_isim.attributes.Remove("erglobalid")
# $new_role_isim.attributes.Remove("erparent")
# $new_role_isim.attributes.Remove("objectclass")

# $new_role_ws	=	New-Object $($new_role_isim.raw.getType().namespace+".WSRole")
# Convert-2WSObject $new_role_isim $new_role_ws

# $r	=	$role_proxy.createStaticRole($wsSession_roles, $wsContainer_roles, $new_role_ws)


# $raw_dinamyc_role				=	New-Object $($role_namespace+".WSRole")
# $raw_dinamyc_role.name			=	"WS v2 Dynamic Test 5"

# $Attributes	=	@{"erscope"="1";"erjavascript"="(cn=not a real filter)"}
# $wsattr	=	Convert-2WSAttr -hash $Attributes -namespace $role_namespace
# $raw_dinamyc_role.attributes	=	$wsattr;

# $role_proxy.createDynamicRole($wsSession_roles, $wsContainer_roles, $raw_dinamyc_role, $null, $false)

