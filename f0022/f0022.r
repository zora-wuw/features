
options(stringsAsFactors=FALSE)


library(reshape2)
library(plyr)
library(dplyr)
library(beepr)
library(magrittr)
library(stringr)
library(mongolite)
library(jsonlite)


##### PART ZERO LOAD FUNCTIONS ------
#import all the files given in the flist which is a csv file or text document

import <- function(sub_folder,flist,pre,post) {
  g=list()
  f=list()
  
  #brings up console here
  #browser()
  
  list=read.csv(flist,comment.char = '#',sep=",")
  
  #suffixes on the census data files
  alph = c('A','B','C','D','E','F','G','H','I','J','K')
  
  #Note this would have been better to do with a check for existence
  #rather than try/catch, but it works fine so.
  for (i in 1:nrow(list)) {
    #browser()
    
    
    pth <- paste(sub_folder,'/',pre,list[i,2],post,sep="")
    
    f[[i]] <- tryCatch({
      
      read.csv(pth)
      
      #errors are likely because the file doesn't exist, which is
      #because if there are more than 200 columns it splits it into
      #G07A G07B etc, so if the folder isn't found keep trying letter
      #suffixes until it's done.
    },error = function(e){
      for (j in 1:7){
        new_pth = paste(sub_folder,'/',pre,list[i,2],alph[j],post,sep='')
        if (file.exists(new_pth)){
          g[[j]] = read.csv(new_pth)
        }
      }
      #I think only one of these is necessary but it works so eh
      return(g)
      f[[i]] <- g
      
    }
    )   
  }
  
  return(f)
}                                               

import2 <- function(sub_folder,flist,pre,post){
  list=read.csv(flist,comment.char = '#',sep=",")
  
  f=list()
  
  # suffixes on the census data files
  alph = c('A','B','C','D','E','F','G','H','I','J','K')
  
  for (i in 1:nrow(list)) {
    pth <- paste(sub_folder,'/',pre,list[i,2],post,sep="")
    if(file.exists(pth)){
      f[[i]] <- read.csv(pth)
    } else {
      g <- list()
      for (j in 1:7){
        new_pth = paste(sub_folder,'/',pre,list[i,2],alph[j],post,sep='')
        if (file.exists(new_pth)){
          g[[j]] = read.csv(new_pth)
        }
      }
      f[[i]] <- g
    }
  }
  return(f)
}

tbl_cln <- function(age){
  # browser()
  ntables <- length(age)
  if (ntables==1||typeof(age[[1]])=="integer"|
      typeof(age[[1]])=="character"){
    age2 <- age
  } else{
    age2 <- as.data.frame(age[[1]])
    for (j in 2:ntables){
      age2 <- cbind(age2,age[[j]][,2:ncol(age[[j]])])
    }
  }
  return(age2)
}

tbl_cln_stack <- function(age){  # same fn but with rbinds if you want tall instead of deep
  browser() 
  ntables <- length(age)
  if (ntables==1||typeof(age[[1]])=="integer"){
    age2 <- age
  } else{
    age2 <- as.data.frame(age[[1]])
    for (j in 2:ntables){
      age2 <- rbind(age2,age[[j]])
    }
  }
  return(age2)
}


#get rid of columns based on regex provided in the impt.txt file (file w/ list of tables
#'to import)
col_edit <- function(age,str,sca){
  # browser()
  str=as.character(str)
  #browser()
  #match columns with the regex
  #p <- str_detect(colnames(age),str) doesn't work for groups
  p <- str_match(colnames(age),str)
  
  #keep the last column, which is the groups (if any), allowing (A ~B) matches using A|(B)
  p <- p[,ncol(p)]
  
  #convert p to logical where NAs are false and everything else is true
  p <- !is.na(p)
  
  
  age2 <- age[,p,drop=FALSE]
  
  # insert the correct scaling business to the start of the thingo
  #scls <- rep(as.character(levels(sca))[sca],ncol(age2))
  scls <- rep(sca,ncol(age2))
  age2 <- rbind(scls,age2)
  return(age2)
}


#rename columns for readability
renamer <- function(age,supp_files){
  #browser()
  namelist <- read.csv(paste0(supp_files,'names.txt'))
  newname <- as.character(namelist$newname)
  oldname <- as.character(namelist$oldname)
  ex <- match(oldname,colnames(age))
  colnames(age)[na.omit(ex)] <- newname[which(!is.na(ex))]
  return(age)  
}

fancy_sqrt <- function(x){
  for (i in 1:length(x)){
    x[i] = sign(x[i])*sqrt(abs(x[i]))
  }
  return(x)
}

col_agg <- function(age,agg,name,yr,sp){
  if (agg == TRUE){
    print(colnames(age))
    #browser()
    filename=paste(sp,as.character(name),yr,'.txt',sep="")
    a <-  read.csv(filename,sep = "\n",comment.char= '#',header = FALSE)
    age2 = as.data.frame(list())
    for (i in 1:nrow(a)){
      #browser()
      id=list()
      b <- as.character(a[i,])
      c <- as.list(strsplit(b, ",")[[1]])
      id <- append(match(c[1:length(c)-1],colnames(age)),id)
      id <- unlist(id)
      if (length(id)==1){
        nc <- as.data.frame(age[,id])
      } else{
        nc <- as.data.frame(rowSums(age[,id]))
      }
      colnames(nc) <- c[length(c)]#put in the last row of c I think
      #browser()
      if (i==1){
        age2 <- nc
      } else {
        age2 <- cbind(age2,nc)
      }
      
    } 
    age <- age2
  }
  return(age)
}

