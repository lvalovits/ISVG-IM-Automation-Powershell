#
#	usage:
#		[IM_Session]::GetSession()
#

Class IM_Session{

	################# Singleton start #################
	# hidden static [IM_Session] $_instance		=	[IM_Session]::new()
	# hidden IM_Session() {}
	# static [IM_Session] GetSession() { return [IM_Session]::_instance }
	################## Singleton end ##################


	static $version 						=	0.2.0
	hidden static $subject 					=	"im_session"
	static $sessions						=	@()

	$raw									=	$null
	$sessionID								=	$null
	$clientSession							=	$null
	$enforceChallengeResponse				=	$null
	$locale	=	@{
		country								=	$null
		variant								=	$null
		language							=	$null
	}

	IM_Session() {
		[IM_Session]::sessions				+=	$this
	}

	[bool] isEmpty(){
		return (( $null -eq $this.clientSession ) -or ( $null -eq $this.sessionID ) -or ( "" -eq $this.clientSession ) -or ( "" -eq $this.sessionID ))
	}
}