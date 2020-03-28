 system("rm pub?output=csv")
 system("wget https://docs.google.com/spreadsheets/d/e/2PACX-1vTfinng5SDBH9RSJMHJk28dUlW3VVSuvqaBSGzU-fYRTVLCzOkw1MnY17L2tWsSOppHB96fr21Ykbyv/pub?output=csv")
 system("rm data.csv")
 system("mv pub?output=csv data.csv")

 dm = read.csv2("data.csv",stringsAsFactors=FALSE)

 tm=0
 for(i in 1:96)
 {
    line=unlist(strsplit(dm[[1]][i],","))
    flag=sum(unlist(strsplit(line[[1]]," "))=="Muertos")
    if(flag==1)
    {
      dline=as.integer(line[(2:26)])
      dline[is.na(dline)] <- 0
      tm=tm+dline
    }
 }

 tc=0
 for(i in 1:96)
 {
    line=unlist(strsplit(dm[[1]][i],","))
    flag=sum(unlist(strsplit(line[[1]]," "))=="Confirmados")
    if(flag==1)
    {
      dline=as.integer(line[(2:26)])
      dline[is.na(dline)] <- 0
      tc=tc+dline
    }
 }

 tr=0
 for(i in 1:96)
 {
    line=unlist(strsplit(dm[[1]][i],","))
    flag=sum(unlist(strsplit(line[[1]]," "))=="Recuperados")
    if(flag==1)
    {
      dline=as.integer(line[(2:26)])
      dline[is.na(dline)] <- 0
      tr=tr+dline
    }
 }

 plot(tc,log="y")
 lines(tm)
 lines(tr,col="red")

 dd=data.frame(d=tm,c=tc,r=tr)
 write.table(dd,file="minimal_data.dat")

 dat=tc[5:length(tc)]
 outa="export default {	i: ["
 ll=length(dat)
 for(i in 1:(ll-1))
 {
     hx="{ x: "
     line=paste0(hx,as.character(i-1))
     hy=", y: "
     line=paste0(line,hy)
     line=paste0(line,as.character(dat[i]))
     end="},"
     line=paste0(line,end)
     outa=c(outa,line)
 }
 hx="{ x: "
 line=paste0(hx,as.character(ll))
 hy=", y: "
 line=paste0(line,hy)
 line=paste0(line,as.character(dat[ll]))
 end="}"
 line=paste0(line,end)
 outa=c(outa,line)
 outa=c(outa,"],")

 dat=tm[5:length(tm)]
 h=" d: ["
 outa=c(outa,h)
 ll=length(dat)
 for(i in 1:(ll-1))
 {
     hx="{ x: "
     line=paste0(hx,as.character(i-1))
     hy=", y: "
     line=paste0(line,hy)
     line=paste0(line,as.character(dat[i]))
     end="},"
     line=paste0(line,end)
     outa=c(outa,line)
 }
 hx="{ x: "
 line=paste0(hx,as.character(ll))
 hy=", y: "
 line=paste0(line,hy)
 line=paste0(line,as.character(dat[ll]))
 end="}"
 line=paste0(line,end)
 outa=c(outa,line)
 outa=c(outa,"],")

 dat=tr[5:length(tr)]
 h=" r: ["
 outa=c(outa,h)
 ll=length(dat)
 for(i in 1:(ll-1))
 {
     hx="{ x: "
     line=paste0(hx,as.character(i-1))
     hy=", y: "
     line=paste0(line,hy)
     line=paste0(line,as.character(dat[i]))
     end="},"
     line=paste0(line,end)
     outa=c(outa,line)
 }
 hx="{ x: "
 line=paste0(hx,as.character(ll))
 hy=", y: "
 line=paste0(line,hy)
 line=paste0(line,as.character(dat[ll]))
 end="}"
 line=paste0(line,end)
 outa=c(outa,line)
 outa=c(outa,"]};")

fileConn<-file("data.js")
writeLines(outa, fileConn)
close(fileConn)

