local lastHatch = game.Players.LocalPlayer:WaitForChild("PlayerGui").ScreenGui:FindFirstChild("Hatching"):FindFirstChild("Last")

if lastHatch then
    print("found")
end

local hatched = {}

local HttpService = game:GetService("HttpService")

local function sendWebhook(chance, name)
    local time = math.floor(os.time() + 600)
    local timestamp = "<t:" .. time .. ":R>"

    if webhook ~= "" then

        local mention = ""
        if getgenv().UserId ~= nil or 0 then
            mention = ""
        else
            mention = getgenv().UserId
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
                        ["name"] = "Chance ",
                        ["value"] = tostring(chance),
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

while task.wait(2) do
    if lastHatch then
        for i, v in ipairs(lastHatch:GetChildren()) do
            task.wait()
            if v:IsA("Frame") then
                local chance = v:FindFirstChild("Chance")
                if chance then
                    table.insert(hatched, {Name = v.Name, Chance = chance.Text})
                end
            end
        end
    end
    if #hatched > 0 then
        for i, v in ipairs(hatched) do
            task.wait()
            local hatchedName = v.Name
            local hatchedChance = string.gsub(v.Chance, "%%", "")

            print(hatchedName, hatchedChance)
            if tonumber(hatchedChance) <= tonumber(getgenv().highestChance) then
                sendWebhook(hatchedChance, hatchedName)
            end
        end
    end
end
