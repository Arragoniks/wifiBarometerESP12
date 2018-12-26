function bmecfg()
    sda, scl = 5, 6
    i2c.setup(0, sda, scl, i2c.SLOW)
    if file.open("properties", "r")then
        a = tonumber(file.readline())
        b = tonumber(file.readline())
        c = tonumber(file.readline())
        d = tonumber(file.readline())
        e = tonumber(file.readline())
        file.close()
        print(a)
        print(b)
        print(c)
        print(d)
        print(e)
    end
    bme280.setup(a, b, 1, c, d, e)--get array
end
bmecfg()
if sv then
    sv:close()
end

sv=net.createServer(net.TCP)

function sendData(sck)
    
end

function receiver(sck, data)
    print(data)
    
    local _, _, method, path, vars = string.find(data, "([A-Z]+) (.+)?(.+) HTTP");
    if(method == nil)then
        _, _, method, path = string.find(data, "([A-Z]+) (.+) HTTP");
    end
    print(method)
    print(path)
    print(vars)
    if (vars ~= nil)then
        key = ""
        value = ""
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            key = k
            value = v
        end
        print(key)
        print(value)
        if (key == "apply")then
            -- Print received data
            --print(data)
            bmecfg()
            --[[P, T = bme280.baro()
            -- H, t = bme280.humi()
            -- Send response
            sck:on("sent", function(sck) sck:close() end)
            sck:send("HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html\r\n\r\n"..
               "<html><title>NodeMCU</title><body>"..
               "<p>Pr"..P.."Pr</p>"..
               "<p>T"..T.."T</p>"..
               "</body></html>")]]--
        else
            a1 = 0
            b1 = 0
            c1 = 0
            d1 = 0
            e1 = 0
            if file.open("properties", "r")then
                a1 = tonumber(file.readline())
                b1 = tonumber(file.readline())
                c1 = tonumber(file.readline())
                d1 = tonumber(file.readline())
                e1 = tonumber(file.readline())
                file.close()
            end
            
            if (key == "temp")then
                a1 = tonumber(value)
            elseif (key == "baro")then
                b1 = tonumber(value)
            elseif (key == "inter")then
                d1 = tonumber(value)
            elseif (key == "filter")then
                e1 = tonumber(value)
            end
            if file.open("properties", "w+")then
                file.writeline(tostring(a1))
                file.writeline(tostring(b1))
                file.writeline(tostring(c1))
                file.writeline(tostring(d1))
                file.writeline(tostring(e1))
                file.close()
            end
        end
    --[[else
        P, T = bme280.baro()
        sck:on("sent", function(sck) sck:close() end)
        sck:send("HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html\r\n\r\n"..
           "<html><title>NodeMCU</title><body>"..
           "<p>Pr"..P.."Pr</p>"..
           "<p>T"..T.."T</p>"..
           "</body></html>")]]--
    end
    P, T = bme280.baro()
        sck:on("sent", function(sck) sck:close() end)
        sck:send("HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html\r\n\r\n"..
           "<html><title>NodeMCU</title><body>"..
           "<p>Pr"..P.."Pr</p>"..
           --"<p>T"..T.."T</p>"..
           "</body></html>")
end

if sv then
    sv:listen(80, function(conn)
        conn:on("receive", receiver)
    end)
end
