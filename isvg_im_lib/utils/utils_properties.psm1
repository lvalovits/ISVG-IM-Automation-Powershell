Class utils_properties{

	static $version = 0.1.5
	hidden static $subject = "utils_properties"

	static $PROPERTY_FILE_PATH	=	@{
		ISIM		=	Convert-Path "$($GLOBAL:PWD)\isim.properties"
		LIB			=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\lib.properties"
		XML_REQUEST	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\requests.properties"
		WSDL_FILES	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\wsdl.properties"
	}

	static $PROPERTIES	=	@{
		ISIM		=	@{}
		LIB			=	@{}
		XML_REQUEST	=	@{}
		WSDL_FILES	=	@{}
		ENDPOINTS	=	@{}
	}

	static [void] get_property_files(){

		[utils_properties]::PROPERTY_FILE_PATH	=	@{
			ISIM		=	Convert-Path "$($GLOBAL:PWD)\isim.properties"
			LIB			=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\lib.properties"
			XML_REQUEST	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\requests.properties"
			WSDL_FILES	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\wsdl.properties"
		}
	}

	static [void] get_property(){
		[utils_properties]::PROPERTY_FILE_PATH.keys | ForEach-Object {
			if ($null -ne [utils_properties]::PROPERTY_FILE_PATH[$_]){
				[utils_properties]::PROPERTIES[$_]	=	ConvertFrom-StringData ((Get-Content ([utils_properties]::PROPERTY_FILE_PATH[$_]) -raw).replace("\","\\"))
			}
		}
	}

	static [void] set_debug_as_bool(){
		try {
			[utils_properties]::PROPERTIES.LIB.DEBUG	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.LIB.DEBUG)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.LIB.DEBUG	=	$false
		}
	}

	static [void] set_ssl_as_bool(){
		try {
			[utils_properties]::PROPERTIES.ISIM.SSL	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.ISIM.SSL)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.ISIM.SSL	=	$false
		}
	}

	static [void] set_sslskip_as_bool(){
		try {
			[utils_properties]::PROPERTIES.ISIM.SSL_SKIP_VALIDATION	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.ISIM.SSL_SKIP_VALIDATION)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.ISIM.SSL_SKIP_VALIDATION	=	$false
		}
	}


	static [void] set_logPath_as_path(){
		if (Test-Path -PathType Container -Path ([utils_properties]::PROPERTIES.LIB.LOG_PATH)){
			if ([System.IO.Path]::IsPathRooted([utils_properties]::PROPERTIES.LIB.LOG_PATH)){
				[utils_properties]::PROPERTIES.LIB.LOG_PATH	=	Convert-Path ([utils_properties]::PROPERTIES.LIB.LOG_PATH)
			}else{
				[utils_properties]::PROPERTIES.LIB.LOG_PATH	=	Convert-Path "$($GLOBAL:PWD)\$([utils_properties]::PROPERTIES.LIB.LOG_PATH)"
			}
		}else{
			Write-Warning "Log files directory not found."
		}
	}
	
	static [void] build_endpoints(){
		[utils_properties]::PROPERTIES.ISIM.URL	=	"https://" + [utils_properties]::PROPERTIES.ISIM.APP_HOST + ":" + [utils_properties]::PROPERTIES.ISIM.APP_PORT
		
		[utils_properties]::PROPERTIES.WSDL_FILES.keys | ForEach-Object {
			if ($null -ne [utils_properties]::PROPERTIES.WSDL_FILES[$_]){
				[utils_properties]::PROPERTIES.ENDPOINTS[$_]	=	"$([utils_properties]::PROPERTIES.ISIM.URL)$([utils_properties]::PROPERTIES.WSDL_FILES[$_])"
			}else{
				write_log error "Endpoint not found: $($_)" 
			}
		}
	}

	static [void] build_endpoints([string]$IP_OR_HOSTNAME, [int]$PORT){

		[utils_properties]::PROPERTIES.ISIM.URL	=	"https://" + $IP_OR_HOSTNAME + ":" + $PORT
		
		[utils_properties]::PROPERTIES.WSDL_FILES.keys | ForEach-Object {
			if ($null -ne [utils_properties]::PROPERTIES.WSDL_FILES[$_]){
				[utils_properties]::PROPERTIES.ENDPOINTS[$_]	=	"$([utils_properties]::PROPERTIES.ISIM.URL)$([utils_properties]::PROPERTIES.WSDL_FILES[$_])"
			}
		}
	}

	# Commented because string[] handle both scenarios (string & string[])

		# static [void] build_endpoints([string]$IP_OR_HOSTNAME, [int]$PORT, [string]$ENDPOINT_NAME){
		# 	[utils_properties]::PROPERTIES.ISIM.URL	=	"https://" + $IP_OR_HOSTNAME + ":" + $PORT
			
		# 	if ($null -ne [utils_properties]::PROPERTIES.WSDL_FILES[$ENDPOINT_NAME]){
		# 		[utils_properties]::PROPERTIES.ENDPOINTS[$ENDPOINT_NAME]	=	"$([utils_properties]::PROPERTIES.ISIM.URL)$([utils_properties]::PROPERTIES.WSDL_FILES[$ENDPOINT_NAME])"
		# 	}else{
		# 		$exceptionMessage = "Endpoint not found: $($ENDPOINT_NAME)" 
		# 		write_log "error" "$([utils_properties]::subject):	+ $($exceptionMessage)"
		# 	}
			
		# }

	static [void] build_endpoints([string]$IP_OR_HOSTNAME, [int]$PORT, [string[]]$ENDPOINT_NAME_LIST){
		[utils_properties]::PROPERTIES.ISIM.URL	=	"https://" + $IP_OR_HOSTNAME + ":" + $PORT
		$ENDPOINT_NAME_LIST | ForEach-Object {
			if ($null -ne [utils_properties]::PROPERTIES.WSDL_FILES[$_]){
				[utils_properties]::PROPERTIES.ENDPOINTS[$_]	=	"$([utils_properties]::PROPERTIES.ISIM.URL)$([utils_properties]::PROPERTIES.WSDL_FILES[$_])"
			}else{
				write_log error "Endpoint not found: $($_)" 
			}
		}
	}

	static [void] _init_(){
		[utils_properties]::get_property()
		[utils_properties]::set_debug_as_bool()
		[utils_properties]::set_ssl_as_bool()
		[utils_properties]::set_sslskip_as_bool()
		[utils_properties]::set_logPath_as_path()
		[utils_properties]::build_endpoints()
	}
}