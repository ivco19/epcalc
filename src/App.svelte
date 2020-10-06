<script>
  
  import { scaleLinear } from "d3-scale";
  // import { Date } from "d3-time"
  import Polys from './Polys.svelte';
  import Polys2 from './Polys2.svelte';
  import { onMount } from 'svelte';
  import { selectAll } from 'd3-selection'
  import { drag } from 'd3-drag';
  import queryString from "query-string";
  import Checkbox from './Checkbox.svelte';
  import Arrow from './Arrow.svelte';
  import { format } from 'd3-format'
  import { event } from 'd3-selection'

  import katex from 'katex';

  const legendheight = 67 

  function range(n){
    return Array(n).fill().map((_, i) => i);
  }

  function formatNumber(num) {
    return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
  }

  var sum = function(arr, bools){
    var x = 0
    for (var i = 0; i < arr.length; i++) {
      x = x + arr[i]*(bools[i] ? 1 : 0)
    }
    return x
  }

  var Integrators = {
    Euler    : [[1]],
    Midpoint : [[.5,.5],[0, 1]],
    Heun     : [[1, 1],[.5,.5]],
    Ralston  : [[2/3,2/3],[.25,.75]],
    K3       : [[.5,.5],[1,-1,2],[1/6,2/3,1/6]],
    SSP33    : [[1,1],[.5,.25,.25],[1/6,1/6,2/3]],
    SSP43    : [[.5,.5],[1,.5,.5],[.5,1/6,1/6,1/6],[1/6,1/6,1/6,1/2]],
    RK4      : [[.5,.5],[.5,0,.5],[1,0,0,1],[1/6,1/3,1/3,1/6]],
    RK38     : [[1/3,1/3],[2/3,-1/3,1],[1,1,-1,1],[1/8,3/8,3/8,1/8]]
  };

  // f is a func of time t and state y
  // y is the initial state, t is the time, h is the timestep
  // updated y is returned.
  var integrate=(m,f,y,t,h)=>{
    for (var k=[],ki=0; ki<m.length; ki++) {
      var _y=y.slice(), dt=ki?((m[ki-1][0])*h):0;
      for (var l=0; l<_y.length; l++) for (var j=1; j<=ki; j++) _y[l]=_y[l]+h*(m[ki-1][j])*(k[ki-1][l]);
      k[ki]=f(t+dt,_y,dt); 
    }
    for (var r=y.slice(),l=0; l<_y.length; l++) for (var j=0; j<k.length; j++) r[l]=r[l]+h*(k[j][l])*(m[ki-1][j]);
    return r;
  }


  $: fact = 1.3
  $: Time_to_death     = 16
  $: logN              = Math.log(3.7e6)
  $: N                 = Math.exp(logN)
  $: I0                = 4
  $: E0                = 55
  $: R0                = 1.65 //1.32 // 1.5 // 1.19 //1.39 //1.39 //1.71
  $: R0_min            = 1.45 //1.16 // 1.08 //1.12  //1.10 //1.2
  $: R0_max            = 1.7  //1.47 // 1.45 //1.73  //1.66 //2.19
  $: D_incbation       = 6    // 5.2442
  $: D_infectious      = 3.35 //2.5  // 4 //2.9
  $: D_recovery_mild   = 10.0 //(8 - 2.9)
  $: D_recovery_severe = 15.6 //24  //(13 - 2.9)
  $: D_hospital_lag    = 4.38 //3
  $: D_death           = Time_to_death - D_infectious
  $: CFR               = 0.003 //0.004 //0.003
  $: DCFR               = 1.0
