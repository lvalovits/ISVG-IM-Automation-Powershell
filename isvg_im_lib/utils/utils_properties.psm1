$SCRIPT:PROPERTY_FILE_PATH	=	@{
	ISIM		=	Convert-Path "$PSScriptRoot\..\..\isim.properties"
	LIB			=	Convert-Path "$PSScriptRoot\..\properties\lib.properties"
	XML_REQUEST	=	Convert-Path "$PSScriptRoot\..\properties\requests.properties"
	WSDL_FILES	=	Convert-Path "$PSScriptRoot\..\properties\wsdl.properties"
}

$GLOBAL:PROPERTY_FILE	=	@{
	ISIM		=	@{}
	LIB			=	@{}
	XML_REQUEST	=	@{}
	WSDL_FILES	=	@{}
	ENDPOINTS	=	@{}
}

function read_property_files{
		
	#Check property files. If file does not exist, throw exception
	$PROPERTY_FILE_PATH.keys | ForEach-Object {
		if ($null -ne $PROPERTY_FILE_PATH[$_]){
			$PROPERTY_FILE[$_]	=	ConvertFrom-StringData ((Get-Content $PROPERTY_FILE_PATH[$_] -raw).replace("\","\\"))
		}
	}
}

function set_debug_as_bool{
	try {
		$PROPERTY_FILE.LIB.DEBUG	=	[System.Convert]::ToBoolean($PROPERTY_FILE.LIB.DEBUG)
	} catch [FormatException] {
		$PROPERTY_FILE.LIB.DEBUG	=	$false
	}
}

function set_ssl_as_bool{
	try {
		$PROPERTY_FILE.ISIM.SSL	=	[System.Convert]::ToBoolean($PROPERTY_FILE.ISIM.SSL)
	} catch [FormatException] {
		$PROPERTY_FILE.ISIM.SSL	=	$false
	}
}

function set_sslskip_as_bool{
	try {
		$PROPERTY_FILE.ISIM.SSL_SKIP_VALIDATION	=	[System.Convert]::ToBoolean($PROPERTY_FILE.ISIM.SSL_SKIP_VALIDATION)
	} catch [FormatException] {
		$PROPERTY_FILE.ISIM.SSL_SKIP_VALIDATION	=	$false
	}
}


function set_logPath_as_path{
	if (Test-Path -PathType Container -Path $PROPERTY_FILE.LIB.LOG_PATH){
		if ([System.IO.Path]::IsPathRooted($PROPERTY_FILE.LIB.LOG_PATH)){
			$PROPERTY_FILE.LIB.LOG_PATH	=	Convert-Path $PROPERTY_FILE.LIB.LOG_PATH
		}else{
			$PROPERTY_FILE.LIB.LOG_PATH	=	Convert-Path "$PSScriptRoot\..\..\$($PROPERTY_FILE.LIB.LOG_PATH)"
		}
	}else{
		Write-Warning "Log files directory not found."
	}
}

function build_endpoints(){
	$PROPERTY_FILE.ISIM.URL	=	"https://" + $PROPERTY_FILE.ISIM.ISIM_APP + ":" + $PROPERTY_FILE.ISIM.ISIM_APP_PORT
	
	$PROPERTY_FILE.WSDL_FILES.keys | ForEach-Object {
		if ($null -ne $PROPERTY_FILE.WSDL_FILES[$_]){
			$PROPERTY_FILE.ENDPOINTS[$_]	=	"$($PROPERTY_FILE.ISIM.URL)$($PROPERTY_FILE.WSDL_FILES[$_])"
		}
	}
}

function init_properties{
	read_property_files
	set_debug_as_bool
	set_ssl_as_bool
	set_sslskip_as_bool
	set_logPath_as_path
	build_endpoints
}