local function getService(name)
    local service = game:GetService(name)
    return if cloneref then cloneref(service) else service
end

-- Services
local UserInputService = getService("UserInputService")
local HttpService = getService("HttpService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local RunService = getService("RunService")
local GuiService = getService("GuiService")

-- Creating folders and fonts for ui
local MainFolder = "Banannih Hub"
--local FontsFolder = MainFolder .. "/Fonts"

local hasFilesystem = type(makefolder) == "function" and type(isfolder) == "function" and type(writefile) == "function"
local hasAssetCloner = type(getcustomasset) == "function" or type(get_custom_asset) == "function"
local getAsset = getcustomasset or get_custom_asset

if not hasFilesystem or not hasAssetCloner then
    return warn("Your executor is trash and does not support getcustomasset!")
end

pcall(makefolder, MainFolder)
pcall(makefolder, FontsFolder)

local HubId = 90215166517629
--local BanannihHubUi = game:GetObjects("rbxassetid://"..HubId)[1]
local success, objects = pcall(function()
    return game:GetObjects("rbxassetid://" .. HubId)
end)

local BanannihHubUi = nil

if success and objects and objects[1] then
    BanannihHubUi = objects[1]
else
    warn("Failed to load hub Ui, that's sad..")
end

if gethui then
	BanannihHubUi.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(BanannihHubUi)
	BanannihHubUi.Parent = CoreGui
elseif CoreGui:FindFirstChild("RobloxGui") then
	BanannihHubUi.Parent = CoreGui:FindFirstChild("RobloxGui")
else
	BanannihHubUi.Parent = CoreGui
end
getgenv().CurrentlyRunningStuff = getgenv().CurrentlyRunningStuff or {}
--getgenv().HubCapturedThreads = getgenv().HubCapturedThreads or {}
if getgenv().BanannihHubUi and getgenv().BanannihHubUi ~= nil then
coroutine.wrap(function(...)
    pcall(function()
        getgenv().BanannihHubUi:Destroy()
        getgenv().BanannihHubUi = nil
        for _, thread in pairs(getgenv().CurrentlyRunningStuff) do
            if typeof(thread) == "thread" then
                pcall(task.cancel, thread)
            end
        end
        table.clear(getgenv().CurrentlyRunningStuff)
        --[[
        for _, oldThread in ipairs(getgenv().HubCapturedThreads) do
            if typeof(oldThread) == "thread" then
                pcall(task.cancel, oldThread)
            end
        end
        table.clear(getgenv().HubCapturedThreads)
        ]]--
        getgenv().BanannihHubUi = BanannihHubUi
    end)
end)()
end

if BanannihHubUi.Enabled == false then BanannihHubUi.Enabled = true end
local Main = BanannihHubUi.Main
local TabList = Main.TabList
local Elements = Main.Elements
local Drag = Main.Drag
--local ElementsList = Elements.TabList
local CloseUIButton = Main.TextButton  -- Temporary
local TabTemplates = TabList.Templates
local ElementsTemplates = Elements.Templates

for _, v in Elements:GetChildren() do
    if v:IsA("CanvasGroup") then
        v:Destroy()
    end
end

for _, v in TabList:GetChildren() do
    if v:IsA("TextButton") then
        if v.Name == "Placeholder" then
        else
            v:Destroy()
        end
    end
end

local HubLibrary = {
    Theme = {
        Default = {}, -- color and do some stuff yeah

    }
}

local SelectedTheme = HubLibrary.Theme.Default
local ToggleUiKey = Enum.KeyCode.RightControl

local function ChangeTheme(Theme)
    if typeof(Theme) == 'string' then
		SelectedTheme = HubLibrary.Theme[Theme]
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

    -- change every element color and style yeah

end
local Exist = true
local CurrentlyRunningStuff = getgenv().CurrentlyRunningStuff

	
--Drag ui stuff yeah
local DRAG_TOGGLE = nil
local DRAG_SPEED = 0.25
local DRAG_START = nil
local START_POS = nil

local function updateInput(input)
	local delta = input.Position - DRAG_START
	local position = UDim2.new(
		START_POS.X.Scale,
		START_POS.X.Offset + delta.X,
		START_POS.Y.Scale,
		START_POS.Y.Offset + delta.Y
	)
	TweenService:Create(Main, TweenInfo.new(DRAG_SPEED, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = position}):Play() -- Variant 1
	--TweenService:Create(mainframe, TweenInfo.new(DRAG_SPEED, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = position}):Play() -- Variant 2
	--TweenService:Create(mainframe, TweenInfo.new(DRAG_SPEED, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = position}):Play() -- Variant 3
end

Drag.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
		DRAG_TOGGLE = true
		DRAG_START = input.Position
		START_POS = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				DRAG_TOGGLE = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if DRAG_TOGGLE then
			updateInput(input)
		end
	end
end)
-- Drag stuff yeah END


