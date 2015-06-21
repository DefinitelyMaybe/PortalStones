--LinkContainer
-------------------------------------------------------------------------------
if LinkContainer == nil then
	LinkContainer = EternusEngine.Class.Subclass("LinkContainer")
end

-------------------------------------------------------------------------------
function LinkContainer:Constructor(mod)
	self.m_mod = mod
	self.m_links = {}
	self.m_id = 0
end

-------------------------------------------------------------------------------
function LinkContainer:Add(id, data)
	if id then
		self.m_links[tostring(id)] = data
	end
end

-------------------------------------------------------------------------------
function LinkContainer:Remove(id)
	if id then
		self.m_links[tostring(id)] = nil
	end
end

-------------------------------------------------------------------------------
function LinkContainer:Get(id)
	if id then
		return self.m_links[tostring(id)]
	else
		return nil
	end
end

-------------------------------------------------------------------------------
function LinkContainer:GetUniqueID()
	self.m_id = self.m_id + 1
	return tostring(self.m_id)
end

-------------------------------------------------------------------------------
function LinkContainer:Save()
	self.m_mod:NKSaveTable("LinkContainer", {links = self.m_links, id = self.m_id})
end

-------------------------------------------------------------------------------
function LinkContainer:Restore()
	local data = self.m_mod:NKRestoreTable("LinkContainer")
	self.m_links = data.links or {}
	self.m_id = data.id or 0
end

-------------------------------------------------------------------------------
return LinkContainer