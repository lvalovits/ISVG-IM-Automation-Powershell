Class utils_properties{

	static $version = 0.2.0
	hidden static $subject = "utils_properties"

	static $PROPERTY_FILE_PATH	=	@{
		IM		=	Convert-Path "$($GLOBAL:PWD)\im.properties"
		LIB			=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\lib.properties"
		XML_REQUEST	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\requests.properties"
		WSDL_FILES	=	Convert-Path "$($GLOBAL:PWD)\isvg_im_lib\properties\wsdl.properties"
	}

	static $PROPERTIES	=	@{
		IM		=	@{}
		LIB			=	@{}
		XML_REQUEST	=	@{}
		WSDL_FILES	=	@{}
		ENDPOINTS	=	@{}
	}

	static [void] get_property_files(){

		[utils_properties]::PROPERTY_FILE_PATH	=	@{
			IM		=	Convert-Path "$($GLOBAL:PWD)\im.properties"
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
			[utils_properties]::PROPERTIES.IM.SSL	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.IM.SSL)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.IM.SSL	=	$false
		}
	}

	static [void] set_sslskip_as_bool(){
		try {
			[utils_properties]::PROPERTIES.LIB.SSL_SKIP_VALIDATION	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.LIB.SSL_SKIP_VALIDATION)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.LIB.SSL_SKIP_VALIDATION	=	$false
		}
	}

		static [void] set_deprecatedtestconn_as_bool(){
		try {
			[utils_properties]::PROPERTIES.LIB.DEPRECATED_TESTCONNECTION	=	[System.Convert]::ToBoolean([utils_properties]::PROPERTIES.LIB.DEPRECATED_TESTCONNECTION)
		} catch [FormatException] {
			[utils_properties]::PROPERTIES.LIB.DEPRECATED_TESTCONNECTION	=	$false
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

	static [bool] _init_(){
		try{
			[utils_properties]::get_property()
			[utils_properties]::set_debug_as_bool()
			[utils_properties]::set_ssl_as_bool()
			[utils_properties]::set_sslskip_as_bool()
			[utils_properties]::set_deprecatedtestconn_as_bool()
			[utils_properties]::set_logPath_as_path()
			return $True
		}catch{
			Write-Warning "Ex.Message:	$($PSItem.exception.Message)"
			Write-Warning "$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)"
			return $False
		}
	}
}