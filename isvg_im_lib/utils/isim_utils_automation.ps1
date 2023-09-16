function seekAndDestroy_person{
	$session	=	getSession
	$PersonClient	=	[ISIM_PersonClient]::getClient()
	$personToDel	=	[ISIM_Person]::new()
	$PersonSearchResult	=	($PersonClient.searchPerson($Session, "(cn=*ws*)"))
	$PersonSearchResult | ForEach-Object{
		$personToDel.itimDN	=	$_.itimdn
		$PersonClient.deletePerson($session, $personToDel)
	}
}

function seekAndDestroy_roles{
	[CmdletBinding()]
	param (
		[Parameter()]
		[String] $filter	=	"(errolename=*ws*)",
		[Parameter()]
		[switch]$v

	)
	
	write_log("seekAndDestroy_roles:	+ Deleting Roles using filter $filter")
	
	$session	=	getSession
	$RoleClient	=	[IM_RoleClient]::getClient()
	$roleToDel	=	[IM_Role]::new()
	
	$RoleSearchResult	=	($RoleClient.searchRole($session, $filter))
	
	$i	=	0
	$totalItems	=	$RoleSearchResult.Count
	$currentItem	=	0
	$percentComplete	=	0
	
	if ($RoleSearchResult.Count -gt 0){
		$RoleSearchResult | ForEach-Object{
			$i++
			$CurrentItem++

			write_log("seekAndDestroy_roles:	++ ($i/$totalItems) Deleting role name: $($_.getName())")
			
			$PercentComplete	=	[int](($CurrentItem / $TotalItems) * 100)
			
			Write-Progress `
			-CurrentOperation "($i/$totalItems) Deleting role: $($_.name)" `
			-Activity "Seek&destroy - Roles" `
			-Status "$PercentComplete% Complete:" `
			-PercentComplete $PercentComplete `

			$curr_role	=	@{
				name	=	$_.name
				status	=	""
			}	
			
			$roleToDel.itimDN	=	$_.getDN()
			$curr_role.status	=	$RoleClient.deleteRole($session, $roleToDel)

			if ($v){
				if ($curr_role.status -eq 0){ Write-Host -NoNewline -fore green "Success" }
					else { Write-Host -NoNewline -fore red "Failed" }
				Write-Host "	$($curr_role.name)"
			}
			
			
		}
	}
}

function newUser{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, position=0)]
		[IM_Session] $session,
		[Parameter(Mandatory, position=1)]
		[Int] $number
	)
	$newPerson	=	[ISIM_Person]::new()
	$PersonClient	=	[ISIM_PersonClient]::getClient()
	$orgUnitClient	=	[ISIM_OrganizationalContainerClient]::getClient()

	$newPerson.profileName	=	"Person"
	$newPerson.name	=	"WS Test $number"
	$attr_list	=	@{}
	$attr_list.add("sn","Test")
	$attr_list.add("givenname","WS")
	$attr_list.add("uid","wstest_\$number")
	$attr_list.add("cn","WS Test $number")
	
	$persons	=	($PersonClient.searchPerson($Session, "(cn=*)"))
	$manager	=	$persons[0]
	$managerDN	=	$manager.itimDN
	$attr_list.add("manager", $managerDN)
	
	$OrgUnitSearchResult	=	($orgUnitClient.searchOrganizationalContainer($Session))
	$ou	=	$OrgUnitSearchResult[0]
	
	$newPerson.attributes	=	$attr_list
	$newPersonID	=	$PersonClient.createPerson($session, $newPerson, $ou)

	return $newPersonID
}

function getUserAdmin{
	$adminSession	=	getSessionAdmin
	$PersonClient	=	[ISIM_PersonClient]::getClient()
	$adminUser	=	($PersonClient.searchPerson($adminSession, "(erglobalid=00000000000000000007)"))

	return $adminUser
}

function getSessionAdmin{
	$sessionClient	=	[ISIM_SessionClient]::getClient()
	$session	=	$sessionClient.GetSession()
	
	if (-Not $session.exist){
		write_log "getSessionAdmin:	+ Login user 'admin'"
		$sessionClient.login("itim manager", "Ninguno123!")
	}

	return $session	
}

function getSession{

	$sessionClient	=	[ISIM_SessionClient]::getClient()
	$session	=	$sessionClient.GetSession()

	if (-Not $session.exist){
		write_log "getSession:	+ Login user $($GLOBAL:ISIM_WS_PROPS['ISIM_PRINCIPAL'])"
		$sessionClient.login($GLOBAL:ISIM_WS_PROPS['ISIM_PRINCIPAL'], $GLOBAL:ISIM_WS_PROPS['ISIM_SECRET'])
	}

	return $session
}

function newStaticRole{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, position=0)]
		[IM_Session] $session,
		[Parameter(Mandatory, position=1)]
		[Int] $number
	)
	$newRole	=	[IM_Role]::new()
	$RoleClient	=	[IM_RoleClient]::getClient()
	$orgUnitClient	=	[ISIM_OrganizationalContainerClient]::getClient()

	$newRole.name	=	"WS Static Test $number"
	$attr_list	=	@{}
	$attr_list.add("errolename","WS Static Test $number")
	$attr_list.add("description","wstest_\$number")
	
	$OrgUnitSearchResult	=	($orgUnitClient.searchOrganizationalContainer($Session))
	$ou	=	$OrgUnitSearchResult[0]
	
	$newRole.attributes	=	$attr_list
	$newRoleDN	=	$RoleClient.createRole($session, $newRole, $ou)

	return $newRoleDN
}

function newDynamicRole{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, position=0, ParameterSetName	=	'Role')]
		[IM_Role]$role,
		[Parameter(position=1, ParameterSetName	=	'Role')]
		[IM_Session]$session,
		[Parameter(position=2, ParameterSetName	=	'Role')]
		[ISIM_OrganizationalContainer]$container
	)
	
	if ($null -eq $session){
		$session	=	getSession
	}

	if ($null -eq $container){
		$container	=	$(getRootContainer $session)
	}
	
	$roleClient	=	[IM_RoleClient]::getClient()
	
	write_log "newDynamicRole:	+ Creating role $($role.name)"
	$newRole_requestID	=	$roleClient.createRole($session, $role, $container)

	return $newRole_requestID
}

function getRootContainer{
	[CmdletBinding()]
	param (
		[Parameter()]
		[IM_Session] $session
	)
	if ($null -eq $session){$session	=	getSession}
	$orgUnitClient	=	[ISIM_OrganizationalContainerClient]::getClient()
	$OrgUnitSearchResult	=	($orgUnitClient.searchOrganizationalContainer($Session))
	$ou	=	$OrgUnitSearchResult[0]
	
	return $ou
}

function getContainers{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, position=0)]
		[IM_Session] $session
	)
	$orgUnitClient	=	[ISIM_OrganizationalContainerClient]::getClient()
	$OrgUnitSearchResult	=	($orgUnitClient.searchOrganizationalContainer($Session))
	$ou	=	$OrgUnitSearchResult
	
	return $ou
}