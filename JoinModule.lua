local JoinModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayRoomFolder = ReplicatedStorage:WaitForChild("PlayRoom")
local Remote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

-- [[ FUNCTION: สั่ง Join ห้องครั้งเดียว ]]
function JoinModule.Join(hostName)
    -- ค้นหา Folder ห้องตามชื่อ Host (เช่น Waterman_Bc)
    local roomPath = PlayRoomFolder:FindFirstChild(hostName)
    
    if roomPath then
        -- ใช้ Arguments ตามที่คุณกำหนดเป๊ะๆ
        local args = {
            "Join-Room",
            {
                Room = roomPath
            }
        }
        
        -- ยิง Remote
        Remote:FireServer(unpack(args))
        return true
    end
    return false
end

-- [[ FUNCTION: Loop Join จนกว่าจะสำเร็จ ]]
function JoinModule.StartLoop(hostName, interval)
    interval = interval or 1 -- ถ้าไม่ใส่เวลา จะวนทุก 1 วินาที
    
    print("👥 [JoinSystem] กำลังเริ่ม Loop ค้นหาห้องของ: " .. hostName)
    
    task.spawn(function()
        local joined = false
        while not joined do
            joined = JoinModule.Join(hostName)
            if joined then
                print("✅ [JoinSystem] เข้าห้องสำเร็จ!")
                break
            end
            task.wait(interval)
        end
    end)
end

return JoinModule
