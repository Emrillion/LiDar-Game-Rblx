--!strict
print("🟢 Server Started")

local mapFolder = workspace:WaitForChild("TestMap")
local mapParts = mapFolder:GetChildren()
local lightingService = game:GetService("Lighting")

local serverId = game.JobId
local placeId = game.PlaceId
local numPlayers = #game.Players:GetPlayers()
local memoryUsage = gcinfo()  -- Returns memory usage in KB
local serverStartTime = os.time()
print("Server Information:")
print("Server ID:", serverId)
print("Place ID:", placeId)
print("Memory Usage (KB):", memoryUsage)
print("Server Start Time (Unix):", serverStartTime)

lightingService.Brightness = 0

for i in mapParts do
	local part = mapParts[i]
	part.Transparency = 1 	
end


game.Players.PlayerAdded:Connect(function(player)
	print("New player joined: " .. player.Name)
	print("Current number of players: " .. #game.Players:GetPlayers())
end)

game.Players.PlayerRemoving:Connect(function(player)
	print("Player left: " .. player.Name)
	print("Current number of players: " .. #game.Players:GetPlayers())
end)
