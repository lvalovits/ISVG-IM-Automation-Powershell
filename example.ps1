using module ".\isvg_im_lib\entities\endpoint.psm1"
using module ".\isvg_im_lib\entities\session.psm1"
using module ".\isvg_im_lib\entities\role.psm1"
using module ".\isvg_im_lib\entities\organizationalUnit.psm1"

using module ".\isvg_im_lib\proxies\Proxy_session.psm1"
using module ".\isvg_im_lib\proxies\Proxy_role.psm1"
using module ".\isvg_im_lib\proxies\Proxy_organizationalUnit.psm1"

using module ".\isvg_im_lib\utils\utils_properties.psm1"
using module ".\isvg_im_lib\utils\utils_logs.psm1"

using module ".\isvg_im_lib\enums\log_category.psm1"

# $Global:PWD var is use to get the execution path to be send to static methods
# unable to get $PSScriptRoot inside a static method
$Global:PWD = $($PSScriptRoot)

# Initialize utils
if (
	$([utils_properties]::_init_()) -and
	$([utils_logs]::_init_())
){ Write-Output "initialization completed" }
else{ throw "initialization error" }

[IM_Endpoint]::new("google.com", "443", $TRUE) | Out-Null
[IM_Endpoint]::test_endpoints_ICMP([IM_Endpoint]::endpoints)
[IM_Endpoint]::test_endpoints_HTTPS([IM_Endpoint]::endpoints)

[IM_Session_Proxy]::new([IM_Endpoint]::endpoints[0])
[IM_Session_Proxy]::proxies[0].login()

exit
function Test-Connection(){
	$session_proxy	=	[ISIM_Session_Proxy]::getProxy()
	$session_proxy.init()
	
	$creds			=	$null

	try{
		$creds		=	Get-Credential -Message "Enter your ISVG IM credential"
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