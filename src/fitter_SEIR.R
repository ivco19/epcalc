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
      
            gamma=1.0/D_infectious
            a    =1.0/D_incbation
	    if ((t > InterventionTime+retardo) && t < (InterventionTime+retardo + duration))
	    {
                 beta = (InterventionAmt)*R0*gamma
            } 
	    else if(t > InterventionTime+retardo + duration)
	    {
	         beta = R0p*gamma
	    } 
	    else 
	    {
	         beta = R0*gamma
            }
      	    # compute derivatives
 
            p_mild   = 1.0 - p_severe -p_fatal

            dS        = -beta*I*S
            dE        =  beta*I*S - a*E
            dI        =  a*E - gamma*I
            dMild     =  p_mild*gamma*I   - (1.0/D_recovery_mild)*Mild
            dSevere   =  p_severe*gamma*I - (1.0/D_hospital_lag)*Severe
            dSevere_H =  (1.0/D_hospital_lag)*Severe - (1.0/D_recovery_severe)*Severe_H
            dFatal    =  p_fatal*gamma*I  - (1.0/D_death)*Fatal
            dR_Mild   =  (1.0/D_recovery_mild)*Mild
            dR_Severe =  (1.0/D_recovery_severe)*Severe_H
            dR_Fatal  =  (1.0/D_death)*Fatal

  
 
            # combine results
 
            results = c (dS,dE,dI,dMild,dSevere,dSevere_H,
                         dFatal,dR_Mild,dR_Severe,dR_Fatal)
 
            list(results)
          }
     )
 }

 #auxilar
 Time_to_death     = 17
 fact_futuro =0.5

 #parameters
 D_incbation_value       = 5.2       
 D_infectious_value      = 2.9 
 R0_value                   = 3.422
 R0p_value                  = 3.422
 #D_recovery_mild_value      = (14 - D_infectious_value)  #Goh values
 D_recovery_mild_value      = (8 - D_infectious_value)  
 #D_recovery_severe_value    = (31.5 - D_infectious_value) #Goh values
 D_recovery_severe_value    = (13 - D_infectious_value)
 D_hospital_lag_value       = 5
 retardo_value              = 4  
 D_death_value              = Time_to_death - D_infectious_value
 #p_fatal_value              = 0.021  #CFR o mu 
 p_fatal_value              = 0.03  #CFR o mu 
 InterventionTime_value     = 18  
 InterventionAmt_value      = 1.0/3.0
 p_severe_value             = 0.2
 duration_value             = 30
 
 N = 44.0e4
 I0                = 1   # infectious hosts
 timepoints = seq (0, 50, by=1)

 d<-read.table("minimal_data.dat")
 # infectious hosts over time
 dias=length(d$activos)


 #rango donde ajustar el modelo
 #fitpnts=5:(dias)


#################################################################
#minimizando R0 y E0 antes de la cuarentena
 R0ss  = seq(0.8,2.0,by=0.01)*D_infectious_value
 exposs= seq(0,100,by=1)
 fitpnts=5:18 #desde el dia 5 al dia de la cuarentena
 min=1e60
 for(E0 in exposs)
 {
     for(R0 in R0ss)
     {
            I0                = 1   # infectious hosts
            initial_values = c (
              S= 1.0, #S0/(N-E0-I0),
              E=E0/(N-E0-I0),
              I=I0/(N-E0-I0),
              Mild=0,
              Severe=0,
              Severe_H=0,
              Fatal=0,
              R_Mild=0,
              R_Severe=0,
              R_Fatal=0
            )

            parameter_list = c (
                      D_incbation       = D_incbation_value,
                      D_infectious      = D_infectious_value,
                      R0                = R0,
                      R0p               = R0*fact_futuro, 
                      D_recovery_mild   = D_recovery_mild_value,
                      D_recovery_severe = D_recovery_severe_value,
                      D_hospital_lag    = D_hospital_lag_value,
                      D_death           = D_death_value,
                      p_fatal           = p_fatal_value,
                      InterventionTime  = InterventionTime_value,
                      retardo           = retardo_value,
                      InterventionAmt   = 1.0, #cuarentena sin efecto
                      p_severe          = p_severe_value,
                      duration          = duration_value
            )
            beta_value=R0_value/D_infectious_value
          
            output = lsoda (initial_values, timepoints, seir_model, parameter_list)
            ivec=((output[,"I"])[fitpnts])*N
            difer=sqrt(sum((d$activos[fitpnts]-ivec)*(d$activos[fitpnts]-ivec)))
            if(difer<min)
            {
                min=difer
                R0min=R0
                E0min=E0
            }
     }
 }
 print(c("R0min",as.character(R0min)))
 print(c("E0min",as.character(E0min)))
#################################################################

 fitpnts=20:(length(d$muertos))
 retardoss= seq(0,15,by=1)
 min=1e60
 for(ret in retardoss)
 {
      I0                = 1   # infectious hosts
      initial_values = c (
        S= 1.0, #S0/(N-E0-I0),
        E=E0min/(N-E0min-I0),
        I=I0/(N-E0min-I0),
        Mild=0,
        Severe=0,
        Severe_H=0,
        Fatal=0,
        R_Mild=0,
        R_Severe=0,
        R_Fatal=0
      )

      parameter_list = c (
                D_incbation       = D_incbation_value,
                D_infectious      = D_infectious_value,
                R0                = R0min,
                R0p               = R0min*fact_futuro,
                D_recovery_mild   = D_recovery_mild_value,
                D_recovery_severe = D_recovery_severe_value,
                D_hospital_lag    = D_hospital_lag_value,
                D_death           = D_death_value,
                p_fatal           = p_fatal_value,
                InterventionTime  = InterventionTime_value,
                retardo           = ret, #acá no importa el retardo lo voy a fijar en los datos de mortandad
                InterventionAmt   = 1.0, #cuarentena sin efecto
                p_severe          = p_severe_value,
                duration          = duration_value
      )
      beta_value=R0_value/D_infectious_value
      
      output = lsoda (initial_values, timepoints, seir_model, parameter_list)
      ivec=((output[,"R_Fatal"])[fitpnts+ret])*N #desplazo la salida del modelo en el tiempo
      difer=sqrt(sum((d$muertos[fitpnts]-ivec)*(d$muertos[fitpnts]-ivec)))
      if(difer<min)
      {
          min=difer
          retmin=ret
      }
 }
 print(c("retmin=",as.character(retmin)))

