using module ".\utils_properties.psm1"
using module "..\enums\log_category.psm1"

Class utils_logs{

	static $version = 0.2.1
	hidden static $subject = "utils_logs"

	static [string] timeStamp() { return (Get-Date).toString("yyyy.MM.dd_HH.mm.ss") }

	static [void] set_log_file(){
		[utils_properties]::PROPERTIES.LIB.LOG_FILE	=	([utils_properties]::PROPERTIES.LIB.LOG_PATH) + '\' + $([utils_logs]::timeStamp()) + ".log"
	}

	static [void] validate_logpath() {
		if (-not (Test-Path -PathType Container -Path ([utils_properties]::PROPERTIES.LIB.LOG_PATH))){
			Write-Warning "Creating log files directory: '$([utils_properties]::PROPERTIES.LIB.LOG_PATH)' on folder $(Convert-Path $($GLOBAL:PWD))"
			New-Item -ItemType Directory -Path ([utils_properties]::PROPERTIES.LIB.LOG_PATH) > $null
			[utils_properties]::PROPERTIES.LIB.LOG_PATH	=	Convert-Path ([utils_properties]::PROPERTIES.LIB.LOG_PATH)
		}
	}

	static [void] write_log([string] $Category, [string]	$Message){
		$log_message	=	"$([utils_logs]::timeStamp())	" + "[" + $category.ToUpper() + "]" + "	" + $message
		Add-content ([utils_properties]::PROPERTIES.LIB.LOG_FILE) -value $log_message
	}


	static [bool] _init_(){
		try{
			[utils_logs]::validate_logpath()
			[utils_logs]::set_log_file()
			[utils_logs]::write_log([LOG_CATEGORY]::INF, "Log init completed")
			return $True
		}catch{
			Write-Warning "Ex.Message:	$($PSItem.exception.Message)"
			Write-Warning "$($PSItem.InvocationInfo.Scriptname.toString().split('\')[-1]):$($PSItem.InvocationInfo.ScriptLineNumber)"
			return $False
		}
	}
}