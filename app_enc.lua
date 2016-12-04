do
    pos, press, queue = rotary.getpos(0)
    local oldpos = pos
    local function enccb(type, pos, when)
       move = math.floor(oldpos/4) - math.floor(pos/4) 
       if move~=0 then
         oldpos=pos
         local s
         if fahrenheit then
            s=math.floor(setpoint*9/5 + move +.5)*5/9
         else
            s=(math.floor(setpoint + move + .5)*2 +.5)/2
         end
         setsetpoint(s)
       end
    end

    function enccbsw(type, pos, when)
         s = setpoint == settings.offsetpoint and settings.onsetpoint or settings.offsetpoint
         setsetpoint(s)
    end

    rotary.on(0, rotary.CLICK, enccbsw)
    rotary.on(0, rotary.TURN, enccb)
end


