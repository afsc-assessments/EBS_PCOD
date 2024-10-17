library(RODBC)
library(data.table)
library(ggplot2)


akfin_user = keyring::key_list("akfin")$username ## enter AKFIN username
akfin_pwd  =  keyring::key_get("akfin", keyring::key_list("akfin")$username)   ## enter AKFIN password

akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)




Plot_CUMMULATIVE<-function(species="'PCOD'",FMP_AREA="'BSAI'",subarea="'BS'",syear=2018)
 {
  library(RODBC)
  library(data.table)
  library(ggplot2)



   test<-paste0("SELECT
    council.comprehensive_blend_ca.week_end_date,
    council.comprehensive_blend_ca.species_group_code,
    council.comprehensive_blend_ca.year,
    council.comprehensive_blend_ca.fmp_area,
    council.comprehensive_blend_ca.fmp_subarea,
    council.comprehensive_blend_ca.fmp_gear,
    council.comprehensive_blend_ca.weight_posted
  FROM
    council.comprehensive_blend_ca
  WHERE
    council.comprehensive_blend_ca.species_group_code = ",species,
    " AND council.comprehensive_blend_ca.year > ", syear,
     " AND council.comprehensive_blend_ca.fmp_area = ",FMP_AREA,
     " AND council.comprehensive_blend_ca.fmp_subarea= ",subarea )


 WED_C=sql_run(akfin, test) %>% 
         dplyr::rename_all(toupper)%>% data.table()

   ##WED_C<- data.table(sqlQuery(akfin,test))
   WED_C$WEEK<-format(as.Date(WED_C$WEEK_END_DATE,"%d-%b-%y"), "%W")
   W1<-WED_C[,list(TONS=sum(WEIGHT_POSTED)),by=c("WEEK","FMP_GEAR","YEAR")]
   W1$WEEK<-as.numeric(as.character(W1$WEEK))

  grid<-data.table(expand.grid(YEAR=unique(W1$YEAR),FMP_GEAR=unique(W1$FMP_GEAR),WEEK=0:52))

  #grid2<-grid[YEAR==2021 & WEEK<42]
  #grid<-grid[YEAR<2021]
  #grid<-rbind(grid,grid2)
  W1=merge(W1,grid,all=T)
  W1[is.na(TONS)]$TONS<-0.00

  W1<-W1[order(FMP_GEAR,YEAR,WEEK),]


  W1$CUM=W1$TONS
   for(i in 2:nrow(W1)){
     if(W1$YEAR[i]==W1$YEAR[i-1]&W1$FMP_GEAR[i]==W1$FMP_GEAR[i-1])W1$CUM[i]<-W1$TONS[i]+W1$CUM[i-1]
   }

  cYear<-year(Sys.time())
  nc=(length(unique(W1$YEAR)))-1
  okabe <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  colors=c(okabe[1:nc],'black')
  shapes=c(as.numeric(14+(1:nc)),1)
    d<- ggplot(data=W1,aes(x=WEEK,y=CUM,color=factor(YEAR),shape=factor(YEAR)))
  d<- d+geom_point()+geom_path(aes(group=YEAR))#+geom_line(data=W1[YEAR==cYear],color="black",size=1)
  d<-d+facet_wrap(~FMP_GEAR,scale="free_y")+scale_color_manual(values=colors)
  d<-d+theme_bw()+theme(axis.text.x = element_text(hjust=0, angle = 90))+scale_shape_manual(values=shapes)
  d<-d+labs(title=paste0(species," Area = ",FMP_AREA," Subarea = ",subarea), y="Cummulative Catch (t)",shape="Year",color="Year")
  print(d)
}


