local Log = {}

function Log:Create()
    local lt = {}
    print("created log")
    lt._logLevel = 0
    lt._outputPrint = false
    lt._outputC4Log = false
    lt._logName =  "Set Log Name to display"

    function lt:SetLogLevel(level)
        self._logLevel = level
    end

    function lt:OutputPrint(value)
        self._outputPrint = value
    end

    function lt:OutputC4Log(value)
        self._outputC4Log = value
    end

    function lt:SetLogName(name)
        self._logName = name
    end

    function lt:Enabled()
        return (self._outputPrint or self._outputC4Log)
    end

    function lt:PrintTable(tValue, sIndent)
        if (type(tValue) == "table") then
            if (self._outputPrint) then
                for k,v in pairs(tValue) do
                    print(sIndent .. tostring(k) .. ":  " .. tostring(v))
                    if (type(v) == "table") then
                        self:PrintTable(v, sIndent .. "   ")
                    end
                end
            end

            if (self._outputC4Log) then
                for k,v in pairs(tValue) do
                    C4:ErrorLog(self._logName .. ": " .. sIndent .. tostring(k) .. ":  " .. tostring(v))
                    if (type(v) == "table") then
                        self:PrintTable(v, sIndent .. "   ")
                    end
                end
            end

        else
            if (self._outputPrint) then
                print (sIndent .. tValue)
            end

            if (self._outputC4Log) then
                C4:ErrorLog(self._logName .. ": " .. sIndent .. tValue)
            end
        end
    end

    function lt:Print(logLevel, sLogText)
        if (self._logLevel >= logLevel) then
            if (type(sLogText) == "table") then
                self:PrintTable(sLogText, "   ")
                return
            end

            if (self._outputPrint) then
                print (sLogText)
            end

            if (self._outputC4Log) then
                C4:ErrorLog(self._logName .. ": " .. sLogText)
            end
        end
    end

    function lt:Fatal(strDebugText)
        self:Print(1, os.date("%c") .. " Fatal   ## " .. strDebugText)
    end

    function lt:Error(strDebugText)
        self:Print(2, os.date("%c") .. " Error   ##  " .. strDebugText)
    end

    function lt:Warn(strDebugText)
        self:Print(3, os.date("%c") .. " Warning ##   " .. strDebugText)
    end

    function lt:Info(strDebugText)
        self:Print(4, os.date("%c") .. " Info    ##    " .. strDebugText)
    end

    function lt:Debug(strDebugText)
        self:Print(5, os.date("%c") .. " Debug   ##     " .. strDebugText)
    end

    function lt:Trace(strDebugText)
        self:Print(6, os.date("%c") .. " Trace   ##     " .. strDebugText)
    end

    return lt
end

return Log