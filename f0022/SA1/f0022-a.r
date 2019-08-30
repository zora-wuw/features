#code starts at line 212. Make sure setwd() is commented out.
#setwd('C:/Users/lgurrstephen/Desktop/testlife')
source('f0022-b.r')
options(stringsAsFactors=FALSE)

.libpaths()

library(reshape2)
library(plyr)
library(dplyr)
library(magrittr)
library(stringr)
library(mongolite)
library(jsonlite)
library(beepr)

########  PART ONE   ######IMPORT CENSUS-------
supp_files <- 'support/'

# opts file - don't include .txt or the year extension which is added automatically (why...)
opts <- 'import_options'

db <- fromJSON(paste0(supp_files,'mongo.txt'))
yr <- db$year
file_agg <- 'aggregate_columns.txt'
local_con <- db$connect_local
output_to_db <- db$output_to_db

##FILE LOCATIONS
if (yr == "2011"){
  pre <- '2011Census_'
  post <- '_VIC_SA1_short.csv'
  subfol <- 'data/2011 Census BCP Statistical Areas Level 1 for VIC/VIC'
} else if (yr == "2016"){
  pre <- '2016Census_'
  post <- '_AUS_SA1.csv'
  subfol <- 'data/2016 Census GCP Statistical Area 1 for AUST'
}

#separate file with list of census tables to import
#file_list='r_scripts/gleneira2/import_agendis.txt'
file_list = paste(supp_files,opts,yr,'.txt',
                  sep='')

##IMPORT CENSUS TABLES--------
#read options file
flist=read.csv(file_list,comment.char = '#',sep=",",quote= '\'')

#function "import" imports the CSV files, but it automatically searches for filenames
#with the letters appended if the import fails, eg searches for G04A if G04 doesn't exist. Will generate warnings.
t <- import2(subfol,file_list,pre,post)
beep(5)
###########CLEANING THE DATA------



#several pre-processing functions. See 'f0022-b.R' for more detail. Essentially:
#tbl_cln combines different excel files if they have been split (the census
#splits up tables with more than 200 columns)
#col_edit keeps columns with names matching regex given in impt.txt
#col_agg tries to aggregate columns based on the logical input in impt.txt
#   if flist[i,4] is 1, it looks for a file with the name of the table that tells it which
#   'columns to aggregate (see age.txt for an example)

t2 <- list()
for (i in 1:nrow(flist)){
  t2[[i]] <- tbl_cln(t[[i]])
  t2[[i]] <- col_edit(t2[[i]],flist[i,3],flist[i,5])
}

#rename renames columns based on the names.txt file, if found
for (i in 1:nrow(flist)){
  t2[[i]] <- renamer(t2[[i]],supp_files)
}
###Proper population scaling goes here

#combine all tables
t3 = dplyr::bind_cols(t2)


##swap it so that australian, irish, and english are next to each other in the anglo block
en <- match("English",names(t3))
aus <- match("Australian",names(t3))
ab <- aus+1
ir <- match("Irish",names(t3))
nz <- match("NZ",names(t3))
sc <- match("Scottish",names(t3))
wl <- match("Welsh",names(t3))
t3 <- t3[,c(0:(aus-1),ab,aus,en,ir,nz,sc,wl,(aus+2):(en-1),(en+1):(ir-1),(ir+1):(nz-1),
            (nz+1):(sc-1),(sc+1):(wl-1),(wl+1):ncol(t3))]

t3 <- renamer(t3,supp_files) #doesn't mind if columns not found


t3_scaled <- scale_pop(t3,yr,subfol,pre,post,TRUE)
t3        <- scale_pop(t3,yr,subfol,pre,post,FALSE)  

if(yr =='2011'){
  pop_table = 'B01'
}else if (yr=='2016'){
  pop_table = 'G01'
}

pop_ind = read.csv(paste(subfol,'/',pre,pop_table,post,sep=""))
SA_codes=pop_ind[,1]

t3_scaled$sa1_7dig2016 <- SA_codes
t3$sa1_7dig2016 <- SA_codes

# aggregate
t3_scaled_agg <- col_agg2(t3_scaled,file_agg,yr,supp_files) #errors if columns not found
t3_agg <- col_agg2(t3,file_agg,yr,supp_files)


duds <- complete.cases(t3_scaled_agg)

t3_scaled_agg <- t3_scaled_agg[duds,] #removes rows with an NA
t3 <- t3[duds,]
t3_scaled <- t3_scaled[duds,]
t3_agg <- t3_agg[duds,]

##############EXPORTING
#what.folder.is.this.script.in()


coll_names <- c('census_xxxx_sa1_count_agg',
                'census_xxxx_sa1_count_notagg',
                'census_xxxx_sa1_proportion_agg',
                'census_xxxx_sa1_proportion_notagg')
coll_names <- gsub('xxxx',yr,coll_names)

t3_all <- list(t3_agg,t3,t3_scaled_agg,t3_scaled)

if(output_to_db){
  usr <- db$usr
  pw <- db$pw
  host <- db$host
  datab <- db$database
  
  uri <- sprintf('mongodb://%s:%s@%s',usr,pw,host)
  
  if(local_con){
    uri <- db$local_uri
  }
  
  print(paste('gonna connect to db',datab,'with \'connect to local\' set as',local_con))
  for (i in 1:length(t3_all)){
    con <- mongo(uri,collection=coll_names[i],db=datab)
    con$count()
    if (con$count()>0){
      con$drop
      print(paste('dropped',coll_names[i],'from',datab))
    }
    con$insert(t3_all[[i]])
    con$disconnect()
    print(paste('inserted',coll_names[i],'to',datab))
  }
} else {
  if(!file.exists('images')){
    dir.create('images')
  }
  for (i in 1:length(t3_all)){
    write.csv(t3_all[[i]],file= paste0('images/',coll_names[i],'.csv'),
              row.names = FALSE)
    
  }
}