local StageCheck = {}

-- [[ SETTINGS ]]
local worlds = {"OnePiece", "Namek", "Naruto", "TokyoGhoul", "SAO", "JJK", "TrashGround"}
local miscStages = {
    "Calamity_Chapter1",
    "Calamity_Chapter2",
    "JJK_Raid_Chapter1",
    "JJK_Raid_Chapter2",
    "Esper_Raid_Chapter"
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Helper: เข้าถึง Folder StageClears
local function getStageFolder()
    local pd = ReplicatedStorage:WaitForChild("Player_Data", 10)
    if not pd then return nil end
    local pFolder = pd:FindFirstChild(player.Name) or pd:FindFirstChild("LocalPlayer")
    return pFolder and pFolder:FindFirstChild("StageClears")
end

-- [[ FUNCTION: CREATE & SHOW GUI ]]
function StageCheck.ShowGUI()
    -- ป้องกันการสร้างซ้ำ
    if player.PlayerGui:FindFirstChild("StageTracker_Module") then 
        player.PlayerGui.StageTracker_Module:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StageTracker_Module"
    ScreenGui.Parent = player.PlayerGui

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
    Title.Text = "📊 STAGE TRACKER (MODULIZED)"
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

    local function updateItems()
        for _, v in ipairs(Scroll:GetChildren()) do 
            if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end 
        end
        
        local folder = getStageFolder()
        if not folder then return end

        for _, w in ipairs(worlds) do
            -- Header
            local h = Instance.new("TextLabel")
            h.Size = UDim2.new(1, 0, 0, 25)
            h.Text = "--- " .. w .. " ---"
            h.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
            h.TextColor3 = Color3.new(1, 1, 1)
            h.Parent = Scroll

            -- Chapters 1-5
            for i = 1, 5 do
                StageCheck.CreateRow(w .. "_Chapter" .. i, folder, Scroll)
            end
            -- Rangers
            local maxR = (w == "JJK") and 4 or 3
            for i = 1, maxR do
                StageCheck.CreateRow(w .. "_RangerStage" .. i, folder, Scroll, true)
            end
        end

        -- Misc Section
        local mh = Instance.new("TextLabel")
        mh.Size = UDim2.new(1, 0, 0, 25)
        mh.Text = "--- MISC / RAIDS ---"
        mh.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
        mh.TextColor3 = Color3.new(1, 1, 1)
        mh.Parent = Scroll
        for _, m in ipairs(miscStages) do
            StageCheck.CreateRow(m, folder, Scroll)
        end
    end

    updateItems()
    -- Auto Refresh when folder changes
    local folder = getStageFolder()
    if folder then folder.ChildAdded:Connect(updateItems) end
end

-- Helper: สร้างแถวใน UI
function StageCheck.CreateRow(name, folder, parent, isRanger)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = isRanger and Color3.fromRGB(35, 40, 55) or Color3.fromRGB(30, 30, 30)
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = "Left"
    label.TextColor3 = folder:FindFirstChild(name) and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(200, 200, 200)
    label.Text = (folder:FindFirstChild(name) and "✅ " or "❌ ") .. name
    label.Parent = row
end

-- [[ FUNCTION: GET NEXT TARGET (สำหรับ Auto Farm) ]]
-- ฟังก์ชันนี้จะคืนค่าชื่อด่านถัดไปที่ยังไม่ผ่าน เพื่อให้บอทวิ่งไปฟาร์ม
function StageCheck.GetNextTarget()
    local folder = getStageFolder()
    if not folder then return nil end

    -- เช็คตามลำดับ World -> Chapter -> Ranger
    for _, w in ipairs(worlds) do
        for i = 1, 5 do
            local name = w .. "_Chapter" .. i
            if not folder:FindFirstChild(name) then return name end
        end
        local maxR = (w == "JJK") and 4 or 3
        for i = 1, maxR do
            local name = w .. "_RangerStage" .. i
            if not folder:FindFirstChild(name) then return name end
        end
    end

    -- เช็ค Misc ต่อ
    for _, m in ipairs(miscStages) do
        if not folder:FindFirstChild(m) then return m end
    end

    return nil -- ผ่านหมดแล้วทุกด่าน!
end

return StageCheck
