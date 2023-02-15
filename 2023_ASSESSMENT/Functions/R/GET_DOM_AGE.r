# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot

GET_DOM_AGE<-function(fsh_sp_str1="99999",fsh_sp_area1="'foo'",max_age1=30)
{
    
    if(fsh_sp_area1=='AI')
    {
        region<-"539 and 544"
    }
    if(fsh_sp_area1=='GOA')
    {
        region<-"600 and 699 AND OBSINT.DEBRIEFED_AGE.NMFS_AREA != 670"
    }
    if(fsh_sp_area1=='BS')
    {
        region<-"500 and 539"
    }

  Age = readLines('sql/dom_age.sql')
  Age = sql_add(x =paste0('between ',region) , sql_code = Age, flag = '-- insert region')
  Age = sql_filter(sql_precode = "in", x =fsh_sp_str1 , sql_code = Age, flag = '-- insert species')
  
  Dage = sql_run(afsc, Age) %>% data.table() %>%
      dplyr::rename_all(toupper)

    Dage$AGE1<-Dage$AGE
    Dage$AGE1[Dage$AGE >= max_age]=max_age

    Dage
}