--- Frequencer
-- in1: Any Audio Input
-- in2: Clock
-- out1: Sequenced Pitch
-- out2: sampled input

accum = 0
counter = 1
last = 440
averaged = 0
prevOutput = 0

function init()
    input[1].mode('freq',0.001)
    input[2].mode('change',1,0.05,'rising')
    output[1].scale({})
end

input[1].freq = function(freq)
    last = freq
    accum = accum + freq
    counter = counter + 1
end

input[2].change = function(s)
    averaged = accum / counter
    counter = 1
    accum = last
    diff = math.abs(prevOutput - averaged)
    prevOutput = averaged
    v1 = map(last)
    v2 = map(averaged)
    output[1].volts = v1
    output[2].volts = v2
    output[3].volts = v2 - 2
    output[4].volts = v2 + 1
end

function map(value)
    volt = -5.81 + 1.43 * math.log(value)
    return volt
end