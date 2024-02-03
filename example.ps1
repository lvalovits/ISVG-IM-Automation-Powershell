# Import entities
	using module ".\isvg_im_lib\entities\endpoint.psm1"
	using module ".\isvg_im_lib\entities\session.psm1"
	using module ".\isvg_im_lib\entities\organizationalUnit.psm1"
	using module ".\isvg_im_lib\entities\role.psm1"
	using module ".\isvg_im_lib\entities\person.psm1"

# Import proxies
	using module ".\isvg_im_lib\proxies\proxy_unauth.psm1"
	using module ".\isvg_im_lib\proxies\proxy_session.psm1"
	using module ".\isvg_im_lib\proxies\proxy_organizationalUnit.psm1"
	using module ".\isvg_im_lib\proxies\proxy_role.psm1"
	using module ".\isvg_im_lib\proxies\proxy_person.psm1"

# Import utils
	using module ".\isvg_im_lib\utils\utils_properties.psm1"
	using module ".\isvg_im_lib\utils\utils_logs.psm1"

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

function Test-GetRootOrganizations(){
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
	# $tree_orgs = $org_proxy.getOrganizationTree($im_session, $pattern)

	Write-Host "Root organizations count:	$($root_orgs.count)"
	# Write-Host "Organization tree count:	$($tree_orgs.count)"
	Write-Host
	$root_orgs
	# $tree_orgs
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
	# $root_orgs = $org_proxy.getOrganizationRoot($im_session, $pattern)

	# Search root organizations including subtrees
	$tree_orgs = $org_proxy.getOrganizationTree($im_session, $pattern)

	# Write-Host "Root organizations count:	$($root_orgs.count)"
	Write-Host "Organization tree count:	$($tree_orgs.count)"
	Write-Host
	# $root_orgs
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

function Test-NewStaticRole(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[Parameter(Mandatory)]
		[IM_Role] $im_role,

		[Parameter(Mandatory)]
		[IM_Container] $im_container
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New role proxy
	$role_proxy	=	[IM_Role_Proxy]::new($im_endpoint)

	# Create static role
	$roles = $role_proxy.createStaticRole($im_session, $im_container, $im_role)

	Write-Host "Roles?:	$($roles)"
	Write-Host
}

function Test-GetPersons(){
	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $port,

        [Parameter(Mandatory)]
        [bool] $secure,

		[string] $ldap_filter
    )

	# New IM endpoint
	$im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)

	# New session proxy
	$im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

	# A valid session is required to retrieve info from IM
	$im_session			=	$im_session_proxy.login()

	# New person proxy
	$person_proxy	=	[IM_Person_Proxy]::new($im_endpoint)

	# Search persons
	$persons = $person_proxy.searchPersonsFromRoot($im_session, $ldap_filter)

	Write-Host "Persons count:	$($persons.count)"
	Write-Host
	$persons
}

