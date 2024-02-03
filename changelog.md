# v3.0.0
##### Added
- **Examples**
	- new function `Test-ExportToJSON` to save roles as .json file
	- new function `Test-ImportToJSON` to load roles from .json file
##### Changed
- N/A
##### Removed
- N/A


# v2.3.4
##### Added
- **IM Role Proxy**
	- new method `createStaticRole (session, container, role)`
- **IM Role Class**
	- new method `isDynamic`
	- new method `isStatic`
- **Examples**
	- new function `Test-MigrateRoles` to test migration scenario
##### Changed
- **Examples**
	- new funcionts to test `createStaticRole` method
	- `Test-GetOrganization` splitted into 2 functions: `Test-GetOrganization` and `Test-GetRootOrganizations`
- **Utils**
	- `utils_proxy_wrapper` renamed to `utils_proxy` and imported on proxies loads
- **IM Object Class**
	- Class renamed. Still not sure if it gonna be useful. Keeping it just in case
- **IM Role Class**
	- method `membership_type` changed to hidden
##### Removed
- N/A


# v2.3.3
##### Added
- **IM Person Proxy**
	- new proxy to handle person operation
	- new method `searchPersonFromRoot (session)`
	- new method `searchPersonFromRoot (session, filter)`
	- new method `lookupPerson (session, dn)`
	- new entity object `IM_Person`
##### Changed
- **Examples**
	- new funcionts to test `searchPersonFromRoot` and `lookupPerson` methods
##### Removed
- N/A


# v2.3.2
##### Added
- **IM Role Proxy**
	- new proxy to handle role operation
	- new method `searchRole (session)`
	- new method `searchRole (session, filter)`
	- new method `lookupRole (session, dn)`
##### Changed
- **Examples**
	- new funcionts to test `searchRole` and `lookupRole` methods
##### Removed
- **Examples**
	- `ValidateNotNullOrEmpty` from test function
