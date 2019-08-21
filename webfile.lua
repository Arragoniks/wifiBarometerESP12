function readSettings()
    local settings = {}
    if file.open("settings", "r") then
        print("reading settings")
        for k, v in string.gmatch(file.read(), "(%w+)=(%d+%.?%d*)") do
            settings[k] = tonumber(v)
            print(k, v)
        end
        file.close()
    end
    return settings
end

function writeSettings(settings)
    if file.open("settings", "w+") then
        print("writing settings")
        for k, v in pairs(settings) do
            file.writeline(k.."="..v)
            print(k, v)
        end
        file.flush()
        file.close()
    end
end

function readBuffer()
    local result = ""
    if file.open("buffer", "r") then
        print("reading buffer")
        local temp = file.readline()
        i=0
        while temp ~= nil do
            i=i+1
            result = result .. temp
            temp = file.readline()
        end
        file.close()
    end
    print(i)
    return result
end

function writeBuffer(line)
    if file.open("buffer", "a+") then
        print("writing buffer")
        file.writeline(line)
        file.flush()
        file.close()
    end
end

function clearBuffer()
    if file.open("buffer", "w+") then
        print("clearing buffer")
        file.close()
    end
end

function bmecfg(mode)
    local settings = readSettings()
    a = bme280.setup(settings["temperature"], settings["pressure"],
    settings["humidity"], mode,
    settings["interval"], settings["filter"])--make a wake from a sleep mode to a forced mode for saving battery
    delay = settings[tostring(settings["interval"])]
    maxpackage = settings["maxpackage"]
    print(mode)
    print(delay)
    print(a)
end

function receiver(sck, data)
    print(data)
    if string.find(data, "data") then -- different packages and add a timeout for the request time
        sck:on("sent", function(sck) sck:close() end)
        sck:send(readBuffer()) -- make an array
        packagecount = 0
        clearBuffer()
    elseif string.find(data, "stop") then
        tmr.stop(0)
        sck:on("sent", function(sck) sck:close() end)
        sck:send(readBuffer()) -- make an array
        packagecount = 0
        clearBuffer()
        bmecfg(0)
    elseif string.find(data, "start") then
        sck:on("sent", function(sck) sck:close() end)
        sck:send("ok")
        bmecfg(3)
        clearBuffer()
        print(delay)
        packagecount = 0
        timeStart = tmr.now() + delay
        tmr.alarm(0, delay, tmr.ALARM_AUTO, measure)
    elseif string.find(data, "settings") then
        sck:on("sent", function(sck) sck:close() end)
        sck:send("ok")
        local settings = readSettings()
        for k, v in string.gmatch(data, "(%w+)=(%w+)") do
            if settings[k] ~= nil then
                settings[k]=tonumber(v)
                print(k, v)
            end
        end
        writeSettings(settings)
        --bmecfg()
    elseif string.find(data, "connect") then
        sck:on("sent", function(sck) sck:close() end)
        sck:send("ok")
    --[[else
        P, T = bme280.baro()
        sck:on("sent", function(sck) sck:close() end)
        sck:send(P)]]--
    end
    --P, T = bme280.baro()
        --sck:on("sent", function(sck) sck:close() end)
        --sck:send("HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html\r\n\r\n"..
           --"<html><title>NodeMCU</title><body>"..
           --"<p>Pr"..P.."Pr</p>"..
           --"<p>T"..T.."T</p>"..
           --"</body></html>")
end

function measure()
    if packagecount < maxpackage then
        P, T = bme280.baro()
        time = (tmr.now() - timeStart) / 1000000
        pressure = P / 10
        str = time .. " " .. pressure
        packagecount = packagecount + 1
        writeBuffer(str)
    else
        print("Package overflow")
        tmr.stop(0)
        clearBuffer()
        packagecount = 0
        bmecfg(0)
    end
end

sda, scl = 5, 6
i2c.setup(0, sda, scl, i2c.SLOW)
bmecfg(0)

if sv then
    sv:close()
end

sv=net.createServer(net.TCP)


if sv then
    sv:listen(80, function(conn)
        conn:on("receive", receiver)
    end)
end
