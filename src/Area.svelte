<script>
  import { scaleLinear, scaleLog } from 'd3-scale';
  import { drag } from 'd3-drag';
  import { selectAll } from 'd3-selection'
  import { onMount } from 'svelte';
  import { createEventDispatcher } from 'svelte';
  import pnts from './data.js';


  const dispatch = createEventDispatcher();

  function range(n){
    return Array(n).fill().map((_, i) => i);
  }

  $: showTip = function (i) {
    active_hover = i
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

  var cuspide = function(arr, bools){
    var x = 0;
    for (var i = 0; i < arr.length; i++) {
      if((arr[i]*(bools[i]))>x) {
          x = arr[i]*(bools[i]);
      }
    }
    return x
  }


  export let y;
  export let tmax;
  export let xmax; 
  export let deaths;
  export let total;
  export let vline;
  export let timestep;
  export let total_infected;
  export let N;
  export let ymax;
  export let InterventionTime;
  export let colors; 
  export let log = false;
  export let confirmados=pnts.i;
  export let muertos=pnts.d;
  export let retardo;

  const padding = { top: 20, right: 0, bottom: 20, left: 25 };

  let width  = 750;
  let height = 420;


  $: xScale = scaleLinear()
    .domain([0, y.length])
    .range([padding.left, width - padding.right]);

  $: xScaleTime = scaleLinear()
    .domain([0, tmax])
    .range([padding.left, width - padding.right]);

  $: indexToTime = scaleLinear()
    .domain([0, y.length])
    .range([0, tmax])

  $: timeToIndex = scaleLinear()
    .domain([0, tmax])
    .range([0, y.length])

  $: yScale = (log ? scaleLog(): scaleLinear())
    .domain([log ? 1: 0,  ymax/1])
    .range([height - padding.bottom, padding.top]);

  $: yScaleL = scaleLog()
    .domain([1,  ymax/1])
    .range([0, height - padding.bottom - padding.top]);

var points0 = [];
var points1 = [];
var points2 = [];
var points3 = [];
var points4 = [];

for(var j=0;j<y.length;j++){
    var p = { 
        x: j,
        y: y[j][0]
    };
    points0.push(p);

    var p = { 
        x: j,
        y: y[j][1]
    };
    points1.push(p);

    var p = { 
        x: j,
        y: y[j][2]
    };
    points2.push(p);

    var p = { 
        x: j,
        y: y[j][3]
    };
    points3.push(p);

    var p = { 
        x: j,
        y: y[j][4]
    };
    points4.push(p);
}

	$: path0 = `M${points0.map(p => `${xScale(p.x)},${yScale(p.y)}`).join('L')}`;
	$: path1 = `M${points1.map(p => `${xScale(p.x)},${yScale(p.y)}`).join('L')}`;
	$: path2 = `M${points2.map(p => `${xScale(p.x)},${yScale(p.y)}`).join('L')}`;
	$: path3 = `M${points3.map(p => `${xScale(p.x)},${yScale(p.y)}`).join('L')}`;
	$: path4 = `M${points4.map(p => `${xScale(p.x)},${yScale(p.y)}`).join('L')}`;


  $: innerWidth = width - (padding.left + padding.right);
  $: barWidth = innerWidth / y.length - 1.5;
  $: active_hover = -1
  $: lock = false
  var active_lock = 0

  $: active = (function () {
    if (lock){
      var i = Math.round(timeToIndex(active_lock))
      if (i > 99) {
        lock = false
        i = 0
      } else {
        return i
      }
    } else {
      return active_hover
    }
  })()
  export let active;
  export let checked;

  // var data = [[2   , 2  ], [5   , 2  ], [18  , 4  ], [28  , 6  ], [43  , 8  ], [61  , 12 ], [95  , 16 ], [139 , 19 ], [245 , 26 ], [388 , 34 ], [593 , 43 ], [978 , 54 ], [1501, 66 ], [2336, 77 ], [2922, 92 ], [3513, 107], [4747, 124]]
  var data = []
</script>

<style>
  h2 {
    text-align: center;
    font-size: 30px;
    font-weight: 300;
    font-family: nyt-franklin,arial,helvetica,sans-serif;
    font-style: normal; 
  }

  .chart {
    width: 100%;
    max-width: 800px;
    margin: 0 auto;
    padding-top:30px;
    padding-bottom:10px;
  }

  svg {
    position: relative;
    width: 100%;
    height: 450px;
  }

  .tick {
    font-family: Helvetica, Arial;
    font-size: .725em;
    font-weight: 200;
  }

  .tick line {
    stroke: #e2e2e2;
    stroke-dasharray: 2;
  }

  .tick text {
    fill: #aaa;
    text-anchor: start;
  }

  .tick.tick-0 line {
    stroke-dasharray: 0;
  }

  .intervention line {
    stroke: #555;
    stroke-dasharray: 0;
    stroke-width:12.5;
  }


  .x-axis .tick text {
    text-anchor: middle;
  }

  .bar {
    stroke: none;
    opacity: 0.65
  }

  .total {
    color: #888;
    font-family: Helvetica, Arial;
    font-size: .725em;
    font-weight: 200;
  }


  a.tip span:before{
      content:'';
      display:block;
      width:0;
      height:0;
      position:absolute;

      border-top: 8px solid transparent;
      border-bottom: 8px solid transparent;
      border-right:8px solid black;
      left:-8px;

      top:7px;
  }

</style>

<div style="width:{width+15}px; height: {height}px; position: relative; top:20px">
  <svg style="position:absolute; height: {height}px">

    <!-- y axis -->
    <g class="axis y-axis" transform="translate(0,{padding.top})">
      {#each yScale.ticks(5) as tick}
        <g class="tick tick-{tick}" transform="translate(0, {yScale(tick) - padding.bottom})">
          <line x2="100%"></line>
          <text y="-4">{Number.isInteger(Math.log10(tick)) ? formatNumber(tick) : (log ? "": formatNumber(tick))}{ (tick == yScale.ticks(5)[0]) ? " ": ""}</text>
        </g>
      {/each}
    </g>

    <!-- x axis -->
    <g class="axis x-axis">
      {#each xScaleTime.ticks() as i}
        <g class="tick" transform="translate({xScaleTime(i)},{height})">
          <text x="0" y="-4">{i == 0 ? "Día ":""}{i}</text>
        </g>
      {/each}
    </g>

    <g class="points">
      {#each points0 as pnt}
    	<circle cx="{xScale(pnt.x)}" cy="{yScale(pnt.y)}" r='4' fill="{colors[0]}" style="opacity: 0.9" />
      {/each}
    </g>

    <g class="points">
      {#each confirmados as point}
    	<circle cx="{xScaleTime(point.x)}" cy="{yScale(point.y)}" r='4' fill="{colors[2]}" style="opacity: 0.9" />
      {/each}
    </g>

   <g class="points">
      {#each muertos as point}
    	<circle cx="{xScaleTime(point.x+retardo)}" cy="{yScale(point.y)}" r='4' fill="{colors[1]}" style="opacity: 0.9" />
      {/each}
    </g>

  </svg> 

  <div style="position: absolute;width:{width+15}px; height: {height}px; position: absolute; top:0px; left:0px; pointer-events: none">
   
    {#if active >= 0}
      <div style="position:absolute; 
                  pointer-events: none;
                  width:100px;
                  left:{xScale(active)}px;
                  top:{Math.max(yScale(cuspide(y[active], checked)),0) }px" class="tip"> 
          <!-- {#if lock} <div style="position:absolute; top:-35px; left:-3.5px; font-family: Source Code Pro">🔒</div> {/if} -->
          <svg style="position:absolute; top:-12px; left:0px" height="10" width="10">
          <path 
            d="M 0 0 L 10 0 L 5 10 z"
            fill="{lock ? '#555':'#AAA'}" 
            stroke-width="3" />
          </svg>
      </div>
    {/if}

  </div>

</div>
