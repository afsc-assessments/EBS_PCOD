plot.phase.plane <- function(SSB0,Fabc,Fmsy,BoverBmsy, FoverFmsy,xlim,ylim,header,bw.mult=1,jitter.fac=0,data=test2) {
   
   plot(x=base::jitter(BoverBmsy,jitter.fac),y=base::jitter(FoverFmsy,jitter.fac),type="l",las=1,
          yaxs="i",xaxs="i",xlab="",ylab="",col="gray50",pch=20,ylim=ylim,xlim=xlim)

  yr<-data$YEAR-1900
  yr[yr>=100]<-yr[yr>=100]-100

  for(i in 1:(length(BoverBmsy)-2)){
    text(BoverBmsy[i],FoverFmsy[i],paste(yr[i]),cex=0.85)
    }
 for(i in (length(BoverBmsy)-1):length(BoverBmsy)){
    text(BoverBmsy[i],FoverFmsy[i],paste(yr[i]),col="purple",cex=0.85,font=2)
    }




    k=Fabc/Fmsy*(((SSB0*0.2)/(SSB0*0.35))-0.05)/(1-0.05)
    k2<-0.05
    k3<-(0.2*SSB0)/(SSB0*0.35)
    points(c(k3,k3),c(0,10),type="l",lty=3)
    points(c((SB100*0.40)/(SB100*0.35),xlim[2]),c(Fabc/Fmsy,Fabc/Fmsy),type="l",lwd=2)
    points(c((SB100*0.40)/(SB100*0.35),xlim[2]),c(1,1),type="l",lwd=2,col="red")
    points(c(k3,(SB100*0.40)/(SB100*0.35)),c(k,Fabc/Fmsy),type="l",lwd=2)
    points(c(k3,k3),c( 0,k),type="l",lwd=2)
    points(c(k2,(SB100*0.40)/(SB100*0.35)),c(0,1.0),type="l",lwd=2,col="red")

    text(xlim[2]-0.5,ylim[2]-0.1,"FOFL",pos=4)
    text(xlim[2]-0.5,ylim[2]-0.2,"Max ABC",pos=4)
    text (xlim[2]-0.5,ylim[2]-0.3,"B20% (no targeting)",pos=4)

    points(c(xlim[2]-0.6,xlim[2]-0.5),c(ylim[2]-0.1,ylim[2]-0.1),lwd=2,type="l",col="red")
    points(c(xlim[2]-0.6,xlim[2]-0.5),c(ylim[2]-0.2,ylim[2]-0.2),lwd=2,type="l")
    points(c(xlim[2]-0.6,xlim[2]-0.5),c(ylim[2]-0.3,ylim[2]-0.3),type="l",lty=3)

   graphics::mtext(side=1,outer=FALSE,line=3.2,expression(B/B[35~'%']),cex=1.3)
   graphics::mtext(side=2,outer=FALSE,line=3,expression(F/F[35~'%']),cex=1.3)
   graphics::mtext(side=3,outer=FALSE,line=0.5,header,cex=1.3)
   abline(h=1,lty=2)
   abline(v=1,lty=2)
}

