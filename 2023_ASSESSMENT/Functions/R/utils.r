

#' utility function to connect to server
#' @param db the database schema ("akfin" or "afsc")
#' @export connect
#' 
connect <- function(db = "akfin") {

    # check if database name is stored in keyring, if not request user/pwd
  if(!(db %in% keyring::key_list()[,1])) {
    user <- getPass::getPass(paste("Enter", db, "username: "))
    pwd <- getPass::getPass(paste("Enter", db, "password: "))
  } else {
    user <- keyring::key_list(db)$username
    pwd <-  keyring::key_get(db, keyring::key_list(db)$username)
  }
    # connect to server
    DBI::dbConnect ( odbc::odbc(),
                     db,
                     uid = user,
                     pwd = pwd )
}

#' utility function to disconnect from server
#' @param db the database schema (e.g., akfin or afsc)
#' @export disconnect
#' 
disconnect <- function(db) {
  DBI::dbDisconnect(db)
}

#' utility function to read sql file
#' @param x the sql code to read, pulled from the top directory
#' @export sql_read
#' @examples 
#' \dontrun{
#' .d = sql_read("fsh_catch.sql")
#' }
sql_read <- function(x) {
  if(file.exists(system.file("sql", x, package = "afscdata"))) {
    readLines(system.file("sql", x, package = "afscdata"))
  } else {
    stop("The sql file does not exist.")
  }
}

#' utility function to filter sql files
#'
#' @param sql_precode change input e.g., ("=")
#' @param x the variable to change (e.g., year)
#' @param sql_code the sql query code...
#' @param flag a flag in the sql code to place the precode and x in the appropriate location
#' @export sql_filter
#' @examples
#' \dontrun{
#' .d = sql_filter(sql_precode = "<=", 2011, sql_code = .d, flag = "-- insert year")
#' }
sql_filter <- function(sql_precode = "IN", x, sql_code, flag = "-- insert species") {
  
  i = suppressWarnings(grep(flag, sql_code))
  sql_code[i] <- paste0(
    sql_precode, " (",
    collapse_filters(x), ")"
  )
  sql_code
}

#' utility function to run sql query
#'
#' @param database which database to connect to 'akfin' or 'afsc'
#' @param query the sql query code
#'
#' @export sql_run
#'
#' @examples
#' \dontrun{
#' .d = sql_read("fsh_catch.sql")
#' .d = sql_filter(sql_precode = "<=", 2011, sql_code = .d, flag = "-- insert year")
#' .d = sql_filter(x = area, sql_code = .d, flag = "-- insert region")
#' .d = sql_filter(sql_precode = "IN", x = c("PEL7", "PELS"), 
#'                    sql_code = .d, flag = "-- insert species")
#' 
#' afsc = DBI::dbConnect(odbc::odbc(), "afsc", UID = "afsc_user", PWD = "afsc_pwd") 
#'  
#' sql_run(afsc, query) %>%
#'          vroom::vroom_write(here::here(year, 'data', 'raw', 'fsh_catch_data.csv'))
#' DBI::dbDisconnect(afsc)
#' }
sql_run <- function(database, query) {
  query = paste(query, collapse = "\n")
  DBI::dbGetQuery(database, query, as.is=TRUE, believeNRows=FALSE)
}

#' utility function for sql queries
#'
#' @param x variable to add quotes to
#' @description adds correct quotes for sql queries, nested within `sql_filter`
#' @export collapse_filters

collapse_filters <- function(x) {
  sprintf("'%s'", paste(x, collapse = "','"))
}

#' Setup folder structure
#'
#' Creates a common folder structure for assessment data
#'
#' @param year assessment year
#' @param dirs directories to write
#' @param tier assessment tier to change the folders used - not currently implemented
#' @return creates a designated/named folder structure 
#' @export setup_folders
#'
#' @examples
#' \dontrun{
#' setup(2022)
#'}
setup_folders <- function(year, dirs = c("raw", "user_input", "output", "sara", "sql"), tier = NULL){
  
  for(i in 1:length(dirs)){
    if(dir.exists(here::here(year, "data", dirs[i])) == FALSE){
      dir.create(here::here(year, "data", dirs[i]), recursive=TRUE)
    }
  }
}

