# onSignal
Einfaches Definieren von Callback-Funktionen für Signale (und Weichen)

## Vorteile
1. `EEPRegisterSignal` nicht mehr nötig (kann also nicht vergessen werden)
2. leichter parametrisierbar
3. Fehlermeldungen
4. mehrere Callback-Funktionen für das selbe Signal

## Beispiel-Code
```lua
onSignal, onSwitch = require("onSignal_BH2")()

onSignal[1] = function(position)
  print("Signal 1 ist nun in Position "..position)
end

for id = 10, 20 do
  onSignal[id] = function(position)
    print("Signal "..id.." ist nun in Position "..position)
  end
  onSignal.add[id] = function(position)
    EEPSetSignal(id+1, position, 1)
  end
end
```