//  $: InterventionTime  = 19
  $: InterventionTime  = 8
  $: IntervPrevia      = 10
  $: retardo           = 0
  $: Time              = 220*fact
  $: Xmax              = 110000
  $: dt                = 2
  $: P_SEVERE          = 0.03 //0.2 (263 hospitalizados / 6310 casos activos)
  $: duration          = 70
  $: interpolation_steps  = 40
  $: laststep = 197 // 185 //158 //112
  $: R0s = {
    values: [2.77,1.3,1.16,1.12,1.47, 1.47,1.39, 1.65,R0],// infeccioso 3.35 
    //values: [2.77,1.3,1.09,1.16, 1.47,1.47,1.39,1.65,R0],//con los tiempos anteriores de incubacion e infecciosos de 2.9 y 5.1
    //  values: [2.77,1.3,1.16,1.16,1.5,   1.5,1.5, R0],
    dias: [0,  13, 35,  98, 112, 125,158,185,laststep,1500]
  }
  $: max_R0s = {
    values: [2.77,1.3,1.16,1.12,1.47, 1.47,1.39, 1.65,R0_max],// infeccioso 3.35 
    //values: [2.77,1.3,1.09,1.16, 1.47,1.47,1.39,1.65,R0_max],//con los tiempos anteriores de incubacion e infecciosos de 2.9 y 5.1
    //values: [2.77,1.3,1.16,1.16,1.5, 1.5,1.5, R0_max],
    dias: [0,  13, 35,  98, 112, 125,158,185,laststep,1500]
  }
  $: min_R0s = {
    values: [2.77,1.3,1.16,1.12,1.47, 1.47,1.39, 1.65,R0_min],// infeccioso 3.35 
    //values: [2.77,1.3,1.09,1.16, 1.47,1.47,1.39,1.65,R0_min],//con los tiempos anteriores de incubacion e infecciosos de 2.9 y 5.1
    //values: [2.77,1.3,1.16,1.16,1.5, 1.5,1.5, R0_min],
    dias: [0,  13, 35,  98, 112, 125,158,185,laststep,1500]
  }
  $: fecha = ["14/3/20","26/8/20"]
  $: lastdata = 165;


  $: state = location.protocol + '//' + location.host + location.pathname + "?" + queryString.stringify({"Time_to_death":Time_to_death,
               "logN":logN,
               "I0":I0,
               "E0":E0,
               "R0":R0,
               "R0_max":R0_max,
               "R0_min":R0_min,
               "D_incbation":D_incbation,
               "D_infectious":D_infectious,
               "D_recovery_mild":D_recovery_mild,
               "D_recovery_severe":D_recovery_severe,
               "CFR":CFR,
               "DCFR":DCFR,
               "InterventionTime":InterventionTime,
               "retardo":retardo,
               "duration":duration,
               "interpolation_steps":interpolation_steps,
               "D_hospital_lag":D_hospital_lag,
               "P_SEVERE": P_SEVERE})

  function get_solution(dt, N, I0,E0, R0ss, D_incbation,
  D_infectious,D_recovery_mild,D_hospital_lag, D_recovery_severe, D_death, P_SEVERE, CFR,DCFR,
  InterventionTime,  retardo, duration, interpolation_steps,rango) {

    // var interpolation_steps = 40
    var steps = rango*interpolation_steps
    var dt = dt/interpolation_steps
    var sample_step = interpolation_steps

    var method = Integrators["RK4"]

    function bata(t){
      var beta = R0ss.values[0]/(D_infectious);
      for(var ii = 0; ii < R0ss.values.length; ii++){
         if (t >= R0ss.dias[ii]+retardo && t < R0ss.dias[ii+1]+retardo){
           beta = R0ss.values[ii]/(D_infectious)
         }
      }
      return beta
    }
 
    function f(t, x){

      var beta = bata(t);
      var a     = 1/D_incbation
      var gamma = 1/D_infectious
      
      var S        = x[0] // Susectable
      var E        = x[1] // Exposed
      var I        = x[2] // Infectious 
      var Mild     = x[3] // Recovering (Mild)     
      var Severe   = x[4] // Recovering (Severe at home)
      var Severe_H = x[5] // Recovering (Severe in hospital)
      var Fatal    = x[6] // Recovering (Fatal)
      var R_Mild   = x[7] // Recovered
      var R_Severe = x[8] // Recovered
      var R_Fatal  = x[9] // Dead

      var p_severe = P_SEVERE
      var p_fatal  = CFR

      if(t <=50) p_fatal = 0.01;
      if(t>=50 && t<=84) p_fatal= 0.002; //p_fatal*(1-DCFR);
      if(t>=84 && t<=134) p_fatal= 0.002; //p_fatal*(1-DCFR);

      var p_mild   = 1 - P_SEVERE - CFR

      var dS        = -beta*I*S
      var dE        =  beta*I*S - a*E
      var dI        =  a*E - gamma*I
      var dMild     =  p_mild*gamma*I   - (1/D_recovery_mild)*Mild
      var dSevere   =  p_severe*gamma*I - (1/D_hospital_lag)*Severe
      var dSevere_H =  (1/D_hospital_lag)*Severe - (1/D_recovery_severe)*Severe_H
      var dFatal    =  p_fatal*gamma*I  - (1/D_death)*Fatal
      var dR_Mild   =  (1/D_recovery_mild)*Mild
      var dR_Severe =  (1/D_recovery_severe)*Severe_H
      var dR_Fatal  =  (1/D_death)*Fatal

      //      0   1   2   3      4        5          6       7        8          9
      return [dS, dE, dI, dMild, dSevere, dSevere_H, dFatal, dR_Mild, dR_Severe, dR_Fatal]
    }

    var v = [1, E0/(N-E0-I0), I0/(N-E0-I0), 0, 0, 0, 0, 0, 0, 0]
    var t = 0

    var P  = []
    var TI = []
    var Iters = []
    var tata = []
    var roro = []
    while (steps--) { 
      if ((steps+1) % (sample_step) == 0) {
            //    Dead   Hospital          Recovered        Infected   Exposed
        P.push([ N*v[9], N*(v[5]+v[6]),  N*(v[7] + v[8]), N*v[2],    N*v[1] ])
        Iters.push(v)
        TI.push(N*(1-v[0]))
        tata.push(t)
        roro.push(bata(t)*D_infectious)
        // console.log((v[0] + v[1] + v[2] + v[3] + v[4] + v[5] + v[6] + v[7] + v[8] + v[9]))
        // console.log(v[0] , v[1] , v[2] , v[3] , v[4] , v[5] , v[6] , v[7] , v[8] , v[9])
      }
      v =integrate(method,f,v,t,dt); 
      t+=dt
    }
    return {"P": P, 
            "deaths": N*v[9], 
            "total": 1-v[0],
            "total_infected": TI,
            "Iters":Iters,
            "dIters": f,
            "dias": tata,
            "R0func": roro
	    }
  }

  function max(P, rm,checked) {
    var maxi=-1.0
    for(var i = 0; i < P.length; i++){
      for(var j=0;j< P[i].length;j++){
        if(P[i][j]*checked[j]>maxi)
        {
          maxi=P[i][j];
        }
      }
      if(rm[i]*checked[7]>maxi)
      {
          maxi=rm[i];
      }

    }
    return maxi;
  }

  function sumactivos(P) {
     var rmt=[]
     for (var i = 0; i < P.length; i++) {
        rmt.push(P[i][0]+P[i][2]+P[i][3]);
     }
    return(rmt);
  }


  $: Sol     = get_solution(dt, N, I0,E0, R0s, D_incbation, D_infectious,
  D_recovery_mild,D_hospital_lag, D_recovery_severe, D_death, P_SEVERE, CFR,DCFR, InterventionTime,
  retardo,duration,interpolation_steps,110*fact)
  $: Sol_max = get_solution(dt, N, I0,E0, max_R0s, D_incbation, D_infectious,
  D_recovery_mild,D_hospital_lag, D_recovery_severe, D_death, P_SEVERE, CFR,DCFR, InterventionTime,
  retardo,duration,interpolation_steps,110*fact)
  $: Sol_min = get_solution(dt, N, I0,E0, min_R0s, D_incbation, D_infectious,
  D_recovery_mild,D_hospital_lag, D_recovery_severe, D_death, P_SEVERE, CFR,DCFR, InterventionTime,
  retardo,duration,interpolation_steps,110*fact)
  $: P              = Sol["P"].slice(0,100*fact)
  $: P_max         = Sol_max["P"].slice(0,100*fact)
  $: P_min         = Sol_min["P"].slice(0,100*fact)
  $: R0func        = Sol["R0func"].slice(0,100*fact)
  $: rm = sumactivos(P);
  $: rm1 = sumactivos(P_max);
  $: rm2 = sumactivos(P_min);
  $: timestep       = dt
  $: tmax           = dt*100*fact
  $: deaths         = Sol["deaths"]
  $: total          = Sol["total"]
  $: total_infected = Sol["total_infected"].slice(0,100*fact)
  $: Iters          = Sol["Iters"]
  $: dIters         = Sol["dIters"]
  $: Pmax           = max(P, rm, checked)
  $: r0max          = Math.max(...R0s.values)
  $: lock           = false


  // var colors = [ "#386cb0", "#8da0cb", "#4daf4a", "#f0027f", "#fdc086"]
  //var colors = [ "#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854","#ffd92f","#e5c494","#b3b3b3"]
  var colors = [ "#8dd3c7","#d1d128","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9"]

  var Plock = 1

  var drag_y = function (){
    var dragstarty = 0
    var Pmaxstart = 0

    var dragstarted = function (d) {
      dragstarty = event.y  
      Pmaxstart  = Pmax
    }

    var dragged = function (d) {
      Pmax = Math.max( (Pmaxstart*(1 + (event.y - dragstarty)/500)), 10)
    }

    return drag().on("drag", dragged).on("start", dragstarted)
  }

  var drag_x = function (){
    var dragstartx = 0
    var dtstart = 0
    var Pmaxstart = 0
    var dragstarted = function (d) {
      dragstartx = event.x
      dtstart  = dt
      Plock = Pmax
      lock = true
    }
    var dragged = function (d) {
      dt = dtstart - 0.0015*(event.x - dragstartx)
    }
    var dragend = function (d) {
      lock = false
    }
    return drag().on("drag", dragged).on("start", dragstarted).on("end", dragend)
  }

  var drag_intervention = function (){
    var dragstarty = 0
    var InterventionTimeStart = 0

    var dragstarted = function (d) {
      dragstarty = event.x  
      InterventionTimeStart = InterventionTime
      Plock = Pmax
      lock = true
    }

    var dragged = function (d) {
      // InterventionTime = Math.max( (*(1 + (event.x - dragstarty)/500)), 10)
      // console.log(event.x)
      InterventionTime = Math.min(tmax-1, Math.max(0, InterventionTimeStart + xScaleTimeInv(event.x - dragstarty)))
    }

    var dragend = function (d) {
      lock = false
    }

    return drag().on("drag", dragged).on("start", dragstarted).on("end", dragend)
  }


  var drag_intervention_end = function (){
    var dragstarty = 0
    var durationStart = 0

    var dragstarted = function (d) {
      dragstarty = event.x  
      durationStart = duration
      Plock = Pmax
      lock = true
    }

    var dragged = function (d) {
      // InterventionTime = Math.max( (*(1 + (event.x - dragstarty)/500)), 10)
      // console.log(event.x)
      duration = Math.min(tmax-1, Math.max(0, durationStart + xScaleTimeInv(event.x - dragstarty)))
    }

    var dragend = function (d) {
      lock = false
    }

    return drag().on("drag", dragged).on("start", dragstarted).on("end", dragend)
  }


  $: parsed = "";
  onMount(async () => {
    var drag_callback_y = drag_y()
    drag_callback_y(selectAll("#yAxisDrag"))
    var drag_callback_x = drag_x()
    drag_callback_x(selectAll("#xAxisDrag"))
    var drag_callback_x2 = drag_x()
    drag_callback_x2(selectAll("#xAxisDrag2"))
    var drag_callback_intervention = drag_intervention()
    // drag_callback_intervention(selectAll("#interventionDrag"))
    drag_callback_intervention(selectAll("#dottedline"))
    // var drag_callback_intervention_end = drag_intervention_end()
    // drag_callback_intervention_end(selectAll("#dottedline2"))

    if (typeof window !== 'undefined') {
      parsed = queryString.parse(window.location.search)
      if (!(parsed.logN === undefined)) {logN = parsed.logN}
      if (!(parsed.I0 === undefined)) {I0 = parseFloat(parsed.I0)}
      if (!(parsed.E0 === undefined)) {E0 = parseFloat(parsed.E0)}
      if (!(parsed.R0 === undefined)) {R0 = parseFloat(parsed.R0)}
      if (!(parsed.R0_max === undefined)) {R0_max = parseFloat(parsed.R0_max)}
      if (!(parsed.R0_min === undefined)) {R0_min = parseFloat(parsed.R0_min)}
      if (!(parsed.D_incbation === undefined)) {D_incbation = parseFloat(parsed.D_incbation)}
      if (!(parsed.D_infectious === undefined)) {D_infectious = parseFloat(parsed.D_infectious)}
      if (!(parsed.D_recovery_mild === undefined)) {D_recovery_mild = parseFloat(parsed.D_recovery_mild)}
      if (!(parsed.D_recovery_severe === undefined)) {D_recovery_severe = parseFloat(parsed.D_recovery_severe)}
      if (!(parsed.CFR === undefined)) {CFR = parseFloat(parsed.CFR)}
      if (!(parsed.DCFR === undefined)) {DCFR = parseFloat(parsed.DCFR)}
      if (!(parsed.InterventionTime === undefined)) {InterventionTime = parseFloat(parsed.InterventionTime)}
      if (!(parsed.retardo === undefined)) {retardo = parseFloat(parsed.retardo)}
      if (!(parsed.duration === undefined)) {duration = parseFloat(parsed.duration)}
      if (!(parsed.interpolation_steps === undefined)) {interpolation_steps = parseFloat(parsed.interpolation_steps)}
      if (!(parsed.D_hospital_lag === undefined)) {D_hospital_lag = parseFloat(parsed.D_hospital_lag)}
      if (!(parsed.P_SEVERE === undefined)) {P_SEVERE = parseFloat(parsed.P_SEVERE)}
      if (!(parsed.Time_to_death === undefined)) {Time_to_death = parseFloat(parsed.Time_to_death)}

    }
  });

  function lock_yaxis(){
    Plock = Pmax
    lock  = true
  }

  function unlock_yaxis(){
    lock = false
  }

  const padding = { top: 20, right: 0, bottom: 20, left: 25 };

  let width  = 750;
  let height = 500;
  let height2 = 200;

  $: xScaleTime = scaleLinear()
    .domain([0, tmax])
    .range([padding.left, width - padding.right]);

  $: xScaleTimeInv = scaleLinear()
    .domain([0, width])
    .range([0, tmax]);

  $: indexToTime = scaleLinear()
    .domain([0, P.length])
    .range([0, tmax])

  window.addEventListener('mouseup', unlock_yaxis);

  $: checked = [true, true, false, true, true,true,true,false]
  $: active  = 0
  $: active_ = active >= 0 ? active : Iters.length - 1

  var Tinc_s = "\\color{#CCC}{T^{-1}_{\\text{inc}}} "
  //var Tinf_s = "\\color{#CCC}{T^{-1}_{\\text{inf}}}"
  var Tinf_s = "\\color{#CCC}{T_{\\text{inf}}}"
  var Rt_s   = "\\color{#CCC}{\\frac{\\mathcal{R}_{t}}{T_{\\text{inf}}}} "
  $: ode_eqn = katex.renderToString("\\frac{d S}{d t}=-" +Rt_s +"\\cdot IS,\\qquad \\frac{d E}{d t}=" +Rt_s +"\\cdot IS- " + Tinc_s + " E,\\qquad \\frac{d I}{d t}=" + Tinc_s + "E-" + Tinf_s+ "I, \\qquad \\frac{d R}{d t}=" + Tinf_s+ "I", {
    throwOnError: false,
    displayMode: true,
    colorIsTextColor: true
  });

  function math_inline(str) {
    return katex.renderToString(str, {
    throwOnError: false,
    displayMode: false,
    colorIsTextColor: true
    });
  }

  function math_display(str) {
    return katex.renderToString(str, {
    throwOnError: false,
    displayMode: true,
    colorIsTextColor: true
    });
  }
  
  $: p_num_ind = 40

  $: get_d = function(i){
    return dIters(indexToTime(i), Iters[i])
  }


  function get_milestones(P,fecha,lastdata){

    function argmax(x, index) {
      return x.map((x, i) => [x[index], i]).reduce((r, a) => (a[0] > r[0] ? a : r))[1];
    }

     //    Dead   Hospital          Recovered        Infected   Exposed
    var milestones = []
    for (var i = 0; i < P.length; i++) {
      if (P[i][0] >= 99.5) {
        milestones.push([i*dt, "100 Muertos"])
        break
      }
    }

    var i = argmax(P, 1)
    milestones.push([i*dt, "Pico: " + format(",")(Math.round(P[i][1])) + " internados"])

    milestones.push([0, fecha[0]])
    milestones.push([lastdata, fecha[1]])
    return milestones
  }

  $: milestones = get_milestones(P,fecha,lastdata)
  $: log = true

  function retrieve_backend_csv(){

    alert('Falta actualizar el Backend')

///   var dias=[]
///   for (var i = 0; i < 365; i++) {
///      dias.push(i)
///   }
///
///var data = {
///    'Time_to_death': Time_to_death,
///    'D_incbation'  : D_incbation,
///    'D_infectious' : D_infectious,
///    'R0'           : R0,
///    'D_recovery_mild'  : D_recovery_mild,
///    'D_recovery_severe': D_recovery_severe,
///    'D_hospital_lag'   : D_hospital_lag,
///    'retardo': retardo,
///    'D_death': D_death,
///    'p_fatal': CFR,
///    'InterventionTime': InterventionTime,
///    'p_severe': P_SEVERE,
///    'E0': E0,
///    'duration': duration,
///    'N': N,
///    'I0': I0,
///    'timepoints': dias
///}
///
/////para un deploy local actualizar url
/////fetch('http://localhost:5001/seir', {
///fetch('https://epyrba.herokuapp.com/seir',{
///    method: 'POST',
///    headers: {
///        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
///    },
///    body: "query=" + JSON.stringify(data)
///}).then(res => {
///    if(!res.ok)
///    {
///        alert('Backend error o query bad formed')
///        throw new Error('Error en backend!');
///    }
///    return res;
///}).then(data => {
///    data.text().then(text => {
///    filename = 'resultados_precisos.csv';
///
///    if (!text.match(/^data:text\/csv/i)) {
///      text = 'data:text/csv;charset=utf-8,' + text;
///    }
///
///    var data, filename, link;
///    data = encodeURI(text);
///    link = document.createElement('a');
///    link.setAttribute('href', data);
///    link.setAttribute('download', filename);
///    document.body.appendChild(link); // Required for FF
///    link.click();
///    document.body.removeChild(link);
///
///    });
///}).catch(err => {
///    throw new Error('Error!!');
///});

  }


  function download_all_csv(){

     var Soln            = get_solution(1, N, I0,E0, R0s, D_incbation,
     D_infectious,D_recovery_mild, D_hospital_lag, D_recovery_severe, D_death, P_SEVERE, CFR,DCFR,
     InterventionTime,retardo, duration,40,365)
    var Pn              = Soln["P"]
    var dias              = Soln["dias"]
    download_csv({
    filename:"resultados_aproximados.csv",header:['Fatalidades','Hospitalizado','Recuperado','Infectado','Expuesto'],data:Pn, scale_factor:1, dias:dias });
    //download_csv({ filename: ,header:['Susceptible', 'Expuesto', 'Infectado', 'Recuperándose (caso leve)', 'Recuperándose (caso severo en el hogar)  ', 'Recuperándose (caso severo en el hospital)', 'Recuperándose (caso fatal)', 'Recuperado (caso leve)', 'Recuperado ( caso severo)', 'Fatalidades'], data:Iters, scale_factor:N, dias:dias});
  }
  function download_csv(args) {
    var data, filename, link;
    var csv = "Día,";

    if(args.header.length!=args.data[0].length){ throw 'header doesn\'t match data';}
    for(var i=0;i<args.header.length;i++){
      csv+=args.header[i]+',';
    }
    csv+='\n';

    for(var i = 0; i < args.data.length; i++){
      csv+=Math.round(args.dias[i])+',';
      for(var j=0;j<args.data[i].length;j++){
        csv+=args.data[i][j]*args.scale_factor+',';
      }
      csv+='\n';
    }

    if (csv == null) return;

    filename = args.filename || 'chart-data.csv';

    if (!csv.match(/^data:text\/csv/i)) {
      csv = 'data:text/csv;charset=utf-8,' + csv;
    }

    data = encodeURI(csv);
    link = document.createElement('a');
    link.setAttribute('href', data);
    link.setAttribute('download', filename);
    document.body.appendChild(link); // Required for FF
    link.click();
    document.body.removeChild(link);
  }
