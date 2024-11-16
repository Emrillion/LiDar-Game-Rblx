--!strict

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local funnelSessionId = HttpService:GenerateGUID()
local analyticsZoneA = workspace:WaitForChild("AnalyticsZoneA")

local zoneCenter = analyticsZoneA.Position
local zoneSize = analyticsZoneA.Size
local zoneCFrame = CFrame.new(zoneCenter)
local playersLoggedInZoneA = {}
local isPlayerLoggedA = false


Players.PlayerAdded:Connect(function(player)
	-- Log when user joins
	AnalyticsService:LogFunnelStepEvent(
		player,
		"Basic Lidar Data", -- Funnel name used to group steps together
		funnelSessionId, -- Funnel session id for this unique checkout session
		1, -- Step number
		"Player Joined" -- Step name
	)
end)


RunService.Heartbeat:Connect(function()
	local partsInZone = workspace:GetPartBoundsInBox(zoneCFrame, zoneSize)

	for _, part in pairs(partsInZone) do
		local player = Players:GetPlayerFromCharacter(part.Parent)
		if player then
			print(player.Name .. " is in the zone!")
			for i, value in ipairs(playersLoggedInZoneA) do
				if player == value then
					isPlayerLoggedA = true
				end
			end
			if isPlayerLoggedA ~= true then
				table.insert(playersLoggedInZoneA, player)
				AnalyticsService:LogFunnelStepEvent(
					player,
					"Basic Lidar Data", 
					funnelSessionId,
					2, 
					"Player Entered Zone A" 
				)
			end
		end
	end
end)




--FOR ONBORDING
--Players.PlayerAdded:Connect(function(player)
--	AnalyticsService:LogOnboardingFunnelStepEvent(
--		player,
--		1, -- Step number
--		"Player Joined" -- Step name
--	)
--end)
