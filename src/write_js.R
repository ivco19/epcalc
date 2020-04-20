 ## carga de datos desde ivco19 libs
 ## https://github.com/ivco19/libs
 ## DOI: 10.13140/RG.2.2.22519.78246
 dd <- read.csv("casos_Covid19_20200416.csv")
 ta=dd$nrocasos


 dat=ta
 outa="export default { c: ["
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
 line=paste0(hx,as.character(ll-1))
 hy=", y: "
 line=paste0(line,hy)
 line=paste0(line,as.character(dat[ll]))
 end="}"
 line=paste0(line,end)
 outa=c(outa,line)
 outa=c(outa,"],")

 #muertos cba
 # 1.- 29/3 - 28
 # 2.- 5/4 -  35
 # 3.- 12/4 - 42
 # 4.- 13/4 - 43
 # 5.- 14/4 - 44
 # 6.- 15/4 - 45
 tm=c(array(0,27),array(1,35-28),array(2,42-35),3,4,5,6,6)

 dat=tm
 h=" m: ["
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
 line=paste0(hx,as.character(ll-1))
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