#' utility function for date of data query
#'
#' @param year assessment year
#' @param loc location to save file if different from default
#' 
#' @return a query date file saved as `year/data/raw/data_called.txt`
#'
q_date <- function(year, loc = NULL){
  txt = "Data were downloaded on:"
  dt = format(Sys.time(), "%Y-%m-%d")
  
  if(is.null(loc)) {
    utils::write.table(c(txt, dt), file = here::here(year, "data", "raw", "data_called.txt"),
                sep = "\t", col.names = F, row.names = F)
  } else {
    utils::write.table(c(txt, dt), file = paste0(loc, "/data_called.txt"),
                sep = "\t", col.names = F, row.names = F)
  }
}





sql_read <- function(x) {
  if(file.exists(system.file("sql", x, package = "swo"))) {
    readLines(system.file("sql", x, package = "swo"))
  } else {
    stop("The sql file does not exist.")
  }
}

collapse_filters <- function(x) {
  sprintf("'%s'", paste(x, collapse = "','"))
  }

sql_add <- function(x, sql_code, flag = "-- insert table") {

  i = suppressWarnings(grep(flag, sql_code))
  sql_code[i] <- x
  sql_code
}


sql_filter <- function(sql_precode = "=", x, sql_code, flag = "-- insert species") {
  
  i = suppressWarnings(grep(flag, sql_code))
  sql_code[i] <- paste0(
    sql_precode, " (",
    collapse_filters(x), ")"
  )
  sql_code
}

sql_run <- function(database, query) {
  query = paste(query, collapse = "\n")
  DBI::dbGetQuery(database, query, as.is=TRUE, believeNRows=FALSE)
}

WED<-function(x)
   { y<-data.table(
     weekday=weekdays(x),
     wed=ceiling_date(x, "week"),  
     plus= ifelse(weekdays(x) %in% c("Sunday"), 6, -1),
     YR=year(x))
     y$next_saturday<-date(y$wed)+y$plus
     y[YR<1993]$next_saturday<-date(y[YR<1993]$wed)
     y$yr2<-year(y$next_saturday)
     y[YR!=yr2]$next_saturday<-date(paste0(y[YR!=yr2]$YR,"-12-31"))
     return(y$next_saturday)
}


fuzzy_dates<-function(length_data=NAPBCOMB,Fish_ticket=PBFTCKT3,ndays=7){
      x<-length_data[,c('DELIVERING_VESSEL','DELIVERY_DATE')]
      y <- Fish_ticket
      y$ID<-1:nrow(y)
      y2<-y[,c("ID","DELIVERING_VESSEL","DELIVERY_DATE")]
      colnames(y2)[which(names(y2) == "DELIVERY_DATE")] <- "DELIVERY_DATE2"

  # join all combos
      x2 = full_join(x, y2, by = "DELIVERING_VESSEL")
  # just resort the data
      x2 = x2 %>% 
      arrange(DELIVERING_VESSEL, DELIVERY_DATE, DELIVERY_DATE2)
  # get absolute difference in datNAPe
      x2 = x2 %>% 
      mutate(date_diff = abs(as.Date(DELIVERY_DATE)- as.Date(DELIVERY_DATE2)))
  # subset only those that have a match
      x3<-subset(x2,!is.na(DELIVERY_DATE)&!is.na(DELIVERY_DATE2))

  # only pull the matches with the lowest difference in date
      x4 <- x3 %>% 
      group_by(DELIVERING_VESSEL, DELIVERY_DATE) %>% 
      slice(which.min(date_diff))

  # get rid of any matches greater than ndays
      x4<-subset(x4,date_diff <= ndays)
  #merge back with original length data
      x5<-merge(x,x4,by=c('DELIVERING_VESSEL','DELIVERY_DATE'), all.x=T)
      x5.1 <- subset(x5,!is.na(ID))
      x5.1=unique(x5.1[,c("DELIVERING_VESSEL","DELIVERY_DATE","ID","date_diff")])
      x6 <- merge(x5.1,y,by='ID')
      names(x6)[2:3]<-c("DELIVERING_VESSEL","DELIVERY_DATE")
      x6<-subset(x6,select=-c(DELIVERY_DATE.y,DELIVERING_VESSEL.y))
      x7<-merge(length_data,x6,by=c("DELIVERING_VESSEL","DELIVERY_DATE"),all.x=T)
      colnames(x7)[which(names(x7) == "FISH_TICKET_NO.x")] <- "FISH_TICKET_NO"
      x7$DELIVERY_DATE.y<-x7$DELIVERY_DATE
      x7$DELIVERING_VESSEL.y<-x7$DELIVERING_VESSEL
      return(x7)
}

