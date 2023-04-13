--[[

File Name:      GFL.lua
Author:         deity#9160
Description:    UI Library for gamefraud.lol

yue was here <3

--]]

--/ Services
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--/ Locals
local TILinear = TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--/ Functions
local Class = function(Name)
    local NewClass = {}
    NewClass.__index = NewClass
    NewClass.ClassName = Name
    return NewClass
end

local Tween = function(Instance, Goal, Callback, TweenInfoOverride)
    Callback = Callback or function() end
    TweenInfoOverride = TweenInfoOverride or nil

    local T = TweenService:Create(Instance, TweenInfoOverride or TILinear, Goal)
    T.Completed:Connect(Callback)
    T:Play()
    return T
end

local GenId = function()
    return HttpService:GenerateGUID(false)
end

--/ Main
local Connections = Class("Connections")
local ClickHandler = Class("ClickHandler")

local Button = Class("Button")
local Section = Class("Section")
local Tab = Class("Tab")
local Toggle = Class("Toggle")
local Slider = Class("Slider")

local UI = Class("UI")

local Library = Class("Library")

function Slider.new(Section, Text, Min, Max, Increment, Default, Callback)
    local slider = setmetatable({}, Slider)

    Min = Min or 0
    Max = Max or 100
    Increment = Increment or 1
    Default = Default or 50
    Section = Section or nil
    Text = Text or "Toggle"
    Callback = Callback or function() print(slider.Text .. " was toggled!") end

    slider.Section = Section
    slider.Text = Text
    slider.Callback = Callback
    slider.Min = Min
    slider.Max = Max
    slider.Increment = Increment
    slider.Default = Default
    slider.Value = 0
    slider.Id = GenId()
    slider.Connections = Connections.new()

    slider.Dragging = false

    slider:_createInstances()
    slider:_setupDragging()

    return slider
end

function Slider:_setupDragging()
    local DragTI = TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    self.ClickHandler = ClickHandler.new(self.Instances._SliderNormal, {
        Neutral = function()
            Tween(self.Instances._Fill, { BackgroundColor3 = Color3.fromRGB(64, 64, 64) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(57, 57, 57) })
        end,
        Hover = function()
            Tween(self.Instances._Fill, { BackgroundColor3 = Color3.fromRGB(64, 64, 64) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(66, 66, 66) })
        end,
        Click = function()
            self.Dragging = true

            Tween(self.Instances._Fill, { BackgroundColor3 = Color3.fromRGB(255, 100, 100) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(255, 100, 100) })

            while RunService.RenderStepped:Wait() and self.Dragging do
                local Percentage = math.clamp((Mouse.X - self.Instances._Slider.AbsolutePosition.X) / (self.Instances._Slider.AbsoluteSize.X), 0, 1)
                local Value = (self.Min + ((self.Max - self.Min) * Percentage))
                local a, b = math.modf(Value / self.Increment)
                Value = math.clamp(self.Increment * (a + (b > 0.5 and 1 or 0)), self.Min, self.Max)
                self.Value = Value
                
                Tween(self.Instances._Value, { TextTransparency = .5 }, function()
                    self.Instances._Value.Text = string.format("%.14g", self.Value)
                    Tween(self.Instances._Value, { TextTransparency = 0 })
                end)
                
                Tween(self.Instances._Fill, {Size = UDim2.fromScale(Percentage, 1)}, function()
                    self.Callback(self.Value)
                end, DragTI)
            end
        end
    }, function()
        self.Dragging = false
    end)
end

function Slider:SetCallback(NewCallback)
    self.Callback = NewCallback
end

function Slider:SetText(NewText)
    self.Text = NewText
    Tween(self.Instances._Text, { TextTransparency = .5 }, function()
        self.Instances._Text.Text = self.Text
        Tween(self.Instances._Text, { TextTransparency = 0 })
    end)
end

function Slider:SetValue(NewValue)
    self.Value = math.clamp(NewValue, self.Min, self.Max)

    Tween(self.Instances._Value, { TextTransparency = 1 }, function()
        self.Instances._Value.Text = self.Value
        Tween(self.Instances._Value, { TextTransparency = 0 })
    end)
    
    Tween(self.Instances._Fill, {Size = UDim2.fromScale(((self.Value - self.Min) / (self.Max - self.Min)), 1) }, function()
        self.Callback(self.Value)
    end)
end

function Slider:GetValue()
    return self.Value
end

