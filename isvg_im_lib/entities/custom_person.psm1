using module "..\entities\person.psm1"

class IM_Custom_Person : IM_Person{

	$custom_attributes	=	@{
		ercustom1		=	$null
		ercustom2		=	$null
		ercustom3		=	$null
		ercustom4		=	$null
		ercustom5		=	$null
	}

	hidden IM_Custom_Person () {
		$this.attributes	=	$this.custom_attributes
	}

}