# import csv strings as strings
options(stringsAsFactors = FALSE)

# libraries
library(dplyr)
library(reshape2)
library(ggplot2)
library(cluster)
library(jsonlite)
library(ini)

# relative folder paths
support_folder <- NULL  # where the supporting .txt files go. Must exist inside the home_folder 
# support_folder <- './'
output_folder <- 'images/'  # must be called images and the images folder must exist inside home folder

# import .ini file with absolute paths in it
inits <- read.ini(paste0(support_folder,'paths.ini'))
natsem_json_data_folder  <- inits$file_paths$natsem_json_data_folder  # contains json and geojson files for non-census data
phidu_json_data_folder  <- inits$file_paths$phidu_json_data_folder # contains json and geojson files for non-census data
aux_data_folder  <-  inits$file_paths$aux_data_folder # contains 2011 to 2016 correspondence file and abs geography file
census_data_folder <- inits$file_paths$census_data_folder  # unzipped GCP folder
script_folder <- inits$file_paths$script_folder # location of census_functions.R
home_folder <- inits$file_paths$home_folder  # where the outputs will go

if(!file.exists(paste0(home_folder,substr(output_folder,1,nchar(output_folder)-1)))){
  dir.create(paste0(home_folder,output_folder))
}

# function locations
source(paste0(script_folder,'/census_functions.R'))

# produce silhouette plots to help determine appropriate number of clusters
sill <- FALSE


##### Function Definitions (other functions are in census_functions.R) #####
# function to output a csv file, as well as a .csvt
# file which is used by QGIS3 to determine datatypes
QGIS_types <- function(tableee,filename,rn=FALSE,path = NULL){
  types <- as.character(sapply(tableee[1,],function(x) typeof(as.vector(x))))
  types <- gsub('double','Real',types)
  types <- gsub('integer','Integer',types)
  types <- gsub('matrix','Real',types)
  types <- gsub('character','String',types)
  write.table(types,file=paste(path,filename,'.csvt',sep=""),row.names=rn
              ,eol=',',col.names=FALSE)
  write.csv(tableee,file=paste(path,filename,'.csv',sep=""),row.names=rn)
  
  return(types)
}

# normalise the values using min-max to be between 0 and 1
minmax <- function(x){
  x2 <- (x-min(x,na.rm=TRUE))/(max(x,na.rm=TRUE)-min(x,na.rm=TRUE))
  return(x2)
}

# standardise values using stdevs
stdise <- function(x){
  x2 <- (x - mean(x,na.rm = TRUE))/sd(x,na.rm=TRUE)
  return(x2)
}
temp_output <- paste0(home_folder,output_folder,'SR_sa2.csv')

