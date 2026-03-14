local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1478551048875413639/WPjX-38TsuurXyL5d9EwiR_euNgWG5EOx6Tncfzc0-q1TQ9Pl050K3BKnNC6PtMCJjWK"
local PLACE_ID = game.PlaceId
local TELEPORT_SERVICE = game:GetService("TeleportService")

-- table pour éviter de revisiter le même serveur
local visitedServers = {}

-- fonction pour envoyer un joueur (ton webhook)
local function SendPlayer(player)
    local UserId = player.UserId
    local Username = player.Name
    local DisplayName = player.DisplayName
    local joinTime = os.date("%Y-%m-%d %H:%M:%S")

    local Image = string.format(
        "https://www.roblox.com/avatar-thumbnail/image?userId=%d&width=420&height=420&format=png",
        UserId
    )
    local Profile = string.format("https://www.roblox.com/users/%d/profile", UserId)
    local serverJoin = string.format('Roblox.GameLauncher.joinGameInstance(%d, "%s")', game.PlaceId, tostring(game.JobId))

    local data = {
        embeds = {{
            title = "🔍 Joueur détecté",
            url = Profile,
            thumbnail = { url = Image },
            fields = {
                { name = "Display Name", value = DisplayName, inline = true },
                { name = "Username", value = Username, inline = true },
                { name = "User ID", value = tostring(UserId), inline = true },
                { name = "Rejoint à", value = joinTime, inline = true },
                { name = "PlaceId", value = tostring(game.PlaceId), inline = true },
                { name = "JobId", value = tostring(game.JobId), inline = true },
                { name = "Lien pour rejoindre", value = serverJoin, inline = false }
            },
            color = 16711680
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Fonction pour récupérer la liste des serveurs
local function GetServers(cursor)
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
        PLACE_ID,
        cursor and "&cursor="..cursor or ""
    )
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return HttpService:JSONDecode(response)
    end
end

-- Fonction principale de server hop
local function ServerHop()
    local servers = GetServers()
    if not servers or not servers.data then return end

    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers and not visitedServers[server.id] then
            visitedServers[server.id] = true
            -- téléporte vers ce serveur
            TELEPORT_SERVICE:TeleportToPlaceInstance(PLACE_ID, server.id, Players.LocalPlayer)
            return
        end
    end

    -- si tous les serveurs ont été visités, on attend un peu puis réessaye
    task.wait(5)
    ServerHop()
end

-- Lancement du tracking
for _, player in ipairs(Players:GetPlayers()) do
    SendPlayer(player)
end
Players.PlayerAdded:Connect(SendPlayer)

-- Start server hop
ServerHop()
