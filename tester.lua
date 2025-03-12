--- Tester
-- in1: Any Audio Input
-- in2: Clock
-- out1: Sequenced Pitch
-- out2: sampled input

frequency = 0
freqcounter = 1
vcounter = 1
freqaccum = 0
vaccum = 0
voltage = 0

function init()
    input[1].mode('freq',0.1)
    input[2].mode('stream',0.001)
end

input[2].stream = function(v)
    vcounter = vcounter + 1
    vaccum = vaccum + v
    voltage = vaccum / vcounter
    if vcounter % 1000 == 0 then
        print("voltage: " ..  tostring(voltage) .. " | freq: " .. tostring(frequency))
    end
    output[1].volts = v
end

input[1].freq = function(freq)
    freqaccum = freqaccum + freq
    freqcounter = freqcounter + 1
    frequency = freqaccum / freqcounter
end