if (!file.exists(temp_output)){
  ##### add census variables #####
  opts <- 'import_options'
  file_agg <- 'aggregate_columns.txt'
  supp_files <- paste0(home_folder,support_folder)

  yr <- '2016'

  # filenames
  pre <- '2016Census_'
  post <- '_AUS_SA2.csv'
  subfol <- census_data_folder

  # main function to process census data
  t3 <- primary(db=NULL,pre,post,subfol,supp_files,yr,opts)

  # scale by population if last arg is TRUE, or just remove scaling variable if it is FALSE.
  t3_scaled <- scale_pop(t3,yr,subfol,pre,post,TRUE)
  t3        <- scale_pop(t3,yr,subfol,pre,post,FALSE)  

  # load the SA2 codes
  table = 'G01'
  ind = read.csv(paste(subfol,'/',pre,table,post,sep=""))
  SA_codes=ind[,1]

  t3_scaled$sa2_9dig2016 <- SA_codes
  t3$sa2_9dig2016 <- SA_codes

  t3_scaled <- t3_scaled[,c(ncol(t3_scaled),1:(ncol(t3_scaled)-1))]
  t3 <- t3[,c(ncol(t3),1:(ncol(t3)-1))]

  # aggregate
  t3_scaled_agg <- col_agg2(t3_scaled,file_agg,yr,supp_files)
  t3_agg <- col_agg2(t3,file_agg,yr,supp_files)

  duds <- complete.cases(t3_scaled_agg)

  t3_scaled_agg <- t3_scaled_agg[duds,] #removes rows with an NA
  t3 <- t3[duds,]
  t3_scaled <- t3_scaled[duds,]
  t3_agg <- t3_agg[duds,]

  # keep columns in the columns section of the init file
  a <- inits$columns$census_keep

  b <- unlist(strsplit(a,','))

  c = match(b,colnames(t3_scaled_agg))
  if (sum(is.na(c))>0){
    print(paste('warning: column',b[is.na(c)],'not found'))
  }


  tokeep_census <- t3_scaled_agg[,c(1,c)]

  print('census processing finished')
  #### add other variables ####

  # add employment
  # source: NATSEM

  filename <- 'NATSEM_Social_and_Economic_Indicators_Employment_Rate_SA2_2016.geoJSON'

  t3 <- fromJSON(paste0(natsem_json_data_folder,filename))
  tokeep_employment <- data.frame(as.integer(t3$features$properties$sa2_code16),
                                  t3$features$properties$sa2_name16,
                                  t3$features$properties$employment_rate)
  colnames(tokeep_employment) = c('sa2_code16','sa2_name16','employment_rate')



  filename <- 'NATSEM_Financial_Indicators_Synthetic_Estimates_SA2_2016.geoJSON'
  t6 <- fromJSON(paste0(natsem_json_data_folder,filename))
  tokeep_emergency <- data.frame(as.integer(t6$features$properties$sa2_code16),
                                 t6$features$properties$sa2_name16,
                                 t6$features$properties$per100_no_emergency_money_synth)
  colnames(tokeep_emergency) = c('sa2_code16','sa2_name16','per100_no_emergency_money_synth')


  filename <- 'NATSEM_Trust_Indicators_Synthetic_Estimates_SA2_2016.geoJSON'
  t5 <- fromJSON(paste0(natsem_json_data_folder,filename))
  tokeep_trust <- data.frame(as.integer(t5$features$properties$sa2_code16),
                             t5$features$properties$sa2_name16,
                             t5$features$properties$trust_1_3_pc_synth)
  colnames(tokeep_trust) = c('sa2_code16','sa2_name16','trust_1_3_pc_synth')



  # PHIDU data, uses 2011 sa2s
  filename <- 'SA2_Psychological_Distress_Modelled_Estimate_2011_2013.geoJSON'
  t4 <- fromJSON(paste0(phidu_json_data_folder,filename))
  tokeep_psychdistress <- data.frame(t4$features$properties$area_code,
                                     t4$features$properties$area_name,
                                     t4$features$properties$k10_me_2_rate_3_11_7_13)
  colnames(tokeep_psychdistress) <- c('sa2_code11','sa2_name11','k10_me_2_rate_3_11_7_13')


  # import sa2s correspondence file
  sa2_file <- 'correspondence2011to2016_SA2.csv'


  corr <- read.csv(paste0(aux_data_folder,sa2_file),sep='\t')

  tokeep_psychdistress_2016 <- left_join(corr,tokeep_psychdistress,by = c('SA2_MAINCODE_2011' = 'sa2_code11'))
  tokeep_psychdistress_2016 <- tokeep_psychdistress_2016[order(tokeep_psychdistress_2016$RATIO,
                                                               tokeep_psychdistress_2016$SA2_NAME_2016,
                                                               decreasing=TRUE),]
  tokeep_psychdistress_2016_2 <- tokeep_psychdistress_2016[!duplicated(tokeep_psychdistress_2016[,"SA2_MAINCODE_2016"]),]

  f=list(
    tokeep_census,tokeep_emergency,tokeep_employment,tokeep_trust,tokeep_psychdistress_2016_2
  )

  # combine all the things into one thing by joining on sa2 code
  g=f[[1]]
  g=full_join(g,f[[2]],by=c('sa2_9dig2016' = 'sa2_code16'))
  g=full_join(g,f[[3]],by=c('sa2_9dig2016' = 'sa2_code16'))
  g=full_join(g,f[[4]],by=c('sa2_9dig2016' = 'sa2_code16'))
  g=full_join(g,f[[5]],by=c('sa2_9dig2016' = 'SA2_MAINCODE_2016'))

  # replace nas from one set of sa2s with value from the other set
  g$sa2_name16.x[is.na(g$sa2_name16.x)] <- g$SA2_NAME_2016[is.na(g$sa2_name16.x)]

  # keep certain columns
  g <- g[,c("sa2_9dig2016","sa2_name16.x","70+","H < 799","migr 2006-15","Need Assistance",
            "No Yr 12","No Volunteer","Moved Dif SA2 5 yr","per100_no_emergency_money_synth",
            "employment_rate","trust_1_3_pc_synth","k10_me_2_rate_3_11_7_13"   )]


  ##### Optional: save a csv to prevent having to run whole code again ####
  write.csv(g,file = temp_output,row.names = FALSE)
} else {
  # Optional: Load the dataset that has been output from QGIS_types
  g <- read.csv(paste0(home_folder,output_folder,'SR_sa2.csv'),check.names = FALSE)
}




#### aggregate and standardise/normalise ####
g$employment_rate <- 100-g$employment_rate

# rename columns
g <- renamer(g,paste0(home_folder,support_folder))  # a function from census_functions.R


# add geography for aggregating at higher levels

geog <- read.csv(paste0(aux_data_folder,'/','SA1_2016_AUST.csv'))

# remove the sa1 columns and remove duplicates
geog <- unique(geog[,3:13])
g <- left_join(g,geog,by=c('SA2_9DIG2016' = 'SA2_MAINCODE_2016'))

