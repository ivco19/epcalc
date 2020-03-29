 ## carga de datos desde ivco19 libs
 ## https://github.com/ivco19/libs
 ## DOI: 10.13140/RG.2.2.22519.78246
 source("load_data.R")
 dd=load_data()
 ta=dd$activos

 dat=ta[1:length(ta)]
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

 tm=dd$muertos
 dat=tm[1:length(tm)]
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

 tr=dd$recuperados
 dat=tr[1:length(tr)]
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

