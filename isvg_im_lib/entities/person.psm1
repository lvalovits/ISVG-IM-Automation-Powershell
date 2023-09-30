class IM_Person{

	$raw
	
	[string]$name
	[string]$profileName
	[string]$itimDN
	$attributes = @{}
	# $attributes	=	@{
	# 	ercustomdisplay		=	$null
	# 	erglobalid			=	$null
	# 	erpswdlastchanged	=	$null
	# 	erroles				=	$null
	# 	erpersonstatus		=	$null
	# 	cn					=	$null
	# 	objectclass			=	$null
	# 	ersynchpassword		=	$null
	# 	uid					=	$null
	# 	givenname			=	$null
	# 	sn					=	$null
	# 	erparent			=	$null
	# 	erlastmodifiedtime	=	$null
	# }

	hidden IM_Person () {}

	IM_Person ( $raw_person ){
		$this.raw			=	$raw_person
		$this.name			=	$raw_person.Name
		$this.profileName	=	$raw_person.profileName
		$this.itimDN		=	$raw_person.itimDN

		$raw_person.attributes | ForEach-Object{
			# $this.attributes.$($_.name)	=	$_.values
			$this.attributes.Add($_.name , $_.values)
		}
	}

	[bool] isEnabled(){
		return -not([System.Convert]::ToBoolean($this.attributes.erpersonstatus))
	}

}