function HubLibrary:CreateWindow(Settings)
    if HubLibrary.Theme[Settings.Theme] then 
        SelectedTheme = HubLibrary.Theme[Settings.Theme]
    end

    local success, result = pcall(function()
        return Settings.ToggleUIKeybind.EnumType == Enum.KeyCode
    end)
    
    if success and result then
        ToggleUiKey = result
    end

    -- Window
    local FirstTab = false
    local Window = {}

    function Window:CreateTab(Name, img)
        local Tab = TabTemplates:FindFirstChild("Template"):Clone()
        Tab.Parent = TabList
        Tab.Name = Name
        Tab.Title.Text = Name
        Tab.Visible = true

		local CanvasList = ElementsTemplates:FindFirstChild("ExampleTabList"):Clone()
		CanvasList.Name = Name.."TabList"
		CanvasList.Parent = Elements

		local List = CanvasList.List


        -- Tab
        local Tab = {}

		-- Tab Switched
		Tab.MouseButton1Click:Connect(function()
			pcall(function()
				for _, elem in Elements:GetChildren() do
					task.spawn(function()
						if elem:IsA("CanvasGroup") then
							if elem.Name == CanvasList.Name and elem.Visible == true then
							else
								t:Create(elem, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupColor3 = Color3.fromRGB(0,0,0)}):Play()
								local waittween = t:Create(elem, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 1})
								waittween:Play()
								waittween.Completed:Wait()
								elem.Visible = false
							end
						end
					end)
				end
				task.wait(0.3)
				CanvasList.Visible = true
				t:Create(CanvasList, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupColor3 = Color3.fromRGB(255,255,255)}):Play()
				local waittween = t:Create(CanvasList, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 0})
				waittween:Play()
				waittween.Completed:Wait()
			end)
		end)

        -- Toggle
        function Tab:CreateToggle(ToggleSettings)
            local ToggleValue = {}
            -- Doing this, so if ToggleSettings.CurrentValue is alredy True, it will execute code inside Callback func
			if ToggleSettings.CurrentValue == true then
				print("THIS IS TEST! "..ToggleSettings.CurrentValue)
	            local success, response = pcall(function() 
	                local anothercall = task.spawn(function() ToggleSettings.Callback(ToggleSettings.CurrentValue) end)
	                table.insert(CurrentlyRunningStuff, anothercall) -- PLEASE remember and ADD a feature in setting that lets you disable currently running functions if they were running but plr setted toggle val to false
	            end)
			end

            local Toggle = ElementsTemplates:FindFirstChild("Toggle"):Clone()
            Toggle.Parent = List
            Toggle.Name = ToggleSettings.Name
            Toggle.Title.Text = ToggleSettings.Name
            Toggle.Visible = true

            -- Stuff for Animating
            local ToggleModel = Toggle.ToggleModel
            local ball = ToggleModel.Frame
            local ToggleGreenBack = ToggleModel.ToggleGreenBack
            local BtnActivate = ToggleModel.BtnActivate
            local folder = ToggleGreenBack.Folder
            local t = TweenService
            local function AnimateToBlack()
                for _, v in folder:GetChildren() do
                    task.delay(0.05, function() v.Visible = true end)
                end

                local ballpos = UDim2.new(0.03, 0,0.071, 0)
                ToggleGreenBack.UIGradient.Enabled = false
                t:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = ballpos}):Play()
                t:Create(ball.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(21,21,21)}):Play()
                t:Create(ball.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
                t:Create(ToggleModel, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
                t:Create(ToggleGreenBack, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
                t:Create(ToggleGreenBack, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(34,34,34)}):Play()
            end

            local function AnimateToGreen()
            	for _, v in folder:GetChildren() do
                    task.delay(0.07, function() v.Visible = false end)
                end
                local ballpos = UDim2.new(0.56, 0,0.071, 0)--0.4, 0,0.857, 0 for a joke
                ToggleGreenBack.UIGradient.Enabled = true
                t:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = ballpos}):Play()
                t:Create(ball.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(149, 229, 125)}):Play()
                t:Create(ball.Shadow, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 0.69}):Play()
                t:Create(ToggleModel, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
                t:Create(ToggleGreenBack, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Transparency = 0.35}):Play()
                t:Create(ToggleGreenBack, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            end

            if ToggleSettings.CurrentValue == true then
                AnimateToGreen()
            else
                AnimateToBlack()
            end

            BtnActivate.MouseButton1Click:Connect(function()
                if ToggleSettings.CurrentValue == true then
                    ToggleSettings.CurrentValue = false
                    AnimateToBlack()
                else 
                    ToggleSettings.CurrentValue = true
                    AnimateToGreen()
                end

                local Success, Response = pcall(function()

					--if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (Interact)') end
                    local call = task.spawn(function() ToggleSettings.Callback(ToggleSettings.CurrentValue) end)
                    table.insert(CurrentlyRunningStuff, call)
				        end)
            end)

        return ToggleSettings
        end

        return Tab
    end

    return Window
end

return HubLibrary
