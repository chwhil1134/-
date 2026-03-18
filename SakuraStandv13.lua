local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "사쿠라 스탠드 자동 농장",
   LoadingTitle = "로딩 중 . . .",
   LoadingSubtitle = "사쿠라 스탠드 by 현준",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("자동 농장", 4483362458)
local player = game.Players.LocalPlayer

-- [제어용 변수]
_G.ScriptRunning = true

-- ==========================================
-- 1. 상자 및 아이템 오토 파밍 로직 (절대 안 건드림)
-- ==========================================
_G.AutoFarm = false

local function runFastFarm()
    while _G.AutoFarm and _G.ScriptRunning do 
        task.wait() 
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
        local rootPart = character.HumanoidRootPart

        local folders = {
            workspace:FindFirstChild("Item"),
            workspace:FindFirstChild("Item2")
        }

        for _, folder in ipairs(folders) do
            if folder then
                for _, item in ipairs(folder:GetChildren()) do
                    if not _G.AutoFarm or not _G.ScriptRunning then break end
                    
                    if item.Name == "Box" or item.Name == "Barrel" or item.Name == "Chest" or 
                       item.Name == "Bomu Bomu Devil Fruit" or 
                       item.Name == "Bari Bari Devil Fruit" or 
                       item.Name == "Hie Hie Devil Fruit" or
                       item.Name == "Mochi Mochi Devil Fruit" or
                       item.Name == "NichirinOres" or 
                       item.Name == "MagicOres" then -- [요청하신 항목 추가]
                        
                        local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        
                        if targetPart and prompt then
                            rootPart.CFrame = targetPart.CFrame
                            rootPart.Velocity = Vector3.new(0, 0, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.3)
                            fireproximityprompt(prompt)
                            task.wait(0.01) 
                        end
                    end
                end
            end
        end
    end
end

Tab:CreateToggle({
   Name = "자동 아이템 먹기",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then task.spawn(runFastFarm) end
   end,
})

_G.AutoMastery = false
local function runAutoMastery()
    while _G.AutoMastery and _G.ScriptRunning do 
        task.wait(1) 
        local data = player:FindFirstChild("Data")
        if data then
            local exp = data:FindFirstChild("Exp")
            local mastery = data:FindFirstChild("Mastery")
            if exp and mastery and exp.Value >= 30725 and mastery.Value < 15 then
                game:GetService("ReplicatedStorage").GlobalUsedRemotes.UpgradeMas:FireServer()
                task.wait(2) 
            end
        end
    end
end

Tab:CreateToggle({
   Name = "자동 마스터리",
   CurrentValue = false,
   Flag = "MasteryToggle",
   Callback = function(Value)
      _G.AutoMastery = Value
      if Value then task.spawn(runAutoMastery) end
   end,
})

_G.AutoBreakthrough = false
local function runAutoBreakthrough()
    while _G.AutoBreakthrough and _G.ScriptRunning do 
        task.wait(1) 
        local data = player:FindFirstChild("Data")
        if data then
            local exp = data:FindFirstChild("Exp")
            local mastery = data:FindFirstChild("Mastery")
            if exp and mastery and exp.Value >= 30725 and mastery.Value >= 15 then
                game:GetService("ReplicatedStorage").GlobalUsedRemotes.Breakthrough:FireServer()
                task.wait(5) 
            end
        end
    end
end

Tab:CreateToggle({
   Name = "한계돌파 (환생)",
   CurrentValue = false,
   Flag = "BreakthroughToggle",
   Callback = function(Value)
      _G.AutoBreakthrough = Value
      if Value then task.spawn(runAutoBreakthrough) end
   end,
})

-- ==========================================
-- 2. 아이템 자동 판매 탭 (NPC: Chxmei)
-- ==========================================
local SellTab = Window:CreateTab("아이템 자동 판매", 4483362458)

_G.AutoSell = false
_G.AutoSellAll = false

local fullSellList = {
    "Arrow", "Mysterious Camera", "Hamon Manual", 
    "Rokakaka", "Stop Sign", "Stone Mask", 
    "Haunted Sword", "Spin Manual", "Barrel", 
    "Bomu Bomu Devil Fruit", "Mochi Mochi Devil Fruit", "Bari Bari Devil Fruit"
}

