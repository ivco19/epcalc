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

 d<-read.table("minimal_data.dat")
 # infectious hosts over time
 dias=length(d$c)
 betass=seq(0.3,5,by=0.01)
 zetass=seq(10,300,by=1)

 min=1e60
 bmin=1.17 #valor de Vane
 #R0 2.38 valor que paso pancho
 #bmin=1.236 #valor de rodrigo
 #bmin=2.38*gamma_value #2.38 valor que paso pancho
 zmin=-1.0
 for(zeta in zetass)
 {
        #vamos a fitear beta y de ahí sacar r0
        W = 4e7        # susceptible hosts
        X = 9           # infectious hosts
        Y = 0           # recovered hosts
        Z = zeta        # exposed hosts
        N = W + X + Y + Z
        initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
      
        parameter_list = c (beta = bmin, gamma = gamma_value, delta = delta_value)
        output = lsoda (initial_values, timepoints, seir_model, parameter_list)
     	ivec=output[,"I"]
     	ivec=ivec[1:(dias-4)]*N
     	difer=sqrt(sum((d$c[5:dias]-ivec)*(d$c[5:dias]-ivec)))
     	if(difer<min)
     	{
     	        min=difer
     	        zmin=zeta
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
 dat=d$c[5:dias]
 mod=ivec[1:(dias-4)]*N

 l1=paste0("R0 ",as.character(Ro))
 l2=paste0("beta ",as.character(bmin))
 l3=paste0("N de Expuestos inicial ",as.character(zmin))
 l4=paste0("Periodo infeccioso ",as.character(infectious_period))
 pdf("fit.pdf")
 plot(1:length(d$c),d$c,log="y",ylim=c(1,max(c(mod,dat))),xlab="Días",ylab="N Casos Confirmados")
 lines(5:length(d$c),mod[mod>0],col="red")
 legend("bottomright",c(l1,l2,l3,l4))
 dev.off()

 #ivec=output[,"R"]
 #mod=ivec[1:(dias-4)]*N
 #points((1:length(d$d)),d$d+d$r,col="blue")
 #lines((5:length(d$c))[mod>0],mod[mod>0],col="blue")

