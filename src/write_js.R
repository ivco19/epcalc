 ## carga de datos desde ivco19 libs
 ## https://github.com/ivco19/libs
 ## DOI: 10.13140/RG.2.2.22519.78246
 ##dd <- read.csv("casos_Covid19_20200416.csv")

 ##dd <- read.csv("data_to_fit_BM.csv")
 ##tc = dd$confirmados_menores_acumulados+dd$confirmados_mayores_acumulados
 ##tr = dd$recuperados_menores_acumulados+dd$recuperados_mayores_acumulados
 ##tm = dd$fallecidos_menores_acumulados + dd$fallecidos_mayores_acumulados

 dd <- read.csv("data_to_fit_BM-sin_edad.csv")
 dd = dd[12:length(dd[[1]]),]
 tc = dd$confirmados_acumulados
 tr = dd$recuperados_acumulados
 tm = dd$fallecidos_acumulados 
 dat=tc
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

 dat=tr
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
 line=paste0(hx,as.character(ll-1))
 hy=", y: "
 line=paste0(line,hy)
 line=paste0(line,as.character(dat[ll]))
 end="}"
 line=paste0(line,end)
 outa=c(outa,line)
 outa=c(outa,"],")

 ta=tc - tr  - tm
 dat=ta
 h=" a: ["
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
 outa=c(outa,"],")

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

