function exec()
dofile("wificfg.lua")
dofile("webfile.lua")
end
tmr.alarm(0, 10000, 0, exec)
