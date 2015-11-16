PortalLinker = EternusEngine.Mixin.Subclass("PortalLinker")


PortalLinker.__mixinoverrides =
	{
		"AffectObject",
		"CanToolAffectObject",
		"PrimaryAction"
	}

-------------------------------------------------------------------------------
function PortalLinker:Constructor( args )
	self.m_linkID = nil
end
-------------------------------------------------------------------------------
function PortalLinker:Spawn()
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalLinker:CanToolAffectObject( args )
	if args then
		if args:NKGetName() == "Portal Stone" then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- The default Primary Action that an equipable object should execute
function PortalLinker:AffectObject( args )
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		-- Bonus emitter on the crystal to indicate linking
		self:NKSetEmitterActive(true)

		local Stone = args.targetObj
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
	end
end

-------------------------------------------------------------------------------
function ReturnStone:PrimaryAction(args)
	if not self.m_bound then
		if args.targetObj then
			self:DefaultPrimaryAction(args)
			return
		else
			return
		end
	end

	self.m_player = args.player
	args.player:RaiseClientEvent("Play3DSound", { sound = "SeedlingNeuriaLoss" } )
	self:RaiseClientEvent("ClientEvent_TeleportToStone", { object = args.player})

	self:ModifyHitPoints(-1)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)