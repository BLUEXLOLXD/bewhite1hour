local Story = {}

-- [[ CONFIGURATION ]]
local worlds = {"OnePiece", "Namek", "Naruto", "TokyoGhoul", "SAO", "JJK", "TrashGround"}
local miscStages = {
    "Calamity_Chapter1",
    "Calamity_Chapter2",
    "JJK_Raid_Chapter1",
    "JJK_Raid_Chapter2",
    "Esper_Raid_Chapter"
}

-- [[ REMOTE PATH ]]
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

-- [[ FUNCTION: ตรวจหาด่านถัดไป ]]
function Story.GetNext(team, ReplicatedStorage)
    local pd = ReplicatedStorage:WaitForChild("Player_Data")
    
    -- 1. เช็ค World ปกติ
    for _, w in ipairs(worlds) do
        -- Chapters (Story Mode)
        for i = 1, 5 do
            local name = w .. "_Chapter" .. i
            if Story.NeedsClear(team, pd, name) then return w, name, "Story" end
        end
        -- Rangers (Ranger Mode)
        local maxR = (w == "JJK") and 4 or 3
        for i = 1, maxR do
            local name = w .. "_RangerStage" .. i
            if Story.NeedsClear(team, pd, name) then return w, name, "Ranger" end
        end
    end

    -- 2. เช็ค Misc (Calamity / Raid)
    for _, m in ipairs(miscStages) do
        if Story.NeedsClear(team, pd, m) then
            if m:find("Calamity") then
                return "CalamityWorld", m, "Calamity"
            else
                return "OnePiece", m, "Raid" -- Raid มักอ้างอิง World หลักอันใดอันหนึ่ง
            end
        end
    end
    return nil, nil, nil
end

-- Helper เช็คว่าต้องผ่านด่านไหม
function Story.NeedsClear(team, pd, stage)
    for _, name in ipairs(team) do
        local d = pd:FindFirstChild(name)
        if d and d:FindFirstChild("StageClears") and not d.StageClears:FindFirstChild(stage) then
            return true
        end
    end
    return false
end

-- [[ FUNCTION: สร้างห้องแยกตามโหมด ]]
function Story.CreateRoom(world, chapter, modeType, delayTime)
    local waitTime = delayTime or 0.5
    print("[F9] Creating Room | Mode: " .. modeType .. " | Chapter: " .. chapter)

    if modeType == "Story" then
        Remote:FireServer("Create") task.wait(waitTime)
        Remote:FireServer("Change-World", { World = world }) task.wait(waitTime)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
        
    elseif modeType == "Ranger" then
        -- Ranger ไม่ต้องกด Create ตามสคริปต์ที่คุณให้มา แต่เน้น Change-Mode
        Remote:FireServer("Change-Mode", { KeepWorld = world, Mode = "Ranger Stage" }) task.wait(waitTime)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
        
    elseif modeType == "Calamity" then
        Remote:FireServer("Create") task.wait(waitTime)
        Remote:FireServer("Change-Mode", { Mode = "Calamity" }) task.wait(waitTime)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
        
    elseif modeType == "Raid" then
        Remote:FireServer("Create") task.wait(waitTime)
        Remote:FireServer("Change-Mode", { KeepWorld = world, Mode = "Raids Stage" }) task.wait(waitTime)
        Remote:FireServer("Change-Chapter", { Chapter = chapter })
    end

    task.wait(waitTime)
    Remote:FireServer("Submit")
    print("✅ Submit successful. Waiting for players to start.")
end

return Story
