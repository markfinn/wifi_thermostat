--------------------------------------
-- Upgrader module for NODEMCU
-- LICENCE: http://opensource.org/licenses/MIT
-- cloudzhou<wuyunzhou@espressif.com>
--------------------------------------

--require('Upgrader')
--Upgrader.update('EspClient.lua', 'http://115.29.202.58/static/script/EspClient.lua')
--Upgrader.updateEspClient()

local moduleName = ...
local M = {}
_G[moduleName] = M

=string.find("HTTP/1.0 200 OK\r\n", 'HTTP/1.0%s+(%d+)[^\r\n]*\r\n')

=string.find("Content-Length: 159\r\n", 'Content%-Length:%s*(%d+)%s*\r\n')
=string.sub("asdfqwer", 4)
=tonumber("200")==200
----
function M.update(filename, url)
headers=''
local save
local function saveneedresp(s)
   if s then
        headers=headers..s
   a,b,r=string.find(headers, 'HTTP/1.0%s+(%d+)[^\r\n]*\r\n')
   if a==1 and tonumber(r)==200 then
     headers=string.sub(headers, b+1)
     save=saveneedlen
     return false
   elseif s and not a then
     return false
   else
     return nil
   end
save=saveneedresp

local function saveneedlen(s)
   if s then
        headers=headers..s
   a,b,r=string.find(headers, 'HTTP/1.0%s+(%d+)[^\r\n]*\r\n')
   if a==1 and tonumber(r)==200 then
     headers=string.sub(headers, b+1)
     save=saveneedlen
     return false
   elseif s and not a then
     return false
   else
     return nil
   end

   s and not a and not string.find(header, '\r\n\r\n')
    if not s or string.strlen(headers)+string.strlen(s) then
    
    
    file.open(filename, 'w')
    if isTruncated then
        file.write(response)
        return
    end
    header = header..response
    local i, j = string.find(header, '\r\n\r\n')
    if i == nil or j == nil then
        return
    end
    prefixBody = string.sub(header, j+1, -1)
    file.write(prefixBody)
    header = ''
    isTruncated = true
    return
        local function reset()
            header = ''
            isTruncated = false
            file.close()
            tmr.stop(0)
            print(filename..' saved')

end

    
    local ip, port, path = string.gmatch(url, 'http://([0-9.]+):?([0-9]*)(/.*)')()
    if ip == nil then
        return false
    end
    if port == nil or port == '' then
        port = 80
    end
    port = port + 0
    if path == nil or path == '' then
        path = '/'
    end
    conn = net.createConnection(net.TCP, 0)
    conn:on('receive', function(sck, response)
print('r')
        save(response)
    end)
    conn:on('connection', function(sck, response)
print('cd')
    conn:send('GET '..path..' HTTP/1.0\r\nHost: '..ip..'\r\n'
    ..'Connection: close\r\nAccept: */*\r\n\r\n')
    end)

    conn:on('disconnection', function(sct)
print('dc')
save()
    end)
    conn:connect(port, ip)
    print('con', ip, port)
end

