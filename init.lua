function exec()
print("init.lua")
dofile("wificfg.lua")
dofile("webfile.lua")
end
tmr.alarm(0, 5000, 0, exec)
