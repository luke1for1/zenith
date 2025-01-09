repeat task.wait() until game:IsLoaded()
print("Loaded")

local httpService = game:GetService("HttpService")

local placeID = game.PlaceId
local teleportService = game:GetService("TeleportService")
local Found = false

local function checkForViciousBee()
    for _, child in ipairs(game:GetService("Workspace").Monsters:GetChildren()) do
        if string.find(child.Name, "Windy Bee") then
            Found = true
            return true
        end
    end
    return false
end
local function sendNotif()
    print("FOUND")
    game.StarterGui:SetCore("SendNotification", {
        Title = "W Bee Hopper",
        Text = "FOUND",
        Duration = 30
    })
end

local function hop()
    local success, site = pcall(function()
        return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?sortOrder=Asc&limit=100'))
    end)
    
    if not success or not site or not site.data then
        return
    end
    
    for _, serverData in pairs(site.data) do
        if serverData.maxPlayers > serverData.playing then
            local serverID = tostring(serverData.id)
            local hopSuccess, _ = pcall(function()
                if Found then
                    sendNotif()
                    return true
                end
                teleportService:TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
            end)
            if hopSuccess then
                break
            end
        end
    end
end

game:GetService("Workspace").Monsters.ChildAdded:Connect(function(child)
    if string.find(child.Name, "Vicious Bee") then
        Found = true
    end
end)

if not checkForViciousBee() then
    hop()
else
    sendNotif()
end
