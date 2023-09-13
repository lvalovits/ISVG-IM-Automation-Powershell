#
#	usage:
#		[ISIM_Session]::GetSession()
#

Class ISIM_Session{

	################# Singleton start #################
	hidden static [ISIM_Session] $_instance		=	[ISIM_Session]::new()

	hidden ISIM_Session() {}

	static [ISIM_Session] GetSession() {
		return [ISIM_Session]::_instance
	}
	################## Singleton end ##################

	$raw
	$sessionID								=	$null
	$clientSession							=	$null
	$enforceChallengeResponse				=	$null
	$locale = @{
		country								=	$null
		variant								=	$null
		language							=	$null
	}

	[void] clean(){
		$this.raw							=	$null
		$this.clientSession					=	$null
		$this.sessionID						=	$null
		$this.enforceChallengeResponse		=	$null
		$this.locale | ForEach-Object{ $_	=	$null }
	}

	[bool] isEmpty(){
		return (( $null -eq $this.clientSession ) -or ( $null -eq $this.sessionID ) -or ( "" -eq $this.clientSession ) -or ( "" -eq $this.sessionID ))
	}
}