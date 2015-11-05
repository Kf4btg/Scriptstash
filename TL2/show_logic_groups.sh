#!/bin/sh

## There have GOT to be a bajillion better ways to do this than...this.
## But this works for now.

inputxml="$1"

xmlstarlet sel -IB -T -t \
-m '//LOGICGROUP' \
  -v '../STRING[@label="NAME"]' -n \
  -o '  ID: ' -v '../INTEGER64[@label="ID"]' -n \
  -o '  NODES: ' -v 'count(LOGICOBJECT)' -n -n \
  -m "LOGICOBJECT" \
    -o "    #" -v '*[1]' -o ") " \
      --var 'objid=INTEGER64[@label="OBJECTID"]/text()' \
      -m '//PROPERTIES/INTEGER64[@label="ID"]' \
        -i './text()=$objid' \
          -v '../STRING[@label="NAME"]' -n \
        -b \
      -b \
    -m 'LOGICLINK' \
      -o "         ." -v '*[@label="OUTPUTNAME"]' \
        -o ' -> ' --var 'linkto=INTEGER[@label="LINKINGTO"]/text()' \
        -m '../../LOGICOBJECT' \
          -i 'UNSIGNED_INT[@label="ID"]/text()=$linkto' \
            --var 'linkid=INTEGER64[@label="OBJECTID"]/text()' \
            -m '//PROPERTIES/INTEGER64[@label="ID"]' \
              -i './text()=$linkid' \
                -v '../STRING[@label="NAME"]' \
              -b \
            -b \
          -b \
        -b \
        -o '::' -v '*[@label="INPUTNAME"]' \
      -n \
    -b \
    -n \
  -b \
-n  "$inputxml"

## Example output:

# cloud logic
#   ID: 9027836300745053355
#   NODES: 4
#
#     #0) day clouds
#
#     #1) night clouds
#
#     #2) DawnTrigger
#          .Activated -> day clouds::Start Particle
#          .Activated -> night clouds::Stop Particle
#
#     #3) DuskTrigger
#          .Activated -> day clouds::Stop Particle
#          .Activated -> night clouds::Start Particle
#
#
# ThunderLogic
#   ID: 789428877120049631
#   NODES: 10
#
#     #0) Output Incrementor4
#          .First Increment -> ThunderSound1::Play
#          .Second Increment -> ThunderSound2::Play
#          .Third Increment -> ThunderSound3::Play
#          .Fourth Increment -> ThunderSound4::Play
#          .Incremented -> Lightning Particle::Start Particle
#
#     #1) ThunderSound1
#
#     #2) ThunderSound2
#
#     #3) ThunderSound3
#
#     #4) ThunderSound4
#
#     #5) Lightning Particle
#
#     #6) Main Timer
#          .Activated -> Output Incrementor4::Increment
#          .Activated -> Random Choice::Roll
#
#     #7) Delay
#          .Activated -> Output Incrementor4::Increment
#          .Activated -> Random Choice::Roll
#
#     #8) Random Choice
#          .One -> Delay::Enable
#
#     #9) Random Choice
#
#
# Logic Group
#   ID: 3251814136014855073
#   NODES: 1
#
#     #0) snowFlurry
#
#     #1) snow Timer
#          .Activated -> snowFlurry::Start Particle
#
#
# Logic Group1
#   ID: -5009895128560102945
#   NODES: 9
#
#     #0) Output Incrementor
#          .First Increment -> GustSound2::Play
#          .Second Increment -> GustSound1::Play
#          .Third Increment -> GustSound3::Play
#          .Fourth Increment -> GustSound5::Play
#          .Fifth Increment -> GustSound4::Play
#          .Incremented -> RainGustsParticle::Start Particle
#          .Incremented -> StopParticleTimer::Enable
#
#     #1) GustSound2
#
#     #2) GustSound1
#
#     #3) GustSound3
#
#     #4) GustSound5
#
#     #5) GustSound4
#
#     #6) RainGustsParticle
#
#     #7) StopParticleTimer
#          .Activated -> RainGustsParticle::Stop Particle
#
#     #8) MainTimer
#          .Activated -> Output Incrementor::Increment
#
#
# Logic Group
#   ID: 613684182480623135
#   NODES: 7
#
#     #0) Chicks
#
#     #1) DawnTrigger
#          .Activated -> ChickTimer::Enable
#          .Activated -> RandomWrenStart::Enable
#
#     #2) DuskTrigger
#          .Activated -> ChickTimer::Disable
#          .Activated -> WrenTimer::Disable
#
#     #3) ChickTimer
#          .Activated -> Chicks::Play
#
#     #4) Wrens
#
#     #5) WrenTimer
#          .Activated -> Wrens::Play
#
#     #6) RandomWrenStart
#          .Activated -> WrenTimer::Enable
#
#
# Logic Group1
#   ID: -8764531225349647905
#   NODES: 6
#
#     #0) DuskTrigger
#          .Activated -> DayAmbient::Stop
#          .Activated -> Fireflies::Start Particle
#          .Activated -> NightAmbient::Play
#
#     #1) DawnTrigger
#          .Activated -> DayAmbient::Play
#          .Activated -> Fireflies::Stop Particle
#          .Activated -> NightAmbient::Stop
#
#     #2) DayAmbient
#
#     #3) Fireflies
#
#     #4) PreDawn Trigger
#
#     #5) PostDusk Trigger
#
#     #6) NightAmbient
#
#
# Logic Group
#   ID: 7610489846092340173
#   NODES: 11
#
#     #0) BeastsTimer
#          .Activated -> Beasts::Play
#
#     #1) Beasts
#
#     #2) Raven
#
#     #3) RavenTimer
#          .Activated -> Raven::Play
#
#     #4) Bears
#
#     #5) BearsTimer
#          .Activated -> Bears::Play
#
#     #6) SteppesNightWind
#
#     #7) SteppesDayWind
#
#     #8) DawnTrigger
#          .Activated -> WindDay::Enable
#          .Activated -> WindNight::Disable
#
#     #9) DuskTrigger
#          .Activated -> WindNight::Enable
#          .Activated -> WindDay::Disable
#
#     #10) WindDay
#          .Activated -> SteppesDayWind::Play
#          .Activated -> SteppesNightWind::Stop
#
#     #11) WindNight
#          .Activated -> SteppesNightWind::Play
#          .Activated -> SteppesDayWind::Stop
