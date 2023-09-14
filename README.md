# ISVG-IM-Powershell
IBM Security Verify Governance Identity Manager (frm ISIM) powershell libs

![Static Badge](https://img.shields.io/badge/status-on%20development-yellow)
![Static Badge](https://img.shields.io/badge/license-MIT-green)


##### TODO:
1. configure log levels
    - How do Levels Works?
    - A log request of level p in a logger with level q is enabled if p >= q.
	- This rule is at the heart of log4j. It assumes that levels are ordered.
	- For the standard levels, we have ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF. 
3. readme.txt	(scope|usage|error 1 by 1 on every operation)
4. session expiration time?
5. unit test exporting to csv and re-importing it to compare objects
6. ldap objects
7. import-export operation
8. replace ISIM by ISVG IM
9. utils_connections.ps: SSL checker
		- ServerCertificateValidationCallback = true
		- This property allows to run non-secure
		- Purpose:
		- If SSL not trusted, bypass it
10. verbose option

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
