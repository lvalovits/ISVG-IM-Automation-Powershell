using module "..\utils\utils_logs.psm1"

function Copy-ISIMObjectNamespace {
    <#
    .SYNOPSIS
        Helper Function to create WS Objects for the different WebServices
    .DESCRIPTION
        ISIM provided individual WebServices for Roles, Person, Session etc. Powershell with it´s New-WebServiceProxy
        Function will append Namespaces for each Service. This makes the objects inoperable between the other Services.
        To overcome this issue this Helper Function will copy an existing WS Object to another Namespace.
    .PARAMETER obj
        The Source Object which have to be copied
    .PARAMETER targetNS
        The Target Namespace for the new Object
    .OUTPUTS
        A Copy of the Object in Parameter obj with the Namespace as in Parameter targetNS
    #>
    param(
        [Parameter(Mandatory=$true)]
        $obj,
	    [Parameter(Mandatory=$true)]
	    [string]$targetNS
    )    

    $myTypeName	=	$obj.getType().Name.Split("[")[0];

    if( $obj.getType().BaseType.Name -eq "Array" ) {
        $tmp_array	=	@();
        
        $obj | ForEach-Object {
            $tmp1	=	Copy-ISIMObjectNamespace $_ $targetNS;
            $tmp_array += $tmp1;
        }

        return $tmp_array;

    } 

    $newObj	=	New-Object ( $targetNS+"."+$myTypeName)

    $obj.psobject.Properties | ForEach-Object {
        $pname	=	$_.Name
        if ( $_.TypeNameOfValue.StartsWith("System.") ) {
            if( $null -ne $newObj.psobject.Properties.Item($pname) ) {
                $newObj.$pname	=	$_.Value
            } else {
                Write-Host -ForegroundColor Yellow "Property $pname Could not be set"
            }
        } else {
            if ( !$newObj.$pname ) {
                $newObj.$pname	=	New-Object ( $targetNS+"."+($_.TypeNameOfValue.Split(".")[-1].Split("[")[0]))
            }
            # ISSUE #2:    $obj is null when converting container raw from role_proxy
            # Detail:   Once pname = "children" cannot keep looping correctly. Somewhere $obj is null
            # TODO:     Keep an eye on this funtion to avoid new errors due to this IF
            if ($pname -ne "children"){
                $newObj.$pname	=	Copy-ISIMObjectNamespace $obj.$pname $targetNS
            }else{
                Write-Warning "Children property skipped"
            }
    }
}
return $newObj
}

function Convert-2WSAttr {
    <#
    .SYNOPSIS
        Helper Function to manage WSAttr with Hash Tables
    .DESCRIPTION
        Helper Function to manage WSAttr with Hash Tables. Will generate an WSAttr Object by adding Values from a Hash Table.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$hash,
        [Parameter(Mandatory=$true)]
        [string]$namespace,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $inAttr
    )
    process {
        if ( $null -NE $inAttr ) {
            $wsattr_array	=	$inAttr;

            $hash.GetEnumerator() | ForEach-Object{
                if ( $null -ne $_.value ){
                    $prop_name	=	$_.name;
                    $prop_value	=	$_.value;

                    if ( ( $wsattr_array | Where-Object { $_.name -eq $prop_name } ).Count -eq 1 ) {
                        ( $wsattr_array | Where-Object { $_.name -eq $prop_name } ).values	=	$prop_value
                    } else {
                        $wsattr	=	New-Object ($namespace+".WSAttribute")
                        $wsattr.name	=	$prop_name
                        $wsattr.values +=  $prop_value
                        $wsattr_array += $wsattr
                    }
                }
            }

        } else {
            $wsattr_array	=	@();
            $hash.GetEnumerator() | ForEach-Object{
                if ( $null -ne $_.value ){
                    $wsattr	=	New-Object ($namespace+".WSAttribute")
                    $wsattr.name	=	$_.name
                    $wsattr.values +=  $_.value
                    $wsattr_array += $wsattr
                }
            }
        }
        return $wsattr_array;
    }

}

function Convert-2WSObject {
    <#
    .SYNOPSIS
        Helper Function to manage WSObject with Custom ISIM objects
    .DESCRIPTION
        Helper Function to manage WSAttr with Custom ISIM objects. Will generate an WS Object by adding Values from a ISIM objects.
    #>
    [CmdletBinding()]
    [OutputType([psObject])]
    param (
        [Parameter(Mandatory=$true)]
        [psObject]$isim_object,
        [Parameter(Mandatory=$true)]
        [psObject]$wsStub
    )

    # Remove empty attributes
    @($isim_object.attributes.keys) | ForEach-Object { if (-not $isim_object.attributes[$_]) { $isim_object.attributes.Remove($_) } }
    
    # Clone isim_object to a WSObject
    $isim_object_props         	=	  $isim_object | Get-Member | Where-Object{ ( $_.membertype -eq "Property" )}

    $isim_object_props | ForEach-Object {
        if (( $_.Name.ToLower() -ne "attributes" ) -and ( $_.Name.ToLower() -ne "raw" )){
            if ( $null -ne $isim_object.$($_.name) ){
                $wsStub.$($_.name) 	=	  ($isim_object.$($_.name)).Clone()
            }
        }
        if ( $_.Name.ToLower() -eq "attributes" ) {
            $wsStub.attributes 	=	  Convert-2WSAttr -hash $isim_object.attributes -namespace $wsStub.GetType().Namespace
        }
    }
    return $wsStub
}

function Convert-Hash2WSAttr {
    <#
    .SYNOPSIS
        Helper Function to manage WSAttr with Hash Tables
    .DESCRIPTION
        Helper Function to manage WSAttr with Hash Tables. Will generate an WSAttr Object by adding Values from a Hash Table.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$hash,
        [Parameter(Mandatory=$true)]
        [string]$namespace,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $inAttr
    )
    process {


        if ( $null -NE $inAttr ) {
            $wsattr_array = $inAttr;

            $hash.GetEnumerator() | ForEach-Object{
                $prop_name = $_.name;
                $prop_value = $_.value;

	            if ( ( $wsattr_array | Where-Object { $_.name -eq $prop_name }).Count -eq 1 ) {
		            ( $wsattr_array | Where-Object { $_.name -eq $prop_name }).values = $prop_value
	            } else {
                    $wsattr = New-Object ($namespace+".WSAttribute")
                    $wsattr.name = $prop_name
                    $wsattr.values +=  $prop_value
                    $wsattr_array += $wsattr
                }

            }

        } else {
            $wsattr_array = @();
            $hash.GetEnumerator() | ForEach-Object{
                $wsattr = New-Object ($namespace+".WSAttribute")
                $wsattr.name = $_.name
                $wsattr.values +=  $_.value
                $wsattr_array += $wsattr
            }
        }



        return $wsattr_array;
    }
}



function to_WSObject() {
		
}