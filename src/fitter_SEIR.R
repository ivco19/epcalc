library(minpack.lm)
 library (deSolve) 
 seir_model = function (current_timepoint, state_values, parameters)
 {
 
   # create state variables (local variables)
 
   S = state_values [1]        # susceptibles
 
   E = state_values [2]        # exposed
 
   I = state_values [3]        # infectious
 
   R = state_values [4]        # recovered
 
   
 
   with ( 
 
     as.list (parameters),     # variable names within parameters can be used 
 
          {
 
            # compute derivatives
 
            dS = (-beta * S * I)
 
            dE = (beta * S * I) - (delta * E)
 
            dI = (delta * E) - (gamma * I)
 
            dR = (gamma * I)
 
            
 
            # combine results
 
            results = c (dS, dE, dI, dR)
 
            list (results)
 
          }
 
     )
 
 }

 contact_rate = 10                     # number of contacts per day
 transmission_probability = 0.07       # transmission probability
 infectious_period = 2.9                 # infectious period
 latent_period = 5.2                     # latent period
 beta_value = contact_rate * transmission_probability
  gamma_value = 1 / infectious_period
  delta_value = 1 / latent_period
 
 
 
 #vamos a fitear beta y de ahí sacar r0
 W = 4e7        # susceptible hosts
 X = 9           # infectious hosts
 Y = 0           # recovered hosts
 Z = 12           # exposed hosts
 N = W + X + Y + Z
 timepoints = seq (0, 50, by=1)
 #initial_values = c (S = W/N, E = X/N, I = Y/N, R = Z/N)#original
 initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)#corri un bug?
 parameter_list = c (beta = beta_value, gamma = gamma_value, delta = delta_value)
 Ro = beta_value / gamma_value
 output = lsoda (initial_values, timepoints, seir_model, parameter_list)

##  plot (S ~ time, data = output, type='b', col = 'blue')       
 # susceptible hosts over time
 
##  plot (S ~ time, data = output, type='b', ylim = c(0,1), col = 'blue', ylab = 'S, E, I, R', main = 'SEIR epidemic') 
##  
##  
##  
##  # remain on same frame
##  par (new = TRUE)    
##  
##  # exposed hosts over time
##  plot (E ~ time, data = output, type='b', ylim = c(0,1), col = 'pink', ylab = '', axes = FALSE)
##  
##  # remain on same frame
##  par (new = TRUE) 
##  
##  # infectious hosts over time
##  plot (I ~ time, data = output, type='b', ylim = c(0,1), col = 'red', ylab = '', axes = FALSE) 
##  
##  
##  
##  # remain on same frame
##  par (new = TRUE)  
##  
##  
##  # recovered hosts over time
##  plot (R ~ time, data = output, type='b', ylim = c(0,1), col = 'green', ylab = '', axes = FALSE)
 
 d<-read.table("minimal_data.dat")
 # infectious hosts over time
 dias=length(d$V1)
 betass=seq(0.3,5,by=0.01)
 zetass=seq(25,35,by=1)

 min=1e60
 bmin=-1.0
 zmin=-1.0
 for(zeta in zetass)
 {
      for(b in betass)
      {
             #vamos a fitear beta y de ahí sacar r0
             W = 4e7        # susceptible hosts
             X = 9           # infectious hosts
             Y = 0           # recovered hosts
             Z = zeta        # exposed hosts
             N = W + X + Y + Z
             initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
      
             parameter_list = c (beta = b, gamma = gamma_value, delta = delta_value)
             output = lsoda (initial_values, timepoints, seir_model, parameter_list)
     	ivec=output[,"I"]
     	ivec=ivec[1:(dias-4)]*N
     	difer=sqrt(sum((d$V1[5:dias]-ivec)*(d$V1[5:dias]-ivec)))
     	if(difer<min)
     	{
     	        min=difer
     	        bmin=b
     	        zmin=zeta
     	}
      }
 }

 #vamos a fitear beta y de ahí sacar r0
 W = 4e7        # susceptible hosts
 X = 9           # infectious hosts
 Y = 0           # recovered hosts
 Z = zmin        # exposed hosts
 N = W + X + Y + Z
 initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
 Ro = bmin / gamma_value
 parameter_list = c (beta = bmin, gamma = gamma_value, delta = delta_value)
 output = lsoda (initial_values, timepoints, seir_model, parameter_list)
 ivec=output[,"I"]
 print(c("R0 ",as.character(Ro)))
 print(c("bmin ",as.character(bmin)))
 print(c("zmin ",as.character(zmin)))
 dat=d$V1[5:dias]
 mod=ivec[1:(dias-4)]*N

 plot(dat,log="y",ylim=c(min(c(mod[mod>0],dat)),max(c(mod,dat))))
 lines(mod[mod>0],col="red")

 outa="export default {	a: ["
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


# plot (I ~ time, data = output, type='b', ylim = c(0,1), col = 'red', ylab = '', axes = FALSE) 
 
 

