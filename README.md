# List of features

* f0001: Download and Restore MongoDB archives 
* f0002: Create Index
* f0003: Group Rows in CSV Files
* f0004: Read records from MongoDB and write into a csv file
* f0005: Count the number of connections between two hashtags
* f0006: Aggregate all grouped csv into one csv
* f0007: Get accurate location based on user location
* f0008: Monitor NIFI
* f0009: MongoDB Insertions(JSON)
* f0010: Jenkins Backup
* f0011: MongoDB Backup
* f0012: Count the number of hashtag daily
* f0013: Concatenate files
* f0014: Collection Level Report

## Detailed Description
### f0002: Create Index
Create Text Index for all MongoDB collections

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Contain-String : filter the collection by the contained string in the name
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
  - If "2", keep all rows
  - If "3", keep the rows with non-English letters
* Delete-None : 
  - If "1", the rows with "none" value will be deleted
  - If "2", the rows with "none" value will not be deleted
  
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
* Contain-String : filter the collection by the contained string in the name

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
* Out-Folder : output file folder (create if not exists)

Outputs:
* result.txt (overwrite the previous one)
* log.txt

### f0009: MongoDB Insertions(JSON)

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Folder-Path : read all JSON files from this path

### f0011: MongoDB Backup
Dump collections and drop them optional

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name
* Drop-Collection : if "1", then drop the collection after dump finished
* Start-Str : start string of the collection name

Outputs:
* gzip files

### f0012: Count the number of hashtag daily

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name
* Contain-String : filter the collection by the contained string in the name
* Output-Path : write output files into this path

Outputs:
* CSV files

### f0013: Concatenate files
This is a bash script file

Inputs:
* $1 : input folder - read files from this path
* $2 : start name - filter the files by the started string in the name
* $3 : output file - name of the output file

Outputs:
* CSV file

### f0014: Collection Level Report
#### f0014-a: Restore archived collection file from the folder and calculate

Inputs:
* $1 : input folder - read files from this path
* $2 : database name
* $3 : output file - name of the output file

Outputs:
* CSV file
  - Number of records in each collection
  - Status of Index in each collection
 
#### f0014-b: Get top 100 hashtags from MongoDB

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Output-File-Aus : file name for "Australia" colletions
* Output-File-World : file name for "Other" collections

Outputs:
* CSV files