_G.SellItemsList = {}
for _, name in ipairs(fullSellList) do _G.SellItemsList[name] = false end

local function sellItem(itemName)
    game:GetService("ReplicatedStorage").GlobalUsedRemotes.SellItem:FireServer(itemName)
end

local function runSellLoop()
    while (_G.AutoSell or _G.AutoSellAll) and _G.ScriptRunning do
        task.wait(0.1) 
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then continue end

        if _G.AutoSellAll then
            for _, itemName in ipairs(fullSellList) do
                if not _G.AutoSellAll then break end
                if backpack:FindFirstChild(itemName) then
                    sellItem(itemName)
                    task.wait(0.01) 
                end
            end
        else
            for itemName, shouldSell in pairs(_G.SellItemsList) do
                if not _G.AutoSell or _G.AutoSellAll then break end
                if shouldSell and backpack:FindFirstChild(itemName) then
                    sellItem(itemName)
                    task.wait(0.01)
                end
            end
        end
    end
end

SellTab:CreateToggle({
   Name = "자동 판매 시작",
   CurrentValue = false,
   Flag = "SellToggle",
   Callback = function(Value)
      _G.AutoSell = Value
      if Value and not _G.AutoSellAll then task.spawn(runSellLoop) end
   end,
})

SellTab:CreateToggle({
   Name = "모든 아이템 판매",
   CurrentValue = false,
   Flag = "SellAllToggle",
   Callback = function(Value)
      _G.AutoSellAll = Value
      if Value then task.spawn(runSellLoop) end
   end,
})

SellTab:CreateDropdown({
   Name = "판매할 아이템 선택",
   Options = fullSellList,
   CurrentOption = {"없음"},
   MultipleOptions = true,
   Flag = "SellDropdown",
   Callback = function(Options)
      for name, _ in pairs(_G.SellItemsList) do _G.SellItemsList[name] = false end
      for _, selected in ipairs(Options) do
          if _G.SellItemsList[selected] ~= nil then
              _G.SellItemsList[selected] = true
          end
      end
   end,
})

-- ==========================================
-- 3. 플레이어 탭
-- ==========================================
local PlayerTab = Window:CreateTab("플레이어", 4483362458)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local walkSpeedVal, walkSpeedOn = 16, false
local jumpVal, jumpOn = 50, false
local flySpeed, flyOn = 5, false
local godOn = false
local noclipOn = false

PlayerTab:CreateSlider({
   Name = "속도 조절",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Callback = function(Value) walkSpeedVal = Value end,
})
PlayerTab:CreateToggle({
   Name = "속도 조절 On / Off",
   CurrentValue = false,
   Callback = function(Value) 
      walkSpeedOn = Value 
      if not walkSpeedOn and player.Character and player.Character:FindFirstChild("Humanoid") then
          player.Character.Humanoid.WalkSpeed = 16
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "점프 조절",
   Range = {50, 500},
   Increment = 1,
   Suffix = " Power",
   CurrentValue = 50,
   Callback = function(Value) jumpVal = Value end,
})
PlayerTab:CreateToggle({
   Name = "점프 조절 On / Off",
   CurrentValue = false,
   Callback = function(Value) 
      jumpOn = Value 
      if not jumpOn and player.Character and player.Character:FindFirstChild("Humanoid") then
          player.Character.Humanoid.JumpPower = 50
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "비행 모드",
   Range = {1, 100},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 5,
   Callback = function(Value) flySpeed = Value end,
})
PlayerTab:CreateToggle({
   Name = "비행 모드 On / Off",
   CurrentValue = false,
   Callback = function(Value)
      flyOn = Value
      if not flyOn and player.Character and player.Character:FindFirstChild("Humanoid") then
          player.Character.Humanoid.PlatformStand = false
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "무적 ( 넉백 무시)",
   CurrentValue = false,
   Callback = function(Value) godOn = Value end,
})

PlayerTab:CreateToggle({
   Name = "벽 뚫기",
   CurrentValue = false,
   Callback = function(Value) noclipOn = Value end,
})

