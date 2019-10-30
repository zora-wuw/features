library(stringr)
library(mongolite)

import2 <- function(sub_folder,flist,pre,post){  # imports relevant census tables
  list1=read.csv(flist,comment.char = '#',sep=",")
  
  f=list()
  
  #want to check the path name, then add suffixes 'A' 'B' etc if the file isn't found
  for (i in 1:nrow(list1)) {
    pth <- paste(sub_folder,'/',pre,list1$Table.Number[i],post,sep="")
    if(file.exists(pth)){
      f[[i]] <- read.csv(pth)
    } else {
      g <- list()
      for (j in 1:10){
        new_pth = paste(sub_folder,'/',pre,list1$Table.Number[i],LETTERS[j],post,sep='')
        if (file.exists(new_pth)){
          g[[j]] = read.csv(new_pth)
        }
      }
      f[[i]] <- g
    }
  }
  return(f)
}

tbl_cln <- function(age){  # deals with the fact the census splits each variable up
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

col_edit <- function(age,str,sca){  #get rid of columns based on regex provided in the impt.txt file
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

renamer <- function(age,supp_files){  # rename columns for readability
  #browser()
  namelist <- read.csv(paste0(supp_files,'names.txt'))
  newname <- as.character(namelist$newname)
  oldname <- as.character(namelist$oldname)
  ex <- match(oldname,colnames(age))
  colnames(age)[na.omit(ex)] <- newname[which(!is.na(ex))]
  return(age)  
}

fancy_sqrt <- function(x){  # fancy_sqrt(-9) = -3
  for (i in 1:length(x)){
    x[i] = sign(x[i])*sqrt(abs(x[i]))
  }
  return(x)
}

col_agg2 <- function(t,file_agg,yr,sp){  # aggregates columns based on file passed to file_agg
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
      next  # move to next stage of for loop
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
}

scale_pop <- function(t,yr,subfol,pre,post,scaleit){  # adds individual and hhld pop as variables
##############IMPORT POPULATION TABLES------
#want to scale each district by it's population size, I've been using the
#'number of people at home' question as a proxy for district size, because
#'it's one of the first questions, most people will answer.
#'this function is necessary to run with scaleit=FALSE if you want the counts
#'so that pop can be added as a variable for each sa area
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

reorder_nationality <- function(t3){  # swap it so that australian, irish, and english are next to each other in the anglo block
  
  en <- match("English",names(t3))
  aus <- match("Australian",names(t3))
  ab <- aus+1
  ir <- match("Irish",names(t3))
  nz <- match("NZ",names(t3))
  sc <- match("Scottish",names(t3))
  wl <- match("Welsh",names(t3))
  
  if (sum(is.na(c(en,aus,ab,ir,nz,sc,wl)))==0){
    t3 <- t3[,c(0:(aus-1),ab,aus,en,ir,nz,sc,wl,(aus+2):(en-1),(en+1):(ir-1),(ir+1):(nz-1),
                (nz+1):(sc-1),(sc+1):(wl-1),(wl+1):ncol(t3))]
  }
  return(t3)
}

dbexport <- function(db,t3_all,coll_names){
  local_con <- db$connect_local
  output_to_db <- db$output_to_db
  
  if(db$output_to_db){

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
}

# main function which calls most of the others
primary <- function(db,pre,post,subfol,supp_files,yr,opts){
  
  #separate file with list of census tables to import
  file_list = paste(supp_files,opts,yr,'.txt',sep='')
  
  ##IMPORT CENSUS TABLES--------
  #read options file
  flist=read.csv(file_list,comment.char = '#',sep=",",quote= '\'')
  
  #function "import2" imports the CSV files, but it automatically searches for filenames
  #with the letters appended if the import fails, eg searches for G04A if G04 doesn't exist. Will generate warnings.
  
  t <- import2(subfol,file_list,pre,post)
  print(paste('read in',sum(unlist((lapply(t,length)))),'columns from',
              paste0(subfol,pre,flist$Table.Number[1],post),'etc'))
  
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
    t2[[i]] <- col_edit(t2[[i]],flist$Regex[i],flist$Scaling[i])
  }
  
  #rename renames columns based on the names.txt file, if found
  for (i in 1:nrow(flist)){
    t2[[i]] <- renamer(t2[[i]],supp_files)
  }
  ###Proper population scaling goes here
  
  #combine all tables
  t3 = dplyr::bind_cols(t2)
  
  #re-order so anglo nationalities appear adjacent
  t3 <- reorder_nationality(t3)
  
  return(t3)
}