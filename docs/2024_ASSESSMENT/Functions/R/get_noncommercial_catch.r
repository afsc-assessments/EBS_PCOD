## get noncommercial catch and export flex table 
#' @area is the generic area of interest GOA, AI, BS
#'@fyr is the first year of the time series
#' @sp_region_code is the regional species code 

get_noncom<-function(area=fsh_sp_area, fyr=2012, species=sp_region_code){

    suppressWarnings({
        region <- switch(area,
            GOA = 600:650,
            AI = 539:543,
            BS = 500:539,
            stop("Not a valid area")
        )

        noncom = readLines('sql/get_noncom_catch.sql')
        noncom = sql_filter(sql_precode = "IN", x = species, sql_code = noncom, flag = '-- insert code')
        noncom = sql_filter(sql_precode = "IN", x = region , sql_code = noncom, flag = '-- insert region')
        noncom = sql_filter(sql_precode = ">=", x = fyr , sql_code = noncom, flag = '-- insert fyr')
        noncom = sql_run(akfin, noncom) %>% data.table() %>%
        dplyr::rename_all(toupper)
    
        noncom$SUM_WEIGHT<-round(noncom$SUM_WEIGHT)    

        suppressMessages({
            df<-data.frame(noncom[,-3]%>% dcast(COLLECTION_NAME~COLLECTION_YEAR))
        })

    # Get the column names
        col_names <- colnames(df)
    # Remove 'X' prefix from year columns
        new_col_names <- gsub("^X", "", col_names)
        names(df)<-new_col_names

        ft<-flextable::flextable(df)
        ft<-flextable:: set_header_labels(ft, COLLECTION_NAME = 'Collection Name')
        ft<-flextable::set_table_properties(ft, width = 0.9, layout = "autofit")
        })

        ft

 }