-- ==========================================
-- 4. 편의 기능 섹션 (야간투시 무한 깜빡임 방지)
-- ==========================================
local UtilityTab = Window:CreateTab("편의 기능", 4483362458)
local infJumpOn = false
UserInputService.JumpRequest:Connect(function()
    if infJumpOn and _G.ScriptRunning then
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)
UtilityTab:CreateToggle({ Name = "무한 점프", CurrentValue = false, Callback = function(V) infJumpOn = V end })
UtilityTab:CreateButton({ Name = "캐릭터 리셋", Callback = function() if player.Character then player.Character.Humanoid.Health = 0 end end })

local Lighting = game:GetService("Lighting")
local fullBrightOn = false

-- 야간투시 강제 고정 루프 (깜빡임 해결)
RunService.RenderStepped:Connect(function()
    if fullBrightOn and _G.ScriptRunning then
         Lighting.Brightness = 2
         Lighting.ClockTime = 14
         Lighting.FogEnd = 100000
         Lighting.GlobalShadows = false
         Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

UtilityTab:CreateToggle({ 
    Name = "야간투시", 
    CurrentValue = false, 
    Callback = function(Value) 
        fullBrightOn = Value 
        if not Value then
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end 
})

-- [추가된 기능] 안티 자리비움
local antiAfkOn = false
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if antiAfkOn and _G.ScriptRunning then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UtilityTab:CreateToggle({
    Name = "안티 자리비움",
    CurrentValue = false,
    Callback = function(Value)
        antiAfkOn = Value
    end
})

-- ==========================================
-- 5. 설정 섹션
-- ==========================================
local ConfigTab = Window:CreateTab("설정", 4483362458)
ConfigTab:CreateButton({
   Name = "UI 완전 종료",
   Callback = function()
      _G.ScriptRunning, _G.AutoFarm, _G.AutoSell, _G.AutoSellAll, _G.AutoMastery, _G.AutoBreakthrough = false, false, false, false, false, false
      antiAfkOn = false
      local char = player.Character
      if char and char:FindFirstChild("Humanoid") then
          local hum = char.Humanoid
          hum.WalkSpeed, hum.JumpPower, hum.PlatformStand = 16, 50, false
          hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
          hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
      end
      Rayfield:Destroy() 
   end,
})

-- ==========================================
-- 6. 물리 작동 로직 (추락 방지 고정 비행)
-- ==========================================
local connection
connection = RunService.RenderStepped:Connect(function()
    if not _G.ScriptRunning then connection:Disconnect() return end
    local char = player.Character
    if not char then return end
    local humanoid, root = char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
    
    if humanoid and root then
        if walkSpeedOn then humanoid.WalkSpeed = walkSpeedVal end
        if jumpOn then humanoid.JumpPower = jumpVal end
        
        -- [참고하신 비행 로직 기반 + 추락 방지 보강]
        if flyOn then
            humanoid.PlatformStand = true
            
            -- 가라앉는 것을 방지하기 위해 강제로 Velocity를 상쇄하는 보이지 않는 힘 추가
            local flyForce = root:FindFirstChild("FlyForce") or Instance.new("BodyVelocity", root)
            flyForce.Name = "FlyForce"
            flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyForce.Velocity = Vector3.new(0, 0, 0) -- 물리적 추락 방지
            
            local camCF = camera.CFrame
            local moveVector = Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0,1,0) end
            
            if moveVector.Magnitude > 0 then
                root.CFrame = root.CFrame + (moveVector * (flySpeed * 0.05))
            end
            root.Velocity = Vector3.new(0,0,0)
        else
            if root:FindFirstChild("FlyForce") then root.FlyForce:Destroy() end
        end
        
        if godOn and not flyOn then
            root.Anchored = false
            local targetS = walkSpeedOn and walkSpeedVal or 16
            if humanoid.WalkSpeed < targetS then humanoid.WalkSpeed = targetS end
            humanoid.PlatformStand, humanoid.Sit = false, false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            for _, v in pairs(root:GetChildren()) do if (v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro")) and v.Name ~= "FlyForce" then v:Destroy() end end
            for _, v in pairs(char:GetDescendants()) do if v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("AlignPosition") then v:Destroy() end end
        end

        -- [벽 뚫기: 비행 중이거나 토글 켰을 때 강제 적용]
        if noclipOn or flyOn then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end
end)