# aggregate up to sa3 and sa4 levels
variables <- c("Age_70+","Household_Income<$700/wk","Recent_Migrants",
               "Need_Assistance","Did_Not_Graduate_Year_12",
               "Not_Volunteering","Different_SA2_5_Years_Ago",
               "No_Emergency_Money_(Synth)","Percent_Not_Employed",
               "Low_Trust_In_People_(Synth)","High_Psychological_Distress_(Modeled)")

g_sa3 <- aggregate(g[,variables],
                   by=list(g$SA3_CODE_2016),FUN = 'mean',na.rm=TRUE)
colnames(g_sa3)[1] <- 'SA3_CODE_2016'

g_sa4 <- aggregate(g[,variables],
                   by=list(g$SA4_CODE_2016),FUN = 'mean',na.rm=TRUE)
colnames(g_sa4)[1] <- 'SA4_CODE_2016'



f <- list(g,g_sa3,g_sa4)



# find which columns are the variable names
cols=list()
for (i in 1:3){
  cols[[i]] <- as.logical(rowSums(sapply(variables,grepl,x=colnames(f[[i]]),fixed=TRUE)))
}

# add the standardised and normalised versions of the variable to f
for (i in 1:3){
  fnorm <- lapply(f[[i]][cols[[i]]],minmax)
  names(fnorm) <- paste0('norm_',names(fnorm))
  fstd <- lapply(f[[i]][cols[[i]]],stdise)
  names(fstd) <- paste0('std_',names(fstd))
  f[[i]] <- cbind(f[[i]],fnorm,fstd)
}

##### cluster on one of the aggregations (in this case sa2) #####
agg <- unlist(strsplit(inits$clusters$aggregations,','))
# agg <- c('sa2','sa3','sa4')
clusteron <- unlist(strsplit(inits$clusters$variable_scaling,','))
# clusteron <- c('norm','norm','norm')  # options are 'norm', 'std' or 'unscaled'

mydata <- list()
mydatav <- list()

for (i in 1:length(agg)){
  g2 <- as.data.frame(f[[i]])
  
  rownames(g2) <- g2[,1]
  
  # make smaller dataset of only the variables to cluster (i.e. not the sa codes etc)
  mydata[[i]] <- g2
  if (clusteron[i]=='unscaled'){
    mydata[[i]] <- mydata[[i]][,variables]
  } else {
    keep_cols <- grep(paste0('^',clusteron[i]),colnames(mydata[[i]]))
    mydata[[i]] <- mydata[[i]][,keep_cols]
  }
  
  # remove areas with NA in any columns
  mydata[[i]] <- mydata[[i]][complete.cases(mydata[[i]]),]
  
  #victoria - state code 2. Keep rows which have sa code starting with 2
  mydatav[[i]] <- mydata[[i]][grepl('^2',row.names(mydata[[i]])),]
  
  # check sillhouette plots of clusters
  if(sill){
    pdf(paste0(home_folder,'/',agg[i],'_',clusteron[i],'silhouette.pdf'))
    for (j in 2:15){
      x <- pam(mydatav[[i]],j)
      plot(silhouette(x))
    }
    dev.off()
  }
}

# choose cluster size for sa2, sa3, sa4
nclus <- as.numeric(unlist(strsplit(inits$clusters$cluster_numbers,',')))
# nclus <- c(8,8,3)

# cluster and export each of them as csv and csvt files
clustered <- list()
for (i in 1:length(agg)){  
  # do clustering and export ready for QGIS
  use <- mydatav[[i]]
  x <- pam(use,nclus[i])
  use <- cbind(use,x$clustering)
  filename <- paste0(nclus[i],'kmedoids_vic',agg[i])
  use$id <- as.integer(row.names(use))
  colnames(use)[colnames(use)=='x$clustering'] <- 'Cluster'
  write_json(use,paste0(home_folder,output_folder,filename,'.json'),pretty=TRUE)
  QGIS_types(use,filename,FALSE,path = paste0(home_folder,output_folder))
  clustered[[i]] <- use
}

#### Calculate means for each cluster ###
ClusterMeans <- list()
for (i in 1:length(agg)){
  use <- data.frame(ID=as.integer(row.names(clustered[[i]])),Clus=clustered[[i]]$Cluster)
  
  use2 <- left_join( f[[i]],use, by=setNames('ID', colnames(f[[i]])[1]) )
  use2 <- use2[complete.cases(use2),]
 
  colids <- sapply(variables,grep,x=colnames(use2),fixed=TRUE) 
  
  ClusterMeans[[i]] <- aggregate(use2[,colids],by=list(use2$Clus),mean)
  colnames(ClusterMeans[[i]])[colnames(ClusterMeans[[i]])=='Group.1'] <- 'Cluster'
  write_json(ClusterMeans[[i]],path = paste0(home_folder,output_folder,'Cluster_Means_',agg[i],'.json'),pretty=TRUE)
}

