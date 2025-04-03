--- Frequencer
-- in1: Any Audio Input
-- in2: Any Audio Input, theoreitcally same as in1
-- out1: Wider Time Window Detected Pitch, Rolling Avg
-- out2: Smaller Time Window Detected Pitch, Output on Volume Thresh
-- out3: Envelope Follower of Input
-- out4: Gate from Volume Threshold of Audio Input

h2vref = 58.14 -- experimentally derived
volThresh = 2
volgate = 0
volumeSR = 0.01 
freqSR = 0.05

-- these variables are used to create a running average
-- of the frequency detector output
slowF = 10  -- in seconds
slowCounter = 1
fastF = 0.5 -- in seconds
fastCounter = 1
slowLen = slowF / freqSR
fastLen = fastF / freqSR
slowAvg = {}
fastAvg = {}

function init()
    input[1].mode('freq',freqSR)
    input[2].mode('volume', volumeSR)
    output[1].scale({0,9,7,9,4})
    output[2].scale({0,2,4,5,7,9,11})

    for i = 1, slowLen do
        slowAvg[i] = 0
    end

    for i = 1, fastLen do
        fastAvg[i] = 0
    end
end

input[1].freq = function(freq)
    slowAvg[slowCounter] = freq
    fastAvg[fastCounter] = freq

    slowCounter = slowCounter + 1
    fastCounter = fastCounter + 1

    if slowCounter > slowLen then
        slowCounter = 1
    end

    if fastCounter > fastLen then
        fastCounter = 1
    end

    output[1].volts = map(averageArray(slowAvg, slowLen))
end

input[2].volume = function(vol)
    output[3].slew = 0.5
    output[3].volts = vol

    -- check if threshold has been exceeded and upate gate and pitches
    if vol > volThresh and volgate == 0 then 
        output[2].volts = map(averageArray(fastAvg, fastLen))
        output[4].volts = 7
        volgate = 1
    elseif vol <= volThresh and volgate == 1 then
        output[4].volts = 0
        volgate = 0
    end
end

-- maps measured frequency to a v/oct voltage
function map(value)
    --volt = hztovolts(value)
    volt = -5.81 + 1.43 * math.log(value)
    return volt
end

function averageArray(array, len)
    pile = 0
    for i = 1, len do
        pile = pile + array[i]
    end
    return pile / len
end