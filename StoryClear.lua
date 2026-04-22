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

-- [[ FUNCTION: หาด่านถัดไปที่ทีมยังไม่ผ่าน ]]
function Story.GetNext(team, ReplicatedStorage)
    local pd = ReplicatedStorage:WaitForChild("Player_Data")
    
    -- 1. เช็คด่านตาม World (Chapter 1-5 และ Ranger)
    for _, w in ipairs(worlds) do
        -- เช็ค Chapter 1-5
        for i = 1, 5 do
            local stageName = w .. "_Chapter" .. i
            if Story.CheckNeedsClear(team, pd, stageName) then
                return w, stageName
            end
        end
        
        -- เช็ค Ranger Stage (JJK มี 4, อื่นๆ มี 3)
        local maxRanger = (w == "JJK") and 4 or 3
        for i = 1, maxRanger do
            local stageName = w .. "_RangerStage" .. i
            if Story.CheckNeedsClear(team, pd, stageName) then
                return w, stageName
            end
        end
    end

    -- 2. เช็คด่าน MISC / RAIDS
    for _, mStage in ipairs(miscStages) do
        if Story.CheckNeedsClear(team, pd, mStage) then
            -- สำหรับ Misc อาจจะไม่มีระบุ World ชัดเจนใน Remote 
            -- ให้ส่งชื่อด่านเป็นทั้ง World และ Chapter หรือปรับตามระบบเกมของคุณ
            return "Misc", mStage 
        end
    end
    
    return nil, nil
end

-- [[ HELPER: ตรวจสอบว่ามีคนในทีมยังไม่ผ่านด่านนี้ไหม ]]
function Story.CheckNeedsClear(team, pd, stageName)
    for _, name in ipairs(team) do
        local d = pd:FindFirstChild(name)
        if d and d:FindFirstChild("StageClears") then
            if not d.StageClears:FindFirstChild(stageName) then
                return true -- มีอย่างน้อย 1 คนยังไม่ผ่าน
            end
        end
    end
    return false
end

-- [[ FUNCTION: สร้างห้อง Story ]]
function Story.CreateRoom(Remote, world, chapter, UI, delayTime)
    print("[F9 LOG] Story Clear Action: " .. chapter)
    
    -- ลำดับการยิง Remote เพื่อสร้างห้อง
    Remote:FireServer("Create") 
    task.wait(delayTime or 0.5)
    
    Remote:FireServer("Change-World", { World = world }) 
    task.wait(delayTime or 0.3)
    
    Remote:FireServer("Change-Chapter", { Chapter = chapter }) 
    task.wait(delayTime or 0.3)
    
    Remote:FireServer("Submit")
    
    -- อัปเดตสถานะบน UI (ถ้ามีฟังก์ชัน Update)
    if UI and UI.Update then
        UI.Update("🛠 สร้างห้อง Story: " .. chapter)
    end
end

return Story
