#
#	usage:
#		[IM_Session]::GetSession()
#

Class IM_Session{

	################# Singleton start #################
	hidden static [IM_Session] $_instance		=	[IM_Session]::new()
	hidden IM_Session() {}
	static [IM_Session] GetSession() { return [IM_Session]::_instance }
	################## Singleton end ##################

	$raw
	$sessionID								=	$null
	$clientSession							=	$null
	$enforceChallengeResponse				=	$null
	$locale	=	@{
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