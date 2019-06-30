# onSignal
`onSignal` vereinfacht das Definieren von Callback-Funktionen für Signale (und Weichen) und verhindert dabei schwer zu findende Fehler.

Die gewünschte Funktion wird einfach in die Tabelle `onSignal[id]` geschrieben. Ein Aufruf von `EEPRegisterSignal()` ist nicht mehr nötig, kann also auch nicht vergessen werden.
Die `id` kann sowohl eine feste Zahl als auch eine Variable sein.
Damit kann das umständliche `_ENV["EEPOnSignal_"..id]`-Konstrukt entfallen.

Außerdem meldet `onSignal`, wenn die Signal-ID ungültig ist, eine Callback-Funktion für ein nicht existierendes Signal definiert wird, oder eine vorhandene Callback-Funktion überschrieben würde.
Ein sofort gemeldeter Fehler ist deutlich einfacher zu beheben als ein Fehler ohne Meldung, der sich erst viel später bemerkbar macht.

### Schnellstart-Anleitung

#### 1. Installieren
Nach dem [Download](http://emaps-eep.de/lua/onsignal) die zip-Datei in EEP über den Menüpunkt „Modelle installieren“ installieren (gibt es erst ab EEP13), ansonsten die zip-Datei entpacken und die `Installation.eep` aufrufen, oder die `onSignal_BH2.lua` von Hand ins EEP-Verzeichnis in den Unterordner `LUA` kopieren.

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
Der `onSignal`-Code ist zwar nicht viel kürzer, bietet aber noch andere Vorteile (siehe Einführungstext).

Callback-Funktionen für Weichen können über `onSwitch[id]` erzeugt werden:
```lua
onSwitch[2] = function(position)
  print("Weiche 2 ist nun in Position "..position)
end
```

### Technische Details
Eigentlich hatte ich geplant, dass man `EEPOnSignal_1` 1:1 durch `onSignal[1]` ersetzen kann.
Doch da hat mir Lua einen Strich durch die Rechnung gemacht: `function onSignal[1](position)` gilt als Syntax-Fehler.
Deshalb ist nur die Schreibweise `onSignal[1] = function(position)` möglich (die man auch für `EEPOnSignal_1` verwenden könnte).

In der Regel wird eine Callback-Funktion einmal definiert, und dann von EEP aufgerufen.
Sollte es aus irgendeinem Grund doch mal nötig sein, eine vorhandene Callback-Funktion per Lua aufzurufen, so ist der Zugriff auf `onSignal[1]` auch lesend (statt schreibend) möglich.

Als ID kann alles verwendet werden, was von der Lua-Funktion `tonumber()` in eine Zahl umgewandelt werden kann.
Das beinhaltet natürlich Zahlen, aber auch numerische Strings (die nur eine Zahl enthalten).
Alles andere (`nil`, Tabellen, ungültige Strings, ...) führt zu einer Fehlermeldung.

```lua
-- funktioniert (wenn es ein Signal mit der ID 123 auf der Anlage gibt)
onSignal["123"] = function() end

-- Fehler, weil keine gültige ID
onSignal["abc"] = function() end
```

Weil die ID des Signals nicht mehr Teil des Funktionsnamens ist, kann auch einfach eine Variable benutzt werden.
Mit einer Schleife können dann Callback-Funktionen für mehrere Signale auf einmal erzeugt werden:
```lua
for id = 10, 20 do
  onSignal[id] = function(position)
    print("Signal "..id.." ist nun in Position "..position)
  end
end
```
Sowas war bisher nur mit dem umständlichen `_ENV["EEPOnSignal_"..id]`-Konstrukt möglich.

### Changelog
Siehe [EMAPS](http://emaps-eep.de/lua/onsignal) oder [GitHub-Release-Seite](/releases).
