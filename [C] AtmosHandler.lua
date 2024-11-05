--!strict

local ZoneModule = require(game:GetService("ReplicatedStorage").Zone)
local ClientDataModule = require(game.StarterPlayer.StarterPlayerScripts.ClientDataModule)
local Lighting = game:GetService('Lighting')

local container = workspace: WaitForChild("SafeZoneContainer")
local safeZone = ZoneModule.new(container)

safeZone.localPlayerEntered:Connect(function(player)
	print(("🔵 %s entered the zone!"):format(player.Name))
	ClientDataModule.canDoLidar = false	
	Lighting.Ambient = Color3.new(0.27451, 0.27451, 0.27451)
end)

safeZone.localPlayerExited:Connect(function(player)
	print(("🔵 %s exited the zone!"):format(player.Name))
	Lighting.Ambient = Color3.new(0, 0, 0)
end)
