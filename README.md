# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs for automation

![Static Badge](https://img.shields.io/badge/version-2.3.1-green)
![Static Badge](https://img.shields.io/badge/status-on%20development-black)
![GitHub top language](https://img.shields.io/github/languages/top/lvalovits/ISVG-IM-Powershell?logo=powershell)
![Static Badge](https://img.shields.io/badge/PowerShell-v5.1-blue?logo=powershell)
![Visual Studio Marketplace Version (including pre-releases)](https://img.shields.io/visual-studio-marketplace/v/ms-vscode.powershell?logo=visualstudiocode)
![GitHub](https://img.shields.io/github/license/lvalovits/ISVG-IM-Powershell)

## References:
 * philipp1184:	for his great work understanding the namespaces on New-WebServiceProxy with <Copy-ISIMObjectNamespace> and <Convert-2WSAttr> functions. Link to public repo: https://github.com/philipp1184/isim-powershell
* cazdlt:			pyisim project was a reference for much of the structure of this project. Link to public repo: https://github.com/cazdlt/pyisim
* guitarrapc:		for singleton powershell implementation. Link to public gist: https://gist.github.com/guitarrapc/2fde990d166286459c309b7cab03938b

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

	|	Entity			|	Search	|	Lookup	|	Add	|	Delete	|	Suspend	|	Restore	|	Modify	|
	|:-----------------:|:---------:|:---------:|:-----:|:---------:|:---------:|:---------:|:---------:|
	|	People			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|
	|	Dynamic Roles	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Static Roles	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Prov. Policies	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Activities		|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	|	&cross;	|	&cross;	| &cross;	|
	|	Org. Container	|	&#9745;	|	&#9745;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Services		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Access			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Groups			|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&cross;	|	&cross;	| &#9744;	|
	|	Accounts		|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	|	&#9744;	| &#9744;	|

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

### TODO:
- organize TODOs
- configure log levels
    - How do Levels Works?
    	- A log request of level p in a logger with level q is enabled if p >= q.
		- This rule is at the heart of log4j. It assumes that levels are ordered.
		- For the standard levels, we have ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF. 
- readme.txt	(scope|usage|error 1 by 1 on every operation)
- session expiration time?
- ldap objects?
- import-export operation (json object please!!!)
	- the singleton eliminates the possibility of working with 2 different environments (e.g. auto export->import)
	- unit test exporting to ~~csv~~ JSON (!) and re-importing it to compare objects
- ~~replace ISIM by ISVG IM~~
- endpoints.psm1: SSL checker
	- Test ICMP - add property to force IPv4 or IPv6
	- Test self-signed certs
	- ~~Add support for others security protocols (property files)~~
	- ~~ServerCertificateValidationCallback	=	true~~
		- ~~This property allows to run non-secure without any kind of validation~~
		- ~~Purpose:~~
		    - ~~If SSL, bypass it~~
- [utils_properties]::build_endpoints: validate ip_or_hostname input
- error handlers
	- Maybe a method/function to avoid repeat the same 5 catch lines?
	- [utils_properties]
	- [utils_log]
	- [utils_connections]
	- [utils_proxy_wrapper]
- Structural definitions
	- ~~Should endpoints have a proxy_list? Gonna think it in the future (my_endpoint.proxy_list.session , my_endpoint.proxy_list.roles , my_endpoint.proxy_list.person).~~ NO.
