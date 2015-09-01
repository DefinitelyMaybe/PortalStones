include("Scripts/Interactable.lua")
include("Scripts/Objects/PlaceableObject.lua")

-------------------------------------------------------------------------------
PortalStone = PlaceableObject.Subclass("PortalStone")

PortalStone.RegisterScriptEvent("ClientEvent_TeleportToLinked",
	{
	position = "vec3"
	}
)

-------------------------------------------------------------------------------
function PortalStone:Constructor(args)
	self.linkedPosition = nil
	self.linkID = nil
	self.targetID = nil
	self.active = false
end

-------------------------------------------------------------------------------
function PortalStone:Interact(args)
	if self.targetID then
		local position = PortalStonesMod.LinkManager:Get(self.targetID)
		if position then
			self:RaiseClientEvent("ClientEvent_TeleportToLinked", 
									{ position = position },
									{ args.player:NKGetInstance().m_connection }
								)
		end
	end
	return true
end

-------------------------------------------------------------------------------
function PortalStone:ClientEvent_TeleportToLinked(args)
	local worldPlayer = Eternus.World:NKGetLocalWorldPlayer()
	worldPlayer:NKTeleportToLocation(args.position)
end

-------------------------------------------------------------------------------
function PortalStone:GetDebuggingText( outData )
	local str = ""
	str = str .. "linkID " .. tostring(self.linkID) .. "\n" 
	local linkPos = PortalStonesMod.LinkManager:Get(self.linkID)
	str = str .. "linkPos " .. (linkPos and linkPos:NKToString() or "nil" ) .. "\n" 
	
	str = str .. "targetID " .. tostring(self.targetID) .. "\n" 
	local targetPos = PortalStonesMod.LinkManager:Get(self.targetID)
	str = str .. "targetPos " .. (targetPos and targetPos:NKToString() or "nil" ) .. "\n" 
	return str
end

-------------------------------------------------------------------------------
function PortalStone:Save( outData )
	PortalStone.__super.Save(self, outData)
	outData.linkID = self.linkID
	outData.targetID = self.targetID
	if self.linkedPosition then
		outData.linkedPosition = {x=self.linkedPosition:x(), y=self.linkedPosition:y(),	z=self.linkedPosition:z()}
	end
end

-------------------------------------------------------------------------------
function PortalStone:Restore( inData, version )
	PortalStone.__super.Restore(self, inData, version)
	self.linkID = inData.linkID
	self.targetID = inData.targetID
end


-------------------------------------------------------------------------------
function PortalStone:NetSerialize( stream )
	PortalStone.__super.NetSerialize(self, stream)
	
	stream:NKWriteBool(self.active)
end

-------------------------------------------------------------------------------
function PortalStone:NetDeserialize( stream )
	PortalStone.__super.NetDeserialize(self, stream)
	
	local active = stream:NKReadBool()
	self:SetActive(active)
end

-------------------------------------------------------------------------------
function PortalStone:SetActive( active )
	if self.active ~= active then
		self.active = active
		NKPrint("PortalStone:SetActive( " .. tostring(active) .. " )")
		if Eternus.IsClient then
			if active then
				self:NKSetEmitterActive(true)
				self:NKGetStaticGraphics():NKSetSubmeshTexture(0, "MagicStonePillar:pCube1", "diffuse_on")
				self:NKGetStaticGraphics():NKSetSubmeshTexture(2, "MagicStonePillar:pCube1", "glow_on")
			else
				self:NKSetEmitterActive(false)
				self:NKGetStaticGraphics():NKSetSubmeshTexture(0, "MagicStonePillar:pCube1", "diffuse_off")
				self:NKGetStaticGraphics():NKSetSubmeshTexture(2, "MagicStonePillar:pCube1", "NULL")
			end
		end
	end
end

-------------------------------------------------------------------------------
function PortalStone:Spawn()
	if Eternus.IsClient then
		self:NKSetEmitterActive(false)
		self:NKGetStaticGraphics():NKSetSubmeshTexture(0, "MagicStonePillar:pCube1", "diffuse_off")
		self:NKGetStaticGraphics():NKSetSubmeshTexture(2, "MagicStonePillar:pCube1", "NULL")
	end
	if Eternus.IsServer then
		self:NKEnableScriptProcessing(true, 1000)
	end
end

-------------------------------------------------------------------------------
function PortalStone:PickedUp()
	self:BreakLink()
end

-------------------------------------------------------------------------------
function PortalStone:OnDestroy()
	self:BreakLink()
end

-------------------------------------------------------------------------------
function PortalStone:BreakLink()
	if Eternus.IsServer then
		if self.linkID then
			PortalStonesMod.LinkManager:Remove(self.linkID)
		end
		self.linkID = nil
		self.targetID = nil
	end
	self:SetActive(false)
end

-------------------------------------------------------------------------------
function PortalStone:GetLinkID()
	if not self.linkID and not self:NKIsPhysicsDynamic() then
		self.linkID = PortalStonesMod.LinkManager:GetUniqueID()
		local position = self:NKGetWorldPosition() + vec3.new(0.0, 0.0, 2.0):mul_quat(self:NKGetWorldOrientation())
		PortalStonesMod.LinkManager:Add(self.linkID, position)
	end
	
	return self.linkID
end

-------------------------------------------------------------------------------
function PortalStone:SetTargetID(linkID)
	if linkID and PortalStonesMod.LinkManager:Get(linkID) then
		self.targetID = linkID
	else
		self.targetID = nil
	end
end
	
-------------------------------------------------------------------------------
function PortalStone:Despawn()
	-- Server only logic
	if Eternus.IsServer then
		self:NKEnableScriptProcessing(false)
	end
end

-------------------------------------------------------------------------------
function PortalStone:Update( )
	-- Server only logic
	if Eternus.IsServer then
		if self.targetID and PortalStonesMod.LinkManager:Get(self.targetID) then
			self:SetActive(true)
		else
			self:SetActive(false)
		end
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalStone)