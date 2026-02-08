OPC = OPC or {}
OBC = OBC or {}
EX_CMD = {}
PRX_CMD = {}
ON_DRIVER_LATEINIT = {}

---Invoked by director after all drivers in the project have been loaded. This
---API is provided for the driver developer to contain all of the driver
---objects that will require initialization after all drivers in the project
---have been loaded.
---
---@param strDit string
function OnDriverLateInit(strDit)
	C4:ErrorLog("INIT_CODE: OnDriverLateInit()")

	if (not C4.GetDriverConfigInfo or not (VersionCheck (C4:GetDriverConfigInfo ('minimum_os_version')))) then
		local errtext = {
			'DRIVER DISABLED - ',
			C4:GetDriverConfigInfo ('model'),
			'driver',
			C4:GetDriverConfigInfo ('version'),
			'requires at least C4 OS',
			C4:GetDriverConfigInfo ('minimum_os_version'),
			': current C4 OS is',
			C4:GetVersionInfo ().version,
		}
		errtext = table.concat (errtext, ' ')

		C4:UpdateProperty ('Driver Version', errtext)
		for property, _ in pairs (Properties) do
			C4:SetPropertyAttribs (property, 1)
		end
		C4:SetPropertyAttribs ('Driver Version', 0)
		return
	end

	-- Call all ON_DRIVER_LATEINIT functions
	for k,v in pairs(ON_DRIVER_LATEINIT) do
		if (ON_DRIVER_LATEINIT[k] ~= nil and type(ON_DRIVER_LATEINIT[k]) == "function") then
			C4:ErrorLog("INIT_CODE: ON_DRIVER_LATEINIT." .. k .. "()")
			ON_DRIVER_LATEINIT[k](strDit)
		end
	end
end

---@param requires_version string
---@return boolean
function VersionCheck (requires_version)
	local curver = {}
	curver [1], curver [2], curver [3], curver [4] = string.match (C4:GetVersionInfo ().version, '^(%d*)%.?(%d*)%.?(%d*)%.?(%d*)')
	local reqver = {}
	reqver [1], reqver [2], reqver [3], reqver [4] = string.match (requires_version, '^(%d*)%.?(%d*)%.?(%d*)%.?(%d*)')

	for i = 1, 4 do
		local cur = tonumber (curver [i]) or 0
		local req = tonumber (reqver [i]) or 0
		if (cur > req) then
			return true
		end
		if (cur < req) then
			return false
		end
	end
	return true
end

---Function called by Director when a command is received for this DriverWorks
---driver. This includes commands created in Composer programming.
---
---@param sCommand string Command to be sent
---@param tParams table Lua table of parameters for the sent command
---@return unknown
function ExecuteCommand(sCommand, tParams)
	Dbg:Debug("ExecuteCommand(" .. sCommand .. ")")

    pcall(function()
        if(tParams == nil) then
            Dbg:Trace("-- Params empty.")
        else
            Dbg:Trace(Dump(tParams))
        end
    end)

	-- Remove any spaces (trim the command)
	local trimmedCommand = string.upper(string.gsub(sCommand, " ", "_"))
	local status, ret

	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		status, ret = pcall(EX_CMD[sCommand], tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		status, ret = pcall(EX_CMD[trimmedCommand], tParams)
	else
		Dbg:Info("ExecuteCommand: Unhandled command = " .. sCommand)
		status = true
	end

	if (not status) then
		Dbg:Error("LUA_ERROR: " .. ret)
	end

	return ret -- Return whatever the function returns because it might be xml, a return code, and so on
end

---Function called for any actions executed by the user from the Actions Tab in Composer.
---
---@param idBinding integer Binding ID of the proxy that sent a BindMessage to the DriverWorks driver.
---@param sCommand string Command that was sent
---@param tParams table Lua table of received command parameters
function ReceivedFromProxy(idBinding, sCommand, tParams)
	if (sCommand ~= nil) then
		-- initial table variable if nil
		if (tParams == nil) then
			tParams = {}
		end

		Dbg:Trace("ReceivedFromProxy(): " .. sCommand .. " on binding " .. idBinding .. "; Call Function PRX_CMD." .. sCommand .. "()")
--		LogInfo(tParams)

		if ((PRX_CMD[sCommand]) ~= nil) then
			local status, err = pcall(PRX_CMD[sCommand], idBinding, tParams)
			if (not status) then
				Dbg:Error("LUA_ERROR: " .. err)
			end
		else
			Dbg:Info("ReceivedFromProxy: Unhandled command = " .. sCommand)
		end
	end
end

function OnPropertyChanged (strProperty)
	Dbg:Trace("OnPropertyChanged (" .. strProperty .. " " .. Properties[strProperty] .. ")")

	local value = Properties [strProperty]
	if (type (value) ~= 'string') then
		value = ''
	end

	local init = {
		'OnPropertyChanged: ' .. strProperty,
		value,
	}

	strProperty = string.gsub (strProperty, '%s+', '_')

	local success, ret

	if (OPC and OPC [strProperty] and type (OPC [strProperty]) == 'function') then
		success, ret = pcall (OPC [strProperty], value)
	end

	if (success == true) then
		return (ret)
	elseif (success == false) then
		Dbg:Error ('OnPropertyChanged error: ' .. ret .. " " .. strProperty .. " " .. value)
	end
end

function OnBindingChanged (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	local tParams = {
		strClass = strClass,
		bIsBound = tostring (bIsBound),
		otherDeviceId = otherDeviceId,
		otherBindingId = otherBindingId,
	}

	Dbg:Debug('OnBindingChanged: ' .. idBinding .. " " .. Dump(tParams))

	local success, ret

	if (OBC and OBC [idBinding] and type (OBC [idBinding]) == 'function') then
		success, ret = pcall (OBC [idBinding], idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	end

	if (success == true) then
		return (ret)
	elseif (success == false) then
		Dbg:Error ('OnBindingChanged error: ' .. ret .. " " .. idBinding .. " " .. strClass .. " " .. bIsBound .. " " .. otherDeviceId .. " " .. otherBindingId)
	end
end