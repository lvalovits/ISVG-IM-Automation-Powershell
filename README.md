# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs

![Static Badge](https://img.shields.io/badge/status-on%20development-yellow)
![GitHub top language](https://img.shields.io/github/languages/top/lvalovits/ISVG-IM-Powershell?logo=powershell)
![Static Badge](https://img.shields.io/badge/PowerShell-v5.1-blue?logo=powershell)
![Visual Studio Marketplace Version (including pre-releases)](https://img.shields.io/visual-studio-marketplace/v/ms-vscode.powershell?logo=visualstudiocode)
![GitHub](https://img.shields.io/github/license/lvalovits/ISVG-IM-Powershell)



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
- replace ISIM by ISVG IM
- utils_connections.ps: SSL checker
	- Test self-signed certs
	- Add support for others security protocols (property files)
	- ~~ServerCertificateValidationCallback	=	true~~
		- ~~This property allows to run non-secure without any kind of validation~~
		- ~~Purpose:~~
		    - ~~If SSL, bypass it~~
- verbose option

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
