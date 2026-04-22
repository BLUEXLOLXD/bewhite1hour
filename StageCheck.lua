local Story = {}

-- [[ CONFIGURATION ]]
local worlds = {"OnePiece", "Namek", "Naruto", "TokyoGhoul", "SAO", "JJK", "TrashGround"}
local miscStages = {
    "Calamity_Chapter1", "Calamity_Chapter2",
    "JJK_Raid_Chapter1", "JJK_Raid_Chapter2", "Esper_Raid_Chapter"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
local PlayRoomFolder = ReplicatedStorage:WaitForChild("PlayRoom")

-- [[ HOST LOGIC ]]
function Story.GetNextTarget(joinerNames)
    local pd = ReplicatedStorage:WaitForChild("Player_Data")
    
    for _, w in ipairs(worlds) do
        -- 1. Story
        for i = 1, 5 do
            local name = w .. "_Chapter" .. i
            if Story.CheckNeeds(joinerNames, pd, name) then return w, name, "Story" end
        end
        -- 2. Ranger
        local maxR = (w == "JJK") and 4 or 3
        for i = 1, maxR do
            local name = w .. "_RangerStage" .. i
            if Story.CheckNeeds(joinerNames, pd, name) then return w, name, "Ranger" end
        end
    end
    -- 3. Misc (Calamity & Raid)
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

-- [[ JOINER LOGIC ]]
function Story.JoinHost(hostName)
    local room = PlayRoomFolder:FindFirstChild(hostName)
    if room then
        Remote:FireServer("Join-Room", { Room = room })
        return true
    end
    return false
end

return Story
