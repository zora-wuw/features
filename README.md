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
* f0015: Geoname
* f0016: Get User Location per Collection
* f0017: Convert CSV to JSON array
* f0018: Add new column in CSV
* f0019: Convert XML to CSV
* f0020: Convert CSV to Excel

## Detailed Description
### f0002: Create Index
Create Text Index for all MongoDB collections

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name
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
* Column-List : column name, if more than one, then separated by ","
* Column-Type-List : column name's type, if more than one, then separated by ","
                     Options: "string","int","float"

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
* DB-Name : database name
* Contain-String : filter the JSON files by the contained string in the name
* JSON-Key : key for the array (if no key then set it to "none" )
* User-Name : MongoDB user name
* Psword : MongoDB user password

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
Generate one csv file for each collection

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name

Outputs:
* CSV files

### f0015: Geoname

#### f0015-a: Get geoname information based on user location

Inputs:
* Flag : 
  - If "Other" collection, then "1".
  - If "Australia" collection, then "2".
* Input-Folder
* Prefix : prefix of the collection files' names
* Output-File
* Ratio-Value
* Column-Number : choose which column in input file to process the geoname
* World-Cities-File : world-cities.csv in supporting-files
* World-States-File : world-states.csv in supporting-files
* World-Countries-File : world-countries.csv in supporting-files
* AU-Cities-File : au-cities.csv in supporting-files
* AU-States-File : au-states.csv in supporting-files
* AU-Countries-File : au-country.csv in supporting-files

Outputs:
* CSV files

#### f0015-b: Insert geoname information into MongoDB

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name
* AU-Geo-File : Australia geoname file (The output file from f0015-a)
* World-Geo-File : World geoname file (The output file from f0015-a)

#### f0015-c: Collection Level Report (python version)
Including : record count, index information, English tweets count, geoname count

* Code Usage: f0015-c.py collection_name

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* DB-Name : database name

Outputs:
* JSON file

### f0016: Get User Location per Collection
Get unique user location csv file for each collection

#### f0016-a: Restore archived collection file, Run f0016-b and Drop the collection

Inputs:
* $1 : input folder - read files from this path
* $2 : database name
* $3 : python file - name of the file
* $4 : prefix - prefix of the collection files' names

Output:
* CSV files

#### f0016-b: Get unique user location csv file for each collection

Inputs:
* IP : MongoDB server IP
* MongoDB-Port
* Output-Folder : output folder ended with "/"

Outputs:
* CSV files

#### f0016-c: Get new user location

Inputs:
* Input-Folder : read files from this path
* Output-Folder : output folder ended without "/"
* Geo-Aus-File
* Geo-World-File 

Outputs:
* CSV files

### f0017: Convert CSV to JSON array
process files with same start string each time

Inputs:
* CSV-Folder-Path : read file from this folder path
* JSON-Folder-Path : write into this folder
* Start-String : String that filenames start with

Outputs:
* JSON files

### f0018: Add new column in CSV

Inputs:
* Input-File : csv file
* Output-File : csv file
* Column-Name
* Split-Character
* Rename: 
  - if "1", then append the original header as a prefix to the new header
  - if "2", then do not append

Outputs:
* CSV file

### f0019: Convert XML to CSV

Inputs:
* Input-File : xml file
* Output-File : csv file

Outputs:
* CSV file

### f0020: Convert CSV to Excel

Inputs:
* Input-File : csv file
* Output-File-Name : xlsx file name without extension

Outputs:
* xlsx file
