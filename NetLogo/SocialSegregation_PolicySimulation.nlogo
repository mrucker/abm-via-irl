;extensions [matlab pathdir]

globals [

  ;global statistics
  percent-same-color-area          ;on average, percentage of majority color agents in a 10-by-10 patch
  percent-same-color-conversation  ;on average, percentage of conversation time with a same color partner
]

turtles-own [
  state
  policy

  conversation-length     ;number of tick during which the agent have a conversation
  conversation-with-like? ;defines the color of the recent partner
  people-around           ;list of people around
  potential-partner       ;list of people who are available to talk
  people-around-to-talk?  ;whether there is a potential conversation partner
  action                  ;1: move short distance 2: move long distance 3: start conversation 4: continue conversation

  ;agent statistics
  cumulative-conversation-length-with-same-color
  cumulative-conversation-length-with-different-color
  same-color-ratio-around-me
]


to setup
  clear-all

  matlab:eval (word "run('"pathdir:get-current"\\initialize.m')")
  set-default-shape turtles "person"
  ask n-of number-of-agents patches [ sprout 1 ]

  ;Solve MDP of random policy
  matlab:eval "finished=0;"
  matlab:eval "run('experiment_2.m');finished=1;"
  let matlabReady false
  while [matlabReady = false] [
    wait 1
    set matlabReady (matlab:get-double "finished")
  ]
  show "ready"
  matlab:eval "learned_policy = Pol{selected};"
  let matlab_policy matlab:get-double-list "learned_policy"

  ask turtles [
    set state 0
    set policy matlab_policy

    set color one-of [ red green ] ;make approximately half the turtles red and the other half green
    set conversation-length 0
    set people-around-to-talk? 0
    set conversation-with-like? 0
    set people-around nobody
    set potential-partner nobody
    set action 0
    set same-color-ratio-around-me 0
    set cumulative-conversation-length-with-same-color 0.1
    set cumulative-conversation-length-with-different-color 0.1
    move 2
  ]

  set percent-same-color-area 0
  set percent-same-color-conversation 0

  reset-ticks
end



to go
  update-agents
  update-global-statistics
  tick
end




to update-agents
  ask turtles [
    ;determine states
    set people-around other turtles in-radius proximity-radius
    if (conversation-length = 0) [
      ifelse any? people-around [
        set potential-partner people-around with [conversation-length = 0]
        ifelse any? potential-partner [;in case there is a potential partner
          set people-around-to-talk? 1
        ][ set people-around-to-talk? 0 ]
      ][ set people-around-to-talk? 0 ]
    ]

    set state conversation-length * 4 + conversation-with-like? * 2 + people-around-to-talk? + 1

    ;look up action
    set action item (state - 1) policy

    do-action
    update-agent-statistics
  ]
end




to do-action

  ifelse (action = 1) [
    set conversation-length 0
    move 1

  ][ifelse (action = 2) [
    set conversation-length 0
    move 2

  ][ifelse (action = 3) [
    let partner one-of potential-partner
    face partner
    fd 0.5
    set conversation-length 1
    let same-color? ifelse-value ([color] of self = [color] of partner) [1] [0]
    set conversation-with-like? same-color?
    ask partner
    [
      set people-around-to-talk? 1
      set action 3
      set conversation-length 1
      set conversation-with-like? same-color?
    ]

  ][ifelse (action = 4) [
    set conversation-length conversation-length + 1
  ][]]]]

end




to move [dist] ; 1:short distance 2:long distance
  rt random-float 360
  fd ifelse-value (dist = 1) [random-float 0.5 + short-distance][(random-float 0.5) + long-distance]
  if any? other turtles-here [
    move dist     ;keep going until we find an unoccupied patch
  ]
end




to update-agent-statistics
  if any? people-around [
      let num_same count people-around with [color = [color] of myself]
      let num_different count people-around with [color != [color] of myself]
      set same-color-ratio-around-me num_same / (num_same + num_different) * 100
  ]
  if (action = 3 or action = 4) [
    ifelse (conversation-with-like? = 1) [ set cumulative-conversation-length-with-same-color cumulative-conversation-length-with-same-color + 1 ]
                                         [ set cumulative-conversation-length-with-different-color cumulative-conversation-length-with-different-color + 1 ]
  ]
end




to update-global-statistics
  let total-time-with-same-color sum [cumulative-conversation-length-with-same-color] of turtles
  let total-time-with-different-color sum [cumulative-conversation-length-with-different-color] of turtles
  set percent-same-color-conversation (total-time-with-same-color / (total-time-with-same-color + total-time-with-different-color)) * 100
  set percent-same-color-area mean [same-color-ratio-around-me] of turtles
end

