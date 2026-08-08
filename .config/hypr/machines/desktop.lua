local secondaryMonitor = "desc:BNQ BenQ RL2455 PCF07551SL0"
local mainMonitor = "desc:Acer Technologies XF250Q TA1AA0038541"

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.monitor({
    output = secondaryMonitor,
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = mainMonitor,
    mode = "highrr",
    position = "1920x0",
    scale = 1,
})

for workspace = 1, 8 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = mainMonitor,
        default = workspace == 1,
    })
end

for workspace = 9, 10 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = secondaryMonitor,
        default = workspace == 10,
    })
end
