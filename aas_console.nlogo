;  Copyright (C) 2014 Lucas Batista
;  All rights reserved.

;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL LUCAS BATISTA BE LIABLE FOR ANY
;  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

__includes["library.nls"]

; Setups
to setup
  clear-all
  setupDefaults
  setupCustom

  reset-ticks
  reset-clock
  set season getSeason
  createEnvironment
end

to setupCustom

  set BaseTimeResolution time-resolution
  set SpaceResolution space-resolution
  set LogFileName "../logs/log.txt"
  if (log?)
  [
   openLogFile
  ]
end

to go
  if testStopCondition
  [stop]
  input
  update
  ai
  tick
end

to update
  set BaseTimeResolution time-resolution
  set NightAcceleration night-acceleration
  set SpaceResolution space-resolution
  set FemaleMaleRatioTolerance female-male-ratio-tolerance
  updateHalos
  updateClock
  updateStateVariables
  updateTroops
  updateEnergyLabel
end

to-report testStopCondition
  report false
end

to reset-clock
  set clock clock-start
end

to debug
  debugDisease
end

to debugDisease
  let iImuneSystem [0 0 0 0 0 0 0 0 0 1 0 0 1 0 1 0]
  let disease []
  let iDiseases []
  let code [0 1 1 0 1 0 1 0]
  let cost 5
  set disease lput code disease
  set disease lput cost disease
  set iDiseases lput disease iDiseases
  ask one-of apes
  [
   print self
   set immuneSystem iImuneSystem
   set diseases iDiseases
  ]
end

to debugImuneSystem
  ask apes
  [
   print self
   print diseases
  ]
end

to createEnvironment
  createTerrain terrain-on?
  if (plants-on?)
  [
    createPlants vegetation-density / 25
  ]
  if (trees-on?)
  [
    createTrees vegetation-density
  ]
  createAstro
  ask trees
  [
    ifelse show-energy?
   [
     set label round energy
   ]
   [
     set label ""
   ]
  ]
end

to input
  if (mouse-down?)
  [
    ifelse (mouse-action = "select-ape")
    [
      selectApe
    ]
    [
      ifelse (mouse-action = "inspect-ape")
      [
        inspect-ape
      ]
      [
        if (mouse-action = "watch-ape")
        [
          watch-ape
        ]
      ]
    ]
  ]
end

;##############################################################################################################################################

; Create

to createJuveniles
  let lRadius 5
  let xCenter 0
  let yCenter 0
  let lTroop nobody
  let lTribe nobody
  create-tribes 1
  [
    set number count tribes
    set lTribe self
    set hidden? true
  ]
  create-troops 1
  [
    set mytribe lTribe
    set lTroop self
    set shape "circle 2"
    set hidden? true
  ]
  create-apes 2
  [
    setRandomApe
    set mytroop lTroop
    set age getBaseTimeFromYears 2 1
    set sex "M"
    set sex "M"
    set strength (random-normal 10 1)
    set color scale-color red strength 5 15
    setxy (xCenter + (- lRadius + random (2 * lRadius))) (yCenter + (- lRadius + random (2 * lRadius)))
    set state "Sensing"
  ]
  updateStateVariables
  updateTribes
  ask apes
  [
    ifelse show-energy?
   [
     set label round energy
   ]
   [
     set label ""
   ]
  ]
end

to createCouple
  let lRadius 5
  let xCenter 0
  let yCenter 0
  let lTroop nobody
  let lTribe nobody
  killEntities
  create-tribes 1
  [
    set number count tribes
    set lTribe self
    set hidden? true
  ]
  create-troops 1
  [
    set mytribe lTribe
    set lTroop self
    set shape "circle 2"
    set hidden? true
  ]
  let flag true
  create-apes 2
  [
    set mytroop lTroop
    ifelse (flag)
    [
      set sex "M"
      set color blue
    ]
    [
      set sex "F"
      set color red
    ]
    set flag not flag
    setRandomSexedApe
    set age getBaseTimeFromYears 8 1
    setxy (xCenter + (- lRadius + random (2 * lRadius))) (yCenter + (- lRadius + random (2 * lRadius)))
    set state "Sensing"
  ]
  create-apes 1
  [
    set mytroop lTroop
    set sex "F"
    set color red
    set flag not flag
    setRandomSexedApe
    set age getBaseTimeFromYears 8 1
    setxy (xCenter + (- lRadius + random (2 * lRadius))) (yCenter + (- lRadius + random (2 * lRadius)))
    set pregnancy getBaseTimeFromDays 165 1
    set childFatherChromosomes [chromosomes] of one-of apes with [sex = "M"]
    set state "Sensing"
  ]
  onAfterCreateApes
