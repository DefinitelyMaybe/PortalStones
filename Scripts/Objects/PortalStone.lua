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
	self.linkedposition = vec3.new(0.0, 0.0, 0.0)
	self.linkedobject = nil
	self.direction_vec = nil
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalStone:Interact( args )
	if self.direction_vec then
		NKPrint(self.direction_vec)
	end
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

	--I'm not sure about the vec 3.
	--I normalize the vector so that I know I have a vector with length 1 to multiple by in the next lines.
	self.direction_vec = (vec3(1.0, 0.0, 1.0):mul_quat(self:NKGetWorldOrientation())):normalize()
	--NKWarn(self.direction_vec:NKToString())
	--So my hope is that this is 2 units away from the Portal stone in the direction of this object
	self.direction_vec = self.direction_vec:mul_scalar(2.0)

end

-------------------------------------------------------------------------------
function PortalStone:Despawn()
	--Reseting the linked Stone's values first.
	if self.linked then
		self.linkedobject:RaiseClientEvent("ClientEvent_ResetLink", {})
	end
	self:RaiseClientEvent("ClientEvent_ResetLink", {})
	self.direction_vec = nil
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_SetLink(args)
	local x, y, z = args.toPosition:x(), args.toPosition:y(), args.toPosition:z()
	self.linkedposition = vec3.new(x+1, y+1, z+1)
	self.linkedobject = args.toObject:NKGetInstance()
	self.linked = true
	self:NKSetEmitterActive(true)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_ResetLink()
	self.linked = false
	self.linkedposition = vec3.new(0.0, 0.0, 0.0)
	self.linkedobject = nil
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_TeleportToLinked(args)
	local worldPlayer = args.playerToAffect:NKGetWorldPlayer()

	--Adding the other stones direction vector to the teleport location.
	worldPlayer:NKTeleportToLocation(self.linkedposition + self.linkedobject.direction_vec)
end

-------------------------------------------------------------------------------
function PortalStone:Save( outData )
	PortalStone.__super.Save(self, outData)
	if self.linked then
		outData.linked = true
		outData.linkedposition = {x=self.linkedposition:x(), y=self.linkedposition:y(),	z=self.linkedposition:z()}
	end
end

-------------------------------------------------------------------------------
function PortalStone:Restore( inData, version )
	if inData.linked then
		self.linked = true
		self.linkedposition = vec3.new(inData.linkedposition.x, inData.linkedposition.y, inData.linkedposition.z)

		--Getting the linked objects instance for resetting links between sessions.
		local minPos = vec3.new(-.5)
		local maxPos = vec3.new(.5)
		local gameobjects = NKPhysics.AABBOverlapCollect(minPos, maxPos, self.linkedposition)
		if gameobjects then
			for objID, objData in pairs(gameobjects) do
				local objName = objData:NKGetName()
				if objName == "Portal Stone" then
					self.linkedobject = objData:NKGetInstance()
					objData:NKGetInstance().linkedobject = self:NKGetInstance()
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalStone)