# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_SURVEY_BIOM <- function(area=fsh_sp_area,species=srv_sp_str, start_yr=srv_start_yr)
{

    if(area == 'GOA') { survey = "47"
                        area_id ="99903"
                        }
    if(area == 'AI') { survey = "52"
                       area_id= "99904"
                       }
    if(area == 'BS') {survey = c(98,143)
                      area_id = c(99900,99902)
                      }
    if(area == 'SLOPE') { survey = "78"
                           area_id = "99905"
                      }

    pop = readLines('sql/survey_biom.sql')
    pop = sql_filter(sql_precode = "in", x = survey     , sql_code = pop, flag = '-- insert survey')
    pop = sql_filter(sql_precode = "in", x = area_id    , sql_code = pop, flag = '-- insert area_id')
    pop = sql_filter(sql_precode = ">=", x = srv_start_yr , sql_code = pop, flag = '-- insert start_year')
    pop = sql_filter(sql_precode =  "=", x = srv_sp_str , sql_code = pop, flag = '-- insert species')
  
    BIOM = sql_run(afsc, pop) %>% data.table() %>%
        dplyr::rename_all(toupper)

    if(fsh_sp_area=='BS'){
      pop1 = readLines('sql/survey_biom.sql')
      pop1 = sql_filter(sql_precode = "in", x = 98     , sql_code = pop1, flag = '-- insert survey')
      pop1 = sql_filter(sql_precode = "in", x = 99901    , sql_code = pop1, flag = '-- insert area_id')
      pop1 = sql_filter(sql_precode = "<", x = 1987 , sql_code = pop1, flag = '-- insert start_year')
      pop1 = sql_filter(sql_precode =  "=", x = srv_sp_str , sql_code = pop1, flag = '-- insert species')
  
    BIOM2 = sql_run(afsc, pop1) %>% data.table() %>%
        dplyr::rename_all(toupper)
    
    BIOM=rbind(BIOM2,BIOM)
    }

    BIOM

}

