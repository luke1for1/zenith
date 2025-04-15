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

    if getgenv().webhook and getgenv().webhook ~= "" then
        local mention = ""
        if getgenv().UserId and getgenv().UserId ~= 0 then
            mention = "<@" .. getgenv().UserId .. ">"
        end

        local oneIn = math.floor(100 / chance)

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
                        ["value"] = tostring(chance) .. "% & 1/" .. oneIn,
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
    task.wait(1)

    if lastHatch.Visible and not hasRun then
        hasRun = true

        for _, v in ipairs(lastHatch:GetChildren()) do
            if v:IsA("Frame") then
                local chance = v:FindFirstChild("Chance")
                if chance and chance:IsA("TextLabel") then
                    local rawChance = chance.Text:gsub("%%", "")
                    local hatchedChance = tonumber(rawChance)
                    if hatchedChance and hatchedChance <= getgenv().highestChance then
                        sendWebhook(hatchedChance, v.Name)
                    end
                end
            end
        end

    elseif not lastHatch.Visible then
        hasRun = false
    end
end
