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
  local mytable = { add = {}, listeners = {} }
  setmetatable(mytable, {
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
  setmetatable(mytable.add, {
    __newindex = function(_, id, func)
      if type(id) == "number" then
        if type(mytable.listeners[id]) ~= "table" then
          registerAndCheck(id)
          local funcName = getFuncName(id)
          mytable.listeners[id] = {}
          if _ENV[funcName] then
            table.insert(mytable.listeners[id], _ENV[funcName])
          end
          _ENV[funcName] = function(...)
            for _, listener in ipairs(mytable.listeners[id]) do
              listener(...)
            end
          end
        end
        table.insert(mytable.listeners[id], func)
      else -- no signal id, maybe someone tries monkeypatching
        rawset(_, id, func)
      end
    end,
  })
  return mytable
end
onSignal.onSignal = makeTable(true)
onSignal.onSwitch = makeTable(false)

local function isSignal(id)
  return EEPGetSignal(id) ~= 0
end
local function isSwitch(id)
  return EEPGetSwitch(id) ~= 0
end

onSignal.onSignalOrSwitch = { add = {}, listeners = {} }
setmetatable(onSignal.onSignalOrSwitch, {
  __index = function(_, id)
    return onSignal.onSignal[id] or onSignal.onSwitch[id]
  end,
  __newindex = function(_, id, func)
    if isSignal(id) then
      onSignal.onSignal[id] = func
    elseif isSwitch(id) then
      onSignal.onSwitch[id] = func
    else
      error(("Weder Signal noch Weiche #%04d existieren, kann daher keine Callback-Funktion anlegen"):format(id), 2)
    end
  end,
})
setmetatable(onSignal.onSignalOrSwitch.add, {
  __newindex = function(_, id, func)
    if isSignal(id) then
      onSignal.onSignal.add[id] = func
    elseif isSwitch(id) then
      onSignal.onSwitch.add[id] = func
    else
      error(("Weder Signal noch Weiche #%04d existieren, kann daher keine Callback-Funktion anlegen"):format(id), 2)
    end
  end,
})
setmetatable(onSignal.onSignalOrSwitch.listeners, {
  __index = function(_, id)
    return onSignal.onSignal.listeners[id] or onSignal.onSwitch.listeners[id]
  end,
})

setmetatable(onSignal, {
  __call = function(_, options)
    return onSignal.onSignal, onSignal.onSwitch, onSignal.onSignalOrSwitch
  end
})

return onSignal
