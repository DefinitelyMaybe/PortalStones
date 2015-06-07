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
	toPosition = "vec3"
	}
)

-------------------------------------------------------------------------------
function PortalStone:Constructor(args)
	self.linkedPosition = nil
end

-------------------------------------------------------------------------------
function PortalStone:Interact( args )
	if not self.linkedPosition then
		return false
	elseif self.linkedPosition then
		self:RaiseClientEvent("ClientEvent_TeleportToLinked", {
			playerToAffect = args.player.object
			})
	end
	--Don't drop held object if Portal Stone was linked.
	return true
end

-------------------------------------------------------------------------------
function PortalStone:TryPickup( target )
	self.linkedPosition = nil
	self:NKSetEmitterActive(false)
	return true
end

-------------------------------------------------------------------------------
function PortalStone:Spawn()
	if self.linkedPosition then
		if self.IsLive() then
			self:NKSetEmitterActive(true)
		else
			self.linkedPosition = nil
			self:NKSetEmitterActive(false)
		end
	else
		self:NKSetEmitterActive(false)
	end
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_SetLink(args)
	self.linkedPosition = vec3.new(args.toPosition:x(), args.toPosition:y(), args.toPosition:z())
	self:NKSetEmitterActive(true)
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_TeleportToLinked(args)
	local worldPlayer = args.playerToAffect:NKGetWorldPlayer()
	worldPlayer:NKTeleportToLocation(self.linkedPosition)
end

-------------------------------------------------------------------------------
function PortalStone:IsLive()
	--checking whether a portal stone is still at the exit.
	local minPos = vec3.new(-.5)
	local maxPos = vec3.new(.5)
	local gameobjects = NKPhysics.AABBOverlapCollect(minPos, maxPos, self.linkedPosition)
	if gameobjects then
		for objID, objData in pairs(gameobjects) do
			local objName = objData:NKGetName()
			if objName == "Portal Stone" then
				return true
			end
		end
	end
	return false
end
-------------------------------------------------------------------------------
function PortalStone:Save( outData )
	PortalStone.__super.Save(self, outData)
	if self.linkedPosition then
		outData.linkedPosition = {x=self.linkedPosition:x(), y=self.linkedPosition:y(),	z=self.linkedPosition:z()}
	end
end

-------------------------------------------------------------------------------
function PortalStone:Restore( inData, version )
	if inData.linkedPosition then
		self.linkedPosition = vec3.new(inData.linkedPosition.x, 
			inData.linkedPosition.y, inData.linkedPosition.z)
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalStone)