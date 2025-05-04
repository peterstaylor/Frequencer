--- Frequencer
-- in1: Any Audio Input
-- in2: Gate or Trigger
-- out1: Faster Tracking Pitch Follower
-- out2: Gate when output 1 updates
-- out3: Slower Tracking Pitch Follower
-- out4: Gate when output 3 updates

h2vref = 58.14 -- experimentally derived
volgateDiv = 4
volumeSR = 0.01 
freqSR = 0.05
minPitchVolt = 1
maxPitchVolt = 5

-- these variables are used to create a running average
-- of the frequency detector output
slowF = 1 * volgateDiv  -- in seconds
slowCounter = 1
fastF = 1 -- in seconds
fastCounter = 1
slowLen = slowF / freqSR
fastLen = fastF / freqSR
slowAvg = {}
fastAvg = {}
output3 = 0
output1 = 0

function init()
    input[1].mode('freq',freqSR)
    input[2].mode('change', 2,0.1,'rising')
    output[1].scale({},19)
    output[3].scale({},19)

    for i = 1, slowLen do
        slowAvg[i] = 0
    end

    for i = 1, fastLen do
        fastAvg[i] = 0
    end
end

input[1].freq = function(freq)
    
    fastAvg[fastCounter] = freq
    fastCounter = fastCounter + 1
    if fastCounter > fastLen then
        fastCounter = 1
    end

    slowAvg[slowCounter] = freq
    slowCounter = slowCounter + 1

    if slowCounter > slowLen then
        slowCounter = 1
    end
    
end

input[2].change = function()
    output1 = clamp(map(averageArray(fastAvg, fastLen)))
    output3 = clamp(map(averageArray(slowAvg, slowLen)))
    output[1].volts = output1
    output[3].volts = output3
    output[2].action = pulse()
    output[4].action = ar()
end

-- maps measured frequency to a v/oct voltage
function map(value)
    volt = hztovolts(value)
    --volt = -5.81 + 1.43 * math.log(value)
    return volt
end

function averageArray(array, len)
    pile = 0
    for i = 1, len do
        pile = pile + array[i]
    end
    return pile / len
end

-- clamp should take in volts
function clamp(val)
    while val < 1 do
        val = val + 1
    end

    while val > maxPitchVolt do
        val = val - 1
    end

    return val
end