function Test-LookupPersons(){
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

	# New person proxy
	$person_proxy	=	[IM_Person_Proxy]::new($im_endpoint)

	# Lookup persons based on input DN
	$persons = $person_proxy.lookupPerson($im_session, $distinguishedName)

	Write-Host "Persons count:	$($persons.count)"
	Write-Host
	$persons
}
#-src_ip_or_hostname $src_ip_or_hostname -src_port $src_port -src_secure $src_secure -dst_ip_or_hostname $dst_ip_or_hostname -dst_port $dst_port -dst_secure $dst_secure
function Test-MigrateRoles(){
	#	Assumptions:
		#	Source and destionation organizational structure are equals.
		#	There is NO DUPLICATED CONTAINERS (name)

	[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $src_ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $src_port,

        [Parameter(Mandatory)]
        [bool] $src_secure,

		[Parameter(Mandatory)]
        [string] $dst_ip_or_hostname,

        [Parameter(Mandatory)]
        [int] $dst_port,

        [Parameter(Mandatory)]
        [bool] $dst_secure,

		[string] $pattern,

		[switch] $useDefaultRootOrg
    )

	# Search roles from source (bkp purposes)
	$src_roles_bkp = Test-GetRoles -ip_or_hostname $src_ip_or_hostname -port $src_port -secure $src_secure
	$dst_roles_bkp = Test-GetRoles -ip_or_hostname $dst_ip_or_hostname -port $dst_port -secure $dst_secure

	# Backup source and destination
	($src_roles_bkp | ConvertTo-Json) >> (".\out\migration\src_bkp_roles_" + $([utils_logs]::timeStamp()) + ".json")
	($dst_roles_bkp | ConvertTo-Json) >> (".\out\migration\dst_bkp_roles_" + $([utils_logs]::timeStamp()) + ".json")

	# Filter roles to migrate
	$src_roles = $src_roles_bkp | Where-Object { $_.name -like $pattern}
	
	# each role to migrate will include (true|falase, role , container) tuple
		#true for static
		#false for dynamic
	$role_tuple = @()
	$roles_to_migrate = @()

	
	# If useDefaultRootOrg search for destination root org
	if ($useDefaultRootOrg){

		$dst_im_container = Test-LookupContainer -ip_or_hostname $dst_ip_or_hostname -port $dst_port -secure $dst_secure -distinguishedName "erglobalid=00000000000000000000,ou=Acme,dc=isim"

		$src_roles | ForEach-Object{
			Write-Warning "Preparing role to be created | r: $($_.name) | c: $($dst_im_container.name)."
			$role_tuple = @($_, $dst_im_container)
			
			# to create an array of array comma is needed. don't ask me go to ask to powershell
			$roles_to_migrate += ,$role_tuple
		}
	}else{
		$src_im_containers = Test-GetOrganization -ip_or_hostname $src_ip_or_hostname -port $src_port -secure $src_secure
		$dst_im_containers = Test-GetOrganization -ip_or_hostname $dst_ip_or_hostname -port $dst_port -secure $dst_secure

		# Validate if source container exist on destination
			# exist -> add to conversion table
			# no exsit -> add to no match table

		# k: source_container_dn
		# v: destination_container_dn
		$containersConversionTable = @{}

		# k: container name
		# v: source_container_dn
		$containersNoMatch

		$src_im_containers | ForEach-Object{
			$c_name = $_.name
			$match = $dst_im_containers | Where-Object { $_.Name -eq $c_name}
			if ($match.count -eq 1){
				$containersConversionTable.add($_.itimDN, $match.itimDN)
			}else{
				$containersNoMatch.add($c_name, $_.itimDN)
				Write-Warning "Zero or Multiple containers found: $($c_name) $($match.count)"
				continue
			}
		}

		$containersNoMatch
		
		$src_roles | ForEach-Object{
			$src_im_container_dn = $_.attributes.erparent
			
			# if container role exist into no match table, skip
			if ($containersNoMatch[$src_im_container_dn]){
				Write-Warning "Zero or Multiple containers found for role: $($_.name) $($match.count)"
				continue
			}

			# search destination container dn into conversion table
			$dst_im_container_dn = $containersConversionTable[$src_im_container_dn]

			# remove extra attributes not needed during creation of im objects
			$_.attributes.Remove("erglobalid")
			$_.attributes.Remove("objectclass")
			$_.attributes.Remove("erparent")

			# retrieve destination container dn from destination container list
			#$dst_im_container = Test-LookupContainer -ip_or_hostname $dst_ip_or_hostname -port $dst_port -secure $dst_secure -distinguishedName $dst_im_container_dn
			$dst_im_container = $dst_im_containers | Where-Object { $_.itimDN -eq $dst_im_container_dn}
			
			Write-Warning "Preparing role to be created | r: $($_.name) | c: $($dst_im_container.name)."
			$role_tuple = @($_, $dst_im_container)
			
			# to create an array of array comma is needed. don't ask me go to ask to powershell
			$roles_to_migrate += ,$role_tuple

			# create role
			#$dst_role_proxy.createStaticRole($dst_im_session, $dst_im_container, $_)

		}

	}

	Test-NewStaticRole -ip_or_hostname $dst_ip_or_hostname -port $dst_port -secure $dst_secure -im_container $dst_im_container -im_role $_
    
}

# Recomedation: move this function to an utils files (your own script like "utils_example.ps1")
function Test-ExportToJSON(){
	[CmdletBinding()]
    param (
		[Parameter(Mandatory)]
		$im_objects,
		
		[System.IO.FileInfo] $export_path,
		[System.IO.FileInfo] $export_file
	)

	if (-not $export_file){
		Write-Warning "Export file not defined."
		$export_file = "im_objects_export" + $([utils_logs]::timeStamp()) + ".json"
	}
	
	if (-not $export_path){
		Write-Warning "Export path not defined. Info will be exported on working directory."
		$export_path = ".\"
	}
	
	if (-not (Test-Path -PathType Container -Path ($export_path))){
		Write-Warning "Creating log files directory"
		New-Item -ItemType Directory -Path ($export_path) > $null
	}
	
	
	$export_path	=	Convert-Path ($export_path)
	$export_file	=	"$($export_path)\$($export_file)"
	
	($im_objects | ConvertTo-Json) >> $export_file

	$export_file	=	Convert-Path ($export_file)

	Write-Warning "Export file: $($export_file)"	
}

function Test(){
	[CmdletBinding()]
    param (
		[switch] $userRootOrganization
	)
	Write-host $userRootOrganization
}

$ip_or_hostname = "172.25.230.154"
$port = 9082
$secure = $TRUE

#	manual test:
	#	([IM_Session_Proxy]::new([IM_Endpoint]::new($ip_or_hostname, $port, $secure))).login()
	#	$proxy = [IM_Person_Proxy]::new([IM_Endpoint]::endpoints[0])
	#	$s = Copy-ISIMObjectNamespace ([IM_Session]::sessions[0].raw) $($proxy.namespace)
	#	$proxy.wsMethod($s, $x, $y)

#	init
	#	Initialize properties and log files
		Test-Init
	#	Test endpoints connectivity. Required to bypass SSL validation if [utils_properties]::PROPERTIES.LIB.SSL_SKIP_VALIDATION is TRUE
		Test-EndpointConnection -ip_or_hostname $ip_or_hostname -port $port -secure $secure

