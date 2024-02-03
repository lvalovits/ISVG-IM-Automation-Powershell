# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs for automation

![Static Badge](https://img.shields.io/badge/version-2.3.3c-green)
![GitHub top language](https://img.shields.io/github/languages/top/lvalovits/ISVG-IM-Powershell?logo=powershell)
![Static Badge](https://img.shields.io/badge/PowerShell-v5.1-blue?logo=powershell)
![GitHub](https://img.shields.io/github/license/lvalovits/ISVG-IM-Powershell)

## First things first - Why powershell?
The idea was to create something that requires no additional installations to run on any server. A scripting language was the only option.
Could it have been Java? Maybe. But at this point, PowerShell surprised me more than expected and I want to continue exploring this path.

**Free Software, Hell Yeah!**

## References:
 * philipp1184:	for his great work understanding the namespaces on New-WebServiceProxy with <Copy-ISIMObjectNamespace> and <Convert-2WSAttr> functions. Link to public repo: https://github.com/philipp1184/isim-powershell
* cazdlt:			pyisim project was a reference for much of the structure of this project. Link to public repo: https://github.com/cazdlt/pyisim

## Version History

|	Version	|	Detail																				|
|:---------:|:--------------------------------------------------------------------------------------|
|	0.x		|	Invoke-WebRequest parsing xml manually												|
|	1.x		|	New-WebServiceProxy sharing namespaces with Copy-ISIMObjectNamespace				|
|	2.x		|	Support to manage multiple endpoints removing proxy and session singleton behaviors	|
|   3.0+	|	(planned) Support for json objects													|
|   3.5+	|	(planned) Import/Export functionalities												|

## Planned Functionalities
- About IM objects:

	|	Entity			|	Search	|	Lookup	|	Add		|	Delete	|	Modify	|	Extras	|
	|:-----------------:|:---------:|:---------:|:---------:|:---------:|:---------:|:---------:|
	|	People			|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	Restore	<br>	&#9744;	Suspend	<br>	&#9744;	Transfer	<br>	&#9744;	Get roles	<br>	&#9744;	Add role	<br>	&#9744;	Remove role	<br>	&#9744;	Get accounts	|
	|	Roles	|	&#9745;	|	&#9745;	|	&#9745;	Static	<br>	&#9744;	Dynamic	|	&#9744;	|	&#9744;	Static	<br>	&#9744;	Dynamic	|	&#9744;	Get members	|
	|	Prov. Policies	|	&#9744;	|	&cross;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|
	|	Activities		|	&quest;	|	&quest;	|	&cross;	|	&cross;	|	&cross;	|	&quest;	|
	|	Org. Container	|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	Move	|
	|	Services		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	Get accounts	<br>	&#9744;	Get support data	<br>	&#9744;	Test connection	<br>	&#9744;	Enforce Policy for Service (?)	|
	|	Access			|	&quest;	|	&quest;	|	&quest;	|	&quest;	|	&quest;	|	&cross;	|
	|	Groups			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|
	|	Accounts		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	Restore	<br>	&#9744;	Suspend	<br>	&#9744;	Orphan	<br>	&#9744;	Adopt	<br>	&#9744;	Get Orphans	<br>	|

- About Use Cases:
	- [x] User Login
	- [ ] Change/Reset password
	- [ ] Resolve pending request activity
	- [ ] Simple utils to do bulk operation (role, person, service, etc)
		- [ ] Creation
		- [ ] Suspend
		- [ ] Delete
	- [ ] Import/Export operation
		- [ ] People
		- [ ] Roles
		- [ ] Policies
		- [ ] ACIs
		- [ ] Workflows/Operations