</script>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.css" integrity="sha384-bsHo4/LA+lkZv61JspMDQB9QP1TtO4IgOf2yYS+J6VdAYLVyx1c3XKcsHh0Vy8Ws" crossorigin="anonymous">

<style>
  .small { font: italic 6px Source Code Pro; }
  @import url('https://fonts.googleapis.com/css?family=Source+Code+Pro&display=swap');


  h2 {
    margin: auto;
    width: 950px;
    font-size: 40px;
    padding-top: 20px;
    padding-bottom: 20px;
    font-weight: 300;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    padding-bottom: 30px
  }

  .center {
    margin: auto;
    width: 950px;
    padding-bottom: 20px;
    font-weight: 300;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    color:#666;
    font-size: 16.5px;
    text-align: justify;
    line-height: 24px
  }

  .ack {
    margin: auto;
    width: 950px;
    padding-bottom: 20px;
    font-weight: 300;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    color:#333;
    font-size: 13px;
  }

  .row {
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    margin: auto;
    display: flex;
    width: 948px;
    font-size: 13px;
  }

  .caption {
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    font-size: 13px;    
  }

  .column {
    flex: 158px;
    padding: 0px 5px 5px 0px;
    margin: 0px 5px 5px 5px;
    /*border-top: 2px solid #999*/
  }

  .minorTitle {
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    margin: auto;
    display: flex;
    width: 950px;
    font-size: 17px;
    color: #666;
  }

  .minorTitleColumn{
    flex: 60px;
    padding: 3px;
    font-size: 20px;
    border-bottom: 2px solid #999;
  }


  .paneltext{
    position:relative;
    height:130px;
  }

  .paneltitle{
    color:#777; 
    line-height: 17px; 
    padding-bottom: 4px;
    font-weight: 700;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
  }

  .paneldesc{
    color:#888; 
    text-align: left;
    font-weight: 300;
  }

  .slidertext{
    color:#555; 
    line-height: 7px; 
    padding-bottom: 0px; 
    padding-top: 7px;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    font-family: 'Source Code Pro', monospace;
    font-size: 10px;
    text-align: right;
    /*font-weight: bold*/
  }
    
  .range {
    width: 100%;
  }

  .chart {
    width: 100%;
    margin: 0 auto;
    padding-top:0px;
    padding-bottom:10px;
  }

  .legend {
    color: #888;
    font-family: Helvetica, Arial;
    font-size: .725em;
    font-weight: 200;
    height: 100px;
    left: 20px;
    top: 4px;
    position: absolute;
  }

  .legendtitle {
    color:#777; 
    font-size:13px;
    padding-bottom: 6px;
    font-weight: 600;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
  }


  .legendtext{
    color:#888; 
    font-size:13px;
    padding-bottom: 5px;
    font-weight: 300;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    line-height: 14px;
  }

  .legendtextnum{
    color:#888; 
    font-size:13px;
    padding-bottom: 5px;
    font-weight: 300;
    line-height: 12px;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    left: -3px;
    position: relative;
  }

  .tick {
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    font-size: .725em;
    font-weight: 200;
    font-size: 13px
  }

  td { 
    text-align: left;
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    border-bottom: 1px solid #DDD;
    border-collapse: collapse;
    padding: 3px;
    /*font-size: 14px;*/
  }

  tr {
    border-collapse: collapse;
    border-spacing: 15px;
  }

  .eqn {
    font-family: nyt-franklin,helvetica,arial,sans-serif;
    margin: auto;
    display: flex;
    flex-flow: row wrap;
    width: 950px;
    column-count: 4;
    font-weight: 300;
    color:#666;
    font-size: 16.5px;
  }

  th { font-weight: 500; text-align: left; padding-bottom: 5px; vertical-align: text-top;     border-bottom: 1px solid #DDD; }

  a:link { color: grey; }
  a:visited { color: grey; }

</style>

<h2>Calculadora Epidémica SEIR</h2>
<button id="downloadCSV" on:click={download_all_csv}>Descargar resultados <br> (aproximados)</button>
<button id="downloadR" on:click={retrieve_backend_csv}>Descargar resultados <br> (precisos)</button>
  
<div class="chart" style="display: flex; max-width: 1120px">

  <div style="flex: 0 0 270px; width:270px;">
    <div style="position:relative; top:48px; right:-115px">
      <div class="legendtext" style="position:absolute; left:-16px; top:-34px; width:50px; height:
      100px; font-size: 13px; line-height:16px; font-weight: normal; text-align: center"><b>Día</b><br> {Math.round(indexToTime(active_))}</div>

      <!-- Susceptible -->
      <div style="position:absolute; left:0px; top:0px; width: 180px; height: 100px">

        <span style="pointer-events: none"><Checkbox color="#CCC"/></span>
        <Arrow height="41"/>

        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Susceptibles</div>
          <div style="padding-top: 5px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*Iters[active_][0]))} 
                                  ({ (100*Iters[active_][0]).toFixed(2) }%)</i></div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px;
	  color:#CCC">Δ</span> <i>{formatNumber(Math.round(N*get_d(active_)[0]))} / días</i>
                                 </div>
          </div>
        </div>
          <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 4px; position:relative;">Población no inmune.</div>

      </div>

      <!-- Exposed -->
      <div style="position:absolute; left:0px; top:{legendheight*1}px; width: 180px; height: 100px">

        <Checkbox color="{colors[4]}" bind:checked={checked[4]}/>      
        <Arrow height="41"/>

        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Expuestos</div>

          <div style="padding-top: 5px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*Iters[active_][1]))} 
                                  ({ (100*Iters[active_][1]).toFixed(2) }%)</div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px; color:#CCC">Δ</span> <i>{formatNumber(Math.round(N*get_d(active_)[1])) } / días</i>
                                 </div>
          </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 4px;
	position:relative;">Población en periodo de incubación.</div>

      </div>

      <!-- Infected -->
      <div style="position:absolute; left:0px; top:{legendheight*2}px; width: 180px; height: 100px">

        <Checkbox color="{colors[3]}" bind:checked={checked[3]}/>
        <Arrow height="41"/>   

        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Infectados</div>
          <div style="padding-top: 5px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*Iters[active_][2]))} 
                                  ({ (100*Iters[active_][2]).toFixed(2) }%)</div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px; color:#CCC">Δ</span> <i>{formatNumber(Math.round(N*get_d(active_)[2])) } / Día</i>
                                 </div>
          </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 4px; position:relative;">Número de infecciones circulando <i>activamente</i>.</div>


      </div>

      <!-- Removed -->
      <div style="position:absolute; left:0px; top:{legendheight*3}px; width: 180px; height: 100px">
        <Checkbox color="grey" callback={(s) => {checked[1] = s; checked[0] = s; checked[2] = s} }/>
        <Arrow height="56" arrowhead="" dasharray="3 2"/>

        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Removidos</div>
          <div style="padding-top: 10px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N* (1-Iters[active_][0]-Iters[active_][1]-Iters[active_][2])+I0 ))} 
                                  ({ ((100*(1-Iters[active_][0]-Iters[active_][1]-Iters[active_][2]-I0/N))).toFixed(2) }%)</div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px; color:#CCC">Δ</span>
	  <i>{formatNumber(Math.round(N*(get_d(active_)[3]+get_d(active_)[4]+get_d(active_)[5]+get_d(active_)[6]+get_d(active_)[7])
	  )) } / días</i>
                                 </div>
          </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 4x; position:relative;">Población no infecciosa por aislamiento o inmunidad. </div>

      </div>

      <!-- Recovered -->
      <div style="position:absolute; left:0px; top:{legendheight*4+14-3}px; width: 180px; height: 100px">
        <Checkbox color="{colors[2]}" bind:checked={checked[2]}/>
        <Arrow height="23" arrowhead="" dasharray="3 2"/>
        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Recuperados</div>

          <div style="padding-top: 3px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*(Iters[active_][7]+Iters[active_][8]) ))} 
                                  ({ (100*(Iters[active_][7]+Iters[active_][8])).toFixed(2) }%)</div>
          </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 8px; position:relative;">Recuperados</div>

      </div>

      <!-- Hospitalized -->
      <div style="position:absolute; left:0px; top:{legendheight*4+57}px; width: 180px; height: 100px">
        <Arrow height="43" arrowhead="" dasharray="3 2"/>
        <Checkbox color="{colors[1]}" bind:checked={checked[1]}/>
        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Hospitalizados</div>
          <div style="padding-top: 3px; padding-bottom: 1px">
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*(Iters[active_][5]+Iters[active_][6]) ))} 
                                  ({ (100*(Iters[active_][5]+Iters[active_][6])).toFixed(2) }%)</div>
          </div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px; color:#CCC">Δ</span> <i>{formatNumber(Math.round(N*(get_d(active_)[5]+get_d(active_)[6]))) } / días</i>
                                 </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 10px; position:relative;">Internaciones activas.</div>

      </div>


      <div style="position:absolute; left:0px; top:{legendheight*4 + 120+2}px; width: 180px; height: 100px">
        <Arrow height="40" arrowhead="" dasharray="3 2"/>

        <Checkbox color="{colors[0]}" bind:checked={checked[0]}/>

        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Difuntos</div>
          <div style="padding-top: 3px; padding-bottom: 1px">          
          <div class="legendtextnum"><span style="font-size:12px; padding-right:3px; color:#CCC">∑</span> <i>{formatNumber(Math.round(N*Iters[active_][9]))} 
                                  ({ (100*Iters[active_][9]).toFixed(2) }%)</div>
          <div class="legendtextnum"><span style="font-size:12px; padding-right:2px; color:#CCC">Δ</span> <i>{formatNumber(Math.round(N*get_d(active_)[9])) } / días</i>
                                 </div>
          </div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 10px; position:relative;">Muertes.</div>
      </div>

     <div style="position:absolute; left:0px; top:{legendheight*5 + 120+2}px; width: 180px; height: 100px">
        <Checkbox color="{colors[7]}" bind:checked={checked[7]}/>
        <div class="legend" style="position:absolute;">
          <div class="legendtitle">I+R+D</div>
        </div>
        <div class="legendtext" style="text-align: right; width:105px; left:-111px; top: 1px; position:relative;">Confirmados por el modelo.</div>
      </div>


     <!-- Data points 
      <div style="position:absolute; left:0px; top:{legendheight*4+220}px; width: 180px; height: 100px">-->
      <div style="position:absolute; left:0px; top:{legendheight*6+122}px; width: 180px; height: 100px">
        <Checkbox color="{colors[5]}" bind:checked={checked[5]}/>
        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Infectados Cba.</div>
	  <!--<div class="legendtextnum"><i>(a t - {retardo} días)</i></div>-->
        </div>
      </div>
      <!--<div style="position:absolute; left:0px; top:{legendheight*4+260}px; width: 180px; height:100px">-->
      <div style="position:absolute; left:0px; top:{legendheight*5+144}px; width: 180px; height: 100px">
        <Checkbox color="{colors[6]}" bind:checked={checked[6]}/>
        <div class="legend" style="position:absolute;">
          <div class="legendtitle">Decesos Cba.</div>
        </div>
      </div>

      <div style="position:absolute; left:0px; top:{legendheight*8 + 120+2}px; width: 180px; height: 100px">
        <div class="legend" style="position:absolute;">
          <div align="right" class="legendtitle">Ritmo reroductivo <br> básico {@html math_inline("\\mathcal{R}_t")}</div>
          <div style="padding-top: 3px; padding-bottom: 1px">          
          <div align="right" class="legendtextnum"><i> parámetros de control <br> abajo</i> </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div style="flex: 0 0 890px; width:890px; height: {height+128}px; position:relative;">

      <div style="position:relative; top:60px; left: 10px">
        <Polys bind:checked={checked}
             bind:active={active}
             y = {P} 
             y_max = {P_max} 
             y_min = {P_min} 
             toto = {rm} 
             xmax = {Xmax} 
             total_infected = {total_infected} 
             deaths = {deaths} 
             total = {total} 
             timestep={timestep}
             tmax={tmax}
             N={N}
             ymax={lock ? Plock: Pmax}
	           retardo={retardo}
             colors={colors}
             log={log}/>
      </div>

      <div id="xAxisDrag"
           style="pointer-events: all;
                  position: absolute;
                  top:{height+80}px;
                  left:{0}px;
                  width:{780}px;
                  background-color:#222;
                  opacity: 0;
                  height:25px;
                  cursor:col-resize">
      </div>

      <div id="yAxisDrag"
           style="pointer-events: all;
                  position: absolute;
                  top:{55}px;
                  left:{0}px;
                  width:{20}px;
                  background-color:#222;
                  opacity: 0;
                  height:425px;
                  cursor:row-resize">
      </div>
      <!-- Medidas previas 
      <div style="position: absolute; width:{width+15}px; height: {height}px; position: absolute; top:120px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(IntervPrevia+retardo)}px;
            visibility: {(xScaleTime(IntervPrevia+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height}px">
            <div style="flex: 0 0 160px; flex-direction:row width:120px; position:relative; top:-125px; left: -111px" >
              <div class="caption" align="right" style="pointer-events: none; position: absolute; left:0; top:40px; width:100px; border-right: 2px solid #777; padding: 5px 7px 7px 7px; ">      
                Medidas <br>Previas (13/3)
              </div>
            </div>
            <div style="flex: 0 0 10px; flex-direction:row width:120px; position:relative; top:-125px; left: 1px" >
              <div class="caption" align="left" style="pointer-events: none; position: absolute; left:0; top:40px; width:100px; padding: 5px 7px 7px 7px; ">      
                 &nbsp;→
              </div>
            </div>

          </div>
      </div>-->
      <!-- Cuarentena inicio -->
      <div style="position: absolute; width:{width+15}px; height: {height}px; position: absolute; top:120px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(InterventionTime+retardo)}px;
            visibility: {(xScaleTime(InterventionTime+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height}px">
            <div style="flex: 0 0 160px; flex-direction:row width:120px; position:relative; top:-125px; left: 1px" >
              <div class="caption" align="center" style="pointer-events: none; position: absolute; left:0; top:40px; width:100px; border-left: 2px solid #777; padding: 5px 7px 7px 7px; ">      
                Cuarentena Social<br>
                ←&nbsp;→
              </div>
            </div>
          </div>
      </div>
      <div style="position: absolute; width:{width+15}px; height: {height}px; position: absolute; top:120px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(134)}px;
            visibility: {(xScaleTime(50) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height}px">
            <div style="flex: 0 0 160px; flex-direction:row width:120px; position:relative; top:-125px; left: 1px" >
              <div class="caption" align="left" style="pointer-events: none; position: absolute; left:0; top:40px; width:100px; border-left: 2px solid #777; padding: 5px 7px 7px 7px; ">      
                CFR actual<br> (la anterior está fija)
                ({CFR*100}%)→
              </div>
            </div>
          </div>
      </div>
 
      <!-- Cuarentena final
      <div style="position: absolute; width:{width+15}px; height: {height}px; position: absolute; top:120px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(InterventionTime+duration+retardo)}px;
            visibility: {(xScaleTime(InterventionTime+duration+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height}px">
            <div style="flex: 0 0 160px; flex-direction:row width:120px; position:relative; top:-125px; left: 1px" >
              <div class="caption" style="pointer-events: none; position: absolute; left:0; top:40px; width:100px; border-left: 2px solid #777; padding: 5px 7px 7px 7px; ">      
              <div style="pointer-events: all">
                Fin Cuarentena <br>
                a los {duration} días→
                </div>
              </div>
            </div>
          </div>
      </div> -->

      <div style="pointer-events: none;
                  position: absolute;
                  top:{height+84}px;
                  left:{0}px;
                  width:{780}px;
                  opacity: 1.0;
                  height:25px;
                  cursor:col-resize">
            {#each milestones as milestone}
              <div style="position:absolute; left: {xScaleTime(milestone[0])+8}px; top: -30px;">
                <span style="opacity: 0.3"><Arrow height=30 arrowhead="#circle" dasharray = "2 1"/></span>
                  <div class="tick" style="position: relative; left: 0px; top: 35px; max-width: 130px; color: #BBB; background-color: white; padding-left: 4px; padding-right: 4px">{@html milestone[1]}</div>
              </div>
            {/each}
      </div>
    
     <div style="opacity:{xScaleTime(InterventionTime) >= 550? 0.2 : 1.0}"> 
      <div class="tick" style="color: #AAA; position:absolute; pointer-events:all; left:690px; top: 10px">
        <Checkbox color="#CCC" bind:checked={log}/><div style="position: relative; top: 4px; left:20px">escala logarítmica</div>
     </div>
    </div>

   </div>

</div>


<div class="chart" style="display: flex; max-width: 1120px">
  <div style="flex: 0 0 270px; width:270px;"> </div>
  <div style="flex: 0 0 890px; width:890px; height: 200px; position:relative;">
      <div style="position:relative; top:0px; left: 10px">
        <Polys2 bind:checked={checked}
             bind:active={active}
             y = {R0func} 
             y_max = {R0_max}
             y_min = {R0_min}
             x_max = 1500
             x_min = {laststep}
             xmax = {Xmax} 
             total_infected = {total_infected} 
             deaths = {deaths} 
             total = {total} 
             timestep={timestep}
             tmax={tmax}
             N={N}
             ymax={r0max}
             InterventionTime={InterventionTime}
	           retardo={retardo}
             colors={colors}
             log={false}/>

      </div>
      <div id="xAxisDrag2"
           style="pointer-events: all;
                  position: absolute;
                  top:{height2}px;
                  left:{0}px;
                  width:{780}px;
                  background-color:#222;
                  opacity: 0;
                  height:25px;
                  cursor:col-resize">
      </div>

      <!-- Medidas previas
      <div style="position: absolute; width:{width+15}px; height: {height2}px; position: absolute; top:40px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(IntervPrevia+retardo)}px;
            visibility: {(xScaleTime(IntervPrevia+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height2}px">
       
          </div>
      </div> -->
      <!-- Cuarentena inicio -->
      <div style="position: absolute; width:{width+15}px; height: {height2}px; position: absolute; top:40px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(InterventionTime+retardo)}px;
            visibility: {(xScaleTime(InterventionTime+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height2}px">
        </div>
      </div>
      <!-- Cuarentena final 
      <div style="position: absolute; width:{width+15}px; height: {height2}px; position: absolute; top:40px; left:10px; pointer-events: none">
        <div style="
            position: absolute;
            top:-38px;
            left:{xScaleTime(InterventionTime+duration+retardo)}px;
            visibility: {(xScaleTime(InterventionTime+duration+retardo) < (width - padding.right)) ? 'visible':'hidden'};
            width:2px;
            background-color:#FFF;
            border-right: 1px dashed black;
            cursor:col-resize;
            height:{height2}px">
          </div>
      </div>-->

      </div>

  </div>

<!-- <div style="height:220px;">
  <div class="minorTitle">
    <div style="margin: 0px 0px 5px 4px" class="minorTitleColumn">Dinámica de transmisión</div>
    <div style="flex: 0 0 20; width:20px"></div>
    <div style="margin: 0px 4px 5px 0px" class="minorTitleColumn">Dinámica Clínica</div>
  </div>-->
  <p class = "center">
  <div class="row">
    <div style="flex: 0 0 20 width:948px" class="minorTitleColumn">Dinámica de transmisión</div>
  </div>
  <div class="row">
    <div style="flex: 0 0 20; width:20px"></div>

    <div class="column">
      <div class="paneltitle" style="padding-top: 10px">Parámetros de Población</div>
      <div class="paneldesc" style="height:26px">Tamaño poblacional</div>
      <div class="slidertext">{format(",")(Math.round(N))}</div>
      <input class="range" style="margin-bottom: 8px" type=range bind:value={logN} min={5} max=25 step=0.01>
      <input style="margin-bottom: 8px" type=integer bind:value={N} min={Math.exp(5)} max={Math.exp(25)} step=1.0>
      <div class="paneldesc" style="height:20px; border-top: 1px solid #EEE; padding-top: 10px">Número de infecciones iniciales<br></div>
      <div class="slidertext"style="padding-top: 15px">{I0}</div>
      <input class="range" style="margin-bottom: 8px" type=range bind:value={I0} min={1} max=100 step=1>
      <input style="margin-bottom: 8px" type=number bind:value={I0} min={1} max=100 step=1>
      <div class="paneldesc" style="height:20px; border-top: 1px solid #EEE; padding-top: 10px; margin-bottom: 8px">Número de expuestos iniciales<br></div>
      <div class="slidertext">{E0}</div>
      <input class="range" type=range bind:value={E0} min={1} max=100 step=1>
      <input type=number bind:value={E0} min={1} max=100 step=1>
    </div>

    <div class="column">
      <div class="paneltitle" style="padding-top: 10px">Escenario futuro de propagacion {@html math_inline("\\mathcal{R}_t")} </div>
      <div class="paneldesc"> Intervalo de confianza (zona sombreada)<br></div>
      <div class="slidertext">Min({@html math_inline("\\mathcal{R}_t")})={R0_min}</div>
      <input class="range" style="margin-bottom: 8px"type=range bind:value={R0_min} min=0.01 max=10 step=0.01> 
      <input style="margin-bottom: 8px" type=number bind:value={R0_min} min=0.01 max=10 step=0.01>
      <div class="slidertext">Max({@html math_inline("\\mathcal{R}_t")})={R0_max}</div>
      <input class="range" style="margin-bottom: 8px"type=range bind:value={R0_max} min=0.01 max=10 step=0.01> 
      <input style="margin-bottom: 8px" type=number bind:value={R0_max} min=0.01 max=10 step=0.01>
 
      <div class="paneldesc"> Ritmo reproductivo medio<br></div>
      <div class="slidertext">{@html math_inline("\\mathcal{R}_t")}={R0}</div>
      <input class="range" style="margin-bottom: 8px"type=range bind:value={R0} min={R0_min} max={R0_max} step=0.01> 
      <input style="margin-bottom: 8px" type=number bind:value={R0} min={R0_min} max={R0_max} step=0.01>
    </div>

    <div class="column">
      <div class="paneltitle" style="padding-top: 10px">Tiempos</div>
      <div class="paneldesc">Periodo de incubación, {@html math_inline("T_{\\text{inc}}")}.<br></div>
      <div class="slidertext" style="margin-bottom: 6px">{(D_incbation).toFixed(2)} días</div>
      <input class="range" style="margin-bottom: 8px"type=range bind:value={D_incbation} min={0.15} max=24 step=0.0001>
      <input style="margin-bottom: 8px"type=number bind:value={D_incbation} min={0.15} max=24 step=0.0001>
      <div class="paneldesc" style="height:28px; border-top: 1px solid #EEE; padding-top: 10px">Periodo infeccioso (desde inicio de síntomas), {@html math_inline("T_{\\text{inf}}")}.<br></div>
      <div class="slidertext">{D_infectious} días</div>
      <input class="range"style="margin-bottom: 8px" type=range bind:value={D_infectious} min={0} max=24 step=0.01>
      <input style="margin-bottom: 8px"type=number bind:value={D_infectious} min={0} max=24 step=0.01>
    </div>

</div>

  <p class = "center">
  <div class="row">
    <div style="flex: 0 0 20 width:948px" class="minorTitleColumn">Dinámica Clínica</div>
  </div>
  <div class="row">
   <div style="flex: 0 0 20; width:20px"></div> 

    <div class="column">
      <div class="paneltitle"style="padding-top: 10px">Estadística de Morbilidad</div>
      <div class="paneldesc" style="height:30px">CFR*100<br></div>
      <div class="slidertext">{(CFR*100).toFixed(2)} %</div>
      <input class="range" style="margin-bottom: 8px" type=range bind:value={CFR} min={0} max=1 step=0.0001>
      <input style="margin-bottom: 8px" type=number bind:value={CFR} min={0} max=1 step=0.0001>
     <!-- <div class="paneldesc" style="height:30px">Disminución de mortandad observada<br></div>
      <div class="slidertext">{(DCFR*100).toFixed(2)} %</div>
      <input class="range" style="margin-bottom: 8px" type=range bind:value={DCFR} min={0} max=1 step=0.0001>
      <input style="margin-bottom: 8px" type=number bind:value={DCFR} min={0} max=1 step=0.01> -->

      <div class="paneldesc" style="height:29px; border-top: 1px solid #EEE; padding-top: 10px">Tiempo desde el final de la incubación a la muerte.<br></div>
      <div class="slidertext">{Time_to_death} días</div>
      <input class="range" type=range bind:value={Time_to_death} min={(D_infectious)+0.1} max=100 step=0.01>
      <input type=number bind:value={Time_to_death} min={(D_infectious)+0.1} max=100 step=0.01>
    </div>

    <div class="column">
      <div class="paneltitle"style="padding-top: 10px">Tiempos de Recuperación</div>
      <div class="paneldesc" style="height:30px">Duración de la estadía en el hospital<br></div>
      <div class="slidertext">{D_recovery_severe} días</div>
      <input class="range" style="margin-bottom: 8px" type=range bind:value={D_recovery_severe} min={0.1} max=100 step=0.01>
      <input style="margin-bottom: 8px" type=number bind:value={D_recovery_severe} min={0.1} max=100 step=0.01>
      <div class="paneldesc" style="height:29px; border-top: 1px solid #EEE; padding-top: 10px">Tiempo de recuperación en casos leves<br></div>
      <div class="slidertext">{D_recovery_mild} días</div>
      <input class="range" type=range bind:value={D_recovery_mild} min={0.5} max=100 step=0.01>
      <input type=number bind:value={D_recovery_mild} min={0.5} max=100 step=0.01>
    </div>

    <div class="column">
      <div class="paneltitle"style="padding-top: 10px">Estadística hospitalaria</div>
      <div class="paneldesc" style="height:30px">Tasa de hospitalización (Rate).<br></div>
      <div class="slidertext">{(P_SEVERE*100).toFixed(2)} %</div>
      <input class="range" style="margin-bottom: 8px"type=range bind:value={P_SEVERE} min={0} max=1 step=0.0001>      
      <input style="margin-bottom: 8px"type=number bind:value={P_SEVERE} min={0} max=1 step=0.0001>
      <div class="paneldesc" style="height:29px; border-top: 1px solid #EEE; padding-top: 10px">Tiempo hasta ser hospitalizado.<br></div>
      <div class="slidertext">{D_hospital_lag} días</div>
      <input class="range" type=range bind:value={D_hospital_lag} min={0.5} max=100 step=0.01>
      <input type=number bind:value={D_hospital_lag} min={0.5} max=100 step=0.01/>
    </div>

</div>
<div style="position: relative; height: 12px"></div>

<p class = "center"> 
Este proyecto se encuentra en el marco de las actividades llevadas a cabo por el grupo
<a href="https://ivco19.github.io/">Arcovid19</a>.
La presente calculadora implementa el modelo clásico epidemiológico &mdash 
<b><a href="https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology#The_SEIR_model">SEIR</a></b> (<b>S</b>usceptible → <span style="color:{colors[4]}"><b>E</b></span>xposed → <span style="color:{colors[3]}"><b>I</b></span>nfected → <span><b>R</b></span>emoved, en inglés), y esta basada en el trabajo del 
<a href="https://gabgoh.github.io/">Dr. Gabriel Goh</a> (<a href="https://github.com/gabgoh/epcalc">código fuente original</a>).
El modelo SEIR es un modelo idealizado de propagación utilizado comunmente en algunas
investigaciones actuales, e.g. [<a
href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30260-9/fulltext">Wu, et.
al</a>, <a href =
"https://cmmid.github.io/topics/covid19/current-patterns-transmission/wuhan-early-dynamics.html">Kucharski
et. al</a>]. La dinámica del modelo es caracterizada mediante un conjunto de cuatro ecuaciones
diferenciales ordinarias que corresponden a los diferentes estadios de la enfermedad durante su
propagación en una dada población: <span style="color:#777">{@html ode_eqn}</span> Además de la
dinámica de transmisión, este modelo permite cargar mediante parámetros de entrada información
suplementaria como la tasa de mortalidad y la carga de atención médica.
</p>
<p class ="center"> Con respecto a la versión del Dr. Goh se añadieron nuevos varias mejoras, el
código fuente es libre y puede descargarse desde el siguiente <a
href="https://github.com/ivco19/epcalc"> repositorio GIT</a>, el Dr. Dante Paz del IATE-OAC es el principal manteiner. Algunas de las modificaciones son:</p>
<p class ="center">- Definir la duración de la cuarentena 
</p>
<p class ="center">- Controlar el ritmo reproductivo en función del tiempo.
</p>
<p class ="center">- Debido a que la detección de nuevos casos es un procedimiento que puede tardar varios
días, se añadió un tiempo de retardo para modelar la demora del efecto que tiene la cuarentena
en el número de casos activos (ver figura 1 en <a
href="https://jamanetwork.com/journals/jama/fullarticle/2762130">Wu y McGoogan</a>). En la última versión
de la calculadora este tiempo de retardo no es necesario gracias a que se utiliza como datos la fecha
de inicio de sintomas. Se añadió en forma de puntos los casos activos y las muertes de COVID-20 en la provincia, para permitir
visualizar con la applet como la variación de parámetros impacta en el ajuste de los mismos.
<!--Si dispusieramos en los datos oficiales del día cuando se desarrollaron los
síntomas de cada caso ésta traslación del eje temporal no sería necesaria. Debido a esto la
serie temporal de fallecidos se encuentra desplazada en el mismo intervalo de tiempo (ya que los
fallecidos se supone que no tienen demora en ser informados).-->
</p>

<p class ="center"> En los parámetros por defecto se ajustó la curva de casos a
partir del día 5, ya que como muchos notaron a partir de ese momento empieza a
evidenciarse el comportamiento exponencial.  Encontré que no solo debía ajustar
el número reporductivo básico R, si no que además era necesiario asumir un
número de casos expuestos mayor a los casos infectados de ese día, lo cual es
razonable, ya que uno espera que antes de presentar síntomas o de ser detectado
el caso, éste pueda exponer a más personas. Los valores históricos de numero
reproductivo medio se han ido corrigiendo y ajustando en intervalos mínimos de
7 días para producir un ajuste en el número de casos. La Dra. Maria del Pilar
Díaz (Universidad Nacional de Córdoba), nos provee de los ajustes del numero
reproductivo medio para los últimos 7 días en la serie temporal de datos junto
con el intervalo de confianza correspondiente al 95% de nivel de confidencia.
Con una área sombreada representamos la varianza esperada de las predicciones
del modelo dado este intervalo de confianza, no obstante estas proyecciones no
deben extrapolarse mas allá de unos pocos días, ya que debido a la dinámica que
ha demostrado la epidemia en Córdoba y en el país, la ocurrencia de brotes y
las medidas de cuarentena las predicciones de evolución de contagios del modelo
SEIR son mas bien inestables. Pode obtenerse una idea de esto al mirar las
fluctuaciónes históricas que presentan los ajustes al parámetro R con el tiempo
(ver gráfico del panel inferior).</p>

<p class ="center"> Gracias a la generosidad de Exequiel Aguirre de la Unidad
de Emergencias y Alertas Tempranas de CONAE, se añadió la facilidad de poder
descargar los datos del modelo implementado en java script a un archivo csv,
que facilita su manipulacion en planillas de cálculo. Los resultados este
modelo tienen un error relativo por debajo del 1%. Gracias al proyecto <a
href="https://github.com/ivco19/epyRba">EPyRBa</a> pudimos implementar una
versión en R del modelo que permite descargar en archivo csv con una precisión
mayor al 0.000001%. El desarrollo de esta calculadora no hubiese sido posible
sin los aportes significativos de Juan Cabral, Rodrigo Quiroga, y todo el
equipo de <a href="https://github.com/ivco19">Arcovid19</a>. En especial
agradecemos el apoyo y asesoría de Mario Lamfri. Este proyecto público da
soporte a una versión desarrollada para el Ministerio de Salud de la Provincia
de Córdoba.  </p>



<p class = "center">
Esta calculadora puede utilizarse para medir el riesgo de exposición a la enfermedad para un día determinado de la epidemia:
Por ejemplo la probabilidad de infectarse en el día {Math.round(indexToTime(active_))} dado <a
href="https://www.cdc.gov/coronavirus/2019-ncov/hcp/guidance-risk-assesment-hcp.html">contactos cercanos</a> con <input type="text" style="width:{Math.ceil(Math.log10(p_num_ind))*9.5 + 5}px; font-size: 15.5px; color:#777" bind:value={p_num_ind}> sujetos es de {((1-(Math.pow(1 - (Iters[active_][2])*(0.45/100), p_num_ind)))*100).toFixed(5)}% dada una <a href="https://glosarios.servidor-alicante.com/epidemiologia/tasa-de-ataque">tasa de de ataque</a> del 0.45% [<a href="https://www.cdc.gov/mmwr/volumes/69/wr/mm6909e1.htm?s_cid=mm6909e1_w">Burke et. al</a>].
</p>


<p class = "center">
A continuación se presenta una muestra de estimaciones de parámetros epidémicos:
</p>

<div class="center">
<table style="width:100%; margin:auto; font-weight: 300; border-spacing: inherit">
  <tr>
    <th></th>
    <th>Lugar</th>
    <th>Ritmo reproductivo<br> {@html math_inline("\\mathcal{R}_0")}</th>
    <th>Periodo de incubación<br> {@html math_inline("T_{\\text{inc}}")} (días)</th>
    <th>Periodo infeccioso<br> {@html math_inline("T_{\\text{inf}}")} (días)</th>
  </tr>
  <tr>
    <td width="27%"><a href = "https://cmmid.github.io/topics/covid19/current-patterns-transmission/wuhan-early-dynamics.html">Kucharski et. al</a></td>
    <td>Wuhan </td>    
    <td>3.0 (1.5 — 4.5)</td>
    <td>5.2</td>
    <td>2.9</td>
  </tr>
  <tr>
    <td><a href = "https://www.nejm.org/doi/full/10.1056/NEJMoa2001316">Li, Leung and Leung</a></td>
    <td>Wuhan </td>    
    <td>2.2 (1.4 — 3.9)</td>
    <td>5.2 (4.1 — 7.0)</td>
    <td>2.3 (0.0 — 14.9)</td>
  </tr>
  <tr>
    <td><a href = "https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30260-9/fulltext">Wu et. al</a></td>
    <td>Greater Wuhan </td>    
    <td>2.68 (2.47 — 2.86)</td>
    <td>6.1</td>
    <td>2.3</td>
  </tr>
  <tr>
    <td><a href = "https://www.who.int/news-room/detail/23-01-2020-statement-on-the-meeting-of-the-international-health-regulations-(2005)-emergency-committee-regarding-the-outbreak-of-novel-coronavirus-(2019-ncov)">WHO Initial Estimate</a></td>
    <td>Hubei </td>    
    <td>1.95 (1.4 — 2.5)</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><a href = "https://www.who.int/docs/default-source/coronaviruse/who-china-joint-mission-on-covid-19-final-report.pdf">WHO-China Joint Mission </a></td>
    <td>Hubei </td>    
    <td>2.25 (2.0 — 2.5)</td>
    <td>5.5 (5.0 - 6.0)</td>
    <td></td>
  </tr>
  <tr>
    <td><a href = "https://www.biorxiv.org/content/10.1101/2020.01.25.919787v2">Liu et. al </a></td>
    <td>Guangdong</td>
    <td>4.5 (4.4 — 4.6)</td>
    <td>4.8 (2.2 — 7.4) </td>
    <td>2.9 (0 — 5.9)</td>
  </tr>
  <tr>
    <td><a href = "https://academic.oup.com/jtm/advance-article/doi/10.1093/jtm/taaa030/5766334">Rocklöv, Sjödin and Wilder-Smith</a></td>
    <td>Princess Diamond</td>
    <td>14.8</td>
    <td>5.0</td>
    <td>10.0</td>
  </tr>
  <tr>
    <td><a href = "https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2020.25.5.2000062">Backer, Klinkenberg, Wallinga</a></td>
    <td>Wuhan</td>
    <td></td>
    <td>6.5 (5.6 — 7.9)</td>
    <td></td>
  </tr>
  <tr>
    <td><a href = "https://www.medrxiv.org/content/10.1101/2020.01.23.20018549v2.article-info">Read et. al</a></td>
    <td>Wuhan</td>
    <td>3.11 (2.39 — 4.13)</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><a href = "https://www.medrxiv.org/content/10.1101/2020.03.03.20028423v1">Bi et. al</a></td>
    <td>Shenzhen</td>
    <td></td>
    <td>4.8 (4.2 — 5.4)</td>
    <td>1.5 (0 — 3.4)</td>
    <td></td>
  </tr>

  <tr>
    <td><a href = "https://www.mdpi.com/2077-0383/9/2/462">Tang et. al</a></td>
    <td>China</td>
    <td>6.47 (5.71 — 7.23)</td>
    <td></td>
    <td></td>
  </tr>

</table>
</div>


<p class="center">
Ver  [<a href="https://academic.oup.com/jtm/advance-article/doi/10.1093/jtm/taaa021/5735319">Liu et.
al</a>] para un relevamiento detallado de las estimaciones actuales del ritmo reporductivo. 
Los parámetros para las características clínicas de las enfermedades se toman de un <a href="https://www.who.int/docs/default-source/coronaviruse/who-china-joint-mission-on-covid-19-final-report.pdf">Informe de la OMS</a>. 
</p>


<p class = "center">
<b>Detalles del modelo</b><br>
La dinámica clínica en este modelo es una implementacion basada en SEIR que simula la progresión de la enfermedad 
en una &quot;resolución más alta&quot;, es decir se subdivide a {@html math_inline("I,R")} en  <i>leves</i> 
(pacientes que se recuperan sin internación), <i>moderado</i> (pacientes que requieren ser
hospitalizados pero sobreviven) y <i>fatales</i> (pacientes que son internados y no sobreviven).
Cada una de estas variables sigue su propia trayectoria hasta el resultado final, y la suma de estos compartimentos
se suman a los valores predichos por SEIR. Tenga en cuenta que suponemos, por simplicidad, que todas las muertes 
provienen de hospitales, y que todos los casos fatales son ingresados en hospitales inmediatamente después del período infeccioso.
</p>

<p class= "center">
ESTE SOFTWARE (C&Oacute;DIGO FUENTE, BINARIOS E INTERFACE WEB) SE SUMINISTRA POR EL PROYECTO ARCOVID19 Y SUS INTEGRANTES “COMO EST&Aacute;” Y CUALQUIER GARANT&Iacute;AS EXPRESA 
O IMPL&Iacute;CITA, INCLUYENDO, PERO NO LIMITADO A, LAS GARANT&Iacute;AS IMPL&Iacute;CITAS DE COMERCIALIZACI&Oacute;N Y APTITUD PARA UN PROP&Oacute;SITO PARTICULAR SON RECHAZADAS.
EN NING&Uacute;N CASO LOS INTEGRANTES DE ARCOVID19 SER&Aacute;N RESPONSABLES POR NINGÚN DA&Ntilde;O DIRECTO, INDIRECTO, INCIDENTAL, ESPECIAL, EJEMPLAR O COSECUENCIAL 
(INCLUYENDO, PERO NO LIMITADO A, LA ADQUISICI&Oacute;N O SUSTITUCI&Oacute;N DE BIENES O SERVICIOS; 
LA P&Eacute;RDIDA DE USO, DE DATOS O DE BENEFICIOS; O INTERRUPCI&Oacute;N DE LA ACTIVIDAD EMPRESARIAL) O POR CUALQUIER TEOR&Iacute;A DE RESPONSABILIDAD, YA SEA POR CONTRATO, 
RESPONSABILIDAD ESTRICTA O AGRAVIO (INCLUYENDO NEGLIGENCIA O CUALQUIER OTRA CAUSA) QUE SURJA DE CUALQUIER MANERA DEL USO DE ESTE SOFTWARE, 
INCLUSO SI SE HA ADVERTIDO DE LA POSIBILIDAD DE TALES DA&Ntilde;OS.
</p>

<!-- Input data -->
<div style="margin-bottom: 30px">

  <div class="center" style="padding: 10px; margin-top: 3px; width: 925px">
    <div class="legendtext">Parámetros para exportar:</div>
    <form>
      <textarea type="textarea" rows="1" cols="5000" style="white-space: nowrap;  overflow: auto; width:100%; text-align: left" id="fname" name="fname">{state}</textarea>
    </form>
  </div>
</div>
