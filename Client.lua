local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ACSFCFramework = ReplicatedStorage:WaitForChild("ACSFFramework")
local Modules = ACSFCFramework:WaitForChild"Modules"
local Events = ACSFCFramework:WaitForChild"Events"
local Viewmodels = ACSFCFramework:WaitForChild"Viewmodels"
local Effects = ACSFCFramework:WaitForChild"Effects"
local GUI = ACSFCFramework:WaitForChild"GUI"
local UserInputService = game:GetService("UserInputService")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local SwayEffect = 0.5

local Walk = true
local Run = false

local speed = Humanoid.WalkSpeed/5

local SwayCFrame = CFrame.new()
local LastCameraCFrame = CFrame.new()
local gunCFrame = CFrame.new();
local WalkCFrame = CFrame.new();
local runCFrame = CFrame.Angles(math.rad(-12.2),math.rad(12.52),math.rad(12.2));
local aimingCFrame = CFrame.new(-0.12,0.012,0.832) * CFrame.Angles(math.rad(0),math.rad(2.12),math.rad(14.34));

local Framework = {
    Primary = "AK47";
    Secondary = nil;
    Viewmodel = nil;
    Module = nil;
    Statuses = {
        Inspecting = false;
        Aiming = false;
    }
}

local function SetViewmodel(Name)
    local Viewmodel = Viewmodels:FindFirstChild(Name)
    local Module = Modules:FindFirstChild(Name)
    if Viewmodel and Module then
        game.Workspace.CurrentCamera:ClearAllChildren()
        Framework.Module = require(Module)
        local NewViewmodel = Viewmodel:Clone()
        NewViewmodel.Parent = game.Workspace.CurrentCamera
        Framework.Viewmodel = NewViewmodel
    end
end

local function HasEssentials()
    if Framework.Viewmodel and Framework.Module then
        return true
    else
        return false
    end
end

local function Val(Val)
    return Val
end

local function ISWALKING()
    if Humanoid.MoveDirection == Vector3.new(0,0,0) then
        return false
    else
        return true
    end
end

SetViewmodel(Framework.Primary)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input and not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.F then
            if HasEssentials() then
                if Val(Framework.Statuses.Inspecting) == false then
                    Framework.Statuses.Inspecting = true
                    Framework.Module:Inspect(Framework.Viewmodel)
                end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then 
            if HasEssentials() then
                Framework.Statuses.Aiming = true
                task.defer(function()
                    for i = 0, 1, 0.1 do
                        gunCFrame = gunCFrame:Lerp(aimingCFrame, i)
                        task.wait()
                    end
                end)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input and not gameProcessedEvent then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if HasEssentials() then
                Framework.Statuses.Aiming = false
                task.defer(function()
                    for i = 0, 1, 0.1 do
                        gunCFrame = gunCFrame:Lerp(CFrame.new(), i);
                        task.wait()
                    end
                end)
            end
        end
    end
end)

RunService:BindToRenderStep(game.Players.LocalPlayer.UserId .. "/" .. Framework.Primary,200,function()
    local Rotation = workspace.CurrentCamera.CFrame:toObjectSpace(LastCameraCFrame)
    local X,Y,Z = Rotation:ToOrientation()
    if Framework.Statuses.Aiming then

    else
        SwayCFrame = SwayCFrame:Lerp(CFrame.Angles(math.abs(math.sin(X)) * SwayEffect, math.abs(math.sin(Y))* SwayEffect, 0), 0.25)
        LastCameraCFrame = workspace.CurrentCamera.CFrame
    end

    if ISWALKING() then
        Walk = true
    else
        Walk = false
    end

    if Walk == true then
        WalkCFrame = WalkCFrame:lerp(CFrame.new(0.03 * math.sin(tick() * (2.3 * speed)),0.03 * math.cos(tick() * (3 * speed)),0)*CFrame.Angles(0,0,-.02 * math.sin(tick() * (3 * speed))),.5)
    else
        WalkCFrame = WalkCFrame:lerp(CFrame.new(),.1)
    end

    if Run == true then
        WalkCFrame = WalkCFrame:lerp(CFrame.new(0.04 * math.sin(tick() * (2.5 * speed)),0.04 * math.cos(tick() * (3 * speed)),0)*CFrame.Angles(0,0,-.03 * math.sin(tick() * (3 * speed))) * runCFrame,.5)
    else
        WalkCFrame = WalkCFrame:lerp(CFrame.new(),.1)
    end

    Framework.Viewmodel:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * CFrame.new(-0.4,-0.2,2.2) * gunCFrame * SwayCFrame * WalkCFrame)
end)