col_agg2 <- function(t,file_agg,yr,sp){
  # t <- t4
  filename=paste(sp,file_agg,sep="")
  a <-  read.csv(filename,sep = "\n",comment.char= '#',header = FALSE)
  for (i in 1:nrow(a)){
    #browser()
    id=list()
    b <- as.character(a[i,])
    c <- as.list(strsplit(b, ",")[[1]])
    id <- append(match(c[2:length(c)],colnames(t)),id)
    id <- unlist(id)
    if(length(id[complete.cases(id)]) < length(id)){#i.e. the id column contains NAs, skip it
      writeLines('\r\ninvalid column')
      print(unlist(c[1]))
      writeLines('Tried to aggregate from')
      print(unlist(c[2:length(c)]))
      writeLines('\r\n it was invalid at')
      print(is.na(id))
      next#move to next stage of for loop
    }
    if (length(id)==1){
      nc <- t[,id,drop=FALSE]
    } else{
      nc <- as.data.frame(rowSums(t[,id]))
    }
    colnames(nc) <- c[1]
    
    t <- t[,-id]
    t <- cbind(t[,c(0:(id[1]-1)),drop=FALSE],nc,t[,c(id[1]:ncol(t))])
  }
  return(t)
  #return(age)
}


scaled <- function(vals,q){
  #browser()
  vals2 <- vals
  for (i in 1:ncol(vals)){
    quant <- quantile(vals[,i],q,na.rm=TRUE)
    vals2[,i] <- vals[,i]/quant  
  }
  
  return(vals2)
}

add_new <- function(t,new_t){
  FISH=1
}

agg2 <- function(t,file,sups){
  #file <- 'age2016_v2.txt'
  ags <- read.csv(paste(sups,file,sep=''),header=FALSE,stringsAsFactors=FALSE)
  #browser()
  for(i in 1:nrow(ags)){
    targets <- ags[i,1]
    sums <- ags[i,2]
    print(sums)
    x <- unlist(strsplit(sums,","))
    y <- targets
    
    x2 <- rowSums(t[x])
    t[y] <- x2
    
    loc <- min(match(x,names(t)))
    
    t <- select(t,-x)
    t <- t[,c(1:(loc-1),ncol(t),(loc):(ncol(t)-1))]
  }
  return(t)
}

#############IMPORT POPULATION TABLES------
#want to scale each district by it's population size, I've been using the
#'number of people at home' question as a proxy for district size, because
#'it's one of the first questions, most poeple will answer.
scale_pop <- function(t,yr,subfol,pre,post,scaleit){
  #
  if(yr =='2011'){
    pop_table = 'B01'
  }else if (yr=='2016'){
    pop_table = 'G01'
  }
  
  pop_ind = read.csv(paste(subfol,'/',pre,pop_table,post,sep=""))
  SA_codes=pop_ind[,1]
  pops = pop_ind$Tot_P_P
  
  ####household numbers
  if(yr=='2016'){
    hh_table = 'G33'
  }
  pop_hh = read.csv(paste(subfol,'/',pre,hh_table,post,sep=""))
  hhs <- pop_hh$Total_Total
  
  ####over15s numbers
  if(yr=='2016'){
    p15_table = 'G40'
  }
  
  pop_15 = read.csv(paste(subfol,'/',pre,p15_table,post,sep=""))
  p15 <- pop_15$P_15_yrs_over_P
  
  ###over 15s and not at school
  if(yr=='2016'){
    p15a_table <- 'G16B'
  }
  
  pop_15a = read.csv(paste(subfol,'/',pre,p15a_table,post,sep=""))
  p15a <- pop_15a$P_tot_tot
  
  t3 <- cbind.data.frame(t3,c('none',pops),c('none',hhs),c('none',p15),stringsAsFactors=FALSE)
  L <- ncol(t3)
  names(t3)[c(L-2,L-1,L)] <- c('pops','hhs','p15')
  
  #scale all the values in t3 by dividing by the end column (population)
  s <- list()
  s['ind'] <- 'pops'
  s['hh'] <- 'hhs'
  s['p15a'] <- 'p15'
  s['none'] <- 'none'
  sclz <- t3[1,]
  z <- t3[c(-1),]
  z <- as.data.frame(sapply(z[,],as.numeric,stringsAsFactors=FALSE),stringsAsFactors=FALSE)
  
  if(scaleit){
    for(i in 1:ncol(z)){
      sc_col <- s[as.character(sclz[i])][[1]]
      if(sc_col!='none'){
        z[,i] <- z[,i]/z[,sc_col]
      }
    }
    
  }
  return(z)
}

########  PART ONE   ######IMPORT CENSUS-------

yr="2016"
supp_files <- 'support/'

# opts file - don't include .txt or the year extension which is added automatically (why...)
opts <- 'import_options'

db <- fromJSON(paste0(supp_files,'mongo.txt'))
file_agg <- 'age2016_v2.txt'

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
t_old <- import(subfol,file_list,pre,post)

###########CLEANING THE DATA------



#several pre-processing functions. See 'funs.R' for more detail. Essentially:
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


coll_names <- c('census_2016_sa1_count_agg',
                'census_2016_sa1_count_notagg',
                'census_2016_sa1_proportion_agg',
                'census_2016_sa1_proportion_notagg')
t3_all <- list(t3_agg,t3,t3_scaled_agg,t3_scaled)

usr <- db$usr
pw <- db$pw
host <- db$host
datab <- db$database

uri <- sprintf('mongodb://%s:%s@%s',usr,pw,host)

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

#uri <- db$uri

#con_local <- mongo(uri,collection='sa1_vic_unagg_unscaled',db='census')
#con_local$insert(t3)

# connect to proper db



con_proper <- mongo(uri,collection='sa1_vic_unagg_unscaled',db='census')


con_proper$insert(t3)
con_proper$drop()






