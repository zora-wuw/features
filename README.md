# List of features

* f0001: Download and Restore MongoDB archives 
* f0002: Create Index
* f0003: Group Rows in CSV Files
* f0004: Read records from MongoDB and write into a csv file
* f0005: Count the number of connections between two hashtags
* f0006: Aggregate all grouped csv into one csv
* f0007: Get accurate location based on user location
* f0008: Monitor NIFI

## Detailed Description
### f0002: Create Index
Create Text Index for all MongoDB collections

Inputs:
* IP : MongoDB server IP
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
* IP : MongoDB server IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name

Outputs:
* CSV files

### f0005: Count the number of connections between two hashtags
Create csv file with three columns (hashtag, linked_hashtag, number) for each collection

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name.

Outputs:
* CSV files

### f0006: Aggregate all grouped csv into one csv
Aggregate every two csv files into one csv file at each time, after f0003 is completed

Inputs:
* Input-Folder : read all files from this path
* Output-Folder : write output files into this path

Outputs:
* CSV files


### f0007: Get accurate location based on user location
Comparing user location with geo file and add three columns (city, state, country) in the new csv file

Inputs:
* Input-Folder : read all files from this path
* Output-Folder : write output files into this path
* Aus-File-Path : path of the au.csv in the supporting-files
* World-File-Path : path of the world-cities.csv in the supporting-files

Outputs:
* CSV files

### f0008: Monitor NIFI
Send a message to Slack only if the record number of collection is reduced or the same compared with the last run

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Slack-Token : Slack API token
* Channel : Slack channel
* File-Path : result.txt path
* Log-File-Path : log.txt path

Outputs:
* result.txt (overwrite the previous one)
* log.txt
