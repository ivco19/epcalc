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

 seiard_model = function (t, state_values, parameters)
 {
 
   # create state variables (local variables)
 
   S        = state_values[1]   # susceptibles
   E        = state_values[2]   # exposed
   I        = state_values[3]   # infectious
   A        = state_values[4]   # asintomático
   Mild     = state_values[5]   # Recovering (Mild)     
   Severe   = state_values[6]   # Recovering (Severe at home)
   Severe_H = state_values[7]   # Recovering (Severe in hospital)
   Fatal    = state_values[8]   # Recovering (Fatal)
   R_Mild   = state_values[9]   # Recovered                       
   R_Severe = state_values[10]   # Recovered
   R_Fatal  = state_values[11]  # Dead
 
   with ( 
     as.list (parameters),     # variable names within parameters can be used 
                               # se añadió R0pa R0a y psym
          {
      
            gamma=1.0/D_infectious
            a    =1.0/D_incbation
	    if ((t > InterventionTime+retardo) && t < (InterventionTime+retardo + duration))
	    {
                 beta  = (InterventionAmt)*R0*gamma
                 betaA = (InterventionAmt)*R0a*gamma
            } 
	    else if(t > InterventionTime+retardo + duration)
	    {
	         beta   = R0p*gamma
	         betaA  = R0pa*gamma
	    } 
	    else 
	    {
	         beta  = R0*gamma
	         betaA = R0a*gamma
            }
      	    # compute derivatives
 
            p_mild   = 1.0 - p_severe -p_fatal


            dS=-(beta*I+betaA*A)*S
            
	    dE= (beta*I+betaA*A)*S -a*E
         
	    dI= a*psym*E - gamma*I
            dA=-gamma*A+a*(1-psym)*E
            
            dMild     =  p_mild*gamma*(I+A)   - (1.0/D_recovery_mild)*Mild
            dSevere   =  p_severe*gamma*(I+A) - (1.0/D_hospital_lag)*Severe
            dSevere_H =  (1.0/D_hospital_lag)*Severe - (1.0/D_recovery_severe)*Severe_H
            dFatal    =  p_fatal*gamma*(I+A)  - (1.0/D_death)*Fatal
            
            dR_Mild   =  (1.0/D_recovery_mild)*Mild
            dR_Severe =  (1.0/D_recovery_severe)*Severe_H
            dR_Fatal  =  (1.0/D_death)*Fatal

 
            # combine results
 
            results = c (dS,dE,dI,dA,dMild,dSevere,dSevere_H,
                         dFatal,dR_Mild,dR_Severe,dR_Fatal)
 
            list(results)
          }
     )
 }

 #auxilar
 Time_to_death     = 17

 #parameters
 D_incbation_value       = 5.2       
 D_infectious_value      = 2.9 
 R0_value                = 3.57
 R0p_value               = 3.00
 R0a_value               = 3.57 
 R0pa_value              = 3.00
 psym_value              = 0.6
 D_recovery_mild_value   = (8 - D_infectious_value)  
 D_recovery_severe_value = (13 - D_infectious_value)
 D_hospital_lag_value    = 5
 retardo_value           = 5  
 D_death_value           = Time_to_death - D_infectious_value
 p_fatal_value           = 0.021  #CFR o mu 
 InterventionTime_value  = 18  
 InterventionAmt_value   = 1.78/R0_value
 p_severe_value          = 0.2
 duration_value          = 30
 N                       = 44.0e6
 I0                      = 1   # infectious hosts
 timepoints = seq (0, 364, by=1)

 initial_values1 = c (
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

 initial_values2 = c (
   S= 1.0, #S0/(N-E0-I0),
   E=E0/(N-E0-I0),
   I=I0/(N-E0-I0),
   A=0,
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
           R0                = R0_value,
           R0p               = R0p_value, 
           R0a               = R0a_value,
           R0pa              = R0pa_value, 
           psym              = psym_value,
           D_recovery_mild   = D_recovery_mild_value,
           D_recovery_severe = D_recovery_severe_value,
           D_hospital_lag    = D_hospital_lag_value,
           D_death           = D_death_value,
           p_fatal           = p_fatal_value,
           InterventionTime  = InterventionTime_value,
           retardo           = retardo_value,
           InterventionAmt   = InterventionAmt_value,
           p_severe          = p_severe_value,
           duration          = duration_value
 )
 beta_value=R0_value/D_infectious_value
 
 output = lsoda (initial_values1, timepoints, seir_model, parameter_list)
 i1=(output[,"I"])*N
 e1=(output[,"E"])*N
 d1=(output[,"R_Fatal"])*N
  
 output2 = lsoda (initial_values2, timepoints, seiard_model, parameter_list)
 i2=(output2[,"I"])*N
 a2=(output2[,"A"])*N
 e2=(output2[,"E"])*N
 d2=(output2[,"R_Fatal"])*N

 pdf("models.pdf")
 plot(timepoints,e1,type="l",main="SEIR",lwd=1.5,ylab="Número",xlab="Días")
 lines(timepoints,i1,col="red",lwd=1.5)
 lines(timepoints,d1,col="blue",lwd=1.5)

 plot(timepoints,e2,type="l",main="SEIAR",lwd=1.5,ylab="Número",xlab="Días")
 lines(timepoints,i2+a2,col="red",lwd=1.5)
 lines(timepoints,d2,col="blue",lwd=1.5)
 lines(timepoints,a2,col="orange",lwd=1.5,lty=2)
 lines(timepoints,i2,col="darkgreen",lwd=1.5,lty=1)
 dev.off()
