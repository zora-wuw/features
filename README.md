# List of features

* f0001: Download and Restore MongoDB archives 
* f0002: Create Index
* f0003: Group Rows in CSV Files
* f0004: Read records from MongoDB and write into a csv file
* f0005: Count the number of connections between two hashtags

## Detailed Description
### f0002: Create Index
Create Text Index for all MongoDB collections

Inputs:
* IP : MongoDB IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name.
* Create-Index : 
  - If "1", then create index.
  - If "2", it lists the collections that require index.

### f0003: Group Rows in CSV Files
Group rows and count the number of the same records

Inputs:
* Input-Folder : read all files from this path
* Output-Folder : write output files into this path
* Language : 
  - If "1", keep the rows with English letters and numbers
  - If "2", keep all rows.
  - If "3", keep the rows with non-English letters
* Delete-None : 
  - If "1", the rows with "none" value will be deleted.
  - If "2", the rows with "none" value will not be deleted.
  
Outputs:
* CSV files 

### f0004: Read records from MongoDB and write into a csv file
Create a csv file with two columns (hashtag, user_location) for each collection

Inputs:
* IP : MongoDB IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name

Outputs:
* CSV files

### f0005: Count the number of connections between two hashtags
Create csv file with three columns (hashtag, linked_hashtag, number) for each collection

Inputs:
* IP : MongoDB IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name.

Outputs:
* CSV files
