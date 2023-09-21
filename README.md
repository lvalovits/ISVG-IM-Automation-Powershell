# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs for automation

![Static Badge](https://img.shields.io/badge/status-on%20development-yellow)
![GitHub top language](https://img.shields.io/github/languages/top/lvalovits/ISVG-IM-Powershell?logo=powershell)
![Static Badge](https://img.shields.io/badge/PowerShell-v5.1-blue?logo=powershell)
![Visual Studio Marketplace Version (including pre-releases)](https://img.shields.io/visual-studio-marketplace/v/ms-vscode.powershell?logo=visualstudiocode)
![GitHub](https://img.shields.io/github/license/lvalovits/ISVG-IM-Powershell)

##### References:
 * philipp1184:	for his great work understanding the namespaces on New-WebServiceProxy with <Copy-ISIMObjectNamespace> and <Convert-2WSAttr> functions. Link to public repo: https://github.com/philipp1184/isim-powershell
* cazdlt:			pyisim project was a reference for much of the structure of this project. Link to public repo: https://github.com/cazdlt/pyisim
* guitarrapc:		for singleton powershell implementation. Link to public gist: https://gist.github.com/guitarrapc/2fde990d166286459c309b7cab03938b

##### TODO:
- configure log levels
    - How do Levels Works?
    	- A log request of level p in a logger with level q is enabled if p >= q.
		- This rule is at the heart of log4j. It assumes that levels are ordered.
		- For the standard levels, we have ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF. 
- readme.txt	(scope|usage|error 1 by 1 on every operation)
- session expiration time?
- unit test exporting to csv and re-importing it to compare objects
- ldap objects
- import-export operation
	- the singleton eliminates the possibility of working with 2 different environments (e.g. auto export->import)
- replace ISIM by ISVG IM
- utils_connections.ps: SSL checker
	- Test self-signed certs
	- Add support for others security protocols (property files)
	- ~~ServerCertificateValidationCallback	=	true~~
		- ~~This property allows to run non-secure without any kind of validation~~
		- ~~Purpose:~~
		    - ~~If SSL, bypass it~~
- verbose option
- [utils_properties]::build_endpoints: validate ip_or_hostname input
- error handlers
	- [utils_properties]
	- [utils_log]
	- [utils_connections]
	- [utils_proxy_wrapper]


##### Functionalities

|	Entity			|	Search	|	Lookup	|	Add	|	Delete	|	Suspend	|	Restore	|	Modify	|
|:-----------------:|:---------:|:---------:|:-----:|:---------:|:---------:|:---------:|:---------:|
|	People			|			|			|		|			|			|			|			|
|	Dynamic Roles	|			|			|		|			|			|			|			|
|	Static Roles	|			|			|		|			|			|			|			|
|	Prov. Policies	|			|			|		|			|			|			|			|
|	Activities		|			|			|		|			|			|			|			|
|	Org. Container	|			|			|		|			|			|			|			|
|	Services		|			|			|		|			|			|			|			|
|	Access			|			|			|		|			|			|			|			|
|	Groups			|			|			|		|			|			|			|			|
|	Accounts		|			|			|		|			|			|			|			|