end

to createFamily
  let m nobody
  let f nobody
  let lRadius 5
  let xCenter 0
  let yCenter 0
  let lTroop nobody
  let lTribe nobody
  killEntities
  create-tribes 1
  [
    set number count tribes
    set lTribe self
    set hidden? true
  ]
  create-troops 1
  [
    set mytribe lTribe
    set lTroop self
    set hidden? true
    set leader nobody
    set followers turtle-set nobody
    set hidden? true
    set shape "circle 2"
    set radius 20 / SpaceResolution
    set size radius
  ]
  create-apes 1
  [
    setRandomApe
    set age getBaseTimeFromYears 4 1
    set sex "M"
    set f self
    set color blue
    set mytroop lTroop
  ]
  create-apes 1
  [
    setRandomApe
    set age getBaseTimeFromYears 4 1
    set sex "F"
    set m self
    set childFatherChromosomes [chromosomes] of f
    set color red
    set mytroop lTroop
    deliverChild m
    set childFatherChromosomes [chromosomes] of f
    deliverChild m
  ]
  ask apes
  [
    setxy (xCenter + (- lRadius + random (2 * lRadius))) (yCenter + (- lRadius + random (2 * lRadius)))
  ]
  ask apes with [sex = "F" and age > 0]
  [
    set childFatherChromosomes [chromosomes] of f
  ]
  ask one-of apes with [age = 0]
  [
    set age getBaseTimeFromYears 2 1
  ]
  let anotherFemale nobody
  create-apes 1
  [
    setRandomApe
    set age getBaseTimeFromYears 4 1
    set sex "F"
    set m self
    set childFatherChromosomes [chromosomes] of f
    set color red
    set mytroop lTroop
    set anotherFemale self
    deliverChild m
  ]
  ask one-of apes with [age = 0 and mother = anotherFemale]
  [
    set age getBaseTimeFromYears 1 1
  ]
  onAfterCreateApes
end

to killEntities
  ask apes
  [
   die
  ]
  ask troops
  [
   die
  ]
  ask tribes
  [
   die
  ]
end

to createTribes
  killEntities
  let troopRadius 0
  let troopRows 2

  if (n-troops = 1)
  [
    set troopRows 1
  ]

  let index 0
  create-tribes n-troops
  [
    set hidden? true
    set number index
    set index index + 1
  ]

  create-troops n-troops
  [
    set mytribe nobody
  ]

  let lTribes sort tribes

  ; Create Tribes
  while [length lTribes > 0]
  [
    let lTribe item 0 lTribes
    set lTribes remove lTribe lTribes

    ask troops with [mytribe = nobody]
    [
      set mytribe lTribe
    ]
    let lTroops sort troops with [mytribe = lTribe]

    set index 0
    ; Create Troops
    while [length lTroops > 0]
    [
      let lTroop item 0 lTroops
      set lTroops remove lTroop lTroops

      ; Paint sorround
      ask lTroop
      [
        setTroop index self n-troops troopRows

        if terrain-on?
        [
          ask patches in-radius (size / 2.5)
          [
            set pcolor scale-color brown (1 - (0.15 * (1 + index))) 0 1
          ]
          repeat 3
          [
            ask patches in-radius (size / 2.5)
            [
              let avgColor (sum [pcolor] of neighbors) / (count neighbors)
              set pcolor avgColor
            ]
          ]
        ]
        set troopRadius size / 4
      ]
      let xCenter [xcor] of lTroop
      let yCenter [ycor] of lTroop
      create-apes (n-apes / n-troops)
      [
        setxy (xCenter + (- troopRadius + random (2 * troopRadius))) (yCenter + (- troopRadius + random (2 * troopRadius)))
        ifelse (random-float 1.0 < initial-female-male-proportion)
        [
          set sex "F"
        ]
        [
         set sex "M"
        ]
        setRandomSexedApe
        set mytroop lTroop
        set color [color] of lTroop
        set state "Sensing"
      ]
      set index index + 1
    ]
  ]
  updateTribes
  onAfterCreateApes
end

to createHalos
  let apesList sort apes
  foreach apesList
  [
    create-halos 1
    [
      setxy [xcor] of ? [ycor] of ?
      set myape ?
      set size [vision] of ? / SpaceResolution
      set shape "circle 2"
      set hidden? not halos-on?
    ]
  ]
