dhtpin=4

sdapin = 7
sclpin = 6
dispaddr = 0x3c

relaypin=8


function relay(state)
    gpio.write(relaypin, state and gpio.HIGH or gpio.LOW) 
end


function draw()
     disp:setFont(u8g.font_6x10)
     disp:drawStr( 0+0, 20+0, "Hello!")
    -- disp:setFont(u8g.font_6x13)   
  --   disp:drawStr( 0, 20+16, "Hello!")
     disp:setScale2x2()
     s=temperature and string.format("%3d", temperature+.5) or "XXX"

     disp:drawStr( 0, (20+16)/2, "temp: "..s)
     disp:undoScale()

     disp:drawBox(0, 0, 3, 3)
     disp:drawBox(disp:getWidth()-6, 0, 6, 6)
     disp:drawBox(disp:getWidth()-9, disp:getHeight()-9, 9, 9)
     disp:drawBox(0, disp:getHeight()-12, 12, 12)
end


function setup()
    gpio.mode(relaypin, gpio.OUTPUT)
    relay(false)
    
    i2c.setup(0, sdapin, sclpin, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(dispaddr)
end




function loop()
    while true do
        local status,temp,humi=dht.readxx(dhtpin)
        if status == dht.OK then
             temperature=temp
--            print("DHT Temperature:"..temp..";".."Humidity:"..humi)
            tmr.wdclr()
        end
    disp:firstPage()
    repeat
        draw()
    until disp:nextPage() == false

    end
end

setup()
loop()




