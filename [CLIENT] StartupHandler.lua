--!strict
print("🔵 Client Started")

local Players = game:GetService("Players")
local ClientDataModule = require(game.StarterPlayer.StarterPlayerScripts.ClientDataModule)

local function addCharacter(player)
	if player.Character then
		ClientDataModule.characters[player.UserId] = player.Character
	end

	player.CharacterAdded:Connect(function(character)
		ClientDataModule.characters[player.UserId] = character
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

for userId, character in pairs(ClientDataModule.characters) do
	print(userId, character)
end