end

; Sets troop location and state variables
to setTroop [lNumber lTroop nTroops troopRows]

  let worldWidth getWorldWidth
  let worldHeight getWorldHeight
  let troopOffset worldHeight / nTroops
  let troopCols nTroops / troopRows

  ask lTroop
  [

    ask troops
    [
      set hidden? not show-troops?
    ]
    set shape "circle 2"

    let troopCol (lNumber mod troopCols)
    let troopRow (floor (lNumber / troopCols))

    let xOffset worldWidth / (troopCols + 1)
    let yOffset worldHeight / (troopRows)

    set radius yOffset
    set size radius

    set xcor ((troopCol) * xOffset) + min-pxcor + xOffset
    set ycor ((troopRow) * yOffset) + min-pycor + yOffset / 2

    if (nTroops mod 2 != 0 and nTroops != 1)
    [
      set xcor xcor - xOffset / 3
    ]

    set color item (lNumber + 1) base-colors

  ]

end

to onAfterCreateApes
  updateStateVariables
  if (create-halos?)
  [
    createHalos
  ]
  ask apes
  [
    ifelse show-energy?
   [
     set label round energy
   ]
   [
     set label ""
   ]
  ]
end

;##############################################################################################################################################

; Scenario Types

to setScenario [tribeRadius scenario]
  let ntrees vegetation-density / 100 * (SpaceResolution) * (getWorldArea / patch-size)

  let groups []
  let group []
  let index 0
  let tribesList sort tribes
  let treesPerTribe floor ((count trees) / (n-troops))

  foreach sort trees
  [
    set group lput ? group
    set index index + 1
    if ((index mod treesPerTribe) = 0)
    [
     set groups lput group groups
     set group []
    ]
  ]

  set index 0
  foreach groups
  [
    let tri item index tribesList
    ask (turtle-set ?)
    [
      ifelse (scenario = "Islands")
      [
        setxy random-normal ([xcor] of tri) (2 * tribeRadius) random-normal ([ycor] of tri) (2 * tribeRadius)
      ]
      [
       if (scenario = "Oasis")
       [
         setxy (([xcor] of tri - 2 * tribeRadius) + (random (4 * tribeRadius))) (([ycor] of tri - 2 * tribeRadius) + (random (4 * tribeRadius)))
       ]
      ]
    ]
    set index index + 1
  ]

end

;##############################################################################################################################################

; Update

to updateHalos
  ask halos
  [
    let lMe self
    let lApe one-of apes with [[myape] of lMe = self]
    ifelse (lApe != nobody)
    [
      setxy [xcor] of lApe [ycor] of lApe
      set size [vision] of lApe / SpaceResolution
      ifelse (halos-on?)
      [set hidden? false]
      [set hidden? true]
    ]
    [die]
  ]
end

to updateTroops
  ask troops
  [
    set hidden? not show-troops?
    ifelse (troop-pen?)
    [
      pen-down
    ]
    [
      pen-up
    ]
    if (leader != nobody)
    [
     ask leader
     [
       ifelse (leader-pen?)
       [
         pen-down
       ]
       [
        pen-up
       ]
     ]
    ]
  ]
end

to updateEnergyLabel
  let tSet (turtle-set apes trees)
  ask tSet
  [
   ifelse show-energy?
   [
     set label round energy
   ]
   [
     set label ""
   ]
  ]
end

;##############################################################################################################################################

; Actions

to selectApe
  let selectedApe getApeIn 3
  if (selectedApe != nobody)
  [
    ask selectedApe
    [
      set ape-number who
    ]
  ]
end

;##############################################################################################################################################

; Events

to fed
  ask apes with [ape-number = who]
  [
    let event createFedEvent 10
    raiseEvent self event
  ]
end

to assaulted
  let attacker nobody
  ask apes with [ape2-number = who]
  [
    set attacker self
  ]
  ask apes with [ape-number = who]
  [
    let event createAssaultedEvent attacker
    raiseEvent self event
  ]
end

;##############################################################################################################################################

; UI

to create-ape-tribes
  createTribes
end

to create-family
  createFamily
end

to create-juveniles
  createJuveniles
end

to create-couple
  createCouple
end

to inspect-ape
  let selectedApe getApeIn 3
  if (selectedApe != nobody)
  [
    ask selectedApe
    [
      inspect selectedApe
    ]
  ]
end

to watch-ape
  let selectedApe getApeIn 3
  if (selectedApe != nobody)
  [
    ask selectedApe
    [
      watch-me
    ]
  ]
