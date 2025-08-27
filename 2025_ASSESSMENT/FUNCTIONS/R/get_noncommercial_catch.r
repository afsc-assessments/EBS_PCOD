## get noncommercial catch and export flex table 
#' @area is the generic area of interest GOA, AI, BS
#' @fyr is the first year of the time series
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
        df$Grand_Total<-rowSums(df[,2:ncol(df)],na.rm=TRUE)
        x<-c("Grand Total",colSums(df[,2:ncol(df)],na.rm=TRUE))
        df<-rbind(df,x)
        df[,2:ncol(df)] <- data.frame(lapply(df[,2:ncol(df)], as.numeric))

        ft<-flextable::flextable(df)%>%
        flextable::set_header_labels(COLLECTION_NAME = 'Collection Name',Grand_Total="Grand Total")%>%
        flextable::bold(part='header')%>%
        flextable::colformat_num(big.mark=",")%>%
        flextable::autofit()%>%flextable::theme_zebra()
        })
    ft

 }