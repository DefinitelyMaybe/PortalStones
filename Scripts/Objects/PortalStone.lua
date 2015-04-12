include("Scripts/Interactable.lua")
include("Scripts/Objects/PlaceableObject.lua")

-------------------------------------------------------------------------------
PortalStone = PlaceableObject.Subclass("PortalStone")

local NKPhysics = include("Scripts/Core/NKPhysics.lua")

-------------------------------------------------------------------------------
--Register Events
NKRegisterEvent("ClientEvent_TeleportToLinked",
	{
	playerToAffect = "gameobject"
	}
)

NKRegisterEvent("ClientEvent_SetLink",
	{
	toObject = "gameobject",
	toPosition = "vec3"
	}
)
NKRegisterEvent("ClientEvent_ResetLink",
	{
	}
)


-------------------------------------------------------------------------------
function PortalStone:Constructor(args)
	self.linked = false
	self.linked_Position = vec3.new(0.0, 0.0, 0.0)
	self.direction_Vec = vec3.new(0.0, 0.0, 0.0)
	self.linked_Object = nil
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalStone:Interact( args )
	if not self.linked then
		return false
	end
	self:RaiseClientEvent("ClientEvent_TeleportToLinked", {
		playerToAffect = args.player.object
		})
	--Don't drop held object if Portal Stone was linked.
	return true
end

-------------------------------------------------------------------------------
function PortalStone:Spawn()
	self:NKSetEmitterActive(false)
	if self.linked then
		self:NKSetEmitterActive(true)
	end
	--The vector relative to the stone's direction/rotation.
	self.direction_Vec = vec3.new(0.0, 0.0, 2.0):mul_quat(self:NKGetWorldOrientation())
end

-------------------------------------------------------------------------------
function PortalStone:Despawn()
	--Reseting the linked Stone's values first.
	if self.linked then
		self.linked_Object:RaiseClientEvent("ClientEvent_ResetLink", {})
	end
	self:RaiseClientEvent("ClientEvent_ResetLink", {})
	self.direction_Vec = vec3.new(0.0, 0.0, 0.0)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_SetLink(args)
	self.linked_Position = vec3.new(args.toPosition:x(), args.toPosition:y(), args.toPosition:z())
	self.linked_Object = args.toObject:NKGetInstance()
	self.linked = true
	self:NKSetEmitterActive(true)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_ResetLink()
	self.linked = false
	self.linked_Position = vec3.new(0.0, 0.0, 0.0)
	self.linked_Object = nil
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_TeleportToLinked(args)
	local worldPlayer = args.playerToAffect:NKGetWorldPlayer()

	--Adding the other stones direction vector to the teleport location.
	worldPlayer:NKTeleportToLocation(self.linked_Position + self.linked_Object.direction_Vec)
end

-------------------------------------------------------------------------------
function PortalStone:Save( outData )
	PortalStone.__super.Save(self, outData)
	if self.linked then
		outData.linked = true
		outData.linked_Position = {x=self.linked_Position:x(), y=self.linked_Position:y(),	z=self.linked_Position:z()}
	end
end

-------------------------------------------------------------------------------
function PortalStone:Restore( inData, version )
	if inData.linked then
		self.linked = true
		self.linked_Position = vec3.new(inData.linked_Position.x, inData.linked_Position.y, inData.linked_Position.z)

		--Getting the linked objects instance for resetting links between sessions.
		local minPos = vec3.new(-.5)
		local maxPos = vec3.new(.5)
		local gameobjects = NKPhysics.AABBOverlapCollect(minPos, maxPos, self.linked_Position)
		if gameobjects then
			for objID, objData in pairs(gameobjects) do
				local objName = objData:NKGetName()
				if objName == "Portal Stone" then
					self.linked_Object = objData:NKGetInstance()
					objData:NKGetInstance().linked_Object = self:NKGetInstance()
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalStone)