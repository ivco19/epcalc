 ## carga de datos desde ivco19 libs
 ## https://github.com/ivco19/libs
 ## DOI: 10.13140/RG.2.2.22519.78246
 source("load_data.R")

 ## #esto no funciona y no se por que, da error de sintaxis
 ## #cuando lo leo al file en js
 ## library('rjson')
 ## dd=load_data()
 ## jsobj=toJSON(dd)
 ## write(jsobj, "data.js")


# dd=load_data()
# load("data.Rdata")
# fis=datafis$casos_fis
 dd= read.csv("data_to_fit_nacional.csv")

 print(dd$fecha[57])

 tc=dd$confirmados_acum[57:length(dd$confirmados_acum)]

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

 tm=dd$fallecidos_acum[57:length(dd$confirmados_acum)]
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

