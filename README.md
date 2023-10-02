# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs for automation

![Static Badge](https://img.shields.io/badge/version-2.3.3c-green)
![Static Badge](https://img.shields.io/badge/status-on%20development-yellowgreen)
![GitHub top language](https://img.shields.io/github/languages/top/lvalovits/ISVG-IM-Powershell?logo=powershell)
![Static Badge](https://img.shields.io/badge/PowerShell-v5.1-blue?logo=powershell)
![Visual Studio Marketplace Version (including pre-releases)](https://img.shields.io/visual-studio-marketplace/v/ms-vscode.powershell?logo=visualstudiocode)
![GitHub](https://img.shields.io/github/license/lvalovits/ISVG-IM-Powershell)

## References:
 * philipp1184:	for his great work understanding the namespaces on New-WebServiceProxy with <Copy-ISIMObjectNamespace> and <Convert-2WSAttr> functions. Link to public repo: https://github.com/philipp1184/isim-powershell
* cazdlt:			pyisim project was a reference for much of the structure of this project. Link to public repo: https://github.com/cazdlt/pyisim

## Version History

|	Version	|	Detail																				|
|:---------:|:--------------------------------------------------------------------------------------|
|	0.x		|	Invoke-WebRequest parsing xml manually												|
|	1.x		|	New-WebServiceProxy sharing namespaces with Copy-ISIMObjectNamespace				|
|	2.x		|	Support to manage multiple endpoints removing proxy and session singleton behaviors	|
|   2.5+	|	(planned) Support for json objects													|
|   3.0+	|	(planned) Import/Export functionalities												|

**Free Software, Hell Yeah!**

## Planned Functionalities
- About IM objects:

	|	Entity			|	Search	|	Lookup	|	Add		|	Delete	|	Suspend	|	Restore	|	Modify	|
	|:-----------------:|:---------:|:---------:|:---------:|:---------:|:---------:|:---------:|:---------:|
	|	People			|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|
	|	Dynamic Roles	|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Static Roles	|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Prov. Policies	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Activities		|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&cross;	|	&cross;	|	&cross;	|
	|	Org. Container	|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Services		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Access			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Groups			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&#9744;	|
	|	Accounts		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|

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
