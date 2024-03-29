class IM_Role{

	$raw
	
	[string]$name
	[string]$description
	[string]$itimDN
	
	[hashtable] $attributes	=	@{
		erglobalid				=	$null
		errolename				=	$null
		erscope					=	$null
		eraccessdescription		=	$null
		eraccessname			=	$null
		description				=	$null
		objectclass				=	$null
		erparent				=	$null
		erjavascript			=	$null
		erroleclassification	=	$null
		eraccessoption			=	$null
	}

	static $MEMBERSHIP_TYPE		=	@{
		STATIC					=	"1"
		DYNAMIC					=	"2"
	}

	static $SCOPE		=	@{
		BUSINESS_UNIT			=	"1"
		SUB_UNIT				=	"2"		
	}

	hidden IM_Role () {}

	IM_Role ( $raw_role ){
		$this.raw			=	$raw_role
		$this.name			=	$raw_role.Name
		$this.description	=	$raw_role.description
		$this.itimDN		=	$raw_role.itimDN

		$raw_role.attributes | ForEach-Object{
			$this.attributes.$($_.name)	=	$_.values
		}
	}
	
	IM_Role ( [string]$name, [string]$description ){
		$this.name							=	$name
		$this.attributes.description		=	$description
	}

	IM_Role ( [string]$name, [string]$description, [int]$scope, [string]$membership_rule ){
		$this.name							=	$name
		$this.attributes.description		=	$description
		$this.attributes.erjavascript		=	$membership_rule
		$this.attributes.erscope			=	$scope
	}

	hidden [Int] membership_type (){
		if (($null -eq $this.attributes.erjavascript) -and ($null -eq $this.attributes.erscope)){
			return 1	# static role
		}elseif((($null -ne $this.attributes.erjavascript) -and ($null -ne $this.attributes.erscope))){
			return 2	# dynamic role
		}else{
			return -1
		}
	}

	[bool] isStatic (){
		return ($this.membership_type -eq 1)
	}

	[bool] isDynamic (){
		return ($this.membership_type -eq 2)
	}

}