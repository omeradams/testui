local Library = loadstring(game:HttpGetAsync('https://gamefraud.lol/main/user_interface.lua'))();
local Main = Library:Init(game.Players.Name, game.Players.LocalPlayer.UserId).UI

local services = setmetatable({}, {
    __index = function(_, key)
        return game:GetService(key)
    end
})

getgenv().settings = {
    key_bind = 'E',
    aim_type = ''; 
    parts_allowed = {'HumanoidRootPart'};
    trigger_bot = false;
    wall_check = false;
    silent_aim = false;
    mouse_lock_type = 'toggle';
    resolver = false;
    aimbot = false;
    hit_chance = math.random(1,5);
    prediction = 0.1;
    auto_prediction = false;
    smoothness = 0.3;
    esps = {
        fov = {
            visible = false,
            radius = 100,
            color = 'White'
        };
        tracer = {
            visible = true
        };
        highlight = {
            visible = true;
        }
    };
}

local Aim = Main:AddTab('Aim Utilities')
local ESP = Main:AddTab('ESP Utilities')

local AimSection = Aim:AddSection('Aim-Configs')
local GameSection = Aim:AddSection('Game-Section')
local FovSection = ESP:AddSection('FOV')
local TracerSection = ESP:AddSection('Tracer')

AimSection:AddToggle('Trigger Bot', function(value)
    settings.trigger_bot = value
end)

AimSection:AddToggle('Camera Lock', function(value)
    settings.aimbot = value
end)

AimSection:AddToggle('Silent Aim', function(value)
    settings.silent_aim = value
end)

GameSection:AddToggle('Auto Prediction', function(value)
    settings.auto_prediction = value
end)

GameSection:AddSlider('Prediction', 0.1, 0.13, 0.2, function(value)
    settings.prediction = value
end)

GameSection:AddToggle('Wall Check', function(value)
    settings.wall_check = value
end)

FovSection:AddToggle('Visible', function(value)
    settings.esps.fov.visible = value
end)

FovSection:AddSlider('Radius', 50, 200, 100, function(value)
    settings.esps.fov.radius = value
end)

TracerSection:AddToggle('Visible', function(value)
    settings.esps.tracer.visible = value
end)

getgenv().hidden_settings = {
    silent_enabled = false,
    camera_toggle = false
}

-- // Services \\ -- 
local players = services.Players
local workspace = services.Workspace
local userinputservice = services.UserInputService
local runservice = services.RunService


local client = game.Players.LocalPlayer
local camera = game:GetService('Workspace').CurrentCamera
local players = game:GetService('Players')

-- // Arrays \\ -- 

local fov_clrs = {
    ['Red'] = Color3.new(255, 0, 0);
    ['Black'] = Color3.new(0, 0, 0);
    ['Purple'] = Color3.new(230,230,250);
    ['Pink'] = Color3.new(159, 43, 104);
    ['Yellow'] = Color3.new(255, 255, 0);
    ['Grey'] = Color3.new(128, 128, 128);
    ['Blue'] = Color3.new(173, 216, 230);
    ['White'] = Color3.new(1,1,1);
}

local predictionTable = {
    [360] = 0.16537,
    [280] = 0.16780,
    [270] = 0.195566,
    [260] = 0.175566,
    [250] = 0.1651,
    [240] = 0.16780,
    [230] = 0.15692,
    [220] = 0.165566,
    [210] = 0.165566,
    [200] = 0.16942,
    [190] = 0.166547,
    [180] = 0.19284,
    [170] = 0.1923111,
    [160] = 0.16,
    [150] = 0.15,
    [140] = 0.1223333,
    [130] = 0.156692,
    [120] = 0.143765,
    [110] = 0.1455,
    [100] = 0.130340,
    [90] = 0.136,
    [80] = 0.1347,
    [70] = 0.119,
    [60] = 0.12731,
    [50] = 0.127668,
    [40] = 0.125,
    [30] = 0.11,
    [20] = 0.12588,
    [10] = 0.9,
}


-- // Vars \\ -- 
local v2, v3, cf = Vector2.new, Vector3.new, CFrame.new
local client = players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = client:GetMouse()

-- // Functions \\ -- 

local velocity_change = function(target_root)
    target_root.Velocity = Vector3.new(target_root.Velocity.X, (target_root.Velocity.Y / 5), target_root.Velocity.Z)
    target_root.AssemblyLinearVelocity = Vector3.new(target_root.Velocity.X, (target_root.Velocity.Y / 5), target_root.Velocity.Z)
end

local sync_part = function(target, part)
    if target.HumanoidRootPart.Velocity.Magnitude > 75 then
        target[part].Velocity = v3(0, 0, 0)
        target[part].AssemblyLinearVelocity = v3(0, 0, 0)
    end
end

