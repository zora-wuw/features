# List of features

* f0001: Download and Restore MongoDB archives 
* f0002: Create Index
* f0003: Group Rows in CSV Files

## Detailed Description
### f0002: Create Index
Create Text Index for all MongoDB collections

Inputs:
* IP : MongoDB IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name
* Create-Index : "yes" or "no". If "no", it lists the collections that require index.

### f0003: Group Rows in CSV Files
Group rows and count the number of the same records

Inputs:
* Input-Folder : read all files from this path
* Output-Folder : write output files in this path
