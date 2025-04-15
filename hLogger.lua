getgenv().UserId = nil
getgenv().highestChance = 1
getgenv().webhook = "https://discord.com/api/webhooks/1360758785920073909/6P30BRv0CdSrs3UD4e9NQntggVbGHqeDFKHMroAA5fTgXfQZzg2ivt3_k9G6oGMW98Wx"

local lastHatch = game.Players.LocalPlayer:WaitForChild("PlayerGui").ScreenGui:FindFirstChild("Hatching"):FindFirstChild("Last")

if lastHatch then
    print("found")
end

local HttpService = game:GetService("HttpService")

local function sendWebhook(chance, name)
    local time = math.floor(os.time() + 600)
    local timestamp = "<t:" .. time .. ":R>"

    local color
    if chance <= 0.005 then
        color = 16776960
    elseif chance <= 0.05 then
        color = 255
    else
        color = 255
    end

    if webhook ~= "" then
        local mention = ""
        if getgenv().UserId ~= nil or 0 then
            mention = ""
        else
            mention = "<@" .. getgenv().UserId .. ">"
        end

        local data = {
            ["content"] = mention,
            ["embeds"] = { {
                ["title"] = "Pet Hatched:",
                ["description"] = "You have hatched a rare pet!",
                ["color"] = color,
                ["fields"] = {
                    {
                        ["name"] = "Pet Name",
                        ["value"] = tostring(name),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Chance",
                        ["value"] = tostring(chance) .. "%",
                        ["inline"] = true
                    }
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            } }
        }

        local response = request({
            Url = getgenv().webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })

        if response.StatusCode ~= 200 then
            warn("Webhook failed with status code: " .. response.StatusCode)
        end
    end
    print("sent webhook")
end

local hasRun = false

while true do
    task.wait()
    
    if lastHatch and lastHatch.Parent == visible and not hasRun then
        hasRun = true

        for _, v in ipairs(lastHatch:GetChildren()) do
            if v:IsA("Frame") then
                local chance = v:FindFirstChild("Chance")
                if chance then
                    local hatchedName = v.Name
                    local hatchedChance = tonumber(chance.Text:gsub("%%", ""))
                    if hatchedChance and hatchedChance <= getgenv().highestChance then
                        sendWebhook(hatchedChance, hatchedName)
                    end
                end
            end
        end
    elseif lastHatch and lastHatch.Parent ~= visible then
        hasRun = false
    end
end
