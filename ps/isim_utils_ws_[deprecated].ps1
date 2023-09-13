function get_header{
	[CmdletBinding()]
        param (
			[Parameter(Mandatory)]
            [string]$ContentLength
		)

		$headers = @{
			'Content-Length' = $ContentLength
			'Content-Type' = 'text/xml;charset=UTF-8'
		}

		return $headers
}

function get_RequestBody{
	[CmdletBinding()]
        param (
			[Parameter(Mandatory)]
			[ValidateSet(
				"logout",
				"searchPerson",
				"lookupOrganizationalContainer",
				"searchOrganizationalContainer",
				"createPerson",
				"deletePerson",
				"searchAssignments",
				"approveReject",
				"lookupRole",
				"searchRole",
				"createDynamicRole",
				"createStaticRole",
				"deleteRole",
				"searchProvisioningPolicies",
				"createProvisioningPolicy"
			)]
            [string]$operation
		)

	try{
		$file=@{
			logout = $GLOBAL:ISIM_WS_PROPS['WS_SESSION_LOGOUT']
			searchPerson = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_PERSON_SEARCH']
			createPerson = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_PERSON_CREATE']
			deletePerson = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_PERSON_DELETE']
			lookupOrganizationalContainer = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ORGANIZATIONALCONTAINER_LOOKUP']
			searchOrganizationalContainer = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ORGANIZATIONALCONTAINER_SEARCH']
			searchAssignments = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ASSIGMENT_SEARCH']
			approveReject = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ASSIGMENT_APPROVEREJECT']
			lookupRole = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ROLE_LOOKUP']
			searchRole = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ROLE_SEARCH']
			createDynamicRole = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ROLE_D_CREATE']
			createStaticRole = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ROLE_S_CREATE']
			deleteRole = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_ROLE_DELETE']
			searchProvisioningPolicies = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_PROVPOLICY_SEACRH']
			createProvisioningPolicy = $GLOBAL:ISIM_WS_PROPS['WS_REQUEST_PROVPOLICY_CREATE']
		}
		debugLog "get_RequestBody:	+ Reading file $($file.$operation)"
		return [xml] (Get-Content $file.$operation)
	}catch{
		Write-Host -fore red "$($Error[0])"
		Write-Host -fore red "`t$($PSItem.InvocationInfo.Scriptname.toString().split("\")[-1]): Error in code line $($PSItem.InvocationInfo.ScriptLineNumber)."
		return $null
	}
}

function Get_ChildAttributes{
	[CmdletBinding()]
        param (
			[Parameter(Mandatory)]
			$object
		)

		try{
			$object_attr = @{}

			$object.childnodes | ForEach-Object{
				$cn = $_
				$i = 0
				
				if ($cn.values.ChildNodes.count -eq 1){
					$cn_value = $cn.values.ChildNodes."#text"
				}else{
					$cn_value = @()
					$cn.values.ChildNodes | ForEach-Object {
						$cn_value += $_."#text"
					}
				}
				
				# some nodes could be unnamed so 

				if ($null -ne $cn.name){
					$object_attr.add($cn.name, $cn_value)
				}else{
					$object_attr.add("value_$i", $cn_value)
				}

				$i++

			}
			return $object_attr
		}catch{
			Write-Host -fore red "$($Error[0])"
			Write-Host -fore red "`t$($PSItem.InvocationInfo.Scriptname.toString().split("\")[-1]): Error in code line $($PSItem.InvocationInfo.ScriptLineNumber)."
		}
}