end

to fwd
  ask apes with [ape-number = who]
  [
    ifelse(walking-state = "walk")
    [walk]
    [
      ifelse (walking-state = "walkFast")
      [walkFast]
      [runFastest]
    ]
  ]
end

to <-
  ask apes with [ape-number = who]
  [
    lt 10
  ]
end

to ->
  ask apes with [ape-number = who]
  [
    rt 10
  ]
end

to attack-target
  ask apes with [ape-number = who]
  [
    if (targetedEnemy != nobody)
    [
      attack self targetedEnemy
    ]
  ]
end

to replenish-energy
  ask apes with [ape-number = who]
  [
    forage self
  ]
end

to strike-target
  let lWho nobody
  let lTargetedEnemy nobody
  ask apes with [ape-number = who]
  [
    set lWho self
    set lTargetedEnemy one-of targetedEnemy in-radius attackRange
  ]
  if (lTargetedEnemy != nobody)
  [
    strike lWho lTargetedEnemy
  ]
end

to run-away
  ask apes with [ape-number = who]
  [
    runFastest
  ]
end

to go-home
  ask apes
  [
   goHome
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
420
10
1728
810
132
78
4.9
1
10
1
1
1
0
0
0
1
-132
132
-78
78
1
1
1
ticks
30.0

BUTTON
11
10
74
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
79
10
142
43
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
148
10
211
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
202
181
235
n-apes
n-apes
1
200
50
1
1
NIL
HORIZONTAL

SLIDER
9
236
181
269
n-troops
n-troops
1
6
1
1
1
NIL
HORIZONTAL

SLIDER
10
270
182
303
vegetation-density
vegetation-density
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
10
304
182
337
troop-threshold
troop-threshold
5
100
10
1
1
NIL
HORIZONTAL

BUTTON
9
493
114
526
NIL
attack-target
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

TEXTBOX
14
389
164
407
Ape Commands
14
0.0
1

BUTTON
212
417
275
450
NIL
fwd
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
180
451
243
484
NIL
<-
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
244
451
307
484
NIL
->
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

INPUTBOX
12
423
91
483
ape-number
852
1
0
Number

BUTTON
9
534
116
567
NIL
replenish-energy
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
122
535
207
568
NIL
run-away
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
123
495
208
528
NIL
strike-target
NIL
1
T
OBSERVER
NIL
F
NIL
NIL
1

MONITOR
207
117
264
162
Day
getDay clock 1
0
1
11

INPUTBOX
11
50
97
110
time-resolution
60
1
0
Number

MONITOR
96
117
153
162
Year
getYear clock 1
0
1
11

INPUTBOX
99
50
193
110
space-resolution
1
1
0
Number

MONITOR
155
117
205
162
Month
getMonth clock 1
0
1
11

MONITOR
266
117
327
162
Hour
getHour clock 1
3
1
11

TEXTBOX
18
174
168
192
Parameters
14
0.0
1

CHOOSER
220
548
312
593
walking-state
walking-state
"walk" "walkFast" "runFast"
2

CHOOSER
219
493
311
538
mouse-action
mouse-action
"select-ape" "inspect-ape" "watch-ape"
0

INPUTBOX
195
50
286
110
clock-start
15768000
1
0
Number

MONITOR
329
117
386
162
Season
season
17
1
11

MONITOR
9
117
94
162
Clock
clock
17
1
11

BUTTON
218
11
284
44
debug
debug
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
187
202
293
235
NIL
create-ape-tribes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
296
202
400
235
NIL
create-family
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
613
125
646
NIL
fed
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
20
591
72
609
Events
14
0.0
1

BUTTON
130
613
244
646
NIL
assaulted
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
98
423
173
483
ape2-number
5036
1
0
Number

BUTTON
186
239
291
272
NIL
create-juveniles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1732
11
1800
56
Total Apes
count apes
17
1
11

MONITOR
1733
58
1818
103
Total Infants
count apes with [getAgeName self = \"Infant\"]
2
1
11

MONITOR
1734
105
1791
150
Yearling
count apes with [getAgeName self = \"Yearling\"]
2
1
11

MONITOR
1735
151
1799
196
Juveniles
count apes with [getAgeName self = \"Juvenile\"]
2
1
11

MONITOR
1736
200
1814
245
Male Adults
count apes with [sex = \"M\" and getAgeName self = \"Adult\"]
2
1
11

MONITOR
1737
248
1815
293
Female Adults
count apes with [sex = \"F\" and getAgeName self = \"Adult\"]
2
1
11

INPUTBOX
288
51
392
111
night-acceleration
5
1
0
Number

SWITCH
10
679
127
712
terrain-on?
terrain-on?
0
1
-1000

SWITCH
131
680
253
713
trees-on?
trees-on?
0
1
-1000

SWITCH
257
680
373
713
halos-on?
halos-on?
1
1
-1000

TEXTBOX
15
652
80
670
Switchers
14
0.0
1

SWITCH
10
714
127
747
plants-on?
plants-on?
1
1
-1000

BUTTON
296
239
376
272
NIL
go-home
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
131
715
251
748
show-troops?
show-troops?
1
1
-1000

MONITOR
1737
295
1810
340
EnvEnergy
sum [energy] of trees
0
1
11

SWITCH
257
715
374
748
log?
log?
0
1
-1000

MONITOR
1737
342
1794
387
Ratio
count apes with [sex = \"F\" and (getAgeName self = \"Adult\")] / count apes with [sex = \"M\"and (getAgeName self = \"Adult\")]
2
1
11

MONITOR
1738
388
1851
433
Aggressiveness Avg
sum [aggressiveness] of apes / count apes
2
1
11

SWITCH
10
749
127
782
create-halos?
create-halos?
0
1
-1000

MONITOR
1739
437
1796
482
NIL
Deaths
0
1
11

MONITOR
1739
486
1827
531
NIL
Engagements
0
1
11

MONITOR
1739
533
1796
578
NIL
Mates
0
1
11

MONITOR
1739
580
1796
625
NIL
Births
0
1
11

MONITOR
1739
627
1798
672
NIL
Seasons
17
1
11

MONITOR
1739
674
1796
719
NIL
Flurts
0
1
11

MONITOR
1798
532
1868
577
NIL
AgeChanges
0
1
11

MONITOR
1799
580
1857
625
NIL
Escapes
0
1
11

BUTTON
186
275
291
308
NIL
create-couple
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1799
626
1869
671
Pregnancies
count apes with [pregnancy > 0]
0
1
11

SLIDER
10
342
182
375
initial-female-male-proportion
initial-female-male-proportion
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
185
343
393
376
female-male-ratio-tolerance
female-male-ratio-tolerance
0
5
4
0.05
1
NIL
HORIZONTAL

SWITCH
133
750
250
783
leader-pen?
leader-pen?
1
1
-1000

SWITCH
257
750
374
783
troop-pen?
troop-pen?
1
1
-1000

SWITCH
10
785
129
818
show-energy?
show-energy?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dead-monkey
true
3
Circle -7500403 true false 165 45 60
Circle -7500403 true false 75 45 60
Polygon -7500403 true false 150 180 135 210 135 225 150 240
Polygon -7500403 true false 150 240 165 255 150 300
Circle -6459832 true true 90 60 120
Line -16777216 false 106 159 192 79
Line -16777216 false 108 77 192 163

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

monkey
true
3
Circle -14835848 true false 165 45 60
Circle -14835848 true false 75 45 60
Polygon -14835848 true false 150 180 135 210 135 225 150 240
Polygon -14835848 true false 150 240 165 255 150 300
Circle -6459832 true true 90 60 120

mouse top
true
0
Polygon -7500403 true true 144 238 153 255 168 260 196 257 214 241 237 234 248 243 237 260 199 278 154 282 133 276 109 270 90 273 83 283 98 279 120 282 156 293 200 287 235 273 256 254 261 238 252 226 232 221 211 228 194 238 183 246 168 246 163 232
Polygon -7500403 true true 120 78 116 62 127 35 139 16 150 4 160 16 173 33 183 60 180 80
Polygon -7500403 true true 119 75 179 75 195 105 190 166 193 215 165 240 135 240 106 213 110 165 105 105
Polygon -7500403 true true 167 69 184 68 193 64 199 65 202 74 194 82 185 79 171 80
Polygon -7500403 true true 133 69 116 68 107 64 101 65 98 74 106 82 115 79 129 80
Polygon -16777216 true false 163 28 171 32 173 40 169 45 166 47
Polygon -16777216 true false 137 28 129 32 127 40 131 45 134 47
Polygon -16777216 true false 150 6 143 14 156 14
Line -7500403 true 161 17 195 10
Line -7500403 true 160 22 187 20
Line -7500403 true 160 22 201 31
Line -7500403 true 140 22 99 31
Line -7500403 true 140 22 113 20
Line -7500403 true 139 17 105 10

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
