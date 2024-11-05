--!strict
--LiDar Script v0.8.4 (by Emrillion) 
--Fixed Square Lidar scaning in different sizes depending on client screen size
---------------------------------------
---------------Variables---------------
---------------------------------------
local RunService = game:GetService('RunService')
local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local PartCacheModule = require(ReplicatedStorage:WaitForChild("PartCache"))
local ClientDataModule = require(game.StarterPlayer.StarterPlayerScripts.ClientDataModule)

local lidarFolder = workspace:WaitForChild("LidarFolder")
local lidarScanFolder = workspace:WaitForChild("LidarScanFolder")
local templateFolder = ReplicatedStorage:WaitForChild("TemplateFolder")
local lidarTemplateParticle = templateFolder:WaitForChild("LidarPart")
local lidarScanTemplate = templateFolder:WaitForChild("ScanPart")

local cameraPosition = Camera.CFrame.Position
local fov = math.rad(Camera.FieldOfView)  
local aspectRatio = Camera.ViewportSize.X / Camera.ViewportSize.Y

local LIDAR_CIRCLE_RADIUS = 2.5
local LIDAR_RANGE = 25
---- Calculate view width and height based on the LIDAR_RANGE
local LIDAR_BOX_Y_SIZE = 2 * LIDAR_RANGE * math.tan(fov / 2)  -- Height
local LIDAR_BOX_X_SIZE = LIDAR_BOX_Y_SIZE * aspectRatio       -- Width
local LIDAR_DENSITY = 10000

local isRightMouseButtonDown = false
local isHoldingMiddleButton = false
local currentFrame = 0

local LidarPCache = PartCacheModule.new(lidarTemplateParticle, 50000, lidarFolder)
--local LidarScanPCache = PartCacheModule.new(lidarScanTemplate, 50, lidarScanFolder)

---------------------------------------
---------------Functions---------------
---------------------------------------

function VisualizeRaycast(origin, destination, removeTime)
	local Distance = (origin - destination).Magnitude
	local Part = Instance.new("Part", workspace)
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanQuery = false
	Part.Size = Vector3.new(0.15, 0.15, Distance)
	Part.CFrame = CFrame.lookAt(origin, destination) * CFrame.new(0, 0, -Distance / 2)
	Part.Color = Color3.fromRGB(255, 17, 17)
	Part.Material = Enum.Material.Plaster
	Part.Transparency = 0.5

end

local function castRay(startPosition, direction)
	local rayParams = RaycastParams.new()
	local ignoreList = {}
	for _, character in pairs(ClientDataModule.characters) do
		table.insert(ignoreList, character)
	end
	table.insert(ignoreList, workspace.CurrentCamera)
	table.insert(ignoreList, workspace.Coolcoolcool3337)

	rayParams.FilterDescendantsInstances = ignoreList
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local rayResult = workspace:Raycast(startPosition, direction * LIDAR_RANGE, rayParams)
	return rayResult
end

local function setPlayerControl(enable)
	
	if enable then
		ContextActionService:UnbindAction("DisableMovement")

		Camera.CameraType = Enum.CameraType.Custom
	else
		ContextActionService:BindAction("DisableMovement", function() return Enum.ContextActionResult.Sink end,
			false, Enum.PlayerActions.CharacterForward,
			Enum.PlayerActions.CharacterBackward,
			Enum.PlayerActions.CharacterLeft,
			Enum.PlayerActions.CharacterRight,
			Enum.PlayerActions.CharacterJump)


		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = Camera.CFrame 
	end
end

local function initializeLidarParticles(raycastResultArray)
	if raycastResultArray then
		coroutine.wrap(function()
			local particlesPerFrame = 400
			local processedParticles = 0

			for i, raycastResult in ipairs(raycastResultArray) do

				--VisualizeRaycast(rayOrigin, raycastResult.Position, 1000)
				if raycastResult.Instance:IsA("BasePart") then
					local lidarParticle = LidarPCache:GetPart()
					lidarParticle.CFrame = CFrame.new(raycastResult.Position)

					processedParticles += 1
					if processedParticles >= particlesPerFrame then
						processedParticles = 0 
						wait() 
					end
				end
			end
			setPlayerControl(true)
		end)()
	end
end