#	Login
	#	Test-Login -ip_or_hostname $ip_or_hostname -port $port -secure $secure

#	Utils
		$im_objects = Test-GetOrganization -ip_or_hostname $ip_or_hostname -port $port -secure $secure
		Test-ExportToJSON -im_objects $im_objects -export_path ".\out\test-export" -export_file "ou.json"
		$im_objects = Test-GetRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure
		Test-ExportToJSON -im_objects $im_objects -export_path ".\out\test-export" -export_file "role.json"
		$im_objects = Test-GetPersons -ip_or_hostname $ip_or_hostname -port $port -secure $secure
		Test-ExportToJSON -im_objects $im_objects -export_path ".\out\test-export" -export_file "person.json"

#	Organization
	#	Test-GetRootOrganizations -ip_or_hostname $ip_or_hostname -port $port -secure $secure
	#	Test-GetRootOrganizations -ip_or_hostname $ip_or_hostname -port $port -secure $secure -pattern "foo*"
	
	#	Test-GetOrganization -ip_or_hostname $ip_or_hostname -port $port -secure $secure
	#	Test-GetOrganization -ip_or_hostname $ip_or_hostname -port $port -secure $secure -pattern "foo*"
	
	#	Test-LookupContainer -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=6329215222743470485,ou=Acme,dc=isim"
	#	Test-LookupContainer -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=00000000000000000000,ou=Acme,dc=isim"

#	Roles
	#	Test-GetRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure
	#	Test-GetRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure -pattern "foo*"
	
	#	Test-LookupRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=2462236994728559718,ou=roles,erglobalid=00000000000000000000,ou=Acme,dc=isim"

	#	$r = [im_role]::new("Test new role from PowerShell - 7", "Description - 7")
	#	$c = Test-LookupContainer -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=6329215222743470485,ou=Acme,dc=isim"
	#	Test-NewStaticRole -ip_or_hostname $ip_or_hostname -port $port -secure $secure -im_container $c -im_role $r

#	Person
	#	Test-GetPersons -ip_or_hostname $ip_or_hostname -port $port -secure $secure
	#	Test-GetPersons -ip_or_hostname $ip_or_hostname -port $port -secure $secure -ldap_filter "(cn=*system*)"
	
	#	Test-LookupPersons -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=00000000000000000007,ou=0,ou=people,erglobalid=00000000000000000000,ou=Acme,dc=isim"

#	Migration
	#	Test-MigrateRoles -src_ip_or_hostname $src_ip_or_hostname -src_port $src_port -src_secure $src_secure -dst_ip_or_hostname $dst_ip_or_hostname -dst_port $dst_port -dst_secure $dst_secure -useDefaultRootOrg
	#	$r = Test-GetRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure -pattern "foo*"
	#	($r | ConvertTo-Json) >> .\out\roles.json
	#	Test-FromJSON

#######################################################

# $c = Test-LookupContainer -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=6329215222743470485,ou=Acme,dc=isim"
# $r = Test-LookupRoles -ip_or_hostname $ip_or_hostname -port $port -secure $secure -distinguishedName "erglobalid=2462236994728559718,ou=roles,erglobalid=00000000000000000000,ou=Acme,dc=isim"

# $im_endpoint		=	[IM_Endpoint]::new($ip_or_hostname, $port, $secure)
# $im_role_proxy		=	[IM_Role_Proxy]::new($IM_Endpoint)
# $im_session_proxy	=	[IM_Session_Proxy]::new($im_endpoint)

# $c_raw = $c.raw
# $r_raw = $r.raw

# $r.raw.name = "Test new role from PowerShell - 2"
# $r.raw.description = "Description - 2"

# $rp_namespace = $im_role_proxy.proxy.GetType().Namespace

# $r.attributes.remove("erjavascript")
# $r.attributes.remove("eraccessdescription")
# $r.attributes.remove("eraccessoption")
# $r.attributes.remove("cargoasociado")
# $r.attributes.remove("erglobalid")
# $r.attributes.remove("erscope")
# $r.attributes.remove("objectclass")
# $r.attributes.remove("eraccessname")
# $r.attributes.remove("erroleclassification")
# $r.attributes.remove("erparent")
# $r.attributes.remove("erobjectprofilename")
# $r.attributes.errolename = "Test new role from PowerShell - 2"
# $r.attributes.description = "Description - 2"

# $wsAttr = Convert-Hash2WSAttr -hash $r.attributes -namespace $rp_namespace
# $r.raw.attributes = $wsattr



# $im_session			=	$im_session_proxy.login()


# $c_RoleNamedpaced	=	Copy-ISIMObjectNamespace $c_raw $rp_namespace
# $c_RoleNamedpaced

# $s_roleNamespaced	=	Copy-ISIMObjectNamespace $im_session.raw $rp_namespace

# $im_role_proxy.proxy.createStaticRole($s_roleNamespaced, $c_RoleNamedpaced, $r_raw)

exit