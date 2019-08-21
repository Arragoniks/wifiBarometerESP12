wifi.setmode(wifi.SOFTAP)
config = {}
config.ssid = "espmeter"
config.pwd = "12344321"
wifi.ap.config(config)
print(wifi.ap.getip())
cfg = nil
collectgarbage()

for mac,ip in pairs(wifi.ap.getclient()) do
    print(mac,ip)
end
--[[
config_ip = {}
config_ip.ip = "192.168.2.1"
config_ip.netmask = "255.255.255.0"
config_ip.gateway = "192.168.2.1"
wifi.ap.setip(config_ip)
]]--

--LEDpin = 2
--gpio.mode(LEDpin, gpio.OUTPUT)
--server = net.createServer(net.TCP)
client = net.createConnection(net.TCP)

function receiver(sck, data)
    print(data)
    if(not string.find(data, "HTTP")) then
        client:send("Hello, i've got it!")
    end
    
  --[[if string.find(data, "LED ON")  then
   sck:send("\r\nLED ON")
   gpio.write(LEDpin, gpio.HIGH)
  elseif string.find(data, "LED OFF")  then
   sck:send("\r\nLED OFF")
   gpio.write(LEDpin, gpio.LOW)
  elseif string.find(data, "EXIT")  then
   sck:close()
  else
   sck:send("\r\nCommand Not Found...!!!")
  end]]--
end
--[[
if server then
    --server:connect(4000, "192.168.4.2")
    --server:send("hello")
  server:listen(80, function(conn)
  --print("yuuuuhuv")
  conn:on("receive", receiver)
  --conn:send("Hello Client\r\n")
  --conn:send("1. Send 'LED ON' command to ON LED\r\n")
  --conn:send("2. Send 'LED OFF' command to OFF LED\r\n")
  --conn:send("3. Send 'EXIT' command to Exit\r\n")
  end)
end
]]--
function sendSmth()
print("sending")
    client:send("hello server!")
end
function connectSmth()
print("connection")
    client:connect(4000, "192.168.4.2")
end
if client then
    client:on("connection", sendSmth)
    tmr.alarm(0, 20000, 0, connectSmth)
end
