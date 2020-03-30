library(minpack.lm)
 library (deSolve) 
 seir_model = function (t, state_values, parameters)
 {
 
   # create state variables (local variables)
 
   S        = state_values[1]   # susceptibles
   E        = state_values[2]   # exposed
   I        = state_values[3]   # infectious
   Mild     = state_values[4]   # Recovering (Mild)     
   Severe   = state_values[5]   # Recovering (Severe at home)
   Severe_H = state_values[6]   # Recovering (Severe in hospital)
   Fatal    = state_values[7]   # Recovering (Fatal)
   R_Mild   = state_values[8]   # Recovered                       
   R_Severe = state_values[9]   # Recovered
   R_Fatal  = state_values[10]  # Dead
 
   with ( 
     as.list (parameters),     # variable names within parameters can be used 
 
          {
      
		  if ((t > InterventionTime+retardo) && t < (InterventionTime+retardo + duration))
		  {
                       var beta = (InterventionAmt)*R0*gamma
                  } 
		  else if(t > InterventionTime+retardo + duration)
		  {
		       var beta = R0p*gamma
		  } 
		  else 
		  {
		       var beta = R0*gamma
                  }
      		  # compute derivatives
 
 
 
            p_mild   = 1 - p_severe -p_fatal

            dS        = -beta*I*S
            dE        =  beta*I*S - a*E
            dI        =  a*E - gamma*I
            dMild     =  p_mild*gamma*I   - (1/D_recovery_mild)*Mild
            dSevere   =  p_severe*gamma*I - (1/D_hospital_lag)*Severe
            dSevere_H =  (1/D_hospital_lag)*Severe - (1/D_recovery_severe)*Severe_H
            dFatal    =  p_fatal*gamma*I  - (1/D_death)*Fatal
            dR_Mild   =  (1/D_recovery_mild)*Mild
            dR_Severe =  (1/D_recovery_severe)*Severe_H
            dR_Fatal  =  (1/D_death)*Fatal

  
 
            # combine results
 
            results = c (dS,dE,dI,dMild,dSevere,dSevere_H,
                         dFatal,dR_Mild,dR_Severe,dR_Fatal)
 
            list(results)
          }
     )
 }

 #auxilar
 Time_to_death     = 32
 D_incbation       = 5.2       
 D_infectious      = 2.9 

 #ic
 I0                = 1
 E0                = 17 

 #parameters
 R0                = 3.422
 R0p               = 3.422
 D_recovery_mild   = (14 - 2.9)  
 D_recovery_severe = (31.5 - 2.9)
 D_hospital_lag    = 5
 D_death           = Time_to_death - D_infectious 
 p_fatal           = 0.021  #CFR o mu 
 InterventionTime  = 18  
 retardo  = 4  
 InterventionAmt   = 1/3
 p_severe          = 0.2
 duration          = 30
 
 #vamos a fitear beta y de ahí sacar r0
 W = 4e7  # susceptible hosts
 X = X0   # infectious hosts
 Y = 0    # recovered hosts
 Z = E0   # exposed hosts
 N = W + X + Y + Z
 timepoints = seq (0, 50, by=1)
 initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
 parameter_list = c (
           R0                = R0_value
           R0p               = R0p_value
           D_recovery_mild   = D_recovery_mild_value
           D_recovery_severe = D_recovery_severe_value
           D_hospital_lag    = D_hospital_lag_value
           D_death           = D_death_value
           p_fatal           = p_fatal_value
           InterventionTime  = InterventionTime_value
           retardo           = retardo_value
           InterventionAmt   = InterventionAmt_value
           p_severe          = p_severe_value
           duration          = duration_value
 )
 Ro = beta_value / gamma_value
 output = lsoda (initial_values, timepoints, seir_model, parameter_list)

 d<-read.table("minimal_data.dat")
 # infectious hosts over time
 dias=length(d$activos)
 betass=seq(0.8,2.0,by=0.01)
 zetass=seq(0,100,by=1)

 min=1e60
 bmin=1.17 #valor de Vane
 #R0 2.38 valor que paso pancho
 #bmin=1.236 #valor de rodrigo
 #bmin=2.38*gamma_value #2.38 valor que paso pancho

 #rango donde ajustar el modelo
 #fitpnts=5:(dias)
 fitpnts=5:24
 zmin=-1.0
 for(zeta in zetass)
 {
     for(b in betass)
     {
            #vamos a fitear beta y de ahí sacar r0
            W = 4e7        # susceptible hosts
            X = 1           # infectious hosts
            Y = 0           # recovered hosts
            Z = zeta        # exposed hosts
            N = W + X + Y + Z
            initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
          
            parameter_list = c (beta = b, gamma = gamma_value, delta = delta_value)
            output = lsoda (initial_values, timepoints, seir_model, parameter_list)
            ivec=((output[,"I"])[fitpnts])*N
            difer=sqrt(sum((d$activos[fitpnts]-ivec)*(d$activos[fitpnts]-ivec)))
            if(difer<min)
            {
                min=difer
                zmin=zeta
                bmin=b
            }
     }
 }

 #vamos a fitear beta y de ahí sacar r0
 W = 4e7        # susceptible hosts
 X = 1           # infectious hosts
 Y = 0           # recovered hosts
 Z = zmin        # exposed hosts
 N = W + X + Y + Z
 initial_values = c (S = W/N, E = Z/N, I = X/N, R = Y/N)
 Ro = bmin / gamma_value
 parameter_list = c (beta = bmin, gamma = gamma_value, delta = delta_value)
 output = lsoda (initial_values, timepoints, seir_model, parameter_list)
 print(c("R0 ",as.character(Ro)))
 print(c("bmin ",as.character(bmin)))
 print(c("zmin ",as.character(zmin)))
 ivec=output[,"I"]
 modI=ivec[1:dias]*N

 l1=paste0("R0 ",as.character(Ro))
 l2=paste0("beta ",as.character(bmin))
 l3=paste0("N de Expuestos inicial ",as.character(zmin))
 l4=paste0("Periodo infeccioso ",as.character(D_infectious))
 pdf("fit.pdf")
 plot(1:length(d$activos),d$activos,log="y",ylim=c(1,max(c(modI,d$activos))),xlab="Días",ylab="Casos Activos")
 lines(1:length(d$activos[modI>0]),modI[modI>0],col="red")
 legend("bottomright",c(l1,l2,l3,l4))

 plot(1:length(d$activos),d$activos,ylim=c(1,max(c(modI,d$activos))),xlab="Días",ylab="Casos Activos")
 lines(1:length(d$activos[modI>0]),modI[modI>0],col="red")
 legend("topleft",c(l1,l2,l3,l4))
 dev.off()

 #ivec=output[,"R"]
 #mod=ivec[1:(dias-4)]*N
 #points((1:length(d$d)),d$d+d$r,col="blue")
 #lines((5:length(d$c))[mod>0],mod[mod>0],col="blue")

