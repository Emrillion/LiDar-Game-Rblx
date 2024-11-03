--!strict
print("🔵 Client Started")

local Players = game:GetService("Players")
local SharedClientDataModule = require(game.StarterPlayer.StarterPlayerScripts.SharedClientDataModule)

local function addCharacter(player)
	if player.Character then
		SharedClientDataModule.characters[player.UserId] = player.Character
	end

	player.CharacterAdded:Connect(function(character)
		SharedClientDataModule.characters[player.UserId] = character
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	addCharacter(player)
end

Players.PlayerAdded:Connect(addCharacter)

-- Optional: Remove character on player leave
--Players.PlayerRemoving:Connect(function(player)
--	SharedClientDataModule.characters[player.UserId] = nil
--end)

for userId, character in pairs(SharedClientDataModule.characters) do
	print(userId, character)
end