@#$#@#$#@
GRAPHICS-WINDOW
270
10
892
653
25
25
12.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
15.0

PLOT
15
300
264
443
Spatial Segregation
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -2674135 true "" "plot percent-same-color-area"

PLOT
15
444
264
608
Social Segregation
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -10899396 true "" "plot percent-same-color-conversation"

SLIDER
15
55
240
88
number-of-agents
number-of-agents
100
1500
700
10
1
NIL
HORIZONTAL

BUTTON
15
15
75
48
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
100
15
155
48
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
0

SLIDER
15
95
240
128
short-distance
short-distance
0
5
0
1
1
NIL
HORIZONTAL

SLIDER
15
135
240
168
long-distance
long-distance
0
20
2
1
1
NIL
HORIZONTAL

SLIDER
15
175
240
208
proximity-radius
proximity-radius
1
10
2
1
1
NIL
HORIZONTAL

@#$#@#$#@
## ACKNOWLEDGMENT

This model is from Chapter Three of the book "Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo", by Uri Wilensky & William Rand.

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

This model is in the IABM Textbook folder of the NetLogo Models Library. The model, as well as any updates to the model, can also be found on the textbook website: http://www.intro-to-abm.com/.

## WHAT IS IT?

This project models the behavior of two types of turtles in a mythical pond. The red turtles and green turtles get along with one another. But each turtle wants to make sure that it lives near some of "its own." That is, each red turtle wants to live near at least some red turtles, and each green turtle wants to live near at least some green turtles. The simulation shows how these individual preferences ripple through the pond, leading to large-scale patterns.

This project was inspired by Thomas Schelling's writings about social systems (particularly with regards to housing segregation in cities).

This model is a simplified version of the Segregation model that is in the Social Science section of the NetLogo models library.

## HOW TO USE IT

Click the SETUP button to set up the turtles. There are equal numbers of red and green turtles. The turtles move around until there is at most one turtle on a patch.  Click GO to start the simulation. If turtles don't have enough same-color neighbors, they jump to a nearby patch.

The NUMBER slider controls the total number of turtles. (It takes effect the next time you click SETUP.)  The %-SIMILAR-WANTED slider controls the percentage of same-color turtles that each turtle wants among its neighbors. For example, if the slider is set at 30, each green turtle wants at least 30% of its neighbors to be green turtles.

The "PERCENT SIMILAR" monitor shows the average percentage of same-color neighbors for each turtle. It starts at about 0.5, since each turtle starts (on average) with an equal number of red and green turtles as neighbors. The "PERCENT UNHAPPY" monitor shows the percent of turtles that have fewer same-color neighbors than they want (and thus want to move).  Both monitors are also plotted.

## THINGS TO NOTICE

When you execute SETUP, the red and green turtles are randomly distributed throughout the pond. But many turtles are "unhappy" since they don't have enough same-color neighbors. The unhappy turtles jump to new locations in the vicinity. But in the new locations, they might tip the balance of the local population, prompting other turtles to leave. If a few red turtles move into an area, the local green turtles might leave. But when the green turtles move to a new area, they might prompt red turtles to leave that area.

Over time, the number of unhappy turtles decreases. But the pond becomes more segregated, with clusters of red turtles and clusters of green turtles.

In the case where each turtle wants at least 30% same-color neighbors, the turtles end up with (on average) 70% same-color neighbors. So relatively small individual preferences can lead to significant overall segregation.

## THINGS TO TRY

Try different values for %-SIMILAR-WANTED. How does the overall degree of segregation change?

If each turtle wants at least 40% same-color neighbors, what percentage (on average) do they end up with?

## NETLOGO FEATURES

In the UPDATE-GLOBALS procedure, note the use of SUM, COUNT and WITH to compute the percentages displayed in the monitors and plots.

## RELATED MODELS

Segregation

## CREDITS AND REFERENCES

This model is a simplified version of:

* Wilensky, U. (1997).  NetLogo Segregation model.  http://ccl.northwestern.edu/netlogo/models/Segregation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

The original work by Thomas Schelling was published in:
Schelling, T. (1978). Micromotives and Macrobehavior. New York: Norton.

See also: Rauch, J. (2002). Seeing Around Corners; The Atlantic Monthly; April 2002;Volume 289, No. 4; 35-48. http://www.theatlantic.com/magazine/archive/2002/04/seeing-around-corners/302471/

## HOW TO CITE

This model is part of the textbook, “Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo.”

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U., Rand, W. (2006).  NetLogo Segregation Simple model.  http://ccl.northwestern.edu/netlogo/models/SegregationSimple.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the textbook as:

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

## COPYRIGHT AND LICENSE

Copyright 2006 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2006 Cite: Wilensky, U., Rand, W. -->
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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
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
1
@#$#@#$#@
