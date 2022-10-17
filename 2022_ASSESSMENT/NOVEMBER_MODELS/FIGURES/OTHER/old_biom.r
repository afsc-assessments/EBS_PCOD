old_biom<-function(data1){
  titl="Female spawning biomass (t)"
  nyr<-ncol(data1)-1
  
  data2<-melt(data1,"YEAR")

  d<-ggplot(data2,aes(x=YEAR,y=value,color=variable,group=variable,shape=variable,size=variable))+
     geom_point(size=1)+geom_line()+theme_bw(base_size=16)+scale_size_manual(values=c(rep(0.25,nyr-1),1))+
     scale_shape_manual(values=c(1:(nyr-1),20))+scale_color_manual(values=c(1:(nyr-1),"black"))+
     labs(x="Year",y=titl,color="Author's Model Year",shape="Author's Model Year",size="Author's Model Year")

    print(d)
}