#################################################################
#minimizando R0 despues de la cuarentena
 R0ss  = seq(0.1,3.0,by=0.01)*D_infectious_value
 fitpnts=5:dias #desde el dia 5 al dia de la cuarentena
 min=1e60
 for(R0t in R0ss)
 {
        I0                = 1   # infectious hosts
        initial_values = c (
          S= 1.0, #S0/(N-E0-I0),
          E=E0min/(N-E0min-I0),
          I=I0/(N-E0min-I0),
          Mild=0,
          Severe=0,
          Severe_H=0,
          Fatal=0,
          R_Mild=0,
          R_Severe=0,
          R_Fatal=0
        )

        parameter_list = c (
                  D_incbation       = D_incbation_value,
                  D_infectious      = D_infectious_value,
                  R0                = R0min,
                  R0p               = R0min*0.5,
                  D_recovery_mild   = D_recovery_mild_value,
                  D_recovery_severe = D_recovery_severe_value,
                  D_hospital_lag    = D_hospital_lag_value,
                  D_death           = D_death_value,
                  p_fatal           = p_fatal_value,
                  InterventionTime  = InterventionTime_value,
                  retardo           = retmin,
                  InterventionAmt   = R0t/R0min, 
                  p_severe          = p_severe_value,
                  duration          = duration_value
        )
        beta_value=R0_value/D_infectious_value
      
        output = lsoda (initial_values, timepoints, seir_model, parameter_list)
        ivec=((output[,"I"])[fitpnts])*N
        difer=sqrt(sum((d$activos[fitpnts]-ivec)*(d$activos[fitpnts]-ivec)))
        if(difer<min)
        {
            min=difer
            R0tmin=R0t
        }
 }
 print(c("R0tmin",as.character(R0tmin)))
 print(c("InverventionAmnt",as.character(R0tmin/R0min)))


 I0= 1   # infectious hosts
 initial_values = c (
   S= 1.0, #S0/(N-E0-I0),
   E=E0min/(N-E0min-I0),
   I=I0/(N-E0min-I0),
   Mild=0,
   Severe=0,
   Severe_H=0,
   Fatal=0,
   R_Mild=0,
   R_Severe=0,
   R_Fatal=0
   )

 parameter_list = c (
           D_incbation       = D_incbation_value,
           D_infectious      = D_infectious_value,
           R0                = R0min,
           #R0p               = R0p_value,
           R0p               = R0min*fact_futuro,
           D_recovery_mild   = D_recovery_mild_value,
           D_recovery_severe = D_recovery_severe_value,
           D_hospital_lag    = D_hospital_lag_value,
           D_death           = D_death_value,
           p_fatal           = p_fatal_value,
           InterventionTime  = InterventionTime_value,
           retardo           = retmin,
           #InterventionAmt   = InterventionAmt_value,
           InterventionAmt   = R0tmin/R0min,
           p_severe          = p_severe_value,
           duration          = duration_value
 )
 bmin=R0min*D_infectious_value
 

 output = lsoda (initial_values, timepoints, seir_model, parameter_list)
 print(c("bmin ",as.character(bmin)))
 ivec=output[,"I"]
 modI=ivec[(1:dias)]*N
 ivec=output[,"R_Fatal"]
 modD=ivec[(1:dias)+retmin]*N

 diasp=1:length(d$activos)
 l=paste0("R0 inicial=",as.character(R0min))
 l=c(l,paste0("Expuestos inicales=",as.character(E0min)))
 l=c(l,paste0("Retardo temporal en activos=",as.character(retmin)))
 l=c(l,paste0("Periodo infeccioso=",as.character(D_infectious_value)))
 l=c(l,paste0("R0 en la intervencion=",as.character(R0tmin)))
 l=c(l,paste0("Tiempo desde la incubación a la muerte=",as.character(Time_to_death)))
 l=c(l,paste0("Tiempo de recuperación casos leves=",as.character(8)))
 l=c(l,paste0("Tiempo de recuperación casos fuertes=",as.character(13)))
 
 pdf("fit.pdf")
 id=d$muertos>0
 ia=d$activos>0
 plot(diasp[ia],d$activos[ia],log="y",ylim=c(1,max(c(modI,d$activos))+1500),xlab="Días",ylab="Casos Activos",col="red")
 points(diasp[id],d$muertos[id],col="blue")
 lines(diasp[modI>0],modI[modI>0],col="red")
 lines(diasp[modD>0],modD[modD>0],col="blue")
 abline(v=InterventionTime_value)
 abline(v=InterventionTime_value+retmin,lty=2)
 legend("topleft",l)

 plot(diasp,d$activos,ylim=c(1,max(c(modI,d$activos))+200),xlab="Días",ylab="Casos Activos",col="red")
 lines(diasp,modI,col="red")
 lines(diasp,modD,col="blue")
 abline(v=InterventionTime_value)
 abline(v=InterventionTime_value+retmin,lty=2)
 legend("topleft",l)
 dev.off()

