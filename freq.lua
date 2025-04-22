--- Frequencer
-- in1: Any Audio Input
-- in2: Any Audio Input, theoreitcally same as in1
-- out1: Faster Tracking Pitch Follower
-- out2: Gate when output 1 updates
-- out3: Slower Tracking Pitch Follower
-- out4: Gate when output 3 updates

h2vref = 58.14 -- experimentally derived
volThresh = 1
volgate = 0
volgateCount = 1
volgateDiv = 4
volumeSR = 0.01 
freqSR = 0.05

-- these variables are used to create a running average
-- of the frequency detector output
slowF = 1  -- in seconds
slowCounter = 1
fastF = 1 -- in seconds
fastCounter = 1
slowLen = slowF / freqSR
fastLen = fastF / freqSR
slowAvg = {}
fastAvg = {}

function init()
    input[1].mode('freq',freqSR)
    input[2].mode('volume', volumeSR)
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
    if volgate == 1 then
        fastAvg[fastCounter] = freq
        fastCounter = fastCounter + 1
        if fastCounter > fastLen then
            fastCounter = 1
        end
    end

    if volgate == 1 and volgateCount >= volgateDiv then
        slowAvg[slowCounter] = freq
        slowCounter = slowCounter + 1

        if slowCounter > slowLen then
            slowCounter = 1
        end
    end
end

input[2].volume = function(vol)
    -- check if threshold has been exceeded and upate gate and pitches
    if vol > volThresh and volgate == 0 then 
        volgateCount = volgateCount + 1
        output[1].volts = map(averageArray(fastAvg, fastLen))
        output[2].volts = 7
        volgate = 1
        if volgateCount >= volgateDiv then
            output[3].volts = map(averageArracy(slowAvg, slowLen))
            output[4].volts = 7
        end
    elseif vol <= volThresh and volgate == 1 then
        output[2].volts = 0
        output[4].volts = 0
        volgate = 0
        
        if volgateCount >= volgateDiv then
            volgateCount = 1
        end
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