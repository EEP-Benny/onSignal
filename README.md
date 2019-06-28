# onSignal
`onSignal` vereinfacht das Definieren von Callback-Funktionen für Signale (und Weichen).

Die gewünschte Funktion wird einfach in die Tabelle `onSignal[id]` geschrieben. Ein Aufruf von `EEPRegisterSignal()` ist nicht mehr nötig, kann also auch nicht vergessen werden.
Die `id` kann sowohl eine Zahl als auch eine Variable sein.
Damit kann auch das umständliche `_ENV["EEPOnSignal_"..id]`-Konstrukt entfallen.
Außerdem erzeugt `onSignal` Fehlermeldungen, wenn eine Callback-Funktion für ein nicht existierendes Signal definiert wird, oder eine vorhandene Callback-Funktion überschrieben würde.
Fehler will zwar niemand, aber eine sofortige Fehlermeldung ist besser als ein Fehler ohne Meldung, der sich erst viel später bemerkbar macht.

### Schnellstart-Anleitung

#### 1. Installieren
Nach dem Download die zip-Datei in EEP über den Menüpunkt „Modelle installieren“ installieren (gibt es erst ab EEP13), ansonsten die zip-Datei entpacken und die `Installation.eep` aufrufen, oder die `onSignal_BH2.lua` von Hand ins EEP-Verzeichnis in den Unterordner `LUA` kopieren.

#### 2. Einbinden
Füge diese Zeile an den Anfang des Anlagen-Skripts ein (die zusätzlichen runden Klammern am Ende sind wichtig!):

```lua
onSignal, onSwitch = require("onSignal_BH2")()
```

#### 3. Verwenden
Um eine Callback-Funktion für das Signal mit der ID 1 zu definieren, speichere die gewünschte Funktion in `onSignal[1]`:
```lua
onSignal[1] = function(position)
  print("Signal 1 ist nun in Position "..position)
end
```
Das bewirkt das gleiche wie folgender Code:
```lua
EEPRegisterSignal(1)
function EEPOnSignal_1(position)
  print("Signal 1 ist nun in Position "..position)
end
```
Der `onSignal`-Code ist zwar nicht viel kürzer, bietet aber noch weitere Vorteile (siehe Einführungstext).

Callback-Funktionen für Weichen können über `onSwitch[id]` erzeugt werden:
```lua
onSwitch[2] = function(position)
  print("Signal 2 ist nun in Position "..position)
end
```

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
