## This code is designed to retrieve Google Trends weekly data for a list 
## of keywords of interest. The initial input is a csv file containing two 
## columns: “id”, which contains an identifier, and “names”, which contains 
## the keywords to search for. The final output is a STATA table with the 
## merged weekly series, each named from the corresponding id. A similar 
## code may be used to retrieve series only available at the monthly level.
## Note that the site does not warn you before whether data are available weekly 
## or not.

## Fill in own paths where we use YOURPATH below.

## for export to STATA
require(foreign)

## 1. Get the list of search strings from the csv file “names”.

ss<-read.csv("YOURPATH/names.csv",header=TRUE, sep=",", stringsAsFactors=TRUE)
kywrds<-unlist(ss[,2,drop=FALSE])
kywrdsN<-unlist(ss[,1,drop=FALSE])
kywrdsN<-gsub("%20","",kywrdsN)

## 2. Initialise the URL format for Google Trends series exports. The 
## endUrl is designed in such a way that it retrieves Google Trends 
## series from January 2004 to December 2012 (108 months-period). It is 
## also possible to customise the geographical area of the searches, by 
## adding the suffix “&geo=”Country ISO Code 2 digit.

## more complex queries are best previewed on the Google Trends site 
## using the Chrome browser. This reveals the precise string that must 
## be passed to your browser. 

initialUrl <- 'http://www.google.com/trends/trendsReport?q='
endUrl <- '&date=1%2F2004%20108m&content=1&export=1'

### 3. For each observation in the csv file, browse the URL and retrieve 
### the corresponding downloaded report (report.csv), read and merge the 
### weekly series. If a query returns no result, the code skips it and goes 
### to the next query. NB: The first query needs to be valid, i.e. to 
### return some observations.

for(i in 1:n)
{	
if(i>1)
 {bdata2<-bdata}
else
 {rm(bdata,bdata2,cdata,adata)} 
cat(i); 		
## combine the URL together
finalUrls <- paste0(initialUrl, kywrds[i], endUrl)
cat(finalUrls);
## download data from Google Trends
browseURL(finalUrls,encodeIfNeeded = FALSE)
## let the system sleep for six seconds, this can be amended, 
## but care should be taken to give your browser time to obtain 
## results from a given query
Sys.sleep(6) 
## read in the data
adata<-read.csv2("YOURPATH/report.csv",header = FALSE ,sep = ",")
## merge the data
if(i==1)
 tryCatch({if(nrow(adata)>500)
		    	{bdata<-adata[5:474,]
				 colnames(bdata)<-c("week", kywrdsN[i]) 
  	 			}
  			else{ print(nrow(adata));
  	    		  cat(i); 
        		  flush.console()
       			} 
     	   },error=function(e){cat("ERROR :",conditionMessage(e), "\n")})	
else
 tryCatch({if(nrow(adata)>500)
 				{cdata<-adata[5:474,]
			     colnames(cdata)<-c("week", kywrdsN[i]) 		
 				 bdata<-merge(bdata,cdata,by=c("week"))
 				}
   			   else{ print(nrow(adata));
   	    		     cat(i) ;
       			     flush.console()
       			    }	
    		 },error=function(e){cat("ERROR :",conditionMessage(e), "\n")})	
file.remove(".../report.csv")
}

### 4. Export the results in a Stata table 

write.dta(bdata,"YOURDATA/YOURFILE.dta", convert.factors="string")
