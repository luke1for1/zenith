local lastHatch = game.Players.LocalPlayer:WaitForChild("PlayerGui").ScreenGui:FindFirstChild("Hatching"):FindFirstChild("Last")

local requestFunc = (syn and syn.request) or http_request or request
if not requestFunc then
    error("Your executor doesn't support HTTP requests.")
end

if lastHatch then
    print("found")
end

local HttpService = game:GetService("HttpService")

local function sendWebhook(chance, name)
    local color = (chance <= 0.005 and 16776960) or (chance <= 0.05 and 255) or 255
    local oneIn = math.floor(100 / chance)
    local mention = (getgenv().UserId and getgenv().UserId ~= 0) and "<@" .. getgenv().UserId .. ">" or ""

    local data = {
        ["content"] = mention,
        ["embeds"] = {{
            ["title"] = "Pet Hatched:",
            ["description"] = "You have hatched a rare pet!",
            ["color"] = color,
            ["fields"] = {
                {["name"] = "Pet Name", ["value"] = tostring(name), ["inline"] = true},
                {["name"] = "Chance", ["value"] = tostring(chance) .. "% & 1/" .. oneIn, ["inline"] = true}
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local response = requestFunc({
        Url = getgenv().webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })

    if not response or response.StatusCode ~= 200 then
        warn("Webhook failed. Code:", response and response.StatusCode)
    else
        print("sent webhook")
    end
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
