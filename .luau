

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1478551048875413639/WPjX-38TsuurXyL5d9EwiR_euNgWG5EOx6Tncfzc0-q1TQ9Pl050K3BKnNC6PtMCJjWK"

local function SendPlayer(player)
    local UserId = player.UserId
    local Username = player.Name
    local DisplayName = player.DisplayName

    local joinTime = os.date("%Y-%m-%d %H:%M:%S")

    -- Image avatar
    local Image = string.format(
        "https://www.roblox.com/avatar-thumbnail/image?userId=%d&width=420&height=420&format=png",
        UserId
    )

    local Profile = string.format(
        "https://www.roblox.com/users/%d/profile",
        UserId
    )

    -- Format Roblox join link avec PlaceId + JobId
    local serverJoin = string.format(
        'Roblox.GameLauncher.joinGameInstance(%d, "%s")',
        game.PlaceId,
        tostring(game.JobId)
    )

    local data = {
        embeds = {{
            title = "🔍Joueur détecté",
            url = Profile,
            thumbnail = { url = Image }, -- avatar à droite
            fields = {
                { name = "Display Name", value = DisplayName, inline = true },
                { name = "Username", value = Username, inline = true },
                { name = "User ID", value = tostring(UserId), inline = true },
                { name = "Rejoint à", value = joinTime, inline = true },
                { name = "PlaceId", value = tostring(game.PlaceId), inline = true },
                { name = "JobId", value = tostring(game.JobId), inline = true },
                { name = "Lien pour rejoindre", value = serverJoin, inline = false } -- lien sur sa propre ligne
            },
            color = 16711680
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- joueurs déjà présents
for _, player in ipairs(Players:GetPlayers()) do
    SendPlayer(player)
end

-- nouveau joueur
Players.PlayerAdded:Connect(SendPlayer)

