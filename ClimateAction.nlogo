;; Global parameters/variables
;; emis_tick_cumulative: total emissions in the atmosphere
;; emis_tick
;; emis_tick_negative
;; per_person_emis: emissions per capita per time step
globals [emis_tick_cumulative emis_tick emis_tick_negative per_person_emis social_tipping_point earth_system_tipping_point]

;; Two types of agents (breeds)
breed [VIPs influencer]
breed [population people]

;; Attributes of population agents:
;; status: activist, denier, neutral
;; energy: level of activism of agent
population-own [status energy]

;; Set up the world
to setup-patches
  ask patches [
    set pcolor black
  ]
end

;; Define agents
to setup
  clear-all
  create-population initial-number-of-agents
  create-VIPs initial-number-of-influencers

  ;; Emission-level starts at 410ppm (today's level of CO2 in atmosphere)
  set emis_tick_cumulative 410
  ;; Normal population emit 0.02ppm per time period. Activist reduce their personal emissions (on average) to 0
  set per_person_emis 0.02
  ;; Emission removal technologies remove emis_tick_negative per time period
  set emis_tick_negative -0.5
  ;;; With at least 60% of population being activists: negative emission technology takes effect
  set social_tipping_point 0.6
  ;;; At a level of 1200ppm of CO2 in the atmosphere, the Earth System reaches a tipping point and the game ends
  set earth_system_tipping_point 1200


  ask population [
    setxy random-xcor random-ycor
    set shape "person"
    let random_prob random-float 1
    (ifelse
      random_prob <= 0.2 [ set status "denier" ]
      random_prob > 0.2 AND random_prob < 0.8 [ set status "neutral" ]
      random_prob >= 0.8 [ set status "activist" ]
    )

    if status = "activist" [
      set color blue
      set energy 90
    ]
    if status = "neutral" [
      set color white
      set energy 50
    ]
    if status = "denier" [
      set color red
      set energy 10
    ]
  ]

  ask VIPs [
    setxy random-xcor random-ycor
    set shape "car"
    set color yellow
  ]

  setup-patches
  reset-ticks
end

to move-population
  ask population [
    right random 360
    fd 1
    encounter
  ]
end

;; Influencers move faster than population
to move-VIPs
  ask VIPs [
    left random 360
    fd 5
    VIPradius
  ]
end

;; Influencers add energy to people in their surrounding (prevent switching to deniers)
to VIPradius
    ask population in-radius 3 [
    set energy energy + energy_inc
 ]
end

to encounter

  if status = "activist" [
    ask other population-here [
      if random-float 1 < Activitst-Convincing-Power [
        set energy energy + energy_inc
         if energy > 70 [
           set status "activist"
          set color blue
        ]
      ]
    ]
 ]

  if status = "denier" [
   ask other population-here [
     if random-float 1 < Denier-Convincing-Power [
       set energy energy - energy_dec
        if energy < 30 [
          set status "denier"
          set color red
       ]
     ]
   ]
 ]

end

to energy_check_post_vip
  ask population[
  if energy <= 30 [
      set status "denier"
      set color red
    ]
  if (energy > 30) AND (energy < 70) [
      set status "neutral"
      set color white
    ]
  if energy >= 70 [
      set status "activist"
      set color blue
    ]
  ]
end

;;; Start the simulation
to go
  move-population
  move-VIPs
  energy_check_post_vip
  set emis_tick per_person_emis * count population with [status != "activist"]
  tick
  set emis_tick_cumulative emis_tick_cumulative + emis_tick
  if (count population with [status = "activist"] / count population) > 0.6 AND emis_tick_cumulative > 0 [
   set emis_tick_cumulative emis_tick_cumulative + emis_tick_negative
  ]
  if emis_tick_cumulative >= 1200 [ stop ]
end

;;; Go one time step
to start
  move-population
  move-VIPs
  energy_check_post_vip
  set emis_tick per_person_emis * count population with [status != "activist"]
  tick
  set emis_tick_cumulative emis_tick_cumulative + emis_tick
  if (count population with [status = "activist"] / count population) > social_tipping_point AND emis_tick_cumulative > 0 [
   set emis_tick_cumulative emis_tick_cumulative + emis_tick_negative
  ]
  if emis_tick_cumulative >= earth_system_tipping_point [ stop ]
end
@#$#@#$#@
GRAPHICS-WINDOW
631
16
1245
336
-1
-1
16.4
1
10
1
1
1
0
1
1
1
-18
18
-9
9
1
1
1
ticks
30.0

BUTTON
9
10
76
43
setup
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
11
50
74
83
go
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

MONITOR
488
18
625
63
Number of Agents
count turtles
17
1
11

MONITOR
488
68
593
113
Activists
count population with [ status = \"activist\" ]
17
1
11

SLIDER
632
339
834
372
initial-number-of-agents
initial-number-of-agents
100
1000
750.0
50
1
NIL
HORIZONTAL

BUTTON
82
51
145
84
NIL
start
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
489
163
546
208
Deniers
count population with [ status = \"denier\" ]
17
1
11

MONITOR
489
115
548
160
Neutrals
count population with [ status = \"neutral\" ]
17
1
11

SLIDER
3
100
201
133
Activitst-Convincing-Power
Activitst-Convincing-Power
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
4
140
202
173
Denier-Convincing-Power
Denier-Convincing-Power
0
1
0.5
0.01
1
NIL
HORIZONTAL

PLOT
216
234
416
384
Cumulative Emissions
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot emis_tick_cumulative"

PLOT
421
233
621
383
Emis Tick
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot emis_tick"

PLOT
215
18
477
227
Totals
time
totals
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Neutrals" 1.0 0 -16710398 true "" "plot count population with [status = \"neutral\" ]"
"Activists" 1.0 0 -13791810 true "" "plot count population with [status = \"activist\" ]"
"Deniers" 1.0 0 -8053223 true "" "plot count population with [ status = \"denier\" ]"

SLIDER
6
191
178
224
energy_inc
energy_inc
0
20
10.0
2
1
NIL
HORIZONTAL

SLIDER
7
228
179
261
energy_dec
energy_dec
0
20
10.0
2
1
NIL
HORIZONTAL

SLIDER
836
338
1026
371
initial-number-of-influencers
initial-number-of-influencers
0
5
1.0
1
1
NIL
HORIZONTAL

PLOT
9
281
209
431
Mean activism-energy level of population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot mean [energy] of population"

@#$#@#$#@
## WHAT IS IT?

The Climate Action ABM is a simple agent-based model. It models the role of
climate activists, climate deniers and the power of influencers in a society.

CO2 emissions per capita depend on the agents state of mind (activists emit less
compared to the general population or climate deniers).
If a certain share of the population is climate-aware (activist state),
carbon removal technologies are used. This is a social tipping point. 

The global level of CO2 in the atmosphere starts at 410ppm. At a state of
1200ppm Earth System tipping points are reached and humanity ends.


## HOW IT WORKS

There are two types of agents (people and influencers). 
People move around randomly.
Influencer (VIPs), represented by the car symbol, also move randomly, but faster. They move several steps in one time step, while people, represented by the person symbol, move only 1 step. 

The population (people) are divided into activists (blue), neutral (white) and deniers (red). Each agent is endowed with a certain level of activism energy. If activism energy is greater than 70, the person is declared activist, if it is below 30, the person is declared denier. All other are neutral individuals. 
Initially, 20% of the population are deniers, 20% activists and 60% neutral individuals. 

When an activists meets another person, the other person's activism energy increases. When a denier meets another person, the other person's activism energy decreases. 

Influencer increase the energy of people in their surrounding (3-pixel radius) by the same amount as activists and therefore support activists and hinder spreading of consipiracy theories and climate scepticism. 

Every agent (except for activists) emits 0.02ppm CO2 per time step. Activists don't emit CO2.
When carbon removal technology comes into place (above social tipping point: support of 60% of population), 0.5ppm CO2 are removed from the atmosphere per time step.  

## HOW TO USE IT

The setup button sets up the world (initialization of game according to selected settings).
The go button starts the simulation run.
The start button lets agents make one step.

The user can set 
(a) the initial number of agents in a range between 1 billion represented by 100 turtles (population at around 1900) and 10 billion represented by 1000 turtles (potential population by the end of the century).  
(b) the initial number of influencers in a range between 0 and 5.
(c) the activits (deniers) convincing power, i.e. the probability that the activits (denier) convinces the person they met (between 0 and 1)
(d) the activits (deniers) level of activism they add (subtract) from the person they meet energy_inc (energy_dec)

## THINGS TO NOTICE

In the standard setting (7.5 billion people (750), 10 mio. influencers (1), same convincing power for activists and deniers), it is possible to hit the Earth System Tipping Point before the Social Tipping Point allowing decarbonization (carbon removal) is reached. However, there is also a chance that humanity survives. 

There are strategies to decrease the likelihood of human extinction (population size, number of influencers, power of activists)


## THINGS TO TRY

- Increase the population: How much faster is the Earth System Tipping Point reached with higher population size? (Analyze risk of over-population)
- Increase the activists convinving power or energy_inc relative to the power of the deniers. (Analyze the effect of Science Communication)
- Play with the number of influencers. (Role of social media)


## EXTENDING THE MODEL

Potential extensions include:
- population expansion scenarios (e.g. increase of population over time)
- make all model parameters flexible (social-tipping-point, earth-system-tipping-point, initial co2 in atmosphere, emissions per capita)
- include social networks and clusters (deniers have higher likelihood to meet deniers, activits higher likelihood to interact with activits)
- include extreme events
- include technological break-throughs

## NETLOGO FEATURES

- Netlogo interface, buttons and output graphs

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

Developed by Abhijeet Mishra and Felicitas Beier

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
NetLogo 6.2.0
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