function Slider:_createInstances()
    self.Instances = {
        ["_SliderNormal"] = Instance.new("Frame");
        ["_Text"] = Instance.new("TextLabel");
        ["_Value"] = Instance.new("TextLabel");
        ["_Slider"] = Instance.new("Frame");
        ["_UICorner"] = Instance.new("UICorner");
        ["_Fill"] = Instance.new("Frame");
        ["_UICorner1"] = Instance.new("UICorner");
        ["_Dragger"] = Instance.new("Frame");
        ["_UICorner2"] = Instance.new("UICorner");
        ["_UIStroke"] = Instance.new("UIStroke");
    }

    self.Instances["_SliderNormal"].BackgroundColor3 = Color3.fromRGB(60.00000022351742, 60.00000022351742, 60.00000022351742)
    self.Instances["_SliderNormal"].BackgroundTransparency = 1
    self.Instances["_SliderNormal"].Size = UDim2.new(1, 0, 0, 34)
    self.Instances["_SliderNormal"].Name = "SliderNormal"
    self.Instances["_SliderNormal"].Parent = self.Section.Instances._Content

    self.Instances["_Text"].Font = Enum.Font.Ubuntu
    self.Instances["_Text"].Text = self.Text
    self.Instances["_Text"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Text"].TextSize = 12
    self.Instances["_Text"].TextWrapped = true
    self.Instances["_Text"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_Text"].TextYAlignment = Enum.TextYAlignment.Top
    self.Instances["_Text"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Text"].BackgroundTransparency = 1
    self.Instances["_Text"].Position = UDim2.new(0, 4, 0, 4)
    self.Instances["_Text"].Size = UDim2.new(1, -50, 0, 12)
    self.Instances["_Text"].Name = "Text"
    self.Instances["_Text"].Parent = self.Instances["_SliderNormal"]

    self.Instances["_Value"].Font = Enum.Font.Ubuntu
    self.Instances["_Value"].Text = self.Default
    self.Instances["_Value"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Value"].TextSize = 12
    self.Instances["_Value"].TextWrapped = true
    self.Instances["_Value"].TextXAlignment = Enum.TextXAlignment.Right
    self.Instances["_Value"].TextYAlignment = Enum.TextYAlignment.Top
    self.Instances["_Value"].AnchorPoint = Vector2.new(1, 0)
    self.Instances["_Value"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Value"].BackgroundTransparency = 1
    self.Instances["_Value"].Position = UDim2.new(1, -4, 0, 4)
    self.Instances["_Value"].Size = UDim2.new(0, 50, 0, 12)
    self.Instances["_Value"].Name = "Value"
    self.Instances["_Value"].Parent = self.Instances["_SliderNormal"]

    self.Instances["_Slider"].BackgroundColor3 = Color3.fromRGB(55.000004321336746, 55.000004321336746, 55.000004321336746)
    self.Instances["_Slider"].BorderSizePixel = 0
    self.Instances["_Slider"].Position = UDim2.new(0, 4, 0, 22)
    self.Instances["_Slider"].Size = UDim2.new(1, -8, 0, 4)
    self.Instances["_Slider"].Name = "Slider"
    self.Instances["_Slider"].Parent = self.Instances["_SliderNormal"]

    self.Instances["_UICorner"].Parent = self.Instances["_Slider"]

    self.Instances["_Fill"].BackgroundColor3 = Color3.fromRGB(64.00000378489494, 64.00000378489494, 64.00000378489494)
    self.Instances["_Fill"].Size = UDim2.new(0.5, 0, 1, 0)
    self.Instances["_Fill"].Name = "Fill"
    self.Instances["_Fill"].Parent = self.Instances["_Slider"]

    self.Instances["_UICorner1"].Parent = self.Instances["_Fill"]

    self.Instances["_Dragger"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_Dragger"].BackgroundColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Dragger"].Position = UDim2.new(1, 0, 0.5, 0)
    self.Instances["_Dragger"].Size = UDim2.new(0, 6, 0, 12)
    self.Instances["_Dragger"].Name = "Dragger"
    self.Instances["_Dragger"].Parent = self.Instances["_Fill"]

    self.Instances["_UICorner2"].Parent = self.Instances["_Dragger"]

    self.Instances["_UIStroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Instances["_UIStroke"].Color = Color3.fromRGB(57.00000420212746, 57.00000420212746, 57.00000420212746)
    self.Instances["_UIStroke"].Parent = self.Instances["_Slider"]

    self:SetValue(self.Default)

    self.Section:_updateSize()
end

function Slider:_getAbsoluteHeight()
    return self.Instances._SliderNormal.AbsoluteSize.Y    
end

function Slider:Destroy()
    self.ClickHandler.Connections:DisconnectAll()
    self.Instances._SliderNormal:Destroy()
    self.Section.Components[self.Id] = nil
    self.Section:_updateSize()
end

function Toggle.new(Section, Text, Callback)
    local toggle = setmetatable({}, Toggle)

    Section = Section or nil
    Text = Text or "Toggle"
    Callback = Callback or function() print(toggle.Text .. " was toggled!") end

    if not Section then return error("A toggle can only be added to a section.") end
    if Section.ClassName ~= "Section" then return error("A toggle can only be added to a section.") end

    toggle.Enabled = false
    toggle.Text = Text
    toggle.Section = Section
    toggle.Callback = Callback
    toggle.Id = GenId()

    toggle:_createInstances()

    return toggle
end

function Toggle:_createInstances()
    self.Instances = {
        ["_ToggleNormal"] = Instance.new("Frame");
        ["_Text"] = Instance.new("TextLabel");
        ["_Clickable"] = Instance.new("Frame");
        ["_UICorner"] = Instance.new("UICorner");
        ["_UICorner1"] = Instance.new("UICorner");
        ["_UIStroke"] = Instance.new("UIStroke");
        ["_Icon"] = Instance.new("ImageLabel");
    }

    self.Instances["_ToggleNormal"].BackgroundColor3 = Color3.fromRGB(60.00000022351742, 60.00000022351742, 60.00000022351742)
    self.Instances["_ToggleNormal"].BackgroundTransparency = 1
    self.Instances["_ToggleNormal"].Size = UDim2.new(1, 0, 0, 18)
    self.Instances["_ToggleNormal"].Name = "ToggleNormal"
    self.Instances["_ToggleNormal"].Parent = self.Section.Instances._Content

    self.Instances["_Text"].Font = Enum.Font.Ubuntu
    self.Instances["_Text"].Text = self.Text
    self.Instances["_Text"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Text"].TextSize = 12
    self.Instances["_Text"].TextWrapped = true
    self.Instances["_Text"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_Text"].TextYAlignment = Enum.TextYAlignment.Top
    self.Instances["_Text"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Text"].BackgroundTransparency = 1
    self.Instances["_Text"].Position = UDim2.new(0, 4, 0, 4)
    self.Instances["_Text"].Size = UDim2.new(1, -24, 1, -6)
    self.Instances["_Text"].Name = "Text"
    self.Instances["_Text"].Parent = self.Instances["_ToggleNormal"]

    self.Instances["_ToggleNormal"].Size = UDim2.new(1, 0, 0, self.Instances._Text.TextBounds.Y + 6)

    self.Instances["_Clickable"].AnchorPoint = Vector2.new(1, 0.5)
    self.Instances["_Clickable"].BackgroundColor3 = Color3.fromRGB(52.00000450015068, 52.00000450015068, 52.00000450015068)
    self.Instances["_Clickable"].Position = UDim2.new(1, -4, 0.5, 0)
    self.Instances["_Clickable"].Size = UDim2.new(0, 14, 0, 14)
    self.Instances["_Clickable"].Name = "Clickable"
    self.Instances["_Clickable"].Parent = self.Instances["_ToggleNormal"]

    self.Instances["_UICorner"].CornerRadius = UDim.new(0, 2)
    self.Instances["_UICorner"].Parent = self.Instances["_Clickable"]

    self.Instances["_UICorner1"].CornerRadius = UDim.new(1, 0)
    self.Instances["_UICorner1"].Parent = self.Instances["_Fill"]

    self.Instances["_Icon"].Image = "rbxassetid://13053611439"
    self.Instances["_Icon"].ImageColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Icon"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_Icon"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Icon"].BackgroundTransparency = 1
    self.Instances["_Icon"].ImageTransparency = 1
    self.Instances["_Icon"].Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Instances["_Icon"].Size = UDim2.new(0, 10, 0, 10)
    self.Instances["_Icon"].Name = "Icon"
    self.Instances["_Icon"].Parent = self.Instances["_Clickable"]

    self.Instances["_UIStroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Instances["_UIStroke"].Color = Color3.fromRGB(70.00000342726707, 70.00000342726707, 70.00000342726707)
    self.Instances["_UIStroke"].Parent = self.Instances["_Clickable"]

    self.ClickHandler = ClickHandler.new(self.Instances._ToggleNormal, {
        Neutral = function()
            if self.Enabled then return end

            Tween(self.Instances._Icon, { ImageTransparency = 1 })
            Tween(self.Instances._Clickable, { BackgroundColor3 = Color3.fromRGB(52, 52, 52) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(52, 52, 52) })
        end,
        Hover = function()
            if self.Enabled then return end

            Tween(self.Instances._Icon, { ImageTransparency = 1 })
            Tween(self.Instances._Clickable, { BackgroundColor3 = Color3.fromRGB(52, 52, 52) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(70, 70, 70) })
        end,
        Click = function()
            if self.Enabled then return end

            Tween(self.Instances._Icon, { ImageTransparency = 1 })
            Tween(self.Instances._Clickable, { BackgroundColor3 = Color3.fromRGB(52, 52, 52) })
            Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(255, 100, 100) })
        end
    }, function()
        if self.Enabled then self:Disable() else self:Enable() end
    end)

    self:_updateSize()
end

function Toggle:Destroy()
    self.ClickHandler.Connections:DisconnectAll()
    self.Instances._ToggleNormal:Destroy()
    self.Section:_updateSize()
    self.Section.Components[self.Id] = nil
end

function Toggle:SetText(NewText)
    self.Text = NewText
    self:_updateSize()
end

function Toggle:SetCallback(NewCallback)
    self.Callback = NewCallback
end

function Toggle:_updateSize()
    Tween(self.Instances._Text, {TextTransparency = 1}, function()
        local OldSize = self.Instances._ToggleNormal.Size
        self.Instances._ToggleNormal.Size = UDim2.new(1, 0, 100, 18)
        self.Instances._Text.Text = self.Text
        local NewYSize = self.Instances._Text.TextBounds.Y
        self.Instances._ToggleNormal.Size = OldSize

        Tween(self.Instances._ToggleNormal, {Size = UDim2.new(1, 0, 0, NewYSize + 6)}, function()
            Tween(self.Instances._Text, {TextTransparency = 0}, function()
                self.Section:_updateSize()
            end)
        end)
    end)
end

function Toggle:Enable()
    self.Enabled = true
    Tween(self.Instances._Icon, { ImageTransparency = 0 })
    Tween(self.Instances._Clickable, { BackgroundColor3 = Color3.fromRGB(255, 100, 100) })
    Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(255, 100, 100) })
    self:Fire()
end

function Toggle:Disable()
    self.Enabled = false
    Tween(self.Instances._Icon, { ImageTransparency = 1 })
    Tween(self.Instances._Clickable, { BackgroundColor3 = Color3.fromRGB(52, 52, 52) })
    Tween(self.Instances._UIStroke, { Color = Color3.fromRGB(52, 52, 52) })
    self:Fire()
end

function Toggle:Fire()
    self.Callback(self.Enabled)
end

function Toggle:_getAbsoluteHeight()
    return self.Instances._ToggleNormal.AbsoluteSize.Y
end

function Toggle:GetState()
    return self.Enabled
end

function Library:Init(Username, UserId, ToggleKey)
    local library = setmetatable({}, Library)

    if getgenv().GFL then getgenv().GFL.UI:Destroy() end

    ToggleKey = ToggleKey or Enum.KeyCode.End

    library.UI = UI.new(library, Username, UserId, ToggleKey)

    getgenv().GFL = { UI = library.UI }

    return library
end

function Library:Destroy()
    self.UI:Destroy()
end

function UI.new(Library, Username, UserId, ToggleKey)
    local ui = setmetatable({}, UI)

    Library = Library or nil
    Username = Username or "Username"
    UserId = UserId or 1000000000

    if not Library then return error("The UI can only be created with the Library.") end
    if Library.ClassName ~= "Library" then return error("The UI can only be created with the Library.") end

    ui.ScreenGui = Instance.new("ScreenGui")
    ui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ui.ScreenGui.DisplayOrder = 10000
    ui.ScreenGui.ResetOnSpawn = false
    
    ui.Id = GenId()
    ui.ToggleKey = ToggleKey
    ui.Library = Library

    ui.Username = Username
    ui.UserId = UserId

    ui.Tabs = {}
    ui.Visible = true

    ui.Connections = Connections.new()

    ui:_createInstances()
    ui:_setupDragging()
    ui:_updateNavigationSize()
    ui:_updateVisibility()
    ui:_setupShowHide()

    if gethui then
        ui.ScreenGui.Parent = gethui()
    else
        syn.protect_gui(ui.ScreenGui)
        ui.ScreenGui.Parent = CoreGui
    end

    return ui
end

function UI:_setupShowHide()
    self.Connections:Add(UserInputService.InputBegan:Connect(function(Input, GPE)
        if Input.KeyCode ~= self.ToggleKey then return end

        if self.Visible then self:Hide() else self:Show() end
    end))
end

function UI:_updateVisibility()
    self.Instances._Main.Visible = self.Visible
end

function UI:Show()
    self.Visible = true
    self:_updateVisibility()
end

function UI:Hide()
    self.Visible = false
    self:_updateVisibility()
end

function UI:Destroy()
    self.ClickHandler.Connections:DisconnectAll()
    self.Connections:DisconnectAll()
    self.ScreenGui:Destroy() 
end

function UI:AddTab(Name, Icon)
    local NewTab = Tab.new(self, Name, Icon)
    table.insert(self.Tabs, NewTab)
    return NewTab
end

function UI:_updateNavigationSize()
    local NewSize = 0

    for _, Tab in pairs(self.Tabs) do
        NewSize += Tab.Instances._NavButtonNormal.AbsoluteSize.Y
    end

    self.Instances._Navigation.CanvasSize = UDim2.new(0, 0, 0, NewSize)
end

function UI:_setupDragging()
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil

    local DragTI = TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local function Update(Input)
        local Delta = Input.Position - DragStart
        local NewPos = UDim2.new(StartPos.X.Scale, math.clamp(StartPos.X.Offset + Delta.X, 0, Camera.ViewportSize.X - self.Instances._Main.Size.X.Offset), StartPos.Y.Scale, math.clamp(StartPos.Y.Offset + Delta.Y, 0, Camera.ViewportSize.Y - self.Instances._Main.Size.Y.Offset - 30))
        TweenService:Create(self.Instances._Main, DragTI, { Position = NewPos }):Play()
    end

    self.Connections:Add(self.Instances._TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        Dragging = true
        DragStart = Input.Position
        StartPos = self.Instances._Main.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end))

    self.Connections:Add(self.Instances._Title.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        Dragging = true
        DragStart = Input.Position
        StartPos = self.Instances._Main.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end))

    self.Connections:Add(self.Instances._TopBar.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        DragInput = Input
    end))

    self.Connections:Add(self.Instances._Title.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        DragInput = Input
    end))

    self.Connections:Add(UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end))
end

function UI:_createInstances()
    self.Instances = {
        ["_Main"] = Instance.new("Frame");
        ["_DropShadowHolder"] = Instance.new("Frame");
        ["_DropShadow"] = Instance.new("ImageLabel");
        ["_UICorner"] = Instance.new("UICorner");
        ["_UIStroke"] = Instance.new("UIStroke");
        ["_Left"] = Instance.new("Frame");
        ["_Logo"] = Instance.new("Frame");
        ["_Title"] = Instance.new("TextLabel");
        ["_Line"] = Instance.new("Frame");
        ["_Line1"] = Instance.new("Frame");
        ["_Profile"] = Instance.new("Frame");
        ["_Line2"] = Instance.new("Frame");
        ["_ImageLabel"] = Instance.new("ImageLabel");
        ["_UICorner1"] = Instance.new("UICorner");
        ["_UIStroke1"] = Instance.new("UIStroke");
        ["_Username"] = Instance.new("TextLabel");
        ["_UserId"] = Instance.new("TextLabel");
        ["_Navigation"] = Instance.new("ScrollingFrame");
        ["_UIPadding"] = Instance.new("UIPadding");
        ["_UIListLayout"] = Instance.new("UIListLayout");
        ["_Right"] = Instance.new("Frame");
        ["_UICorner2"] = Instance.new("UICorner");
        ["_TabHolder"] = Instance.new("Frame");
        ["_UICorner3"] = Instance.new("UICorner");
        ["_Extend"] = Instance.new("Frame");
        ["_TopBar"] = Instance.new("Frame");
        ["_Extend1"] = Instance.new("Frame");
        ["_Line3"] = Instance.new("Frame");
        ["_PlaceName"] = Instance.new("TextLabel");
        ["_Minimize"] = Instance.new("Frame");
        ["_Icon"] = Instance.new("ImageLabel");
        ["_UICorner4"] = Instance.new("UICorner");
    }

    self.Instances["_Main"].BackgroundColor3 = Color3.fromRGB(40.00000141561031, 40.00000141561031, 40.00000141561031)
    self.Instances["_Main"].Position = UDim2.fromOffset(Camera.ViewportSize.X / 2 - 300, Camera.ViewportSize.Y / 2 - 200)
    self.Instances["_Main"].Size = UDim2.new(0, 600, 0, 400)
    self.Instances["_Main"].Name = "Main"
    self.Instances["_Main"].Parent = self.ScreenGui

    self.Instances["_DropShadowHolder"].BackgroundTransparency = 1
    self.Instances["_DropShadowHolder"].BorderSizePixel = 0
    self.Instances["_DropShadowHolder"].Size = UDim2.new(1, 0, 1, 0)
    self.Instances["_DropShadowHolder"].ZIndex = 0
    self.Instances["_DropShadowHolder"].Name = "DropShadowHolder"
    self.Instances["_DropShadowHolder"].Parent = self.Instances["_Main"]

    self.Instances["_DropShadow"].Image = "rbxassetid://6014261993"
    self.Instances["_DropShadow"].ImageColor3 = Color3.fromRGB(0, 0, 0)
    self.Instances["_DropShadow"].ImageTransparency = 0.5
    self.Instances["_DropShadow"].ScaleType = Enum.ScaleType.Slice
    self.Instances["_DropShadow"].SliceCenter = Rect.new(49, 49, 450, 450)
    self.Instances["_DropShadow"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_DropShadow"].BackgroundTransparency = 1
    self.Instances["_DropShadow"].BorderSizePixel = 0
    self.Instances["_DropShadow"].Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Instances["_DropShadow"].Size = UDim2.new(1, 47, 1, 47)
    self.Instances["_DropShadow"].ZIndex = 0
    self.Instances["_DropShadow"].Name = "DropShadow"
    self.Instances["_DropShadow"].Parent = self.Instances["_DropShadowHolder"]

    self.Instances["_UICorner"].CornerRadius = UDim.new(0, 4)
    self.Instances["_UICorner"].Parent = self.Instances["_Main"]

    self.Instances["_UIStroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Instances["_UIStroke"].Color = Color3.fromRGB(100.00000923871994, 100.00000923871994, 100.00000923871994)
    self.Instances["_UIStroke"].Parent = self.Instances["_Main"]

    self.Instances["_Left"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Left"].BackgroundTransparency = 1
    self.Instances["_Left"].Size = UDim2.new(0, 140, 1, 0)
    self.Instances["_Left"].Name = "Left"
    self.Instances["_Left"].Parent = self.Instances["_Main"]

    self.Instances["_Logo"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Logo"].BackgroundTransparency = 1
    self.Instances["_Logo"].Size = UDim2.new(1, 0, 0, 40)
    self.Instances["_Logo"].Name = "Logo"
    self.Instances["_Logo"].Parent = self.Instances["_Left"]

    self.Instances["_Title"].Font = Enum.Font.Ubuntu
    self.Instances["_Title"].RichText = true
    self.Instances["_Title"].Text = [[<b>game<font color="rgb(255, 100, 100)">fraud</font></b>]]
    self.Instances["_Title"].TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Title"].TextSize = 18
    self.Instances["_Title"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_Title"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Title"].BackgroundTransparency = 1
    self.Instances["_Title"].Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Instances["_Title"].Size = UDim2.new(1, 0, 0, 18)
    self.Instances["_Title"].Name = "Title"
    self.Instances["_Title"].Parent = self.Instances["_Logo"]

    self.Instances["_Line"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_Line"].BackgroundColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Line"].BorderSizePixel = 0
    self.Instances["_Line"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_Line"].Size = UDim2.new(1, 0, 0, 1)
    self.Instances["_Line"].Name = "Line"
    self.Instances["_Line"].Parent = self.Instances["_Logo"]

    self.Instances["_Line1"].AnchorPoint = Vector2.new(1, 0)
    self.Instances["_Line1"].BackgroundColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Line1"].BorderSizePixel = 0
    self.Instances["_Line1"].Position = UDim2.new(1, 0, 0, 0)
    self.Instances["_Line1"].Size = UDim2.new(0, 1, 1, 0)
    self.Instances["_Line1"].Name = "Line"
    self.Instances["_Line1"].Parent = self.Instances["_Left"]

    self.Instances["_Profile"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_Profile"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Profile"].BackgroundTransparency = 1
    self.Instances["_Profile"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_Profile"].Size = UDim2.new(1, 0, 0, 40)
    self.Instances["_Profile"].Name = "Profile"
    self.Instances["_Profile"].Parent = self.Instances["_Left"]

    self.Instances["_Line2"].BackgroundColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Line2"].BorderSizePixel = 0
    self.Instances["_Line2"].Size = UDim2.new(1, 0, 0, 1)
    self.Instances["_Line2"].Name = "Line"
    self.Instances["_Line2"].Parent = self.Instances["_Profile"]

    self.Instances["_ImageLabel"].Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    self.Instances["_ImageLabel"].AnchorPoint = Vector2.new(0, 0.5)
    self.Instances["_ImageLabel"].BackgroundColor3 = Color3.fromRGB(255, 100.00000163912773, 100.00000163912773)
    self.Instances["_ImageLabel"].Position = UDim2.new(0, 8, 0.5, 0)
    self.Instances["_ImageLabel"].Size = UDim2.new(0, 24, 0, 24)
    self.Instances["_ImageLabel"].Parent = self.Instances["_Profile"]

    self.Instances["_UICorner1"].CornerRadius = UDim.new(1, 0)
    self.Instances["_UICorner1"].Parent = self.Instances["_ImageLabel"]

    self.Instances["_UIStroke1"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Instances["_UIStroke1"].Color = Color3.fromRGB(255, 100.00000163912773, 100.00000163912773)
    self.Instances["_UIStroke1"].Parent = self.Instances["_ImageLabel"]

    self.Instances["_Username"].Font = Enum.Font.Ubuntu
    self.Instances["_Username"].Text = "@ " .. self.Username
    self.Instances["_Username"].TextColor3 = Color3.fromRGB(255, 100.00000163912773, 100.00000163912773)
    self.Instances["_Username"].TextSize = 10
    self.Instances["_Username"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_Username"].AnchorPoint = Vector2.new(0, 0.5)
    self.Instances["_Username"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Username"].BackgroundTransparency = 1
    self.Instances["_Username"].Position = UDim2.new(0, 40, 0.5, -7)
    self.Instances["_Username"].Size = UDim2.new(1, -44, 0, 10)
    self.Instances["_Username"].Name = "Username"
    self.Instances["_Username"].Parent = self.Instances["_Profile"]

    self.Instances["_UserId"].Font = Enum.Font.Ubuntu
    self.Instances["_UserId"].Text = "# " .. self.UserId
    self.Instances["_UserId"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_UserId"].TextSize = 10
    self.Instances["_UserId"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_UserId"].AnchorPoint = Vector2.new(0, 0.5)
    self.Instances["_UserId"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_UserId"].BackgroundTransparency = 1
    self.Instances["_UserId"].Position = UDim2.new(0, 40, 0.5, 7)
    self.Instances["_UserId"].Size = UDim2.new(1, -44, 0, 10)
    self.Instances["_UserId"].Name = "UserId"
    self.Instances["_UserId"].Parent = self.Instances["_Profile"]

    self.Instances["_Navigation"].ScrollBarImageColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Navigation"].ScrollBarThickness = 0
    self.Instances["_Navigation"].Active = true
    self.Instances["_Navigation"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Navigation"].BackgroundTransparency = 1
    self.Instances["_Navigation"].BorderSizePixel = 0
    self.Instances["_Navigation"].Position = UDim2.new(0, 0, 0, 41)
    self.Instances["_Navigation"].Size = UDim2.new(1, -1, 1, -81)
    self.Instances["_Navigation"].Name = "Navigation"
    self.Instances["_Navigation"].Parent = self.Instances["_Left"]

    self.Instances["_UIPadding"].PaddingBottom = UDim.new(0, 8)
    self.Instances["_UIPadding"].PaddingTop = UDim.new(0, 8)
    self.Instances["_UIPadding"].Parent = self.Instances["_Navigation"]

    self.Instances["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
    self.Instances["_UIListLayout"].Parent = self.Instances["_Navigation"]

    self.Instances["_Right"].AnchorPoint = Vector2.new(1, 0)
    self.Instances["_Right"].BackgroundColor3 = Color3.fromRGB(45.00000111758709, 45.00000111758709, 45.00000111758709)
    self.Instances["_Right"].BackgroundTransparency = 1
    self.Instances["_Right"].BorderSizePixel = 0
    self.Instances["_Right"].Position = UDim2.new(1, 0, 0, 0)
    self.Instances["_Right"].Size = UDim2.new(1, -140, 1, 0)
    self.Instances["_Right"].Name = "Right"
    self.Instances["_Right"].Parent = self.Instances["_Main"]

    self.Instances["_UICorner2"].CornerRadius = UDim.new(0, 4)
    self.Instances["_UICorner2"].Parent = self.Instances["_Right"]

    self.Instances["_TabHolder"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_TabHolder"].BackgroundColor3 = Color3.fromRGB(45.00000111758709, 45.00000111758709, 45.00000111758709)
    self.Instances["_TabHolder"].BorderSizePixel = 0
    self.Instances["_TabHolder"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_TabHolder"].Size = UDim2.new(1, 0, 1, -40)
    self.Instances["_TabHolder"].Name = "TabHolder"
    self.Instances["_TabHolder"].Parent = self.Instances["_Right"]

    self.Instances["_UICorner3"].CornerRadius = UDim.new(0, 4)
    self.Instances["_UICorner3"].Parent = self.Instances["_TabHolder"]

    self.Instances["_Extend"].BackgroundColor3 = Color3.fromRGB(45.00000111758709, 45.00000111758709, 45.00000111758709)
    self.Instances["_Extend"].BorderSizePixel = 0
    self.Instances["_Extend"].Size = UDim2.new(1, 0, 0.5, 0)
    self.Instances["_Extend"].Name = "Extend"
    self.Instances["_Extend"].Parent = self.Instances["_TabHolder"]

    self.Instances["_TopBar"].BackgroundColor3 = Color3.fromRGB(40.00000141561031, 40.00000141561031, 40.00000141561031)
    self.Instances["_TopBar"].BorderSizePixel = 0
    self.Instances["_TopBar"].Position = UDim2.new(0, -10, 0, 0)
    self.Instances["_TopBar"].Size = UDim2.new(1, 10, 0, 40)
    self.Instances["_TopBar"].Name = "TopBar"
    self.Instances["_TopBar"].Parent = self.Instances["_Right"]

    self.Instances["_Extend1"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_Extend1"].BackgroundColor3 = Color3.fromRGB(40.00000141561031, 40.00000141561031, 40.00000141561031)
    self.Instances["_Extend1"].BorderSizePixel = 0
    self.Instances["_Extend1"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_Extend1"].Size = UDim2.new(1, 0, 0.5, 0)
    self.Instances["_Extend1"].Name = "Extend"
    self.Instances["_Extend1"].Parent = self.Instances["_TopBar"]

    self.Instances["_Line3"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_Line3"].BackgroundColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Line3"].BorderSizePixel = 0
    self.Instances["_Line3"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_Line3"].Size = UDim2.new(1, 0, 0, 1)
    self.Instances["_Line3"].ZIndex = 2
    self.Instances["_Line3"].Name = "Line"
    self.Instances["_Line3"].Parent = self.Instances["_TopBar"]

    self.Instances["_PlaceName"].Font = Enum.Font.Ubuntu
    self.Instances["_PlaceName"].Text = MarketplaceService:GetProductInfo(game.PlaceId).Name
    self.Instances["_PlaceName"].TextColor3 = Color3.fromRGB(200.00000327825546, 200.00000327825546, 200.00000327825546)
    self.Instances["_PlaceName"].TextSize = 14
    self.Instances["_PlaceName"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_PlaceName"].AnchorPoint = Vector2.new(0, 0.5)
    self.Instances["_PlaceName"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_PlaceName"].BackgroundTransparency = 1
    self.Instances["_PlaceName"].BorderSizePixel = 0
    self.Instances["_PlaceName"].Position = UDim2.new(0, 10, 0.5, 0)
    self.Instances["_PlaceName"].Size = UDim2.new(1, -45, 1, 0)
    self.Instances["_PlaceName"].Name = "PlaceName"
    self.Instances["_PlaceName"].Parent = self.Instances["_TopBar"]

    self.Instances["_Minimize"].AnchorPoint = Vector2.new(1, 0.5)
    self.Instances["_Minimize"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Minimize"].BackgroundTransparency = 1
    self.Instances["_Minimize"].Position = UDim2.new(1, -8, 0.5, 0)
    self.Instances["_Minimize"].Size = UDim2.new(0, 24, 0, 24)
    self.Instances["_Minimize"].Name = "Minimize"
    self.Instances["_Minimize"].Parent = self.Instances["_TopBar"]

    self.Instances["_Icon"].Image = "rbxassetid://13084930860"
    self.Instances["_Icon"].ImageColor3 = Color3.fromRGB(200.00000327825546, 200.00000327825546, 200.00000327825546)
    self.Instances["_Icon"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Icon"].BackgroundTransparency = 1
    self.Instances["_Icon"].Size = UDim2.new(1, 0, 1, 0)
    self.Instances["_Icon"].Name = "Icon"
    self.Instances["_Icon"].Parent = self.Instances["_Minimize"]

    self.Instances["_UICorner4"].Parent = self.Instances["_TopBar"]

    self.ClickHandler = ClickHandler.new(self.Instances._Minimize, {
        Neutral = function()
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(200.00000327825546, 200.00000327825546, 200.00000327825546)})
        end,
        Hover = function()
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(240.00000327825546, 240.00000327825546, 240.00000327825546)})
        end,
        Click = function()
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(255.00000327825546, 100.00000327825546, 100.00000327825546)})
        end
    }, function()
        self:Hide()
    end)
end

function Tab.new(UI, Name, Icon)
    local tab = setmetatable({}, Tab)

    UI = UI or nil
    Name = Name or "New Tab"
    Icon = Icon or "rbxassetid://13084639373"

    if not UI then return error("Tabs can only be added to a UI.") end
    if UI.ClassName ~= "UI" then return error("Tabs can only be added to a UI.") end

    tab.UI = UI
    tab.Sections = {}
    tab.Name = Name
    tab.Icon = Icon
    tab.Active = false
    tab.ClickHandler = nil
    tab.Id = GenId()

    tab:_createInstances()

    return tab
end

function Tab:Destroy()
    self.Instances._Tab:Destroy()
    self.UI.Tabs[self.Id] = nil
    self.UI:_updateNavigationSize()
end

function Tab:Activate()
    self.Active = true

    for _, Tab in pairs(self.UI.Tabs) do
        if self == Tab then continue end
        if not Tab.Active then continue end
        Tab:Deactivate() 
    end

    Tween(self.Instances._NavButtonNormal, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
    Tween(self.Instances._Text, { TextColor3 = Color3.fromRGB(255, 100, 100) })
    Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(255, 100, 100) })
    self.Instances._Tab.Visible = true
end

function Tab:Deactivate()
    self.Active = false
    Tween(self.Instances._NavButtonNormal, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
    Tween(self.Instances._Text, { TextColor3 = Color3.fromRGB(200, 200, 200) })
    Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(200, 200, 200) })
    self.Instances._Tab.Visible = false
end

function Tab:_createInstances()
    self.Instances = {
        ["_Tab"] = Instance.new("ScrollingFrame");
        ["_Left"] = Instance.new("Frame");
        ["_UIListLayout"] = Instance.new("UIListLayout");
        ["_Right"] = Instance.new("Frame");
        ["_UIListLayout1"] = Instance.new("UIListLayout");
        ["_UIPadding"] = Instance.new("UIPadding");
        ["_NavButtonNormal"] = Instance.new("Frame");
        ["_Icon"] = Instance.new("ImageLabel");
        ["_Text"] = Instance.new("TextLabel");
    }

    self.Instances["_Tab"].ScrollBarImageColor3 = Color3.fromRGB(100.00000163912773, 100.00000163912773, 100.00000163912773)
    self.Instances["_Tab"].ScrollBarThickness = 0
    self.Instances["_Tab"].Active = true
    self.Instances["_Tab"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_Tab"].BackgroundColor3 = Color3.fromRGB(45.00000111758709, 45.00000111758709, 45.00000111758709)
    self.Instances["_Tab"].BorderSizePixel = 0
    self.Instances["_Tab"].Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Instances["_Tab"].Size = UDim2.new(1, -14, 1, -14)
    self.Instances["_Tab"].Name = "Tab"
    self.Instances["_Tab"].Visible = false
    self.Instances["_Tab"].Parent = self.UI.Instances._TabHolder

    self.Instances["_Left"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Left"].BackgroundTransparency = 1
    self.Instances["_Left"].Size = UDim2.new(0.5, -4, 1, 0)
    self.Instances["_Left"].Name = "Left"
    self.Instances["_Left"].Parent = self.Instances["_Tab"]

    self.Instances["_UIListLayout"].Padding = UDim.new(0, 6)
    self.Instances["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
    self.Instances["_UIListLayout"].Parent = self.Instances["_Left"]

    self.Instances["_Right"].AnchorPoint = Vector2.new(1, 0)
    self.Instances["_Right"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Right"].BackgroundTransparency = 1
    self.Instances["_Right"].Position = UDim2.new(1, 0, 0, 0)
    self.Instances["_Right"].Size = UDim2.new(0.5, -4, 1, 0)
    self.Instances["_Right"].Name = "Right"
    self.Instances["_Right"].Parent = self.Instances["_Tab"]

    self.Instances["_UIListLayout1"].Padding = UDim.new(0, 6)
    self.Instances["_UIListLayout1"].SortOrder = Enum.SortOrder.LayoutOrder
    self.Instances["_UIListLayout1"].Parent = self.Instances["_Right"]

    self.Instances["_UIPadding"].PaddingBottom = UDim.new(0, 2)
    self.Instances["_UIPadding"].PaddingLeft = UDim.new(0, 2)
    self.Instances["_UIPadding"].PaddingRight = UDim.new(0, 2)
    self.Instances["_UIPadding"].PaddingTop = UDim.new(0, 2)
    self.Instances["_UIPadding"].Parent = self.Instances["_Tab"]

    self.Instances["_NavButtonNormal"].BackgroundColor3 = Color3.fromRGB(40.00000141561031, 40.00000141561031, 40.00000141561031)
    self.Instances["_NavButtonNormal"].BorderColor3 = Color3.fromRGB(65.0000037252903, 65.0000037252903, 65.0000037252903)
    self.Instances["_NavButtonNormal"].Size = UDim2.new(1, 0, 0, 30)
    self.Instances["_NavButtonNormal"].Name = "NavButtonNormal"
    self.Instances["_NavButtonNormal"].Parent = self.UI.Instances._Navigation

    self.Instances["_Icon"].Image = self.Icon
    self.Instances["_Icon"].ImageColor3 = Color3.fromRGB(200.00000327825546, 200.00000327825546, 200.00000327825546)
    self.Instances["_Icon"].AnchorPoint = Vector2.new(0, 0.5)
    self.Instances["_Icon"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Icon"].BackgroundTransparency = 1
    self.Instances["_Icon"].Position = UDim2.new(0, 6, 0.5, 0)
    self.Instances["_Icon"].Size = UDim2.new(0, 21, 0, 21)
    self.Instances["_Icon"].Name = "Icon"
    self.Instances["_Icon"].Parent = self.Instances["_NavButtonNormal"]

    self.Instances["_Text"].Font = Enum.Font.Ubuntu
    self.Instances["_Text"].Text = self.Name
    self.Instances["_Text"].TextColor3 = Color3.fromRGB(200.00000327825546, 200.00000327825546, 200.00000327825546)
    self.Instances["_Text"].TextSize = 12
    self.Instances["_Text"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_Text"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Text"].BackgroundTransparency = 1
    self.Instances["_Text"].Position = UDim2.new(0, 34, 0, 0)
    self.Instances["_Text"].Size = UDim2.new(1, -34, 1, 0)
    self.Instances["_Text"].Name = "Text"
    self.Instances["_Text"].Parent = self.Instances["_NavButtonNormal"]

    self.ClickHandler = ClickHandler.new(self.Instances._NavButtonNormal, {
        Neutral = function()
            if self.Active then return end

            Tween(self.Instances._NavButtonNormal, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
            Tween(self.Instances._Text, { TextColor3 = Color3.fromRGB(200, 200, 200) })
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(200, 200, 200) })
        end,
        Hover = function()
            if self.Active then return end

            Tween(self.Instances._NavButtonNormal, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
            Tween(self.Instances._Text, { TextColor3 = Color3.fromRGB(200, 200, 200) })
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(200, 200, 200) })
        end,
        Click = function()
            if self.Active then return end

            Tween(self.Instances._NavButtonNormal, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
            Tween(self.Instances._Text, { TextColor3 = Color3.fromRGB(240, 240, 240) })
            Tween(self.Instances._Icon, { ImageColor3 = Color3.fromRGB(240, 240, 240) })
        end
    }, function()
        self:Activate()
    end)

    self:_updateSize()
end

function Tab:_updateSize()
    local HeightLeft = -3
    local HeightRight = -3

    for _, Section in pairs(self.Sections) do
        if Section.Instances._Section.Parent == self.Instances._Left then
            HeightLeft += Section.Instances._Section.AbsoluteSize.Y + 6
        elseif Section.Instances._Section.Parent == self.Instances._Right then
            HeightRight += Section.Instances._Section.AbsoluteSize.Y + 6
        end
    end

    self.Instances._Tab.CanvasSize = UDim2.new(0, 0, 0, HeightRight > HeightLeft and HeightRight or HeightLeft)
end

function Tab:AddSection(Name)
    local NewSection = Section.new(self, Name)
    self.Sections[NewSection.Id] = NewSection
    self:_updateSize()
    return NewSection
end

function Tab:_rightOrLeft()
    local HeightLeft = 0
    local HeightRight = 0

    for _, Section in pairs(self.Sections) do
        if Section.Instances._Section.Parent == self.Instances._Left then
            HeightLeft += Section.Instances._Section.AbsoluteSize.Y
        elseif Section.Instances._Section.Parent == self.Instances._Right then
            HeightRight += Section.Instances._Section.AbsoluteSize.Y
        end
    end

    return HeightLeft > HeightRight and self.Instances._Right or self.Instances._Left
end

function Section.new(Tab, Name)
    local section = setmetatable({}, Section)

    Tab = Tab or nil
    Name = Name or "Section"

    if not Tab then return error("A section can only be added to a Tab.") end
    if Tab.ClassName ~= "Tab" then return error("A section can only be added to a Tab.") end

    section.Tab = Tab
    section.Name = Name
    section.Components = {}
    section.Id = GenId()

    section:_createInstances()

    return section
end

function Section:AddSlider(Text, Min, Max, Increment, Default, Callback)
    local NewSlider = Slider.new(self, Text, Min, Max, Increment, Default, Callback)
    self.Components[NewSlider.Id] = NewSlider
    self:_updateSize()
    return NewSlider
end

function Section:Destroy()
    self.Instances._Section:Destroy()
    self.Tab.Sections[self.Id] = nil
    self.Tab:_updateSize()
end

function Section:SetName(NewName)
    self.Name = NewName
    Tween(self.Instances._Name, {TextTransparency = 1}, function()
        self.Instances._Name.Text = self.Name
        Tween(self.Instances._Name, {TextTransparency = 0})
    end)
end

function Section:AddToggle(Text, Callback)
    local NewToggle = Toggle.new(self, Text, Callback)
    self.Components[NewToggle.Id] = NewToggle
    self:_updateSize()
    return NewToggle
end

function Section:AddButton(Text, Callback)
    local NewButton = Button.new(self, Text, Callback)
    self.Components[NewButton.Id] = NewButton
    self:_updateSize()
    return NewButton
end

function Section:_updateSize()
    local NewHeight = -4

    for _, Component in pairs(self.Components) do
        NewHeight += Component:_getAbsoluteHeight() + 4
    end

    Tween(self.Instances._Section, {Size = UDim2.new(1, 0, 0, 26 + NewHeight)}, function()
        self.Tab:_updateSize()
    end)
end

function Section:_createInstances()
    self.Instances = {
        ["_Section"] = Instance.new("Frame");
        ["_UICorner"] = Instance.new("UICorner");
        ["_UIStroke"] = Instance.new("UIStroke");
        ["_TopBar"] = Instance.new("Frame");
        ["_UICorner1"] = Instance.new("UICorner");
        ["_Extend"] = Instance.new("Frame");
        ["_Name"] = Instance.new("TextLabel");
        ["_Content"] = Instance.new("Frame");
        ["_UIPadding"] = Instance.new("UIPadding");
        ["_UIListLayout"] = Instance.new("UIListLayout");
    }

    self.Instances["_Section"].BackgroundColor3 = Color3.fromRGB(40.00000141561031, 40.00000141561031, 40.00000141561031)
    self.Instances["_Section"].BorderSizePixel = 0
    self.Instances["_Section"].Size = UDim2.new(1, 0, 0, 26)
    self.Instances["_Section"].Name = "Section"
    self.Instances["_Section"].Parent = self.Tab:_rightOrLeft()

    self.Instances["_UICorner"].CornerRadius = UDim.new(0, 2)
    self.Instances["_UICorner"].Parent = self.Instances["_Section"]

    self.Instances["_UIStroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Instances["_UIStroke"].Color = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
    self.Instances["_UIStroke"].Parent = self.Instances["_Section"]

    self.Instances["_TopBar"].BackgroundColor3 = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
    self.Instances["_TopBar"].BorderSizePixel = 0
    self.Instances["_TopBar"].Size = UDim2.new(1, 0, 0, 18)
    self.Instances["_TopBar"].Name = "TopBar"
    self.Instances["_TopBar"].Parent = self.Instances["_Section"]

    self.Instances["_UICorner1"].CornerRadius = UDim.new(0, 2)
    self.Instances["_UICorner1"].Parent = self.Instances["_TopBar"]

    self.Instances["_Extend"].AnchorPoint = Vector2.new(0, 1)
    self.Instances["_Extend"].BackgroundColor3 = Color3.fromRGB(80.00000283122063, 80.00000283122063, 80.00000283122063)
    self.Instances["_Extend"].BorderSizePixel = 0
    self.Instances["_Extend"].Position = UDim2.new(0, 0, 1, 0)
    self.Instances["_Extend"].Size = UDim2.new(1, 0, 0.5, 0)
    self.Instances["_Extend"].Name = "Extend"
    self.Instances["_Extend"].Parent = self.Instances["_TopBar"]

    self.Instances["_Name"].Font = Enum.Font.Ubuntu
    self.Instances["_Name"].Text = self.Name
    self.Instances["_Name"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Name"].TextSize = 12
    self.Instances["_Name"].TextXAlignment = Enum.TextXAlignment.Left
    self.Instances["_Name"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Name"].BackgroundTransparency = 1
    self.Instances["_Name"].Position = UDim2.new(0, 6, 0, 0)
    self.Instances["_Name"].Size = UDim2.new(1, -6, 1, 0)
    self.Instances["_Name"].Name = "Name"
    self.Instances["_Name"].ClipsDescendants = true
    self.Instances["_Name"].Parent = self.Instances["_TopBar"]

    self.Instances["_Content"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Content"].BackgroundTransparency = 1
    self.Instances["_Content"].Position = UDim2.new(0, 0, 0, 18)
    self.Instances["_Content"].Size = UDim2.new(1, 0, 1, -18)
    self.Instances["_Content"].Name = "Content"
    self.Instances["_Content"].Parent = self.Instances["_Section"]

    self.Instances["_UIPadding"].PaddingBottom = UDim.new(0, 4)
    self.Instances["_UIPadding"].PaddingLeft = UDim.new(0, 4)
    self.Instances["_UIPadding"].PaddingRight = UDim.new(0, 4)
    self.Instances["_UIPadding"].PaddingTop = UDim.new(0, 4)
    self.Instances["_UIPadding"].Parent = self.Instances["_Content"]

    self.Instances["_UIListLayout"].Padding = UDim.new(0, 4)
    self.Instances["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
    self.Instances["_UIListLayout"].Parent = self.Instances["_Content"]

    self:_updateSize()
end

function Connections.new()
    local connections = setmetatable({}, Connections)

    connections.Connections = {}

    return connections
end

function Connections:Add(RBXScriptConnection)
    table.insert(self.Connections, RBXScriptConnection)
end

function Connections:DisconnectAll()
    for _, Conn in pairs(self.Connections) do
        Conn:Disconnect()
    end
end

function ClickHandler.new(Frame, States, Callback)
    local clickHandler = setmetatable({}, ClickHandler)

    Frame = Frame or nil
    States = States or {
        Neutral = function() end,
        Hover = function() end,
        Click = function() end
    }
    Callback = Callback or function() end

    if not Frame then return error("A ClickHandler must be assigned a Frame.") end
    if Frame.ClassName ~= "Frame" then return error("A ClickHandler must be assigned a Frame.") end

    clickHandler.Frame = Frame
    clickHandler.States = States
    clickHandler.Callback = Callback
    clickHandler.Connections = Connections.new()

    clickHandler:_setupHandler()

    return clickHandler
end

function ClickHandler:_setupHandler()
    local MouseHover = false
    local MouseDown = false

    self.Frame.MouseEnter:Connect(function()
        MouseHover = true

        if not MouseDown then
            self.States.Hover()
        end
    end)

    self.Frame.MouseLeave:Connect(function()
        MouseHover = false

        if not MouseDown then
            self.States.Neutral()
        end
    end)

    self.Connections:Add(UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        if MouseHover then
            MouseDown = true
            self.States.Click()
        end
    end))

    self.Connections:Add(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        if MouseDown and MouseHover then
            self.Callback()
        end

        MouseDown = false

        if MouseHover then
            self.States.Hover()
        else
            self.States.Neutral()
        end
    end))
end

function Button.new(Section, Text, Callback)
    local button = setmetatable({}, Button)

    Section = Section or nil
    Text = Text or "Button"
    Callback = Callback or function() print(button.Text .. " was clicked!") end

    if not Section then return error("A button can only be added to a section.") end
    if Section.ClassName ~= "Section" then return error("A button can only be added to a section.") end

    button.Text = Text
    button.Section = Section
    button.Callback = Callback
    button.Id = GenId()

    button:_createInstances()

    return button
end

function Button:_getAbsoluteHeight()
    return self.Instances._ButtonNormal.AbsoluteSize.Y
end

function Button:SetText(NewText)
    self.Text = NewText
    self:_updateSize()
end

function Button:SetCallback(NewCallback)
    self.Callback = NewCallback
    self.ClickHandler.Callback = self.Callback
end

function Button:Fire()
    self.Callback()
end

function Button:_updateSize()
    Tween(self.Instances._Text, {TextTransparency = 1}, function()
        local OldSize = self.Instances._ButtonNormal.Size
        self.Instances._ButtonNormal.Size = UDim2.new(1, 0, 100, 20)
        self.Instances._Text.Text = self.Text
        local NewYSize = self.Instances._Text.TextBounds.Y
        self.Instances._ButtonNormal.Size = OldSize

        Tween(self.Instances._ButtonNormal, {Size = UDim2.new(1, 0, 0, NewYSize + 8)}, function()
            Tween(self.Instances._Text, {TextTransparency = 0}, function()
                self.Section:_updateSize()
            end)
        end)
    end)
end

function Button:Destroy()
    self.ClickHandler.Connections:DisconnectAll()
    self.Instances._ButtonNormal:Destroy()
    self.Section.Components[self.Id] = nil
    self.Section:_updateSize()
end

function Button:_createInstances()
    self.Instances = {
        ["_ButtonNormal"] = Instance.new("Frame");
        ["_UICorner"] = Instance.new("UICorner");
        ["_Text"] = Instance.new("TextLabel");
    }

    self.Instances["_ButtonNormal"].BackgroundColor3 = Color3.fromRGB(60.00000022351742, 60.00000022351742, 60.00000022351742)
    self.Instances["_ButtonNormal"].Size = UDim2.new(1, 0, 0, 20)
    self.Instances["_ButtonNormal"].Name = "ButtonNormal"
    self.Instances["_ButtonNormal"].Parent = self.Section.Instances._Content

    self.Instances["_UICorner"].CornerRadius = UDim.new(0, 4)
    self.Instances["_UICorner"].Parent = self.Instances["_ButtonNormal"]

    self.Instances["_Text"].Font = Enum.Font.Ubuntu
    self.Instances["_Text"].Text = self.Text
    self.Instances["_Text"].TextColor3 = Color3.fromRGB(240.00000089406967, 240.00000089406967, 240.00000089406967)
    self.Instances["_Text"].TextSize = 12
    self.Instances["_Text"].AnchorPoint = Vector2.new(0.5, 0.5)
    self.Instances["_Text"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Instances["_Text"].BackgroundTransparency = 1
    self.Instances["_Text"].Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Instances["_Text"].Size = UDim2.new(1, -8, 1, 0)
    self.Instances["_Text"].Name = "Text"
    self.Instances["_Text"].TextWrapped = true
    self.Instances["_Text"].Parent = self.Instances["_ButtonNormal"]

    self.ClickHandler = ClickHandler.new(self.Instances._ButtonNormal, {
        Neutral = function()
            Tween(self.Instances._ButtonNormal, { BackgroundColor3 = Color3.fromRGB(60.00000022351742, 60.00000022351742, 60.00000022351742) })
        end,
        Hover = function()
            Tween(self.Instances._ButtonNormal, { BackgroundColor3 = Color3.fromRGB(70.00000022351742, 70.00000022351742, 70.00000022351742) })
        end,
        Click = function()
            Tween(self.Instances._ButtonNormal, { BackgroundColor3 = Color3.fromRGB(50.00000022351742, 50.00000022351742, 50.00000022351742) })
        end
    }, self.Callback)

    self:_updateSize()
end

return Library
