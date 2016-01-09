do
    local encastate
    local encbstate
    local encpos=0
    local function enccb(cw)
       local oldpos = encpos
       encpos = encpos + (cw and 1 or -1)
       if math.floor(oldpos/4)~=math.floor(encpos/4) then
         local d=encpos > oldpos and 1 or -1
         local s
         if fahrenheit then
            s=math.floor(setpoint*9/5 + d +.5)*5/9
         else
            s=(math.floor(setpoint + .5)*2 +.5)/2
         end
         setsetpoint(s)
       end
    end

    function enccbsw(pushed)
       if pushed then
         s = setpoint == settings.offsetpoint and settings.onsetpoint or settings.offsetpoint
         setsetpoint(s)
       end
    end

    local function xor(a,b)
    if a and b or not a and not b then return false end
    return true
    end
    
    gpio.mode(encsw, gpio.INT, gpio.PULLUP)
    gpio.trig(encsw, "both", function(level) enccbsw(level==0) end)
    gpio.mode(encqa, gpio.INT, gpio.PULLUP)
    gpio.trig(encqa, "both", function(level) level=gpio.read(encqa)==0 enccb(xor(level, encbstate)) encastate=level end) --level doesnt seem to work
    gpio.mode(encqb, gpio.INT, gpio.PULLUP)
    gpio.trig(encqb, "both", function(level) level=gpio.read(encqb)==0 enccb(not xor(encastate, level)) encbstate=level end) --level doesnt seem to work
    encastate = gpio.read(encqa)==0
    encbstate = gpio.read(encqb)==0
end
