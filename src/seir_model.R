# This file is part of the
#   Arcovid19 (https://ivco19.github.io/).
# Copyright (c) 2020, Arcovid Team
# License: BSD-3-Clause

library(minpack.lm)
library(deSolve)
library('rjson')
library(readr)

seir_model = function(t, state_values, parameters)
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
        as.list(parameters),  # variable names within parameters can be used
        {
            gamma= 1.0 / D_infectious
            a    = 1.0 / D_incbation
	    beta = R0s$values[1]/(D_infectious);
            for(ii in 1:length(R0s$values))
	    {
               if (t >= R0s$dias[ii]+retardo && t < R0s$dias[ii+1]+retardo)
	       {
                   beta = R0s$values[ii]/(D_infectious)
               }
            }

            # compute derivatives

            p_mild   = 1.0 - p_severe - p_fatal

            dS        = -beta * I * S
            dE        =  beta * I * S - a * E
            dI        =  a * E - gamma * I
            dMild     =  p_mild * gamma * I   - (1.0 / D_recovery_mild) * Mild
            dSevere   =  p_severe * gamma * I - (1.0 / D_hospital_lag) * Severe
            dSevere_H =  (1.0 / D_hospital_lag) * Severe - (1.0 / D_recovery_severe) * Severe_H
            dFatal    =  p_fatal * gamma * I  - (1.0 / D_death) * Fatal
            dR_Mild   =  (1.0 / D_recovery_mild) * Mild
            dR_Severe =  (1.0 / D_recovery_severe) * Severe_H
            dR_Fatal  =  (1.0 / D_death) * Fatal

            # combine results
            results = c(dS, dE, dI, dMild, dSevere, dSevere_H,
                        dFatal, dR_Mild, dR_Severe, dR_Fatal)
            list(results)
          }
     )
 }

#for debuggin in a R console, not used in the backend
get_def_params <- function()
{
    D_incbation   = 5.2
    D_infectious0 = 2.9
    Time_to_death = 17
    list(
        Time_to_death     = Time_to_death,
        D_incbation       = D_incbation,
        D_infectious      = D_infectious0,
        R0s               = list(values=c( 3.2, 2.67, 0.98, 3.2),dias=c(0,10,18,56,1500)),
        D_recovery_mild   = (8 - D_infectious0),
        D_recovery_severe = (13 - D_infectious0),
        D_hospital_lag    = 5,
        retardo           = 4,
        D_death           = Time_to_death - D_infectious0,
        p_fatal           = 0.05,
        p_severe          = 0.2,
        duration          = 38,
        N                 = 44.0e4,
        I0                = 1,
        E0                = 21,
        timepoints        = seq(0, 50, by=1)
    )
 }

 #json es el data frame de parametros, salida de fromJSON() o de get_def_params()
 get_ic <-function(json)
 {
    I0 = json$I0   # infectious hosts
    E0 = json$E0
    N  = json$N
    initial_values = c(
        S        = 1.0, #S0/(N-E0-I0),
        E        = E0 / (N - E0 - I0),
        I        = I0 / (N - E0 - I0),
        Mild     = 0,
        Severe   = 0,
        Severe_H = 0,
        Fatal    = 0,
        R_Mild   = 0,
        R_Severe = 0,
        R_Fatal  = 0)
    return(initial_values)
}

integrador <-function(args)
{
    json <- fromJSON(args)
    initial_values = get_ic(json)
    output = lsoda(initial_values, json$timepoints, seir_model, json, atol=1E-12)

    dfout = as.data.frame(output)
    for( f in colnames(dfout)[2:11])
        dfout[f]=dfout[f]*json$N
    csvdata=format_csv(dfout,col_names=FALSE)
    #para tener los nombres de columnas que ya usa cba
    head="Día,Susceptible,Expuesto,Infeccioso,Recuperándose (caso leve),Recuperándose (caso severo en el hogar),Recuperándose (caso severo en el hospital),Recuperándose (caso fatal),Recuperado (caso leve),Recuperado (caso severo),Fatalidades,\n0"

    cat(paste0(head,csvdata))
 }

 #args es json
 #args <- commandArgs(trailingOnly=TRUE)
 #integrador(args)
