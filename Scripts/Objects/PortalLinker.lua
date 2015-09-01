include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
PortalLinker = Equipable.Subclass("PortalLinker")

-- Static Vars
PortalLinker.DefaultAmbientSound   =	""

-------------------------------------------------------------------------------
function PortalLinker:Constructor(args)
	self.m_linkID = nil

	self.m_crystalSoundInstances = 0
	self.m_encumberance = 0.0 
	self.m_requestedEnergy = false
	self.m_requestTimer = 0.0

	if args == nil then
		return
	end
	
	if args.encumberance ~= nil then
		self.m_encumberance = args.encumberance
	end

	--Check for an ambient sound
	self.m_ambSound = PortalLinker.DefaultAmbientSound
	--if args then
	--	if args.ambSound ~= nil then
	--		self.m_ambSound = args.ambSound
	--	end
	--end
end

-------------------------------------------------------------------------------
function PortalLinker:PostLoad()
	PortalLinker.__super.PostLoad(self)
end

-------------------------------------------------------------------------------
function PortalLinker:Spawn()
	self:NKSetEmitterActive(false)
	self:NKGetLight():NKSetRadius(0)
	self.m_requestedEnergy = false

	if self.m_ambSound ~= "" then
		self:NKGetSound():NKStop3DSound(self.m_ambSound)
	end
end

-------------------------------------------------------------------------------
function PortalLinker:Despawn()
	self:NKGetLight():NKSetRadius(0)

	if self.m_ambSound ~= "" then
		self:NKGetSound():NKStop3DSound(self.m_ambSound)
	end
	-- Turn off the event listener for the alchemy table
	Eternus.EventSystem:NKBroadcastEventInRadius("Event_NotSeekingEnergy", self:NKGetPosition(), 6.0, self)	
end

-------------------------------------------------------------------------------
function PortalLinker:Update(dt)
	if self.m_requestedEnergy == false then
		self.m_requestTimer = self.m_requestTimer + dt
		if self.m_requestTimer > 1.0 then
			Eternus.EventSystem:NKBroadcastEventInRadius("Event_SeekingEnergy", self:NKGetPosition(), 6.0, self)	
			self.m_requestedEnergy = true
		end
	end
end

-------------------------------------------------------------------------------
-- This needs to be here due to how the save system currently works.  When children (emitters)
-- are added back to this object at load time, the engine automatically sets them active.
function PortalLinker:ChildAdded(obj)
	
end

-------------------------------------------------------------------------------
-- Increments the instance count for number of sound instances and starts
-- playing the sound if the number of instances goes from 0 to 1.
function PortalLinker:PlayCrystalSound()
	if (self.m_crystalSoundInstances == 0) then
		if (self.m_ambSound ~= "") then
			self:NKGetSound():NKPlay3DSound(self.m_ambSound, true, vec3.new(0, 0, 0), 5.0, 25.0)
		end
		
		self:NKGetLight():NKSetRadius(5)
	end
	
	self.m_crystalSoundInstances = self.m_crystalSoundInstances + 1
end

-------------------------------------------------------------------------------
-- Decrements the instance count for number of sound instances and stops
-- playing the sound if the number of instances reaches 0.
function PortalLinker:StopCrystalSound()
	self.m_crystalSoundInstances = self.m_crystalSoundInstances - 1
	if (self.m_crystalSoundInstances < 0) then
		self.m_crystalSoundInstances = 0
	end
	
	if (self.m_crystalSoundInstances == 0) then
		if (self.m_ambSound ~= "") then
			self:NKGetSound():NKStop3DSound(self.m_ambSound)
		end
		
		self:NKGetLight():NKSetRadius(0)
	end
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction(args)
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		-- Bonus emitter on the crystal to indicate linking
		self:NKSetEmitterActive(true)

		local Stone = args.targetObj:NKGetInstance()
		if self.m_linkID then
			if not (Stone:GetLinkID() == self.m_linkID) then
				if Stone and Stone.SetTargetID then
					self.m_linkID = Stone:SetTargetID(self.m_linkID)
					self.m_linkID = nil
					self:ModifyStackSize(-1)
					self:NKSetEmitterActive(false)
				end
			end
		else
			if Stone and Stone.GetLinkID then
				self.m_linkID = Stone:GetLinkID()
			end
		end
		-- Don't drop Linker if it was a Portal Stone.
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)