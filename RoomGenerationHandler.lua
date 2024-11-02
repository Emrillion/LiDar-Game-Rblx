--!strict 

local ServerStorage = game:GetService("ServerStorage")
local roomsFolder = ServerStorage:WaitForChild("Rooms")
local rooms = roomsFolder:GetChildren()
local mapFolder = game.Workspace:WaitForChild("MapFolder")
local startThreshold = mapFolder:WaitForChild("StartThreshold")

local randomRoom = rooms[math.random(1, 4)]

local newRoom = randomRoom:Clone()
