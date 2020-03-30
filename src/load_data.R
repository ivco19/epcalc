load_data <- function()
{
	#Esta funcion parsea el csv producido por ivco19 Libraries
	#https://github.com/ivco19/libs
	#descarga la base de datos en formato csv con los datos de Argentina
	#DOI: 10.13140/RG.2.2.22519.78246
	#Luego de ejecutada crea un archivo data.csv con el RAW data
	#y un archivo minimal_data.dat con los totales a nivel nacional del número
	#de casos confirmados, recuperados, activos y muertos por dia. En la salida 
	#la función devuelve un data.frame con las series temporales de estos totales.
 
	#donwload
	system("wget https://docs.google.com/spreadsheets/d/e/2PACX-1vTfinng5SDBH9RSJMHJk28dUlW3VVSuvqaBSGzU-fYRTVLCzOkw1MnY17L2tWsSOppHB96fr21Ykbyv/pub?output=csv")
        #borrado de posible version anterior
	system("rm data.csv")
        #renombrado a data.csv
	system("mv pub?output=csv data.csv")

	#numero de filas (24 (provincias)* 4 (muertos, confirmados, recuperados y activos)
	Nf=96


       	dm = read.csv2("data.csv",stringsAsFactors=FALSE)

        line=unlist(strsplit(dm[[1]][i],","))
	#numero de días desde el primer caso confirmado
	Nd=length(line) 


	#parsea cada filea buscando el string Muertos y lo suma a un array
        tm=0.0*(2:Nd)
        for(i in 1:Nf)
        {
           line=unlist(strsplit(dm[[1]][i],","))
	   #a este parseado se le puede agregar facilmente el nombre de cualquier 
	   #provincia si se requiere
           flag=sum(unlist(strsplit(line[[1]]," "))=="Muertos")
           if(flag==1)
           {
             dline=as.integer(line[(2:Nd)])
             dline[is.na(dline)] <- 0
             tm=tm+dline
           }
        }
       
	#parsea Confirmados
        tc=0.0*(2:Nd)
        for(i in 1:Nf)
        {
           line=unlist(strsplit(dm[[1]][i],","))
           flag=sum(unlist(strsplit(line[[1]]," "))=="Confirmados")
           if(flag==1)
           {
             dline=as.integer(line[(2:Nd)])
             dline[is.na(dline)] <- 0
             tc=tc+dline
           }
        }
       
	#parsea Recuperados
        tr=0.0*(2:Nd)
        for(i in 1:Nf)
        {
           line=unlist(strsplit(dm[[1]][i],","))
           flag=sum(unlist(strsplit(line[[1]]," "))=="Recuperados")
           if(flag==1)
           {
             dline=as.integer(line[(2:Nd)])
             dline[is.na(dline)] <- 0
             tr=tr+dline
           }
        }

	#parsea Activos
        ta=0.0*(2:Nd)
        for(i in 1:Nf)
        {
           line=unlist(strsplit(dm[[1]][i],","))
           flag=sum(unlist(strsplit(line[[1]]," "))=="Activos")
           if(flag==1)
           {
             dline=as.integer(line[(2:Nd)])
             dline[is.na(dline)] <- 0
             ta=ta+dline
           }
        }
 
	#plot para ver la pinta de los datos cargados
	pdf("load_data.pdf")
        plot(tc,log="y",xlab="Días",ylab="Numero de Casos",type="l")
        lines(tm,col="blue")
        lines(tr,col="green")
        lines(ta,col="red")
        legend("bottomright",c("Confirmados","Activos","Recuperados","Muertos"),lty=1,col=c("black","red","green","blue"))
 
	dev.off()

	#data.frame para el return conteniendo los totales nacionales de cada categoria
        dd=data.frame(muertos=tm,confirmados=tc,recuperados=tr, activos=ta)
	#file para poder cargar el data.frame en cualquier codigo R
        write.table(dd,file="minimal_data.dat")
	return(dd)
}
