local onSignal = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Einfaches Definieren von Callback-Funktionen für Signale (und Weichen)',
  _URL         = 'https://github.com/EEP-Benny/onSignal',
  _LICENSE     = "MIT",
}

local function makeTable(isForSignal)
  local function assertId(id)
    local idAsNumber = tonumber(id)
    if idAsNumber == nil then
      local message
      if isForSignal then
        message = "Kann keine Callback-Funktion anlegen, da %s (Typ %s) keine gültige Signal-ID ist"
      else
        message = "Kann keine Callback-Funktion anlegen, da %s (Typ %s) keine gültige Weichen-ID ist"
      end
      error(message:format(id, type(id)), 3)
    else
      return idAsNumber
    end
  end
  
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
      error(message:format(id), 3)
    end
  end
  
  return setmetatable({}, {
    __index = function(_, id)
      id = assertId(id)
      return _ENV[getFuncName(id)]
    end,
    __newindex = function(_, id, func)
      id = assertId(id)
      registerAndCheck(id)
      local funcName = getFuncName(id)
      if _ENV[funcName] ~= nil and func ~= nil then
        local message
        if isForSignal then
          message = "Kann keine Callback-Funktion für Signal #%04d anlegen, da die Funktion %s bereits existiert"
        else
          message = "Kann keine Callback-Funktion für Weiche #%04d anlegen, da die Funktion %s bereits existiert"
        end
        error(message:format(id, funcName), 2)
      end
      _ENV[funcName] = func
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