local closest_pingindex = function(player_ping)
    local closestIndex = nil
    local closestDistance = math.huge

    for ping, prediction in pairs(predictionTable) do
        local distance = math.abs(player_ping - ping)
        if distance < closestDistance then
            closestIndex = ping
            closestDistance = distance
        end
    end
    
    return closestIndex, closestDistance
end

is_visible = function(player)
 
        local my_char = client.Character
        local my_root = my_char.HumanoidRootPart
        
        local enemy_char = player.Character
        local enemy_root = enemy_char.HumanoidRootPart
        
        if (my_char and my_root and enemy_char and enemy_root) then 
            local position, onscreen = camera:WorldToViewportPoint(enemy_root.Position)
            local cast = {my_root.Position, enemy_root.Position}
            local ignore = {my_char, enemy_char}
            
            local result = camera:GetPartsObscuringTarget(cast, ignore)
            
            return (onscreen and #result == 0)
        end
 
    
    return false
end

local function Draw(obj, props)
    local obj_drawing = Drawing.new(obj)

    for i,v in pairs(props) do
        obj_drawing[i] = v
    end

    return obj_drawing
end

local closestplr_client = function()
    local distance, closest_player = math.huge;
    
    for i,v in pairs(players:GetPlayers()) do
        if ( v ~= client and v.Character and v.Character:FindFirstChild('HumanoidRootPart') ) then
            local magnitude = (client.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude

             if magnitude < distance then
                distance = magnitude
                closest_player = v
            end
        end
    end

    return closest_player
end

local closestplr_mouse = function()
    local player = nil 
    local dist = settings.esps.fov.radius

    for i, v in pairs(players:GetPlayers()) do 
        if (v == client) then continue end 

        local char = v.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')

        if (char and root) then 
            local pos = camera:WorldToViewportPoint(root.Position)
            local mag = (v2(pos.x, pos.y) - userinputservice:GetMouseLocation()).magnitude 
            if (mag < dist) then 
                dist = mag 
                player = v 
            end
        end
    end

    return player
end
local getplayer_ping = function()
     return client:GetNetworkPing() * 2000
end

local closestplr_part = function()
    local player = closestplr_mouse()
    local part = nil 
    local dist = settings.esps.fov.radius
    
    if player then 
        for i,v in pairs(player.Character:GetChildren()) do
            if ( v:IsA('Basepart') and not table.find(settings.parts_allowed, v.Name) and v.Humanoid and v.Humanoid.Health > 2) then
                local pos = camera:WorldToViewportPoint(v.Position)
                local mag = (v2(pos.x, pos.y) - userinputservice:GetMouseLocation()).magnitude 
    
                if (mag < dist) then 
                    dist = mag
                    part = v 
                end
            end
        end
    end
    
    return part
end

local function on_key(input, typing)
    if (typing) then return end 

    if (settings.silent_type == 'toggle') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.silent_enabled = not hidden_settings.silent_enabled
        end
    end

    if (settings.silent_type == 'hold') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.silent_enabled = true
        end
    end
end

local function off_key(input, typing)
    if (typing) then return end 

    if (settings.silent_type == 'hold') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.silent_enabled = false
        end
    end
end


local function tog_lock(input, typing)
    if (typing) then return end 

    if (settings.lock_type == 'toggle') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.camera_toggle = not hidden_settings.camera_toggle
        end
    end

    if (settings.lock_type == 'hold') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.camera_toggle = true
        end
    end
end

local function off_lock(input, typing)
    if (typing) then return end 

    if (settings.silent_type == 'hold') then 
        if (input.KeyCode == Enum.KeyCode[settings.keybind]) then
            hidden_settings.camera_toggle = false
        end
    end
end

userinputservice.InputBegan:Connect(on_key)
userinputservice.InputEnded:Connect(off_key)
userinputservice.InputEnded:Connect(tog_lock)
userinputservice.InputEnded:Connect(off_lock)

local fov_circle = Draw('Circle', { Visible = settings.esps.fov.visible, Position = v2(0,0), Radius = settings.esps.fov.radius, Filled = false, Thickness = 1 })

local target
local closestIndex, closestDistance = closest_pingindex(getplayer_ping())

runservice.PostSimulation:Connect(function()
    closestIndex, closestDistance = closest_pingindex(getplayer_ping())
    if settings.auto_prediction then
        settings.prediction = predictionTable[closestIndex]
    end
    
    target = closestplr_mouse()

    fov_circle.Position = userinputservice:GetMouseLocation()
    fov_circle.Color = fov_clrs[settings.esps.fov.color]
    fov_circle.Visible = settings.esps.fov.visible
    fov_circle.Radius = settings.esps.fov.radius
end)

local esp_lib = {}; do 
    local cache = {
        tracers = {},
        text = {}
    }
    
    function esp_lib:add_text(player)
        if (cache.text[player]) then return end 
        cache.text[player] = Draw('Text', {Transparency = 1, Color = Color3.new(193,202,222), Visible = false, Center = true, Outline = true, Font = 2, Size = 12})
    end
    
    function esp_lib:add_tracer(player)
        if (cache.tracers[player]) then return end 
        cache.tracers[player] = Draw('Line', {Transparency = 1, Color = Color3.new(193,202,222), Thickness = 1, Visible = false})
    end
    
    local function on_player()
        for i,v in pairs(players:GetPlayers()) do 
            if (v == client) then continue end 
            
            esp_lib:add_tracer(v)
            esp_lib:add_text(v)
        end
    end
    
    on_player()
    players.PlayerAdded:Connect(on_player())
    
    
    task.spawn(function()
        while (true) do 
            for player, text in pairs(cache.text) do 
                local char = player.Character 
                local root = char and char:FindFirstChild('HumanoidRootPart')
                local pos, onscreen = nil, false 
                local _text = ''
                
                if (char and root) then 
                    pos, onscreen = camera:WorldToViewportPoint(root.Position)
                    text.Position = Vector2.new(pos.x, pos.y) - Vector2.new(0, text.TextBounds.y)
                    _text = '[ ' .. player.Name .. ' ]'
                end
                
                text.Text = _text
                text.Visible = onscreen and settings.esps.tracer.visible
            end
           
            runservice.RenderStepped:Wait() 
        end
    end)
    
    
    task.spawn(function()
        while (true) do 
            for player, line in pairs(cache.tracers) do 
                local char = player.Character 
                local root = char and char:FindFirstChild('HumanoidRootPart')
                local pos, onscreen = nil, false 
                
                if (char and root) then 
                    pos, onscreen = camera:WorldToViewportPoint(root.Position)
                    line.From = camera.ViewportSize / 2
                    line.To = Vector2.new(pos.x, pos.y)
                end
                 
                line.Visible = onscreen and settings.esps.tracer.visible
            end
           
            runservice.RenderStepped:Wait() 
        end
    end)
end

local getclosest_prediction = function(ping)
    local max_value, cprediction = math.huge

    for k,v in pairs(prediction_arr) do
        local value = (ping - k)

        if value < max_value then
            max_value = value
            cprediction = v
        end
    end

    return cprediction
end

local shoot
shoot = hookmetamethod(game, '__namecall', function(self, ...) 
    local method = getnamecallmethod()
    local args = {...}

    if (method == 'FireServer' and self.Name == 'RemoteEvent' and args[1] == 'shoot' and hidden_settings.silent_enabled and target) then
        pcall(function()
            local char = target.Character 
            local root = char and char:FindFirstChild('HumanoidRootPart')
    
            if (char and root) then 
                local target_part = (settings.aim_type == 'Closest Part' and closestplr_part()) or root
                velocity_change(root)
                sync_part(char, target_part)
    
                args[2][1] = target_part.Position + (root.Velocity * settings.prediction)
                self.FireServer(self, unpack(args))
            end
        end)
    end

    return shoot(self, ...)
end)

spawn(function()
    while true do task.wait()
        if (hidden_settings.silent_enabled and settings.aimbot) then 
            if (target and settings.wallcheck) then
                pcall(function()
                    if is_visible(target) then
                    
                        local char = target.Character 
                        local root = char and char:FindFirstChild('HumanoidRootPart')
                        local target_part = (settings.aim_type == 'Closest Part' and closestplr_part()) or root
                        local target_part_pos, _ = workspace.CurrentCamera:WorldToViewportPoint(target_part.Position)
                        target_part_pos = Vector2.new(target_part_pos.X, target_part_pos.Y)
                        local offset = (target_part_pos - userinputservice:GetMouseLocation()) * settings.smoothness
                        
                        velocity_change(root)
                        sync_part(char, target_part)
            
                        if (target and char and root and hidden_settings.camera_toggle and target_part ~= nil and target_part_pos ~= nil) then
                            mousemoverel(offset.X, offset.Y)
                        end
                    end
                end)
            elseif target and not settings.wallcheck then
                if (hidden_settings.silent_enabled and settings.aimbot) then
                    pcall(function()
                        
                        local char = target.Character 
                        local root = char and char:FindFirstChild('HumanoidRootPart')
                        local target_part = (settings.aim_type == 'Closest Part' and closestplr_part()) or root
                        local target_part_pos, _ = workspace.CurrentCamera:WorldToViewportPoint(target_part.Position)
                        target_part_pos = Vector2.new(target_part_pos.X, target_part_pos.Y)
                        local offset = (target_part_pos - userinputservice:GetMouseLocation()) * settings.smoothness
                        
                        velocity_change(root)
                        sync_part(char, target_part)
                    
                        if (target and char and root and hidden_settings.camera_toggle and target_part ~= nil and target_part_pos ~= nil) then
                            mousemoverel(offset.X, offset.Y)
                        end
                    end)
                end
            end
        end
    end
end)
