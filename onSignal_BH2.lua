local onSignal = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Einfaches Definieren von Callback-Funktionen für Signale (und Weichen)',
  _URL         = 'https://github.com/EEP-Benny/onSignal',
  _LICENSE     = "MIT",
}

local function makeTable(isForSignal)
  local function getFuncName(id)
    if isForSignal then
      return ("EEPOnSignal_%d"):format(id)
    else
      return ("EEPOnSwitch_%d"):format(id)
    end
  end
  local function registerAndCheck(id)
    local ok
    if isForSignal then
      ok = EEPRegisterSignal(id)
    else
      ok = EEPRegisterSwitch(id)
    end
    if ok ~= 1 then
      local message
      if isForSignal then
        message = "Kann keine Callback-Funktion für Signal #%04d anlegen, da es nicht existiert"
      else
        message = "Kann keine Callback-Funktion für Weiche #%04d anlegen, da sie nicht existiert"
      end
      error(message:format(id), 2)
    end
  end
  return setmetatable({}, {
    __index = function(_, id)
      if type(id) == "number" then
        return _ENV[getFuncName(id)]
      end
    end,
    __newindex = function(_, id, func)
      if type(id) == "number" then
        registerAndCheck(id)
        local funcName = getFuncName(id)
        if _ENV[funcName] ~= nil then
          local message
          if isForSignal then
            message = "Kann keine Callback-Funktion für Signal #%04d anlegen, da die Funktion %s bereits existiert"
          else
            message = "Kann keine Callback-Funktion für Weiche #%04d anlegen, da die Funktion %s bereits existiert"
          end
          error(message:format(id, funcName), 2)
        end
        _ENV[funcName] = func
      else -- no signal id, maybe someone tries monkeypatching
        rawset(_, id, func)
      end
    end,
  })
end
onSignal.onSignal = makeTable(true)
onSignal.onSwitch = makeTable(false)

setmetatable(onSignal, {
  __call = function(_, options)
    return onSignal.onSignal, onSignal.onSwitch
  end
})

return onSignal
