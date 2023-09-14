$SCRIPT:PROPERTY_FILE_PATH = @{
	ISIM		=	Convert-Path "$PSScriptRoot\..\..\isim.properties"
	LIB			=	Convert-Path "$PSScriptRoot\..\properties\lib.properties"
	XML_REQUEST	=	Convert-Path "$PSScriptRoot\..\properties\requests.properties"
	WSDL		=	Convert-Path "$PSScriptRoot\..\properties\wsdl.properties"
}

$GLOBAL:PROPERTY_FILE = @{
	ISIM		=	""
	LIB			=	""
	XML_REQUEST	=	""
	WSDL		=	""
}

function read_property_files{
		
	#Check property files. If file does not exist, throw exception
	$PROPERTY_FILE_PATH.keys | ForEach-Object {
		if ($null -ne $PROPERTY_FILE_PATH[$_]){
			$GLOBAL:PROPERTY_FILE[$_] = ConvertFrom-StringData ((Get-Content $PROPERTY_FILE_PATH[$_] -raw).replace("\","\\"))
		}
	}
}

function set_debug_as_bool{
	try {
		$Global:PROPERTY_FILE.LIB.DEBUG = [System.Convert]::ToBoolean($Global:PROPERTY_FILE.LIB.DEBUG)
	} catch [FormatException] {
		$Global:PROPERTY_FILE.LIB.DEBUG = $false
	}
}

function set_ssl_as_bool{
	try {
		$Global:PROPERTY_FILE.ISIM.SSL = [System.Convert]::ToBoolean($Global:PROPERTY_FILE.ISIM.SSL)
	} catch [FormatException] {
		$Global:PROPERTY_FILE.ISIM.SSL = $false
	}
}

function set_logPath_as_path{
	if (Test-Path -PathType Container -Path $PROPERTY_FILE.LIB.LOG_PATH){
		if ([System.IO.Path]::IsPathRooted($PROPERTY_FILE.LIB.LOG_PATH)){
			$PROPERTY_FILE.LIB.LOG_PATH = Convert-Path $PROPERTY_FILE.LIB.LOG_PATH
		}else{
			$PROPERTY_FILE.LIB.LOG_PATH = Convert-Path "$PSScriptRoot\..\..\$($PROPERTY_FILE.LIB.LOG_PATH)"
		}
	}else{
		Write-Warning "Log files directory not found."
	}
}

function build_urls(){
	$GLOBAL:PROPERTY_FILE.ISIM.URL				=	"https://" + $GLOBAL:PROPERTY_FILE.ISIM.ISIM_APP + ":" + $GLOBAL:PROPERTY_FILE.ISIM.ISIM_APP_PORT
	
	$GLOBAL:PROPERTY_FILE.WSDL.keys | ForEach-Object {
		if ($null -ne $GLOBAL:PROPERTY_FILE.WSDL[$_]){
			$url =  "$($GLOBAL:PROPERTY_FILE.ISIM.URL)$($GLOBAL:PROPERTY_FILE.WSDL[$_])"
			Write-Output $GLOBAL:PROPERTY_FILE.WSDL[$_]
			Write-Output $url
			$GLOBAL:PROPERTY_FILE.WSDL.URL[$_] = $url
		}
	}
}

function init_properties{
	read_property_files
	set_debug_as_bool
	set_ssl_as_bool
	set_logPath_as_path
	build_urls
}