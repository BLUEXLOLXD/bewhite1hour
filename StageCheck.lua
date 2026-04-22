local Story = {}

-- [[ CONFIGURATION ]]
local worlds = {"OnePiece", "Namek", "Naruto", "TokyoGhoul", "SAO", "JJK", "TrashGround"}
local miscStages = {
    "Calamity_Chapter1", "Calamity_Chapter2",
    "JJK_Raid_Chapter1", "JJK_Raid_Chapter2", "Esper_Raid_Chapter"
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Remote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
local PlayRoomFolder = ReplicatedStorage:WaitForChild("PlayRoom")

-- Helper: เข้าถึงโฟลเดอร์ StageClears ของผู้เล่นนั้นๆ
local function getStageFolder(targetName)
    local pd = ReplicatedStorage:WaitForChild("Player_Data", 10)
    if not pd then return nil end
    local pFolder = pd:FindFirstChild(targetName) or pd:FindFirstChild("LocalPlayer")
    return pFolder and pFolder:FindFirstChild("StageClears")
end

-- [[ 1. GUI LOGIC (Centered Check List) ]]
function Story.ShowGUI()
    if player.PlayerGui:FindFirstChild("StageTracker_UI") then 
        player.PlayerGui.StageTracker_UI:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StageTracker_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 480)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Text = "📊 STAGE PROGRESS"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -15, 1, -60)
    Scroll.Position = UDim2.new(0, 7, 0, 52)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 2200)
    Scroll.ScrollBarThickness = 3
    Scroll.Parent = Main
    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

    local function refreshUI()
        for _, v in ipairs(Scroll:GetChildren()) do 
            if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end 
        end
        
        local folder = getStageFolder(player.Name)
        if not folder then return end

        for _, w in ipairs(worlds) do
            local h = Instance.new("TextLabel")
            h.Size = UDim2.new(1, 0, 0, 25)
            h.Text = "--- " .. w .. " ---"
            h.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
            h.TextColor3 = Color3.new(1, 1, 1)
            h.Parent = Scroll

            for i = 1, 5 do Story.AddRow(w .. "_Chapter" .. i, folder, Scroll) end
            local maxR = (w == "JJK") and 4 or 3
            for i = 1, maxR do Story.AddRow(w .. "_RangerStage" .. i, folder, Scroll, true) end
        end

        local mh = Instance.new("TextLabel")
        mh.Size = UDim2.new(1, 0, 0, 25)
        mh.Text = "--- MISC / RAIDS ---"
        mh.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
        mh.TextColor3 = Color3.new(1, 1, 1)
        mh.Parent = Scroll
        for _, m in ipairs(miscStages) do Story.AddRow(m, folder, Scroll) end
    end

    refreshUI()
    local folder = getStageFolder(player.Name)
    if folder then folder.ChildAdded:Connect(refreshUI) end
end

function Story.AddRow(name, folder, parent, isRanger)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = isRanger and Color3.fromRGB(35, 40, 55) or Color3.fromRGB(30, 30, 30)
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = "Left"
    local hasStage = folder:FindFirstChild(name)
    label.TextColor3 = hasStage and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(200, 200, 200)
    label.Text = (hasStage and "✅ " or "❌ ") .. name
    label.Parent = row
end

-- [[ 2. HOST LOGIC (Targeting & Room Creation) ]]
function Story.GetNextTarget(joinerNames)
    local pd = ReplicatedStorage:WaitForChild("Player_Data")
    for _, w in ipairs(worlds) do
        for i = 1, 5 do
            local name = w .. "_Chapter" .. i
            if Story.CheckNeeds(joinerNames, pd, name) then return w, name, "Story" end
        end
        local maxR = (w == "JJK") and 4 or 3
        for i = 1, maxR do
            local name = w .. "_RangerStage" .. i
            if Story.CheckNeeds(joinerNames, pd, name) then return w, name, "Ranger" end
        end
    end
    for _, m in ipairs(miscStages) do
        if Story.CheckNeeds(joinerNames, pd, m) then
            local mode = m:find("Calamity") and "Calamity" or "Raid"
            return "OnePiece", m, mode
        end
    end
    return nil, nil, nil
end

function Story.CheckNeeds(names, pd, stage)
    for _, n in ipairs(names) do
        local d = pd:FindFirstChild(n)
        if d and d:FindFirstChild("StageClears") and not d.StageClears:FindFirstChild(stage) then
            return true
        end
    end
    return false
end

function Story.CreateRoom(world, chapter, modeType)
    Remote:FireServer("Create") task.wait(0.5)
    if modeType == "Story" then
        Remote:FireServer("Change-World", { World = world }) task.wait(0.3)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
    elseif modeType == "Ranger" then
        Remote:FireServer("Change-Mode", { KeepWorld = world, Mode = "Ranger Stage" }) task.wait(0.3)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
    elseif modeType == "Calamity" then
        Remote:FireServer("Change-Mode", { Mode = "Calamity" }) task.wait(0.3)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
    elseif modeType == "Raid" then
        Remote:FireServer("Change-Mode", { KeepWorld = world, Mode = "Raids Stage" }) task.wait(0.3)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
    end
    task.wait(0.5)
    Remote:FireServer("Submit")
end

-- [[ 3. ROOM CHECK LOGIC (Player1-4 Validation) ]]
function Story.IsRoomReady(hostName, joinerNames)
    local room = PlayRoomFolder:FindFirstChild(hostName)
    if not room then return false end
    local playersFolder = room:FindFirstChild("Players")
    if not playersFolder then return false end

    local required = { [hostName] = true }
    for _, n in ipairs(joinerNames) do required[n] = true end
    
    local readyCount = 0
    local targetCount = #joinerNames + 1

    print("--- Checking Room: " .. hostName .. " ---")
    for i = 1, 4 do
        local pObj = playersFolder:FindFirstChild("Player" .. i)
        if pObj and pObj.Value ~= "" and pObj.Value ~= "None" then
            if required[pObj.Value] then
                print(string.format("[Player%d] ✅ %s", i, pObj.Value))
                readyCount = readyCount + 1
            else
                print(string.format("[Player%d] ❌ Unknown: %s", i, pObj.Value))
            end
        end
    end
    print(string.format("Status: %d/%d Ready", readyCount, targetCount))
    return readyCount >= targetCount
end

function Story.StartGame()
    Remote:FireServer("Start") -- ปรับชื่อ Remote Start ตามจริง
    print("🚀 All ready! Game Started.")
end

-- [[ 4. JOINER LOGIC ]]
function Story.JoinHost(hostName)
    local room = PlayRoomFolder:FindFirstChild(hostName)
    if room then
        Remote:FireServer("Join-Room", { Room = room })
        return true
    end
    return false
end

return Story

-- [[ JOINER LOGIC: FIX JOIN REMOTE ]]
function Story.JoinHost(hostName)
    -- ตรวจสอบว่ามี Object ห้องของ Host ใน PlayRoom หรือยัง
    local roomPath = PlayRoomFolder:FindFirstChild(hostName)
    
    if roomPath then
        -- ใช้โครงสร้าง args ตามที่คุณระบุมาเป๊ะๆ
        local args = {
            "Join-Room",
            {
                Room = roomPath
            }
        }
        
        -- ยิง Remote ไปที่ Event
        Remote:FireServer(unpack(args))
        
        print("✅ [JOINER] ยิง Remote Join-Room ไปที่ห้อง: " .. hostName)
        return true
    end
    return false
end
