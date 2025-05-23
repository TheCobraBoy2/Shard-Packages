local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile

function PlayerProfile.new(player, profile, replica)
	local self = setmetatable({}, PlayerProfile)

	self._player = player
	self._profile = profile
	self._replica = replica

	return self
end

-- API
function PlayerProfile:CanAfford(currency: string, amount: number)
	local retrieved = self:Get(currency)

	return retrieved >= amount
end

function PlayerProfile:Increment(currency: string, amount: number)
	local retrieved = self:Get(currency)
	local newAmount = retrieved + amount

	if newAmount < 0 then
		newAmount = 0
	end

	self:Set(currency, newAmount)
end

function PlayerProfile:Decrement(currency: string, amount: number)
	local retrieved = self:Get(currency)
	local newAmount = retrieved - amount

	if newAmount < 0 then
		newAmount = 0
	end

	self:Set(currency, newAmount)
end

-- INTERNAL API
function PlayerProfile:Get(keyToGet: string, tableToSearch: {})
	tableToSearch = tableToSearch or self._profile.Data
	for key, value in tableToSearch do
		if key == keyToGet then
			return value
		end

		if typeof(value) == "table" then
			local result = self:Get(keyToGet, value)
			if result then
				return result
			end
		end
	end

	return nil
end

function PlayerProfile:Set(keyToSet: string, valueToSet: any, tableToSearch: {}, path: { string })
	tableToSearch = tableToSearch or self._profile.Data
	path = path or {}

	for key, currentValue in tableToSearch do
		local newPath = { unpack(path) }
		table.insert(newPath, key)

		if key == keyToSet then
			-- tableToSearch[key] = valueToSet
			self._replica:Set(newPath, valueToSet)
			return true
		end

		if typeof(currentValue) == "table" then
			local result = self:Set(keyToSet, valueToSet, currentValue, newPath)
			if result then
				return true
			end
		end
	end

	return false
end

function PlayerProfile:GetPlayer()
	return self._player
end

function PlayerProfile:GetProfile()
	return self._profile
end

function PlayerProfile:IsActive()
	return self._profile:IsActive()
end

return PlayerProfile
