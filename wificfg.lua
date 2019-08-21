wifi.setmode(wifi.SOFTAP)
local cfg = {}
cfg.ssid = "espmeter"
cfg.pwd = "12344321"
cfg.max = 1
wifi.ap.config(cfg)
print(wifi.ap.getip())
cfg = nil
collectgarbage()
