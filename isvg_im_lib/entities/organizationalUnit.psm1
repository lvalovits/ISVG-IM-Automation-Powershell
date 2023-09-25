Class IM_Container{

	static $version 						=	0.2.0
	hidden static $subject 					=	"im_container"
	static $containers						=	@()

	$raw
	[string] $name
	[string] $profileName
	[string] $itimDN
	[string] $parentDN
	[string] $supervisorDN
	$children	=	@()
	$attributes	=	@{
		erglobalid				=	$null
		erorgstatus				=	$null
		objectclass				=	$null
		erparent				=	$null
		o						=	$null
		ou						=	$null
		ersupervisor			=	$null
		description				=	$null
	}

	hidden IM_Container () { throw 'Default constructor disabled. To instance a new container use [IM_Container]::new( [WSContainer] $raw_container )' }

	IM_Container ($raw_container){
		$this.raw			=	$raw_container
		$this.name			=	$raw_container.Name
		$this.profileName	=	$raw_container.ProfileName
		$this.itimDN		=	$raw_container.itimDN
		$this.parentDN		=	$raw_container.parentDN
		$this.supervisorDN	=	$raw_container.supervisorDN

		$raw_container.attributes | ForEach-Object{
			$this.attributes.$($_.name)	=	$_.values
		}

		if ($null -ne $raw_container.children.parentDN){
			$this.raw.children | ForEach-Object{
				$this.children		+=	[IM_Container]::new($_)
			}
		}

	}

}