function ISIM_ObjectBuilder{
	[CmdletBinding()]
        param (
			[Parameter(Mandatory, position=0)]
			[ValidateSet(
				"ISIM_Person",
				"ISIM_OrganizationalContainer",
				"ISIM_Assignment",
				"ISIM_Role",
				"ISIM_ProvisioningPolicy",
				"Policy_Entitlement",
				"Entitlement_ServiceTarget",
				"Entitlement_Parameter"
			)]
            [String] $type,
			[Parameter(Mandatory, position=1)]
            $object
		)
		try{

			$newObject = $null

			switch ( $type ){
				"ISIM_Person" { $newObject = [ISIM_Person]::new() }
				"ISIM_OrganizationalContainer" { $newObject = [ISIM_OrganizationalContainer]::new() }
				"ISIM_Assignment" { $newObject = [ISIM_Assignment]::new() }
				default { Throw "ISIM_ObjectBuilder: Parameter set not found" }
			}

			$newObject | Get-Member -MemberType property | ForEach-Object{
				if ($_.name -ne "attributes"){
					$newObject.($_.name) = $object.($_.name)
				}
			}

			if (Get-Member -inputobject $newObject -name "attributes" -Membertype Properties){
				$object_attr = Get_ChildAttributes $object.attributes
				$newObject.attributes = $object_attr
			}

			return $newObject
			
		}catch{
			Write-Host -fore red "$($Error[0])"
			Write-Host -fore red "`t$($PSItem.InvocationInfo.Scriptname.toString().split("\")[-1]): Error in code line $($PSItem.InvocationInfo.ScriptLineNumber)."
		}
}

function xml_setupAttributes{
	[CmdletBinding()]
        param (
			[Parameter(Mandatory, position=0)]
            $isim_object,

			[Parameter(Mandatory, position=1)]
			$xml_object

		)

	while ($isim_object.attributes.Count -ne $xml_object.attributes.ChildNodes.Count){
		$attrNodeNew = $xml_object.attributes.ChildNodes[0].Clone()
		$xml_object.attributes.AppendChild($attrNodeNew) > $null
	}

	#set node names
	$i = 0
	$personAttributesNames = @()
	

	foreach ($key in $isim_object.attributes.Keys) {
		$personAttributesNames += $key
	}

	$xml_object.attributes.ChildNodes | ForEach-Object{

		$curr_node = $_
		$curr_node.name = $personAttributesNames[$i]
		
		#if single-value
		if ($isim_object.attributes.($personAttributesNames[$i]).count -eq 1){
			$curr_node.values.ChildNodes[0].'#text' = $isim_object.attributes.($personAttributesNames[$i])
		}
		
		#if multi-value
		else{
			if ($isim_object.attributes.($personAttributesNames[$i]).count -gt 1){
				
				#new value nodes
				while ($isim_object.attributes.($personAttributesNames[$i]).count -ne $curr_node.ChildNodes[1].ChildNodes.Count){
					$valueNodeNew = $curr_node.ChildNodes[1].ChildNodes[0].Clone()
					$curr_node.ChildNodes[1].AppendChild($valueNodeNew) > $null
				}
				
				$k = 0
				
				$isim_object.attributes.($personAttributesNames[$i]) | ForEach-Object{
					$curr_node.values.ChildNodes[$k].'#text' = $isim_object.attributes.($personAttributesNames[$i])[$k]
					$k++
				}

			}
		
		#if empty-value
			else{
				Write-Host "Empty attribute: " $personAttributesNames[$i]
			}
		}

		$i++
	}

	return $xml_object
}

function is_dynamicRole{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, position=0)]
		[ISIM_Role] $role
	)

	try{
		
		return $role.attributes.Contains("erscope")
			
	}catch{
		Write-Host -fore red "$($Error[0])"
		Write-Host -fore red "`t$($PSItem.InvocationInfo.Scriptname.toString().split("\")[-1]): Error in code line $($PSItem.InvocationInfo.ScriptLineNumber)."
	}

}



function wsParseError($ws_error){
	return ([xml]$ws_error.ErrorDetails).Envelope.Body.Fault.faultstring
}

function callWS($m, $uri, $h, $b){

	[boolean]$keepAlive = [System.Convert]::ToBoolean($GLOBAL:ISIM_WS_PROPS['KEEP_ALIVE'])
	
	$requestXML = [System.Xml.Linq.XElement]::Parse( $b.OuterXml ).ToString()

	debugLog "callWS:	+ request xml`r`n$($requestXML)"

	if ($keepAlive){
		debugLog "callWS:	++ keepAlive=true"
		$rsp = (Invoke-WebRequest -Method $m -Uri $uri -Headers $h -Body $b)
	}else{
		debugLog "callWS:	++ keepAlive=false"
		$rsp = (Invoke-WebRequest -DisableKeepAlive -Method $m -Uri $uri -Headers $h -Body $b)
		$rsp.BaseResponse.close()
	}

	debugLog "callWS:	+ response xml`r`n$($rsp)"
	return $rsp

}