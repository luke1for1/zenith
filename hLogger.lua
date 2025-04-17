local lastHatch = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Hatching"):WaitForChild("Last")

local requestFunc = (syn and syn.request) or http_request or request
if not requestFunc then error("Your executor doesn't support HTTP requests.") end

local HttpService = game:GetService("HttpService")

local function sendWebhook(chance, name, asset)
    local color = (chance <= 0.005 and 16776960) or (chance <= 0.05 and 255) or 255
    local oneIn = math.floor(100 / chance)
    local mention = (getgenv().UserId and getgenv().UserId ~= 0) and "<@" .. getgenv().UserId .. ">"

    local assetId = asset:match("%d+")

    local thumbUrl = ""
    local response = requestFunc({
        Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=png",
        Method = "GET"
    })

    if response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data and #data.data > 0 then
            thumbUrl = data.data[1].imageUrl 
        end
    else
        warn("Failed to fetch image URL. Status code:", response and response.StatusCode)
    end

    local data = {
        content = mention,
        embeds = { {
            title = "Pet Hatched:",
            description = "You have hatched a rare pet!",
            color = color,
            fields = {
                {name = "Pet Name", value = tostring(name), inline = true},
                {name = "Chance", value = tostring(chance) .. "% & 1/" .. oneIn, inline = true}
            },
            thumbnail = { url = thumbUrl },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        } }
    }

    local response = requestFunc({
        Url = getgenv().webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })

    if not response or response.StatusCode ~= 200 then
        warn("Webhook failed. Code:", response and response.StatusCode)
    end
end

local hasRun = false

spawn(function()
    while true do
        task.wait()
        if lastHatch.Parent.Visible and not hasRun then
            hasRun = true
            for _, v in ipairs(lastHatch:GetChildren()) do
                if v:IsA("Frame") then
                    local chance = v:FindFirstChild("Chance")
                    local petName = v:FindFirstChild("PetName") or v:FindFirstChildOfClass("TextLabel")
                    local imageId = v:FindFirstChild("Icon") and v.Icon:FindFirstChild("Label") and v.Icon.Label.Image

                    if chance and chance:IsA("TextLabel") then
                        local rawChance = chance.Text:gsub("%%", "")
                        local hatchedChance = tonumber(rawChance)

                        if v.Icon and v.Icon.Label and v.Icon.Label.Shine then
                            n = "Shiny " .. v.Name
                        else
                            n = v.Name
                        end

                        if hatchedChance and hatchedChance <= getgenv().highestChance then
                            sendWebhook(hatchedChance, n, imageId)
                        end
                    end
                end
            end
        elseif not lastHatch.Parent.Visible then
            hasRun = false
        end
    end
end)