-------------Main Functions-------------
local function doSquareLidar()
	local testTime = tick()
	local testFrame = currentFrame
	
	aspectRatio = Camera.ViewportSize.X / Camera.ViewportSize.Y
	LIDAR_BOX_Y_SIZE = 2 * LIDAR_RANGE * math.tan(fov / 2)
	LIDAR_BOX_X_SIZE = LIDAR_BOX_Y_SIZE * aspectRatio

	local raycastResultArray = {}
	local raycastScreenPositionDictionary = {}
	for count = 0, LIDAR_DENSITY do

		local random = Random.new()
		local randomX = (random:NextNumber() - 0.5) * LIDAR_BOX_X_SIZE
		local randomY = (random:NextNumber() - 0.5) * LIDAR_BOX_Y_SIZE

		local direction = (LIDAR_RANGE * Camera.CFrame.LookVector)
			+ (Camera.CFrame.XVector * randomX) 
			+ (Camera.CFrame.YVector * randomY)

		local rayOrigin = Camera.CFrame.Position
		local raycastResult = castRay(rayOrigin, direction)
		if raycastResult then
			table.insert(raycastResultArray, raycastResult)
			local screenPosition = Camera:WorldToViewportPoint(raycastResult.Position)
			raycastScreenPositionDictionary[raycastResult] = screenPosition

		end
	end	
	-- Sort raycastResultArray based on screen Y value from raycastScreenPositionDictionary
	table.sort(raycastResultArray, function(a, b)
		return raycastScreenPositionDictionary[a].Y < raycastScreenPositionDictionary[b].Y
	end)
	
	print("⬜ Initalizing...")
	setPlayerControl(false)
	initializeLidarParticles(raycastResultArray)
	print("⬜ Square RayCast Time:", testTime - tick(), "seconds")
	print("⬜ Square RayCast Frames:", testFrame - currentFrame)
end

local function doCircleLidar()
	local cameraDirection = Camera.CFrame.LookVector
	local cameraRight = Camera.CFrame.RightVector
	local cameraUp = Camera.CFrame.UpVector

	local angle = math.rad(math.random(0, 360))
	local randomDistance = math.random() * LIDAR_CIRCLE_RADIUS

	local offsetX = math.cos(angle) * randomDistance * cameraRight
	local offsetY = math.sin(angle) * randomDistance * cameraUp

	local rayDirection = (cameraDirection * LIDAR_RANGE) + offsetX + offsetY
	rayDirection = rayDirection.Unit 

	local direction = rayDirection * LIDAR_RANGE

	local startTime = tick()
	local raycastResult = castRay(Camera.CFrame.Position, direction)
	local raycastTime = tick() - startTime
	print("RayCastTime:", raycastTime, "seconds")
	print("Raycast Frame:", currentFrame)

	if raycastResult then
		--VisualizeRaycast(Camera.CFrame.Position, raycastResult.Position, 1000)
		if raycastResult.Instance:IsA("BasePart") then

			local cframeStartTime = tick()
			local lidarParticle = LidarPCache:GetPart()
			lidarParticle.CFrame = CFrame.new(raycastResult.Position)
			local cframeTime = tick() - cframeStartTime
			print("CFrame Setting Time:", cframeTime, "seconds")
			print("CFrame Setting Frame:", currentFrame)
		end
	end
end

---------------------------------------
-----------------Input-----------------
---------------------------------------

local function onUserInputBegin(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then --LeftMouse
		isRightMouseButtonDown = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then -- MiddleMouse
		if not isHoldingMiddleButton then
			isHoldingMiddleButton = true
			doSquareLidar()
			task.wait(0.35)
			isHoldingMiddleButton = false
		end

	elseif input.KeyCode == Enum.KeyCode.U then
		if gameProcessedEvent then return end 
		LIDAR_CIRCLE_RADIUS = LIDAR_CIRCLE_RADIUS + 1
		print("Scroll Variable increased by 'U' key:", LIDAR_CIRCLE_RADIUS)
	elseif input.KeyCode == Enum.KeyCode.Y then
		if gameProcessedEvent then return end 
		LIDAR_CIRCLE_RADIUS = LIDAR_CIRCLE_RADIUS - 1
		print("Scroll Variable decreased by 'Y' key:", LIDAR_CIRCLE_RADIUS)
	end
end

local function onUserInputEnded(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then --LeftMouse
		isRightMouseButtonDown = false
	end
end	

---------------------------------------
--------------Connections--------------
---------------------------------------

UserInputService.InputBegan:Connect(onUserInputBegin)
UserInputService.InputEnded:Connect(onUserInputEnded)

RunService.Heartbeat:Connect(function()
	currentFrame += 1
end)

RunService.RenderStepped:Connect(function()
	if isRightMouseButtonDown then
		task.wait(0.025)
		doCircleLidar()
	end
end)
