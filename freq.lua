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
highVoltage = 7
retrigdelay = 0 
retrigcap = 20

function init()
    input[1].mode('freq',0.001)
    input[2].mode('volume', volumeSR)
    output[1].scale({})
    output[2].scale({})
    output[4].action = pulse(0.001, 7, 1)
   
end

input[1].freq = function(freq)
    last = freq
    output[1].slew = 0.1
    output[1].volts = map(last)
    accum = accum + freq
    counter = counter + 1
end

input[2].volume = function(vol)
    output[3].slew = 0.1
    output[3].volts = vol

    if volgate == 1 then
        retrigdelay = retrigdelay + 1
    end

    -- check if threshold has been exceeded and upate gate and pitches
    if vol > volThresh and volgate == 0 then 
        averaged = accum / counter
        counter = 1
        accum = last
        v2 = map(averaged)
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
    --volt = hztovolts(value [h2vref])
    volt = -5.81 + 1.43 * math.log(value)
    return volt
end
