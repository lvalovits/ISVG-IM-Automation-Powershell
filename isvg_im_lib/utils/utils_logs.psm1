function timeStamp() { (Get-Date).toString("yyyy.MM.dd_HH.mm.ss") }

function set_log_file(){
	$GLOBAL:PROPERTY_FILE.LIB.LOG_FILE = $PROPERTY_FILE.LIB.LOG_PATH + "/" + $(timeStamp) + ".log"
}

function validate_logpath() {
	if (-not (Test-Path -PathType Container -Path $PROPERTY_FILE.LIB.LOG_PATH)){
		Write-Warning "Creating log files directory: '$($PROPERTY_FILE.LIB.LOG_PATH)' on folder $(Convert-Path $PSScriptRoot\..\..\)"
		New-Item -ItemType Directory -Path $PROPERTY_FILE.LIB.LOG_PATH > $null
		$PROPERTY_FILE.LIB.LOG_PATH = Convert-Path $PROPERTY_FILE.LIB.LOG_PATH
	}
}

function write_log(){
	[CmdletBinding()]
        param (
			[Parameter(Mandatory, position=0)]
			[ValidateSet(
				"info", "error", "warning", "debug", "trace"
			)]
            $Category,
			[Parameter(Mandatory, position=1)]
			[string]	$Message
		)

	$log_message = "$(timeStamp) - " + "[" + $category.ToUpper() + "]" + "	" + $message
	
	Add-content $PROPERTY_FILE.LIB.LOG_FILE -value $log_message
	
}


function init_logging(){
	validate_logpath
	set_log_file
	write_log -Category Info -Message "Log init complete"
}