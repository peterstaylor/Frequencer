--- Frequencer
-- in1: Any Audio Input
-- in2: Any Audio Input, theoreitcally same as in1
-- out1: Slewing Detected Pitch
-- out2: Accumulated Detected Pitch
-- out3: Envelope Follower
-- out4: gate from volume detection

accum = 0
counter = 1
last = 440
averaged = 0
h2vref = 58.14 -- experimentally derived
volThresh = 2
volgate = 0
timeForEF = 0.25
volumeSR = 0.01 
freqSR = 0.001
highVoltage = 7
retrigdelay = 0 
retrigcap = 20
slewCount = 0
freqAvg = {}

function init()
    input[1].mode('freq',freqSR)
    input[2].mode('volume', volumeSR)
    output[1].scale({0,9,7,9,4})
    output[2].scale({0,2,4,5,7,9,11})
    output[4].action = pulse(0.01, 7, 1)
   
end

input[1].freq = function(freq)
    slewCount = slewCount + 1
    
    last = freq
    if slewCount > (1/freqSR) then
        slewCount = 0 
        output[1].slew = 2
        go = map(freq/2)
        output[1].volts = go
    end
    accum = accum + freq
    counter = counter + 1
end

input[2].volume = function(vol)
    output[3].slew = 0.5
    output[3].volts = vol

    if volgate == 1 then
        retrigdelay = retrigdelay + 1
    end

    -- check if threshold has been exceeded and upate gate and pitches
    if vol > volThresh and volgate == 0 then 
        averaged = accum / counter
        counter = 1
        accum = last
        v2 = map(averaged/2)
        output[2].volts = v2 
        output[4]()
        volgate = 1
    elseif (vol <= volThresh and volgate == 1) or retrigdelay > retrigcap then
        volgate = 0
        retrigdelay = 0
    end
end

-- maps measured frequency to a v/oct voltage
function map(value)
    --volt = hztovolts(value)
    volt = -5.81 + 1.43 * math.log(value)
    return volt
end
